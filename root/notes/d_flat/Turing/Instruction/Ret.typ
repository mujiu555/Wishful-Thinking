
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Ret`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VM/Instruction.typ")

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

