pub struct Solution;

enum Token {
  Symbol(Vec<char>),
  Number(i64),
  Bracket(char),
}

impl Token {
  fn next(self, c: char) -> Option<Self> {
    Some(self)
  }
}

impl Solution {
  pub fn evaluate(expression: String) -> i32 {
    0
  }
}
