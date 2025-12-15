= D-Flat Spec

== Lilies: S-Expression Language Build Upon D-Flat System

== Abstract 摘要

// TODO:

== Introduction 引言

// TODO:

=== Background 背景

// TODO:

=== Guiding Principle 指导方略

// TODO:

== Overview 语言总览

本章用于描述语言的基本概念, 以帮助了解后续章节.
本章依据语法条目以帮助手册的方式被组织起来, 并非完整对于语言的描述.
在某些地方也不会完善和规范.

=== Type System 类型系统

- Basic Types
- Symbols
- Object System
- Internal Types (Special Types Concerning Compiler)
- Syntax Types
- Auto Type Detection

=== Object System

  - Basic Class & Meta Class
    - Parent & Final
    - Extend Base Class
  - Fields
  - Properties
  - Interface
    + Implement Interface
    + Default Implement
    + Cross-domain Interface
  + Methods
    + Method for objects
    + Method for classes
    + Implement Methods
    + Inherit Methods
    + Call the Method
      + Static Dispatch
      + Method visit Syntax Sugar
      + Dynamic Dispatch
      + Invoke
  + Generic Functions
    + History: `CLOS`
    + Define Generic Function:
      广义函数允许方法调用以普通函数的方式被使用:

      ``` scheme
      (define foo:constraint
        (interface ()
          (define bar (function (self)))

      (define foo
        (generic bar () #:implement foo:constraint))

      (define zoo
        (class
          #:self this))

      (implement zoo foo:constraint
        (define bar
          (lambda ()
            (display 1))))

      (implement zoo new
        (define new
          (lambda (self)
            (alloc:heap (this))))

      (define a (new zoo))

      ({bar a})
      ;; equal to
      (foo a)
      ```

    + Trait Shadow

=== Expression

=== Apply & Evaluation

+ Apply & Evaluation
  + Value Pass
  + Reference Pass
    + Ownership transaction
    + Move
    + Brought

=== Variable, Binding & Reference

- Variable, Definition & Binding
  - Dynamic Scope
  - Lexical Scope
  - `define`
  - `let` & `let:` family
  - Dynamic In Lexical Scope
- Form
- Assignment

=== Procedure, Function & Method

- Functions
  - Parameters
  - Rest Parameters
  - Parameter Stack
  - Return Values
  - Multiple Values Returning
  - Function Call
  - Multiple Value for Function Call

=== Name Space, Lexical Scope, Dynamic Scope, Closure

=== Generics

+ Generics: Template
  + Generic Macro

=== Macro

+ Macro
  + History: Compile-time calculation
  + History: C-Style Macro
  + History: `defmacro`
  + Procedure Macro
  + Hygiene for the Unhygienic Macro

=== Syntax Rules

+ Syntax Rules
  + History: Hygiene Macro
  + Syntax Object

=== Memory Management
+ Pointer
  + Reference Count
  + Unique Ownership
  + Raw Pointer
  + Address
  + Virtual Method Table: How dynamic dispatch implemented
+ Ownership
+ Garbage Collection
+ Allocation
  + `alloc:stack`: Object Allocated in Stack
  + `alloc:heap`: Object Allocated in Heap
  + `new`: Object creation
+ Auto Life-cycle Detection

=== Expression Tree

=== Continuations

=== Exception Handling
  + Condition System

=== Module & Library

=== Top-Level

== ...
