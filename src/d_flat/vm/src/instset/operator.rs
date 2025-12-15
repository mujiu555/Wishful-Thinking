struct OptInt {}

pub enum Operator {
  Int,
  Nop,

  Mov,

  LoadIL,
  LoadIH,
  LoadIM,
  LoadUM,

  LoadF,

  Add,
  Sub,
  Mul,
  Div,

  Shl,
  RShl,
  Shr,
  RShr,

  And,
  Or,
  Xor,
  Not,

  Push,
  Pop,

  Jmp,

  Test,
  If,
  Ifn,

  Loop,

  Call,
  Ret,
}
