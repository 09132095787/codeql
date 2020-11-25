mod dbscheme;
mod language;
mod ql;
mod ql_gen;

use language::Language;
use std::collections::BTreeMap as Map;
use std::collections::BTreeSet as Set;
use std::fs::File;
use std::io::LineWriter;
use std::path::PathBuf;
use tracing::{error, info};

/// Given the name of the parent node, and its field information, returns a pair,
/// the first of which is the name of the field's type. The second is an optional
/// dbscheme entry that should be added, representing a union of all the possible
/// types the field can take.
fn make_field_type<'a>(
    field: &'a node_types::Field,
    nodes: &'a node_types::NodeTypeMap,
) -> (&'a str, Option<dbscheme::Entry<'a>>) {
    match &field.type_info {
        node_types::FieldTypeInfo::Multiple {
            types,
            dbscheme_union,
            ql_class: _,
        } => {
            // This field can have one of several types. Create an ad-hoc QL union
            // type to represent them.
            let members: Set<&str> = types
                .iter()
                .map(|t| nodes.get(t).unwrap().dbscheme_name.as_str())
                .collect();
            (
                &dbscheme_union,
                Some(dbscheme::Entry::Union(dbscheme::Union {
                    name: dbscheme_union,
                    members,
                })),
            )
        }
        node_types::FieldTypeInfo::Single(t) => (&nodes.get(&t).unwrap().dbscheme_name, None),
    }
}

fn add_field_for_table_storage<'a>(
    field: &'a node_types::Field,
    table_name: &'a str,
    has_index: bool,
    nodes: &'a node_types::NodeTypeMap,
) -> (dbscheme::Table<'a>, Option<dbscheme::Entry<'a>>) {
    let parent_name = &nodes.get(&field.parent).unwrap().dbscheme_name;
    // This field can appear zero or multiple times, so put
    // it in an auxiliary table.
    let (field_type_name, field_type_entry) = make_field_type(&field, nodes);
    let parent_column = dbscheme::Column {
        unique: !has_index,
        db_type: dbscheme::DbColumnType::Int,
        name: &parent_name,
        ql_type: ql::Type::AtType(&parent_name),
        ql_type_is_ref: true,
    };
    let index_column = dbscheme::Column {
        unique: false,
        db_type: dbscheme::DbColumnType::Int,
        name: "index",
        ql_type: ql::Type::Int,
        ql_type_is_ref: true,
    };
    let field_column = dbscheme::Column {
        unique: true,
        db_type: dbscheme::DbColumnType::Int,
        name: field_type_name,
        ql_type: ql::Type::AtType(field_type_name),
        ql_type_is_ref: true,
    };
    let field_table = dbscheme::Table {
        name: &table_name,
        columns: if has_index {
            vec![parent_column, index_column, field_column]
        } else {
            vec![parent_column, field_column]
        },
        // In addition to the field being unique, the combination of
        // parent+index is unique, so add a keyset for them.
        keysets: if has_index {
            Some(vec![&parent_name, "index"])
        } else {
            None
        },
    };
    (field_table, field_type_entry)
}

fn add_field_for_column_storage<'a>(
    field: &'a node_types::Field,
    column_name: &'a str,
    nodes: &'a node_types::NodeTypeMap,
) -> (dbscheme::Column<'a>, Option<dbscheme::Entry<'a>>) {
    // This field must appear exactly once, so we add it as
    // a column to the main table for the node type.
    let (field_type_name, field_type_entry) = make_field_type(&field, nodes);
    (
        dbscheme::Column {
            unique: false,
            db_type: dbscheme::DbColumnType::Int,
            name: column_name,
            ql_type: ql::Type::AtType(field_type_name),
            ql_type_is_ref: true,
        },
        field_type_entry,
    )
}

/// Converts the given tree-sitter node types into CodeQL dbscheme entries.
fn convert_nodes<'a>(nodes: &'a node_types::NodeTypeMap) -> Vec<dbscheme::Entry<'a>> {
    let mut entries: Vec<dbscheme::Entry> = vec![
        create_location_union(),
        create_locations_default_table(),
        create_sourceline_union(),
        create_numlines_table(),
        create_files_table(),
        create_folders_table(),
        create_container_union(),
        create_containerparent_table(),
        create_source_location_prefix_table(),
    ];
    let mut ast_node_members: Set<&str> = Set::new();
    let token_kinds: Map<&str, usize> = nodes
        .iter()
        .filter_map(|(_, node)| match &node.kind {
            node_types::EntryKind::Token { kind_id } => {
                Some((node.dbscheme_name.as_str(), *kind_id))
            }
            _ => None,
        })
        .collect();
    ast_node_members.insert("token");
    ast_node_members.insert("file");
    for (_, node) in nodes {
        match &node.kind {
            node_types::EntryKind::Union { members: n_members } => {
                // It's a tree-sitter supertype node, for which we create a union
                // type.
                let members: Set<&str> = n_members
                    .iter()
                    .map(|n| nodes.get(n).unwrap().dbscheme_name.as_str())
                    .collect();
                entries.push(dbscheme::Entry::Union(dbscheme::Union {
                    name: &node.dbscheme_name,
                    members,
                }));
            }
            node_types::EntryKind::Table { name, fields } => {
                // It's a product type, defined by a table.
                let mut main_table = dbscheme::Table {
                    name: &name,
                    columns: vec![
                        dbscheme::Column {
                            db_type: dbscheme::DbColumnType::Int,
                            name: "id",
                            unique: true,
                            ql_type: ql::Type::AtType(&node.dbscheme_name),
                            ql_type_is_ref: false,
                        },
                        dbscheme::Column {
                            db_type: dbscheme::DbColumnType::Int,
                            name: "parent",
                            unique: false,
                            ql_type: ql::Type::AtType("ast_node_parent"),
                            ql_type_is_ref: true,
                        },
                    ],
                    keysets: None,
                };
                ast_node_members.insert(&node.dbscheme_name);

                // If the type also has fields or children, then we create either
                // auxiliary tables or columns in the defining table for them.
                for field in fields {
                    match &field.storage {
                        node_types::Storage::Column { name } => {
                            let (field_column, field_type_entry) =
                                add_field_for_column_storage(field, name, nodes);
                            if let Some(field_type_entry) = field_type_entry {
                                entries.push(field_type_entry);
                            }
                            main_table.columns.push(field_column);
                        }
                        node_types::Storage::Table { name, has_index } => {
                            let (field_table, field_type_entry) =
                                add_field_for_table_storage(field, name, *has_index, nodes);
                            if let Some(field_type_entry) = field_type_entry {
                                entries.push(field_type_entry);
                            }
                            entries.push(dbscheme::Entry::Table(field_table));
                        }
                    }
                }

                if fields.is_empty() {
                    // There were no fields and no children, so it's a leaf node in
                    // the TS grammar. Add a column for the node text.
                    main_table.columns.push(dbscheme::Column {
                        unique: false,
                        db_type: dbscheme::DbColumnType::String,
                        name: "text",
                        ql_type: ql::Type::String,
                        ql_type_is_ref: true,
                    });
                }

                // Finally, the type's defining table also includes the location.
                main_table.columns.push(dbscheme::Column {
                    unique: false,
                    db_type: dbscheme::DbColumnType::Int,
                    name: "loc",
                    ql_type: ql::Type::AtType("location"),
                    ql_type_is_ref: true,
                });

                entries.push(dbscheme::Entry::Table(main_table));
            }
            node_types::EntryKind::Token { .. } => {}
        }
    }

    // Add the tokeninfo table
    let (token_case, token_table) = create_tokeninfo(token_kinds);
    entries.push(dbscheme::Entry::Table(token_table));
    entries.push(dbscheme::Entry::Case(token_case));

    // Create a union of all database types.
    entries.push(dbscheme::Entry::Union(dbscheme::Union {
        name: "ast_node",
        members: ast_node_members,
    }));

    // Create the ast_node_parent union.
    entries.push(dbscheme::Entry::Union(dbscheme::Union {
        name: "ast_node_parent",
        members: ["ast_node", "file"].iter().cloned().collect(),
    }));
    entries
}

fn create_tokeninfo<'a>(
    token_kinds: Map<&'a str, usize>,
) -> (dbscheme::Case<'a>, dbscheme::Table<'a>) {
    let table = dbscheme::Table {
        name: "tokeninfo",
        keysets: None,
        columns: vec![
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::Int,
                name: "id",
                unique: true,
                ql_type: ql::Type::AtType("token"),
                ql_type_is_ref: false,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::Int,
                name: "parent",
                unique: false,
                ql_type: ql::Type::AtType("ast_node_parent"),
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "kind",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "file",
                ql_type: ql::Type::AtType("file"),
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "idx",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::String,
                name: "value",
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "loc",
                ql_type: ql::Type::AtType("location"),
                ql_type_is_ref: true,
            },
        ],
    };
    let branches: Vec<(usize, &str)> = token_kinds
        .iter()
        .map(|(&name, kind_id)| (*kind_id, name))
        .collect();
    let case = dbscheme::Case {
        name: "token",
        column: "kind",
        branches: branches,
    };
    (case, table)
}

fn write_dbscheme(language: &Language, entries: &[dbscheme::Entry]) -> std::io::Result<()> {
    info!(
        "Writing database schema for {} to '{}'",
        &language.name,
        match language.dbscheme_path.to_str() {
            None => "<undisplayable>",
            Some(p) => p,
        }
    );
    let file = File::create(&language.dbscheme_path)?;
    let mut file = LineWriter::new(file);
    dbscheme::write(&language.name, &mut file, &entries)
}

fn create_location_union<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Union(dbscheme::Union {
        name: "location",
        members: vec!["location_default"].into_iter().collect(),
    })
}

fn create_files_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "files",
        keysets: None,
        columns: vec![
            dbscheme::Column {
                unique: true,
                db_type: dbscheme::DbColumnType::Int,
                name: "id",
                ql_type: ql::Type::AtType("file"),
                ql_type_is_ref: false,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::String,
                name: "name",
                unique: false,
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::String,
                name: "simple",
                unique: false,
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::String,
                name: "ext",
                unique: false,
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::Int,
                name: "fromSource",
                unique: false,
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
        ],
    })
}
fn create_folders_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "folders",
        keysets: None,
        columns: vec![
            dbscheme::Column {
                unique: true,
                db_type: dbscheme::DbColumnType::Int,
                name: "id",
                ql_type: ql::Type::AtType("folder"),
                ql_type_is_ref: false,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::String,
                name: "name",
                unique: false,
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                db_type: dbscheme::DbColumnType::String,
                name: "simple",
                unique: false,
                ql_type: ql::Type::String,
                ql_type_is_ref: true,
            },
        ],
    })
}

fn create_locations_default_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "locations_default",
        keysets: None,
        columns: vec![
            dbscheme::Column {
                unique: true,
                db_type: dbscheme::DbColumnType::Int,
                name: "id",
                ql_type: ql::Type::AtType("location_default"),
                ql_type_is_ref: false,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "file",
                ql_type: ql::Type::AtType("file"),
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "start_line",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "start_column",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "end_line",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "end_column",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
        ],
    })
}

fn create_sourceline_union<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Union(dbscheme::Union {
        name: "sourceline",
        members: vec!["file"].into_iter().collect(),
    })
}

fn create_numlines_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "numlines",
        columns: vec![
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "element_id",
                ql_type: ql::Type::AtType("sourceline"),
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "num_lines",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "num_code",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "num_comment",
                ql_type: ql::Type::Int,
                ql_type_is_ref: true,
            },
        ],
        keysets: None,
    })
}

fn create_container_union<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Union(dbscheme::Union {
        name: "container",
        members: vec!["folder", "file"].into_iter().collect(),
    })
}

fn create_containerparent_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "containerparent",
        columns: vec![
            dbscheme::Column {
                unique: false,
                db_type: dbscheme::DbColumnType::Int,
                name: "parent",
                ql_type: ql::Type::AtType("container"),
                ql_type_is_ref: true,
            },
            dbscheme::Column {
                unique: true,
                db_type: dbscheme::DbColumnType::Int,
                name: "child",
                ql_type: ql::Type::AtType("container"),
                ql_type_is_ref: true,
            },
        ],
        keysets: None,
    })
}

fn create_source_location_prefix_table<'a>() -> dbscheme::Entry<'a> {
    dbscheme::Entry::Table(dbscheme::Table {
        name: "sourceLocationPrefix",
        keysets: None,
        columns: vec![dbscheme::Column {
            unique: false,
            db_type: dbscheme::DbColumnType::String,
            name: "prefix",
            ql_type: ql::Type::String,
            ql_type_is_ref: true,
        }],
    })
}

fn main() {
    tracing_subscriber::fmt()
        .with_target(false)
        .without_time()
        .with_level(true)
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    // TODO: figure out proper dbscheme output path and/or take it from the
    // command line.
    let ruby = Language {
        name: "Ruby".to_owned(),
        node_types: tree_sitter_ruby::NODE_TYPES,
        dbscheme_path: PathBuf::from("ql/src/ruby.dbscheme"),
        ql_library_path: PathBuf::from("ql/src/codeql_ruby/ast.qll"),
    };
    match node_types::read_node_types_str(&ruby.node_types) {
        Err(e) => {
            error!("Failed to read node-types JSON for {}: {}", ruby.name, e);
            std::process::exit(1);
        }
        Ok(nodes) => {
            let dbscheme_entries = convert_nodes(&nodes);

            if let Err(e) = write_dbscheme(&ruby, &dbscheme_entries) {
                error!("Failed to write dbscheme: {}", e);
                std::process::exit(2);
            }

            let classes = ql_gen::convert_nodes(&nodes);

            if let Err(e) = ql_gen::write(&ruby, &classes) {
                println!("Failed to write QL library: {}", e);
                std::process::exit(3);
            }
        }
    }
}
