use std::{
  cell::RefCell,
  collections::{BTreeSet, VecDeque},
  rc::Rc,
};

pub enum Special {
  Any,

  Blank,
  NonBlank,

  // TODO: Zero-width assertions:
  // Begin of ..., End of ...
  BoL,
  EoL,
  BoF,
  EoF,
  // Word boundaries
  BoW,
  EoW,
}

pub enum Condition {
  Symbol(char),
  Special(Special),
  PosRange { begin: char, end: char },
  NegRange { begin: char, end: char },
  PosCharset(BTreeSet<char>),
  NegCharset(BTreeSet<char>),
  Assertion(Node),
  Negative(Node),
}

struct Rule {
  to: Rc<RefCell<Node>>,
  cond: Condition,
}

struct Node {
  start: bool,
  finals: bool,
  epsilon: Vec<RefCell<Node>>,
  rules: Vec<RefCell<Rule>>,
}

pub struct State {
  current: Rc<RefCell<Node>>,
  trace: Vec<char>,
}

pub struct Engine {
  start: Rc<RefCell<Node>>,
  finals: Vec<RefCell<Node>>,
  nodes: Vec<RefCell<Node>>,
  states: VecDeque<State>,
}

impl Condition {
  pub fn validate(&self, c: char) -> bool {
    match self {
      Condition::Symbol(sc) => *sc == c,
      Condition::Special(special) => match special {
        Special::Any => true,
        Special::Blank => c.is_whitespace(),
        Special::NonBlank => !c.is_whitespace(),
        _ => todo!(),
      },
      Condition::PosRange { begin, end } => c >= *begin && c <= *end,
      Condition::NegRange { begin, end } => c < *begin || c > *end,
      Condition::PosCharset(set) => set.contains(&c),
      Condition::NegCharset(set) => !set.contains(&c),
      Condition::Assertion(_) => todo!(),
      Condition::Negative(_) => todo!(),
    }
  }

  pub fn charset(v: &str) -> Self {
    let set: BTreeSet<char> = v.chars().collect();
    Condition::PosCharset(set)
  }

  pub fn neg_charset(v: &str) -> Self {
    let set: BTreeSet<char> = v.chars().collect();
    Condition::NegCharset(set)
  }
}

impl Node {
  pub fn new(start: bool, finals: bool) -> Self {
    Self {
      start,
      finals,
      epsilon: vec![],
      rules: vec![],
    }
  }

  pub fn add_epsilon(&mut self, node: RefCell<Node>) -> &mut Self {
    todo!()
  }

  pub fn add_rule(&mut self, to: Rc<RefCell<Node>>, cond: Condition) -> &mut Self {
    todo!()
  }
}

impl Engine {
  /// Creates a new NFA that matches the given symbol.
  pub fn symbol(c: char) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches the given string.
  pub fn string(s: &str) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches the given special condition.
  pub fn special(special: Special) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches the concatenation of the original NFA and the other NFA.
  pub fn concatnate(&self, other: &Self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches either the original NFA or the other NFA.
  pub fn alternate(&self, other: &Self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches zero or more repetitions of the original NFA.
  pub fn kleene_star(&self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches one or more repetitions of the original NFA.
  pub fn exist(&self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches zero or one occurrence of the original NFA.
  pub fn optional(&self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches the original NFA as a lookahead assertion.
  pub fn assertion(&self) -> Self {
    todo!()
  }

  /// Creates a new NFA that matches the original NFA as a negative lookahead assertion.
  pub fn negative(&self) -> Self {
    todo!()
  }
}
