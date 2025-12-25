
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Mov`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VM/Instruction.typ")

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

