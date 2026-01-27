
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `LSD`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann/Instruction.typ")

`LSD` instruction is used to load or save data between global data stack and register `Reg#A` or `Reg#R`.

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

The `LSD` instruction have one immediate parameter.
- Syntax: `:lsd op idx`
- Description: load or save data between global data stack and register `Reg#A` with index `idx`
  - `op`: operation type, can be one of following:
    - `load`: load data from global data stack to `Reg#A`
    - `save`: save data from `Reg#A` to global data stack
    - `loadr`: load data from global data stack to `Reg#R`
    - `saver`: save data from `Reg#R` to global data stack
    - `loadc`: load pre-defined data to `Reg#A`
- Flags:
  - `typ`: 3 bits operation type code
    - `000`: load
    - `001`: save
    - `010`: load into `Reg#R`
    - `011`: save from `Reg#R`
    - `100`: load constant

For the case of `load` operation, data is loaded from global data stack with index `idx` into target register.
For the case of `save` operation, data is saved from register `Reg#A` into global data stack with `idx`
For the case of `loadr` operation, data is loaded from global data stack with index `idx` into target register `Reg#R`.
For the case of `saver` operation, data is saved from register `Reg#R` into global data stack with `idx`.
For the case of `loadc` operation, pre-defined data with index `idx` is loaded into target register `Reg#A`.
Index `idx` can be:
- `0`: unsigned 64-bit integer `0`
- `1`: unsigned 64-bit integer maximum value
- `2`: unsigned 64-bit integer minimum value
- `3`: signed 64-bit integer `0`
- `4`: signed 64-bit integer maximum value
- `5`: signed 64-bit integer minimum value
- `6`: IEEE 754 double-precision floating-point `0.0`
- `7`: IEEE 754 double-precision floating-point maximum value
- `8`: IEEE 754 double-precision floating-point minimum value
- `9`: IEEE 754 double-precision floating-point Not-a-Number (NaN)
- `10`: IEEE 754 double-precision floating-point positive infinity
- `11`: IEEE 754 double-precision floating-point negative infinity
- `12`: IEEE 754 single-precision floating-point `0.0`
- `13`: IEEE 754 single-precision floating-point maximum value
- `14`: IEEE 754 single-precision floating-point minimum value
- `15`: IEEE 754 single-precision floating-point Not-a-Number (NaN)
- `16`: IEEE 754 single-precision floating-point positive infinity
- `17`: IEEE 754 single-precision floating-point negative infinity
- `18`: boolean `true`
- `19`: boolean `false`
- `20`: character `'\0'`
- `21`: character maximum value
- `22`: character minimum value
- `23`: null pointer

Basically, `lsd` instruction provides a simple way to load or save data between global data stack and register `Reg#A` or `Reg#R`.

