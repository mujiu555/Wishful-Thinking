
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Call Convention]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/notes/d_flat/VM&Assembler.typ")

When a function about to be called, the caller must do following steps:
+ Reverse return value space allocation in global data stack
+ Push function arguments into global data stack, left most argument pushed last
+ Move the return value address into `Reg#A`
+ Invoke call instruction with function

When a function called, the callee must do following steps:
+ Create new function frame in global data stack, store previous stack base pointer and stack top pointer
+ Store return value address from `Reg#A` into function frame
+ Push local variables into global data stack

When a function about to return, the callee must do following steps:
+ Move return value accordingly, if the signature of function return value by register, move return value into `Reg#A` and `Reg#R`
  Else move return value into pre-allocated space in global data stack
+ Restore previous stack base pointer and stack top pointer from function frame
+ Invoke ret instruction

When a function returned, the caller must do following steps:
+ Clean up function arguments from global data stack
+ Resume execution from previous function frame
