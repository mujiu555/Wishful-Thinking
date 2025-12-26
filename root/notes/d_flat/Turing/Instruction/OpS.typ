
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `OpS`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VM/Instruction.typ")

`OpS` instruction is used to perform shift computation.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |               | opt | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpS` instruction have following variants:
- Register-Register variant:
  - Syntax: `:ops op dst, src`
  - Type code: 0, `RR`
  - Description: perform shift operation `op` on `dst` by bits in `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Register-Address(Register) variant:
  - Syntax: `:ops op dst, ptr[src]`
  - Type code: 1, `RR`
  - Description: perform shift operation `op` on `dst` by bits in memory address `src`, store result into `Reg#A`
    - `dst`: target register
    - `src`: source memory address register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Address(Register)-Register variant:
  - Syntax: `:ops op ptr[dst], src`
  - Type code: 2, `RR`
  - Description: perform shift operation `op` on memory address `dst` by bits in `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right
- Address(Register)-Address(Register) variant:
  - Syntax: `:ops op ptr[dst], [src]`
  - Type code: 3, `RR`
  - Description: perform shift operation `op` on memory address `dst` by bits in memory address `src`, store result into `Reg#A`
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: shift operation
  - Flags:
    - `opt`: 3 bits operation code
      - `000`: logical left shift
      - `001`: logical right shift
      - `010`: arithmetic left shift
      - `011`: arithmetic right shift
      - `100`: rotate left
      - `101`: rotate right
      - `110`: rotate through carry left
      - `111`: rotate through carry right

