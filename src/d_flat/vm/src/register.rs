use std::convert::TryFrom;

/// A typed handle for VM registers.
/// Matches the codes described in the VM spec:
/// - General registers: 0x00..0x7f (0..127)
/// - Special registers: 0xf0..0xff as described in the spec
#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub enum RegisterType {
  // General Register: Reg#0 .. Reg#127
  General(u8),

  // Special registers with their codes
  Ign,   // 0xff - ignore (assign-only)
  A,     // 0xfe - Accumulator
  C,     // 0xfd - Counter
  R,     // 0xfc - Reminder

  PC,    // 0xfb - Program Counter
  EP,    // 0xfa - Execution Stack Pointer

  BP,    // 0xf9
  SP,    // 0xf8
  SS,    // 0xf7

  LS,    // 0xf6 - Literal Segment
  LP,    // 0xf5 - Literal Pointer

  FLAGS, // 0xf4
  TESTS, // 0xf3

  Jmp,   // 0xf2
  JS,    // 0xf1
  RVP,   // 0xf0
}

impl RegisterType {
  /// Return the numeric code for this register type.
  /// General registers return their index (0..127).
  pub fn code(self) -> u8 {
    match self {
      RegisterType::General(n) => n,
      RegisterType::Ign => 0xff,
      RegisterType::A => 0xfe,
      RegisterType::C => 0xfd,
      RegisterType::R => 0xfc,
      RegisterType::PC => 0xfb,
      RegisterType::EP => 0xfa,
      RegisterType::BP => 0xf9,
      RegisterType::SP => 0xf8,
      RegisterType::SS => 0xf7,
      RegisterType::LS => 0xf6,
      RegisterType::LP => 0xf5,
      RegisterType::FLAGS => 0xf4,
      RegisterType::TESTS => 0xf3,
      RegisterType::Jmp => 0xf2,
      RegisterType::JS => 0xf1,
      RegisterType::RVP => 0xf0,
    }
  }
}

impl TryFrom<u8> for RegisterType {
  type Error = &'static str;

  fn try_from(v: u8) -> Result<Self, Self::Error> {
    match v {
      0x00..=0x7f => Ok(RegisterType::General(v)),
      0xff => Ok(RegisterType::Ign),
      0xfe => Ok(RegisterType::A),
      0xfd => Ok(RegisterType::C),
      0xfc => Ok(RegisterType::R),
      0xfb => Ok(RegisterType::PC),
      0xfa => Ok(RegisterType::EP),
      0xf9 => Ok(RegisterType::BP),
      0xf8 => Ok(RegisterType::SP),
      0xf7 => Ok(RegisterType::SS),
      0xf6 => Ok(RegisterType::LS),
      0xf5 => Ok(RegisterType::LP),
      0xf4 => Ok(RegisterType::FLAGS),
      0xf3 => Ok(RegisterType::TESTS),
      0xf2 => Ok(RegisterType::Jmp),
      0xf1 => Ok(RegisterType::JS),
      0xf0 => Ok(RegisterType::RVP),
      _ => Err("unknown register code"),
    }
  }
}

/// Individual flag bits used in the `FLAGS` register.
/// Values chosen to mirror traditional CPU flag positions (CF, PF, AF, ZF, SF, TF, IF, DF, OF).
#[derive(Copy, Clone, Debug)]
#[repr(u64)]
pub enum Flag {
  CF = 1 << 0,
  PF = 1 << 2,
  AF = 1 << 4,
  ZF = 1 << 6,
  SF = 1 << 7,
  TF = 1 << 8,
  IF = 1 << 9,
  DF = 1 << 10,
  OF = 1 << 11,
}

/// Test condition codes used by `:TEST`.
#[derive(Copy, Clone, Debug)]
pub enum TestCond {
  G,  // greater (signed)
  NG, // not greater
  L,  // less (signed)
  NL, // not less
  E,  // equal / zero
  O,  // overflow
  NO, // not overflow
}

/// Storage and access for the VM registers.
///
/// The implementation stores all registers as u64. Floating-point
/// access is provided via bit-casting to/from f64. The `Ign` register
/// discards writes and returns None on reads.
pub struct Registers {
  general: [u64; 128],

  // special registers
  a: u64,
  c: u64,
  r: u64,

  pc: u64,
  ep: u64,

  bp: u64,
  sp: u64,
  ss: u64,

  ls: u64,
  lp: u64,

  flags: u64,
  tests: u64,

  jmp: u64,
  js: u64,
  rvp: u64,
}

impl Default for Registers {
  fn default() -> Self {
    Self::new()
  }
}

impl Registers {
  /// Create a new Registers set with all zeros.
  pub fn new() -> Self {
    Registers {
      general: [0u64; 128],
      a: 0,
      c: 0,
      r: 0,
      pc: 0,
      ep: 0,
      bp: 0,
      sp: 0,
      ss: 0,
      ls: 0,
      lp: 0,
      flags: 0,
      tests: 0,
      jmp: 0,
      js: 0,
      rvp: 0,
    }
  }

  /// Set register with u64 value. For `Ign`, the write is ignored.
  pub fn set_u64(&mut self, r: RegisterType, v: u64) {
    match r {
      RegisterType::General(n) => self.general[n as usize] = v,
      RegisterType::Ign => { /* ignore writes */ }
      RegisterType::A => self.a = v,
      RegisterType::C => self.c = v,
      RegisterType::R => self.r = v,
      RegisterType::PC => self.pc = v,
      RegisterType::EP => self.ep = v,
      RegisterType::BP => self.bp = v,
      RegisterType::SP => self.sp = v,
      RegisterType::SS => self.ss = v,
      RegisterType::LS => self.ls = v,
      RegisterType::LP => self.lp = v,
      RegisterType::FLAGS => self.flags = v,
      RegisterType::TESTS => self.tests = v,
      RegisterType::Jmp => self.jmp = v,
      RegisterType::JS => self.js = v,
      RegisterType::RVP => self.rvp = v,
    }
  }

  /// Read a register as u64. Returns None for `Ign` (read not allowed).
  pub fn get_u64(&self, r: RegisterType) -> Option<u64> {
    match r {
      RegisterType::General(n) => Some(self.general[n as usize]),
      RegisterType::Ign => None,
      RegisterType::A => Some(self.a),
      RegisterType::C => Some(self.c),
      RegisterType::R => Some(self.r),
      RegisterType::PC => Some(self.pc),
      RegisterType::EP => Some(self.ep),
      RegisterType::BP => Some(self.bp),
      RegisterType::SP => Some(self.sp),
      RegisterType::SS => Some(self.ss),
      RegisterType::LS => Some(self.ls),
      RegisterType::LP => Some(self.lp),
      RegisterType::FLAGS => Some(self.flags),
      RegisterType::TESTS => Some(self.tests),
      RegisterType::Jmp => Some(self.jmp),
      RegisterType::JS => Some(self.js),
      RegisterType::RVP => Some(self.rvp),
    }
  }

  /// Set as f64 by reinterpreting bits.
  pub fn set_f64(&mut self, r: RegisterType, f: f64) {
    self.set_u64(r, f.to_bits());
  }

  /// Read as f64 by reinterpreting bits. Returns None for `Ign`.
  pub fn get_f64(&self, r: RegisterType) -> Option<f64> {
    self.get_u64(r).map(|v| f64::from_bits(v))
  }

  /// Convenience: set general register by index (0..=127)
  pub fn set_general(&mut self, idx: usize, v: u64) {
    if idx < 128 {
      self.general[idx] = v;
    }
  }

  /// Convenience: get general register by index
  pub fn get_general(&self, idx: usize) -> Option<u64> {
    if idx < 128 {
      Some(self.general[idx])
    } else {
      None
    }
  }

  /// Set or clear a specific flag bit in `FLAGS`.
  pub fn set_flag(&mut self, flag: Flag, value: bool) {
    if value {
      self.flags |= flag as u64;
    } else {
      self.flags &= !(flag as u64);
    }
  }

  /// Read a flag bit from `FLAGS`.
  pub fn get_flag(&self, flag: Flag) -> bool {
    (self.flags & (flag as u64)) != 0
  }

  /// Update common flags after an unsigned addition: sets CF, PF, AF, ZF, SF, OF.
  /// - `a` and `b` are the operands, `res` is the low 64-bit result.
  pub fn update_flags_add_u64(&mut self, a: u64, b: u64, res: u64) {
    // Carry flag: unsigned overflow if result < a
    let cf = res < a;

    // Aux carry: carry from bit 3
  let af = ((a & 0xf).wrapping_add(b & 0xf) & 0x10) != 0;

    // Zero flag
    let zf = res == 0;

    // Sign flag: most significant bit
    let sf = (res as i64) < 0;

    // Parity flag: true if low-byte of result has even parity
    let byte = (res & 0xff) as u8;
    let ones = byte.count_ones();
    let pf = (ones % 2) == 0;

    // Overflow flag for signed addition: when operands have same sign and result has different sign
    let ai = a as i64;
    let bi = b as i64;
    let ri = res as i64;
    let of = (ai >= 0 && bi >= 0 && ri < 0) || (ai < 0 && bi < 0 && ri >= 0);

    self.set_flag(Flag::CF, cf);
    self.set_flag(Flag::AF, af);
    self.set_flag(Flag::ZF, zf);
    self.set_flag(Flag::SF, sf);
    self.set_flag(Flag::PF, pf);
    self.set_flag(Flag::OF, of);
  }

  /// Evaluate a test condition based on the current `FLAGS` register.
  pub fn evaluate_test(&self, cond: TestCond) -> bool {
    let zf = self.get_flag(Flag::ZF);
    let sf = self.get_flag(Flag::SF);
    let of = self.get_flag(Flag::OF);

    match cond {
      TestCond::E => zf,
      TestCond::O => of,
      TestCond::NO => !of,
      TestCond::G => !zf && (sf == of),
      TestCond::L => sf != of,
      TestCond::NG => !( !zf && (sf == of) ),
      TestCond::NL => !( sf != of ),
    }
  }

  /// Execute a `:TEST`-like operation: set `TESTS` register to 1 if condition true else 0,
  /// and return the boolean result.
  pub fn exec_test(&mut self, cond: TestCond) -> bool {
    let r = self.evaluate_test(cond);
    self.tests = if r { 1 } else { 0 };
    r
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn general_register_read_write() {
    let mut regs = Registers::new();
    regs.set_u64(RegisterType::General(3), 0x1234);
    assert_eq!(regs.get_u64(RegisterType::General(3)), Some(0x1234));
  }

  #[test]
  fn special_registers_and_f64() {
    let mut regs = Registers::new();
    regs.set_f64(RegisterType::A, 1.5);
    assert_eq!(regs.get_f64(RegisterType::A), Some(1.5));

    regs.set_u64(RegisterType::PC, 0xdeadbeef);
    assert_eq!(regs.get_u64(RegisterType::PC), Some(0xdeadbeef));
  }

  #[test]
  fn ign_behaviour() {
    let mut regs = Registers::new();
    regs.set_u64(RegisterType::Ign, 0xaaaa);
    // Ign ignores writes. Reading returns None.
    assert_eq!(regs.get_u64(RegisterType::Ign), None);
  }

  #[test]
  fn add_updates_flags_and_tests() {
    let mut regs = Registers::new();

    // choose operands that cause signed overflow: i64::MAX + 1 -> negative result
    let a = i64::MAX as u64; // 0x7fff... 
    let b = 1u64;
    let res = a.wrapping_add(b);

    regs.update_flags_add_u64(a, b, res);

    // Overflow should be set for signed overflow
    assert!(regs.get_flag(Flag::OF));

    // Zero flag should be false
    assert!(!regs.get_flag(Flag::ZF));

    // Execute an equality test (should be false)
    let eq = regs.exec_test(TestCond::E);
    assert!(!eq);

    // Now set flags to indicate zero and test E
    regs.set_flag(Flag::ZF, true);
    let eq2 = regs.exec_test(TestCond::E);
    assert!(eq2);
    assert_eq!(regs.get_u64(RegisterType::TESTS), Some(1));
  }
}

