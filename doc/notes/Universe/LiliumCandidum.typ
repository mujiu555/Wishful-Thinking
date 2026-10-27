#import "/lib/typst-mode/lib/_lib.typ/lib.typ": meta, mkheading
#import "../aut.typ": mujiu

#meta(
  title: [Lilium Candidum --- The Algebra of Abstraction: A Language of Types, Syntax, and Continuations],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  authors: (mujiu,),
  id: "dflat-lilies",
  parent_id: "index",
  abstract: "
The language Lilium Candidum (Lilies) is designed to be a staged, statically typed language of bindings, abstractions, applications, and contexts, in which represent functional programming using at least as much primitives.
  ",
)

#mkheading()

== Introduction

// TODO: finish introduction

== Overview of the Language

// TODO: intro for overview

=== Types and Values

Programs operate on values.
Every value has a type.
All value types described in this section are first-class:
their values may be passed to functions, returned from functions, and stored in data structures.

Detailed descriptions of types in Lilies are provided in later chapters.
This section does not specify the detailed semantics of these types and their instances.

==== Primitive Types and Literal Forms

Primitive types are types whose values admit literal representations in the surface syntax.
Such literals may occur in different compilation stages, subject to the interpretation rules of each stage.

The following notation is used to describe literal syntax:
- `<name>` denotes a metavariable, representing a syntactic component.
- `[component]` denotes an optional component.
- Text appearing outside metavariables and optional components is matched literally.
- `...` denotes repetition where explicitly specified.
Angle brackets are notation only and do not appear in source code unless explicitly stated otherwise.

NOTE:
- `<sym>` is just a sequence of valid characters, (text)
- `[sign]` is an optional `+` or `-`
- `<int>` means a sequence of decimal digits, possible `1234567890` and `'`
- `<oct>` means octal numbers literal, possible `12345670` and `'`
- `<hex>` means hexadecimal numbers literal, possible `123456789abcdef0` and `'`
- `<bin>` means binary numbers literal, possible `10` and `'`
- Digit separators (`'`) may appear only between two valid digits of the corresponding numeral system.
- `<n>` and `<m>` are decimal numbers
- `<base>` is decimal-mantissa and `<exp>` is decimal integer
- for boolean, the provided string is either `#true` or `#false`
- `<char>` is any single Unicode character
- `<name>` is ASCII escaped character name, or short name like C-Style escape set, no name `u` will be chosen since we have u for Unicode
- `<unicode>` is a hexadecimal representation of a valid Unicode scalar value
- `<str>` is a continuous escape uninterpreted text that delimited by double quote `"`
- within escape interpreting string, there are two method for escape:
  - `\<short-name>`: C-Style escape, e.g., `\r` for return, `\n` for newline (linefeed)
  - `\u{<unicode>}`: unicode code point, decoded into utf-8 automatically

+ Integer: Signed Integers
  - `[sign]<int>`   : Decimal
  - `[sign]0o<oct>` : Octal
  - `[sign]0x<hex>` : Hexadecimal
  - `[sign]0b<bin>` : Binary
+ Rational:
  Exact rational numbers represented by a numerator and a nonzero denominator.
  A rational literal always denotes a value of type Rational,
  even when its mathematical value is an integer.
  - `[sign]<n>/<m>` : Rational
+ Real: Arbitrary-precision decimal floating-point numbers
  - `[sign]<n>.<m>` : Float
  - `[sign]<base>e[sign]<exp>`: Scientific/ Standard
+ Boolean: Sum type of `true` and `false`
  - `#true`         : True the literal
  - `#false`        : False the literal
+ Character:
  Unicode characters represented directly, by named escapes, or by Unicode escapes
  - `#\'<char>`     : Character, `<char>` can be any single Unicode scalar value, parse only once, even space
  - `#\<name>`      : Character Escape
  - `#\u{<unicode>}`: Unicode
+ String: An immutable sequence of bytes, encoded as UTF-8.
  - `"<str>"`       : String with escape
  - `r"<str>"`      : Raw String without escape
+ Symbol:
  Symbols are names represented by character sequences.
  Depending on syntactic context, a symbol may occur as an identifier or denote a symbolic value.
  Identifiers additionally carry binding-related information through their associated syntax objects.
  A symbol consists of a name and an identity.
  Symbols with identical names are not necessarily identical if their identities differ.
  - `<sym>`         : Symbol the Identifier
+ Syntax Symbol:
  Compile-time only constant, indicates named argument.
  Syntax symbols are compared by name.
  - `#:<sym>`       : Symbol, two syntax symbol with same name are same
+ Unit: Absence of meaningful information.
  - `()`: Denotes Unit when used as an unquoted expression.
+ Pair, Nil, and S-expression:
  S-expressions are structured data consisting of atomic values and pairs.
  Pairs and Nil form the structure of S-expression lists.
  - `()`: Denotes Nil when interpreted as an S-expression value.
  - `(<car> . <cdr>)`: A pair in S-expression data.
  - `(<sexp>...)`: A list in S-expression data.
  In expression position, an unquoted `()` evaluates to Unit.
  When `()` is represented as S-expression data, it denotes Nil.
  Such data may be produced by quotation, contained in syntax objects,
  or returned by functions.

==== Compound Types

Value types described in this section can be interpreted in runtime or compile-time computation.

- Functions: Functions are values
- Records:   Record values are instances of user defined nominal product types
- Tuples (Number Indexed Records): Tuples are product types
- Enumerations: Enumerations values are tagged variants of user defined nominal sum types
- Type-Class Dictionaries (Records):
  Type-class dictionaries are ordinary record values that provide implementations of a type-class interface.
  They are explicitly passed to functions.
- Module Packs (Records): Modules are first-class values

==== Compile-Time only Entities

Compile-time entities participate in compilation, expansion, or type checking,
but are not ordinary runtime values in the current language design.

+ Macros: Macros are compile-time functions
+ Types and Type Constructors:
  Types and type constructors are compile-time entities classified by kinds.
  They support type-level abstraction and application but are not ordinary runtime values.
+ Syntax Objects: Syntax objects are structured representations of program syntax that preserve lexical context and binding information

=== Expressions, Forms and Application

Expressions are syntactic constructs that are evaluated to produce values.

The most basic expressions are literals:
```lisp
#true
#false

25'5
0xff
0o377
0b1111'1111
0x00ff
0x0'FF

00   ; 0
-0   ; 0
0    ; 0

+0/1
2/2
-10/4
-29/128

0.5
-1.2
+99.0
-1e20
3.8e9
+21e12
0e-3

#\'a
#\space
#\n
#\u{2764}

"Lilium Candidum"
"\n"
r"Lilies"  ; same as "Lilies"
r"\n"      ; same as "\\n"

'()        ; quoted empty list, nil
(quote ()) ; same

()         ; Unit
```

Compound expressions are represented using S-expression list.
The first element of the list is the operator and the rest expressions of the list are operands.
```lisp
(+ 10 9)
(+ 86 (* 3 5))
```
Compound expressions use prefix notation.

Quote (`(quote ...)`) is a form, just like regular functions, a form occupies the first expression.
It is a special form because it do not necessarily follow the evaluation rules functions follows --- it will not evaluate sub-expressions.

==== Application

Application is the process of applying an operator to operands.

Lilies supports two modes of application, determined by the operator's signature and corresponding parameter form:

- *Parameter-wise application:*
  The operator receives its operands individually, according to its parameter signature.
  The operator itself is not supplied as an argument.
- *Entire-expression application:*
  The operator receives the complete application expression as a single argument,
  including the operator itself and all operands.

These two modes correspond to different parameter forms of `lambda` and different signature forms.
The parameter form of a lambda must agree with its declared signature.

```lisp
(lambda <ids> <body>)                            ; Lambda                      Expression
(lambda (<id>...) <body>)                        ; Lambda                      Expression
;; NOTE: Unlike the lambda appearing in macros, a runtime lambda that wants to
;;   use the matcher form must be able to express the whole call expression,
;;   which contains the function itself.  Doing so constructs a type for that
;;   bound object which needs to encode itself.
;;   Lilies requires recursive type definitions to satisfy a positivity restriction.
;;   Consequently, a recursive function signature that places its own type in a negative position is rejected.
;;   The lambda in macros, by contrast, only receives the expression itself.
(forall (<id>...) <body>)                        ; Typed                       Constructor,
;; NOTE: Although a matcher is syntactically permitted in this parameter
;;   position, the current type system does not support matching an
;;   entire type-level expression in this manner.
;;
;;   Supporting this operation would require additional rules for
;;   type-level representation, universe levels, and binding.
;;
;;   Lilies intentionally excludes this form. The precise restrictions
;;   are specified in the type system chapter.
```

Both functions and macros support the same application syntax and parameter-binding mechanism.
However, they operate on different representations at different compilation stages.

For ordinary runtime functions,
entire-expression application requires a type capable of representing the complete application,
including the function value itself.
Such a signature introduces a recursive occurrence of the function's type in an argument position,
which violates Lilies' recursive-type positivity restriction.

Consequently, although entire-expression application is syntactically supported for runtime functions,
such definitions cannot pass type checking under the current type system.

Macros are not subject to this particular restriction because
their complete applications are represented as syntax objects rather than runtime function values.

The following examples illustrate application syntax;
their typing rules are presented in later sections.
```lisp
(define id
  (forall (a)
    (function (:Self a) a))
  (lambda (i) i))

(define when
  (macro #syn #syn)
  (lambda ctx
    (case ctx ()
      ((_ cond then)
       (syntax (list (quote if) cond then ())))
      (:else
       (error "")))))

;; INVALID: rejected by the recursive type restriction.
;;(define id
;;  (forall (a)
;;    (mu (lambda (L)
;;      (function (:Self (tuple L a)) a))))
;;  (lambda f
;;    (case f ()
;;      ((_ a) a)
;;      (:else (error "")))))
;; This construction is syntactically valid, but, actually, will cannot pass the type check, so, type level recursive will not allowed,
;; you can try to letting function to accept function invoke expression itself, but it will never pass the compilication
```

When we calling functions, they are provided with arguments as:
```lisp
(id 'sym)              ; provide id with 'sym

;; The macro receives the complete application syntax,
;; including the operator `when`.
(when #true (id 'sym)) ; provide when with (#syn (cons 'when (cons #true (cons (cons 'id (cons ''sym '())) '()))))
```


All required arguments must be supplied in a single application.
Implicit partial application is not supported.

Whenever evaluation of operands is required, operands are evaluated from left to right.

An application is invalid if its arguments do not satisfy the operator's declared signature.

=== Variables, Bindings, Signatures and Definitions

To represent the computation process, the language choose to allowing users to binding a name and a value,
the name that can be used for referring value (and memory) and the binding relation is called variable.

There are two ways to create such definition.
- Lambda Parameter - Application Argument Provider
- Definition

==== Variable and Lexical Scope

Generally, if you have defined a variable, then its value will never changed within its scope.
Thus you can treat it directly as the value itself.

The language adopt a name resolving method called lexical scope.
That is, any function or something similar will only be able to capture free variables from its definition environment,
so, prevent program from variable occasionally capturing.

Traditionally, Lisp System use dynamic scope,
even scheme, the first dialect to adopt lexical scope, provides dynamic-let (parameterized).
However, this might make whole system impure.

===== `lambda` Parameter

A lambda expression creates a function and specifies how the arguments of an application are bound.

Lilies provides two parameter forms:

```lisp
(lambda (<param>...) <body>)  ; Parameter-list form
(lambda <param> <body>)       ; Parameter-matcher form
```

- *Parameter-list form*:
  The parameter-list form binds each supplied operand to its corresponding parameter.
  The operator itself is not bound as a parameter.
  This form requires a parameter-list signature using `:Self`.
- *Parameter-matcher form*:
  The parameter-matcher form binds the complete application to a single parameter.
  The bound application includes the operator itself and all operands.
  This form requires an entire-expression signature.

For example, given an application:
```lisp
(foo x y)
```
the parameter-matcher form receives the complete application:
```lisp
(foo x y)
```
It does not receive merely the operand list:
```lisp
(x y)
```

The representation and interpretation of the received application depend on the compilation stage and the category of the operator.

In particular, macro applications are represented using syntax objects.

==== Signature

A signature describes the type of an entity and the requirements imposed on its components.

Signature constructors are type-producing constructs.
They produce types, and their results may be used wherever a type is expected.

Lilies provides signature constructors for functions, macros, type constructors, type classes, and modules.
Although these signatures describe different categories of entities, they participate in the same type system.

===== Function and Macro Signatures

Functions and macros support two signature forms:

```lisp
(function (:Self <param>...) <return>)               ; Function                    Signature
(function <application-type> <return>)               ; Function                    Signature
(macro (:Self <param>...) <return>)                  ; Macro                       Signature
(macro <application-type> <return>)                  ; Macro                       Signature
```

The two forms correspond to the two application modes.

- *Parameter-list Signature*:
  In the parameter-list form, `:Self` is a special syntactic marker denoting the operator position of an application.
  It does not introduce a parameter, a type variable, or a recursive reference to the operator's type.
  Each `<param>` specifies the type of one operand, in application order.
  The operator itself is not passed to the lambda as an argument.
- *Entire-expression signature*:
  In the entire-expression form, `<application-type>` specifies the type of the complete application supplied to the lambda.
  The complete application includes the operator itself and all operands.
  Unlike the parameter-list form, this signature must account for the operator as part of the received application.

The signature form determines which lambda parameter form is valid.
A parameter-list signature corresponds to `(lambda (:Self <param>...) <body>)`,
while an entire-expression signature corresponds to `(lambda <params> <body>)`.

E.g.,
```lisp
(define sum-of-two-integer
  (function (:Self #int #int) #int)
  (lambda (a b) (+ a b)))

(define cond
  (macro (#syn sexp) (#syn sexp))
  (lambda ctx
    (case (:else)
      ((list _ (case body) . rest)
       #(syn `(if ,case ,body ,(cond rest))))
      ((list _ (:else body))
       #(syn body))
      (:else (error)))))
;; list is a variant constructor of sexp
;; list is a wrap of cons
```

===== Parameterized Type Constructor

```lisp
(type (:Self <type>...) <type-sig>)                           ; Type Constructor            Signature
(class (:Self <type>...) <type-sig>)                          ; Type Class                  Signature
```

Types and Classes can be constructed in same way.
This is a method to implement parameterized polymorphism.
They can accept parameter list only.

===== Module

```lisp
(module (:Self <type>...) <module-sig>)                       ; Module                      Signature
```

Module is used to create parameterized module type.
But actually, you can use `type` to create same one.

===== Type-Class, Super Type and Constraint

```lisp
(constraint (<type-class-constraint>...) <body>)     ; Type                        Constraint
(include (<super-class-constraint>...) <body>)       ; Super                       Constraint
;; Constraint looks like (<Type Class> <type>...)
```

Constraint and Include, are some kind of special.
Though they marks the type of accepted type as well, they are only meaningful for type-class dictionaries.

```lisp
(define Monad
  (class (:Self (type (:Self *) *)) *)
  (lambda (m)
    (record
      (:include (Applicative m))
      (: >>= (forall (x y) (function (:Self (m x) (function (:Self x) (m y))) (m y)))))))
;; Assume Applicative is defined before

(define foo
  (forall (a)
    (constraint ((Sum a))
      (function (:Self a a) a)))
  (lambda (dict)
    (lambda (x y)
      ((invoke dict sum) x y))))

(define monad
  (include ((Applicative Maybe)) (Monad Maybe))
  (lambda (cst)
    (record
      (: return (invoke cst pure))
      (: >>= (lambda (a b) ...)))))
```

==== Binding
===== `define`

```lisp
(define <name> <type> <value>)
```

===== `let` Family

```lisp
(let ((: <name> <type> <val>)...) <body>)
(let:seq ((: <name> <type> <val>)...) <body>)
(let:rec ((: <name> <type> <val>)...) <body>)
(let:seqrec ((: <name> <type> <val>)...) <body>)
```

=== Functions, Macros and Lambda
==== `function`
==== `macro`
==== `lambda`
==== Parameter
===== List
===== Matcher

=== Syntactic Type, Literal, Datum Value and Semantic Interpretation
==== S-Expression
An S-expression is the syntactic type used to represent the structural form of Lilies programs.
==== Literal
==== Syntax Objects

=== Records, Enumerations, Tuples and Algebraic Data Types
==== Product Type
==== Sum Type
==== `record`
===== `:include`
==== `tuple`
==== `enum`
==== `#type` and `*`

=== Polymorphism
==== `forall`
==== `type`
==== `constraint`
==== `include`

=== Type Classes
==== `class`

=== Conditional Expression
==== "`if` then else"
==== `when`, `unless` the Macro
==== `cond`, `switch` the Macro
==== `loop` the Macro
==== `while`, `until` the Macro
==== `for` the Named Let
==== `foreach` the Map
==== `:break`
==== `:continue`

=== Pattern Match
==== `match`
==== `case`
==== Literal
==== `:or`
==== `:and`
==== `:as`
==== Pattern Variable
==== Wildcard
==== `:else`
==== "Ctor" Extraction
==== `:guard`

=== Delimited Continuations
==== `reset`
==== `shift`

=== $"System" F_omega^mu$

==== Type Universe

=== Module Packs
==== `module` and records
==== `provide`
==== `require`
==== `export`
==== `import`

=== Top-Level Program

=== Summary
==== `forall`, `lambda`  and Arrow Expression
==== `function`, `macro`, `type`, `class`, `module` and Arrow Expression
==== `Constraint` and `Include`
