
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `Raise`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")

`Raise` instruction is used to raise exception.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Immediate     | literal                       |             | typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `Raise` instruction have one immediate parameter.
- Syntax: `:raise code`
- Description: raise exception with code `code`
No flag used.

Basically, `raise` instruction will invoke exception handler function unit.
Exception code will be passed to exception handler function unit via `Reg#FLAGS`.
Exception handler function unit may return to previous execution status by `iret` instruction.
Exception handler is a special interrupt handler.

There are some pre-defined exception code:
- `0x00`: General Exception
- `0x01`: Invalid Instruction Exception
- `0x02`: Invalid Operand Exception
- `0x03`: Invalid Variation Exception
- `0x04`: Arithmetic Exception
- `0x05`: Division by Zero Exception
- `0x06`: Shift Count Exception
- `0x07`: Arithmetic Overflow Exception
- `0x08`: Invalid Interrupt Exception
- `0x09`: Invalid Function Call Exception
- `0x0A`: Invalid Parameter Exception
- `0x0B`: Invalid Memory Access Exception
- `0x0C`: Invalid Segment Access Exception
- `0x0D`: Invalid Register Access Exception
- `0x0E`: Stack Overflow Exception
- `0x0F`: Stack Underflow Exception
- `0x10`: Invalid Register Access Exception
- `0x11`: Snapshot Restore Exception
- `0x12`: Snapshot Exception

