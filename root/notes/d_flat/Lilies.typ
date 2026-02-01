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

A single generic programming language cannot satisfy all needs of all programmers.
Therefore reducing language complexity is important:
keep a small core and give users the ability to extend the language.

A simple, clear expression syntax and unlimited composability of expressions make it possible to construct a practical and effective programming language.

Lilies draws many design ideas from earlier Lisps and Scheme dialects:
first-class functions (procedures), lexical scope, continuations, and macros.
Syntax objects can be manipulated programmatically.
In contrast to those languages, Lilies is designed with a strong static type system.

Lilies is intended to be a native language that can compete with C,
or a compilation target upon which other languages can be implemented.
In the D-Flat system, Marguerite is implemented on top of Lilies.

All symbols in Lilies share a single namespace, whether they are variables, functions, classes, interfaces, modules, or other entities.
In each expression, operators and operands are distinguished by their positions.

Unlike some Lisp dialects that use function application to implement loops,
Lilies provides full functional loop constructs as built-in syntax extensions (outside the minimal core).
Tail-call optimization is provided to ensure loops are efficient.

Object-oriented classes are supported.
Everything in Lilies is an object, including functions, classes, interfaces, and modules.
Classes can be computed at compile time, enabling powerful metaprogramming and generic programming.
With traits and interfaces, Lilies supports polymorphism and code reuse.
Contracts enable design-by-contract programming.
The language also provides full compile-time type checking and type inference.

Modules are first-class citizens: they can be defined, imported, and exported.

The language can capture continuations
--- the "rest of the computation" at any point ---
allowing advanced control-flow constructs to be built on top.
When a continuation is captured it is saved as an "escape procedure",
a function that can be invoked later to resume execution at the capture point.
Delimited continuations are also supported.

For higher-level control, algebraic effects and handlers are supported.
Although effect handlers can be implemented with continuations,
Lilies treats them as a distinct construct with dedicated syntax and semantics.

A full functional exception system is provided.
Exceptions can be defined, raised, caught, propagated, and in some cases resumed, allowing flexible handling.

There are several ways to extend the language;
macros are the most powerful.
Lilies’ macros are hygienic and let users parse ASTs, access or drop contextual information, and generate new syntax trees.
Macro-generated syntax can be hygienic or intentionally unhygienic as needed.
Syntax objects are first-class, permitting parsing, manipulation, and generation of syntax trees,
especially within macros.
Another extension mechanism is symbol generation: new expressions can be generated at compile time with specific symbols or attributes
(similar in spirit to KSP for Kotlin or Roslyn for C\#).

The macro system must ensure that macros can provide the same compile-time information as built-in syntax so the compiler can produce full error diagnostics.

The language is built on an attribute grammar so that each syntax node can carry attributes used to store type information, scope information, and other metadata.

Except for `define`, no construct may directly create new bindings in the current scope.
The `let` and `let:` families create bindings through closure capture.
The language is designed to be referentially transparent: variables, functions, classes, modules, and macros should be defined before use.

These features make Lilies a powerful tool for building complex software systems and a fertile platform for research in programming theory.

单一的通用编程语言无法满足所有程序员的所有需求。因此，简化语言复杂性很重要：保留最小核心，并赋予用户扩展语言的能力。

简单清晰的表达式语法以及表达式的无限可组合性，使得构建实用且高效的编程语言成为可能。

Lilies 在设计上借鉴了早期的 Lisp 和 Scheme 方言的许多思想：一等函数（过程）、词法作用域、continuations（续延/延续）和宏。语法对象可以以编程方式进行操作。与这些语言不同，Lilies 设计为具有强静态类型系统的语言。

Lilies 的目标是成为一门可与 C 竞争的本地语言，或作为其他语言的编译目标。在 D-Flat 系统中，Marguerite 就是建立在 Lilies 之上的。

在 Lilies 中所有符号共享同一个命名空间，不论它们是变量、函数、类、接口、模块或其他实体。在每个表达式中，运算符和操作数由其位置来区分。

不同于某些 Lisp 方言通过函数调用实现循环的做法，Lilies 提供完整的函数式循环构造，作为内建的语法扩展（而非核心）。同时提供尾调用优化以保证循环的高效性。

支持面向对象的类。Lilies 中的一切都是对象，包括函数、类、接口和模块。类可以在编译期计算，从而支持强大的元编程能力和泛型编程。通过 trait（特征）和接口，Lilies 支持多态和代码重用。通过契约（contracts），支持契约式设计。语言同时提供完整的编译时类型检查和类型推断能力。

模块是第一类公民：可以定义、导入和导出。

语言能够捕获任意时刻的 continuation（程序剩余计算），从而可以构建高级控制流构造。捕获的 continuation 会被保存为“逃逸过程”（escape procedure），这是一个可以稍后调用以从捕获点恢复计算的函数。Lilies 也支持定界（delimited）continuation。

为了实现更高层次的控制，Lilies 也支持代数效果（algebraic effects）及其处理器。虽然效果处理器可以用 continuation 来实现，但 Lilies 将它们作为独立的构造来提供，以便拥有更好的语法和语义支持。

提供了完整的函数式异常处理系统。异常可以定义、抛出、捕获和传播，并在某些情况下支持恢复，从而灵活地处理错误。

有多种方式扩展语言，其中宏是最强大的。Lilies 的宏是“卫生”的（hygienic），并允许用户解析抽象语法树（AST）、获取或丢弃上下文信息、生成新的语法树。宏生成的语法可以根据需要是卫生的或有意非卫生的。语法对象在 Lilies 中是一等公民，便于在宏中解析、操作和生成语法树。另一种扩展方式是符号生成：可以在编译时根据给定的符号或属性生成新的表达式（类似于 Kotlin 的 KSP 或 C\# 的 Roslyn）。

宏系统必须确保程序中使用的宏在编译时能提供与内建语法相同的信息，以便编译器能给出完整的错误诊断。

该语言基于属性文法构建，每个语法节点都可以关联属性，用于存储类型信息、作用域信息或其他元数据。

除 `define` 外，任何构造都不能直接在当前作用域创建新的绑定。`let` 和 `let:` 系列通过闭包捕获来创建绑定。因此语言被设计为引用透明：变量、函数、类、模块和宏应在使用前定义。

这些特性使 Lilies 成为构建复杂软件系统的强大工具，同时也是计算机程序理论研究的良好平台。

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
A type can be a subtype of another type, if and only if it inherits from that type and implement all traits and interfaces the type implemented.

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
- Meta
- Unit

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

String are some serialized data, a continuous sequence of bytes.
No matter it is encoded utf-8 ro raw bytes, even integers or complex objects.

In Lilies, there are different kinds of continuous data:
- Strings, which is described here,
- Vector, fixed-size sequence of same-type elements,
- Tuple, fixed-size sequence of potentially different-type elements,
- Array, variable-size sequence of same-type elements,
- List, variable-size sequence of potentially different-type elements, as a linked list,

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

==== Meta 元类型

Meta type is the type of types in Lilies.
Meta type may be structure description or type generator.

Meta type always promises to be non-empty, thus has no default empty type.

==== Unit 单元类型

Every structure that has no fields is considered as Unit type.
Thus unit type is not a primitive type, but a special structure type.

Unit types cannot have instances, thus has no default empty type.

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

Use `type` to define new recursive types by creating type generators that can produce types based on type parameters.
The type described by `type` will not create a new type indeed, rather a new type checker that can check whether a value is of the described type or not will be implemented.

=== List Types 表类型

In Lilies, same as other Lisp dialect, the List is composited by Pairs that have second element be another List.

=== Enum Types 枚举类型

Enumeration types in Lilies are special form of tagged unions, which represent a set of named values.
Furthermore, if a enum is not defined to have variants with specified type, the variants can be assigned with any constant value with same type.
Though it is just be done by translating Enum index to corresponding value, it will be obviously use-friendly.

=== Sealed Classes 密封类

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

=== Traits 特征与接口

Traits are a way to define shared behavior that can be implemented by multiple types.
Furthermore, traits can be composed together to create new traits.

Traits can be used to constraint generic types, ensuring that a type parameter implements a specific set of behaviors.
Traits can be used to define dynamic dispatch rule, allowing methods to be called on values of different types that implement the same trait.

=== Type Dispatch 类型分派

When a value is used in an expression, the type of the value is determined through type dispatch.

=== Auto Type Detection 自动类型检测

When defining variables, functions, classes, and so on, if the type is not explicitly specified, the type will be inferred from the context.

== Object System 对象系统

Object is the core concept of Lilies language.
Though types in Lilies can not inherit from other types in the traditional sense,
objects system for Lilies still provides other way to archive polymorphism and code reuse.

The class defines only the structure of a object, but methods are implemented separately.
With traits, it becomes possible to share method implementations across different classes and extend object behaviour outside the class definition.

A concept of generic function is borrowed from CLOS and it is renamed to `interface` in Lilies.
With interface, user-defined methods can be called in a uniform way as traditional functions.
Another benefit is that interfaces are all static dispatched by default, making them more efficient than traditional methods.

`implement` syntax will create methods for a specific class, and assign the method to corresponding class.

There are still some special concept borrowed form traditional OOP languages:
- Fields: named slots associated with a specific object instance.
- Properties: named slots that used for value fetching only.

All objects in lilies are referenced by value by default.
To have a object referenced by reference, use type wrappers.

Type wrapper can be ownership, garbage collected or reference counted pointer.

This part describes the object system, definition of classes, and their possible literals.

=== Primitive Object 原始对象

Primitive objects in Lilies are build upon primitive types.
Some of primitive objects can be written in literal syntax.

Primitive objects cannot be split into smaller parts.

For which, there are:
- Integer Object
  - `[1-9][0-9]*`
  - `0b[01]+`
  - `0o[0-7]+`
  - `0x[0-9a-fA-F]+`
- Float Object
  - `[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?`
  - `\.[0-9]+([eE][+-]?[0-9]+)?`
  - `[0-9]+[eE][+-]?[0-9]+`
- Character Object
  - `#\descrition`
  - `#\'character`
  - `#\uXXXX`
- String Object
  - `"string content"`
  - `#f"string content with escapes"`
  - `#b"raw string content"`
- Symbol Object
  - `'symbol-name`
- Boolean Object
  - `#True`
  - `#False`
- Pair Object
  - `'(first . second)`

Above, quote syntax is used to create literal syntax for symbols and pairs.

=== Classes, Fields, Properties & Traits 类, 字段, 属性与特征

Classes are user defined types for structure types.

A classes can declare it inherits from a parent class explicitly,
but that will not change the class structure.
If a class is declared to have a parent class, it must implement all traits that its parent class implements.

Fields are named slots associated with a specific object instance.
Each field has its own name and type.
In class definition, fields are declared with `define` syntax.

Properties are named slots that used for value fetching only.
The method to declare a field as property can be various,
Use setter and getter methods is one of the common way.
However, it is encouraged to manually assign accessibility attributes to fields to control read and write access right for internal, class internal, package internal, and public access levels.

Traits are used to define shared behavior that can be implemented by multiple classes.
Traits can be implemented manually for a class,
and user defined traits can be used to extend class behavior for a library defined class.

==== Definition of Classes 类的定义

Define a new class with `class` syntax.
E.g., to define a new class `Point` with two fields `x` and `y` of type `Integer`:
```lisp
(define Point
  (class
    (define x Integer)
    (define y Integer))))
```
Here, `define` syntax used to declare Point as the class we defined using `class` syntax.
And `define` syntax inside the class body used to declare fields `x` and `y` of type `Integer`.
`#:self this` declares that within the class body, `this` refers to the current instance of the class.
Symbols starts with `#:` are keywords annotations, for which pass some attributes when function or macro application.
Another special keyword annotations are start with `#&`, for passing some attributes when function or macro definition.
Most generic annotations are written as `#@[attributes]`, and is assigned to expressions.
Later there will be a chapter describing all these annotations in detail.

Full syntax of class definition is described as:
```lisp
class-definition ::=
'(' 'class' <inherits>
   { <fields> } ')'

<inherits>       => '(' { <class> } ')'
<fields>         =>
'(' ':fields' { <deffield> } ')'

<deffield>       =>
'(' 'define' <name> [ '#:type' ] <type> [ <init> ] ')'
```

Inherits clause declares the super classes of the class being defined.
Self clause declares the symbol that refers to the current instance of the class within the class body.
Type clause declares the type of the class being defined.

With annotations, the accessibility of fields can be controlled:
E.g.,
```lisp
(define Point
  (class
    #@[accessibility x (read :public) (write :private)]
    #@[accessibility y (read :public) (write :private)]
    (define x Integer)
    (define y Integer))))
```

To define filed to be variable, wrap type with `variable`.
Otherwise, the field is not assignable after object creation.

Define syntax vary depend on the context it appears, thus the `define` we used here is not suitable for other case in Lilies.
But, it is clear that, there can be only `define` or `lambda` to have the ability to create a new binding.

==== Definition of Traits 特征的定义

Define a new trait with `trait` syntax.
E.g., to define a new trait `Drawable` with a method `draw`:
```lisp
(define Drawable
  (trait
    #:self self
    (define draw (function (self)))))
```
==== Method and Trait Implementation 方法与特征实现

Both Methods and Traits are implemented with `implement` syntax.

`implement` unwraps namespace of a class, and then methods defined within the body are assigned to the class function table.
Furthermore, traits can unwrap namespace of a object, and then anything inside will only extend the object behavior.

Empty implementation list indicates the methods defined inside this `implement` are for the class itself, not for a trait.

E.g., Implement Drawable for Point:
```lisp
(implement Point (Drawable)
  #:self self
  #:Type Self
  (define draw
    (lambda (self)
      #:returns (None)
      (print f"x: {(field self 'x)}; y: {(field self 'y)}"))))
```

Since `implement` syntax unwraps the namespace of a class or object only, it is possible to define variables associated with the class or object inside.

==== Generic Function & Interface 泛义函数与接口


==== Method Dispatch 方法分派

When a method is called on an object, the method to be executed is determined through method dispatch.

===== Dynamic Dispatch 动态分派

```lisp
((invoke object 'method-name') object ...args)
;; or
({method-name object} ...args) ; for short
```

===== Static Dispatch 静态分派

```lisp
((method Class 'method-name') ...args)
;; or
({method-name Class} ...args) ; for short
```

===== Method Access 语法糖方法调用

===== Invoke 调用

==== Field & Property Access 字段与属性访问

==== Traits Shadowing 特征遮蔽

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

Assignment is a trait that must be implemented by any type that supports assignment operation.
There are three types of assignment:
- Move: move the ownership
- Clone: clone the object
- Reference: assign by reference

== Procedure, Function & Method

- Functions
  - Parameters
  - Rest Parameters
  - Parameter Stack
  - Function body
  - Return Values
  - Multiple Values Returning
  - Function Call
  - Multiple Value for Function Call
  - Returning


```lisp
(define foo
  (lambda ((param #:ref (int 8) #:init 0))
    #:returns ()
    '()))
;; param with type of `(int 8)', signed integer length 8bits, passed by reference (borrow in rust),
;; initial default value 0
(define bar
  (lambda ((param (String)))
    #:returns ()
    '()))
;; param with type of `String`, passed by value, deep clone needed
(define baz
  (lambda ((param #:in (Vector (int 32) 4)))
    #=> ()
    '())))
;; param with type of `Vector` of 4 elements, each element is signed integer length 32bits,
;; passed by ownership movement

;; `#:returns ()` here is the returning value list for each function
```

Procedures can have their returning value list have named values or just types, which declare the types of returning values.
If named values are provided, the returning values can be accessed by name, and they can be used as ordinary variables in the function body.

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
+ Syntax Rules
  + History: Hygiene Macro
  + Syntax Object

== Symbol Generation

=== Expression Tree

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

== Continuations

== Exception Handling
+ Condition System

== Module & Library

== Top-Level

= ...
