
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction Specification]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing.typ")

All Instruction adopted in the virtual machine are 32-bits length-fixed.

The instruction have four type of addressing method:
- None addressing: no parameter is accepted
- Register addressing: parameter is a register
- Immediate addressing: parameter is a literal value
- Memory addressing: parameter is a memory address

From all above addressing methods, the instruction can be divided into following categories:
- Zero operand instruction: no parameter
- Register operand instruction: only register parameter
- Immediate operand instruction: only literal parameter
- Memory operand instruction: only memory address parameter

- Register-Register operand instruction: two register parameters
- Register-Immediate operand instruction: one register parameter, one literal parameter
- Immediate-Register operand instruction: one literal parameter, one register parameter
- Register-Memory operand instruction: one register parameter, one memory address parameter
- Memory-Register operand instruction: one memory address parameter, one register parameter
- Memory-Memory operand instruction: two memory address parameters
- Immediate-Immediate operand instruction: two literal parameters
- Memory-Immediate operand instruction: one memory address parameter, one literal parameter

- Register-Register-Register operand instruction: three register parameters

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
              20          1a          18      10            09    06          00
Default       | register  | register  | register  |         | typ | operator  |
              | register  | register  |                     | typ | operator  |
              | register  |                                 | typ | operator  |
--------------------------------------------------------------------------------
Zero          | flags                                       | typ | operator  |
Register      | register  | flags                           | typ | operator  |
Immediate     | literal                       | flags       | typ | operator  |
RR            | register  | register  | flags               | typ | operator  |
RI            | register  | literal                     |   | typ | operator  |
IR            | register  | literal                     |   | typ | operator  |
II            | literal       | literal       | flags       | typ | operator  |
RRR           | register  | register  | register  | flags   | typ | operator  |
RRI           | register  | register  | literal       |flags| typ | operator  |
RIR           | register  | register  | literal       |flags| typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction pattern, distinguish by instruction type
* RRI and RIR are two variant of same instruction pattern, distinguish by instruction type
```


= #embed("./Instruction/IS.typ")
= #embed("./Instruction/Int.typ")
= #embed("./Instruction/Snap.typ")
= #embed("./Instruction/Raise.typ")
= #embed("./Instruction/Mov.typ")
= #embed("./Instruction/LSD.typ")
= #embed("./Instruction/OpI.typ")
= #embed("./Instruction/OpU.typ")
= #embed("./Instruction/OpF.typ")
= #embed("./Instruction/OpB.typ")
= #embed("./Instruction/OpS.typ")
= #embed("./Instruction/Test.typ")
= #embed("./Instruction/Jmp.typ")
= #embed("./Instruction/Loop.typ")
= #embed("./Instruction/Call.typ")
= #embed("./Instruction/Ret.typ")
= #embed("./Instruction/IRet.typ")
= #embed("./Instruction/RegF.typ")
= #embed("./Instruction/Stack.typ")


