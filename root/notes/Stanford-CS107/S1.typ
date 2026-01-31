/// TAG: c, programming paradigm, computer architecture
#import "@preview/zh-kit:0.1.0": *
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Stanford CS107: Programming Paradigm]
#date[2025-12-17 15:56]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

#show: doc => setup-base-fonts(doc)

= Data Types and Conversion

== Binary Numbers

对于正数, 直接相加即可得到结果(在范围内)

对于含负数数, 需要通过一种方式表示它的正负性

+ 原码: 选取数值的最高位, 0为正1为负.

  直接用最高位为1的数表示, 与正数相加时可能会取得不正确的结果.
  对于一个负数, 不能采用通常二进制加法, 简单将最高位置1.

  ```txt
     00000000 000000111   (+7)
   + 10000000 000000111   (-7)
  ----------------------
     10000000 000001110   (-14)
  ```

  需要保证运算过后, 可以使得负数与对应正数相加值为0(最高位1溢出).

+ 反码 1's complement: 将数值原样取反.

  正数与绝对值相同的负数相加, 和为全1, 会造成＋0和－0问题

  ```txt
     00000000 000000111   (+7)
   + 11111111 111111000   (-7)
  ----------------------
     11111111 111111111   (0xffff)
  ```

+ 补码 2's complement: 将2中结果＋1, 则为所需结果, 对于实用, 将值加到负数中

  ```txt
     00000000 000000111   (+7)
   + 11111111 111111001   (-7)
  ----------------------
  (0)00000000 000000000   (0x0000)
  ```

  补码的数学含义: 模数加法构成阿贝尔群: 正整数的加法逆元

== Characters

字符本身即为数字

== Convert

小数值的赋值近似直接将对应值赋值到大数值的低位

大数值赋值到小数值空间, 直接抛弃高位

负数赋值会用符号位填充高位(逻辑赋值), 或填0

== Floats

+ 定点二进制小数: 采用几个位数表示 $$ 2^{-n} $$

  可以表示的整数和小数的位数一定,

  浮点数, 用以有限位数和精度逼近稠密数域上的精确小数

+ float 32: IEEE 754 2-based float number

  ```txt
  [sign] [<<--- mangnitude -->>] [<-fractions>]
  [1/0 ] [exp(unsigned integer)] [base(2^{-n})]
  ```

  实际上来说, $"val"(10) = (-1)^"sign" times 1."base"^(exp-2^("bits"(exp)-1)+1)$

== Endian

最高位所在的字节称为大端，最低位所在的字节称为小端.

小端序: 高位在低字节
大端序: 高位在高字节

大端符合人类阅读习惯

指针指向会被字节序影响

= Structure (`struct`)

指针指向结构的起始地址, 其他元素通过相对于起始地址
(基地址,类似汇编的基地址和偏移地址的关系,
汇编的偏移地址以0x10为基,
此处偏移地址以0x1为基且偏移地址的值相等于之前变量的长度的总和)
的偏移访问.

== Array

指针指向数组的起始地址, 其他元素通过相对于起始地址的偏移访问.
总体类似于结构, 但是偏移地址的长度等于n倍的元素变量长度

== Generic

c风格的泛型,

```c
void swap(void* ap, void* bp, size_t size) {
  byte_t tmp[size];
  memcpy(tmp, a, size);
  memcpy(a, b, size);
  memcpy(b, tmp, size);
}
```

相对于模板, c风格的泛型不需要为相同内核的算法生成不同的二进制.
可以规避二进制膨胀问题

`lsearch` 参考 [ulibs.c: binsearch_linear](https://github.com/mujiu555/ublis.c)

Example for generic:

``` c
void * lsearch (
  void* key,
  void * base,
  int n,
  int elem_size,
  int (* cmpfn)(void *, void *)
) {
  for (int i = 0; i < n; i ++) {
    void * elemAddr = (u8_t*) base + i * elem_size;
    if (cmpfn (key, elemAddr) == 0) {
      return elemAddr;
    }
  }
  return NULL;
}
```

= Stack

== Stack with int

== Generic Stack

= Memory Management

若需要在析构泛型栈的同时析构内部元素, 则需要提供释放函数, 以便于析构.

需要确定指针与地址.


= Memory Segments

Soft managed memory:

When a program are loaded to memory,
the heap part is managed by `malloc`, `relloc`, `free`.

The memory space allocated for you will contains more bytes just before the head.
The meta data information.

Thus, `free(head+offset);` is not allowed.
For `malloc` needs meta data, index with offset will lead to crash.

Furthermore, free a array is not allowed, as well.
For array are space allocated in stack and managed by compiler.
Which also contains no meta data.

Memory manager may spilt memory into segments,
and just allocate memory space for you
within some specify segment if request less than 2^n bytes.

== Memory compose

Split a large space of memory to handle memory allocation using handler.
Handler are some pointer points to the pointer points to actual memory.

== Stack segment

Stack depth roughly relative with function call count.

When define a variable or array within a function, like main,
it will create stack frame, increase stack top.
(Stack increase towards low address).
(Similarly, heap increase towards higher address).

Stack top pointer is embedded within stack and split the stack and gap.
(Gap is the space between heap and stack)

When a function has been called, a stack frame will create for it,
when a function exited, stack top pointer will go back to where before frame.

```text
Relatively slow RAM (Compared to register):

High address        +-----------------------+       +-------------+
                    |                       |      /|    ARG-N    |
                    |                       |     / |    .....    |
                    |                       |    /  |    ARG-1    |
                    |                       |   /   |-------------|
                    |-----------------------|  /    |  <Ret Addr> | <- BP
                    |                       | /    .|-------------|
                    |         Stack         |/    / |   <Old SP>  |
                    |                       |    /  |-------------|
              BP -> |-----------------------| --`   |   Local-1   |
                    |         Frame         |       |   .......   |
              SP -> |-----------------------| ----. |   Local-N   |
                    |                       |\     `|-------------|
                    |                       | \     |    ARGs-N   | <- SP
                    |                       |  \    |             |
                    |                       |   \   |             |
                    |                       |    \  |             |
                    |                       |     \ +-------------+
                    |                       | <- "Gap"
                    |                       |
                    |                       |
                    |                       |
                    |                       |
                    |                       |
                    |-----------------------|
                    |                       |
                    |                       |
                    |         Heap          |
                    |                       |
                    |                       |
                    |                       |
                    |-----------------------|
                    |                       |
                    |     .Section code     |
                    |                       |
Low address         +-----------------------+
```

== Memory Management

When memory allocating, memory allocator will not only allocate memory you request,
but also some extra memory for meta data.

``` text
|   total space allocated    |
| head | space you allocated |
       ^
       pointer points to
```

Some times memory manager may use some free space for storing
free space block meta data.

Allocate strategy:

- Best fit
- Worst fit
- First fit
- Continuous search

Some times memory allocator may return more space you need, but you can only
rely on space you request.

Compact:


= Section IX: Computer architecture

If have code:

``` c
int i;
int j;

i = 10;
j = i + 7;
j ++;
```

Assuming memory segment:

``` text
       +-----------+
0xf000 |           |
0xeffc |           |
       |   | i |   | <- BP
       |   | j |   |
       |           | <- SP
       |           |
       |           |
       |           |
       |           |
       |           |
       +- - - - - -+
....
       +- - - - - -+
0x1000 |           |
       +-----------+
```

Assume i, j are packed together within stack.
BP storing stack base address.

To visit variable `i`, using `[SP+4]`.
Thus, `i = 10;` could be written as `mov [sp+4], 10`

For `j = i + 7`, it should first load `i` and then do ALU operation.

- load `i`: `mov r1, [sp+4]`
- add: `add r2, 7`

Then, `mov [sp], r2`.
And, `inc [sp]`

== Load / Store, ALU Operations

== force conversion

Force conversion just cheat compiler rather than assembler.
Assembler knows only address.


= activate record: function call frame

If have: prototype:
```c
void foo(int bar, int * baz) {
  char sninke[4];
  short * why;
  // ...
}
```

The argument of corresponding parameter and the local variables are placed in
almost close place.

```text
4 byte
        |         | baz
        |         | bar
        | < ret > |
        |         | snike
        |         | why
```

When calling within other functions: like `main`:

```c
int main (int argc, char * argv[]) {
  int i = 4;
  foo(i, &i);
  return 0;
}
```

We may have:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC <- sp
```
at initial.

Then, allocate space for variable `i`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |         |      <- sp
```
Assign for `i`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |    4    | i    <- sp
```

When calling `foo`:
pushing argument to stack for `foo`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |         | i
        | argument| i
        | argument| &i   <- sp
```

= Section XI: Swap, call in assembly

```c
void foo() {
  int x = 11;
  int y = 17;
  swap(&x, &y);
}
```

In assembly, `_cdecl`, arguments are pushed in reverse order:

```asm
_foo:
  push rbp
  mov rbp, rsp

  sub rsp, 8              ; x, y are 4 bytes each, total 8 bytes
  mov dword [rsp + 4], 11 ; x = 11
  mov dword [rsp], 17     ; y = 17

  push qword [rsp]
  add rsp, 8              ; clean up stack after call

  mov rax, 60
  mov rdi, 0
  syscall

  mov rsp, rbp
  pop rbp
```

While `swap` may written as:

```c
void swap(int * a, int * b) {
  int tmp = *a;
  *a = *b;
  *b = tmp;
}
```

8 bytes are reserved for `saved pc` and 16 bytes for 2 arguments.
`a` for `rsp - 8`, `b` for `rsp - 16`
since the program runs in x86_64 machine.
Left most parameter lays at the button of stack frame.


In c:
```c
void __attribute__((naked)) swap(int *ap, int *bp) {

  asm volatile(
      // fetch arguments from stack
      "mov rbx, [rsp + 8];\n"
      "mov eax, [rbx];\n"
      "mov rbx, [rsp + 16];\n"
      "xchg eax, [rbx];\n"
      "mov rbx, [rsp + 8];\n"
      "mov [rbx], eax;\n"

      "ret;\n"
      :
      :
      : "rsi", "rdi", "memory");
}

void __attribute__((naked)) foo() {

  asm volatile(
      // initialize variables
      // push rbp;
      // mov rbp, rsp;
      // for better if possible
      "sub rsp, 8;\n"
      "mov dword ptr [rsp + 4], 11;\n"
      "mov dword ptr [rsp], 17;\n"

      "lea rax, [rsp + 4];\n"
      "push rax;\n"
      "lea rax, [rsp];\n"
      "push rax;\n"

      "call swap;\n"

      "add rsp, 16;\n" // clean up calling

      // clean up stack
      // also possible to use
      // `mov rsp, rbp; push rbp;`
      // if bp is set
      "add rsp, 8;\n"
      "ret;\n"
      :
      :
      : "memory");
}

int main(int argc, char *argv[]) {
  foo();
  return 0;
}
```

`swap` function does not implemented as code shown in c, but use `xchg`.

= Pre-process, Compile, Assemble, Link

Code -> Processed Code -> Assembled Code -> Objected File -> Executable File

== Preprocessor

=== `#define`

Replacement of text appear in source file.

+ constant replacement

  ```c
  #define SIZE 1024
  char buf[SIZE];
  ```

+ parameterized macro

  ```c
  #define MAX(a, b) ((a) > (b) ? (a) : (b))
  int x = MAX(3, 5);
  ```

=== `#include`

== compiler

= Section XIII:

What if comment `#include <stdio.h>`?

The program can probably still be compiled.

What if comment `#include <stdlib.h>`?

`assert` will be seen as a function and the final object file will miss the symbol.

```c
void foo() {
  int i;
  int array[4];
  for (i = 0; i <= 7 /* for 32-bit alignment requirement in x86_64 Linux, there are 3-bits padding */; i ++) {
    array[i] = 0;
  }
}
```
Will loop, forever.

What will happen if
```c
int Declare() {
  int array[100];
  for (int i = 0; i < 100; i ++) {
    array[i] = i;
  }
}

int Print() {
  int array[100];
  for (int i = 0; i < 100; i ++) {
    printf("%d", array[i]);
  }
}
```

Two function have same memory structure so that the Print can work correctly,
since the function `Declare` will not clean whole bit pattern after returning.

The technology is called "Channeling".

== multiple arguments

Push arguments from right to left.
For better organization of compiler.

= Multiple Threads

Operating systems give different process a virtual memory.
So that the program can assuming it holds all memory.

Kernel trace and maintaining Virtual Memory Mapping Table and calls MMU to map virtual memory of each process to real memory.

Program execution is sequential.

When multiple processes share one shared data,
it may manipulate the data after other process manipulate it already.
E.g., read a variable and check it already fit the requirement, when it about to do operation on it, it was switched to another process by
scheduler, and the other process do operation on the variable successfully.
When the time scheduler dispatch back to original one, it will never able to validate the variable and do same operation to the variable.
Which cause the error.

The condition happened here called race condition.

There always be some critical section in code, when code executing in critical section, it will never able to validate the shared data again.

The solution is to use semaphore or lock to protect critical section.
When a process want to enter critical section, it will try to acquire the lock.

Semaphore is a integer variable with atomic operation ability,
when it is 0, the process can not enter critical section,
else if it is greater than 0, the process can enter critical section and decrease the semaphore by 1 atomically.
When leaving critical section, add the semaphore, release the resource.

Semaphore operations acquire resources.

== Producer Consumer Problem

Producer generates data, puts into a buffer.
Consumer takes data from buffer, process it.

Consumer should not take data when buffer is empty.
Producer should not put data when buffer is full.

Use two semaphores to track the number of empty slots and full slots in buffer.

== Reader Writer Problem

Reader Writer problem is a classic synchronization problem.
With two types of processes, readers and writers,
readers can read shared data simultaneously,
writers need exclusive access to shared data.

== Philosophers Dining Problem

Every philosopher needs two forks to eat.
Five philosophers sitting around a table,
when a philosopher wants to eat,
it will try to pick up the left and right forks.
But if all philosophers pick up the left fork first,
then they will never able to pick up the right fork,

This is a deadlock.

== Ice cream Shop Problem

= Functional Programming Paradigm

In functional programming paradigm, each function are treated as regular mathematical function.
Which accepts some input and produce some output.

```lisp
;car
;cdr
```

`car` in scheme extracts the first element of a list.
While `cdr` extracts the rest of the list.

Known already, so for short, Mujiu will not explain more about scheme here.

In scheme, or in lisp, car and cdr comes from lisp machine assembly instruction.
There are two registers, address register and data register, which is the `ar` and `dr` where `car` and `cdr` comes from.


Eval & Apply loop:
`Eval` represents evaluation in lisp, which is the process of parsing the list and evaluating it.
And then, when a application is found, `Apply` will be called to apply the function to the arguments.
Apply reduce the expression with function and it also need eval to evaluate the arguments and function body.

Then eval and apply loops over and over until the expression is fully evaluated.

== Power Set

If it is required to generate power set of a set.
Concerning all subsets with and without each element.
Then the process can be divided into two branches at each element.
Which is a recursive division.

With `let`, it is possible to store intermediate result temporarily.
Thus it decrease the computation time since it avoid recomputation of same subproblem.
Though it cannot decrease the time and space complexity of a recursive process indeed.

`let` is equivalent to lambda expression application, with parameters bind to arguments like regular values bind to let variables.

= Python: Script Language Paradigm

Python is a imperative, object-oriented, and functional programming language.

All paradigms may be used by the user using python.
Thus the paradigm python represents is script style paradigm.
Which means you may work with python without really design a program structure.




