use serde::Deserialize;
use std::collections::BTreeMap;
use std::path::Path;

use std::collections::BTreeSet as Set;
use std::fs;

/// A lookup table from TypeName to Entry.
pub type NodeTypeMap = BTreeMap<TypeName, Entry>;

#[derive(Debug)]
pub struct Entry {
    pub flattened_name: String,
    pub ql_class_name: String,
    pub kind: EntryKind,
}

#[derive(Debug)]
pub enum EntryKind {
    Union { members: Set<TypeName> },
    Table { fields: Vec<Field> },
    Token { kind_id: usize },
}

#[derive(Debug, Ord, PartialOrd, Eq, PartialEq)]
pub struct TypeName {
    pub kind: String,
    pub named: bool,
}

#[derive(Debug)]
pub enum FieldTypeInfo {
    /// The field has a single type.
    Single(TypeName),

    /// The field can take one of several types, so we also provide the name of
    /// the database union type that wraps them, and the corresponding QL class
    /// name.
    Multiple {
        types: Set<TypeName>,
        dbscheme_union: String,
        ql_class: String,
    },
}

#[derive(Debug)]
pub struct Field {
    pub parent: TypeName,
    pub type_info: FieldTypeInfo,
    /// The name of the field or None for the anonymous 'children'
    /// entry from node_types.json
    pub name: Option<String>,
    pub storage: Storage,
}

fn name_for_field_or_child(name: &Option<String>) -> String {
    match name {
        Some(name) => name.clone(),
        None => "child".to_owned(),
    }
}

impl Field {
    pub fn get_name(&self) -> String {
        name_for_field_or_child(&self.name)
    }

    pub fn get_getter_name(&self) -> String {
        format!(
            "get{}",
            dbscheme_name_to_class_name(&escape_name(&name_for_field_or_child(&self.name)))
        )
    }
}

#[derive(Debug)]
pub enum Storage {
    /// the field is stored as a column in the parent table
    Column,
    /// the field is stored in a link table, and may or may not have an
    /// associated index column
    Table(bool),
}

pub fn read_node_types(node_types_path: &Path) -> std::io::Result<NodeTypeMap> {
    let file = fs::File::open(node_types_path)?;
    let node_types = serde_json::from_reader(file)?;
    Ok(convert_nodes(node_types))
}

pub fn read_node_types_str(node_types_json: &str) -> std::io::Result<NodeTypeMap> {
    let node_types = serde_json::from_str(node_types_json)?;
    Ok(convert_nodes(node_types))
}

fn convert_type(node_type: &NodeType) -> TypeName {
    TypeName {
        kind: node_type.kind.to_string(),
        named: node_type.named,
    }
}

fn convert_types(node_types: &Vec<NodeType>) -> Set<TypeName> {
    let iter = node_types.iter().map(convert_type).collect();
    std::collections::BTreeSet::from(iter)
}

pub fn convert_nodes(nodes: Vec<NodeInfo>) -> NodeTypeMap {
    let mut entries = NodeTypeMap::new();
    let mut token_kinds = Set::new();
    for node in nodes {
        let flattened_name = node_type_name(&node.kind, node.named);
        let ql_class_name = dbscheme_name_to_class_name(&escape_name(&flattened_name));
        if let Some(subtypes) = &node.subtypes {
            // It's a tree-sitter supertype node, for which we create a union
            // type.
            entries.insert(
                TypeName {
                    kind: node.kind,
                    named: node.named,
                },
                Entry {
                    flattened_name,
                    ql_class_name,
                    kind: EntryKind::Union {
                        members: convert_types(&subtypes),
                    },
                },
            );
        } else if node.fields.as_ref().map_or(0, |x| x.len()) == 0 && node.children.is_none() {
            let type_name = TypeName {
                kind: node.kind,
                named: node.named,
            };
            token_kinds.insert(type_name);
        } else {
            // It's a product type, defined by a table.
            let type_name = TypeName {
                kind: node.kind,
                named: node.named,
            };
            let mut fields = Vec::new();

            // If the type also has fields or children, then we create either
            // auxiliary tables or columns in the defining table for them.
            if let Some(node_fields) = &node.fields {
                for (field_name, field_info) in node_fields {
                    add_field(
                        &type_name,
                        Some(field_name.to_string()),
                        field_info,
                        &mut fields,
                    );
                }
            }
            if let Some(children) = &node.children {
                // Treat children as if they were a field called 'child'.
                add_field(&type_name, None, children, &mut fields);
            }
            entries.insert(
                type_name,
                Entry {
                    flattened_name,
                    ql_class_name,
                    kind: EntryKind::Table { fields },
                },
            );
        }
    }
    let mut counter = 0;
    for type_name in token_kinds {
        let entry = if type_name.named {
            counter += 1;
            let unprefixed_name = node_type_name(&type_name.kind, true);
            Entry {
                flattened_name: format!("token_{}", &unprefixed_name),
                ql_class_name: dbscheme_name_to_class_name(&escape_name(&unprefixed_name)),
                kind: EntryKind::Token { kind_id: counter },
            }
        } else {
            Entry {
                flattened_name: "reserved_word".to_owned(),
                ql_class_name: "ReservedWord".to_owned(),
                kind: EntryKind::Token { kind_id: 0 },
            }
        };
        entries.insert(type_name, entry);
    }
    entries
}

fn add_field(
    parent_type_name: &TypeName,
    field_name: Option<String>,
    field_info: &FieldInfo,
    fields: &mut Vec<Field>,
) {
    let storage = if !field_info.multiple && field_info.required {
        // This field must appear exactly once, so we add it as
        // a column to the main table for the node type.
        Storage::Column
    } else if !field_info.multiple {
        // This field is optional but can occur at most once. Put it in an
        // auxiliary table without an index.
        Storage::Table(false)
    } else {
        // This field can occur multiple times. Put it in an auxiliary table
        // with an associated index.
        Storage::Table(true)
    };
    let type_info = if field_info.types.len() == 1 {
        FieldTypeInfo::Single(convert_type(field_info.types.iter().next().unwrap()))
    } else {
        // The dbscheme type for this field will be a union. In QL, it'll just be AstNode.
        FieldTypeInfo::Multiple {
            types: convert_types(&field_info.types),
            dbscheme_union: format!(
                "{}_{}_type",
                &node_type_name(&parent_type_name.kind, parent_type_name.named),
                &name_for_field_or_child(&field_name)
            ),
            ql_class: "AstNode".to_owned(),
        }
    };
    fields.push(Field {
        parent: TypeName {
            kind: parent_type_name.kind.to_string(),
            named: parent_type_name.named,
        },
        type_info,
        name: field_name,
        storage,
    });
}
#[derive(Deserialize)]
pub struct NodeInfo {
    #[serde(rename = "type")]
    pub kind: String,
    pub named: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub fields: Option<BTreeMap<String, FieldInfo>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub children: Option<FieldInfo>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub subtypes: Option<Vec<NodeType>>,
}

#[derive(Deserialize)]
pub struct NodeType {
    #[serde(rename = "type")]
    pub kind: String,
    pub named: bool,
}

#[derive(Deserialize)]
pub struct FieldInfo {
    pub multiple: bool,
    pub required: bool,
    pub types: Vec<NodeType>,
}

/// Given a tree-sitter node type's (kind, named) pair, returns a single string
/// representing the (unescaped) name we'll use to refer to corresponding QL
/// type.
fn node_type_name(kind: &str, named: bool) -> String {
    if named {
        kind.to_string()
    } else {
        format!("{}_unnamed", kind)
    }
}

const RESERVED_KEYWORDS: [&'static str; 14] = [
    "boolean", "case", "date", "float", "int", "key", "of", "order", "ref", "string", "subtype",
    "type", "unique", "varchar",
];

/// Returns a string that's a copy of `name` but suitably escaped to be a valid
/// QL identifier.
pub fn escape_name(name: &str) -> String {
    let mut result = String::new();

    // If there's a leading underscore, replace it with 'underscore_'.
    if let Some(c) = name.chars().next() {
        if c == '_' {
            result.push_str("underscore");
        }
    }
    for c in name.chars() {
        match c {
            '{' => result.push_str("lbrace"),
            '}' => result.push_str("rbrace"),
            '<' => result.push_str("langle"),
            '>' => result.push_str("rangle"),
            '[' => result.push_str("lbracket"),
            ']' => result.push_str("rbracket"),
            '(' => result.push_str("lparen"),
            ')' => result.push_str("rparen"),
            '|' => result.push_str("pipe"),
            '=' => result.push_str("equal"),
            '~' => result.push_str("tilde"),
            '?' => result.push_str("question"),
            '`' => result.push_str("backtick"),
            '^' => result.push_str("caret"),
            '!' => result.push_str("bang"),
            '#' => result.push_str("hash"),
            '%' => result.push_str("percent"),
            '&' => result.push_str("ampersand"),
            '.' => result.push_str("dot"),
            ',' => result.push_str("comma"),
            '/' => result.push_str("slash"),
            ':' => result.push_str("colon"),
            ';' => result.push_str("semicolon"),
            '"' => result.push_str("dquote"),
            '*' => result.push_str("star"),
            '+' => result.push_str("plus"),
            '-' => result.push_str("minus"),
            '@' => result.push_str("at"),
            _ if c.is_uppercase() => {
                result.push_str(&c.to_lowercase().to_string());
                result.push('_')
            }
            _ => result.push(c),
        }
    }

    for &keyword in &RESERVED_KEYWORDS {
        if result == keyword {
            result.push_str("__");
            break;
        }
    }

    result
}

/// Given a valid dbscheme name (i.e. in snake case), produces the equivalent QL
/// name (i.e. in CamelCase). For example, "foo_bar_baz" becomes "FooBarBaz".
fn dbscheme_name_to_class_name(dbscheme_name: &str) -> String {
    fn to_title_case(word: &str) -> String {
        let mut first = true;
        let mut result = String::new();
        for c in word.chars() {
            if first {
                first = false;
                result.push(c.to_ascii_uppercase());
            } else {
                result.push(c);
            }
        }
        result
    }
    dbscheme_name
        .split('_')
        .map(|word| to_title_case(word))
        .collect::<Vec<String>>()
        .join("")
}
