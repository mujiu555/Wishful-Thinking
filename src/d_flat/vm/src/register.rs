use std::mem::ManuallyDrop;

pub union Register {
  u: ManuallyDrop<u64>,
  f: ManuallyDrop<f64>,
}

#[derive(Debug)]
pub enum RegisterType {
  // General Register
  General(u8),

  // Ignore
  Ign, // Ignore, 0xff

  // arithmetic
  A, // Acuumulator, 0xfe
  C, // Counter, 0xfd
  R, // Reminder, 0xfc

  // Execution status
  PC, // Program Counter, 0xfb
  EP, // Execution Stack Pointer, 0xfa

  // Data Stack
  BP, // Base Pointer, 0xf9
  SP, // Stack Pointer, 0xf8
  SS, // Stack Segment, 0xf7

  // Literal Pointer
  LS, // Literal Segment, 0xf6
  LP, // Literal Pointer, 0xf5

  // Test
  #[allow(clippy::upper_case_acronyms)]
  FLAGS, // computation flags, 0xf4
  #[allow(clippy::upper_case_acronyms)]
  TESTS, // Status, 0xf3

  // Function Calling
  Jmp, // Jump address pointer, 0xf2
  JS,  // Jump segment, 0xf1
  #[allow(clippy::upper_case_acronyms)]
  RVP, // Return value pointer, 0xf0
}
