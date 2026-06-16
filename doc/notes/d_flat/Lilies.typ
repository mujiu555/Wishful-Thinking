#import "/lib/_lib.typ/lib.typ": *

#meta(
  title: [Lilies: List Interpret Language in s-Expression Syntax],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  author: link("https://github.com/mujiu555")[GitHub\@mujiu555],
  id: "dflat-lilies",
  parent_id: "index",
)

#mkheader()

== Abstract 摘要

Lilies (short for "List Interpret Language in s-Expression Syntax")
is a dialect of LISt-Processing language.

This report describes the design and implementation of Lilies language.

Lilies is designed to be extremely simple and portable.
With a small set of kernel, clear semantics, and a powerful macro system,
Lilies makes it easy to combine expressions into higher-level constructs.

The language is designed to be extensible and flexible:
its hygienic macro system lets users defines new syntax and corresponding semantics safely.
A set of built-in special forms and macros is provided to simplify common programming tasks; these act as syntactic sugar over the core language.

Lilies aims to be efficient, practical, and safe.
With a strong type system, an ownership model that forces memory safety, and compile-time evaluation capabilities, the language can guide programmers to write efficient and safe code.
Lilies can express complex algorithms and data structures in functional, imperative, declarative and message passing styles or so.

The standard library for Lilies is divided into two parts:
a core language library that provides basic data types, syntaxes, and contracts;
and a compile-time library that supplies macros and compile-time functions.

The language Lilies should be implemented with both an interpreter and a compiler.
Together with REPL, Development Environment, Debugger, and other tools to provide a complete programming experience.

The language has a full type system: primitive types, composite types, generic types, and user-defined types, plus type annotations and type inference.
The type system should support type inference, type checking, and type casting.
Providing trait and generic programming capabilities.

Lilies should include a complete module system (module definition, import / export, and versioning)
that supports dependency management and module resolution.

It should also include a complete exception handling system (exception definition, exception throwing and catching, and exception propagation)
with custom exception types definition and hierarchies.

The language should support continuations (definition, capture, and invocation),
including first-class continuations and continuation passing style.

Finally, Lilies should provide a comprehensive metaprogramming system (macros, compile-time functions, and code generation) that support hygienic macros and compile-time evaluation.

== Introduction 引言

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

All symbols in Lilies share a single namespace, whether they are variables, functions, classes, traits, modules, or other entities.
In each expression, operators and operands are distinguished by their positions.

Unlike some Lisp dialects that use function application to implement loops,
Lilies provides full functional loop constructs as built-in syntax extensions (outside the minimal core).
Tail-call optimization is provided to ensure loops are efficient.

Classes (product types / record types) are supported as user-defined composite types.
Everything in Lilies is a value with a type; functions, classes, traits, and modules are all first-class values at compile time.
Classes can be computed at compile time, enabling powerful metaprogramming and generic programming.
With traits, Lilies supports polymorphism and code reuse.
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

`define` is the only construct that directly adds new bindings to the current scope.
At the top-level and within `lambda` bodies, `define` is ordered and carries side effects: bindings created by `define` are visible to subsequent expressions in the same scope.
Within a module body, `define` does not carry sequential side effects — modules are compiled as namespace units rather than executed in order, so all definitions in a module are mutually visible regardless of textual order.
In contrast, `lambda` creates formal-parameter bindings within a new scope — it does not mutate the scope in which the `lambda` form appears.
The `let` and `let:` families create bindings through closure capture (i.e., by desugaring into `lambda`), so they also operate in a new scope rather than mutating the current one.
The language is designed to require definition before use: variables, functions, classes, modules, and macros must be defined before they are referenced.
This ensures that every name can be resolved at compile time without forward-reference ambiguity.

These features make Lilies a powerful tool for building complex software systems and a fertile platform for research in programming theory.

=== Background 背景

The lilies language is designed and implemented as part of the D-Flat system.
The goal is to create a practical programming language and a powerful tool that can be used to implement other languages.

In the design of Lilies, many ideas and concepts from other programming languages are borrowed.

=== Guiding Principle 指导方略

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

=== Section Description 章节描述

In the specification of the Lilies language, each topic is described in a separate chapter.

== Overview 语言总览

本章用于描述语言的基本概念, 以帮助了解后续章节.
本章依据语法条目以帮助手册的方式被组织起来, 并非完整对于语言的描述.
在某些地方也不会完善和规范.
在后续章节中, 每个主题都会被单独描述, 并且附带推荐实现细节.

=== Comment 注释

In the language Lilies, there are three main types of comments:
+ Documentation: Every piece of code can have its own documentation, and accessed through documentation family functions.
+ Code Block Comment: A block of code, each part of which is parsed as normal code, but without semantic meaning. Code block comments are used to temporarily disable a block of code or to provide examples of code usage.
+ Normal Comment: A comment that is ignored by the compiler and is used to provide explanations for code.

Documentation comments in Lilies extract the documentation-before-declaration convention found in other languages (Javadoc, doc comments in Rust, etc.) into a first-class syntax.
A documentation comment starts with `#;|` immediately followed by a token that indicates the documentation kind (e.g., no token for a plain doc comment, or a keyword like `TODO`, `FIXME`, `NOTE`, etc.; see below).
The documentation block ends with `|#;`.
Documentation comments must be placed directly before the definition or declaration they document.

At the beginning of each line within the documentation block, there must be a `;` to indicate that this line is part of the documentation.
Within documentation, there are some annotations for describing the properties of a function, variable, or symbol:
- `#name`
- `#param`
- `#return`
And for sample code part, `#;code|` and `|#;` are used to indicate the beginning and end of the code part respectively.
In each code part, the code this documentation belongs to is imported automatically, and all code blocks in same documentation
are treated as if they are in the same scope, thus can refer to each other.
Though each code block is seen as an individual parse unit.

For code block comments, the syntax is `#;` followed by a normal code block.

Normal comments can be either line comments,
starting with `;` and ending at the end of the line,
or block comments, starting with `#|` and ending with `|#`.

Nesting of comments is supported: `#|` ... `#|` ... `|#` ... `|#` is valid for block comments.
(Line comments are also technically described as nestable — nesting `;` within `;` is meaningless in practice since a line comment ends at the end of its line, but the rule is stated uniformly to keep the comment syntax simple and consistent.)

There are some simple conventions for single line comments:
- `;;` is used for comments that describe the following code.
- `;` is used for comments that describe the current line of code.
- `;;;` is used for comments that describe a block of code.
- `;;; %` and followed by a symbol, is used to split different sections of code, and the symbol is used to indicate the section name.

Except three main types of comments, there are some documentation comments' variants:
- todo comments, `#;TODO:`, a kind of single line documentation comment, indicates that there is still work to be done in this part of code.
- fixme comments, `#;FIXME:`, a kind of single line documentation comment, indicates that there is a known issue in this part of code that needs to be fixed.
- note comments, `#;NOTE:`, a kind of single line documentation comment, indicates that there is an important note or explanation about this part of code.
- hack comments, `#;HACK:`, a kind of single line documentation comment, indicates that there is a hack or workaround in this part of code that should be improved in the future.
- benchmark comments, `#;BENCHMARK:`, a kind of single line documentation comment, indicates that there is a benchmark or performance test related to this part of code.
- reference comments, `#;REF:`, a kind of single line documentation comment, indicates that there is a reference or related information about this part of code.
- test comments, `#;TEST:`, a kind of single line documentation comment, indicates that there is a test case or test code related to this part of code.

E.g., a function with documentation:
```lisp
#;|
 ; #name add
 ; #param a: Integer, the first number to add
 ; #param b: Integer, the second number to add
 ; #return Integer, the sum of a and b
 ;
 ; add for Church numerals
 ;
 ; #;code|
 ;  ; (add 1 2) ; => 3
 ;  |#;
 |#;
(define add
  (lambda ((a Integer) (b Integer))
    #:returns (Integer)
    ;; increse a by one and decrese b by one until b is zero
    (if (equal b 0)
      a
      (add (succ a) (pred b)))))
```

=== Variable, Slots & Fields 变量, 插槽与字段

Variables in Lilies are bindings that refer to allocated storage locations for values.

Slots are locations within objects that can hold values, named or not.
In practice, slots are memory locations allocated within an object to store values.

Fields are similar to slots, but they are named and is used to store values that are associated with a specific object instance.

=== Type System 类型系统

Every value in Lilies has a type.
Types are used to classify values and determine what operations can be performed on them.

It is able to define new types by combining existing types (structures) or inductively defining new types (recursive types).

Each type is individual, defined by its name, structure, and behavior.
Types are not related through inheritance or subtyping — Lilies adopts a Hindley-Milner type system without subtyping.
Instead, types relate to one another through trait implementations:
a type can implement a trait to provide shared behavior, and constrained generic type parameters accept any type that satisfies the required trait bounds.

Every user-defined type must derive a default "empty" value, together with its corresponding type, which is used when a value of that type is required but not provided.
Every type has its own type checking rules, which are used to determine whether a value is of that type or not.
Thus empty values can be distinguished from other values of the same type.

Certain built-in types and traits are explicitly exempt from the empty-value requirement, as noted in their respective sections: `Any` (a trait, not a concrete type), `Symbol`, `Meta`, and `Empty` have no empty value, either because they are not meant to be instantiated or because no meaningful empty value exists.

==== Basic Types 基本类型

Primitive types for Lilies language include:
- Numbers
- Booleans
- Characters
- Strings
- Symbols
- Pairs
- Vector
- Tuples
- Any (trait)
- Ignore
- Meta
- Unit
- Empty

===== Number Tower 数字类型层次

Numeric types in Lilies are not organized by subtyping.
Instead, each numeric type is distinct, and relationships between them are expressed through trait implementations (e.g., a type implements the `Number` trait, the `Integral` trait, etc.), similar to Haskell's type-class approach.

The numeric types include:

- `Integer` — arbitrary-precision integer, analogous to Haskell's `Integer` or Scheme's exact integer.
  This is the default integer type when no specific size is required.
- `Int` — fixed-size machine integer. Specific sizes are given by type application:
  - `(Int 8)`, `(Int 16)`, `(Int 32)`, `(Int 64)` for signed integers
  - `(Uint 8)`, `(Uint 16)`, `(Uint 32)`, `(Uint 64)` for unsigned integers
- `Rational` — exact rational number, represented as a pair of `Integer` numerator and denominator.
- `Real` — real number (floating-point). Specific precisions:
  - `(Real 32)` for single precision
  - `(Real 64)` for double precision (the default when writing `Real`)
- `Complex` — complex number, parameterized by the real component type:
  - `(Complex (Real 64))` for double-precision complex numbers.

`Int` is distinct from `Integer`: `Int` values are bounded machine words with wrap-around or checked arithmetic, while `Integer` values are arbitrary-precision and never overflow.

`Zero` is a special literal value that can be used wherever a numeric type is expected; the compiler infers the intended numeric type from context.

Default value for numeric types is the zero value of the corresponding type (e.g., `0` for `Integer` and `Int`, `0.0` for `Real`, etc.).

`Int` without a size argument defaults to `(Int 32)`, which is the most commonly used signed integer type.
`Size` is the short name for `(Uint 64)`, the longest unsigned integer type, used for memory-related quantities.

===== Booleans 布尔类型

Booleans in Lilies are represented by the type `Boolean`, an algebraic sum type with two constructors: `#True` (true) and `#False` (false).
`True` and `False` are not subtypes of `Boolean`; they are the only inhabitants of the `Boolean` type.

Default value for booleans is `#False`.

===== Characters 字符类型

Characters in Lilies are represented by the type `Character`, which represents a single Unicode character.
The empty character type is `EOF`, whose only instance (the default value) is `#\EOF`.

===== Strings 字串类型

Strings in Lilies are represented by the type `String`, which is a continuous sequence of bytes — analogous to Rust's `str` / `String`.
A string literal (e.g., `"hello"`) creates an immutable, UTF-8-encoded string by default; raw byte strings are created with the `#b"..."` literal prefix.
Strings are not generic over their element type: they always store bytes, though library functions interpret those bytes as UTF-8 code units when appropriate.
Default value for strings is a special canonical empty-string instance, distinct from the literal `""`.
The literal `""` creates a new empty string at each use, while the canonical empty string is a singleton — every reference to the string default value resolves to the same instance, avoiding allocation.

In Lilies, there are different kinds of continuous data:
- Strings, which is described here,
- Vector, fixed-size sequence of same-type elements,
- Tuple, fixed-size sequence of potentially different-type elements,
- Array, variable-size sequence of same-type elements,
- List, variable-size sequence of potentially different-type elements, as a linked list,

===== Symbols 符号类型

Symbols is a unique and immutable identifier used to represent names or labels in Lilies.
Symbols have their own name, which is a string.
Symbols are often used as keys in associative data structures, such as hash tables or dictionaries.
Two symbols with the same name are considered equal.

Symbols are interned, meaning that there is only one instance of a symbol with a given name in the system.
When a symbol is created, the system checks if a symbol with the same name already exists, and if so, returns the existing symbol instead of creating a new one.

Symbols has their own type, `Symbol`.
Symbols are exempt from the empty-value requirement (see Type System overview): they have no default empty type.

===== Pairs 对偶类型

Pairs in Lilies are represented by the type `Pair`, which represents a ordered pair of values.
Pairs are a primitive type with generic type parameters, allowing pairs of any two types of values.

A Pair whose second element is either another Pair or the empty list (nil) is treated as a list node.
Proper lists are linked lists constructed from pairs, terminated by the empty list.

The empty-type variant for pairs is `Pair::Empty`, whose only instance (the default value) is `(None . None)`.

===== Vectors 向量类型

Vectors in Lilies are represented by the type `Vector`, which represents a fixed-size sequence of values.
Vectors are a primitive type with two generic type parameters: the type of the elements and the size of the vector.

The empty-type variant for vectors is `Vector::Empty`, a vector type that has size 0 and element type `None`.
The only instance (the default value) of this type is the empty vector `[]`.

===== Tuples 元组类型

Tuples in Lilies are represented by the type `Tuple`, which represents a fixed-size sequence of values of potentially different types.
Tuples are a primitive type with a variable number of generic type parameters, each representing the type of an element in the tuple.

The empty-type variant for tuples is `Tuple::Empty`, a tuple type that has no elements.
The only instance (the default value) of this type is the empty tuple `<>`.

===== Any 任意类型

`Any` is a trait (analogous to Rust's `std::any::Any`) that is automatically implemented by every concrete type in Lilies.
A value of any type can be erased to a trait object `(dyn Any)` via an explicit coercion; the original concrete type can be recovered through a checked downcast.
`Any` itself is not a type that can be directly instantiated or that holds values directly — it is always used behind a reference or pointer as `(dyn Any)`.

In practice, `(dyn Any)` is used when the specific type of a value is not known at compile time and must be inspected at runtime (e.g., heterogeneous collections, reflective operations).

`Any` is exempt from the empty-value requirement (see Type System overview): it has no default empty type, since it is a trait rather than a concrete type.

===== Ignore 忽略类型

Ignore type is a special type that indicates that a value should be ignored.
Values of Ignore type are not stored or used in any way.
Ignore type is often used in situations where a value is required by the syntax or semantics of the language, but the value itself is not important.
Ignore type has only one value, also a variable, which is also called Ignore.

In practice, Ignore type is used to indicate that a value should be ignored or discarded.

Ignore is its own default value.

===== Meta 元类型

Meta type is the type of types in Lilies.
Meta type may be structure description or type generator.

Meta type always promises to be non-empty, thus has no default empty type (exempt from the empty-value requirement; see Type System overview).

===== Unit 单元类型

Unit is a primitive type that represents the absence of meaningful data.
Every structure that has no fields also yields the Unit type — the empty structure and the primitive Unit are the same type, not distinct.

Sometimes Unit type is used to represent that a function is finished and has no meaningful return value.

All unit values share the same instance, which is also called Unit.

Unit is its own default value.

===== Empty 空类型

Empty type is the bottom type in Lilies' type system (analogous to Rust's never type `!`).
Empty unifies with every other type during type inference, representing computations that never produce a value.
Empty type has no instances and can hold nothing.

In practice, Empty type is used to indicate that a value is missing or not applicable,
or that a function never returns (e.g., a function that always panics or diverges).

Empty has no default empty type (exempt from the empty-value requirement; see Type System overview).

==== Syntax Object 语法类型

Syntax objects in Lilies are representations of code as data structures, together with contextual information such as scope and source location.
Syntax objects are so special that they should be built-in and given first-class status in the language.

==== Closure Type 闭包类型

A function in Lilies represents a mapping from input values (parameters) to output values (return values).
When a `lambda` expression captures variables from its enclosing lexical scope, it forms a closure.
The resulting closure type includes the types of its parameters and its return values, and is a distinct type for each `lambda` expression.

A closure captures variables from the enclosing scope by borrow (default).
The borrow lasts for the lifetime of the closure — the compiler ensures captured references do not outlive their referents.
To capture by move (transferring ownership of a captured variable into the closure), annotate the `lambda` with `#:move`:
```lisp
(lambda #:move (x) ...)   ;; captures enclosing variables by move
```
This is analogous to `move |x| { ... }` in Rust: after the closure is created, moved variables are no longer accessible in the enclosing scope.

==== Continuation Type 续体类型

A continuation represents the "rest of the computation" at a given point in a program.
The continuation type captures the control state and environment at the point where the continuation is created.

In Lilies, continuations are first-class values with type `Continuation`.
A continuation can be invoked as if it were a procedure: it accepts a value (or values) and resumes execution at the capture point with those values.
Unlike ordinary functions, invoking a continuation never returns to the caller — it replaces the current continuation entirely.

The continuation type is parameterized by the types of values it accepts:
- `(Continuation A)` — a continuation that accepts a single value of type `A`
- `(Continuation A B)` — a continuation that accepts two values of types `A` and `B`

Continuations are created by the `call/cc` (call-with-current-continuation) primitive or by delimited continuation operators such as `reset` and `shift`.
Delimited continuations have type `(DelimitedContinuation A B)` where `A` is the input type and `B` is the type of the enclosing `reset` expression.

Continuations cannot be serialized and are valid only within the dynamic extent of their creation point, unless explicitly captured as escape procedures.

==== Annotation Type 注解类型

Annotations are metadata attached to expressions, declarations, or types that carry additional information for the compiler, tooling, or runtime.
The annotation type in Lilies is `Annotation`, which represents a key-value pair of compile-time or runtime metadata.

Annotations can be attached to syntax nodes using the `#@[...]` syntax or through keyword annotations (`#:key` and `#&key`).
The annotation type is parameterized by the kind of entity it annotates and the value it carries:
- `(Annotation :type T)` — an annotation carrying a type
- `(Annotation :expr)` — an annotation on an expression
- `(Annotation :decl NAME)` — an annotation on a declaration named `NAME`

Annotations are processed at compile time by annotation processors, which can inspect annotated syntax nodes and generate additional code, perform validation, or modify the compilation pipeline.
Built-in annotations include `#:type`, `#:returns`, `#:self`, `#:mut`, and `#:init`.
(`#:naming` is a call-site modifier for lazy evaluation, not an annotation; see Calling Conventions.)
Users can define custom annotations and corresponding annotation processors through the macro system.

==== Contracts 契约

Contracts in Lilies provide a design-by-contract mechanism that allows programmers to specify preconditions, postconditions, and invariants for functions, methods, and types.
Contracts are checked at compile time where possible, with remaining checks performed at runtime.

A contract is defined using the `contract` form, which associates a predicate with a name:
```lisp
(define non-negative?
  (contract (lambda (x) (>= x 0))))
```

Contracts can be attached to function parameters and return values:
```lisp
(define sqrt
  (lambda ((x (contract Integer non-negative?)))
    #:returns (contract Real non-negative?)
    ...))
```

Contract types include:
- Precondition contracts: checked before the function body executes.
- Postcondition contracts: checked after the function body executes, before returning.
- Invariant contracts: checked on entry and exit of every public method of a class.
- Class invariant contracts: checked after construction and before/after every public method.

Contracts can be selectively enabled or disabled at compile time for performance.
When a contract violation is detected, a `ContractViolation` condition is raised, which can be caught and handled by the condition system.

Contracts compose through trait implementation: a type implementing a trait
must satisfy or strengthen the contracts declared on that trait.


==== Composite Types 复合类型

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

Some of them are built-in primitive types with generic type parameters, such as tuple, pair, and vector.
Others are constructed through type definition syntax, such as structures, unions, and recursive types.

Use `type` to define new recursive types by creating type generators that can produce types based on type parameters.
The type described by `type` does not create a new type; rather, it implements a type checker that can verify whether a value matches the described type.

==== List Types 表类型

In Lilies, as in other Lisp dialects, a List is a chain of Pairs where each Pair's first element holds a value and its second element holds either the next Pair in the chain or the empty list (nil), which terminates the list.

==== Union Types 联合类型

Union types in Lilies are special form of tagged unions, which represent a set of named values.

==== Enum Types 枚举类型

If an enumeration type is not defined to have variants with specified types, the variants can be assigned any constant value of the same type.
This is done by translating the enum variant index to the corresponding value, which is user-friendly.

==== Sealed Classes 密封类

A sealed class is an algebraic data type with a closed set of variant constructors,
declared at the definition site. No new variants can be added outside the defining module,
analogous to Rust's `enum` with named-field variants.

Sealed classes are useful for modeling restricted hierarchies where all variants are known at compile time,
enabling exhaustive pattern matching.

```lisp
(define Expr
  (class #:sealed (Num Var Add Mul)
    (define loc (constant SourceLocation))))
```

`Num`, `Var`, `Add`, and `Mul` are the only constructors for `Expr`.
The compiler uses this information to verify exhaustiveness in `case` and `match` expressions over sealed types.

All variant constructors of a sealed class must be defined in the same module as the sealed class itself.
This ensures that the full set of variants is known at compilation time and cannot be extended by external code.

==== Record Classes 记录类

A record class is a compact class definition form that automatically generates:
- A primary constructor with parameters corresponding to all fields
- Accessor methods for each field
- Structural equality and hashing based on all fields
- A printable representation

Record classes are defined using the `record` keyword instead of `class`:
```lisp
(define Point
  (record
    (define x (constant Integer))
    (define y (constant Integer))))
```

This definition automatically provides:
- Constructor: `(Point x y)`
- Accessors: `(Point-x point)`, `(Point-y point)`
- Equality: structural comparison of `x` and `y`
- Hashing: based on `x` and `y`

Fields in a record class must be wrapped with `constant`; `variable` is not permitted for record fields.
Record fields are always immutable — this is a defining property of record classes.

Record classes are self-contained product types. They can implement traits normally,
but are not part of any class hierarchy — there is no inheritance in Lilies' type system.
Record classes are implicitly closed: no other type may extend or inherit fields from a record class.

==== Enum Classes 枚举类

Similar to enum types, but an enum class definition creates the enumeration together with a newly defined type,
and the variants of the enumeration can only be assigned with values of that type.

Behaving like enum classes in Java, an enum class in Lilies is syntactic sugar that combines an enum type definition
with a class definition. Each variant can carry its own fields and implement methods.
```lisp
(define Color
  (enum-class
    (Red    (define r (constant Integer)) (define g (constant Integer)) (define b (constant Integer)))
    (Green  (define brightness (constant Integer)))
    (Blue   (define saturation (constant Float)))))
```

Each variant of an enum class is a distinct constructor of the enum class (analogous to Rust's enum variants).
Methods can be defined on the enum class directly, with per-variant dispatch provided as syntactic sugar for exhaustive pattern matching in the method body.
Pattern matching over enum class instances is exhaustive when all variants are covered.

Enum classes are implicitly sealed: no variants may be added outside the defining module.
This guarantees that pattern matches over enum class values can be checked for exhaustiveness at compile time.

==== Internal Types 内部类型

Internal types in Lilies are special types that are used by the language implementation itself, and are not intended to be used directly by programmers.
The only exception is the Syntax Object type, which is used in macros and syntax manipulation.

==== Generic 泛型类型

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

==== Traits 特征与接口

Traits are a way to define shared behavior that can be implemented by multiple types.
Furthermore, traits can be composed together to create new traits.

Traits can be used to constraint generic types, ensuring that a type parameter implements a specific set of behaviors.
Traits can be used to define dynamic dispatch rule, allowing methods to be called on values of different types that implement the same trait.

==== Type Dispatch 类型分派

When a value is used in an expression, the type of the value is determined through type dispatch.

==== Auto Type Detection 自动类型检测

When defining variables, functions, classes, and so on, if the type is not explicitly specified, the type will be inferred from the context.

==== Type Inference 类型推断

===== Type Family 类型族

==== Typing Rules 类型规则

This section defines the formal typing rules of Lilies, modeled after the style used in the Kotlin language specification.
Typing rules are presented as inference rules of the form:

#figure(
  ```
    Premise₁    ...    Premiseₙ
  ────────────────────────────────  (Rule-Name)
              Conclusion
  ```
)

The notation is read as: if all premises above the line hold, then the conclusion below the line is derivable.
Each rule has a name (in parentheses on the right) for reference in the text.

===== Notation 记号

In the typing rules that follow:

- `Γ` (Gamma) denotes a typing context — a finite map from variable names to type schemes.
- `Δ` (Delta) denotes a trait environment — the set of trait implementations in scope.
- `Σ` (Sigma) denotes the structure definition environment — the set of class, record, enum, and type-family definitions in scope.
- `Γ(x)` denotes the type scheme assigned to variable `x` in context `Γ`.
- `Γ, x : τ` denotes the context `Γ` extended with variable `x` bound to type `τ`.
- `Γ \ x` denotes the context `Γ` with the binding for `x` removed.
- `[α ↦ τ]` denotes the capture-avoiding substitution of type variable `α` with type `τ`.
- `ftv(τ)` denotes the set of free type variables in type `τ`.
- `dom(Γ)` denotes the set of variable names bound in context `Γ`.

===== Judgment Forms 判断形式

The typing rules use the following judgment forms:

- `Γ ⊢ e : τ` — Under context `Γ`, expression `e` has type `τ`.
- `Γ ⊢ e : τ ! E` — Under context `Γ`, expression `e` has type `τ` and may perform effects `E`.
- `Γ ⊢ p : τ ⇒ Γ′` — Under context `Γ`, pattern `p` matches type `τ` and produces bindings `Γ′`.
- `Γ ⊢ τ` — Type `τ` is well-formed under context `Γ`.
- `Γ ⊢ τ : κ` — Type `τ` has kind `κ` under context `Γ`.
- `Δ ⊢ τ implements T` — Under trait environment `Δ`, type `τ` implements trait `T`.
- `Γ ⊢ τ₁ ≡ τ₂` — Types `τ₁` and `τ₂` are equivalent (definitionally equal).
- `Γ ⊢ τ₁ ≤ τ₂` — Type `τ₁` is a subtype of, or coercible to, type `τ₂`.
- `Γ ⊢ σ` — Type scheme `σ` is well-formed under context `Γ`.

===== Well-Formed Types 合式类型

A type `τ` is well-formed under context `Γ` if all its free type variables are bound in `Γ` and all its constituent type constructors are in scope.

```
    x ∈ dom(Γ)
  ─────────────  (WF-Var)
    Γ ⊢ x

    Γ ⊢ τ₁     Γ ⊢ τ₂
  ─────────────────────  (WF-Pair)
    Γ ⊢ (Pair τ₁ τ₂)

    Γ ⊢ τ    n is a nat-lit   n ≥ 0
  ─────────────────────────────────  (WF-Vector)
        Γ ⊢ (Vector τ n)

    Γ ⊢ τ₁    ...    Γ ⊢ τₙ   (n ≥ 0)
  ───────────────────────────────────  (WF-Tuple)
      Γ ⊢ (Tuple τ₁ ... τₙ)

     Γ, α ⊢ τ
  ───────────────  (WF-Forall)
    Γ ⊢ (∀ α. τ)

    Γ ⊢ τ₁    Γ ⊢ τ₂
  ────────────────────  (WF-Fun-Pos)
    Γ ⊢ (-> (τ₁ ... τₙ) τ_ret)

    Γ ⊢ τ₁    ...    Γ ⊢ τₙ    Γ ⊢ τ_ret
  ─────────────────────────────────────────  (WF-Fun-Named)
    Γ ⊢ (-> {x₁ : τ₁, ..., xₙ : τₙ} τ_ret)

    Δ ⊢ τ implements T
  ──────────────────────  (WF-Dyn)
    Γ ⊢ (dyn T)

    Γ ⊢ τ    Σ ⊢ C is a class with fields (f₁ : τ₁, ..., fₙ : τₙ)
  ──────────────────────────────────────────────────────────────  (WF-Class)
    Γ ⊢ C

    Σ(τ_generic) = type params α̅
    Γ ⊢ τ₁    ...    Γ ⊢ τₙ
  ────────────────────────────  (WF-Generic-Inst)
    Γ ⊢ (τ_generic τ₁ ... τₙ)
```

===== Expression Typing 表达式类型推导

====== Literals 字面量

```
  ──────────────────  (T-Integer)
    Γ ⊢ n : Integer

    n is a float-lit
  ────────────────────  (T-Real)
    Γ ⊢ n : Real

  ────────────────────  (T-Bool-True)
    Γ ⊢ #True : Boolean

  ────────────────────  (T-Bool-False)
    Γ ⊢ #False : Boolean

    c is a char-lit
  ────────────────────  (T-Character)
    Γ ⊢ #\c : Character

    s is a string-lit
  ────────────────────  (T-String)
    Γ ⊢ s : String

  ────────────────  (T-Unit)
    Γ ⊢ Unit : Unit

    Γ expects a numeric type Num
  ──────────────────────────────  (T-Zero)
    Γ ⊢ Zero : Num
```

====== Variable Reference 变量引用

```
    Γ(x) = τ
  ────────────  (T-Var)
    Γ ⊢ x : τ

    Γ(x) = σ     σ = ∀α̅. τ     β̅ fresh
  ───────────────────────────────────────  (T-Var-Inst)
    Γ ⊢ x : [α̅ ↦ β̅] τ
```

If a variable is bound to a polymorphic type scheme `σ`, the bound type variables `α̅` are instantiated with fresh type variables `β̅` at each reference site (let-polymorphism).

====== Lambda Abstraction 函数抽象

```
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e_body : τ_ret
    Γ ⊢ τ₁    ...    Γ ⊢ τₙ    Γ ⊢ τ_ret
  ────────────────────────────────────────────  (T-Lambda-Pos)
    Γ ⊢ (lambda (x₁ : τ₁ ... xₙ : τₙ) e_body)
        : (-> (τ₁ ... τₙ) τ_ret)

    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e_body : τ_ret
    Γ ⊢ τ₁    ...    Γ ⊢ τₙ    Γ ⊢ τ_ret
  ────────────────────────────────────────────  (T-Lambda-Named)
    Γ ⊢ (lambda {x₁ : τ₁, ..., xₙ : τₙ} e_body)
        : (-> {x₁ : τ₁, ..., xₙ : τₙ} τ_ret)
```

If `#:returns` is declared, the body's inferred type must be equivalent to the declared return type:

```
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e_body : τ_body
    Γ ⊢ τ_body ≡ τ_declared
  ──────────────────────────────────────────────────  (T-Lambda-Ret)
    Γ ⊢ (lambda (x₁ : τ₁ ...) #:returns τ_declared e_body)
        : (-> (τ₁ ...) τ_declared)
```

A lambda with an empty parameter list and no return annotation has the type `(-> () Unit)`:

```
    Γ ⊢ e_body : τ_ret
  ──────────────────────────────────  (T-Lambda-Nullary)
    Γ ⊢ (lambda () e_body) : (-> () τ_ret)
```

A lambda with a rest parameter collects remaining arguments:

```
    Γ, x₁ : τ₁, ..., xₙ : τₙ, rest : (List τ_rest) ⊢ e_body : τ_ret
    Γ ⊢ τ₁    ...    Γ ⊢ τₙ    Γ ⊢ τ_rest    Γ ⊢ τ_ret
  ─────────────────────────────────────────────────────────────  (T-Lambda-Rest)
    Γ ⊢ (lambda (x₁ : τ₁ ... xₙ : τₙ . rest) e_body)
        : (-> (τ₁ ... τₙ ... τ_rest) τ_ret)
```

The `#:move` annotation on a `lambda` affects the ownership analysis (borrow checker) and does not change the type.

====== Function Application 函数应用

```
    Γ ⊢ e_f : (-> (τ₁ ... τₙ) τ_ret)
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ───────────────────────────────────────  (T-App-Pos)
    Γ ⊢ (e_f e₁ ... eₙ) : τ_ret

    Γ ⊢ e_f : (-> {x₁ : τ₁, ..., xₙ : τₙ} τ_ret)
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ──────────────────────────────────────────────  (T-App-Named)
    Γ ⊢ {e_f x₁ : e₁, ..., xₙ : eₙ} : τ_ret
```

Call-site modifiers `(move e)` and `(clone e)` affect only the ownership analysis, not the type:

```
    Γ ⊢ e : τ          Γ ⊢ e : τ
  ────────────        ────────────
  (move e) : τ        (clone e) : τ
```

`#:naming` (lazy evaluation) wraps the argument type in a thunk:

```
    Γ, param : (-> () τ) ⊢ e_body : τ_ret
  ──────────────────────────────────────────  (T-Lambda-Naming)
    Γ ⊢ (lambda (#:naming param) e_body)
        : (-> (τ) τ_ret)
    where the call site wraps the argument in an implicit thunk
```

====== Definition 定义

```
    Γ ⊢ e_val : τ     x ∉ dom(Γ)
  ────────────────────────────────  (T-Define)
    Γ ⊢ (define x e_val) : Unit
    and Γ, x : τ for subsequent expressions

    Γ ⊢ e_val : τ     Γ ⊢ τ_declared
    x ∉ dom(Γ)        Γ ⊢ τ ≡ τ_declared
  ─────────────────────────────────────────  (T-Define-Typed)
    Γ ⊢ (define (x τ_declared) e_val) : Unit
    and Γ, x : τ_declared for subsequent expressions
```

At the top level and within `lambda` bodies, `define` is ordered: each binding is visible to subsequent expressions.
Within a module body, all `define` forms are mutually visible regardless of textual order (define does not carry sequential side effects in module context), but the typing rule `Γ, x : τ` still applies to the logical environment after the definition.

====== Conditional 条件

```
    Γ ⊢ e_cond : Boolean
    Γ ⊢ e_then : τ     Γ ⊢ e_else : τ
  ─────────────────────────────────────  (T-If)
    Γ ⊢ (if e_cond e_then e_else) : τ

    For each i = 1...n:   Γ ⊢ e_condᵢ : Boolean    Γ ⊢ e_bodyᵢ : τ
    Γ ⊢ e_else : τ
  ───────────────────────────────────────────────────────────────  (T-Cond)
    Γ ⊢ (cond (e_cond₁ e_body₁) ... (e_condₙ e_bodyₙ) (else e_else)) : τ

    Γ ⊢ e_scrutinee : τ_key
    For each i = 1...n:   Γ ⊢ e_keyᵢ : τ_key    Γ ⊢ e_bodyᵢ : τ
    Γ ⊢ e_else : τ
  ───────────────────────────────────────────────────────────────  (T-Case)
    Γ ⊢ (case e_scrutinee ((e_key₁) e_body₁) ... ((e_keyₙ) e_bodyₙ) (else e_else)) : τ
```

====== Let Binding Family

```
    Γ ⊢ e₁ : τ₁    Γ, x₁ : τ₁ ⊢ e_body : τ
  ───────────────────────────────────────────  (T-Let)
    Γ ⊢ (let ((x₁ e₁)) e_body) : τ

    Γ ⊢ e₁ : τ₁    Γ, x₁ : τ₁ ⊢ e₂ : τ₂    Γ, x₁ : τ₁, x₂ : τ₂ ⊢ e_body : τ
  ────────────────────────────────────────────────────────────────────────────  (T-Let-Fwd)
    Γ ⊢ (let:fwd ((x₁ e₁) (x₂ e₂)) e_body) : τ

    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e₁ : τ₁
    ...
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ eₙ : τₙ
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e_body : τ
  ──────────────────────────────────────────────────  (T-Let-Rec)
    Γ ⊢ (let:rec ((x₁ e₁) ... (xₙ eₙ)) e_body) : τ

    Γ, x₁ : τ₁ ⊢ e₁ : τ₁
    Γ, x₁ : τ₁, x₂ : τ₂ ⊢ e₂ : τ₂
    ...
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ eₙ : τₙ
    Γ, x₁ : τ₁, ..., xₙ : τₙ ⊢ e_body : τ
  ──────────────────────────────────────────────────  (T-Let-Seq-Rec)
    Γ ⊢ (let:seq:rec ((x₁ e₁) ... (xₙ eₙ)) e_body) : τ
```

In `let:fwd` and `let:seq:rec`, each binding can refer to previous bindings.
In `let:rec` and `let:seq:rec`, bindings may be recursive (refer to themselves or bindings defined later).

====== Sequence 序列

```
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ₋₁ : τₙ₋₁    Γ ⊢ eₙ : τ
  ───────────────────────────────────────────────────────  (T-Seq)
    Γ ⊢ (sequence e₁ ... eₙ) : τ
```

The type of a sequence is the type of its last expression. In syntactic contexts such as a `lambda` body, multiple expressions are implicitly wrapped as a sequence — no explicit `sequence` keyword is needed.

Another case of sequencing is the top-level of a file, where expressions are evaluated in order:

```
    For top-level expressions e₁ ... eₙ:
      ∅ ⊢ e₁ : τ₁,   Γ₁ ⊢ e₂ : τ₂,   ...,   Γₙ₋₁ ⊢ eₙ : τₙ
  ───────────────────────────────────────────────────────────  (T-Top-Level)
    where Γ₁ = (x₁ : τ₁) for each (define x₁ e₁)
```

====== Quotation 引用

```
  ────────────────  (T-Quote-Symbol)
    Γ ⊢ 's : Symbol

    e is a self-evaluating datum
  ───────────────────────────────  (T-Quote-Datum)
    Γ ⊢ 'e : (QuoteType e)
```

`(QuoteType e)` yields the type of the quoted datum as a syntax-object type at compile time.

====== Pair Construction and Access

```
    Γ ⊢ e_car : τ₁    Γ ⊢ e_cdr : τ₂
  ────────────────────────────────────  (T-Cons)
    Γ ⊢ (cons e_car e_cdr) : (Pair τ₁ τ₂)

    Γ ⊢ e : (Pair τ₁ τ₂)
  ───────────────────────  (T-Car)
    Γ ⊢ (car e) : τ₁

    Γ ⊢ e : (Pair τ₁ τ₂)
  ───────────────────────  (T-Cdr)
    Γ ⊢ (cdr e) : τ₂
```

The empty pair `(None . None)` has type `Pair::Empty`.
For list construction, `(cons e₁ (cons e₂ ... (cons eₙ '())))` has type `(List τ)` when each `eᵢ : τ`.

====== Vector Construction and Access

```
    Γ ⊢ e₁ : τ    ...    Γ ⊢ eₙ : τ
  ─────────────────────────────────────  (T-Vector)
    Γ ⊢ [e₁ ... eₙ] : (Vector τ n)
    where n is the compile-time-known length

    Γ ⊢ e_vec : (Vector τ n)    Γ ⊢ e_idx : (Int 64)
  ───────────────────────────────────────────────────  (T-Vector-Index)
    Γ ⊢ (index e_vec e_idx) : τ
```

When the index is a compile-time constant, the compiler can partially evaluate the access and emit a bounds check or omit it for in-bounds indices that are statically proven safe.

====== Tuple Construction and Access

```
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ──────────────────────────────────────  (T-Tuple)
    Γ ⊢ <e₁ ... eₙ> : (Tuple τ₁ ... τₙ)

    Γ ⊢ e_tup : (Tuple τ₁ ... τᵢ ... τₙ)    i is a compile-time constant
  ────────────────────────────────────────────────────────────────  (T-Tuple-Index)
    Γ ⊢ (index e_tup i) : τᵢ
    where 0 ≤ i < n
```

====== Assignment 赋值

```
    Γ ⊢ e_loc : τ     Γ ⊢ e_val : τ
  ───────────────────────────────────  (T-Set!)
    Γ ⊢ (set! e_loc e_val) : Unit
```

The location `e_loc` must be mutable — the binding must have been declared with `#:mut` (for variables) or the field must have been declared with `variable` (for class fields).
An assignment to an immutable binding or a `constant` field is rejected by the type checker.

====== Class Construction 类构造

```
    Σ(ClassName) = (class (define f₁ (constant τ₁)) ... (define fₙ (constant τₙ)))
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ─────────────────────────────────────────  (T-New)
    Γ ⊢ (ClassName e₁ ... eₙ) : ClassName
```

The order of constructor arguments matches the order of field definitions in the class body. All fields must be provided; there is no partial initialization.

For a record class, the typing rule is identical — record classes are syntactic sugar over classes, and the constructor is auto-generated with the same field order:

```
    Σ(R) is a record with fields (f₁ : τ₁, ..., fₙ : τₙ)
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ─────────────────────────────────────────  (T-Record-New)
    Γ ⊢ (R e₁ ... eₙ) : R
```

====== Field and Property Access

```
    Γ ⊢ e_obj : ClassName
    ClassName has field f : τ
  ───────────────────────────────  (T-Field-Ref)
    Γ ⊢ (ref e_obj 'f) : τ

    Γ ⊢ e_obj : ClassName
    ClassName has field f : τ
  ───────────────────────────────  (T-Field-Direct)
    Γ ⊢ (field e_obj 'f) : τ
```

`ref` dispatches through getter/setter methods when defined; `field` bypasses accessors and accesses the storage slot directly.
Both are subject to accessibility checks (`:public`, `:internal`, `:class-internal`, `:private`).

Dot-notation sugar:

```
    Γ ⊢ e_obj : ClassName    ClassName has field f : τ
  ──────────────────────────────────────────────────────  (T-Dot)
    Γ ⊢ e_obj.f : τ
    (desugared to (ref e_obj 'f))
```

====== Method Access 方法访问

```
    Γ ⊢ e_obj : τ_obj
    τ_obj has method m : (-> (τ_self τ₁ ... τₙ) τ_ret) in its method table
  ──────────────────────────────────────────────────────────────────  (T-Method-Call)
    Γ ⊢ (@{m e_obj} e₁ ... eₙ) : τ_ret

    Γ ⊢ e_obj : τ_obj
    τ_obj has method m : (-> (τ_self τ₁ ... τₙ) τ_ret) via trait T
  ──────────────────────────────────────────────────────────────────  (T-Trait-Method-Call)
    Γ ⊢ (@{m e_obj} e₁ ... eₙ) : τ_ret
    (dispatch through T's vtable when e_obj : (dyn T))
```

====== Trait Object (Dynamic Dispatch)

```
    Δ ⊢ τ implements T
  ──────────────────────────  (T-Coerce-Dyn)
    Γ ⊢ (e :> (dyn T)) : (dyn T)    when Γ ⊢ e : τ

    Γ ⊢ e : (dyn T)    T has method m : (-> (Self τ₁ ... τₙ) τ_ret)
  ─────────────────────────────────────────────────────────────────  (T-Dyn-Call)
    Γ ⊢ (@{m e} e₁ ... eₙ) : τ_ret
```

The coercion `e :> (dyn T)` is explicit — there is no implicit upcast from a concrete type to a trait object.

====== Pattern Matching 模式匹配

```
    Γ ⊢ e_scrutinee : τ_scrut
    For each clause i = 1...n:
      Γ ⊢ pᵢ : τ_scrut ⇒ Γᵢ
      Γ, Γᵢ ⊢ e_bodyᵢ : τ
  ───────────────────────────────────────────────  (T-Match)
    Γ ⊢ (match e_scrutinee (p₁ e_body₁) ... (pₙ e_bodyₙ)) : τ
```

The compiler verifies exhaustiveness: for sealed types, all constructors must be covered (either explicitly or via a wildcard). For non-sealed types, a wildcard or variable pattern must be present.

```
    Γ ⊢ e_scrutinee : τ_scrut
    Γ ⊢ p : τ_scrut ⇒ Γ₁
    Γ, Γ₁ ⊢ e_then : τ_res     Γ ⊢ e_else : τ_res
  ─────────────────────────────────────────────────  (T-Try)
    Γ ⊢ (try p e_scrutinee e_then e_else) : τ_res
```

====== Loop Expressions 循环表达式

```
    Γ ⊢ e_body : Unit
  ────────────────────  (T-Loop)
    Γ ⊢ (loop e_body) : Empty

    Γ ⊢ e_cond : Boolean    Γ ⊢ e_body : Unit
  ────────────────────────────────────────────  (T-While)
    Γ ⊢ (while e_cond e_body) : Unit

    Γ, name : (-> (τ₁ ... τₙ) τ_loop) ⊢ e_body : τ_loop
  ──────────────────────────────────────────────────────  (T-For)
    Γ ⊢ (for name ((x₁ τ₁) ... (xₙ τₙ)) e_body) : τ_loop

    Γ ⊢ e_coll : (Collection τ_elem)    Γ, x : τ_elem ⊢ e_body : Unit
  ──────────────────────────────────────────────────────────────────  (T-Foreach)
    Γ ⊢ (foreach x e_coll e_body) : Unit
```

`loop` has type `Empty` because an infinite loop (with no `:break`) never completes normally.
`for` is syntactic sugar for a named-let with tail-call optimization.

====== Exception Handling 异常处理

```
    Γ ⊢ e_body : τ ! {Exception}
    For each handler i = 1...n:
      ExcTypeᵢ implements Exception
      Γ, eᵢ : ExcTypeᵢ ⊢ e_handlerᵢ : τ
  ─────────────────────────────────────────────  (T-Guard)
    Γ ⊢ (guard ((ExcType₁ e₁) e_handler₁) ... e_body) : τ

    Γ ⊢ e_exc : ExcType    ExcType implements Exception
  ──────────────────────────────────────────────────────  (T-Raise)
    Γ ⊢ (raise e_exc) : Empty ! {Exception}
```

`raise` has return type `Empty` (it never returns normally), allowing it to be used in any typed context.

```
    Γ ⊢ e_body : τ    Γ ⊢ e_cleanup : Unit
  ──────────────────────────────────────────  (T-Unwind-Protect)
    Γ ⊢ (unwind-protect e_body e_cleanup) : τ
    (e_cleanup runs regardless of how e_body exits)
```

====== Continuation Expressions 续体表达式

```
    Γ, k : (Continuation τ) ⊢ e_body : τ
  ─────────────────────────────────────────  (T-CallCC)
    Γ ⊢ (call/cc (lambda (k) e_body)) : τ

    Γ ⊢ e_body : τ
  ───────────────────────────  (T-Reset)
    Γ ⊢ (reset e_body) : τ

    Γ, k : (DelimitedContinuation τ_shift τ_reset) ⊢ e_body : τ_reset
  ──────────────────────────────────────────────────────────────────  (T-Shift)
    Γ ⊢ (shift k e_body) : τ_reset
    where τ_reset is the type of the innermost enclosing reset
```

====== Macro Expansion 宏展开

Macros operate on syntax objects at compile time.
The type checker verifies the result of macro expansion, not the macro invocation directly:

```
    macro M expands (e₁ ... eₙ) to e_expanded
    Γ ⊢ e_expanded : τ
  ────────────────────────────  (T-Macro)
    Γ ⊢ (macro! M e₁ ... eₙ) : τ
```

If the expanded expression is ill-typed, the compiler reports the error at the macro call site, including the macro expansion trace.

====== Compile-Time Expressions 编译时表达式

Expressions annotated with `#:compile-time` are evaluated during compilation and must not depend on runtime values:

```
    Γ ⊢ e : τ    e is pure (no runtime effects)
  ──────────────────────────────────────────────  (T-Comptime)
    Γ ⊢ (#:compile-time e) : τ
    (e is evaluated at compile time; its value replaces the expression)
```

===== Pattern Typing 模式的类型推导

Patterns are typed against a scrutinee type and produce a typing context of variable bindings.

```
  ────────────────────  (P-Wildcard)
    Γ ⊢ _ : τ ⇒ ∅

    x ∉ dom(Γ)
  ────────────────────  (P-Var)
    Γ ⊢ x : τ ⇒ (x : τ)

    lit has type τ_lit    Γ ⊢ τ_lit ≡ τ
  ───────────────────────────────────────  (P-Lit)
    Γ ⊢ lit : τ ⇒ ∅

    Γ ⊢ p₁ : τ₁ ⇒ Γ₁    Γ ⊢ p₂ : τ₂ ⇒ Γ₂
    dom(Γ₁) ∩ dom(Γ₂) = ∅
  ───────────────────────────────────────────  (P-Cons)
    Γ ⊢ (cons p₁ p₂) : (Pair τ₁ τ₂) ⇒ Γ₁ ∪ Γ₂

    For each i = 1...n:
      Γ ⊢ pᵢ : τᵢ ⇒ Γᵢ
    dom(Γᵢ) pairwise disjoint
  ───────────────────────────────────────────  (P-Tuple)
    Γ ⊢ <p₁ ... pₙ> : (Tuple τ₁ ... τₙ) ⇒ Γ₁ ∪ ... ∪ Γₙ

    For each i = 1...n:
      Γ ⊢ pᵢ : τ ⇒ Γᵢ
    dom(Γᵢ) pairwise disjoint
  ──────────────────────────────────────  (P-Vector)
    Γ ⊢ [p₁ ... pₙ] : (Vector τ n) ⇒ Γ₁ ∪ ... ∪ Γₙ

    Γ ⊢ p : τ_declared ⇒ Γ₁    Γ ⊢ τ ≡ τ_declared
  ─────────────────────────────────────────────────  (P-Typed)
    Γ ⊢ (p : τ_declared) : τ_declared ⇒ Γ₁

    Γ ⊢ p : τ ⇒ Γ₁    Γ, Γ₁ ⊢ e_guard : Boolean
  ────────────────────────────────────────────────  (P-Guard)
    Γ ⊢ (p #:when e_guard) : τ ⇒ Γ₁

    Γ ⊢ p₁ : τ ⇒ Γ₁    Γ ⊢ p₂ : τ ⇒ Γ₂
    dom(Γ₁) = dom(Γ₂)    (same set of bound variables)
  ─────────────────────────────────────────  (P-Or)
    Γ ⊢ (or p₁ p₂) : τ ⇒ Γ₁
    (Γ₁ and Γ₂ must agree on types for each variable)

    Γ ⊢ p : τ ⇒ Γ₁
  ────────────────────────────  (P-As)
    Γ ⊢ (p #:as x) : τ ⇒ Γ₁, x : τ
```

===== Subtyping and Coercion 子类型与强制转换

Lilies has a Hindley-Milner type system without general subtyping, with one exception:

```
  ──────────────  (S-Empty)
    Empty ≤ τ    for any type τ

  ───────────  (S-Refl)
    τ ≤ τ
```

The `Empty` type (bottom type) represents computations that never produce a value (infinite loops, panics, `raise`, `unreachable`). It can be used in any context expecting any type.

No other implicit subtyping relation exists. In particular:
- There is no implicit upcast from a concrete type to a trait — the coercion `e :> (dyn T)` must be explicit.
- There is no numeric widening (`Int 32` to `Int 64`, `Int` to `Integer`, etc.) — these require explicit conversion.
- There is no subtyping between classes, records, or sealed class variants.

====== Explicit Coercion

The type system supports the following explicit coercions:

```
    Γ ⊢ e : τ     Δ ⊢ τ implements T
  ───────────────────────────────────  (T-Coerce-Dyn)
    Γ ⊢ (e :> (dyn T)) : (dyn T)

    Γ ⊢ e : τ₁    Γ ⊢ τ₁ ≡ τ₂
  ────────────────────────────  (T-Coerce-Eq)
    Γ ⊢ (e :> τ₂) : τ₂
```

===== Trait Resolution 特征决议

Trait resolution determines whether a type implements a given trait.

```
    (implement τ (T)) is declared in scope
  ────────────────────────────────────────  (TR-Direct)
    Δ ⊢ τ implements T

    (implement τ (T₁ ... Tₙ)) is declared in scope
  ────────────────────────────────────────────────  (TR-Multiple)
    Δ ⊢ τ implements Tᵢ    for each i

    Δ ⊢ τ implements T
    T #:requires (U₁ ... Uₙ)
  ───────────────────────────────  (TR-Requires)
    Δ ⊢ τ implements Uᵢ    for each i

    τ has type parameters α̅
    (implement (C α̅) (T)) is declared    [α̅ ↦ τ̅]
  ────────────────────────────────────────────────  (TR-Generic)
    Δ ⊢ (C τ̅) implements T

    Δ ⊢ τ implements Container
    Container has associated type Element := τ_elt
  ──────────────────────────────────────────────  (TR-Associated)
    (Container.Element)[τ ↦ Element] is τ_elt
```

Trait requirements form a directed acyclic graph — circular requirements are rejected at compile time.
When a type implements multiple traits with conflicting methods, the programmer must provide an explicit disambiguation via `shadow`; otherwise the conflict is a compile-time error.

===== Generic Type Instantiation 泛型实例化

```
    Σ(τ_gen) = type parameters (α₁ ... αₙ)
    Γ ⊢ τ₁    ...    Γ ⊢ τₙ   (n type arguments)
  ────────────────────────────────────────────  (T-Gen-Inst)
    Γ ⊢ (τ_gen τ₁ ... τₙ) : type

    τ_gen has parameter α with bound T
    Γ ⊢ τ_arg    Δ ⊢ τ_arg implements T
  ─────────────────────────────────────────  (T-Gen-Bound-Check)
    (τ_gen τ_arg) is well-formed
    (bound check: τ_arg must satisfy all trait bounds on α)
```

Monomorphization produces a specialized copy of the generic code for each unique set of type arguments at compile time. The type checker verifies bounds before monomorphization.

===== Type Inference 类型推断

Type inference in Lilies follows the Hindley-Milner algorithm W, extended with:
- Trait constraints (similar to qualified types in Haskell)
- Row polymorphism for field access (the set of accessible fields is inferred from usage)
- Let-polymorphism (generalization at `define` and `let` bindings)

====== Generalization and Instantiation

```
    Γ ⊢ e : τ     α̅ = ftv(τ) \ ftv(Γ)
  ──────────────────────────────────────  (Gen)
    Γ ⊢ e : ∀α̅. τ
    (generalize over type variables not free in Γ)

    Γ(x) = ∀α̅. τ     β̅ fresh
  ────────────────────────────  (Inst)
    Γ ⊢ x : [α̅ ↦ β̅] τ
    (instantiate polymorphic scheme at each use site)
```

Generalization occurs at `define` and `let` bindings, giving them polymorphic types. Lambda-bound variables are not generalized (they have monomorphic types).

====== Type Annotations

```
    Γ ⊢ e : τ_inferred    Γ ⊢ τ_declared
    unify(τ_inferred, τ_declared) = success
  ──────────────────────────────────────────  (Ann)
    Γ ⊢ (e : τ_declared) : τ_declared

    unify(τ_inferred, τ_declared) = failure
  ──────────────────────────────────────────
    Type error: expected τ_declared, found τ_inferred
```

Type annotations constrain inference. When an annotation is present, the inferred type must be unifiable with the declared type.

====== Unification

The unification algorithm handles:

- **Type variables**: `unify(α, τ)` = `[α ↦ τ]` (occurs check enforced).
- **Type constructors**: `unify((Pair τ₁ τ₂), (Pair σ₁ σ₂))` = `unify(τ₁, σ₁) ∪ unify(τ₂, σ₂)`.
- **Function types**: structural unification of parameter lists and return types.
- **Trait objects**: `unify((dyn T), (dyn U))` succeeds only if `T = U`; no implicit subtyping.
- **Empty type**: `unify(Empty, τ)` always succeeds (Empty is the bottom type and unifies with everything).

===== Effect Typing 效应类型

Functions that perform effects carry effect information in the type system through the `! E` annotation in the judgment form. Effect checking is performed after type checking (the types are already known).

```
    effect E declares operation op : (-> (τ₁ ... τₙ) τ_ret)
    Γ ⊢ e₁ : τ₁    ...    Γ ⊢ eₙ : τₙ
  ────────────────────────────────────────────  (T-Perform)
    Γ ⊢ (perform E:op e₁ ... eₙ) : τ_ret ! {E}

    Γ ⊢ e_body : τ ! {E} ∪ F
    handler_h covers effect E with resume type τ
  ────────────────────────────────────────────────  (T-Handle)
    Γ ⊢ (handle (E) #:handler handler_h e_body) : τ ! F

    Γ ⊢ e_f : (-> (τ₁ ... τₙ) τ_ret) ! E_f
    Γ ⊢ e₁ : τ₁ ! E₁    ...    Γ ⊢ eₙ : τₙ ! Eₙ
  ────────────────────────────────────────────────  (T-App-Effect)
    Γ ⊢ (e_f e₁ ... eₙ) : τ_ret ! E_f ∪ E₁ ∪ ... ∪ Eₙ
```

Effects are tracked in the function type: `(-> (τ₁ ... τₙ) τ_ret) ! {E₁, E₂}` denotes a function that may perform effects `E₁` and `E₂`.
The `! {}` annotation is omitted for pure functions (the default).

====== `async` / `await` Effect

```
    Γ ⊢ e_body : τ ! {Async}
  ───────────────────────────────────────  (T-Async)
    Γ ⊢ (async lambda (x₁ : τ₁ ...) e_body)
        : (-> (τ₁ ...) (Future τ)) ! {}

    Γ ⊢ e_future : (Future τ)
  ──────────────────────────────  (T-Await)
    Γ ⊢ (await e_future) : τ ! {Async}
```

The `Async` effect is handled by the async runtime; `await` may only appear inside an `async` lambda body.

===== Module Typing 模块类型

A module's type is structurally determined by its exported bindings.

```
    module M exports {x₁ : τ₁, ..., xₙ : τₙ}
  ───────────────────────────────────────────────  (T-Module)
    M : (Module (x₁ : τ₁, ..., xₙ : τₙ))

    Γ ⊢ M : (Module (x₁ : τ₁, ..., xₙ : τₙ))
  ──────────────────────────────────────────────  (T-Module-Access)
    Γ ⊢ M:xᵢ : τᵢ

    (require :module-name) resolves to module M
    M : (Module (x₁ : τ₁, ..., xₙ : τₙ))
  ───────────────────────────────────────────  (T-Require)
    Γ ⊢ (require :module-name) : (Module (x₁ : τ₁, ..., xₙ : τₙ))

    Γ ⊢ M : (Module (x₁ : τ₁, ..., xₙ : τₙ))
    (:ns M) imports all xᵢ : τᵢ into Γ
  ─────────────────────────────────────────  (T-Import-Ns)
    Γ, x₁ : τ₁, ..., xₙ : τₙ for the importing scope
```

Module types are first-class at compile time — a module can be passed as an argument to a compile-time function and its type structure is statically known.

===== Conditional Typing for Type Families 类型族的条件类型推导

Type families allow type-level computation. When a type family is applied, the resulting type is determined by pattern matching on the input types:

```
    type-family F has clause: (pattern τ_pat => τ_body)
    Γ ⊢ τ_arg ≡ τ_pat (under substitution σ)
  ─────────────────────────────────────────────  (T-Type-Family)
    F(τ_arg) ≡ σ(τ_body)
```

If no clause matches, the type-family application is ill-typed. Type families are evaluated at compile time and must be total (cover all possible input patterns) unless annotated with `#:partial`.

=== Value System 值系统

Values of user-defined types are the core data abstraction in Lilies.
Lilies adopts a Hindley-Milner type system without subtyping or inheritance —
polymorphism and code reuse are achieved through traits.

A class defines the structure (fields) of a value, but methods are implemented separately via `implement`.
With traits, it becomes possible to share method implementations across different classes and extend behavior outside the class definition.

A concept of generic function is borrowed from CLOS and it is called `trait` in Lilies.
With traits, user-defined methods can be called in a uniform way as traditional functions.
Another benefit is that trait methods are all statically dispatched by default, making them efficient.

`implement` syntax creates method implementations for a specific class, associating methods with the class's method table.

Concepts for structuring data:
- Fields: named slots associated with a specific class instance.
- Properties: named accessors that expose values through getter/setter methods.

All objects in Lilies are passed by value by default.
To have an object passed by reference, use type wrappers.

Type wrapper can be ownership, garbage collected or reference counted pointer.

This part describes the object system, definition of classes, and their possible literals.

==== Primitive Object 原始对象

Primitive objects in Lilies are built upon primitive types.
Some of primitive objects can be written in literal syntax.

Primitive objects cannot be split into smaller parts.

For which, there are:
- Integer Object
- Float Object
- Character Object
- String Object
- Symbol Object
- Boolean Object
- Pair Object

==== Classes, Fields, Properties & Traits 类, 字段, 属性与特征

Classes are user-defined product types that group named fields together.

A class does not inherit from any other class — there is no class inheritance in Lilies.
Instead, classes can implement traits to provide shared behavior.
Composition over inheritance is the recommended pattern: a class can contain instances of other classes as fields.

Fields are named slots associated with a specific class instance.
Each field has its own name and type.
In class definition, fields are declared with `define` syntax.

Properties are named slots that used for value fetching only.
The method to declare a field as property can be various,
Use setter and getter methods is one of the common way.
However, it is encouraged to manually assign accessibility attributes to fields to control read and write access right for internal, class internal, package internal, and public access levels.

Traits are used to define shared behavior that can be implemented by multiple classes.
Traits can be implemented manually for a class,
and user-defined traits can be used to extend the behavior of a class defined in a library.

===== Definition of Classes 类的定义

Define a new class with `class` syntax.
E.g., to define a new class `Point` with two fields `x` and `y` of type `Integer`:
```lisp
(define Point
  (class
    (define x (constant Integer))
    (define y (constant Integer))))
```
Here, `define` syntax used to declare Point as the class we defined using `class` syntax.
And `define` syntax inside the class body used to declare fields `x` and `y` of type `Integer`.
`#:self this` declares that within the class body, `this` refers to the current instance of the class.
Symbols starts with `#:` are keywords annotations, for which pass some attributes when function or macro application.
Another special keyword annotations are start with `#&`, for passing some attributes when function or macro definition.
Most generic annotations are written as `#@[attributes]`, and is assigned to expressions.
Annotations are described in detail in the Annotations and Annotation processing section.

Full syntax of class definition is described as:
```lisp
class-definition ::=
'(' 'class' { <fields> } ')'

<fields>         =>
'(' ':fields' { <deffield> } ')'

<deffield>       =>
'(' 'define' <name> [ '#:type' ] <type> [ <init> ] ')'
```

The class body contains field definitions using `define`.
Self clause declares the symbol that refers to the current instance of the class within the class body (via the `#:self` annotation).
Type clause declares the type of the class being defined.

With annotations, the accessibility of fields can be controlled:
E.g.,
```lisp
(define Point
  (class
    #@[accessibility x (read :public) (write :private)]
    #@[accessibility y (read :public) (write :private)]
    (define x (constant Integer))
    (define y (constant Integer))))
```

To define a field to be variable, wrap the type with `variable`.
Otherwise, if the type is wrapped with `constant`, the field is not assignable after object creation.
All assignment traits for that field will be dropped.

Define syntax varies depending on the context in which it appears; the `define` used within a class body to declare fields is not the same form as top-level `define`.
More precisely, only `define` can directly add a new binding to the current scope; `lambda` creates a new scope whose formal parameters are bound within that scope, without mutating the enclosing scope.

Type families allow types to be computed from other types at compile time.
A type family is declared with `type-family` and defines a mapping from type parameters to concrete types:
```lisp
(type-family ElementType
  ((Vector T) => T)
  ((List   T) => T)
  ((Array  T) => T))
```
Type families enable type-level programming, where types can be computed based on other types,
similar to associated types in Rust or type families in Haskell.

Classes in Lilies are first-class values at compile time: a class can be passed as an argument to
a compile-time function, stored in a compile-time data structure, and used to construct instances.
This enables patterns like compile-time factories, serialization codecs generated from class definitions,
and ORM-style mappings.

===== Definition of Traits 特征的定义

Traits in Lilies follow a Rust-like dispatch model:
- **Static dispatch** is the default. When a generic function is called with concrete types known at compile time,
  the compiler monomorphizes the code, producing a specialized copy for those types with full inlining and optimization.
- **Dynamic dispatch** is opt-in. A trait object type, written `(dyn TraitName)`, erases the concrete type
  and dispatches through a vtable at runtime. Trait objects are used when the concrete type cannot be determined
  at compile time (e.g., heterogeneous collections).
```lisp
;; Static dispatch (default): compiler monomorphizes for Integer
(define add-one (lambda ((x Integer)) #:returns (Integer) (+ x 1)))

;; Dynamic dispatch via trait object
(define draw-all (lambda ((shapes (List (dyn Drawable))))
  #:returns (None)
  (foreach shape shapes
    (draw shape))))
```

A trait can require its implementing type (`Self`) to also implement other traits,
just as Haskell type classes support superclass constraints (`class Eq a => Ord a`).
This is specified with the `#:requires` annotation in the trait definition:
```lisp
(define Ord
  (trait
    #:requires (Eq Self)   ;; Self must implement Eq
    (define compare (function (Self Self) #:returns (Ordering)))))
```
The compiler enforces that any type implementing `Ord` must also implement `Eq`.
Trait bounds on `Self` form a directed acyclic graph; circular requirements are rejected at compile time.

Traits can also specify associated types and constraints, similar to Haskell type classes:
```lisp
(define Container
  (trait
    #:associated-type Element
    (define insert (function (Self (Self:Element)) #:returns (Self)))
    (define lookup (function (Self Integer) #:returns (Optional (Self:Element))))))
```

Concepts are named sets of constraints that can be used to describe requirements on type parameters
more concisely than listing individual traits. A concept combines multiple trait bounds and
associated type constraints:
```lisp
(concept Sortable
  #:requires (Ord (Element T))
  #:where (T implements Container))
```
E.g., to define a new trait `Drawable` with a method `draw`:
```lisp
(define Drawable
  (trait
    #:self self
    (define draw (function (self)))))
```
===== Method and Trait Implementation 方法与特征实现

Both Methods and Traits are implemented with `implement` syntax.

`implement` opens the namespace of a class, and then methods defined within the body are assigned to the class method table.
Furthermore, trait implementations can open the namespace of an object, and then anything inside will extend the object's behavior.

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

===== Method Dispatch 方法分派

Lilies adopts a Rust-like dispatch model: static dispatch is the default, and dynamic dispatch is opt-in.

====== Static Dispatch (default) 静态分派

When the concrete type is known at compile time, method calls are resolved statically and monomorphized — the compiler generates a direct call to the method implementation. This is the default and incurs no runtime overhead:
```lisp
;; Static dispatch: the compiler knows p is Point, calls Point's draw directly
(define p (Point 3 4))
(draw p)
```

====== Dynamic Dispatch (opt-in) 动态分派

Dynamic dispatch is used when the concrete type cannot be determined at compile time.
A trait object type `(dyn TraitName)` erases the concrete type and dispatches through a vtable:
```lisp
;; Dynamic dispatch via trait object
(define draw-all (lambda ((shapes (List (dyn Drawable))))
  #:returns (None)
  (foreach shape shapes
    (draw shape))))  ;; dispatch through Drawable's vtable at runtime
```

The `invoke` primitive explicitly requests dynamic dispatch for a specific object and method:
```lisp
(invoke object 'method-name)
;; => a procedure that, when called, dispatches through the object's vtable
```

The dispatch protocol for dynamic dispatch is:
1. The runtime type of `object` is retrieved.
2. The vtable of that type is searched for `'method-name`.
3. If found, the corresponding implementation is returned and called.
4. If not found, the search proceeds to implemented traits (in order of implementation).
5. If still not found, a `MethodNotFound` condition is raised.

For cases where the type is known at compile time but the programmer wants to explicitly select a specific trait's method implementation, the `method` form is used:
```lisp
(method ClassName 'method-name)
;; => the method implementation for ClassName, resolved at compile time
```

====== Method Access 方法调用语法糖

Lilies provides syntactic sugar for method calls using the `@{}` notation:
```lisp
(@{method-name object} arg1 arg2)
;; desugars to:
((invoke object 'method-name) object arg1 arg2)
```

For chained access, the `->` operator threads an object through a series of operations:
```lisp
(-> object
    (@{method1} arg)
    (@{method2} arg2))
;; desugars to:
(@{method2 (@{method1 object} arg)} arg2)
```

===== Chain Call & Chain Methods 链式调用与链式方法

====== Syntax Sugar for Chain Methods Definition 链式方法定义的语法糖

Chain methods return `Self` (the type of the receiver), enabling fluent method chaining.
A chain method is defined by annotating the return type with `#:returns (Self)`:

```lisp
(implement Point ()
  #:self self
  (define set-x
    (lambda (self (new-x Integer))
      #:returns (Self)
      (Point new-x (field self 'y))))
  (define set-y
    (lambda (self (new-y Integer))
      #:returns (Self)
      (Point (field self 'x) new-y))))
```

Chain methods can then be called in sequence using the `->` threading macro:
```lisp
(-> point (@{set-x 10}) (@{set-y 20}))
```

Chain methods are statically dispatched when the concrete type is known,
and dynamically dispatched when called through a trait reference.

===== Field & Property Access 字段与属性访问

Field access in Lilies uses the `ref` form, which retrieves the value of a named slot from an object:
```lisp
(ref object 'field-name)
;; retrieves the value of field-name from object
```

For mutable access, `ref` can be used in assignment contexts:
```lisp
(set! (ref object 'field-name) new-value)
```

Fields declared with accessibility annotations enforce access control:
- `:public` — accessible from any code.
- `:internal` — accessible only within the same module.
- `:class-internal` — accessible only within the defining class and code within the same module that operates on the same type.
- `:private` — accessible only within the defining class.

Properties are fields accessed through getter and setter methods.
When a field has defined getters/setters, `ref` automatically dispatches through them rather than accessing the storage directly.
This allows classes to change internal representation without breaking callers.

Dot notation is available as syntactic sugar:
```lisp
object.field-name
;; desugars to:
(ref object 'field-name)
```

===== `field` Primitive `field` 原语

The `field` form is the low-level primitive for reading a named field from an object at runtime.
Unlike `ref`, which respects property accessors (getter/setter methods) and accessibility annotations,
`field` bypasses accessors and accesses the underlying storage directly:
```lisp
(field self 'x)
;; retrieves the raw storage slot for field x, bypassing any getter method
```

When a class defines getter/setter methods for a field, `ref` dispatches through those methods,
while `field` always performs a direct slot access. This makes `field` useful in contexts where
the raw storage must be accessed without triggering side effects (e.g., within the implementation
of getter/setter methods themselves, or in low-level serialization code).

`field` respects accessibility annotations (`:public`, `:internal`, `:class-internal`, `:private`)
and is subject to the same access-control checks as `ref`.

`field` can be combined with `set!` for direct field mutation, bypassing setter methods:
```lisp
(set! (field self 'x) new-value)
```

===== Traits Shadowing 特征遮蔽

When a class implements multiple traits that define methods with the same name, a name conflict arises.
Lilies resolves trait method conflicts through explicit disambiguation rather than implicit shadowing.

By default, if two implemented traits provide a method with the same name and signature,
the compiler emits an error requiring the programmer to disambiguate.

Disambiguation is done in the `implement` body by providing an explicit disambiguation:
```lisp
(implement MyClass (TraitA TraitB)
  #:self self
  (define conflict-method
    ;; explicitly choose TraitB's implementation
    (shadow (method TraitA 'conflict-method)
            (method TraitB 'conflict-method))))
```

The `shadow` form declares a precedence order: the first argument is shadowed by the second.
When calling `conflict-method` on `MyClass`, `TraitB`'s implementation is used,
while `TraitA`'s implementation remains accessible through a qualified call:
```lisp
((method TraitA 'conflict-method) my-instance args...)
```

If a class defines its own method with the same name, it automatically shadows any trait-provided implementations.

===== Predefined Traits 预定义特征

Assignment:
- Clone (Deep clone all fields)
- Move (Move the ownership)
- Reference (Borrow the value)

Comparison:
- Strict Equal (Compare whether two value have same type and value in bitwise)
- Value Equal (Compare whether two value is same logically, in this case, two children that treat as same parent type may be equal)
- Identity Equal (Compare whether two bindings reference the same object)

=== Generic Programming 泛型编程

Generic programming in Lilies is achieved through compile-time type computation, where generic code
is expanded and specialized at compile time rather than relying on runtime type erasure.
This section ties together the type system, object system, and metaprogramming facilities
to describe how generic programming works in practice.

==== Type-Level Programming

Type families (described in the Type System chapter) enable type-level computation.
Combined with compile-time evaluation, Lilies can express complex type-level transformations:
```lisp
(type-family MapType
  ((List T) => (List (Option T)))
  ((Vector T N) => (Vector (Option T) N)))
```

Type-level programming in Lilies is not a separate language — it uses the same expression language
as runtime code, evaluated at compile time. This unification means type-level functions
can reuse ordinary functions and vice versa.

==== Generic Code Generation

When the compiler encounters a generic function applied to concrete types, it monomorphizes:
it generates a specialized copy of the function for those concrete type arguments.
Monomorphization enables full optimization of generic code (inlining, constant folding)
and eliminates any runtime overhead from generics.

For cases where monomorphization would produce excessive code size,
the compiler can use a hybrid approach with a universal representation fallback,
selected via the `#:generic-strategy` annotation.

==== Constrained Generics

Type parameters can be constrained by traits:
```lisp
(lambda ((x T) (y T))
  #:where (T implements Ord)
  (if (< x y) x y))
```

The `#:where` clause specifies constraints on type parameters.
The compiler checks that all concrete type arguments satisfy these constraints at monomorphization time.

=== Expression

An expression is the fundamental unit of computation in Lilies.
Every construct in Lilies is an expression that evaluates to a value and has a type.
There are no statements — even control flow constructs, definitions, and module declarations are expressions.

The general form of an expression is a list `(operator operand ...)` where the first element
(the operator position) determines how the expression is evaluated.
The operator may be:
- A special form keyword (e.g., `define`, `lambda`, `if`, `let`), which follows custom evaluation rules.
- A macro name, which triggers compile-time expansion before evaluation.
- A procedure value (function or closure), which causes function application.
- A symbol bound to a procedure, which is resolved and then applied.

Expressions can also be self-evaluating literals — forms that evaluate to themselves without any further computation:
- Numbers: `42`, `3.14`, `#x2A`
- Booleans: `#True`, `#False`
- Characters: `#\a`, `#\space`
- Strings: `"hello"`
- Vectors: `[1 2 3]`
- Tuples: `<1 "a" #True>`

Symbols and pairs are not self-evaluating. As in Common Lisp and Scheme, an unquoted symbol evaluates to the value bound to that name in the current scope. To obtain a symbol or pair as a literal value, the `quote` special form (abbreviated `'`) is used:
- `'foo` is shorthand for `(quote foo)`, which evaluates to the symbol `foo`.
- `'(first . second)` is shorthand for `(quote (first . second))`, which evaluates to a pair.

Thus `'foo` is not a self-evaluating literal; it is a quoted expression — a special form whose evaluation rule is to return its argument unevaluated.

The value of a sequence (block) is the value of its last expression.
All preceding expressions are evaluated for their side effects.

==== Expression Evaluation Order

By default, Lilies uses eager evaluation with left-to-right evaluation order within a sequence.
Arguments to a function are evaluated before the function is called, in left-to-right order.
Lazy evaluation can be requested for specific parameters using the `#:naming` calling convention.

==== Expression Types

Every expression has a statically known type. The type of an expression is determined by:
1. For literals: the type is the literal's inherent type.
2. For variable references: the declared or inferred type of the variable.
3. For function applications: the return type of the function, with type parameters substituted.
4. For special forms: defined by the semantics of the special form.
5. For macros: the type of the expanded expression.

The compiler checks that every expression's type is consistent with the context in which it appears.

=== Apply & Evaluation

Function application in Lilies follows a uniform protocol: the operator and operands are evaluated,
then the operator is applied to the operands. The application mechanism depends on what the operator evaluates to.

==== Evaluation Protocol

1. The operator expression is evaluated.
2. The operand expressions are evaluated left-to-right (unless `#:naming` defers evaluation).
3. The resulting operator value is applied to the resulting operand values.

If the operator is a procedure (lambda), the application proceeds by:
1. Matching actual arguments to formal parameters — by position (for positional parameter lists) or by name (for named parameter lists).
2. Creating a new lexical environment binding parameters to the argument values, with the argument-passing convention (borrow, move, or clone) applied as specified at the call site.
3. Evaluating the procedure body in this new environment.
4. Returning the result(s) to the caller by ownership transfer (move).

==== Calling Conventions

Lilies follows a Rust-like argument-passing model. Calling conventions are not specified in the parameter list. Instead, how an argument is passed is determined at the call site:

- **Borrow** (default): The argument is evaluated and a shared reference is passed. The callee can read but not mutate the borrowed value. The caller retains ownership; the borrow lasts for the call duration. This is the default for all arguments and corresponds to Rust's `&` borrow.
  ```lisp
  (fun a b)   ;; a and b are both borrowed
  ```

- **Move** (explicit): Ownership of the argument is transferred into the callee. After the call, the caller can no longer access the moved value. This is the most efficient convention for large or non-copyable values and corresponds to Rust's move semantics.
  ```lisp
  (fun (move a) b)   ;; a is moved, b is borrowed
  ```

- **Clone** (explicit): The argument is deep-copied and the copy is passed. The callee owns the copy; the caller retains the original. This is used when the callee needs ownership but the caller must keep the value — analogous to `.clone()` in Rust.
  ```lisp
  (fun (clone a) b)   ;; a is deep-copied, b is borrowed
  ```

- **Lazy / Call-by-Name** (`#:naming`): The argument is not evaluated at the call site. Instead, a thunk (a closure of zero arguments) is passed, and the argument is evaluated each time the parameter is referenced in the function body. This supports defining control structures and short-circuit evaluation.
  ```lisp
  (fun #:naming a b)   ;; a is passed lazily, b is borrowed
  ```

There is no implicit deep-copy: if a function needs an owned copy of a borrowed argument, it must clone explicitly within its body.

The call-site modifiers `(move x)` and `(clone x)` control how an argument is passed to a function — analogous to Rust's argument passing.
These are distinct from `#:move` on a `lambda` expression, which controls how the closure captures variables from its enclosing scope (see Closure Type).
In Rust terms: `(move x)` is argument-passing move, while `(lambda #:move ...)` is `move |...| { ... }` closure capture.

==== Multiple Return Values

A function may return multiple values. The caller can receive them by destructuring:
```lisp
(let:rec ((values a b) (divmod x y))
  ;; a is quotient, b is remainder
  ...)
```
If a multi-value result is used in a single-value context, only the first value is retained.



=== Variable, Binding & Reference

- Variable, Definition & Binding
  - Dynamic Scope
  - Lexical Scope
  - `define`
    `define` binds a name to a value in the current scope: `(define name value)`.
    An optional type annotation follows the name, matching the lambda parameter syntax: `(define (name Type) value)`.
    An optional `#:mut` indicates the binding is mutable; otherwise the binding is immutable and assignment traits are dropped.
    In some environments such as a class body, `define` may have a different syntax (see Definition of Classes).

    The semantics of `define` vary by context:
    - **Top-level**: `define` is ordered and carries sequential side effects — bindings created by `define` are visible to subsequent expressions in the same top-level scope. The top-level is executed in order at program startup (or when a script file is run).
    - **`lambda` body**: `define` within a `lambda` body likewise has sequential side effects — later expressions in the same body see earlier `define` bindings.
    - **Module body**: `define` within a module body does *not* carry sequential side effects, because a module is a namespace construct that is compiled as a unit rather than executed in order. All definitions within a module are mutually visible and are resolved at compile time; the order of `define` forms in a module does not affect visibility. Module-level `define` does not imply runtime initialization — modules are not "executed" in the sense that top-level code or lambda bodies are.
  - `let` & `let:` family
    - `let`: `let` in scheme, which creates a new scope and binds variables in that scope.
    - `let:fwd`: `let*` in scheme, which creates a new scope and binds variables in that scope, but the bindings are visible to the rest of the body. Sequential bindings are supported, which means that the value of a variable can be used in the initialization of another variable defined later in the same `let:fwd` expression.
    - `let:rec`: `letrec` in scheme, which creates a new scope and binds variables in that scope, but the bindings are visible to the rest of the body. Recursive bindings are supported, which means that the value of a variable can be used in the initialization of itself or another variable defined later in the same `let:rec` expression.
    - `let:seq:rec`: `letrec*` in scheme, which creates a new scope and binds variables in that scope, but the bindings are visible to the rest of the body. Sequential and recursive bindings are supported, which means that the value of a variable can be used in the initialization of itself or another variable defined later in the same `let:seq:rec` expression.
  - Dynamic In Lexical Scope:
    Lilies uses lexical scoping by default, but dynamic scoping can be introduced for specific variables
    using the `dynamic` form. A dynamically scoped variable looks up its value in the dynamic extent
    (the call chain) rather than the lexical environment:
    ```lisp
    (define *current-output-port*
      (dynamic (make-stdout-port)))
    ```
    Dynamic variables are conventionally named with surrounding asterisks `*like-this*`.
    The `dynamic-let` form temporarily rebinds a dynamic variable for the dynamic extent of its body:
    ```lisp
    (dynamic-let ((*current-output-port* (make-file-port "output.txt")))
      (display "This goes to the file"))
    ```
    Dynamic binding is implemented via shallow binding with a thread-local binding stack,
    ensuring efficient access and thread safety.
  - Form:
    A form is any syntactic unit that can be evaluated. In Lilies, forms are classified as:
    - Self-evaluating forms: literals that evaluate to themselves.
    - Symbol forms: variable references that evaluate to the bound value.
    - List forms: compound expressions `(operator ...operands)`.
    - Special forms: built-in constructs with custom evaluation rules (`define`, `lambda`, `if`, `let`, etc.).
    - Macro forms: expressions expanded at compile time before evaluation.
    The term "form" is often used interchangeably with "expression" in Lisp tradition,
    though "form" emphasizes the syntactic structure while "expression" emphasizes the evaluable nature.
- Assignment

Assignment is a trait that must be implemented by any type that supports assignment operation.
There are three types of assignment:
- Move: move the ownership
- Clone: clone the object
- Reference: assign by reference

=== Built-in Data Types and Literals 内建数据类型与字面量

==== Primitive Types and Literals 基本类型与字面量

- Integer Object
  - `[1-9][0-9]*`
  - `0b[01]+`
  - `0o[0-7]+`
  - `0x[0-9a-fA-F]+`
- Float Object
  - `[0-9]+\.[0-9]*([eE][+-]?[0-9]+)?`
  - `[0-9]+[eE][+-]?[0-9]+`
- Character Object
  - `#\description`
  - `#\'character`
  - `#\uXXXX`
- String Object
  - `"string content"`
  - `#f"string content with escapes"`
  - `#b"raw string content"`
  - ```lisp
    #"|
     " string content with newlines
     " Each line begins with a space, which will be removed in the final string
     " Though it is not necessary, it is recommended to have a space before every line
     |#"
    ```
- Symbol Object
  - `'symbol-name`
- Boolean Object
  - `#True`
  - `#False`
- Pair Object
  - `'(first . second)`

Above, quote syntax is used to create literal syntax for symbols and pairs.

==== Vectors(Matrix), Tuples, Arrays, Lists, dictionaries & Index

There are some built-in composite types in Lilies, including:

- Vectors, which is a fixed-size sequence of same-type elements, and can be indexed by integers.
- Tuples, which is a fixed-size sequence of potentially different-type elements, and can be indexed by integers.
- Arrays, which is a variable-size sequence of same-type elements, and can be indexed by integers.
- Lists, which is a variable-size sequence of potentially different-type elements, and can be indexed
- Dictionaries, which is a collection of key-value pairs, and can be indexed by keys.

==== Vector

In Lilies, one-dimension vectors can be written in the form of `[element1 element2 ...]`,
Furthermore, vector type have its own literal syntax rather than regular type application syntax like `(int 8)`,
E.g., a vector of 4 signed 32bit integers can be written as `[(int 32): 4]`, similar to array type in Rust.
Multi-dimensional vectors also exist, and can be written as `[(int 32): 4 4]` for a 4x4 matrix of signed 32bit integers.

To index a vector, use `index`, which accepts a vector and an vector of integers as index, and returns the variable element at the corresponding position.
`(index obj indexs)`.
E.g., to index the element at position (1, 2) in a 4x4 matrix `mat`, we can write `(index mat [1 2])`.

In other case, something like jagged array can be implemented by using vector of vectors, which is also a vector.
However, only vector slice is able to used as type argument for vector without really declare the length of a vector.
It will never behave like a jagged array in C\#.

==== Tuple

Tuple is another fixed-length sequence in Lilies.
Compared to vector, tuple is slightly more flexible.
In practice, multiple return values can be implemented using tuples.

Tuple can be written as `<element1 element2 ...>` in Lilies for short.

Tuple is obviously able to contains another tuple.

Tuple is indexed still by `index`.

==== Array

In contrast to other languages, array in Lilies behaves like `std::vector` in C++ or `ArrayList` in Java,
which is a data type that can contain a variable number of elements of the same type and can be indexed by integers.

==== List

List is a traditional data structure in Lisp dialects, which is a variable-length sequence of potentially different-type elements.
Since the list is a type derived from pairs, determined in compilation time, it is not difficult to check the safety of list operations and optimize the code for list operations.

List, a kind of recursive type, defined in the form of `(cons element list)`, where `cons` is a constructor for pairs, and `element` is the first element of the list, and `list` is the rest of the list, is able to be visited using traditional `car` and `cdr` functions, and furthermore, `index` for `nth` in common lisp.
Operations whose index is known at compile time can be partially evaluated by the compiler (e.g., unrolling a fixed number of `cdr` steps). In the general case, however, indexed access to a linked list is an O(n) traversal, whereas vector indexing is O(1) — this is an inherent algorithmic difference between the two data structures.

==== Dictionary

Dictionary is a collection of key-value pairs,
in common lisp, it is called `associative list`,
while scheme defines it as `hash table`.

In Lilies, dictionary provides a simple way to store and retrieve values based on keys,
a corresponding built-in library for export dictionary and array to json format is also provided.

Similar to classes and other structures that have names associated with fields, dictionary uses `ref` to access the value of a key.

=== Reference

Actually, define something directly to another variable creates a new reference to the same object.
Thus if you'd like to define reference to a variable defined within same scope, or same structures,
just write something like `(define refe var)` and then `refe` is associated with the same object as `var`.

However, sometime we may want to have the variable reference another object as another type,
e.g., access a vector of 32 bit integer as a vector of 8 bit integer.
If create raw pointer, it costs space to store the pointer, and it is not safe to use.
Thus Lilies provides a way to create reference without creating a new variable,
with definition like `(define refe (reference var #:type <type>))`, which creates a new reference to the same object as `var`, but with a different type.

=== Procedure, Function & Method

- Function Call
- Multiple Value for Function Call
- Returning

```lisp
(define foo
  (lambda ((param (Int 8) #:init 0))
    #:returns ()
    '()))
;; param type is `(Int 8)`, signed 8-bit integer. Calling convention is determined at the call site:
;;   (foo x)         — borrow x (default)
;;   (foo (move x))  — move x into param
;;   (foo (clone x)) — deep-copy x into param
(define bar
  (lambda ((param String))
    #:returns ()
    '()))
;; param type is `String`. No deep-copy is implicit — the call site decides.
(define baz
  (lambda ((param (Vector (Int 32) 4)))
    #:returns ()
    '()))
;; param type is `(Vector (Int 32) 4)`, a vector of 4 signed 32-bit integers.

;; `#:returns ()` declares the return-value list — `()` is the empty list.
;; Returned values are moved out (ownership transfer) to the caller.
```


Parameter lists come in exactly one style per procedure — positional and named forms may not be mixed in a single lambda.

**Positional parameters** are specified as a list. Arguments are matched by position:
```lisp
(lambda (x y z) ...)
;; called as: (proc 1 2 3)
```

Each positional parameter may carry an optional type annotation and default value:
```lisp
(lambda ((x Integer) (y String #:init "default")) ...)
```

**Named parameters** use the curly-brace form. Arguments are matched by name at the call site and can be provided in any order:
```lisp
(lambda {x: Integer, y: String, z: Boolean} ...)
;; called as: {proc x: 1, y: "hello", z: #True}
```

**Rest parameters** collect additional arguments. In positional form, the dotted-pair notation `( ... . rest)` gathers remaining positional arguments into a list:
```lisp
(lambda (x y . rest) ...)
;; (proc 1 2 3 4 5) => x=1, y=2, rest='(3 4 5)
```

In named form, the dotted-pair notation `{ ... . rest }` gathers remaining named arguments into a dictionary:
```lisp
(lambda {x: Integer . rest} ...)
;; {proc x: 1, y: "hello", z: #True} => x=1, rest={'y "hello", 'z #True}
```

**Mixing positional and named parameter styles in the same lambda is not permitted.** Choose one style per procedure.

Parameter list of a procedure can also be a pattern, a case expression, or a single symbol.

==== Procedures

To define a procedure, bind a lambda expression to a name.
A lambda expression is composed of a parameter list, an optional returning value list, and a function body.

In the parameter list, each parameter is defined with its name, optional type, and optional initial value.
The calling convention is not specified in the parameter declaration — it is determined at the call site (see Calling Conventions).
If the parameter list is empty, the function takes no parameters.
If the last element of the parameter list is a dotted rest parameter (` . rest`), it collects the remaining arguments into a list (positional) or dictionary (named).
The type for a rest parameter can be inferred from context and need not be explicitly declared.

For each parameter:
- First element is the parameter name (a symbol).
- Then an optional type annotation — the type must be defined before use.
- Last, an optional initial value (`#:init <value>`).

Procedures declare their return types with `#:returns` followed by a return-value list.
Returned values are transferred by ownership move to the caller (Rust-style).
If names are provided in the return list, the return values can be accessed by name within the function body.

For each entry in the return-value list:
- First element is an optional return-value name (a symbol).
- Second element is the type of the returned value.

The body of a lambda expression must be a single expression.

You can exit a function early by invoking the built-in function `:return`, which is only valid within a function body.
It returns the values passed to it as the function's return values.

==== Positional, Named or Rest Parameters

Lilies supports both positional and named parameter styles, but they cannot be mixed in a single lambda.

**Named-parameter call syntax** uses curly braces with the function name immediately after `{`, followed by a space and then comma-separated `key: value` pairs: `{fun key: value, ... . rest}`.
The space after the function name marks the start of the argument list; commas separate individual arguments, matching the dictionary literal syntax.
`. rest` collects remaining named arguments into a dictionary:
```lisp
{fun x: 1, y: 2}              ;; call `fun` with named args x=1, y=2
{fun x: 1, y: 2 . extras}     ;; extras collects additional named args as a dictionary
```

**Positional calls** use the standard parenthesized form:
```lisp
(fun 1 2)                  ;; positional call
(fun 1 2 . extras)         ;; extras collects remaining positional args as a list
```

**Method access shorthand** uses `(@{method obj} arg ...)`:
```lisp
(@{draw shape})            ;; calls method `draw` on `shape`
(@{draw shape} x y)        ;; calls method `draw` on `shape` with args x, y
```

The choice between positional and named style is made at the definition site and must be consistent at the call site.

The `{}` syntax serves two roles, distinguished by context:
- **Named call**: `{` immediately followed by the function name, then a space, then comma-separated `key: value` pairs — e.g., `{fun x: 1, y: 2}`.
- **Named parameter definition**: `{` appears inside a `lambda` form to declare named formal parameters — e.g., `(lambda {x: Integer, y: String} ...)`.
There is no ambiguity because a named call always appears in expression position with the function name directly after `{`, while a named parameter list always appears as the second element of a `lambda` form.

==== Functions

A `lambda` expression, as described in the Procedures section, evaluates to a function value — a closure that captures the lexical scope in which it was defined.
The type of each `lambda` expression is a unique closure type that includes the types of its parameters and return values.
When a `lambda` is bound to a name via `define`, the resulting procedure can be called by that name.

To declare a variable or parameter that holds an arbitrary function, use a function type.
Function types are written with the `(-> ...)` syntax:
```lisp
(-> (Integer String) Boolean)          ;; takes Integer and String (positional), returns Boolean
(-> {x: Integer, y: String} Boolean)   ;; takes named x, y, returns Boolean
```

Every function type implements the `Callable` trait.
The `Callable` trait is the common interface for all callable values — procedures, closures, and continuations.

When the concrete function type is not known at compile time, use a trait object:
```lisp
(define apply-twice
  (lambda ((f (dyn (-> (Integer) Integer))) (x Integer))
    #:returns (Integer)
    (f (f x))))
```
Here `f` is dynamically dispatched through the `Callable` vtable.

=== Conditional & Control Flow

==== Conditionals 条件语句

+ `if`
+ `cond`
+ `case`

+ `switch`

==== Loops 循环语句

Traditional loops provided in Lilies are:
+ `loop`: infinite loop
+ `while`: condition loop
+ `for`: named recursive loop, which similar to named-let in Scheme
+ `foreach`: iterate over each element in a collection

And lisp style loops are also provided:
+ `map`: apply a function to each element in a collection and return a new collection
+ `filter`: filter elements in a collection based on a predicate function and return a new collection
+ `reduce`: reduce a collection to a single value by applying a binary function
+ `fold`: fold a collection to a single value by applying a binary function with an initial value
+ `scan`: scan a collection to produce a new collection by applying a binary function with an initial value

==== Try With Pattern 匹配尝试

Similar to Rust, the Lilies supports tagged union types and pattern matching.
`try` works similar to `if let` in Rust.
When the pattern matches, control flow goes to the then-branch; otherwise it goes to the else-branch.

==== Control Flow 控制流

=== Name Space, Lexical Scope, Dynamic Scope, Closure 命名空间, 词法作用域, 动态作用域, 闭包

==== `sequence`, Sequence Point & Evaluation Order 序列, 序列点与求值顺序

In Lilies, the code block is called `sequence`,
basically, the sequence is a list of expressions that are evaluated in order, and the value of the sequence is the value of the last expression in the sequence.
The sequence can have a name and then return through the name.
To exit a sequence, use `:break` and the output value will be the value passed to `:break`.
If optional label is provided, the `:break` will jump out of the sequence with the label, otherwise it will jump out of the nearest sequence.

==== `dynamic` & Dynamic Binding

==== Environment & Context 环境与上下文

=== Lazy Evaluation & Call by Name 惰性求值与按名调用

By default, Lilies uses eager evaluation: arguments are evaluated before being passed to the function, regardless of whether they are borrowed, moved, or cloned at the call site.
If `#:naming` is used, the argument is treated as a lazy-evaluated expression — the thunk is evaluated each time the parameter is referenced.

=== Generics

+ Generics: Template
  + Generic Macro

=== Macro

+ Macro
  + History: Compile-time calculation
  + History: C-Style Macro
  + History: `defmacro`
  + Unhygienic Expender Macro
  + Semi-Hygienic Procedure Macro
  + Hygienic Pattern-Matching Macro
  + Hygiene for the Unhygienic Macro
+ Syntax Rules
  + History: Hygiene Macro
  + Syntax Object
  + Contextual Information
  + Pattern Matching
  + Template Generation
+ Macro Application
  + Macro Expansion Syntax
    ```lisp (macro! macro params...)```
  + Compile-Time Evaluation
  + Compile-Time Function Call
  + How can we have macro understand the types of expressions?
  + Evaluate while expanding

==== Built-in Macros 内建宏

- `todo`: a simple macro to indicate that there is still work to be done in this part of code.
- `assert`: a simple macro to check if a condition is true; if not, it raises an `AssertionFailure` condition.
- `unreachable`: a simple macro to indicate that the code is unreachable and should not be executed.
- `debug`: a simple macro to print debug information during development.

=== Pattern-Matching

Pattern matching in Lilies provides a concise way to destructure values and branch on their structure.
The primary pattern-matching construct is `match`, which evaluates a scrutinee expression and
dispatches to the first matching clause.

```lisp
(match expr
  (pattern1 body1 ...)
  (pattern2 body2 ...)
  (_ default-body ...))
```

==== Pattern Forms

Lilies supports the following pattern forms:

- **Wildcard**: `_` matches any value and discards it.
- **Variable**: a symbol matches any value and binds it to the symbol.
- **Literal**: a literal value (`42`, `#True`, `"hello"`) matches if the scrutinee is equal to the literal.
- **Constructor**: `(Cons head tail)` matches a pair/list node and recursively matches `head` and `tail`.
- **Tuple**: `<p1 p2 ...>` matches a tuple with matching elements.
- **Vector**: `[p1 p2 ...]` matches a vector with matching elements, where `...` captures the rest of the vector.
- **Typed**: `(p : Type)` matches if the value matches pattern `p` AND has type `Type`.
- **Guard**: `(p #:when condition)` matches if `p` matches AND `condition` evaluates to true.
- **Or**: `(or p1 p2)` matches if either `p1` or `p2` matches.
- **As**: `(p #:as name)` matches `p` and also binds the whole value to `name`.

==== Exhaustiveness Checking

The compiler checks that `match` expressions are exhaustive — every possible value of the scrutinee type
must be covered by at least one pattern. For sealed types, the compiler knows all variants and can verify
completeness. For open types, a wildcard or variable pattern is required.

==== `try` Pattern Matching

The `try` form is a shorthand for two-way matching, similar to `if let` in Rust:
```lisp
(try (Ok value) result
  (display value)
  (error-handler))
```
If the pattern matches, the then-branch is evaluated; otherwise, the else-branch is evaluated.

==== Destructuring in Bindings

Patterns can be used directly in `let` and `define` bindings:
```lisp
(let ((<x y> (get-coordinates)))
  (+ x y))
```
This destructures the tuple and binds `x` and `y` in a single step.

=== Annotations and Annotation processing

`#@[attributes]` is the general syntax for annotations in Lilies.

==== Built-in Annotations

- `wip`: a simple annotation to indicate that the annotated code is still a work in progress and may not be complete or fully functional.
- `deprecated`: a simple annotation to indicate that the annotated code is deprecated and should not be used in new code.
- `experimental`: a simple annotation to indicate that the annotated code is experimental and may be subject to change or removal in future versions.
- `internal`: a simple annotation to indicate that the annotated code is intended for internal use only and should not be used by external code.

=== Symbol Generation

Symbol generation is a compile-time metaprogramming mechanism that allows the creation of new symbols,
expressions, and declarations based on existing code patterns. It is similar in spirit to KSP (Kotlin Symbol Processing)
or Roslyn source generators for C\#, adapted to the Lisp syntax model.

A symbol generator is defined using the `generate` form, which specifies:
1. A pattern that matches the declarations or expressions to be processed.
2. A template that produces the generated code.
3. Optional filtering criteria to constrain which matched nodes are processed.

```lisp
(generate
  #:pattern (define $name (record #:serializable $fields ...))
  #:template
  (implement (serialize $name)
    #:self self
    (define to-json
      (lambda (self)
        #:returns (String)
        (json-encode (list $@(map (lambda (f) (list f (ref self f))) $fields)))))))
```

Symbol generation runs after parsing and name resolution but before type checking.
Generated code is fully integrated into the compilation pipeline and receives full type checking
and error diagnostics, just like hand-written code.

==== Expression Tree

An expression tree is the parsed, structured representation of Lilies source code as a tree of syntax objects.
Each node in the expression tree is a syntax object that carries:
- The kind of expression (literal, symbol, list, special form).
- Source location information (file, line, column).
- Scope and binding information (after name resolution).
- Type information (after type checking).
- Any annotations attached to the node.

Expression trees are first-class values that can be inspected, traversed, and manipulated by macros
and compile-time functions. The expression tree API includes:
- `syntax-kind` — returns the kind of a syntax node.
- `syntax-children` — returns the child nodes.
- `syntax-location` — returns source location.
- `syntax-type` — returns the inferred/checked type.
- `syntax-attributes` — returns attached annotations.
- `syntax->datum` — converts a syntax object to a plain datum (stripping source and scope info).
- `datum->syntax` — embeds a datum as a syntax object, attaching context from a template syntax object.

=== Memory Management

Lilies provides a hybrid memory management model combining ownership-based allocation with optional garbage collection.
The default mode is ownership tracking (similar to Rust), with garbage collection available as an opt-in for
cyclic or shared-ownership data structures.

==== Ownership

Every value in Lilies has a single owner at any given time.
Ownership is transferred via explicit `(move x)` at the call site, or shared via borrowing (the default).
The compiler tracks ownership statically and inserts deallocation code at the end of each owning scope.
No runtime reference counting or GC overhead is incurred for owned values.

Ownership rules:
- Each value has exactly one owner.
- When the owner goes out of scope, the value is deallocated.
- Ownership can be transferred (moved) to another binding or function.
- Borrowing creates a temporary, non-owning reference that must not outlive the owner.
- Mutable borrows are exclusive: only one mutable borrow may exist at a time.

==== Pointers

Lilies provides several pointer types for different use cases:

- **Unique Ownership** (`Owned T`): A uniquely owning pointer. When dropped, the owned value is deallocated.
  This is the default reference type for heap-allocated objects.

- **Reference Count** (`Rc T`): A shared-ownership pointer with reference counting.
  The value is deallocated when the last `Rc` pointing to it is dropped.
  For cycle breaking, `Weak T` provides a non-owning reference to an `Rc`-managed value.

- **Raw Pointer** (`Ptr T`): An unsafe, non-owning pointer. Dereferencing a raw pointer requires an `unsafe` block.
  Raw pointers are used for FFI and low-level systems programming.

- **Address** (`Addr T`): A typed memory address, distinct from pointers in that it does not imply
  any ownership or liveness guarantees. Used primarily for memory-mapped I/O and embedded programming.

- **Virtual Method Table**: Each concrete type has an associated vtable stored in the type descriptor.
  Dynamic dispatch is implemented by indexing into this vtable at runtime.
  The vtable is constructed at compile time and stored in the static data section.

==== Garbage Collection

For data structures with cycles or shared ownership, Lilies provides an optional tracing garbage collector.
GC-managed values are allocated with `gc:new` and tracked by the collector.
```lisp
(gc:new (MyClass ...))
```

GC is opt-in per allocation. Owned and GC-managed values can coexist in the same program,
but GC references cannot be stored inside owned structures (to avoid dangling references after collection).

==== Allocation

Lilies provides explicit control over allocation strategy:

- `alloc:stack`: Allocates the object on the call stack. The object is deallocated when the stack frame is popped.
  Suitable for small, short-lived values with a size known at compile time.

- `alloc:heap`: Allocates the object on the heap with ownership tracking. The object is deallocated when
  its owner goes out of scope.

- `new`: The standard object creation form. By default allocates on the heap for types whose size is not
  statically known, and on the stack otherwise. The compiler may optimize stack allocation based on escape analysis.

- `variable`: A mutable slot wrapper. Wrapping a type with `variable` creates a mutable cell that can be
  assigned to after creation.

- `constant`: An immutable slot wrapper. Wrapping a type with `constant` creates an immutable cell
  that cannot be assigned to after creation. This is the default for record fields and `let` bindings.

==== Auto Life-Cycle Detection

The compiler performs escape analysis to determine whether a heap-allocated value can be safely allocated
on the stack instead. If the compiler can prove that a value does not escape its allocating scope
(i.e., it is not returned, assigned to a longer-lived location, or captured by a closure that escapes),
it may transparently use stack allocation. This optimization is guaranteed safe and does not change program semantics.



=== CPS, Continuations & Delimited Continuations

Lilies provides first-class continuations, enabling the program to capture and manipulate
the "rest of the computation" at any point.

==== Continuation Passing Style (CPS)

CPS is a programming style where control is passed explicitly as a continuation argument.
Lilies does not require CPS by default, but supports it through the `call/cc` primitive.
The compiler can optionally transform code into CPS as an intermediate representation for optimization.

==== First-Class Continuations

`call/cc` (call-with-current-continuation) captures the current continuation as a first-class value:
```lisp
(call/cc (lambda (k)
  ;; k is the continuation — the rest of the computation after this call/cc
  (k 42)   ;; invoke the continuation: return 42 from the call/cc
  (display "never reached")))
```

When a continuation is invoked:
1. Control jumps to the point where the continuation was captured.
2. The value(s) passed to the continuation become the result of the `call/cc` expression.
3. The current continuation at the invocation point is discarded (the invocation never returns).

Continuations are escape procedures: once invoked, they do not return to the caller.
A continuation remains valid as long as its dynamic extent is on the call stack.
Captured continuations can be stored in data structures and invoked multiple times,
but they must not be invoked after the original call stack frame has been exited,
unless the continuation was captured as a delimited continuation (see below).

==== Delimited Continuations

Delimited continuations capture a segment of the continuation rather than the entire rest of the computation.
They are created using `reset` (which marks the boundary) and `shift` (which captures up to the nearest `reset`):

```lisp
(reset
  (* 2 (shift k
    ;; k captures: (* 2 [·])
    ;; i.e., the context between shift and reset
    (+ (k 3) (k 4)))))
;; => (+ (* 2 3) (* 2 4)) => 14
```

`reset` delimits the continuation. `shift` captures the delimited continuation (from the `shift` up to
the nearest enclosing `reset`) and binds it to a variable. The body of `shift` can invoke this
delimited continuation zero, one, or many times.

Delimited continuations are implemented as composable, multi-prompt continuations:
- `(reset #:prompt p body)` — marks a boundary with prompt tag `p`.
- `(shift p k body)` — captures up to the nearest `reset` with prompt `p`.

==== Implementation

Continuations are implemented via stack copying: when a continuation is captured, the relevant portion
of the control stack is copied into the heap. When the continuation is invoked, the stack is restored
from the copy. Delimited continuations copy only the stack segment between the `reset` and `shift` frames.

=== Side Effects & Algebraic Effects

Lilies supports algebraic effects and handlers as a high-level mechanism for managing side effects.
Algebraic effects separate the description of an effect from its implementation, allowing effect handlers
to be composed, interleaved, and reinterpreted.

==== Effect Declarations

An effect is declared with the `effect` form, specifying the operations it provides:
```lisp
(define-effect State
  (get (function () #:returns (Any)))
  (put (function (Any) #:returns (None))))
```

Each operation declares its name and signature. The effect declaration defines an interface
that effect handlers must implement.

==== Performing Effects

Effects are performed using the `perform` form:
```lisp
(perform State:get)
(perform State:put new-value)
```

When an effect is performed, control transfers to the nearest enclosing handler for that effect.
The handler processes the operation and can either:
- Resume the computation with a value (using `resume`).
- Abort the computation entirely.

==== Effect Handlers

An effect handler is installed with the `handle` form:
```lisp
(handle (State)
  #:handler
  (lambda (op resume)
    (match op
      ((State:get) (resume current-state))
      ((State:put v) (set! current-state v) (resume None)))))
  body ...)
```

Multiple effects can be handled simultaneously, and handlers can be nested.
The nearest handler for a given effect intercepts `perform` operations.

==== Built-in Effects

Lilies provides standard effects for common side-effecting operations:
- `IO` — console input/output, file operations.
- `Exception` — exception raising and handling.
- `State` — mutable state.
- `Reader` — read-only environment.
- `NonDet` — non-deterministic computation (multiple resumptions).

==== Relationship to Continuations

Algebraic effects can be implemented using delimited continuations: `perform` is `shift`,
and `resume` invokes the delimited continuation. Lilies treats effects as a distinct construct
with dedicated syntax because it provides clearer semantics, better error messages,
and more optimization opportunities than a direct encoding with continuations.

=== Yield, Suspend, Resume & Stream (Engine)

Lilies provides generators and streams as composable abstractions for lazy sequences and
cooperative concurrency.

==== Yield

The `yield` form suspends a generator function and produces a value to the caller:
```lisp
(define-generator (count-from n)
  (let loop ((i n))
    (yield i)
    (loop (+ i 1))))
```

A generator is a function that can suspend its execution and later resume from the suspension point.
Each call to the generator resumes from the last `yield` and runs until the next `yield` or `return`.

==== Suspend & Resume

Generators are built on a lower-level suspend/resume mechanism:
- `suspend` captures the current execution state and returns control to the invoker.
- `resume` restores a suspended execution and continues from the suspension point.

These are implemented using delimited continuations internally, but the generator abstraction
provides a safer, more constrained interface.

==== Streams (Engine)

A stream is a lazy, potentially infinite sequence produced by a generator.
Streams support the full set of sequence operations:
```lisp
(stream-map square (count-from 1))
(stream-filter even? (count-from 1))
(stream-take 10 (count-from 1))
```

Streams are evaluated on demand: elements are computed only when needed.
Stream operations compose without creating intermediate collections.
```lisp
(-> (count-from 1)
    (stream-filter even?)
    (stream-map square)
    (stream-take 5)
    stream->list)
;; => (4 16 36 64 100)
```

Streams can be infinite and support operations like `stream-zip`, `stream-interleave`,
`stream-merge`, and `stream-iterate`.

==== Implementation

Generators are compiled to state machines at compile time when possible (for simple, local generators).
For complex generators (those that capture non-local state or are passed as values), they are
implemented via delimited continuations backed by heap-allocated stack segments.

=== Threads & Subroutines

Lilies provides both operating-system threads and lightweight user-space threads (subroutines)
for concurrent and parallel execution.

==== OS Threads

Native threads are created with the `thread` form:
```lisp
(let ((handle (thread (lambda ()
  (display "running in thread")))))
  (thread-join handle))
```

OS threads run in parallel across multiple CPU cores. Each thread has its own call stack,
dynamic environment, and thread-local storage. Communication between threads uses
channels, mutexes, and atomic variables.

Thread safety is enforced by the type system: types that are not `Send` cannot be transferred
across thread boundaries, and types that are not `Sync` cannot be shared across thread boundaries
via borrowing.

==== Subroutines

Subroutines are lightweight, cooperatively scheduled execution contexts that run within a single OS thread.
They are similar to green threads or fibers, providing cheap context switching without kernel involvement.
```lisp
(subroutine (lambda ()
  (yield-to :scheduler)
  ...))
```

Subroutines are scheduled cooperatively: a subroutine runs until it explicitly yields control
(via `yield-to` or an I/O operation) or completes. The scheduler then selects the next ready subroutine.

Subroutines are suitable for high-concurrency workloads (many thousands of concurrent tasks)
where OS thread overhead would be prohibitive.

==== Channels

Communication between threads and subroutines uses channels:
```lisp
(let ((ch (make-channel Integer)))
  (subroutine (lambda () (channel-send ch 42)))
  (let ((value (channel-recv ch)))
    ...))
```

Channels can be buffered or unbuffered, synchronous or asynchronous.
Channel operations can be integrated with `select` for multi-way waiting.

=== Async, Await & Coroutines

Lilies provides built-in support for asynchronous programming through coroutines and the `async`/`await` syntax,
integrated with the effect system for composable, testable async code.

==== Async Functions

An async function is defined with `async` before `lambda`:
```lisp
(define fetch-data
  (async lambda ((url String))
    #:returns (String)
    (let ((response (await (http-get url))))
      (response-body response))))
```

An async function returns a `Future T` value, where `T` is the return type.
The future represents a computation that will complete at some point in the future.

==== Await

`await` suspends the current coroutine until the awaited future completes:
```lisp
(await future-value)
```

When a coroutine awaits, it yields control to the scheduler (the async runtime),
which can run other coroutines while waiting for I/O or other events.

==== Coroutines

Async functions are compiled into coroutines — resumable functions whose local state is preserved
across suspension points (await calls). Each `await` is a suspension point where the coroutine's
state is saved and control returns to the scheduler.

Coroutines are similar to subroutines but are specifically designed for I/O-bound concurrency:
- They are scheduled by an async I/O event loop rather than cooperatively.
- They automatically yield on I/O operations without explicit `yield-to`.
- They can run across multiple threads via work-stealing schedulers.

```lisp
;; Concurrently fetch multiple URLs
(let ((results
  (await (future-join
    (list (fetch-data url1)
          (fetch-data url2)
          (fetch-data url3))))))
  ...)
```

==== Async Runtime

The async runtime is pluggable. Lilies provides a default multi-threaded work-stealing runtime,
but users can provide custom runtimes for embedded or specialized environments.
The runtime is selected at program entry and is global to the program.

==== Relationship to Algebraic Effects

Async/await is implemented as an algebraic effect. The `await` operation performs the `Async` effect,
which the runtime handler intercepts. This design allows testing async code without a real event loop
by providing a mock handler:
```lisp
(handle (Async)
  #:handler (lambda (op resume) (resume mock-result))
  (test-async-function))
```

=== Exception Handling

Lilies provides a comprehensive condition system for error handling, inspired by the Common Lisp
condition system but enhanced with static type checking.

==== Exception Types

Exceptions are values of types that implement the `Exception` trait:
```lisp
(define ParseError
  (record
    (define message (constant String))
    (define location (constant SourceLocation))))
(implement ParseError (Exception))
```

The standard library provides a hierarchy of exception types:
- `Exception` (trait) — base trait for all exceptions.
  - `Error` — serious errors that typically should not be caught.
  - `Warning` — non-fatal warnings.
  - `Condition` — general conditions for non-local control flow.

==== Raising Exceptions

Exceptions are raised with the `raise` form:
```lisp
(raise (ParseError "unexpected token" (here)))
```

`here` is a compile-time form that expands to the current source location.

==== Handling Exceptions

Exception handlers are installed with `guard`:
```lisp
(guard
  ((ParseError e)
   (display "parse error: ")
   (display (ParseError-message e)))
  body ...)
```

Multiple handlers can be specified, and the first matching handler is selected.
Handlers can be chained: if a handler cannot resolve the condition, it can re-raise it.

==== Condition System

Beyond simple try/catch, Lilies provides a full condition system with restarts:
```lisp
(guard
  ((ParseError e)
   (restart-case
     ((skip () (continue))
      (retry-with (new-input) new-input))
     (display "parse error; use restart to recover"))))
```

Restarts are recovery options established by handler code that can be invoked by the raiser
or by interactive debugging tools. This separates error detection (raising) from error recovery
(restart selection).

Key condition system forms:
- `raise` — signals a condition, searching for a handler.
- `guard` — establishes condition handlers for a body of code.
- `restart-case` — establishes restart options available to handlers.
- `restart` — invokes a named restart.
- `continue` — resumes execution from the point where the condition was raised (if resumable).
- `unwind-protect` — ensures cleanup code runs regardless of how a body exits (normal, exception, or continuation).

==== Typed Exceptions

Exception types are part of a function's effect signature.
A function that may raise `ParseError` declares it in its return type:
```lisp
(lambda (input String)
  #:returns (Result AST ParseError)
  ...)
```

For functions using the condition system with restarts, the `Condition` effect tracks
which conditions may be raised, enabling compile-time verification that all conditions
are either handled or propagated.



=== Top-Level

For each file, the top-level is the outermost level of code that is not nested inside any other expression or structure.
Briefly, the definition and expression at the top-level is treated to be executed in order.

Top-level is the smallest unit of code, defines the entry point, global environment and the module of a lilies program.

A library file that defines and exposes exactly one module (via `provide`) naturally conforms to the recommended style: the module definition is the single top-level expression. Multiple local modules within a single file exist as a convenience to avoid deep file hierarchies for small, closely related interfaces; this pattern is discouraged for general use. The main file (entry point) is exempt from this recommendation, as it typically requires `import` and `provide` forms alongside the `main` definition.

==== Entry Point

The entry point of a lilies program is a function provided directly at the top-level.

Main function must be a function that takes one `(Optional (Vector String))` parameter, which is the command line arguments,
and returns `(Result Integer (impl Error))`, which gives the feedback of the program execution,
where `Integer` is the exit code, and `impl Error` is the error information when the program execution fails.

=== Module & Library

The module system in Lilies organizes code into named, separately compilable units with explicit
dependencies and controlled visibility. Each file has exactly one top-level scope.
Within that top-level, multiple local modules may be defined; they can reference one another freely.
However, only one module per file may be exposed to other files via `provide`.

A module as a whole can be treated as a first-class value: binding a module to a variable name
allows accessing its exported members through member-access syntax (e.g., `module:member`),
or all of its exported members can be imported into the current scope at once.

Modules serve several purposes:
- **Namespace management**: modules group related definitions, preventing name collisions across modules.
- **Visibility control**: modules declare what is exported and accessible to other modules.
- **Dependency management**: modules declare their dependencies explicitly via `require`.
- **Separate compilation**: modules are compiled independently, with dependencies resolved at link time.

==== Provide & Require

In each file, it is possible and only to have only one provide form, which declares what objects are provided by this file.
And these objects can be loaded by other file with `require` form.

Provide accepts a symbol as the module name, and a object to be provided.
Require takes the name of the module to be loaded and returns the provided object of that module.
The search path of require is relative to the file that required.
Other search path for standard libraries and third-party libraries can be configured in the compiler.

Even though it is not encouraged, you can still define something outside of the provide form,
thus, though those objects maybe used by functions in the module, they are not possible to be loaded by other modules.
This can remove the unnecessary module definition.
Some times, the trick is useful in main file.

The name provided by a file must be the same as the file name, without the file extension and prefixed with `:`;
thus, for example, if a file is named `foo.l`, it must provide a module named `:foo`.

E.g., Traditional module definition:
```lisp
(provide :foo
  (module
    #:export (main)
    (import (:ns (require :std)))

    (define main
      (lambda ((args (Optional (Vector String))))
        #:returns (Result Integer (impl Error))
        (Ok 0)))))
```
Main file without module definition:
```lisp
(import
  (:ns (require :std))
  (:ns (require :foo)))

(define main
  (lambda ((args (Optional (Vector String))))
    #:returns (Result Integer (impl Error))
    (Ok 0)))

(provide :main main)
```

Formally, the syntax of provide and require is described as:
```lisp
provide ::=
'(' 'provide' <module-name> <provided-object> ')'

require ::=
'(' 'require' <module-name> ')'
;; require => <provided-object>
```

==== Module & Library System

Module is a way to organize code into separate namespaces, and to control the visibility and accessibility of code.
A single file may define multiple local modules that can reference one another.
However, each file exposes at most one module to the outside world: only one `provide` form is permitted per file, and it determines which module (or value) is visible to other files.

A file that provide a module is called a library, and a file that require only modules is called the client.
There are three type of client:
- Executable client, which is a file that provides the main function as the entry point of the program.
- Test client, which is a file that provides test class.
- Script client, no provide form needed, and the code at the top-level will be executed directly when the file is run.

Module is also a special form like `define`.

E.g., to define a empty module:
```lisp
(module
  #:export ())
```

The module definition syntax is described as:
```lisp
module ::=
'(' 'module'
  [ <export-list> ]
  { <expressions> } ')'

export-list ::=
'#:export' '(' { <exported-object> } ')'
```

==== Import & :Export

Provide simply declare the object to be provided, and require simply load the provided object and returns it.
So, it must have some special syntax for bind the provided object to a name.

Define form is usable but if the object provided is a module, it is not possible to unwrap the module namespace and use objects exported by the module.

Import form is a special form that can import a module and bind the exported objects to names in the current namespace.
- `:ns` sub-form is used to import a module and bind its exported objects to names in the current namespace, with prefix same as the library name.
- `:some` sub-from can extract some of the exported objects from a module and bind them to names in the current namespace.
- `:ren` sub-form can rename some of the exported objects from a module and bind them to names in the current namespace.
Each sub-from can be combined together to import a module in a flexible way.

Export form is a sub-form of module definition, which is used to declare which objects are exported by the module.

== Compilation Model 编译模型

Lilies is designed to be implemented as both an interpreter and a native compiler.
This chapter describes the compilation pipeline and how the interpreter and compiler share infrastructure.

=== Compilation Pipeline

The Lilies compilation pipeline consists of the following phases:

1. **Lexing**: Source text is tokenized into a stream of tokens (identifiers, literals, delimiters, keywords).
2. **Parsing**: Tokens are parsed into syntax objects forming an abstract syntax tree (AST).
  The parser produces syntax objects with source location annotations.
3. **Macro Expansion**: Macros are expanded recursively. The expander walks the AST, expanding
  macro forms and inserting the resulting syntax in place. Expansion continues until no macro forms remain.
4. **Name Resolution**: All symbols are resolved to their definitions. The resolver builds a scope graph
  and links each reference to its binding site. Unresolved references produce compile-time errors.
5. **Type Checking & Inference**: The type checker assigns types to every expression, verifies
  type consistency, and infers types where annotations are omitted.
6. **Ownership Analysis**: The borrow checker verifies ownership rules: no use-after-move,
  no dangling borrows, exclusive mutable references.
7. **Optimization**: Middle-end optimizations: inlining, constant folding, dead code elimination,
  closure conversion, and monomorphization of generic code.
8. **Code Generation**: The IR is lowered to target code — either bytecode for the interpreter
  or native code (via LLVM / Cranelift) for the compiler.
9. **Linking**: Object files and libraries are linked into the final executable.

=== Interpreter Mode

In interpreter mode, after type checking, the AST (or a high-level intermediate representation)
is evaluated directly by a tree-walking interpreter. The interpreter:
- Evaluates expressions in the current environment.
- Uses the same type-checked AST as the compiler, ensuring consistent semantics.
- Supports REPL interaction with incremental compilation of each input form.
- Provides enhanced debugging: breakpoints, single-stepping, stack inspection.

=== Compiler Mode

In compiler mode, the pipeline proceeds through code generation to produce native executables.
The compiler:
- Translates the typed, ownership-checked IR to native code.
- Performs target-specific optimizations (register allocation, instruction selection).
- Supports multiple backends: LLVM for optimizing compilation, Cranelift for fast compilation.
- Produces standalone executables or shared libraries.

=== REPL

The Read-Eval-Print Loop provides interactive development:
- Each input form is lexed, parsed, expanded, resolved, type-checked, and evaluated incrementally.
- Definitions persist in the REPL environment across inputs.
- The REPL provides command history, tab completion, and inline documentation via the `doc` function.
- In REPL mode, the interpreter is used by default; individual forms can be JIT-compiled with a directive.

=== Foreign Function Interface

The FFI allows Lilies code to call functions written in other languages (primarily C) and vice versa.
```lisp
(ffi:declare fopen
  (function (String String) #:returns (Ptr None)))
```

FFI declarations are checked at compile time; the linker verifies symbol availability.
Calling conventions, struct layouts, and type mappings are specified through FFI annotations.
Unsafe FFI calls must be enclosed in `unsafe` blocks.

=== Linkage & Distribution

Lilies modules can be distributed as:
- **Source libraries**: distributed as source files, compiled by the consumer.
- **Compiled libraries**: distributed as pre-compiled IR or object files with interface files.
- **Packages**: collections of modules with versioned dependencies, distributed through the package registry.

The compiler supports building static and dynamic libraries, as well as standalone executables.

== Code Generation

Code generation is the final phase of compilation, translating the optimized intermediate representation
into executable target code. Lilies supports multiple backends for different use cases.

=== Intermediate Representation

The Lilies IR is a typed, SSA-based (Static Single Assignment) intermediate language that preserves:
- Full type information, including generic type parameters after monomorphization.
- Ownership and borrowing information for memory management code generation.
- Source location mappings for debug information.
- Effect annotations for handler code generation.

The IR is lowered through a series of passes:
1. **High-level IR**: Preserves algebraic data types, closures, and pattern matching.
2. **Mid-level IR**: Closures are converted to closure objects; pattern matching is lowered to decision trees.
3. **Low-level IR**: Types are converted to machine representations; ownership is lowered to allocation/deallocation.

=== Backend Targets

Lilies supports multiple code generation backends:

==== LLVM Backend

The primary backend for production builds. Generates optimized native code for all LLVM-supported targets.
Features:
- Full link-time optimization (LTO).
- Profile-guided optimization (PGO) support.
- Sanitizer integration (address, memory, thread, undefined behavior).
- Debug info generation (DWARF, PDB).

==== Cranelift Backend

A fast, simple code generator for debug/development builds.
Prioritizes compilation speed over runtime performance.
Used by default in the REPL's JIT compiler.

==== Bytecode Backend

Generates portable bytecode for the Lilies VM.
The bytecode is interpreted by the Lilies runtime, providing:
- Platform-independent distribution.
- Smaller binary sizes.
- Runtime dynamic loading and hot-swapping of code.

=== Code Generation Phases

1. **Instruction Selection**: IR operations are mapped to target machine instructions.
2. **Register Allocation**: Virtual registers are assigned to physical registers or stack slots.
3. **Instruction Scheduling**: Instructions are reordered to exploit pipeline parallelism.
4. **Prologue/Epilogue Generation**: Stack frame setup and teardown code is emitted.
5. **Object File Emission**: The final machine code is written in the target object format (ELF, Mach-O, PE).

=== Garbage Collection Integration

When the GC is enabled, the code generator:
- Emits stack maps at GC-safe points, recording which registers and stack slots contain GC-managed references.
- Inserts write barriers for stores into GC-managed objects (to track inter-generational pointers).
- Aligns allocations with GC requirements.
- Generates GC-trigger checks before heap allocations.

=== Linkage

The Lilies linker combines compiled modules, resolves cross-module references,
and produces the final executable or library. The linker handles:
- Module dependency resolution and version checking.
- Vtable and trait implementation table construction.
- Initialization code generation for module-level definitions and top-level expressions.
- Entry point wrapping (calling the main function with command-line arguments).

=== Compile-Time Evaluation

Expressions that can be evaluated at compile time are computed during compilation
rather than at runtime. This includes:
- Constant expressions (literals, constant-folding).
- Macro expansions and symbol generation.
- Type-level computations (type families, trait resolution).
- Compile-time function calls (functions annotated with `#:compile-time`).

Compile-time evaluation uses the interpreter, providing identical semantics to runtime evaluation
for all pure expressions.

=== Debug Information

Debug information maps generated code back to source locations, enabling:
- Source-level debugging (breakpoints, stepping).
- Stack traces with source file names and line numbers.
- Variable inspection (names, types, values).

Debug info is generated in the platform-appropriate format (DWARF on Unix, CodeView/PDB on Windows)
and can be stripped for release builds.
