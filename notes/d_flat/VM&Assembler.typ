= D-Flat Spec

== Virtual Machine & Assembler

== Virtual Machine Design

The virtual machine works just similar to real CPU.

The virtual machine have:
- $2^7$ general-purposed register
- SP, BP, SS, PC, DS, ES, and other special-purposed register
- Almost infinite Stack for Data
- Literal Pool
- Almost infinite Calling Stack

=== Register

The register can be divided into two kinds:
- General Purposed Registers
- Special Purposed Registers

The general-purposed registers may appear directly in instructions.
Most special-purposed registers can only update automatically by instructions call.

The name of registers start as "`Reg#`", and following are its name.

General-purposed registers may have only numbers as their name.
For example: `Reg#0`, `Reg#1`, ...
There are only 128 general-purposed registers available.

Special-purposed registers have their own name, and their own code (number).

First one is used to discard result:
- Ignore: `Reg#Ign`, code `0xff`

Second three are register for calculation:
- Accumulator: `Reg#A`, code `0xfe`
- Counter: `Reg#C`, code `0xfd`
- Reminder: `Reg#R`, code `0xfc`

Third two used to instruct execution status:
- Program Counter `Reg#PC`, code `0xfb`
- Execution Stack Pointer `Reg#EP`, code `0xfa`

Forth three used to direct data stack:
- Stack Base Pointer `Reg#BP`, code `0xf9`
- Stack Top Pointer `Reg#SP`, code `0xf8`
- Stack Segment `Reg#SS`, code `0xf7`

Fifth two used to locate literal:
- Literal Segment `Reg#LS`, code `0xf6`
- Literal Pointer `Reg#LP`, code `0xf5`

Sixth two used for test:
- flags: `Reg#FLAGS`, code `0xf4`
- tests: `Reg#TESTS`, code `0xf3`

Seventh three used for function calling:
- Jump To Pointer: `Reg#Jmp`, code `0xf2`
- Jump To Segment: `Reg#JS`, code `0xf1`
- Return Value Pointer: `Reg#RVP`, code `0xf0`

==== General Purposed Registers: `Reg#n`, n for number

==== Ignore: `Reg#Ign`

Ignore all value move into.

Assign-only register, special-purposed register that can be visited by user.

==== Accumulator, Counter, Reminder: `Reg#A`, `Reg#C`, `Reg#R`

Every Result of `ADD`, `SUB`, `MUL`, and `DIV`, may assigned into `Reg#A`, accumulator.

Loop counts may relay on `Reg#C`.

Reminder of `DIV` may assigned into `Reg#R`

Fetch-only register, special-purposed register that can be visited by user.

==== Program Counter, Execution Stack Pointer: `Reg#PC`, `Reg#EP`

`Reg#PC` points to next instruction to be executed in current function frame.

`Reg#EP` points to current execution frame in execution stack.

Also used for provide unwind information.

May have their value available to user by instruction calling.

==== Stack Segment, Stack Pointer, Base Pointer: `Reg#SS`, `Reg#SP`, `Reg#BP`

`Reg#SS` referencing Data Stack Segment, with offset $2^32$ (P.S., 4 GiB).

`Reg#SP` referencing Stack Top for current Function Frame.

`Reg#BP` referencing Stack Base for current Function Frame.

`Reg#SP` and `Reg#BP` won't less than 0, and won't larger than Segment length,
though they are 64 bit (52 bit for addressing) pointer.

==== Literal Segment, Literal Pointer: `Reg#LS`, `Reg#LP`

`Reg#LS` referencing Literal Stack Segment, with offset $2^32$ (P.S., 4 GiB).

`Reg#LP` referencing target Literal.

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

==== Jump To Pointer, Jump To Segment, Return Value Pointer: `Reg#Jmp`, `Reg#JS`, `Reg#RVP`

`:JMP` instruction has three variant:
- `:JMP:near dest`: for short jump with offset
- `:JMP:short ptr[dest]`: for short jump using address
- `:JMP:far ptr[segment] : ptr[dest]`: for cross function jump

`:IF` and `:IFN` instructions are also instruction belongs to `:JMP` family.
But `:IF` family only has one variant that behaviour like `:JMP:short`.

`Reg#Jmp` used for addressing `dest` in `:JMP:short` and `:JMP:far`.

`Reg#JS` used for addressing function segment

`Reg#RVP` used for return value passing.
`Reg#RVP` always points to base of return value stack, a place within data stack.

=== Function Execution Stack

=== Addressing

=== Execution Stack

=== Data Stack

=== Literal Stack

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

R             |  operator |k | Flags                          |   register    |
A             |  operator |                                   |   register    |
I             |  operator |                   | Literal                       |
RR            |  operator |                   |   register    |   register    |
RI            |  operator |           |offset |   literal     |   register    |
IR            |  operator |           |offset |   literal     |   register    |
RA            |  operator |             | sl* |   register    |   register    |
AR            |  operator |       | ss* | dl* |   register    |   register    |
AA            |  operator |       | dl  | sl  |   register    |   register    |
LI            |  operator | Literal                                           |

J             |  operator |typ|                                               |

* ss for start at (where to read), and dl for dest length (how much byte to write)
```

== Instruction Set

VM CPU interruption:
- `Int`: interruption
- `Nop`: no operation

Move:
- `Mov`: move
- `XChg`: swap

Literal Load:
- `LoadIL`: load integer low 18
- `LoadIH`: load integer high 18
- `LoadIM`: load integer maximum
- `LoadUM`: load unsigned integer maximum

Arithmetic:
- `Add`: add
- `Sub`: subtract
- `Mul`: multiple
- `Div`: divide

- `Addf`: add float
- `Subf`: subtract float
- `Mulf`: multiple float
- `Divf`: divide float

Bitwise Shift:
- `Shl`: shift left
- `RShl`: shift left roll
- `Shr`: shift right
- `RShr`: shift right roll

Bitwise Boolean:
- `And`: and
- `Or`: or
- `Xor`: xor
- `Not`: not

Stack operations:
- `Push`: push
- `Pop`: pop
- `Idx`: peek
- `Dup`: duplicate

Jump:
- `Jmp`: jump to
- `If`: if cond jump to
- `Ifn`: if not cond jump to

Conditional:
- `Test`: test cond

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

=== `Nop`

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

Corresponding instruction written in format: `Nop`

Do nothing.

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

Corresponding instruction written in format: `LoadIL literal`

Load a 26-bit integer literal into register `Reg#a` (low 32-bit).

=== `LoadIH`

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

Corresponding instruction written in format: `LoadIH literal`

Load a 26-bit integer literal into register `Reg#a` (high 32-bit).

=== `LoadIM`

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

Corresponding instruction written in format: `LoadIM`

Load a signed 64-bit integer maximum into register `Reg#a`

=== `LoadUM`

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

Corresponding instruction written in format: `LoadUM`

Load a unsigned 64-bit integer maximum into register `Reg#a`

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

=== `Addf`
=== `Subf`
=== `Mulf`
=== `Divf`

=== `Shl`
=== `RShl`
=== `Shr`
=== `RShr`

=== `And`
=== `Or`
=== `Xor`
=== `Not`

=== `Push`
=== `Pop`

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

== Assembly

=== Label

=== Addressing
