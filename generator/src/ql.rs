use std::collections::BTreeSet;
use std::fmt;

pub enum TopLevel<'a> {
    Class(Class<'a>),
    Import(&'a str),
}

impl<'a> fmt::Display for TopLevel<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            TopLevel::Import(x) => write!(f, "import {}", x),
            TopLevel::Class(cls) => write!(f, "{}", cls),
        }
    }
}

#[derive(Clone, Eq, PartialEq, Hash)]
pub struct Class<'a> {
    pub name: &'a str,
    pub is_abstract: bool,
    pub supertypes: BTreeSet<Type<'a>>,
    pub characteristic_predicate: Option<Expression<'a>>,
    pub predicates: Vec<Predicate<'a>>,
}

impl<'a> fmt::Display for Class<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.is_abstract {
            write!(f, "abstract ")?;
        }
        write!(f, "class {} extends ", &self.name)?;
        for (index, supertype) in self.supertypes.iter().enumerate() {
            if index > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{}", supertype)?;
        }
        write!(f, " {{ \n")?;

        if let Some(charpred) = &self.characteristic_predicate {
            write!(
                f,
                "  {}\n",
                Predicate {
                    name: self.name.clone(),
                    overridden: false,
                    return_type: None,
                    formal_parameters: vec![],
                    body: charpred.clone(),
                }
            )?;
        }

        for predicate in &self.predicates {
            write!(f, "  {}\n", predicate)?;
        }

        write!(f, "}}")?;

        Ok(())
    }
}

// The QL type of a column.
#[derive(Clone, Eq, PartialEq, Hash, Ord, PartialOrd)]
pub enum Type<'a> {
    /// Primitive `int` type.
    Int,

    /// Primitive `string` type.
    String,

    /// A database type that will need to be referred to with an `@` prefix.
    AtType(&'a str),

    /// A user-defined type.
    Normal(&'a str),
}

impl<'a> fmt::Display for Type<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Type::Int => write!(f, "int"),
            Type::String => write!(f, "string"),
            Type::Normal(name) => write!(f, "{}", name),
            Type::AtType(name) => write!(f, "@{}", name),
        }
    }
}

#[derive(Clone, Eq, PartialEq, Hash)]
pub enum Expression<'a> {
    Var(&'a str),
    String(&'a str),
    Pred(&'a str, Vec<Expression<'a>>),
    Or(Vec<Expression<'a>>),
    Equals(Box<Expression<'a>>, Box<Expression<'a>>),
    Dot(Box<Expression<'a>>, &'a str, Vec<Expression<'a>>),
    Aggregate(
        &'a str,
        Vec<FormalParameter<'a>>,
        Box<Expression<'a>>,
        Box<Expression<'a>>,
    ),
}

impl<'a> fmt::Display for Expression<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Expression::Var(x) => write!(f, "{}", x),
            Expression::String(s) => write!(f, "\"{}\"", s),
            Expression::Pred(n, args) => {
                write!(f, "{}(", n)?;
                for (index, arg) in args.iter().enumerate() {
                    if index > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", arg)?;
                }
                write!(f, ")")
            }
            Expression::Or(disjuncts) => {
                if disjuncts.is_empty() {
                    write!(f, "none()")
                } else {
                    for (index, disjunct) in disjuncts.iter().enumerate() {
                        if index > 0 {
                            write!(f, " or ")?;
                        }
                        write!(f, "({})", disjunct)?;
                    }
                    Ok(())
                }
            }
            Expression::Equals(a, b) => write!(f, "{} = {}", a, b),
            Expression::Dot(x, member_pred, args) => {
                write!(f, "{}.{}(", x, member_pred)?;
                for (index, arg) in args.iter().enumerate() {
                    if index > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", arg)?;
                }
                write!(f, ")")
            }
            Expression::Aggregate(n, vars, range, term) => {
                write!(f, "{}(", n)?;
                for (index, var) in vars.iter().enumerate() {
                    if index > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", var)?;
                }
                write!(f, " | {} | {})", range, term)
            }
        }
    }
}

#[derive(Clone, Eq, PartialEq, Hash)]
pub struct Predicate<'a> {
    pub name: &'a str,
    pub overridden: bool,
    pub return_type: Option<Type<'a>>,
    pub formal_parameters: Vec<FormalParameter<'a>>,
    pub body: Expression<'a>,
}

impl<'a> fmt::Display for Predicate<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        if self.overridden {
            write!(f, "override ")?;
        }
        match &self.return_type {
            None => write!(f, "predicate ")?,
            Some(return_type) => write!(f, "{} ", return_type)?,
        }
        write!(f, "{}(", self.name)?;
        for (index, param) in self.formal_parameters.iter().enumerate() {
            if index > 0 {
                write!(f, ", ")?;
            }
            write!(f, "{}", param)?;
        }
        write!(f, ") {{ {} }}", self.body)?;

        Ok(())
    }
}

#[derive(Clone, Eq, PartialEq, Hash)]
pub struct FormalParameter<'a> {
    pub name: &'a str,
    pub param_type: Type<'a>,
}

impl<'a> fmt::Display for FormalParameter<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{} {}", self.param_type, self.name)
    }
}

/// Generates a QL library by writing the given `classes` to the `file`.
pub fn write<'a>(
    language_name: &str,
    file: &mut dyn std::io::Write,
    elements: &'a [TopLevel],
) -> std::io::Result<()> {
    write!(file, "/*\n")?;
    write!(file, " * CodeQL library for {}\n", language_name)?;
    write!(
        file,
        " * Automatically generated from the tree-sitter grammar; do not edit\n"
    )?;
    write!(file, " */\n\n")?;

    for element in elements {
        write!(file, "{}\n\n", &element)?;
    }

    Ok(())
}
