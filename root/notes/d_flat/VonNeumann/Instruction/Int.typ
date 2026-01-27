
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Int`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann/Instruction.typ")

`Int` instruction is used to invoke interrupt.

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

There are two variant of `Int` instruction:
- Register variant:
  - Syntax: `:int reg`
  - Description: invoke interrupt with address stored in register `reg`
- Immediate variant:
  - Syntax: `:int idx`
  - Description: invoke interrupt with index `idx`
No flags used.

Basically, `int` instruction will save current execution status, and jump to interrupt handler function unit.
All registers will be pushed into global data stack.
The interrupt handler function unit will return to previous execution status by `iret` instruction.

Apart from 6 bits operator code and 3 bits type code, the rest 17 bits in R case, and rest 7 bits in I case must be 0.
Otherwise, invalid instruction exception will be raised automatically.

The `idx` in immediate variant is a 15 bits unsigned integer.
If `idx` larger than `0xff`, invalid interrupt exception will be raised automatically.

There are some pre-defined interrupt index:
- `0x00`: Exception Interrupt
- `0x01`: System Call Interrupt
- `0xff`: Halt Interrupt

For case with register variant, the value in register must be aligned to 4 bytes.
With unaligned address will raise invalid interrupt exception automatically.
Treat the value in register as address in global data stack segment.
And invoke interrupt handler function unit from that address.
