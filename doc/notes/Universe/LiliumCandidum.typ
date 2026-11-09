#import "@preview/tysty:0.1.0": entry
#import "../aut.typ": mujiu

#entry(
  title: [Lilium Candidum --- The Algebra of Abstraction: A Language of Types, Syntax, and Continuations],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  authors: (mujiu,),
  id: "universe-lilies",
  //parent-id: "universe-index",
  abstract: "
The language Lilium Candidum (Lilies) is designed to be a staged, statically typed language of bindings, abstractions, applications, and contexts, in which represent functional programming using at least as much primitives.
  ",
)[
  = Introduction

  // TODO: finish introduction

  = Overview of the Language

  // TODO: intro for overview

  == Types and Values

  Programs operate on values.
  Every value has a type.
  All value types described in this section are first-class:
  their values may be passed to functions, returned from functions, and stored in data structures.

  Detailed descriptions of types in Lilies are provided in later chapters.
  This section does not specify the detailed semantics of these types and their instances.

  === Primitive Types and Literal Forms

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
    Such data may be produced by quotation, contained in syntax objects,
    or returned by functions.

  === Compound Types

  Value types described in this section can be interpreted in runtime or compile-time computation.

  - Functions: Functions are values
  - Records:   Record values are instances of user defined nominal product types
  - Tuples (Number Indexed Records): Tuples are product types
  - Enumerations: Enumerations values are tagged variants of user defined nominal sum types
  + Never: Impossible value
  - Type-Class Dictionaries (Records):
    Type-class dictionaries are ordinary record values that provide implementations of a type-class interface.
    They are explicitly passed to functions.
  - Module Packs (Records): Modules are first-class values

  === Compile-Time only Entities

  Compile-time entities participate in compilation, expansion, or type checking.

  + Macros: Macros are compile-time functions
  + Types and Type Constructors:
    Types and type constructors are compile-time entities classified by kinds.
    They support type-level abstraction and application but are not ordinary runtime values.
  + Syntax Objects: Syntax objects are structured representations of
    program syntax that preserve lexical context and binding information

  == Expressions, Forms and Application

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

  === Application

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

  ;; NOTE: INVALID: rejected by the recursive type restriction.
  ;; (define id
  ;;   (forall (a)
  ;;     (mu (lambda (L)
  ;;       (function (:Self (tuple L a)) a))))
  ;;   (lambda f
  ;;     (case f ()
  ;;       ((_ a) a)
  ;;       (:else (error "")))))
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

  == Variables, Bindings, Signatures and Definitions

  To represent the computation process, the language choose to allowing users to binding a name and a value,
  the name that can be used for referring value (and memory) and the binding relation is called variable.

  There are two ways to create such definition.
  - Lambda Parameter - Application Argument Provider
  - Definition

  === Variable and Lexical Scope

  Generally, if you have defined a variable, then its value will never changed within its scope.
  Thus you can treat it directly as the value itself.

  The language adopt a name resolving method called lexical scope.
  That is, any function or something similar will only be able to capture free variables from its definition environment,
  so, prevent program from variable occasionally capturing.

  Traditionally, Lisp System use dynamic scope,
  even scheme, the first dialect to adopt lexical scope, provides dynamic-let (parameterized).
  However, this might make whole system impure.

  ==== `lambda` Parameter

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

  === Signature

  A signature describes the type of an entity and the requirements imposed on its components.

  Signature constructors are type-producing constructs.
  They produce types, and their results may be used wherever a type is expected.

  Lilies provides signature constructors for functions, macros, type constructors, type classes, and modules.
  Although these signatures describe different categories of entities, they participate in the same type system.

  ==== Function and Macro Signatures

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

  ==== Parameterized Type Constructor

  ```lisp
  (type (:Self <type>...) <type-sig>)                           ; Type Constructor            Signature
  (class (:Self <type>...) <type-sig>)                          ; Type Class                  Signature
  ```

  Types and Classes can be constructed in same way.
  This is a method to implement parameterized polymorphism.
  They can accept parameter list only.

  ==== Module

  ```lisp
  (module (:Self <type>...) <module-sig>)                       ; Module                      Signature
  ```

  Module is used to create parameterized module type.
  But actually, you can use `type` to create same one.

  ==== Type-Class, Super Type and Constraint

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

  === Binding

  Lilies provides two fundamental ways to introduce bindings:

  - *Lambda Parameters*:
    Bind arguments supplied by an application to the parameters of a lambda expression.
  - *Definitions*:
    Introduce named entities within a scope.

  The `let` form provides a convenient way to introduce local bindings.
  It is equivalent to an immediately applied lambda expression.

  ==== `define`

  A `define` form introduces a named binding within the enclosing scope.

  ```lisp
  (define <name> <type> <value>)
  ```

  - `<name>` is the identifier being defined.
  - `<type>` specifies the declared type of the binding.
  - `<value>` provides the entity associated with the identifier.

  The defined entity must satisfy its declared type.
  Once defined, the identifier may be used to refer to the associated entity within its scope.

  For example:
  ```lisp
  (define answer #int 42)

  (define add
    (function (:Self #int #int) #int)
    (lambda (a b) (+ a b)))
  ```
  Definitions may introduce both runtime values and compile-time entities, such as types and macros.

  Definition can visit all names within same scope, but it cannot invoke values before they are initialized.

  ==== `let` Family

  A `let` form introduces local bindings that are accessible within its body.

  ```lisp
  (let ((: <name> <type> <val>)...) <body>)
  (let:seq ((: <name> <type> <val>)...) <body>)
  (let:rec ((: <name> <type> <val>)...) <body>)
  (let:seqrec ((: <name> <type> <val>)...) <body>)
  ```

  - `let` binds values with their name before enter its body
  - `let:seq` binds values sequentially
  - `let:rec` allows mutual recursion
  - `let:seqrec` binds values sequentially, with still allow for mutual recursion

  == Functions, Macros and Lambda

  Functions are first-class values representing computations parameterized by arguments.

  A function may be passed as an argument to another function, returned as a result, or stored in a data structure.

  Every function has a function type, described by a `function` signature.
  Function signatures specify the accepted arguments and the result type, as described in the *Signatures* section.

  Functions are constructed by evaluating lambda expressions.

  === Function Values

  A function value is conceptually a closure consisting of a lambda expression and the lexical bindings required by its body.

  The environment captured by a function is determined by the lexical scope in which its lambda expression is evaluated,
  rather than the environment from which the function is subsequently called.

  The physical representation of a function value and its captured environment is implementation-dependent.

  For example:
  ```lisp
  (define make-adder
    (function
      (:Self #int)
      (function (:Self #int) #int))
    (lambda (x)
      (lambda (y)
        (+ x y))))
  ```
  The inner function refers to `x`, which is bound in the enclosing function.

  When the inner lambda is evaluated, the resulting function retains access to that binding.

  === Function Application

  A function application invokes a function with the supplied arguments.

  The function expression is evaluated to obtain a function value.
  Its operands are then evaluated from left to right, and their resulting values are bound according to the function's parameter form.

  The body is evaluated in the function's lexical environment extended with those parameter bindings.

  The result of the body becomes the result of the application.

  All required arguments must be provided in a single application. Lilies does not support implicit partial application.

  For example:
  ```lisp
  (define add
    (function (:Self #int #int) #int)
    (lambda (x y)
      (+ x y)))

  (add 10 20)
  ```
  The application evaluates to `30`.

  An application is well-typed only if the supplied arguments satisfy the function's signature.

  === Higher-Order Functions

  Functions are first-class values and therefore may be supplied to or returned from other functions.

  A function that accepts or returns another function is called a higher-order function.

  For example:
  ```lisp
  (define apply-twice
    (function
      (:Self
        (function (:Self #int) #int)
        #int)
      #int)
    (lambda (f x)
      (f (f x))))
  ```
  Higher-order functions follow the same binding, application, and evaluation rules as other functions.

  === Polymorphic Functions

  A function may have a universally quantified type.

  Such a function can be instantiated at different types according to its signature.
  ```lisp
  (define id
    (forall (a)
      (function (:Self a) a))
    (lambda (x) x))
  ```
  Polymorphic functions are first-class values. They may be passed to other functions, returned as results,
  or stored in data structures without necessarily losing their polymorphic types.

  The rules for type abstraction, instantiation, and checking are specified in the type system chapter.

  === Macros

  Macros are compile-time functions whose results are interpreted as program syntax.

  When a macro is applied, its body is evaluated at compile time.
  The resulting syntax object replaces the original macro application.

  Macro expansion is hygienic:
  the lexical context and binding identities preserved by syntax objects are respected during expansion,
  preventing accidental identifier capture.

  The resulting syntax is recursively expanded and processed according to the syntactic context of the original application.

  Macro expansion continues until the expression contains no further macro applications requiring expansion.

  === Lambda Expressions

  A lambda expression constructs a function value.

  The parameter form of a lambda determines how arguments are bound when the resulting function is applied,
  as described in the *Lambda Parameter* section.

  A lambda expression is checked against its expected function signature.
  The signature provides the types of its parameters and the expected result type of its body.

  Evaluating a lambda expression produces a function value without evaluating its body.
  The body is evaluated when the resulting function is applied.

  === Lexical Closures

  A function value is a lexical closure consisting conceptually of
  a lambda expression and the lexical environment required to evaluate its body.

  A closure preserves the bindings of free variables from the environment in which the lambda expression is evaluated.

  These bindings remain accessible when the closure is applied,
  independently of the environment from which it is called.

  For example:
  ```lisp
  (define make-adder
    (function
      (:Self #int)
      (function (:Self #int) #int))
    (lambda (x)
      (lambda (y)
        (+ x y))))
  ```
  The inner lambda refers to `x`, which is bound by the enclosing lambda.
  The resulting closure preserves this binding even after the enclosing application has completed.

  The physical representation of a closure and its captured environment is implementation-dependent.

  == Syntactic Type, Literal, Datum Value and Semantic Interpretation

  Lilies distinguishes the syntactic representation of programs
  from the values and meanings obtained through their interpretation.

  An S-expression describes the structural form of syntax.
  A datum is an S-expression interpreted as data.
  A syntax object represents program syntax together with lexical information
  required for binding resolution and hygienic macro expansion.

  The same syntactic structure may admit different interpretations depending on its context.

  === S-Expression

  An S-expression (`sexpr`) is the syntactic type used to represent the structural form of Lilies programs.

  The set of S-expressions is defined inductively:
  ```text
  <sexpr>
  ::= <atom>
    | ()
    | (<sexpr> . <sexpr>)
    | <sequence>

  <atom>
  ::= <integer>
    | <rational>
    | <real>
    | <boolean>
    | <character>
    | <string>
    | <symbol>
    | <syntax-symbol>

  <sequence>
  ::= {sexpr}
  ```

  Here, `<atom>` denotes an atomic syntactic form corresponding to one of the primitive literal categories defined earlier.
  The empty list `()` and pairs are the fundamental compound structures of S-expressions.

  A proper list is a finite sequence of pairs terminated by the empty list.
  List notation is an abbreviation for nested pairs:
  ```lisp
  (a b c)
  ```
  is structurally equivalent to:
  ```lisp
  (a . (b . (c . ())))
  ```

  An improper list is a sequence of pairs whose final `cdr` is not the empty list.
  For example:
  ```lisp
  (a b . c)
  ```
  is structurally equivalent to:
  ```lisp
  (a . (b . c))
  ```

  Every atom, the empty list, and every pair whose components are S-expressions is itself an S-expression.

  This definition specifies only the syntactic structure of S-expressions.
  Their interpretation as expressions, datum values, or syntax objects is defined separately.

  === Literal

  A literal is a syntactic form that denotes a value according to the interpretation rules of its context.

  Lilies provides literal forms for primitive values, as described in the "Primitive Types" section.

  For example:

  ```lisp
  42
  #true
  "hello"
  #\a
  ```

  A literal form is distinct from the value it denotes. For example, `42` is a syntactic representation of an integer value, not the value itself.

  Literal forms may occur as components of larger S-expressions without being independently evaluated.

  === Datum Values

  A datum is a value obtained by interpreting an S-expression as data rather than as a program expression.

  The `quote` form provides this interpretation without evaluating its operand.

  Datum values preserve the structure of the represented S-expression,
  but not the lexical context or binding identities associated with program syntax.

  Datum values are first-class values.
  They may be passed to functions, returned from functions, and stored in data structures.

  Consequently, datum values alone are insufficient to preserve binding relationships during hygienic macro expansion.

  === Syntax Objects

  A syntax object is an S-expression variant that associates an S-expression with lexical context information
  required for lexical binding resolution and hygienic macro expansion.
  Syntax objects are represented by the `synobj` variant of the S-expression type:
  ```text
  data <sexp>
   = ...
   | synobj <context> <sexp>
  ```

  The `synobj` variant consists of two components:
  - *Context:* The lexical context associated with the wrapped S-expression.
  - *S-expression:* The syntactic content to which the context is associated.

  Since the wrapped content is itself an S-expression, syntax objects may be nested and may occur as components of other S-expressions.

  ==== Syntax Objects and Datum Values

  S-expressions may be interpreted as program syntax or as datum values, according to their interpretation context.

  A syntax object preserves the lexical information associated with program syntax.
  An ordinary datum does not preserve this information.

  Converting syntax into a datum removes the contextual information used for binding resolution,
  while retaining the underlying S-expression content.

  The conversion from a datum to syntax requires the provision or establishment of suitable lexical context information.
  Such conversion does not recover lexical information previously discarded.

  == Records, Enumerations, Tuples and Algebraic Data Types

  An algebraic data type is a type constructed by combining other types using two fundamental operations:
  - Product types (AND): A value contains multiple components simultaneously.
  - Sum types (OR): A value is one of several possible alternatives.

  === Product Type

  A product type combines multiple types into a single type.
  Each value contains one component of each constituent type.

  For types $A$ and $B$, their product is written as:

  $ A times B $

  A value of $A times B$ contains both a value of type $A$ and a value of type $B$.

  In Lilies, records and tuples are product types.
  Records identify components by name, while tuples identify them by position.

  === Sum Type

  A sum type combines multiple types as alternatives.
  Each value belongs to exactly one alternative.

  For types $A$ and $B$, their sum is written as:
  $ A + B $
  A value of $A + B$ contains either a value of type $A$ or a value of type $B$,
  together with a tag identifying the chosen alternative.

  In Lilies, enumerations are sum types.
  Each enumeration defines named variants that may carry associated data.

  === `record`

  ==== Type Construction

  In type construction, `record` defines a nominal product type consisting of named fields.

  Each field specifies a name and a type.
  A value of the resulting record type must provide a value for every required field.

  ```lisp
  <record>
    ::= (record {naming binding})

  <naming binding>
    ::= (: <name> <type>)

  <name>
    ::= <sym>
  <type>
    ::= <sexpr>
  ```
  You may use record to define unit as:
  ```lisp
  (define unit * (record))
  ```
  This is a type that have only one instance.

  Record types are nominally distinguished,
  even when they contain identical field definitions.

  ==== Instance Construction

  In instance construction, `record` creates a record value from named field values.

  Each field associates a name with an expression.
  The expressions are evaluated to obtain the corresponding field values.

  ```lisp
  <record>
    ::= (record {naming binding})

  <naming binding>
    ::= (: <name> <val>)

  <name>
    ::= <sym>
  <val>
    ::= <sexpr>
  ```
  Mostly same as type construction, the only difference is
  that it can only accept evaluated values in the place where previously to be type instance.
  ```lisp
  (define foo
    (record (: bar #int))
    (record (: bar 10)))
  ```
  It is possible to define instance without even actually define a type instance.
  However, since the type is nominal, it will not be able to distinct and evaluate it in later program.

  The resulting value must satisfy the expected record type.

  === `:include`

  ==== Type Construction

  In record type construction, `:include` incorporates the fields of
  another record type into the type being defined.

  The included fields become part of the resulting record type,
  retaining their names and types.

  ```lisp
  <:include>
    ::= (:include <type>)

  <type>
    ::= <sexpr>
  ```

  The resulting record type retains its own nominal identity.

  ==== Instance Construction

  In record instance construction, `:include` incorporates the fields of
  an existing record value into the record being constructed.

  ```lisp
  <:include>
    ::= (:include <val>)

  <val>
    ::= <sexpr>
  ```

  The included fields retain their names and values and
  must satisfy the corresponding fields of the resulting record type.

  === `tuple`

  ==== Type Construction

  In type construction, `tuple` defines a product type consisting of
  an ordered sequence of component types.

  Tuples are simply numeric named records.
  As a convenient method to define a product type
  with sequence of different type.

  ```lisp
  <tuple>
    ::= (tuple {type})

  <type>
    ::= <sexpr>
  ```

  The number, order, and types of the components determine
  the structure of the tuple type.

  ==== Instance Construction

  In instance construction, `tuple` creates a tuple value from
  an ordered sequence of expressions.

  ```lisp
  <tuple>
    ::= (tuple {val})

  <val>
    ::= <sexpr>
  ```

  Each expression provides the value of the component at
  its corresponding position.

  The number and types of the resulting components must satisfy
  the expected tuple type.

  === `enum`

  ==== Type Construction

  In type construction, `enum` defines a nominal sum type
  consisting of named variants.

  Each variant has a distinct name and may specify
  associated component types.

  ```lisp
  <enum>
    ::= (enum {naming binding})

  <naming binding>
    ::= (: <name> <type>)

  <name>
    ::= <sym>
  <type>
    ::= <sexpr>
  ```
  It is possible to define enumerator without any variant,
  but it meaning nothing.

  Since it is not possible to construct an enumerator instance without any variant.
  Bottom type never can be defined as:
  ```lisp
  (define never * (enum))
  ```

  A variant with type unit represents a single alternative without additional data.

  ==== Instance Construction

  In instance construction, `enum` creates a value of an enumeration type by
  selecting one of its variants.

  ```lisp
  <enum>
    ::= (enum <naming binding>)

  <naming binding>
    ::= (: <name> <val>)

  <name>
    ::= <sym>
  <val>
    ::= <sexpr>
  ```

  The selected variant determines the tag of
  the resulting value and the types of any associated components.

  The supplied component values must satisfy the definition of the selected variant.

  === `#type` and `*`

  `#type` is the type signature.
  It labels a type with level.

  Commonly, we defines `*` as `(define * (#type 2) (#type 1))`.

  === Nested Instance Construction

  For nested instance construction, we follow the rules:
  - expressions in the position of value, must have same type as signature declared.
  - value construction may have same layout of type definition.

  == Polymorphism

  === `forall`
  === `type`
  === `constraint`
  === `include`

  == Type Classes
  === `class`

  == Conditional Expression and Loops
  === "`if` then else"
  === `when`, `unless` the Macro
  === `cond`, `switch` the Macro
  === `loop` the Macro
  === `while`, `until` the Macro
  === `for` the Named Let
  === `foreach` the Map
  === `:break`
  === `:continue`

  == Pattern Match
  === `match`
  === `case`
  === Literal
  === `:or`
  === `:and`
  === `:as`
  === Pattern Variable
  === Wildcard
  === `:else`
  === "Ctor" Extraction
  === `:guard`

  == Delimited Continuations
  === `reset`
  === `shift`

  == $"System" F_omega^mu$

  === Type Universe

  == Module Packs
  === `module` and records
  === `provide`
  === `require`
  === `export`
  === `import`

  == Top-Level Program

  == Summary
  === `forall`, `lambda`  and Arrow Expression
  === `function`, `macro`, `type`, `class`, `module` and Arrow Expression
  === `Constraint` and `Include`
]
