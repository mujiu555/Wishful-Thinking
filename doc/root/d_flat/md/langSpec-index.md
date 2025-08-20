# D-Flat Language Spec (Index)

## Abstract 摘要

## Contents 目录

[TOC]

## Introduction 概述

## Description of the Language 语言描述

### Overview

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
+ Auto Life-cycle Detection
+ Auto Type Detection
+ Expression Tree
+ Continuations
+ Exception Handling
  + Condition System
+ Module & Library
+ Top-Level

### Requirement

### Number Level

### Lexical Syntax & Datum Syntax

#### Notation

#### Lexical Syntax

##### Form Description (for Lexical Syntax)

##### Line Ending (`CR-LF`)

##### Blanks & Comments

##### Symbol Literals

##### Boolean Literals

##### Character Literals

##### Character String Literals

##### Number Literals

#### Datum Syntax

##### Form Description (for Datum Syntax)

##### Pair & List Datum

##### Array Datum

##### Special Forms

##### Prelude Special Forms' Abbreviations

### Lexical Concept

#### Program, Module & Library

#### Variable, Binding, Scope & Environment

#### Exception Condition

#### Parameters Check

#### Syntax Error

#### Boolean, `#True` & `#False`

#### Multiple Return value

#### Unspecified Behaviour

#### Undefined

#### Variable Storage

#### Proper tail recursion

#### Dynamic extent

### Library

### Primary Syntax

#### Primitive Expression Types

##### Literals

##### Variable Reference

##### Procedure Call

``` scheme
<call>          => (<operator> <operand> ...)
<operator>      => <expression>
<operand>       => [ '#&' <name> ] <expression>
```

##### Method Call

For static dispatch:

``` scheme
((method <object> <operator-name>) <object> <operand> ...)
```

For dynamic dispatch:

``` scheme
(invoke <object> <operator-name> <operand> ...)
```

##### Method Call Abbreviation

``` scheme
({<operator-name> <object>} <operand> ...)
;; which is same as
((method <object> <operator-name>) <object> <operand> ...)

({<operator-name> <class>} <operand> ...)
;; which is same as
((method <class> <operator-name>) <operand> ...)
```

##### Annotation

``` scheme
<Annotation>    => '#@(' <name> { <operand> } ')'
<name>          => <symbol>
```

#### Procedure Macro

#### Reader Macro

#### Syntax Rules

#### Expander

### Prelude

#### Primitive Types

#### Definition

``` scheme
<define>        => '(' 'define' <name> [ '#:type' <type> ] <init> ')'
```

+ variable
+ function
+ generic
+ macro
+ syntax rule

#### Intern

#### Expression

##### Quotation

``` scheme
<quotation>      => '(' 'quote' <datum> ')'
```

##### Function

``` scheme
<lambda>         => 
'(' 'lambda' <formals> [ ('#:returns' <returning>) | ('=>' <returning>) ] 
    <body> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
<name>           => <symbol>
<type>           => <expression>
<initial>        => <literals>
<constraint>     => <expression>
<returning>      => '(' { <type> } ')'
                 |  <nil>
                 |  <type>
<body>           => <expression>
```

``` scheme
<function>       => '(' 'function' <formals> <returning> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
<name>           => <symbol>
<type>           => <expression>
<initial>        => <literals>
<constraint>     => <expression>
<returning>      => '(' { <type> } ')'
                 |  <nil>
                 |  <type>
```

##### Logical Expression

``` scheme
<and>            => '(' 'and' { <test> } ')'
<or>             => '(' 'or' { <test> } ')'
<xor>            => '(' 'xor' { <test> } ')'
<not>            => '(' 'not' <test> ')'
```

##### Conditionals

``` scheme
<if>             => '(' 'if' <test> <consequent> [ <alternate> ] ')'
```

``` scheme
<cond>           => '(' 'cond' <entry> { <entry> } ')'
<entry>          => '(' <test> <consequent> ')'
                 |  '(' ':else' <consequent> ')'
```

``` scheme
<case>           => '(' 'case' <val> <entry> { <entry> } ')'
<val>            => <expression>
<entry>          => '(' <pattern> <consequent> ')'
                 |  '(' ':else' <consequent ')'
<pattern>        => <expression>
```

Pattern match utility:

``` scheme
<match>          => '(' 'match' <val> <entry> { <entry> } ')'
<val>            => <expression>
<entry>          => '(' <pattern> <consequent> ')'
                 |  '(' '_' <consequent ')'
<pattern>        => <expression>
```

##### Loop

``` scheme
<iter>           => '(' 'iter' '(' <binding-lst> { <binding-lst> } ')'  <body> ')'
<binding-lst>    => '(' <name> <enumerable> ')'
```

##### Assignment

``` scheme
<set!>           => '(' 'set!' <variable> <value> ')'
<variable>       => <expression>
<value>          => <expression>
```

Assignable

##### Binding Structures

``` scheme
<let>            => '(' 'let' '(' { <binding-lst> } ')' <body> ')'
<binding-lst>    => '(' <variable> [ '#:type' <type> ] [ <init> ] ')'

<let:fwd>        => '(' 'let:fwd' '(' { <binding-lst> } ')' <body> ')'
<let:rec>        => '(' 'let:rec' '(' { <binding-lst> } ')' <body> ')'
<let:rec:fwd>    => '(' 'let:rec:fwd' '(' { <binding-lst> } ')' <body> ')'

<for>            => '(' 'for' <name> '(' { <binding-lst> } ')' <body> ')'
```

##### Sequence

``` scheme
<sequence>       => '(' 'sequence' [ '#:tag' <name> ] <body> ')'
<body>           => <expression>
                 |  '(' ':break' [ '#:tag' <name> ] [ <value> ] ')'
<value>          => <expression>
```

##### Equivalent Predicate

``` scheme
<equal?>         => '(' 'equal?' <value1> <value2> ')'
```

##### Number

+ Integer
+ Float
+ Bit Decimal

##### Boolean

##### Symbol

##### Pair & List

##### Character

##### String

##### Array

##### Error

##### Type

+ Class:

``` scheme
<class>          =>
'(' 'class' <inherits>
   [ '#:super' <super> ]
   [ '#:self' <self> ]
   { <fields> }
   { <properties> } ')'

<inherits>       => '(' { <class> } ')'
<fields>         =>
'(' ':fields' <deffield> { <deffield> } ')'
<properties>     =>
'(' ':properties' <defprop> { <defprop> } ')'

<deffield>       =>
'(' 'define' <name> [ '#:type' ] <type> [ <init> ] ')'
<defprop>        =>
'(' 'define' <name> [ '#:type' ] <type> <init> <getter> <setter> ')'
```

+ Type Self Reference

``` scheme
<Self>           => '&Self'
```

+ Interface

``` scheme
<interface>      =>
'(' 'interface' <inherits>
   <methods>
  { <methods> } ')'
```

+ Method

``` scheme
<method>         => '(' 'define' <name> <lambda> ')'
<lambda>         => '(' 'lambda' <formals> [ '#:returns' <types> ] <body> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
                 |  [ <pass> ] <self>
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
```

+ Implement

``` scheme
<implement>      =>
'(' 'implement' <class> [ <interface> ]
   <method>
   { <method> } ')'
```

+ Generic

###### Trait Shadow

##### Multiple Values

##### `apply`

##### `call/cc`

##### `cc:values`

##### `call/values`

##### Tail Call & Tail Context

## Description of the Standard Library 标准库描述

## Appendices 附录
