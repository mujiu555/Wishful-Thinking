
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Register]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/Turing.typ")

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
The read-write ability below for each special-purposed register are suggested only.

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
  - Execution Segment `Reg#ES`, code `0x39`, for execution stack segment
- Stack locating used:
  - Stack Base Pointer `Reg#BP`, code `0x38`, for current stack frame base
  - Stack Top Pointer `Reg#SP`, code `0x37`, for current stack frame top
  - Stack Segment `Reg#SS`, code `0x36`, for stack segment
- Condition reflecting used:
  - flags: `Reg#FLAGS`, code `0x35`, for flags after instruction execution
  - tests: `Reg#TESTS`, code `0x34`, for test condition

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

Read-Write register, special-purposed register that can be visited by user.

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

`:TEST cond, jmp` instruction will set `Reg#TESTS` according to `cond`,
and check whether `:AND Reg#TESTS, Reg#FLAGS`
If `cond` is true, jump to `dst`.

There are some literal for `cond`.
- `Test#g`
- `Test#ng`
- `Test#l`
- `Test#nl`
- `Test#e`
- `Test#o`
- `Test#no`
Or any literal 16 bits value is also acceptable.

The meaning of flags bits in `Reg#FLAGS` is as following:

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
              | Exception code                                                |
* VF <- VIF; VP <- VIP
```

- CF: Carry Flag
- PF: Parity Flag
- AF: Auxiliary Carry Flag
- ZF: Zero Flag
- SF: Sign Flag
- TF: Trap Flag

Exception code are passed to exception interrupt handler when exception raised.

Write operation on them will not have any effect.
