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

=== Snapshot

== Datum

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

First 6 bit used to represent operation.
Following 4-bits to represent parameter type
Only if the parameter is register then code will appeared in literal instruction.

```txt
00           06       0B       10                             18                             20
|  operator  |  type  |reserved|                              |                              |
```

== Instruction Set

== Assembly

=== Label

=== Addressing
