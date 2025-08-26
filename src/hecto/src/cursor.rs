#[derive(Debug)]
struct Pos {
  x: usize,
  y: usize,
}

#[derive(Debug)]
pub struct Cursor {
  pos: Pos,
}

impl Default for Cursor {
  fn default() -> Self {
    Self {
      pos: Pos { x: 0, y: 0 },
    }
  }
}
