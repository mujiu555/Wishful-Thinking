= D-Flat Spec

== Virtual Machine & Assembler

== Virtual Machine Design

The virtual machine works just similar to real CPU-memory.

The virtual machine has following properties:
- 32-bit instruction width
- 64-bit register size
- 32 general-purposed registers
- 32 special-purposed registers
The virtual machine adopt a new designed instruction set.

#include "Overview/Overview.typ"

#include "Register/Register.typ"

== Interrupt and Exception Handling

Interrupt handled by interrupt dispatch table.
The first 128 entries of function unit vector is reserved for interrupt handling.
When interrupt invoked, virtual machine will do following steps:
+ Store current execution status by pushing all registers into global data stack
+ Invoke interrupt handler function unit from interrupt dispatch table
+ After interrupt handler function unit return, restore previous execution status by popping all registers from global data stack

Exception handled by invoke exception handler function unit.
The default exception handler function unit is at index `0` in function unit vector. It is a special interrupt handler.

The interrupt handler must be provided by program,
if no interrupt handler provided, virtual machine will write interrupt dispatch table entry to point to default exception handler.
Which is a function unit that display exception trace information and halt the virtual machine.

Exception handle process do like described in instruction `raise`.

== Model

The execution model of virtual machine have following steps:
+ Load function unit into function unit vector
+ Initialize global data stack
+ Initialize execution stack
+ Initialize register records
+ Start execution from main function

When function call invoked, virtual machine will do following steps:
+ Push current function frame pointer into execution stack
+ Create new function frame in global data stack
+ push local variables into global data stack
+ start execution from called function

When function return invoked, virtual machine will do following steps:
+ Move return value into `Reg#A` and `Reg#R`, if the return value larger than 2 register can represent,
  move the returning value into pre-allocated space in global data stack, and move the pointer into `Reg#A`.
+ Pop current function frame from execution stack.
+ Clean up current function frame in global data stack.
+ Resume execution from previous function frame.

When snapshot exception invoked, virtual machine will do following steps:
+ Duplicate current global data stack segment, execution stack segment, and register records.

#include "Call/Call.typ"

#include "Instruction/Instruction.typ"
#include "Instruction/IS.typ"
#include "Instruction/Int.typ"
#include "Instruction/Snap.typ"


=== Instruction: `Raise`

`Raise` instruction is used to raise exception.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Immediate     | literal                       |             | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `Raise` instruction have one immediate parameter.
- Syntax: `:raise code`
- Description: raise exception with code `code`
No flag used.

Basically, `raise` instruction will invoke exception handler function unit.
Exception code will be passed to exception handler function unit via `Reg#FLAGS`.
Exception handler function unit may return to previous execution status by `iret` instruction.
Exception handler is a special interrupt handler.

There are some pre-defined exception code:
- `0x00`: General Exception
- `0x01`: Invalid Instruction Exception
- `0x02`: Invalid Operand Exception
- `0x03`: Invalid Variation Exception
- `0x04`: Arithmetic Exception
- `0x05`: Division by Zero Exception
- `0x06`: Shift Count Exception
- `0x07`: Arithmetic Overflow Exception
- `0x08`: Invalid Interrupt Exception
- `0x09`: Invalid Function Call Exception
- `0x0A`: Invalid Parameter Exception
- `0x0B`: Invalid Memory Access Exception
- `0x0C`: Invalid Segment Access Exception
- `0x0D`: Invalid Register Access Exception
- `0x0E`: Stack Overflow Exception
- `0x0F`: Stack Underflow Exception
- `0x10`: Invalid Register Access Exception
- `0x11`: Snapshot Restore Exception
- `0x12`: Snapshot Exception

=== Instruction: `Mov`

`Mov` instruction is used to move data between registers and memory.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |k| l |d| shl       |s| typ | operator  |
RR(1)         | register  | register  |             |o  |ss | typ | operator  |
RI            | register  | literal                     |o  | typ | operator  |
IR            | register  | literal                     |o  | typ | operator  |
RRI           | register  | register  | literal       | |ss | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `Mov` instruction have following variants:
- Register-Register variant:
  - Syntax: `:mov s dst, shl d(src)`
  - Type code: 0, `RR`
  - Description: move data from `src` to `dst`, shift left by `shl` bits, padding with 0 or 1 by `+` or `-`. `+` is default if omitted.
    - `dst`: target register
    - `src`: source register
    - `shl`: shift left bits, from `0` to `63`, optional, default is `0` if omitted
    - `s`: `+` or `-`, padding with `0` or `1`, optional, if provided, manual padding
    - `d`: shift direction and type, optional, default is left logical shift if omitted
      `<` for shift left logical,
      `>` for shift right logical,
      `>>` for shift right arithmetic,
      `rol` for roll left,
      `ror` for roll right,
      `lp` for manual padding shift
  - Flags:
    - `s`: padding bit, `0` for `+`, `1` for `-`, available only when l is `11`
    - `d`: shift direction, `0` for left, `1` for right
    - `l`: shift type code
      - `00`: logical shift
      - `01`: arithmetic shift
      - `10`: roll shift
      - `11`: manual padding shift
    - `shl`: 6 bits shift left bits
    - `k`: short process flag, if read as `0`, treat as shift left logical with `shl` bits shift.
- Register-Immediate variant:
  - Syntax: `:mov offset dst, val`
  - Type code: 1 / 2, `RI` / `RI`, if literal have 16th bit set, use second type code, otherwise use first type code
  - Description: move immediate value `val` to `dst`, offset can be `low16`, `high16`, `low16h`, `high16h` for low 16 or high 16 bits in totally low 32 bits of `dst` or low 16 or high 16 bits in totally high 32 bits of `dst`.
    - `dst`: target register
    - `val`: immediate value
    - `offset`: target offset
  - Flags:
    - `o`: 2 bits offset code
      - `00`: low 16
      - `01`: high 16
      - `10`: low 16h
      - `11`: high 16h
- Register-Address(Register) variant:
  - Syntax: `:mov ptr[dst], offset src`
  - Type code: 3, `RR(1)`
  - Description: move data from `src` to memory address `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size,
    offset can be `0`, `1`, `2`, `4` for source data offset
    - `dst`: target memory address register
    - `src`: source register
    - `ptr`: data size
    - `offset`: source data offset
  - Flags:
    - `ss`: 2 bits source data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword
    - `o`: 2 bits source data offset
      - `00`: 0
      - `01`: 1
      - `10`: 2
      - `11`: 4
- Address(Register)-Register variant:
  - Syntax: `:mov offset dst, ptr[src]`
  - Type code: 4, `RR(2)`
  - Description: deference memory address `src` and move data to `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size,
    offset can be `0`, `1`, `2`, `4` for target data offset
    - `dst`: target register
    - `src`: source memory address register
    - `ptr`: data size
    - `offset`: target data offset
  - Flags:
    - `ss`: 2 bits target data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword
    - `o`: 2 bits target data offset
      - `00`: 0
      - `01`: 1
      - `10`: 2
      - `11`: 4
- Address(Register)-Address(Register) variant:
  - Syntax: `:mov ptr [dst], [src]`
  - Type code: 5, `RR`
  - Description: move data from memory address `src` to memory address `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size
    - `dst`: target memory address register
    - `src`: source memory address register
    - `ptr`: data size
  - Flags:
    - `ss`: 2 bits data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword
- Register-Address(Register + Immediate) variant:
  - Syntax: `:mov dst, ptr[base + offset]`
  - Type code: 6, `RRI`
  - Description: move data from memory address calculated by `base` register plus immediate `offset` to `dst`
    - `dst`: target register
    - `base`: base register for memory address calculation
    - `offset`: immediate offset for memory address calculation
  - Flags: none
- Address(Register + Immediate)-Register variant:
  - Syntax: `:mov ptr[base + offset], src`
  - Type code: 7, `RIR`
  - Description: move data from `src` to memory address calculated by `base` register plus immediate `offset`
    - `src`: source register
    - `base`: base register for memory address calculation
    - `offset`: immediate offset for memory address calculation
  - Flags: none

All other combination of source and target operand are invalid for `Mov` instruction.

Basically, `mov` instruction copies data from source operand to target operand directly.

The whole `mov` instruction family can be divided into three categories:
- register to register move, including register-register variant, simply copy data between registers, with optional shift operation.
  Shift operation may be applied during data move.
  Depend on shift type and direction, data in source register will be shifted left or right by specified bits, and then moved to target register.
  For most case without shift operation, data in source register is copied directly to target register.
  ```c dst = src; ```
  For rest case with default shift operation,
  data int source register is shifted left logically by specified bits,
  and then moved to target register.
  ```c dst = src << shl; ```
  For rest case with specified shift operation,
  data in source register is shifted depend on shift type and direction,
  and then moved to target register.
  By register to register move, the user can simulate 32 bits general-purposed register, like in Risc-V or x86_64 architecture.
- immediate to register move, including register-immediate variant I and II, move immediate value to target register directly.
  The immediate value have 15 bits stored in instruction, the 16th bit distinguished by type code.
  For register-immediate variant I, 16th bit is `1`,
  for register-immediate variant II, 16th bit is `0`.
  The immediate value can be assigned to corresponding double-word in target register depend on offset parameter.
  Since the flags have 2 bits offset code, all four double-words in target register can be assigned separately.
- register to memory, memory to register and memory to memory move, including RR, RR, RR, RR, RRI, RIR variants,
  Addressing using register, or register plus immediate offset.
  Basically read value in register and or add immediate to the value, addressing global data stack using the value as memory address.
  Data size and data offset must be specified by flags.
  For data size:
  - 0 means qword (8 bytes)
  - 1 means bytes (1 byte)
  - 2 means word (2 bytes)
  - 3 means dword (4 bytes)
  For data offset:
  - 0 means offset 0
  - 1 means offset 1
  - 2 means offset 2
  - 3 means offset 4
  RR variant with Addressing(Register)-Addressing(Register) must have o with 0
  For RR(A(R)R) or RRI variant, Read ss bytes data from source memory address and write ss bytes data to target register with offset o.
  For RR(RA(R)) or RIR variant, Read ss bytes data from source register with offset o and write ss bytes data to target memory address.
  For RR(A(R)A(R)) variant, Read ss bytes data from source memory address and write ss bytes data to target memory address.

=== Instruction: `LSD`

`LSD` instruction is used to load or save data between global data stack and register `Reg#A` or `Reg#R`.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Immediate     | literal                       |             | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `LSD` instruction have one immediate parameter.
- Syntax: `:lsd op idx`
- Description: load or save data between global data stack and register `Reg#A` with index `idx`
  - `op`: operation type, can be one of following:
    - `load`: load data from global data stack to `Reg#A`
    - `save`: save data from `Reg#A` to global data stack
    - `loadr`: load data from global data stack to `Reg#R`
    - `saver`: save data from `Reg#R` to global data stack
    - `loadc`: load pre-defined data to `Reg#A`
- Flags:
  - `typ`: 3 bits operation type code
    - `000`: load
    - `001`: save
    - `010`: load into `Reg#R`
    - `011`: save from `Reg#R`
    - `100`: load constant

For the case of `load` operation, data is loaded from global data stack with index `idx` into target register.
For the case of `save` operation, data is saved from register `Reg#A` into global data stack with `idx`
For the case of `loadr` operation, data is loaded from global data stack with index `idx` into target register `Reg#R`.
For the case of `saver` operation, data is saved from register `Reg#R` into global data stack with `idx`.
For the case of `loadc` operation, pre-defined data with index `idx` is loaded into target register `Reg#A`.
Index `idx` can be:
- `0`: unsigned 64-bit integer `0`
- `1`: unsigned 64-bit integer maximum value
- `2`: unsigned 64-bit integer minimum value
- `3`: signed 64-bit integer `0`
- `4`: signed 64-bit integer maximum value
- `5`: signed 64-bit integer minimum value
- `6`: IEEE 754 double-precision floating-point `0.0`
- `7`: IEEE 754 double-precision floating-point maximum value
- `8`: IEEE 754 double-precision floating-point minimum value
- `9`: IEEE 754 double-precision floating-point Not-a-Number (NaN)
- `10`: IEEE 754 double-precision floating-point positive infinity
- `11`: IEEE 754 double-precision floating-point negative infinity
- `12`: IEEE 754 single-precision floating-point `0.0`
- `13`: IEEE 754 single-precision floating-point maximum value
- `14`: IEEE 754 single-precision floating-point minimum value
- `15`: IEEE 754 single-precision floating-point Not-a-Number (NaN)
- `16`: IEEE 754 single-precision floating-point positive infinity
- `17`: IEEE 754 single-precision floating-point negative infinity
- `18`: boolean `true`
- `19`: boolean `false`
- `20`: character `'\0'`
- `21`: character maximum value
- `22`: character minimum value
- `23`: null pointer

Basically, `lsd` instruction provides a simple way to load or save data between global data stack and register `Reg#A` or `Reg#R`.

=== Instruction: `OpI`

`OpI` instruction is used to perform arithmetic integer computation.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |                 | op| typ | operator  |
RR(1)         | register  | register  |             |ss | op| typ | operator  |
RI            | register  | literal                     | op| typ | operator  |
IR            | register  | literal                     | op| typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpI` instruction have following variants:
- Register-Register variant:
  - Syntax: `:opi op dst, src`
  - Type code: 0, `RR`
  - Description: perform arithmetic operation `op` on integer `dst` and `src`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - `dst`: target register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Register-Immediate variant:
  - Syntax: `:opi op dst, val`
  - Type code: 1, `RI`, `val` can be at most 15 bits integer, or 14 bits signed integer
  - Description: perform arithmetic operation `op` on integer `dst` and immediate value `val`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - `dst`: target register
    - `val`: immediate value
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Immediate-Register variant:
  - Syntax: `:opi op val, src`
  - Type code: 2, `IR`, `val` can be at most 15 bits integer, or 14 bits signed integer
  - Description: perform arithmetic operation `op` on integer `src` and immediate value `val`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - `src`: source register
    - `val`: immediate value
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Register-Address(Register) variant:
  - Syntax: `:opi op dst, ptr[src]`
  - Type code: 3, `RR(1)`
  - Description: perform arithmetic operation `op` on integer `dst` and memory address `src`, store result into `Reg#A`, carry or reminder into `Reg#R`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size
    - `dst`: target register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits source data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword
- Address(Register)-Register variant:
  - Syntax: `:opi op ptr[dst], src`
  - Type code: 4, `RR(1)`
  - Description: perform arithmetic operation `op` on integer memory address `dst` and integer `src`, store result into `Reg#A`, carry or reminder into `Reg#R`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size
    - `dst`: target memory address register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits target data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword
- Address(Register)-Address(Register) variant:
  - Syntax: `:opi op prt[dst], [src]`
  - Type code: 5, `RR`
  - Description: perform arithmetic operation `op` on integer memory address `dst` and integer memory address `src`, store result into `Reg#A`, carry or reminder into `Reg#R`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits data size code
      - `00`: qword
      - `01`: bytes
      - `10`: word
      - `11`: dword

`OpI` support following arithmetic operations:
- `add`: addition
- `sub`: subtraction
- `mul`: multiplication
- `div`: division

After `OpI` instruction executed, original `Reg#A` and `Reg#R` values are overwritten.

Basically, `OpI` instruction performs arithmetic operation on integer data.
And store result into `Reg#A`, carry or reminder into `Reg#R`.
For addition operation,
`dst` treated as addend, `src` treated as addor,
For subtraction operation,
`dst` treated as minuend, `src` treated as subtrahend,
For multiplication operation,
`dst` treated as multiplicand, `src` treated as multiplier,
For division operation,
`dst` treated as dividend, `src` treated as divisor.

=== Instruction: `OpF`

`OpF` instruction is used to perform arithmetic floating-point computation.


```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |             |ss | op| typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpF` instruction have following variants:
- Register-Register variant:
  - Syntax: `:opf op dst, src`
  - Type code: 0, `RR`
  - Description: perform arithmetic operation `op` on floating-point `dst` and `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Register-Address(Register) variant:
  - Syntax: `:opf op dst, ptr[src]`
  - Type code: 1, `RR(1)`
  - Description: perform arithmetic operation `op` on floating-point `dst` and memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Register variant:
  - Syntax: `:opf op ptr[dst], src`
  - Type code: 2, `RR(1)`
  - Description: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target memory address register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits target data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Address(Register) variant:
  - Syntax: `:opf op ptr[dst], [src]`
  - Type code: 3, `RR`
  - Description: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Register-Register Modulus variant:
  - Syntax: `:opf fmod dst, src`
  - Type code: 4, `RR`
  - Description: perform floating-point modulus operation on `dst` and `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target register
    - `src`: source register
  - Flags:
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Address(Register) Modulus variant:
  - Syntax: `:opf fmod ptr [dst], [src]`
  - Type code: 5, `RR`
  - Description: perform floating-point modulus operation on memory address `dst` and memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target memory address register
    - `src`: source memory address register
  - Flags:
    - `ss`: 2 bits data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128

If `ss` is `10`, float 128 operation is performed, and `Reg#R` store high 64 bits of result.
If `ss` is `10`, type code must be 3 or 5, only when both operands are memory address.

After `OpF` instruction executed, original `Reg#A` and `Reg#R` values are overwritten.

=== Instruction: `OpB`

`OpB` instruction is used to perform bitwise computation.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |                 |op | typ | operator  |
RI            | register  | literal                     |op | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpB` instruction have following variants:
- Register-Register variant:
  - Syntax: `:opb op dst, src`
  - Type code: 0, `RR`
  - Description: perform arithmetic operation `op` on bitwise `dst` and `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Register-Immediate variant:
  - Syntax: `:opb op dst, val`
  - Type code: 1, `RI`, `val` can be at most 15 bits integer, or 14 bits signed integer
  - Description: perform arithmetic operation `op` on bitwise `dst` and immediate value `val`, store result into `Reg#A`
    - `dst`: target register
    - `val`: immediate value
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Address(Register)-Register variant:
  - Syntax: `:opb op ptr[dst], src`
  - Type code: 2, `RR`
  - Description: perform arithmetic operation `op` on bitwise memory address `dst` and bitwise `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Register-Address(Register) variant:
  - Syntax: `:opb op dst, ptr[src]`
  - Type code: 3, `RR`
  - Description: perform arithmetic operation `op` on bitwise `dst` and bitwise memory address `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Address(Register)-Address(Register) variant:
  - Syntax: `:opb op ptr[dst], [src]`
  - Type code: 4, `RR`
  - Description: perform arithmetic operation `op` on bitwise memory address `dst` and bitwise memory address `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
- Address(Register)-Immediate variant:
  - Syntax: `:opb op ptr[dst], val`
  - Type code: 5, `RI`, `val` can be at most 15 bits integer, or 14 bits signed integer
  - Description: perform arithmetic operation `op` on bitwise memory address `dst` and immediate value `val`, store result into `Reg#A`
    - `dst`: target memory address register
    - `val`: immediate value
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code

`OpB` support following bitwise operations:
- `and`: bitwise AND
- `or`: bitwise OR
- `xor`: bitwise XOR
- `not`: bitwise NOT

For the case `op` is `not`, operation result of performance to `dst` will be stored into `Reg#A`, and other will be written to `Reg#R`.
For all other operations, result will be stored into `Reg#A`, and `Reg#R` is not modified.

=== Instruction: `OpS`

`OpS` instruction is used to perform shift computation.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |               | opt | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpS` instruction have following variants:
- Register-Register variant:
  - Syntax: `:ops op dst, src`
  - Type code: 0, `RR`
  - Description: perform shift operation `op` on `dst` by bits in `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Register-Address(Register) variant:
  - Syntax: `:ops op dst, ptr[src]`
  - Type code: 1, `RR`
  - Description: perform shift operation `op` on `dst` by bits in memory address `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source memory address register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Address(Register)-Register variant:
  - Syntax: `:ops op ptr[dst], src`
  - Type code: 2, `RR`
  - Description: perform shift operation `op` on memory address `dst` by bits in `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Address(Register)-Address(Register) variant:
  - Syntax: `:ops op ptr[dst], [src]`
  - Type code: 3, `RR`
  - Description: perform shift operation `op` on memory address `dst` by bits in memory address `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right

=== Instruction: `Test`

`Test` instruction is used to test condition and jump to target address if condition is met.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
II            | literal       | literal       |             | typ | operator  |

* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
```

The `Test` instruction have one immediate parameter.
- Syntax: `:test cond, addr`
- Description: test condition `cond`, if met, jump to target address `addr`
  - `cond`: condition to be tested
  - `addr`: target address to jump to if condition is met
- Flags: none

`cond` are integer indeed, can be written as following to prevent confusion:
- `Test#e`, 0, equal, zero flag is set
- `Test#g`, 1, greater, not equal and sign flag equals overflow flag
- `Test#ng`, 2, not greater, equal or sign flag not equals overflow flag
- `Test#l`, 3, less, sign flag not equals overflow flag
- `Test#nl`, 4, not less, sign flag equals overflow flag
- `Test#o`, 5, overflow, overflow flag is set
- `Test#no`, 6, not overflow, overflow flag is not set
- `Test#c`, 7, carry, carry flag is set
- `Test#nc`, 8, not carry, carry flag is not set
- `Test#z`, 9, zero, zero flag is set
- `Test#nz`, 10, not zero, not zero flag is set
- `Test#s`, 11, sign, sign flag is set

=== Instruction: `Jmp`

`Jmp` instruction is used to jump to target address unconditionally.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Register      | register  |                                 | typ | operator  |
Immediate     | literal                       |             | typ | operator  |
RI            | register  | literal                     |   | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
```

The `Jmp` instruction have following variants:
- Register variant:
  - Syntax: `:jmp short dst`
  - Type code: 0, R
  - Description: jump to target address in register `dst`
    - `dst`: target register
  - Flags: none
- Immediate variant:
  - Syntax: `:jmp near offset`
  - Type code: 1, I
  - Description: jump to address offset with `offset` from function entry point.
    - `offset`: target address offset
  - Flags: none
- Register-Immediate variant:
  - Syntax: `:jmp far dst, offset`
  - Type code: 2, RI
  - Description: jump to function with index `dst` in function unit vector, plus address offset `offset`
    - `dst`: target register
    - `offset`: immediate offset
  - Flags: none

Basically, `jmp` instruction provides a way to jump to target address unconditionally.
Used for control flow transfer in program execution.

=== Instruction: `Loop`

`Loop` instruction is used to perform loop operation with counter register.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Immediate     | literal                       |             | typ | operator  |

* literal: literal constant value, either in 16 bits or 8 bits integer.
```

The `Loop` instruction have no parameters.
- Syntax: `:loop addr`
- Description: decrement counter register `Reg#C`, if not zero, jump to target address `addr`
  - `addr`: target address to jump to if counter not zero
- Flags: none

Loop like x86 `loop` instruction, decrement counter register `Reg#C` by 1.

=== Instruction: `Call`

`Call` instruction is used to call function at target address.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Register      | register  |                                 | typ | operator  |
Immediate     | literal                       |             | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `Call` instruction have following variants:
- Register variant:
  - Syntax: `:call dst`
  - Type code: 0, R
  - Description: call function at target address in register `dst`
    - `dst`: target register
  - Flags: none
- Immediate variant:
  - Syntax: `:call idx`
  - Type code: 1, I
  - Description: call function with index `idx` in function unit vector
    - `idx`: target index
  - Flags: none

Basically, `call` instruction provides a way to call function.
All necessary function call setup must be done before `call` instruction executed.
Top of execution stack always trace both pointer to function and the execution status of the function.
Thus return address is stored automatically when `call` instruction executed.
Call instruction pushes new execution context onto execution stack.

=== Instruction: `Ret`

`Ret` instruction is used to return from function call.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Zero          | flags                                       | typ | operator  |

* flags: reserved space, for instruction extension use
```

The `Ret` instruction have no parameters.
- Syntax: `:ret`
- Description: return from current function call to caller function
- Flags: none

Basically, `ret` instruction provides a way to return from function call.
When `ret` instruction executed, current execution context is popped from execution stack,
`Reg#PC` and `Reg#EP` restored to caller function's context.

=== Instruction: `IRet`

`IRet` instruction is used to return from interruption handler.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Zero          | flags                                       | typ | operator  |

* flags: reserved space, for instruction extension use
```

The `IRet` instruction have no parameters.
- Syntax: `:iret`
- Description: return from current interruption handler to interrupted context
- Flags: none

Basically, `iret` instruction provides a way to return from interruption handler.
When `iret` instruction executed, register information stored when interruption occurs is restored.
Execution stack pop and continues execution of previous executed function.

=== Instruction: `RegF`

`RegF` instruction is used to register a new function.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |                     | typ | operator  |

* registers: 6 bits register code
```

The `RegF` instruction have two parameters.
- Syntax: `:regf skip, len`
- Description: register a new function with code length `len`, skip `skip` bytes after registration
  - `skip`: number of bytes to skip after registration
  - `len`: length of function code in bytes
- Flags: none

The `RegF` instruction creates a new function unit and assign the text with given data.
If `skip` and `len` is not aligned to instruction size a invalided instruction exception will be raised.

=== Instruction: `Stack`

`Stack` instruction is used to manipulate global data stack.


