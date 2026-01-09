
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `OpB`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")


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

