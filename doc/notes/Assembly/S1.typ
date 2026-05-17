#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Assembly, Constitution Principle of Computer, Computer Organization and Architecture and Operating System (Section I)]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Assembly, Constitution Principle of Computer, Computer Organization and Architecture and Operating System

== Section I: Basis Assembly

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

When CPU executing programs, it follows the fetch-execute cycle.
Until it receives halt instruction, it will repeat read, decode, execute process.

Instructions are stored in memory, and CPU must read them so that it can be decode then.
CU, controls the whole process of reading and decode.

CPU first determine logical memory address according to PC, and then send the memory request to MAR.
MAR store the command and communicate with main memory.
Main memory pass requested data, or instructions to CPU by bus, and then store those data in MBR.
IR then fetch instruction from MBR, split full instruction into Operator part and address part.
Calling ALU to actually execute the instruction.

This is a full fetch-execute cycle for CPU.

=== CISC & RISC

CISC, Complex Instruction Set Computer, a collection of architecture,
try to improve computer performance by decrease instruction number of some specify operations.
In general, CISC computer may have more special purpose instruction, so that it can perform different
complex operation within one execution cycle.
Instructions used by CISC, sometimes are multiple-bytes, and may vary with its purpose.
Total CPU cycle consumed by a instruction may also vary.
But they always provides various method for memory accessing.

While RISC, Reduced Instruction Set Computer, try to reduce type of instructions.
Since most instructions in CISC may not used frequently,
and some of those instruction can be seen as combination of other simpler high-frequent instructions,
improve the performance of basic instructions may have higher performance overall,
and this can make ISA design simpler as well.
Instructions are all fixed byte and most of them consume only 1 CPU cycle strictly in RISC.
CPU pipeline can even shrink some instructions' execution less than 1 CPU cycle.
Memory addressing method are limited and most operations are finished in register.

Most register in CISC may have its own function but those in RISC are mostly general purposed.
Furthermore, overall number of registers in RISC are more than those in CISC.

CPU control method adopted by those two type of architecture are also different,
CISC often uses micro program to control whole CPU, while RISC uses logical circuit.

=== Cache

Inside CPU, it is too slow to fetch outside registers, so cache some frequent used data is a good idea.
Cache may have multiple level, each get far away from core.

L1, L2 cache may spare within one core, and L3 cache may be used commonly by whole CPU.

=== Memory

Memory, most data and instructions are stored here,
CPU use it to cache data, store results and communicate with other components.

Primary memory, often RAM, random access memory, have different kind of distribution.
Mainly there are two different RAM,
- Static RAM, SRAM, RAM that designed using flip-flop to store bits.
  "Static" means that SRAM need not extra operations to keep data.
  And have relative faster access speed among all kind of memory.
  - Sync SRAM
  - Async SRAM
  - Burst SRAM
- Dynamic RAM, DRAM, RAM that designed using capacitor.
  "Dynamic", in contrast, needs refresh regularly, for capacitor lacks electron as time.
  DRAM always have smaller size, lower electronic level, but slower speed.
  - DDR
  - LPDDR

On the other part, memory can also distinct by memory Error Check and Correct ability,
- Regular memory
- ECC memory

Recently (but not that recently), there are a new kind of memory,
Optane memory, it can even store data after power-off.

Devices other than main memory still have their own memory,
for example, hard drivers, may have their own cache (a memory) to exchange information with CPU.

==== Address

Memory is a kind of physical device,
but it is not possible to access memory through its physical information,
otherwise, every program vendor must provide different program instance for every combination of memory,
CPU, and other hardware.
Concerning size of memory, design of memory, even id of memory.

So, mapping physical memory unit into logical memory is essential.
In computer, we assume memory are continuous, no matter how many memory card you installed, and no matter
what size each memory card have.
And then, we split this continuous space into pieces with same logical size.
Assign each logical piece with an id, for referencing.
Those ID for memory space, just like id for bank safe, by accessing corresponding bank safe,
we can store or withdraw things in it.

Even, you may store a id represent another bank safe inside.
And we can than find another bank safe by the one you holds.

Other memories (or some special device can abstract as memory) will also be mapped and concatenated into the logical memory.
And then CPU can access those devices without specify its hardware information.

This id, we call it "Address".
Every address indexes a space of memory.

==== Bytes, Word, Double Word and Half-Word

In assembly, or CPU design, there are another measurement for data,

#table(
  columns: 3,
  stroke: none,
  table.hline(),
  table.header([Name], [Conversion], [From]),
  table.hline(stroke: 0.5pt),
  [`bit`], [/], [None],
  [`Byte`], [8], [`bit`],
  [`Half`], [4], [`bit`],
  [`Word`], [2], [`Byte`],
  [`Double Word`], [2], [`Word`],
  [`Quad Word`], [4], [`Word`],
  [`Paragraph`], [8], [`Word`],
  table.hline(),
)

Those units measure the data computer can manipulate DIRECTLY.

==== Direct Memory Access

Most time, CPU do calculating work, this takes relative small times.
But when CPU have to access memory or other device, it must take multiple cycles to fetch data.
Transfer data from and between memory.

Thus, it is natural to have a special designed device fetching data for CPU.
When CPU have to fetch data from peripheral, DMA will take this job and copy information from those devices into memory,
while CPU do its own calculating job.

=== ROM

Outside memory, there are another kind of data storage, ROM, Read-Only Memory.

This kind of flash, can store data without electronic refresh.
So, even power-off may not delete required data,
thus, it always used for BIOS storage.

As time goes, ROM soon developed into EPROM, EEPROM and NAND Flash.
Which can be read and rewritten using special tool, can be covered using light or other method, and Write-Rewrite using only electron.
NADA Flash is the basis of USB Memory Driver and SSD.

=== Storage

Hard drivers, together old school soft drivers, are storage for computer, which have larger space,
more reliable storage ability than memory.
Always have the responsibility for keep data.

But the speed of storage are much slower than memory.

=== BUS

How CPU access its desired data, how CPU touches its required devices indeed?

In modern computer system, CPU communicate with other devices through BUS.

Why we need BUS, rather than other communicate architecture?
- BUS can decrease complexity:
  In other system, like directly communicate, if we have N devices to communicate,
  then there must have at least $C^2_N$ circuit.
  But with BUS, N-N network topology can be then reduced to
  N-1-N topology or N-1-Adapter-1-N bus-star topology.
- BUS also standardize interfaces for devices.
  Before PCIe, there are multiple different connector for devices.

==== Address BUS

Address Bus, as its name, used for transfer memory address.
With address bus, CPU then can visit its wanted memory.

Address Bus transfer address information, and only pass from controller to terminal device.
Width of address bus determine the largest memory space a computer can visit.

With a 32-bit address bus, CPU can visit maximum 4GB data.

==== Data BUS

Data Bus transfer actual data, as CPU specify its wanted data space address by Address Bus.
The terminal device may return actual data the space stores back towards CPU using Data Bus.
Also, CPU may write its result to memory by Data Bus.

Data Bus transfer data, Data Bus can transfer data towards both side.
No matter data from CPU and write to terminal device, or come from terminal and fetched by CPU.
Width of Data Bus limits maximum size of data a CPU can fetch or write.

With a CPU with register size 64, Data Bus width 64, whole register can be stored directly.

==== Control BUS

Control Bus transfer control or status signal.
Both side can send or receive signal transferred by Control Bus.
Width of Control Bus can affect operations of CPU.

Signals send by Control Bus controls the behaviour of devices, for example, write or read signal send
to storage will instruction storage which data to read or how to store some data.
Also, signals send by terminal devices may also affect CPU, for example, I/O finish interrupt signal
may tell CPU some data finish reading.

==== Dual Independent BUS: North, South Bridge

In traditional bus system, bus connects all components of a computer.
This result in long time waste when I/O transfer.

Then it is possible to spare high-speed devices and low-speed devices into two bus.

Back Side Bus, inside CPU, connect each kernel of CPU, ALU, CU and so on.
Front Side Bus, outside CPU, connect CPU with North and South Bridge.
- North Bridge, connects CPU, North Bridge and other high speed devices.
  Main Memory and high speed caches
- South Bridge, connects to North Bridge and other low speed devices.
  - PCI: high speed I/O devices
  - ISA: low speed I/O devices

=== Stack

Since memory is represented in large continuous space logically.
Find methods for data management is a large problem.

A simple way to manage data is stack.

Stack is a linear first-in-last-out data structure.
First choose an address as base of stack, and then we can push data and pop data out of the stack.
On the other way, it is possible to index element inside a stack by offset.

==== Stack grows downwards

In computer, continuous memory have address, and then some address with larger value can be seen as high
address, and thus we can define the side of stack.

In general, we always choose higher address as the base of stack,
and then stack increment will result in stack grown towards lower address.

Why stack always choose higher address: #link("https://github.com/mujiu555/Wishful-Thinking/blob/mujiu555@feat/c/doc/root/c/typ/S1.typ").

==== Push

Push operations to stack eventually lead to stack growth.
It first add new element onto the top of stack, and then increase stack top pointer.

==== Pop

Pop operation to stack eventually lead to stack shrink.
It store the value store at top to somewhere, and then decrease stack top pointer.

=== Registers

Registers in CPU, is the most basic function unit.
They have the function to store data, and put them into calculating.

Following are registers commonly used in `8086`, `i386`, `x86`, `ia32`, `amd64`(`x86_64`).

==== AX(Accumulator), BX(Base Address), CX(Counter), DX(Data)

In x86_64, there are four general purpose registers.
They are `*AX`, `*BX`, `*CX`, `*DX`.

Those general purpose registers can be divide, and used as smaller registers.

#table(
  columns: 6,
  stroke: none,
  table.hline(),
  table.header([Name], [Representation], [x64], [x86], [x16], [8]),
  table.hline(stroke: 0.5pt),
  [`Accumulator`], [\*AX], [RAX], [EAX], [AX], [AH, AL],
  [`Base Address`], [\*BX], [RBX], [EBX], [BX], [BH, BL],
  [`Counter`], [\*CX], [RCX], [ECX], [CX], [CH, CL],
  [`Data`], [\*DX], [RDX], [EDX], [DX], [DH, DL],
  table.hline(),
)

- \*AX register always join calculation, and can store results in `mut`, `div` operation,
  or function call returning value.
- \*BX register always join rebase operation, used as memory access offset.
- \*CX register always treat as counter, and will automatically decrease in loop.
- \*DX register always transfer arguments, do I/O operation.

==== CS:IP(Code Segment: Instruction Pointer)

==== SS:BP, SS:SP (Stack Segment: Base Pointer, Stack Segment: Stack Pointer)

==== SI, DI (Source Index, Destination Index)

==== DS (Data Segment)

==== ES (Extra Segment)

==== FLAGs

==== R8, R9, R10, ..., R15

=== Heap

== Syntax

=== Operator, Operand

=== Comment

=== Memory Access

=== Labels

=== Macro
