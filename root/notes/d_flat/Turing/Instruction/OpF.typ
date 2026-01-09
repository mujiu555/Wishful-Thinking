
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Instruction: `OpF`]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing/Instruction.typ")


`OpF` instruction is used to perform arithmetic floating-point computation.


```txt
0x
              20              18              10              08              00
              |3 3 2 2 2 2 2 2|2 2 2 2 1 1 1 1|1 1 1 1 1 1 0 0|0 0 0 0 0 0 0 0|
Decimal       |1 0 9 8 7 6 5 4|3 2 1 0 9 8 7 6|5 4 3 2 1 0 9 8|7 6 5 4 3 2 1 0|
--------------------------------------------------------------------------------
RR            | register  | register  |             |ss | op| typ | operator  |

* registers: 6 bits register code
* literal: literal constant value, either in 16 bits or 8 bits integer.
* flags: reserved space, for instruction extension use
* RI and IR are two variant of same instruction, distinguish by instruction type
```

The `OpF` instruction have following variants:
- Register-Register variant:
  - Syntax: `:opf op dst, src`
  - Type code: 0, `RR`
  - Description: perform arithmetic operation `op` on floating-point `dst` and `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Register-Address(Register) variant:
  - Syntax: `:opf op dst, ptr[src]`
  - Type code: 1, `RR(1)`
  - Description: perform arithmetic operation `op` on floating-point `dst` and memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Register variant:
  - Syntax: `:opf op ptr[dst], src`
  - Type code: 2, `RR(1)`
  - Description: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target memory address register
    - `src`: source register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits target data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Address(Register) variant:
  - Syntax: `:opf op ptr[dst], [src]`
  - Type code: 3, `RR`
  - Description: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`, `ptr` can be `qword`(`0`), `dword`(`1`), `float128`(`2`) for data size
    - `dst`: target memory address register
    - `src`: source memory address register
    - `op`: arithmetic operation
  - Flags:
    - `op`: 2 bits operation code
    - `ss`: 2 bits data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Register-Register Modulus variant:
  - Syntax: `:opf fmod dst, src`
  - Type code: 4, `RR`
  - Description: perform floating-point modulus operation on `dst` and `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target register
    - `src`: source register
  - Flags:
    - `ss`: 2 bits source data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128
- Address(Register)-Address(Register) Modulus variant:
  - Syntax: `:opf fmod ptr [dst], [src]`
  - Type code: 5, `RR`
  - Description: perform floating-point modulus operation on memory address `dst` and memory address `src`, store result into `Reg#A`, reminder or high 64 bits of float 128 into `Reg#R`
    - `dst`: target memory address register
    - `src`: source memory address register
  - Flags:
    - `ss`: 2 bits data size code
      - `00`: double-precision
      - `01`: single-precision
      - `10`: float 128

If `ss` is `10`, float 128 operation is performed, and `Reg#R` store high 64 bits of result.
If `ss` is `10`, type code must be 3 or 5, only when both operands are memory address.

After `OpF` instruction executed, original `Reg#A` and `Reg#R` values are overwritten.

