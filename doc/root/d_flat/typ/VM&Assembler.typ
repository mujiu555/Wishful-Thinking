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
I             |  operator | Literal                                           |
RR            |  operator |                   |   register    |   register    |
RI            |  operator |           |offset |   literal     |   register    |
RA            |  operator |             | sl* |   register    |   register    |
AR            |  operator |       | ss* | dl* |   register    |   register    |
AA            |  operator |       | dl  | sl  |   register    |   register    |
LI            |  operator | Literal                           |   register    |

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

Continuous:
- `SnapShot`

Misc:
- `Halt`: halt

=== `Int`
=== `Nop`

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
Totally 8 types.

For two register case:
```txt
              00          06    09 a          10                              20
RR            |  operator | typ |i| SHL       |   register    |   register    |
```
Apart from 9 bits prefix, there are 7 bits flag and 16 bits registers information.

Flag modify the behaviour of `mov`:
- 1 bit `s` for sign.
- 6 bits `SHL` for left shift counts.

If `SHL` has value of nonzero, register `dst` will be assigned with value `src << SHL`.
Padding with 0 on the right.
Likely ```c dst = src << SHL;``` in C.

If `s` has value of nonzero, register `dst` will be assigned with value `src << SHL`.
Padding with 1 on the right.

For case associated immediate:
```txt
              00          06    09            10                              20
RI positive l |  operator | typ | literal                     |   register    |
RI negative l |  operator | typ | literal                     |   register    |
RI positive h |  operator | typ | literal                     |   register    |
RI negative h |  operator | typ | literal                     |   register    |
```
Apart from 9 bits prefix, there are 15 bits literal and 8 bits registers information.

If instruction has type low, literal will be written in low 16 bits with 16th bit controlled by type of instruction.
If instruction has type h, literal will be written in 16-32 bits with 32 bit controlled by type of instruction.

```txt
              00          06    09 a    0d    10                              20
RA            |  operator | typ |k|     | sl  |   register    |   register    |
AR            |  operator | typ |k| ss  | dl  |   register    |   register    |
AA            |  operator | typ |k| dl  | sl  |   register    |   register    |
```










=== `LoadIL`
=== `LoadIH`
=== `LoadIM`
=== `LoadUM`

=== `Add`
=== `Sub`
=== `Mul`
=== `Div`
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

== Assembly

=== Label

=== Addressing
