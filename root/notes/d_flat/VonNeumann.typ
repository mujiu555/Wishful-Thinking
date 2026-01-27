#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Turing Machine Simulator (R-M Von-Neumann Simulator) for Project D-Flat]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Turing Machine Virtual Machine Design

The virtual machine works just similar to real CPU-memory.

The virtual machine has following properties:
- 32-bit instruction width
- 64-bit register size
- 32 general-purposed registers
- 32 special-purposed registers
The virtual machine adopt a new designed instruction set.

= #embed("VonNeumann/Overview.typ")

= #embed("VonNeumann/Register.typ")

= #embed("VonNeumann/Pointer.typ")

= Interrupt and Exception Handling

Interrupt handled by interrupt dispatch table.
The first 128 entries of function unit vector is reserved for interrupt handling.
When interrupt invoked, virtual machine will do following steps:
+ Store current execution status by pushing all registers into global data stack
+ Invoke interrupt handler function unit from interrupt dispatch table
+ After interrupt handler function unit return, restore previous execution status by popping all registers from global data stack

Exception handled by invoke exception handler function unit.
The default exception handler function unit is at index `0` in function unit vector. It is a special interrupt handler.

The interrupt handler must be provided by program,
if no interrupt handler provided, virtual machine will write interrupt dispatch table entry to point to default exception handler.
Which is a function unit that display exception trace information and halt the virtual machine.

Exception handle process do like described in instruction `raise`.

= Model

The execution model of virtual machine have following steps:
+ Load function unit into function unit vector
+ Initialize global data stack
+ Initialize execution stack
+ Initialize register records
+ Start execution from main function

When function call invoked, virtual machine will do following steps:
+ Push current function frame pointer into execution stack
+ Create new function frame in global data stack
+ push local variables into global data stack
+ start execution from called function

When function return invoked, virtual machine will do following steps:
+ Move return value into `Reg#A` and `Reg#R`, if the return value larger than 2 register can represent,
  move the returning value into pre-allocated space in global data stack, and move the pointer into `Reg#A`.
+ Pop current function frame from execution stack.
+ Clean up current function frame in global data stack.
+ Resume execution from previous function frame.

When snapshot exception invoked, virtual machine will do following steps:
+ Duplicate current global data stack segment, execution stack segment, and register records.

= #embed("VonNeumann/Call.typ")

= #embed("VonNeumann/Instruction.typ")

