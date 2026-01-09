
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `IRet`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")

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

