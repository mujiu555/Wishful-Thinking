
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Architecture Overview]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VonNeumann.typ")

The virtual machine works in a register-memory architecture.

```txt
File:                                                 Memory:
+--------------------------------------+      +-------------------------------+
| Archive                              |      |  +--------------------++++    |
| +----------+    +---------------+++  |      |  | Global Data Stack  ||||    |
| | Global   | +->| Function Unit |||| |      |  |--------------------++++    |
| | +--+++   | |  | +--+++  +-++  |||| |      |  | Text Vector           |    |
| | | D |||  | |  | | T ||| |D||| |||| |      |  +-----------------------+    |
| | | a |||  | |  | | e ||| |a||| ||||==========>| Function Unit Vector  |<-+ |
| | | t |||  | |  | | x ||| |t||| |||| |      |  | +-------------------++|  | |
| | | a |||  | |  | | t ||| |a||| |||| |      |  | | +---------------+ |||  | |
| | +--+++   | |  | +--+++  +-++  |||| |      |  | | | Data Vector   | |||  | |
| | +--+++   | |  | +--+++  +-++  |||| |      |  | | | +---------+++ | |||  | |
| | | E |||  | |  | | C ||| |C||| |||| |      |  | | | | Literal ||| | |||  | |
| | | n |||  | |  | | o ||| |l||| |||| |      |  | | | +---------+++ | |||  | |
| | | t -------+  | | s ||| |o||| |||| |      |  | | | | capture ||| | |||  | |
| | | e |||  |    | | t ||| |s||| |||| | Load |  | | | +---------+++ | |||  | |
| | | r |||  |    | | a ||| |u||| |||| | ===> |  | | | | data    ||| | |||  | |
| | | y |||  |    | | n ||| |r||| |||| |      |  | | | +---------+++ | |||  | |
| | +--+++   |    | | t ||| |e||| |||| |      |  | | +---------------+ |||  | |
| |          |    | +--+++  +-++  |||| |      |  | | | Text          | |||  | |
| |          |    |               |||| |      |  | | +---------------+ |||  | |
| +----------+    +---------------+++  |      |  | +------------------+++|  | |
|                                      |      |  +---------------------+++  | |
+--------------------------------------+      |  | Execution Stack     |||  | |
                                              |  | +---------+++       |||  | |
                                              |  | | Pointer ---------------+ |
                                              |  | +---------+++       |||    |
                                              |  +---------------------+++    |
                                              |  | Register Records    |||    |
                                              |  +---------------------+++    |
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
- Text Vector: Every function's text segment is loaded into text vector.
  Text Vector stores all text segments in the program.
- Function Unit Vector: every function has its own function unit, including text segment and data segment
  Function Unit Vector stores all function units in the program.
  Function Unit Vector maps function index to function unit, a pointer points to corresponding function unit in function unit.
  If a Function unit is not be referenced by any pointer, the slot for the function unit is freed and can be reused.
  Function Unit includes:
  - Text Segment: A pointer points to text segment in text vector.
  - Data Segment: every function have its own data segment, storing literal data and captured data, which are pointers to global data stack.
    - Literal Section: literal are constant may used in function or for instruction parameter, not able to be embedded in instruction directly.
    - Capture Section: Captured data are pointers, points to global data stack or heap data.
      Every pointer must be pushed into capture section and deleted when the function does not hold it.
      If the parameter is a captured pointer, the pointer must be pushed into capture section.
      No pointer is allowed to be stored in global data stack except argument passing area.
    - Data Section: other data used in function.
  Literal Section is loaded from file into data segment directly.
  Capture Section is constructed when function unit constructed.
  Data section is loaded from file into data segment directly.
- Execution Stack: every function call will push a pointer points to corresponding function unit in function unit vector into execution stack.
  Execution stack stores function call frame pointer.
  The Execution Stack can be duplicated and stored in new execution stack segment, when continuous, fork invoked.
  And the `Reg#ES` will be updated to point to new execution stack segment.
- Register Records: The register records store all register values, and will change the value as instructions executed.
  Register records will be saved and restored with snapshot exception handling invoked.

