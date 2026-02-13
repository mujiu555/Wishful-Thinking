#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Crafting Interpreters]
#date[2026-02-12 20:05]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Chapter I: Overview

Process of compile:
+ Lexing: source code -> tokens, lexing is the shortcut for "lexical analysis",
  it is the first step of compile, it is responsible for breaking the source code into tokens,
  which are the basic building blocks of the language.
  - Accept text stream
  - Break input into tokens
  - return stream of pairs for token type and value
+ Parse: tokens -> syntax tree, takes flat sequence of tokens and builds a tree structure that mirrors the nested nature of the grammar.
  - Build syntax tree from token stream
  - Report syntax errors
  - Resume from errors
+ Static Analysis: syntax tree -> annotated syntax tree,
  - Gather information about program structure and behavior
  - Binding: resolve variable and function names to their declarations
  - Type checking: ensure that operations are performed on compatible types
  - Store semantic information in properties field of a node, store data in symbol table, or transform the tree into a new form that is easier to analyze.
Following steps are middle end of compilation.
The compiler works like a pipeline, each step organizes the data in a way that makes the next step easier to perform.
Front end of compilation aims to understand the structure and meaning of the source code, while the back end focuses on generating efficient machine code.
However, the middle end is not related to both front end and back end tightly, it preforms as a bridge.
This helps to separate code generation from the details of the source language, and allows for optimizations that are independent of the target architecture.
+ Optimization: annotated syntax tree -> optimized syntax tree, translate current program to a more efficient one.
+ Code Generation: optimized syntax tree -> machine code, translate the optimized syntax tree into targeted machine code, virtual or real.

Alongside these steps, there are also some other important part for a programming language.
+ Virtual machine: an abstract machine that executes bytecode, which is a low-level, platform-independent representation of the program.
+ Runtime: the environment in which a program executes, providing services such as memory management, input/output, and error handling.

Compiler is not the only thing helps to execute a program,
- Single pass compiler: a compiler that processes the source code in a single pass, without generating intermediate representations.
- Tree walk interpreter: an interpreter that executes a program by traversing its abstract syntax tree (AST) directly, without generating bytecode or machine code.
- Transpiler: a compiler that translates source code from one programming language to another, often with the goal of making it easier to run on a different platform or to take advantage of features in the target language.
- Just-in-time (JIT) compiler: a compiler that generates machine code at runtime, rather than ahead of time, allowing for optimizations based on the actual execution context.

= Chapter II: Lox

