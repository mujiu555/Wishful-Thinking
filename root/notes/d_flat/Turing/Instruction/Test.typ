
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Test`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")

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

