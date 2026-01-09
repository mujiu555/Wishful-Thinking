
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `RegF`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")

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



