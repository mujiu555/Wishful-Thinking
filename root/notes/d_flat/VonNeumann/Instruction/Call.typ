

#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Call`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann/Instruction.typ")

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

