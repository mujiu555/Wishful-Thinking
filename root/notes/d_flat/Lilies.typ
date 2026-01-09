#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Lilies: S-Expression Language Build Upon D-Flat System]
#date[2025-12-14 23:46]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Abstract 摘要

Lilies (short for "List Interpret Language in s-Expression Syntax")
is a dialect of LISt-Processing language.

This report describes the design and implementation of Lilies language.

Lilies is designed to be extremely simple and portable.
With a small set of kernel, clear semantics, and a powerful macro system,
Lilies makes it easy to combine expressions into higher-level constructs.

The language is designed to be extensible and flexible:
its hygienic macro system lets users defines new syntax and corresponding semantics safely.
A set of built-in special forms and macros is provided to simplify common programming tasks; these act as syntactic sugar over the core language.

Lilies aims to be efficient practical and safe.
With a strong type system, an ownership model forces memory safety and, and compile-time evaluation capabilities, the language can force programmers to write efficient and safe code.
Lilies can express complex algorithms and data structures in functional, imperative, declarative and message passing styles or so.

The standard library for Lilies are divided into two parts:
a core language library that provides basic data types, syntaxes, and contracts;
and a compile-time library that supplies macros and compile-time functions.

The language Lilies should be implemented with both an interpreter and a compiler.
Together with REPL, Development Environment, Debugger, and other tools to provide a complete programming experience.

The language has a full type system: primitive types, composite types, generic types, and user-defined types, plus type annotations and type inference.
The type system should support type inference, type checking, and type casting.
Providing with interface, trait, and generic programming capabilities.

Lilies should include a complete module system (module definition, import / export, and versioning)
that support dependency management and module resolution.

It should also include a complete exception handling system (exception definition, exception throwing and catching, and exception propagation)
with custom exception types definition and hierarchies.

The language should support continuation system (definition, capture and invocation),
including continuation system should support first-class continuations and continuation passing style.

Finally, Lilies should provide a comprehensive metaprogramming system (macros, compile-time functions, and code generation) that support hygienic macros and compile-time evaluation.

Lilies（全称 “List Interpret Language in s-Expression Syntax”）是一种列表处理语言方言。本报告描述了 Lilies 语言的设计与实现。

Lilies 的设计目标是极其简单且可移植。通过一个精简的内核、清晰的语义以及强大的宏系统，Lilies 能够方便地将表达式组合成更高层次的构造。该语言强调可扩展性与灵活性：其卫生宏（hygienic macro）系统使用户可以安全地向语言中添加新的语法及相应语义。语言提供了一组内建的特殊形式和宏以简化常见编程任务，这些可视为语法糖。

Lilies 追求高效、实用与安全。借助强类型系统、强制内存安全的所有权模型以及编译时求值能力，语言能够帮助程序员编写高效且安全的代码。Lilies 可用于以函数式、命令式或消息传递等风格表达复杂算法与数据结构。

Lilies 的标准库分为两类：一类是核心语言库，提供基本数据类型、语法与契约；另一类是编译时库，提供宏和编译时函数。

Lilies 应当同时实现解释器和编译器，并配套提供 REPL、开发环境、调试器及其它工具，以提供完整的开发体验。

该语言应具备完整的类型系统，包括基本类型、复合类型、泛型类型和用户自定义类型，并支持类型注解与类型推断。类型系统应支持类型推断、类型检查与类型转换，并提供接口、特征（trait）和泛型编程能力。

Lilies 应设计完整的模块系统，包含模块定义、导入导出与版本管理，模块系统应支持依赖管理与模块解析。语言还应设计完整的异常处理系统，包含异常定义、抛出与捕获以及异常传播，并支持自定义异常类型与异常层次结构。

Lilies 应设计完整的续体/延续（continuation）系统，包含续体的定义、捕获与调用，支持一等续体和续体传递风格（continuation-passing style）。

最后，Lilies 应设计完善的元编程系统，包含宏、编译时函数与代码生成，元编程系统应支持卫生宏与编译时求值。

= Introduction 引言

A generic programming language cannot satisfy all the needs of all programmers.
Thus reduce the complexity of the language is important.
Keeping the least core language and giving users the ability to extend the language.

A simple and clear expression syntax and the unlimited combinability of expressions can thus  construct a practical and effective programming language.

Lilies have many design from earlier Lisps and Scheme dialects.
First-class functions(procedures), lexical scope, continuations, macros.
Syntax are also a objects that can be manipulated programmatically.
But in contrast to them, Lilies is designed to be with a strong static type system.

Lilies meant to be a native language competed with c.
Or be like a compile target, so that other languages can be implemented upon it.
In D-Flat system, Marguerite is implemented upon Lilies.

Every symbols in Lilies sharing same namespace, no matter they are variables, functions, classes, interfaces, modules or so.
In each expression, operators and operands are distinguished by their position.

Though other lisp dialects use function application to archive loop, Lilies provides full functional loop constructs as built-in syntax extension other than core language.
The tail call optimization is also provided to make sure loops are efficient.

Classes for the object-oriented programming paradigm are provided.
Everything in Lilies is an object, including functions, classes, interfaces, modules, and so on.
Classes can be computed at compile-time, allowing for powerful metaprogramming capabilities and generic programming.
Lilies supports monomorphized generics, allowing for efficient code generation and type safety.
With traits and interfaces, Lilies supports polymorphism and code reuse.
With contracts, Lilies supports design by contract programming.
There also provided with full compile-time type checking and type inference capabilities.

Modules in Lilies are first-class citizens.
Modules can be defined, imported, and exported.

The language is able to capture every continuation, which is "rest of the computation" at any point in the program. For which advanced control flow constructs can be built upon.
When a continuation is captured, it will be saved as "escape procedure", a function that can be invoked later to resume the computation from the point where the continuation was captured.
Markable, there exists a special kind of continuation, "delimited continuation", which will also be supported in Lilies.

For a higher-level logical, algebraic effects can be also handled with Lilies.
The effect handlers can be implemented with continuations, but in Lilies, it will be treated as a separate construct to provide better syntax and semantics.

A full functional exception handling system is provided.
With conditional system, exceptions can be defined, raise, caught, and propagated.
Allowing users to resume from exceptions or handle them in a flexible way.
For non-local control flow, a simpler and lighter exceptions system can be used to implement coroutines, generators, and other advanced control flow constructs.

There are various ways to extend the language.
Macros are the most powerful one.
Macros in Lilies are hygienic and provide user with the ability to parse AST, fetch or drop context information, and generate new syntax trees.
Thus new syntax constructed can be hygienic or unhygienic as needed.
Syntax objects are first-class in Lilies, provides the ability to parse, manipulate, and generate syntax trees, especially in macros.
The other way to extend the language is through symbol generation.
It is possible to generate new expressions with given symbols or attributes at compile-time (likely Ksp for kotlin or Roslyn for c\#).

Macros system for Lilies must ensure that macros used in the program can provide same information as built-in syntax at compile-time.
So that the compiler can provide full error information for user.

The language is built with attribute grammar.
So that every syntax can be associated with attributes, which can be used to store type information, scope information, or other metadata.

Everything except `define` cannot create new bindings directly in the current scope.
`let` and `let:` family are used to create new bindings through closure capture.
Thus, the language is designed to be referentially transparent.
Everything including variables, functions, classes, modules, and macros should be defined before use.

Those features make Lilies a powerful tool for building complex software systems.
Furthermore, a research for computer program theory.

== Background 背景

The lilies language is designed and implemented as part of the D-Flat system.
For creating a practical programming language and a powerful tool that can be used to implement other languages.

In the design of Lilies, many ideas and concepts from other programming languages are borrowed.

== Guiding Principle 指导方略

The design of Lilies is guided by several principles:
+ Simplicity: The language should be simple and easy to learn, with a small set of core constructs and clear semantics.
+ Portability: The language should be portable, able to run on a variety of platforms and architectures.
+ Extensibility: The language should be extensible, allowing users to define new syntax and without modifying the core language.
+ Orthogonality: The language should be orthogonal, with constructs that can be combined in a variety of ways without unexpected interactions.
+ Uniformity: The language should be uniform, with consistent syntax and semantics across different constructs; Source code should be able to be treated as data and vice versa.

For real world programming, the following principles are also important:
+ Enable library creation and code reuse.
+ Provide strong type system to catch errors at compile-time.
+ Allowing for efficient code generation and execution.
+ Support multiple programming paradigms, including functional, imperative, and declarative programming styles.

= Overview 语言总览

本章用于描述语言的基本概念, 以帮助了解后续章节.
本章依据语法条目以帮助手册的方式被组织起来, 并非完整对于语言的描述.
在某些地方也不会完善和规范.

== Variable, Slots & Fields 变量, 插槽与字段

Variables in Lilies are some space allocated to store values.

Slots are locations within objects that can hold values, named or not.
In practice, slots are some space allocated within an object to store values.

Fields are similar to slots, but they are named and is used to store values that are associated with a specific object instance.

== Type System 类型系统

Every value in Lilies has a type.
Types are used to classify values and determine what operations can be performed on them.

It is able to define new types by combining existing types (structures) or inductively defining new types (recursive types).

Each type are individual, defined by its name, structure, and behavior.
But types can also have hierarchical relationships with other types through inheritance and subtyping.
A type can be a subtype of another type, if and only if it inherits from that type and implement all traits and interfaces defined the type implemented.

Supertype doesn't means that all values of the subtype can be treated as values of the supertype.
The only guarantee is that when a constraint requires a value of the supertype, a value of the subtype can be used instead.

Every type must derive a default "empty" value, together with its corresponding type, which is used when a value of that type is required but not provided.
Every type has its own type checking rules, which are used to determine whether a value is of that type or not.
Thus empty values can be distinguished from other values of the same type.

=== Basic Types 基本类型

Primitive types for Lilies language include:
- Numbers
- Booleans
- Characters
- Strings
- Symbols
- Pairs
- Vector
- Tuples
- Any
- None
- Ignore

==== Number Tower 数字类型层次

Numbers in Lilies are organized in a type hierarchy known as the "number tower".
At the base of the tower is the most general type, `Number`, which encompasses all numeric types:
- Number
- Complex
- Real
- Rational
- Integer
- Unsigned Integer
- Zero
Below `Unsigned Integer`, there are specific types for different sizes of integers:
- `(int 8)` or `(uint 8)`
- `(int 16)` or `(uint 16)`
- `(int 32)` or `(uint 32)`
- `(int 64)` or `(uint 64)`

Zero is a special type that represents the value zero.
It can be used to construct other numeric types.

Default Empty type for numbers is Zero.

==== Booleans 布尔类型

Booleans in Lilies are represented by the type `Boolean`, which has two possible values: `#True` (true) and `#False` (false).
The boolean type are organized in a type hierarchy:
- Boolean
  - True
  - False

Default Empty type for booleans is False.

==== Characters 字符类型

Characters in Lilies are represented by the type `Character`, which represents a single Unicode character.
Default Empty type for characters is the null character type EOF, which has the only instance `#\EOF`.

==== Strings 字串类型

Strings in Lilies are represented by the type `String`, which represents a sequence of objects, typically characters.
Default Empty type for strings is the Empty type, for which the only instance is the empty string `""`.

==== Symbols 符号类型

Symbols is a unique and immutable identifier used to represent names or labels in Lilies.
Symbols have their own name, which is a string.
Symbols are often used as keys in associative data structures, such as hash tables or dictionaries.
Two symbols with the same name are considered equal.

Symbols are interned, meaning that there is only one instance of a symbol with a given name in the system.
When a symbol is created, the system checks if a symbol with the same name already exists, and if so, returns the existing symbol instead of creating a new one.

Symbols has their own type, `Symbol`.
None default empty type for symbols.

==== Pairs 对偶类型

Pairs in Lilies are represented by the type `Pair`, which represents a ordered pair of values.
Pairs is a type as primitive type but with generic type parameters, allowing for pairs of any two types of values.

Pairs that the second element contains another pair that has its second element being None are treated as lists.
Which are linked lists constructed from pairs.

Default Empty type for pairs is the `Pair::Empty` type, for which the only instance is the pair `(None . None)`.

==== Vectors 向量类型

Vectors in Lilies are represented by the type `Vector`, which represents a fixed-size sequence of values.
Vectors is a type as primitive type but with two generic type parameters: the type of the elements and the size of the vector.

Default Empty type for vectors is the `Vector::Empty` type, a vector type that has size of 0 and type of None.
The only instance of this type is the empty vector `#()`.

==== Tuples 元组类型

Tuples in Lilies are represented by the type `Tuple`, which represents a fixed-size sequence of values of potentially different types.
Tuples is a type as primitive type but with a variable number of generic type parameters, each representing the type of an element in the tuple.

Default Empty type for tuples is the `Tuple::Empty` type, a tuple type that has no elements.
The only instance of this type is the empty tuple `#<>`.

==== Any 任意类型

Any type is the supertype of all types in Lilies.
Every value in Lilies is of type Any.
But Any type cannot hold any value directly nor be instantiated.

In practice, Any type is used as a placeholder type when the specific type of a value is not known or not important.

Any type has no default empty type.

==== None 空类型

None type is the subtype of all types in Lilies.
None represents the absence of a value.
None type can hold only one value, which is also called None.

In practice, None type is used to indicate that a value is missing or not applicable.

None type is the default empty type for Symbols, and itself.

==== Ignore 忽略类型

Ignore type is a special type that indicates that a value should be ignored.
Values of Ignore type are not stored or used in any way.
Ignore type is often used in situations where a value is required by the syntax or semantics of the language, but the value itself is not important.
Ignore type has only one value, also a variable, which is also called Ignore.

In practice, Ignore type is used to indicate that a value should be ignored or discarded.

Ignore type is the default empty type for itself.

=== Syntax Object 语法类型

Syntax objects in Lilies are representations of code as data structures, together with contextual information such as scope and source location.
Syntax objects are so special that they should be built-in and given first-class status in the language.

=== Closure Type 闭包类型

Functions in Lilies represents a mapping from a set of input values (parameters) to a set of output values (return values).
And can capture the lexical scope in which they are defined, forming closures.

Closure type constructs the type of a function, including the types of its parameters and return values.

=== Composite Types 复合类型

There are composite type constructors provided in Lilies language, including:
- product types
  - tuples
  - pairs
  - vectors
  - lists
  - arrays
  - maps
  - structures
- sum types
  - tagged unions
- recursive types
  - linked lists
- intersection types
  - traits
  - interfaces

Some of them are built-in primitive types with generic type parameters, such as tuple, pair, and vector.
Others are constructed through type definition syntax, such as structures, unions, and recursive types.

=== Enum Types 枚举类型

Enumeration types in Lilies are special form of tagged unions, which represent a set of named values.

=== Internal Types 内部类型

Internal types in Lilies are special types that are used by the language implementation itself, and are not intended to be used directly by programmers.
The only exception is the Syntax Object type, which is used in macros and syntax manipulation.

=== Generic 泛型类型

There exists different kinds of generic type implements in practice,
including:
- monomorphization
- type erasure
- dictionary passing / witness table
- reified generics
- boxing / universal representation
- compile-time type computation / metaprogramming
- canonicalization
In the Lilies language, compile-time type computation is main approach used to implement generics.

=== Type Dispatch 类型分派

When a value is used in an expression, the type of the value is determined through type dispatch.

=== Auto Type Detection 自动类型检测

When defining variables, functions, classes, and so on, if the type is not explicitly specified, the type will be inferred from the context.

== Object System

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
=== Traits 特征

=== Implementation 实现

=== Generic 广义函数


== Expression

== Apply & Evaluation

+ Apply & Evaluation
  + Value Pass
  + Reference Pass
    + Ownership transaction
    + Move
    + Brought

== Variable, Binding & Reference

- Variable, Definition & Binding
  - Dynamic Scope
  - Lexical Scope
  - `define`
  - `let` & `let:` family
  - Dynamic In Lexical Scope
- Form
- Assignment

== Procedure, Function & Method

- Functions
  - Parameters
  - Rest Parameters
  - Parameter Stack
  - Return Values
  - Multiple Values Returning
  - Function Call
  - Multiple Value for Function Call

== Name Space, Lexical Scope, Dynamic Scope, Closure

== Generics

+ Generics: Template
  + Generic Macro

== Macro

+ Macro
  + History: Compile-time calculation
  + History: C-Style Macro
  + History: `defmacro`
  + Procedure Macro
  + Hygiene for the Unhygienic Macro

== Syntax Rules

+ Syntax Rules
  + History: Hygiene Macro
  + Syntax Object

== Memory Management
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

== Expression Tree

== Continuations

== Exception Handling
+ Condition System

== Module & Library

== Top-Level

= ...
