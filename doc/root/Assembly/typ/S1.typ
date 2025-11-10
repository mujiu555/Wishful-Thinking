= Assembly, Constitution Principle of Computer and Computer Organization and Architecture,

Author: #link("https://github.com/mujiu555")[GitHub\@mujiu555].

== Section I: Basis

== Coding, Numeration, Radix

Values, plain bits, expressed in high or low electronic levels, may represent some information.
With corresponding context or encoding, together with its own properties, like name, can be then
interpreted as real information, the data.
Raw information, data, must have some way to be stored.
And the way to translate original data into values can be stored in computer, it then called,
"coding".
Encoding converting data into a specific format or representation.

Coding help people understand data.

=== Symbol, Calculation & Presentation

Calculation are some relation between different data.
Directly, manipulate different value in different coding.

=== Decimal

Decimal integers are numbers based on ten,
which means every number represented in decimal form may contains only
0-9.
Every digit's value based on position dependent power of 10.

=== Binary

Binary integers are numbers based on two,
every time a digit has value of 2, will result in carry.
Digits in binary representation called "bits".
Thus only 0, 1 will appear in binary representation.

Every bit's value based on position dependent power of 2.

=== Hexadecimal, Octal

Hexadecimal numbers based on 16 while Octal numbers based on 8.

=== Radix conversion

Referencing
#link("https://github.com/mujiu555/Wishful-Thinking/blob/main/doc/root/c/typ/S1.typ")[redix].

=== Data, Numbers, Computer

Data is presented in binary number in computer.

For each cell of calculation unit can only have two state, open and close.
Which has natural one-to-one correspondence with binary bits.

== CPU, BUS, Memory

Most important part of a computer is CPU.
CPU, central processing unit, controls almost all calculation process of computer.

And, further more, ALU, arithmetic logic unit, is kernel of CPU.
The ALU is responsible for arithmetic and logical computations.
Without an ALU, the CPU would be unable to perform its core operations.

Registers are another kernel of CPU, which provides ability for CPU to store data.

CU, front-end of a CPU, controls the behaviour of whole CPU.
CU may fetch commands, do preprocessing and instruct command execution order.
Preprocessing for commands can be `PreDecode`, `Decode`, `Micro-Fusion`/`Macro-Fusion`, `Branch Prediction` and `Static Prediction`.

To boost execution for float point number calculation, some CPU may also have FPU,
floating point unit.

Memory access is another function a CPU must have, so, AGU, address generation unit,
or ACU, address calculation unit,
will help CPU calculating address offset of main memory.

MMU, memory management unit, a control unit maybe outside CPU, controls memory, maps
logical memory from to physical address.

TLB, translation lookaside buffer, a critical cache for memory management,
every time CPU try to map and fetch data from memory, it may visit TLB,
so that memory address translation may speed up by checking existing mapping entry.

Cache, a general purpose buffer for data fetch from memory,
once data caches, it can be access much faster than other data still exist only in
main memory later.
When data accessed, changed and used, it may also be written back to memory when every thing finished.

=== Data, Instructions

Data, the raw information, may has some specified meaning after interpreting by associating it together with context and name.
Instruction, represented in same way as regular data, in binary number.

Data is what a computer processes, and instructions specify how to do so.

==== Dimension, Unit

To measure how much data there are, it is needed to specify units.

#table(
  columns: 3,
  stroke: none,
  table.hline(),
  table.header([Unit], [Conversion], [From]),
  table.hline(stroke: 0.5pt),
  [`bit`], [/], [None],
  [`Byte`], [8], [`bit`],
  [`KiB`], [1024], [`Byte`],
  [`MiB`], [1024], [`KiB`],
  [`GiB`], [1024], [`MiB`],
  [`TiB`], [1024], [`GiB`],
  [`EiB`], [1024], [`TiB`],
  [`kB`], [1000], [`Byte`],
  [`mB`], [1000], [`kB`],
  [`gB`], [1000], [`mB`],
  table.hline(),
)

Most common used unit in computer is Byte, it is also the smallest data unit a computer can handle (for most computer).

As for information theory, smallest unit is bit, which is also the smallest unit to weigh memory.
For most memory (SRAM, DRAM), the smallest storage unit is also bit.
In most architecture, memory is visited in bytes, but there still some special processor can address using bit.
Some even special ones may address by word, or double word.

Processors may treat data different as well.
As for processing granularity, a byte is typically the smallest independently loadable/storable object,
whereas the minimum operand width for arithmetic/logic operations depends on the ISA (commonly 8/16/32/64 bits).

=== Harvard, von Neumann Architecture

As we mentioned before, data and instructions both stored in binary form.
So, CPU cannot actually tell whether some memory storing data or instructions.

Thus there are two method to store them.

One is "von Neumann Architecture", data and instructions share same memory space.
In this way, it depends on context to distinct which one is data and which one is instruction.

Another way called "Harvard Architecture", for which data and instructions are stored in two different memory.

von Neumann architecture provides programmers with flexibility to treat data as instructions,
so that some self-modifying code can be possible.
For example, some JIT compiler are implemented in such way.

Harvard architecture, however, prevent data from being treated as instruction.
Though it reduces flexibility, ambiguity are prevented.

=== Program Counter, Instruction Register

How a program executes?
CPU reads instruction, and them executes them.
Both Harvard and von Neumann architecture will follow this process.

But how CPU read instructions then?
Let's concerning von Neumann architecture first:
Data and instructions are mixed up in memory for a von Neumann processor.
Thus, there must have something can record which one is instruction, so that processor may not read wrong memory.
Each time processor want to execute next instruction, it will refer to the thing.
And after processor executed one instruction, it may move to next instruction, so that processor can execute whole
program in specified sequence, rather than just execute one instruction repeatedly.
What will happened when we switch to Harvard architecture processor?
Still, though where instructions are placed is fixed for computer during a program's execution.
The processor must know, how many instructions it has executed and where next instruction is.

Thus, in practice, there must exist a abstract register called "Program Counter Register" tracks instruction execution.

But, where shall CPU read instructions to?
To parse and knowing detailed execution information,
CPU first read instructions according to PC, and then put what it reads to IR, "Instruction Register".

Those instructions then parsed and analyzed,
and take effects.

PC and IR are both abstracted concept of physical registers.
They may not exists in real CPU, but there must exist a, or group of, register(s) do the function they describes.

=== Memory Address Register, Memory Buffer Register, Memory Data Register & Memory

When CPU try to visit memory, it also needs something to record where it meant to read.
Just like PC records which instruction should execute next.
MAR, "Memory Address Register" records which memory should be read next.
And just like IR records instruction read, MBR caches data read from memory.

In some case, MBR can also be called as "Memory, Data Register", MDR.

Furthermore, most important, MAR, MBR still not the real register.

=== Fetch-Execute Cycle

=== CISC & RISC

=== Memory

==== Address

==== Bytes, Word, Double Word and Half-Word

=== Direct Memory Access

=== BUS

==== Address BUS

==== Data BUS

==== Command BUS

=== Stack

==== Push

==== Pop

=== Registers

==== AX(Accumulator), BX(Base Address), CX(Counter), DX(Data)

==== CS:IP(Code Segment: Instruction Pointer)

==== SS:BP, SS:SP (Stack Segment: Base Pointer, Stack Segment: Stack Pointer)

==== SI, DI (Source Index, Destination Index)

==== DS (Data Segment)

==== ES (Extra Segment)

==== FLAGs

==== R8, R9, R10, ..., R15

=== North, South Bridge
