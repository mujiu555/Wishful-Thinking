use crate::instset::operator::Operator;

pub struct Instruction {
  full_inst: u32,
  inst: Operator,
  literal: u32,
}
