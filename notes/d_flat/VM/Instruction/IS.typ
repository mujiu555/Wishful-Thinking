
=== Instruction Set

The instruction set includes following instructions:
- Interrupt and Exception Handling
  - `Int`: interrupt invoke instruction
    - I, `:int idx`: invoke interrupt with index `idx`
    - R, `:int reg`: invoke interrupt with address stored in register `reg`
- Snapshot Exception Handling
  - `Snap`: snapshot exception invoke instruction
    - `:snap`: invoke snapshot exception
  - `Raise`: raise exception instruction
    - I, `:raise code`: raise exception with code `code`
- Data Management
  - `Mov`: move data instruction
    - RR, `:mov s dst, shl d(src)`: move data from `src` to `dst`, shift left by `shl` bits, padding with 0 or 1 by `+` or `-`.
    - RI, RI, `:mov offset dst, val`: move immediate value `val` to `dst`, offset can be `low16`, `high16`, `low16h`, `high16h` for low 16 or high 16 bits in totally low 32 bits of `dst` or low 16 or high 16 bits in totally high 32 bits of `dst`.
      E.g., `:mov l Reg#1, 0xffff` assigns low 16 bits of `Reg#1` to `0xffff`, `:mov l Reg#1, 0x8fff` assigns low 16 bits of `Reg#1` to `0x8fff`, with other version of `:mov`
    - RR, `:mov offset dst, ptr[src]`: deference memory address `src` and move data to `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size,
      offset can be `0`, `1`, `2`, `4` for target data offset
      E.g., `mov ah, ptr[rbx]` in x86_64 assembly can be represented as `:mov 1 ah, bytes ptr[Reg#1]`, meanwhile `mov eax, ptr[rbx]` can be represented as `:mov 0 eax, dword ptr[Reg#1]`
    - RR, `:mov ptr[dst], offset src`: move data from `src` to memory address `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size,
      offset can be `0`, `1`, `2`, `4` for source data offset
      E.g., `mov ptr[rbx], ah` in x86_64 assembly can be represented as `:mov 1[Reg#1], 1 ah`, meanwhile `mov ptr[rbx], eax` can be represented as `:mov 4[Reg#1], 0 eax`
    - RR, `:mov ptr [dst], [src]`: move data from memory address `src` to memory address `dst`, `ptr` can be `qword`(`0`), `bytes`(`1`), `word`(`2`), `dword`(`4`) for data size
    - RRI, `:mov dst, ptr[base + offset]`: move data from memory address calculated by `base` register plus immediate `offset` to `dst`
    - RIR, `:mov ptr[base + offset], src`: move data from `src` to memory address calculated by `base` register plus immediate `offset`
  - `LSD`: load / save data instruction
    - I, `:lsd op idx`: load or save data between global data stack and register `Reg#A` with index `idx`
    `op` can be one of following:
    - `load`: load data from global data stack to `Reg#A`
    - `save`: save data from `Reg#A` to global data stack
    - `loadr`: load data from global data stack to `Reg#R`
    - `saver`: save data from `Reg#R` to global data stack
    - `loadc`: load pre-defined data to `Reg#A`
- Arithmetic Computation
  - `OpI`: arithmetic integer computation
    - RR, `:opi op dst, src`: perform arithmetic operation `op` on integer `dst` and `src`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - RI, `:opi op dst, val`: perform arithmetic operation `op` on integer `dst` and immediate value `val`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - IR, `:opi op val, src`: perform arithmetic operation `op` on integer `src` and immediate value `val`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - RR, `:opi op dst, ptr[src]`: perform arithmetic operation `op` on integer `dst` and memory address `src`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - RR, `:opi op ptr[dst], src`: perform arithmetic operation `op` on integer memory address `dst` and integer `src`, store result into `Reg#A`, carry or reminder into `Reg#R`
    - RR, `:opi op prt[dst], [src]`: perform arithmetic operation `op` on integer memory address `dst` and integer memory address `src`, store result into `Reg#A`, carry or reminder into `Reg#R`
    `op` can be one of following:
    - `add`: addition
    - `sub`: subtraction
    - `mul`: multiplication
    - `div`: division
  - `OpF`: arithmetic floating-point computation
    - RR, `:opf op dst, src`: perform arithmetic operation `op` on floating-point `dst` and `src`, store result into `Reg#A`
    - RR, `:opf op dst, ptr[src]`: perform arithmetic operation `op` on floating-point `dst` and memory address `src`, store result into `Reg#A`
    - RR, `:opf op ptr[dst], src`: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point `src`, store result into `Reg#A`
    - RR, `:opf op ptr[dst], [src]`: perform arithmetic operation `op` on floating-point memory address `dst` and floating-point memory address `src`, store result into `Reg#A`
    - RR, `:opf fmod dst, src`: perform floating-point modulus operation on `dst` and `src`, store result into `Reg#A`
    - RR, `:opf fmod ptr [dst], [src]`: perform floating-point modulus operation on memory address `dst` and memory address `src`, store result into `Reg#A`
    `op` can be one of following:
    - `fadd`: floating-point addition
    - `fsub`: floating-point subtraction
    - `fmul`: floating-point multiplication
    - `fdiv`: floating-point division
  - `OpB`: arithmetic bitwise computation
    - RR, `:opb op dst, src`: perform arithmetic operation `op` on bitwise `dst` and `src`, store result into `Reg#A`
    - RI, `:opb op dst, val`: perform arithmetic operation `op` on bitwise `dst` and immediate value `val`, store result into `Reg#A`
    - RR, `:opb op dst, ptr[src]`: perform arithmetic operation `op` on bitwise `dst` and memory address `src`, store result into `Reg#A`
    - RR, `:opb op ptr[dst], src`: perform arithmetic operation `op` on bitwise memory address `dst` and bitwise `src`, store result into `Reg#A`
    - RR, `:opb op ptr[dst], [src]`: perform arithmetic operation `op` on bitwise memory address `dst` and bitwise memory address `src`, store result into `Reg#A`
    - RI, `:opb op ptr[dst], val`: perform arithmetic operation `op` on bitwise memory address `dst` and immediate value `val`, store result into `Reg#A`
    `op` can be one of following:
    - `and`: bitwise AND
    - `or`: bitwise OR
    - `xor`: bitwise XOR
    - `not`: bitwise NOT
  - `OpS`: arithmetic shift computation
    - RR, `:ops op dst, src`: perform shift operation `op` on `dst` by `src` bits, store result into `Reg#A`
    - RR, `:ops op dst, ptr[src]`: perform shift operation `op` on `dst` by memory address `src` bits, store result into `Reg#A`
    - RR, `:ops op ptr[dst], src`: perform shift operation `op` on memory address `dst` by `src` bits, store result into `Reg#A`
    - RR, `:ops op ptr[dst], [src]`: perform shift operation `op` on memory address `dst` by memory address `src` bits, store result into `Reg#A`
    `op` can be one of following:
    - `shl`: shift left
    - `shr`: shift right
    - `sal`: shift arithmetic left
    - `sar`: shift arithmetic right
    - `rol`: rotate left
    - `ror`: rotate right
    - `rcl`: rotate through carry left
    - `rcr`: rotate through carry right
- Condition Test and Branch
  - `Test`: condition test instruction
    - II, `:text cond, jmp`: test condition `cond`, if true, jump to near address with offset `jmp`
- Control Flow Jump
  - `Jmp`: control flow jump instruction
    - I, `:jmp:near offset`: jump to near address `dst` with offset
    - R, `:jmp:short dst`: jump to short address stored in register `dst`
    - RI, `:jmp:far segment : offset`: jump to far address `offset` in function unit `segment`
- Loop Control
  - `Loop`: loop control instruction
    - I, `:loop offset`: decrement `Reg#C` by one, if not zero, jump to near address with offset
- Function Call and Return
  - `Call`: function call instruction
    - I, `:call idx`: call function with index `idx` in function unit vector
    - R, `:call dst`: call function with address stored in register `dst`
  - `Ret`: function return instruction
    - `:ret`: return from current function
  - `IRet`: interrupt return instruction
    - `:iret`: return from interrupt
  - `RegF`: register new function instruction
    - RR, `:regf skip, len`: register new function unit with code length `len` in bytes, skip first `skip` bytes in global data stack
- Stack Management
  - `Stack`: stack management instruction
    - I, `:stack alloc size`: allocate stack space with size `size` bytes
    - I, `:stack free size`: free stack space with size `size` bytes
    - Zero, `:stack clear`: clear current function stack frame
    - Zero, `:stack dump`: dump current stack frame information for debugging
    - Zero, `:stack create`: create a new function stack frame
    - Zero, `:stack destroy`: destroy current function stack frame and return to previous function stack frame
    - I, `:stack duplicate idx`: duplicate current stack segment, and update `Reg#SS` to point to new stack segment, store previous stack segment pointer into global data stack at index `idx`
    - I, `:stack restore idx`: restore previous stack segment from global data stack at index `idx`, and update `Reg#SS` to point to restored stack segment
  - `Push`: push data onto stack instruction
    - R, `:push src`: push data from register `src` onto stack
    - I, `:push val`: push immediate value `val` onto stack
    - R, `:push ptr[src]`: push data from memory address `src` onto stack
  - `Pop`: pop data from stack instruction
    - R, `:pop dst`: pop data from stack into register `dst`
    - R, `:pop ptr[dst]`: pop data from stack into memory address `dst`
