
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Jmp`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann/Instruction.typ")

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

