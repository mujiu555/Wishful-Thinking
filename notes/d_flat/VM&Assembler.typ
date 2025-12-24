= D-Flat Spec

== Virtual Machine & Assembler

== Virtual Machine Design

The virtual machine works just similar to real CPU-memory.

The virtual machine have following properties:
- 32-bit instruction width
- 64-bit register size
- 32 general-purposed registers
- 32 special-purposed registers
The virtual machine adopt a new designed instruction set.

=== Architecture Overview

The virtual machine works in a register-memory architecture.
For each function unit, there are several sections:
- Text Section: for instructions, read-only, executable
- Data Section: for function global data, read-write
- Constant Section: for constant values, read-only, non-executable
- Closure Section: for closure data, read-only, non-executable, maps outer scope variable to inner function unit
When execution, there are several section will be loaded into memory:
- text segment: for instructions, read directly from text section, read-only, executable
- data segment: for function data, read directly from data section, closure variables will be mapped here, read-write, modify using load / store instructions
- literal segment: for literal data, read directly from constant section, read-only, load using load / mov instructions

For the global virtual machine, there are several segment:
- heap segment: for dynamic allocated data, read-write
- stack segment: for data stack, read-write
- execution stack: for function execution stack frames, pointers point to function units, read-write
- data segment: global data stack, read-write, modify using load / store instructions
- function unit segment: for function units, read-only, executable

=== Register

The register can be divided into two kinds:
- General Purposed Registers
- Special Purposed Registers
All registers are 64 bits length.
And can be represented use 6 bits number.

General-purposed registers can be visited by user freely, and can be updated by any instruction.
Change a general-purposed register will not affect any other register or virtual machine execution status.

Special-purposed registers reflects the execution status of virtual machine.
The value of special-purposed registers may be changed by virtual machine automatically.
Or changed by instructions automatically.

It is not recommended to change special-purposed registers directly,
though all special-purposed register can be read and write as general-purposed registers.

The name of registers start as "`Reg#`", and following are its name, a number or a string.

General-purposed registers may have only numbers as their name.
For example: `Reg#0`, `Reg#1`, ...
There are only 32 general-purposed registers available.

Special-purposed registers have their own name, and their own code (number):
- Result discarding used:
  - Ignore: `Reg#Ign`, code `0x3f`, any value move into will be ignored.
- Arithmetic computation, Result used:
  - Accumulator: `Reg#A`, code `0x3e`, for result of `ADD`, `SUB`, `MUL`, and `DIV`, or return value
  - Counter: `Reg#C`, code `0x3d`, for loop counts
  - Reminder: `Reg#R`, code `0x3c`, for reminder of `DIV`, or return value
- Execution locating used:
  - Program Counter `Reg#PC`, code `0x3b`, for next instruction to be executed
  - Execution Stack Pointer `Reg#EP`, code `0x3a`, for current execution frame in execution stack
- Stack locating used:
  - Stack Base Pointer `Reg#BP`, code `0x39`, for current stack frame base
  - Stack Top Pointer `Reg#SP`, code `0x38`, for current stack frame top
  - Stack Segment `Reg#SS`, code `0x37`, for stack segment
- Condition reflecting used:
  - flags: `Reg#FLAGS`, code `0x34`, for flags after instruction execution
  - tests: `Reg#TESTS`, code `0x33`, for test condition
- Control flow jump used:
  - Jump To Pointer: `Reg#Jmp`, code `0x32`, for jump address
  - Jump To Segment: `Reg#JS`, code `0x31`, for function segment

==== General Purposed Registers: `Reg#n`, n for number

General-purposed registers, from `Reg#0` to `Reg#1F` (31).
Can be visited by user freely.

==== Ignore: `Reg#Ign`

Ignore all value move into.

Assign-only register, special-purposed register that can be visited by user.
If user try to read value from it, always get zero.

==== Accumulator, Counter, Reminder: `Reg#A`, `Reg#C`, `Reg#R`

Every Result of `ADD`, `SUB`, `MUL`, and `DIV`, may assigned into `Reg#A`, accumulator.

Loop counts may relay on `Reg#C`, counter. If `LOOP` instruction used, `Reg#C` will be decremented by one automatically.

Reminder of `DIV` may assigned into `Reg#R`, reminder.

Fetch-only register, special-purposed register that can be visited by user.
Write operation on them will not have any effect.

It is possible to not use stack to pass return value between functions, then `Reg#A` and `Reg#R` used for return value passing.

==== Program Counter, Execution Stack Pointer: `Reg#PC`, `Reg#EP`

`Reg#PC` points to next instruction to be executed in current function frame.

`Reg#EP` points to current execution frame in execution stack.

Also used for provide unwind information.

Read only register, not recommended to write directly.
Write operation on them will affect the execution status of virtual machine.
If value written into `Reg#PC` is within corresponding text segment of current function frame, the next instruction to be executed will be changed.
If value written into `Reg#EP` is out of range, virtual machine will raise exception.
If value written into `Reg#EP` is less than current top of execution stack, virtual machine will unwind execution stack to the target frame.
If value written into `Reg#EP` is larger than current top of execution stack, virtual machine will raise exception.

==== Stack Segment, Stack Pointer, Base Pointer: `Reg#SS`, `Reg#SP`, `Reg#BP`

`Reg#SS` referencing Data Stack Segment, with offset $2^32$ (P.S., 4 GiB).
In most cases, `Reg#SS` won't be changed, since data stack works like normal stack, with a small size.

`Reg#SP` referencing Stack Top for current Function Frame.

`Reg#BP` referencing Stack Base for current Function Frame.

`Reg#SP` and `Reg#BP` won't less than 0, and won't larger than Segment length,
though they are 64 bit (52 bit for addressing) pointer.

Read Write register, not recommended to write directly.
The value of `Reg#SP` and `Reg#BP` will be changed automatically when push / pop / call / ret instructions executed.
The value of `Reg#SS` usually won't be changed, unless user allowed for a extremely large stack dynamically allocated.

User can write `Reg#SP` and `Reg#BP` directly to change the stack frame.
User can write `Reg#SS` directly to change the stack segment base.
If `Reg#SS` changed and not restored before returning from function, the behaviour of other function frame may be not correct.

==== Flags, Test: `Reg#FLAGS`, `Reg#TESTS`

After any instruction, `Reg#FLAGS` will be set according to execution result.

`:TEST dest, cond` instruction will set `Reg#TESTS`
and check whether `:AND Reg#TESTS, Reg#FLAGS`
will generate a true value and assign result into target register.

`:IF result, jmp` instruction will jump to `jmp` if `result` is a true value.

`:IFN result, jmp` instruction will jump to `jump` if `result` is a false value.

There are some literal for `TEST`.
- `Test#g`
- `Test#ng`
- `Test#l`
- `Test#nl`
- `Test#e`
- `Test#o`
- `Test#no`


```txt
0x
              00              08              10              18              20
                                                                              40
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
            => 3 3 3 3 3 3 3 3|4 4 4 4 4 4 4 4|4 4 5 5 5 5 5 5|5 5 5 5 6 6 6 6|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
            => 2 3 4 5 6 7 8 9|0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|
--------------------------------------------------------------------------------
              00                              10                              20
                                                                              40
Default       |C|1|P|0|A|0|Z|S|T|I|D|O|IOP|N|0|R|V|A|V*V*I|                   |
              |F| |F| |F| |F|F|F|F|F|F|L  |T| |F|M|C|F|P|D|                   |
            =>                                                                |
              |                                                               |
* VF <- VIF; VP <- VIP
```
- CF: Carry Flag
- PF: Parity Flag
- AF: Auxiliary Carry Flag
- ZF: Zero Flag
- SF: Sign Flag
- TF: Trap Flag

Write operation on them will not have any effect.

==== Jump To Pointer, Jump To Segment: `Reg#Jmp`, `Reg#JS`

`:JMP` instruction has three variant:
- `:JMP:near dest`: for short jump with offset
- `:JMP:short ptr[dest]`: for short jump using address
- `:JMP:far ptr[segment] : ptr[dest]`: for cross function jump

`:IF` and `:IFN` instructions are also instruction belongs to `:JMP` family.
But `:IF` family only has one variant that behaviour like `:JMP:short`.

`Reg#Jmp` used for addressing `dest` in `:JMP:short` and `:JMP:far`.

`Reg#JS` used for addressing function segment

=== Function Execution Stack

=== Addressing

=== Execution Stack

=== Data Stack

=== Literal Stack

=== Function Unit

=== Heap

=== Snapshot

=== Exception

When a internal exception (interrupt) happens,
`Reg#Jmp` will be set to address of interrupt handler in interrupt handler vector.

== Datum

=== Integer 64

=== Float 64

=== Pointer 12:4:48

== Execution

== Call Convention

=== Arguments

=== Return Address

Return Address recorded by Calling Stack

=== Returning

=== Module

```txt
4 byte
0xffff  |         |      <- RV
0xfffc  |         |
        |   ...   |
        ~         ~
        |   ...   |
0xff..  | <arg-2> |
0xff..  | <arg-1> |
        | < ret > | Saved PC
        |<local-1>|      <- sp
        ~         ~
        |   ...   |
```

== Instruction Form

All Instruction adopted in the virtual machine are 32-bits length-fixed.

An instruction may accept totally three kind of parameter lists:
- Zero parameter
- One parameter
- Two parameter

An instruction may do operation on two kind of object:
- Literal
- Register

An instruction have following variation:
- No parameter
- Literal: number
- Register: Reg\#n
- Addressing: [Reg\#n]
- Register, Literal
- Register, Register
- Register, Addressing: Register
- Addressing: Register, Register

All Addressing and Literal cases will have special register join and Address.
Which does not have any difference.

First 6 bit used to represent operation.
Following 3-bits to represent parameter type
Following 6 bits and following 16 bits are reserved.

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
--------------------------------------------------------------------------------
              00          06    09            10                              20
Default       |  operator |type | Reserved    |                               |

Zero          |  operator | Flags                                             |

R             |  operator |k | Flags                              | register  |
A             |  operator |                                       | register  |
I             |  operator |                   | Literal                       |
RR            |  operator |                   |       | register  | register  |
RI            |  operator |           |offset |       | literal   | register  |
IR            |  operator |           |offset |       | literal   | register  |
RA            |  operator |             | sl* |       | register  | register  |
AR            |  operator |       | ss* | dl* |       | register  | register  |
AA            |  operator |       | dl  | sl  |       | register  | register  |
LI            |  operator | Literal                                           |
J             |  operator |typ|                                               |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

== Instruction Set

VM CPU interruption:
- `Int`: interruption

Move:
- `Mov`: move
- `XChg`: swap

Literal Load:
- `LoadIL`: load integer (or data in format of integer) from constant vector, each function unit has a constant vector
- `LoadM`: load pre-defined data according to flags

Arithmetic:
- `Add`: add
- `Sub`: subtract
- `Mul`: multiple
- `Div`: divide

- Float Computation family:
  - `Addf`: add float
  - `Subf`: subtract float
  - `Mulf`: multiple float
  - `Divf`: divide float
  - `Modf`: mod float

- Bitwise Shift family:
  - `Shl`: shift left
  - `Sal`: shift arithmetic left
  - `RShl`: shift left roll
  - `Shr`: shift right
  - `Sal`: shift arithmetic right
  - `RShr`: shift right roll
  - `SShr`: shift signed right
  - `UShr`: shift unsigned right

Bitwise Boolean:
- `And`: and
- `Or`: or
- `Xor`: xor
- `Not`: not

Stack operations:
- `Push`: push
- `Pop`: pop
- `Idx`: peek
- `RIdx`: peek from bottom
- `Dup`: duplicate

Conditional:
- `Test`: test cond

Jump:
- `Jmp`: jump to

Loop:
- `Loop`: go back to ... and contrast a loop

Functional:
- `Call`: function call, jump
- `SysCall`: ffi
- `Ret`: restore stack and return
- `IRet`: interrupt return

Continuous:
- `SnapShot`

Misc:
- `Halt`: halt
- `Op`: do operation and save result into

=== `Int`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
I             |  operator |t|                 | Literal                       |
R             |  operator |t|                 |k | Flags      |   register    |
```

Corresponding instruction written in format:
- `Int reg`
- `Int immediate`

If `t` is 0, the instruction is called with immediate.
If `t` is 1, the instruction is called with register.

Basically, `Int` instruction invoke interrupt functions.
- Called with immediate, invoke corresponding interruption by id.
- Called with register, call function according to the address stored in register, the function must be interruption handler.

=== `Mov`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | typ |s| SHL       |   register    |   register    |
RI positive l |  operator | typ | literal                     |   register    |
RI negative l |  operator | typ | literal                     |   register    |
RI positive h |  operator | typ | literal                     |   register    |
RI negative h |  operator | typ | literal                     |   register    |
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

`Mov` instruction:
Move copies data from source to destination.
- `MOV dst, src`
- `MOV offset dst, immediate`
- `MOV dst, ptr [src]`
- `MOV ptr [dst], src`
- `MOV ptr [dst], ptr [src]`

Basically, `mov` instruction needs two argument.
It could be two register, register-immediate, register-address, address-register or address-address pair.

There are 32 bits totally for the instruction, 6 bits for operator, 3 bits to distinct which type the `mov` instruction is.
Totally 9 types.

For two register case:
```txt
              00          06    09 a          10                              20
RR            |  operator | typ |s| SHL       |   register    |   register    |
```

Corresponding instruction written in format: `MOV dst, src`

Apart from 9 bits prefix, there are 7 bits flag and 16 bits registers information.

Flag modify the behaviour of `mov`:
- 1 bit `s` for sign.
- 6 bits `SHL` for left shift counts.

If `SHL` has value of nonzero, register `dst` will be assigned with value `src << SHL`.
Padding with 0 on the right.
Likely ```c dst = src << SHL;``` in C.

If `s` has value of nonzero, register `dst` will be assigned with value `src << SHL`.
Padding with 1 on the right.

If `dst` has a prefix `-`, the s will be set.
If `src` written in form of `shl(src)` instead of regular `src`, `SHL` will be set.
`dst` and `src` can only be string that represent registers.
E.g.,
- `mov Reg#1, Reg#a`
- `mov -Reg#2, Reg#1`
- `mov Reg#3, 2(Reg#2)`
- `mov -Reg#4, 1(Reg#3)`

For cases associated immediate:
```txt
              00          06    09            10                              20
RI positive l |  operator | typ | literal                     |   register    |
RI negative l |  operator | typ | literal                     |   register    |
RI positive h |  operator | typ | literal                     |   register    |
RI negative h |  operator | typ | literal                     |   register    |
```

Corresponding instruction written in format: `MOV offset dst, immediate`

Apart from 9 bits prefix, there are 15 bits literal and 8 bits registers information.

If instruction has type l, for low, literal will be written in low 16 bits with 16th bit controlled by type of instruction.
If instruction has type h, for high, literal will be written in 16-32 bits with 32 bit controlled by type of instruction.

If instruction has type positive, sign bit will be set as 0.
If instruction has type negative, sign bit will be set as 1.

So that a instruction can fulfill the assignment of 16bits.

According to `offset`, l, or h version of `mov` will be chosen.
According to `immediate`, positive of negative version of `mov` will be chosen.

`dst` can only be string that represent registers.
`immediate` can only be number literal.

E.g.,
- `mov Reg#1, 12345`
- `mov Reg#2, -12345`
- `mov h Reg#3, 12345`
- `mov l Reg#4, 65535`

For cases associated addresses:
```txt
              00          06    09 a    0d    10                              20
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |
```

Corresponding instruction written in format:
- `MOV dst, ptr [src]`
- `MOV ptr [dst], src`
- `MOV ptr [dst], ptr [src]`

Apart from 9 bits prefix, there are 7 bits flag and 16 bits register, address information.

Flag modify the behaviour of `MOV` instruction:
- `k`: reserved
- `sl`: source data length, how much data are there, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
- `ss`: source offset, copy which part of data to destination, can be 0, 1, 2, 4, or for special cases, can be any between 0\~4.
- `dl`: destination data length, how much data can be written, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
For all instructions, `sl` must have same value as `dl`.
For all instructions, 8 - `ss` must have same value as `dl`.

The register corresponding to address should store the address information.
This move instruction will dereference the address and copy value to `dst`.

E.g.,
- `mov Reg#1, ptr [Reg#2]`: `sl` 0
- `mov Reg#3, dword ptr [Reg#4]`: `sl` 4
- `mov ptr [Reg#5], Reg#6`: `ss` 0, `dl` 0
- `mov byte ptr [Reg#7], Reg#8`: `ss` 0, `dl` 1
- `mov byte ptr [Reg#9], 1(Reg#10)`: `ss` 1, `dl` 4, likely `mov [...], ah`
- `mov ptr [Reg#11], ptr [Reg#12]`: `sl` 0, `dl` 0

=== `LoadIL`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
LI            |  operator | Literal                                           |
```

Corresponding instruction written in format: `LoadIL idx`.

Load a integer from constant value vector and assign to `Reg#a`.

=== `LoadM`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
Zero          |  operator | Flags                                             |
```

Corresponding instruction written in format: `LoadIM type`.
Flag can be a integer only.
- `type`: which pre-defined data to load.
  - `0`: Load a signed 64-bit integer minimum into register `Reg#a`
  - `1`: Load a signed 64-bit integer maximum into register `Reg#a`
  - `2`: Load a signed 64-bit integer zero into register `Reg#a`
  - `3`: Load a unsigned 64-bit integer maximum into register `Reg#a`
  - `4`: Load a float 64 zero into register `Reg#a`
  - `5`: Load a float 64 minimum into register `Reg#a`
  - `6`: Load a float 64 maximum into register `Reg#a`
  - `7`: Load a float 32 zero into register `Reg#a`
  - `8`: Load a float 32 minimum into register `Reg#a`
  - `9`: Load a float 32 maximum into register `Reg#a`
  - `10`: Load a true boolean into register `Reg#a`
  - `11`: Load a false boolean into register `Reg#a`

Load pre-defined data according to flags into register `Reg#a`.

=== `Add`, `Sub`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | typ |             |   register    |   register    |
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

`Add` instruction:
Adds two values and store result into register `Reg#a`.
- `ADD dst, src`
- `ADD dst, immediate`
- `ADD immediate, src`
- `ADD immediate1, immediate2`
- `ADD dst, ptr [src]`
- `ADD ptr [dst], src`
- `ADD ptr [dst], ptr [src]`
Add instruction has almost same format as `Mov` instruction.
If overflow happens, the carry flag (CF) in `Reg#FLAGS` will be set, overflowed value stored in `Reg#R`, reminder register.
`src` and `dst` for adder and addend respectively.

`Sub` instruction:
Subtracts two values and store result into register `Reg#a`.
- `SUB dst, src`
- `SUB dst, immediate`
- `SUB immediate, src`
- `SUB immediate1, immediate2`
- `SUB dst, ptr [src]`
- `SUB ptr [dst], src`
- `SUB ptr [dst], ptr [src]`
Sub instruction has almost same format as `Mov` instruction.
If carry happens, the carry flag (CF) in `Reg#FLAGS` will be set, overflowed value stored in `Reg#R`, reminder register.
`src` and `dst` for minuend and subtrahend respectively.

Basically, `Add` and `Sub` instruction needs two argument.
It could be two register, register-immediate, register-address, address-register or address-address pair.

There are 32 bits totally for the instruction, 6 bits for operator, 3 bits to distinct which type the `Add`/`Sub` instruction is.

For two register case:
```txt
              00          06    09 a          10                              20
RR            |  operator | typ |             |   register    |   register    |
```

Corresponding instruction written in format:
- `ADD dst, src`
- `SUB dst, src`

E.g.,
- `add Reg#1, Reg#2`
- `sub Reg#3, Reg#2`

For cases associated immediate:
```txt
              00          06    09            10                              20
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
```

Corresponding instruction written in format:
- `ADD dst, immediate`
- `SUB dst, immediate`
- `ADD immediate, src`
- `SUB immediate, src`
- `ADD immediate1, immediate2`
- `SUB immediate1, immediate2`

Apart from 9 bits prefix, there are 15 bits literal and 8 bits registers information.
Or, 1-bits reserved and two 11-bits literal for `II` type.

E.g.,
- `add Reg#1, -2`
- `sub Reg#2, 10`

For cases associated addresses:
```txt
              00          06    09 a    0d    10                              20
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k|     | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |
```

Corresponding instruction written in format:
- `ADD dst, ptr [src]`
- `SUB dst, ptr [src]`
- `ADD ptr [dst], src`
- `SUB ptr [dst], src`
- `ADD ptr [dst], ptr [src]`
- `SUB ptr [dst], ptr [src]`

Apart from 9 bits prefix, there are 7 bits flag and 16 bits register, address information.

Falg modify the behaviour of `ADD`/`SUB` instruction:
- `k`: reserved
- `sl`: source data length, how much data are there, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
- `dl`: destination data length, how much data can be written, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
For all instructions, `sl` must have same value as `dl`.

The register corresponding to address should store the address information.
This `ADD`/`SUB` instruction will dereference the address and do addition/subtraction.

E.g.,
- `add Reg#1, ptr [Reg#2]`: `sl` 0
- `sub Reg#3, dword ptr [Reg#4]`: `sl` 4
- `add ptr [Reg#5], Reg#6`: `ss` 0, `dl` 0
- `sub byte ptr [Reg#7], Reg#8`: `ss` 0, `dl` 1
- `add ptr [Reg#9], ptr [Reg#10]`: `sl` 0, `dl` 0

=== `Mul`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | typ |             |   register    |   register    |
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

`Mul` instruction:
Multiplies two values and store result into register `Reg#a`.
- `MUL dst, src`
- `MUL dst, immediate`
- `MUL immediate, src`
- `MUL immediate1, immediate2`
- `MUL dst, ptr [src]`
- `MUL ptr [dst], src`
- `MUL ptr [dst], ptr [src]`
Mul instruction has almost same format as `Add` instruction.
`src` and `dst` for multiplicand and multiplier respectively.

Basically, `Mul` instruction needs two argument.
It could be two register, register-immediate, register-address, address-register or address-address pair.

There are 32 bits totally for the instruction, 6 bits for operator, 3 bits to distinct which type the `Mul` instruction is.

For two register case:
```txt
              00          06    09 a          10                              20
RR            |  operator | typ |             |   register    |   register    |
```
Corresponding instruction written in format:
- `MUL dst, src`

For cases associated immediate:
```txt
              00          06    09            10                              20
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
```

Corresponding instruction written in format:
- `MUL dst, immediate`
- `MUL immediate, src`
- `MUL immediate1, immediate2`

Apart from 9 bits prefix, there are 15 bits literal and 8 bits registers information.
Or, 1-bits reserved and two 11-bits literal for `II` type.

For cases associated addresses:

```txt
              00          06    09 a    0d    10                              20
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k|     | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |
```

Corresponding instruction written in format:
- `MUL dst, ptr [src]`
- `MUL ptr [dst], src`
- `MUL ptr [dst], ptr [src]`

Apart from 9 bits prefix, there are 7 bits flag and 16 bits register, address information.
- `k`: reserved
- `sl`: source data length, how much data are there, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
- `dl`: destination data length, how much data can be written, can be 1
For all instructions, `sl` must have same value as `dl`.

The register corresponding to address should store the address information.
This `MUL` instruction will dereference the address and do multiplication.

=== `Div`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | typ |             |   register    |   register    |
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

`Div` instruction:
Divides two values and store result into register `Reg#a`, store remainder into `Reg#R`.
- `DIV dst, src`
- `DIV dst, immediate`
- `DIV immediate, src`
- `DIV immediate1, immediate2`
- `DIV dst, ptr [src]`
- `DIV ptr [dst], src`
- `DIV ptr [dst], ptr [src]`
Div instruction has almost same format as `Add` instruction.
`src` and `dst` for divisor and dividend respectively.

Basically, `Div` instruction needs two argument.
It could be two register, register-immediate, register-address, address-register or address-address pair.

there are 32 bits totally for the instruction, 6 bits for operator, 3 bits to distinct which type the `Div` instruction is.

For two register case:
```txt
              00          06    09 a          10                              20
RR            |  operator | typ |             |   register    |   register    |
```
Corresponding instruction written in format:
- `DIV dst, src`

For cases associated immediate:
```txt
              00          06    09            10                              20
RI            |  operator | typ | literal                     |   register    |
IR            |  operator | typ | literal                     |   register    |
II            |  operator | typ |k| literal             | literal             |
```

Corresponding instruction written in format:
- `DIV dst, immediate`
- `DIV immediate, src`
- `DIV immediate1, immediate2`

Apart from 9 bits prefix, there are 15 bits literal and 8 bits registers information.
Or, 1-bits reserved and two 11-bits literal for `II` type.

For cases associated addresses:

```txt
              00          06    09 a    0d    10                              20
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k|     | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |
```

Corresponding instruction written in format:
- `DIV dst, ptr [src]`
- `DIV ptr [dst], src`
- `DIV ptr [dst], ptr [src]`

Apart from 9 bits prefix, there are 7 bits flag and 16 bits register, address information.
- `k`: reserved
- `sl`: source data length, how much data are there, can be 1, 2, 4, 0 (0 for 8), or for special cases, can be any between 0\~7.
- `dl`: destination data length, how much data can be written, can be 1
For all instructions, `sl` must have same value as `dl`.

The register corresponding to address should store the address information.
This `DIV` instruction will dereference the address and do division.

=== Float Computation Family: `Addf`, `Subf`, `Mulf`, `Divf`, `Modf`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | typ     | e | f | |   register    |   register    |
RA            |  operator | typ     | e | f | |   register    |   register    |
AR            |  operator | typ     | e | f | |   register    |   register    |
AA            |  operator | typ     | e | f | |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

Instruction format for floating point arithmetic operations.
- `ADDF dst, src`
- `SUBF dst, src`
- `MULF dst, src`
- `DIVF dst, src`
- `MODF dst, src`
- `ADDF dst, ptr [src]`
- `SUBF dst, ptr [src]`
- `MULF dst, ptr [src]`
- `DIVF dst, ptr [src]`
- `MODF dst, ptr [src]`
- `ADDF ptr [dst], src`
- `SUBF ptr [dst], src`
- `MULF ptr [dst], src`
- `DIVF ptr [dst], src`
- `MODF ptr [dst], src`
- `ADDF ptr [dst], ptr [src]`
- `SUBF ptr [dst], ptr [src]`
- `MULF ptr [dst], ptr [src]`
- `DIVF ptr [dst], ptr [src]`
- `MODF ptr [dst], ptr [src]`

Do floating point arithmetic operation and store result into register `Reg#a` and `Reg#r`.
In most cases, `Reg#R` will be cleared to zero.
Only if float 128 is used, `Reg#R` will store the overflowed part, higher 64 bits.

Basically, floating point arithmetic instructions needs two argument.
It could be two register, register-address, address-register or address-address pair.

All floating point arithmetic instructions share same operator number, distinct by type field.
There are 32 bits totally for the instruction, 6 bits for operator, 5 bits to distinct which type the instruction is,
2 bits for exponent size, 2 bits for fraction size.
- `e`: exponent size
  - `00`: 8 bits
  - `01`: 11 bits
  - `10`: 15 bits
- `f`: fraction size
  - `00`: 23 bits
  - `01`: 52 bits
  - `10`: 112 bits
`e` with `f` combination decide which floating point format to use.
1010 for `e` and `f` only available for `AA` type, which means decimal arithmetic with arbitrary precision.

=== Bitwise Shift family: `Shl`, `Sal`, `RShl`, `Shr`, `Sar` `RShr`, `SShr`, `UShr`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
RR            |  operator | ty|p|r| s |       |   register    |   register    |
RI            |  operator | ty|p|r| s |       |   literal     |   register    |
RA            |  operator | ty|p|r| s |       |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

Corresponding instructions written in format:
- `SHL dst, src`
- `SAL dst, src`
- `RSHL dst, src`
- `SHR dst, src`
- `SAR dst, src`
- `RSHR dst, src`
- `SSHR dst, src`
- `USHR dst, src`
- `SHL dst, immediate`
- `SAL dst, immediate`
- `RSHL dst, immediate`
- `SHR dst, immediate`
- `SAR dst, immediate`
- `RSHR dst, immediate`
- `SSHR dst, immediate`
- `USHR dst, immediate`
- `SHL dst, ptr [src]`
- `SAL dst, ptr [src]`
- `RSHL dst, ptr [src]`
- `SHR dst, ptr [src]`
- `SAR dst, ptr [src]`
- `RSHR dst, ptr [src]`
- `SSHR dst, ptr [src]`
- `USHR dst, ptr [src]`
Shift instructions shift bits to left or right, rolling or not, arithmetic or logical.
The change will be saved into register `Reg#a`.
All shift instructions share same operator number, distinct by type field.

Basically , shift instructions needs two argument.
It could be two register, register-immediate, or register-address pair.

There are 32 bits totally for the instruction, 6 bits for operator, 2 bits to distinct which type the instruction is,
1 bit for shift destination, 1 bit for roll or not, 2 bit for arithmetic or logical, or padding with 1 or 0.
- `ty`: type of shift
  - `00`: RR type
  - `01`: RI type
  - `10`: RA type
- `p`: destination
  - `0`: left
  - `1`: right
- `r`: roll
  - `0`: no roll
  - `1`: roll
- `s`: shift
  - `00`: logical
  - `01`: arithmetic
  - `10`: padding 0 only
  - `11`: padding 1 only
If `r` set, `s` must be 00.

`SH*` will shift bits padding with 0 only.
`RSH*` will shift bits rolling.
`SA*` will shift bits arithmetically.
`USH*` will shift bits padding with 0 only.
`SSH*` will shift bits padding with 1 only.

=== `And`, `Or`, `Xor`, `Not`

```txt
0x
              00              08              10              18              20
              |0 0 0 0 0 0 0 0|0 0 1 1 1 1 1 1|1 1 1 1 2 2 2 2|2 2 2 2 2 2 3 3|
Decimal       |0 1 2 3 4 5 6 7|8 9 0 1 2 3 4 5|6 7 8 9 0 1 2 3|4 5 6 7 8 9 0 1|
              00          06    09            10                              20
----------------------------------------------------------------------------------
Default       |  operator |type | Reserved    |                               |
----------------------------------------------------------------------------------
R             |  operator |k | Flags                          |   register    |
A             |  operator |                                   |   register    |
RR            |  operator | typ |             |   register    |   register    |
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

Corresponding instructions written in format:
- `AND dst, src`
- `OR dst, src`
- `XOR dst, src`
- `AND dst, immediate`
- `OR dst, immediate`
- `XOR dst, immediate`
- `AND dst, ptr [src]`
- `OR dst, ptr [src]`
- `XOR dst, ptr [src]`
- `AND ptr [dst], src`
- `OR ptr [dst], src`
- `XOR ptr [dst], src`
- `AND ptr [dst], ptr [src]`
- `OR ptr [dst], ptr [src]`
- `XOR ptr [dst], ptr [src]`
- `NOT dst`
- `NOT ptr [dst]`


=== `Push`
=== `Pop`
=== `Idx`
=== `RIdx`
=== `Dup`

=== `Jmp`

```txt
              00          06    09            10                              20
J_near i      |  operator |00 | jump address                                  |
J_short       |  operator |10 |               |               |   register    |
J_far         |  operator |11 |               |   register    |   register    |
```

=== `Test`
=== `If`
=== `Ifn`

=== `Loop`

=== `Call`
=== `Ret`

=== `SysCall`

=== `SnapShot`

=== `Halt`
=== `Op`

== Assembly

=== Label

=== Addressing
