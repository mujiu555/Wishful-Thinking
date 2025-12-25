
=== Instruction: `Snap`

`Snap` instruction is used to invoke snapshot exception.

```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
Zero          |                                           |f| typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `Snap` instruction have no parameter.
- Syntax: `:snap flags`
- Description: invoke snapshot exception

`flags` in syntax can be `full` or `light`, indicating full snapshot or light snapshot.
If flags is omitted, `full` is assumed.
If flags is `full`, the flag bit `f` is set to `1`, otherwise `0`.
If light snapshot invoked, only register records will be snapshotted.

Basically, `snap` instruction will duplicate current global data stack segment, execution stack segment, and register records.
Then snapshot exception may be handled by exception handler function unit.
Snapshot restore must be handled by user program explicitly.

Apart from 6 bits operator code and 3 bits type code, and 1 bits flag `f`, the rest 22 bits must be 0.
Otherwise, invalid instruction exception will be raised automatically.
