pub struct Stack {
  cap: u32,
  sp: u32,
  dat: Vec<u8>,
}

impl Stack {
  fn new() -> Self {
    Self {
      cap: 0,
      sp: 0,
      dat: vec![],
    }
  }
}
