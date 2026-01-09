
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Loop`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")



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

