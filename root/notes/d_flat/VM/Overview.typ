
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Architecture Overview]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VM&Assembler.typ")

The virtual machine works in a register-memory architecture.

```txt
File:                                                 Memory:
+--------------------------------------+      +-------------------------------+
| Archive                              |      |  +--------------------+++     |
| +----------+    +---------------+++  |      |  |                    |||     |
| | Global   | +->| Function Unit |||| |      |  | Global Data Stack  |||     |
| | +--+++   | |  | +--+++  +-++  |||| |      |  |                    |||     |
| | | D |||  | |  | | T ||| |D||| |||| |      |  +--------------------+++     |
| | | a |||  | |  | | e ||| |a||| |||| |      |  +-----------------------+    |
| | | t |||  | |  | | x ||| |t||| |||| |      |  |                       |    |
| | | a |||  | |  | | t ||| |a||| ||||==========>| Function Unit Vector  |<-+ |
| | +--+++   | |  | +--+++  +-++  |||| |      |  | +-------------------++|  | |
| | +--+++   | |  | +--+++  +-++  |||| |      |  | | +---------------+ |||  | |
| | | E |||  | |  | | C ||| |C||| |||| |      |  | | | Data Vector   | |||  | |
| | | n |||  | |  | | o ||| |l||| |||| |      |  | | | +---------+++ | |||  | |
| | | t -------+  | | s ||| |o||| |||| |      |  | | | | Literal ||| | |||  | |
| | | e |||  |    | | t ||| |s||| |||| | Load |  | | | +---------+++ | |||  | |
| | | r |||  |    | | a ||| |u||| |||| | ===> |  | | | | capture ||| | |||  | |
| | | y |||  |    | | n ||| |r||| |||| |      |  | | | +---------+++ | |||  | |
| | +--+++   |    | | t ||| |e||| |||| |      |  | | | | data    ||| | |||  | |
| |          |    | +--+++  +-++  |||| |      |  | | | +---------+++ | |||  | |
| |          |    |               |||| |      |  | | +---------------+ |||  | |
| +----------+    +---------------+++  |      |  | | | Text          | |||  | |
|                                      |      |  | | +---------------+ |||  | |
+--------------------------------------+      |  | +------------------+++|  | |
                                              |  +-----------------------+  | |
                                              |  +----------------------+++ | |
                                              |  | Execution Stack      ||| | |
                                              |  | +---------+++        ||| | |
                                              |  | | Pointer ---------------+ |
                                              |  | +---------+++        |||   |
                                              |  +----------------------+++   |
                                              |  +--------------------+++     |
                                              |  | Register Records   |||     |
                                              |  +--------------------+++     |
                                              +-------------------------------+
```

In data status stored in file,
the file includes following section:
- Global Data section: storing global variable data
- Global entry section: storing all entry points of data and function
- Function Unit section: storing all function units
  Function Unit includes:
  - Text section: storing instructions to be executed
  - Data section: storing constants, variables used only in this function
  - Constant section: storing immediate value used in this function
  - Closure section: storing relocation information for captured variables

In memory, there are three segments:
- Global Data Stack: every function will share the same global data stack, used for variable storage, argument passing, etc.
  Global Data Stack works like normal stack in x86_64 assembly.
  Global Data Stack stores global variable data at initial, and then construct function frames when function called.
  A Global Data Stack can be at most 4 GiB size.
  The register `Reg#SS` points to the current used data stack segment base.
  The global data stack may be duplicated and stored in new data stack segment, when continuous, fork, extremely large stack allocation invoked.
  And the `Reg#SS` will be updated to point to new data stack segment base.
  It is also possible to use the data stack duplicate for snapshot purpose.
- Function Unit Vector: every function has its own function unit, including text segment and data segment
  Function Unit Vector stores all function units in the program.
  Function Unit Vector maps function index to function unit, a pointer points to corresponding function unit in function unit.
  Function Unit includes:
  - Text Segment: every function have its own text segment, storing instructions to be executed.
    Same instance of a function shares same text segment.
  - Data Segment: every function have its own data segment, storing literal data and captured data, which are pointers to global data stack.
    - Literal Data: literal are constant may used in function or for instruction parameter.
    - Capture Data: capture data are pointers to global data stack, used for closure variable access,
      When a function is a closure, a new instance of function unit will be created, with capture data initialized.
- Execution Stack: every function call will push a pointer points to corresponding function unit in function unit vector into execution stack.
  Execution stack stores function call frame pointer.
  The Execution Stack can be duplicated and stored in new execution stack segment, when continuous, fork invoked.
  And the `Reg#ES` will be updated to point to new execution stack segment.
- Register Records: The register records store all register values, and will change the value as instructions executed.
  Register records will be saved and restored with snapshot exception handling invoked.

