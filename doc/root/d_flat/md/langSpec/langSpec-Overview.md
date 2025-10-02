# D-Flat Language Spec (Overview)

## Overview

### Type System

### Expression

### Variable, Binding & Reference

### Procedure, Function & Method

+ Types
  + Basic Types
  + Symbols
  + Object System
  + Internal Types (Special Types Concerning Compiler)
  + Syntax Types
+ Expression
+ Variable, Definition & Binding
  + Dynamic Scope
  + Lexical Scope
  + `define`
  + `let` & `let:` family
  + Dynamic In Lexical Scope
+ Form
+ Assignment
+ Functions
  + Parameters
  + Rest Parameters
  + Parameter Stack
  + Return Values
  + Multiple Values Returning
  + Function Call
  + Multiple Value for Function Call
+ Classes & Objects
  + Basic Class & Meta Class
    + Parent & Final
    + Extend Base Class
  + Fields
  + Properties
  + Interface
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
+ Generics: Template
  + Generic Macro
+ Macro
  + History: Compile-time calculation
  + History: C-Style Macro
  + History: `defmacro`
  + Procedure Macro
  + Hygiene for the Unhygienic Macro
+ Syntax Rules
  + History: Hygiene Macro
  + Syntax Object
+ Apply & Evaluation
  + Value Pass
  + Reference Pass
    + Ownership transaction
    + Move
    + Brought
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
+ Auto Type Detection
+ Expression Tree
+ Continuations
+ Exception Handling
  + Condition System
+ Module & Library
+ Top-Level
