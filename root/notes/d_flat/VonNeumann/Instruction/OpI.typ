
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `OpI`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann/Instruction.typ")

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

