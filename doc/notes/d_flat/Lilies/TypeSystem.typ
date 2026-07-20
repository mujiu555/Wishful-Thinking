
== Type System

=== Overview of the Type System

==== Type System Goals

==== Hindley-Milner Type System

==== Formal Definition

==== Soundness and Completeness

=== Primary Types

==== Numeric Types

==== Boolean Type

==== Character Type

==== Empty Type & Unit Type

==== Sequence Types

===== String

===== ByteVector

==== Pair Types & List Types

List is a recursive data type that comes from the pair type, which is a product type of two elements.

List is a variable-length sequence of elements of the different type, while pair is a fixed-length sequence of two elements of the different type.

==== Array Types & Vector Types

Array is a variable-length sequence of elements of the same type,
while vector is a fixed-length sequence of elements of the same type.

Literal array and vectors are supported using square brackets,
e.g., `[1 2 3]` is a literal array of three integers, and `#[1 2 3]` is a literal vector of three integers.

==== Slice Type

==== Tuple Types

Tuple is a fixed-length sequence of elements of the different type,
its behaviours likely much to the unnamed structure.

==== Symbol Type

Symbol is a unique identifier that can be used to represent variables, functions, and other entities in the language.

=== First-Class Types

=== Higher-Rank Types

=== Decision: No First-Class Types

=== First-Class Functions

=== Composite Types & User-Defined Types

==== Algebraic Data Types (ADTs): Sum Types and Product Types

==== Union Types: Sum Types

```txt
(union
  (<variant-name> <variant-type>)
  ...)
```

The type of a variant is not limited to a named type,
you can place another anonymous union or anonymous structure as the type of a variant.

==== Structure Types: Product Types --- Another view of Tuple

```txt
(struct
  (<field-name> <field-type>)
  ...)
```

e.g.,
```txt
(define foo
  (Type)
  (struct
    (:x (Integer))
    (:y (Integer))))
```

==== Abstract Data Types (ADTs): Encapsulation and Information Hiding

==== Trait: Type Classes

===== Trait Definition

```txt
(trait
  (<method-name> <method-signature>)
  ...)
```

e.g.,
```txt
(define foo
  (Class)
  (trait
    (:bar (function ((x : (Integer))
                     (y : (Integer)))
      : ((result : (Integer)))))))
```

Naming convention, method-name defined in the trait should be prefixed with a colon, e.g. `:method-name`, to avoid name collision with other methods.

===== Trait Composition

==== Type Family: Generic Programming

=== Fields

==== Field Access

```txt
(field <obj> <field-name>)
```

=== Methods

==== Method Access

```txt
(method <obj> <method-name>)

(method <type> <method-name>)
```

==== Method Invoking

```txt
((method <obj> <method-name>) <args>)
((method <type> <method-name>) <args>)
```

==== Static Dispatch

```txt
((method <obj> <method-name>) <args>)
((method <type> <method-name>) <args>)
```

==== Dynamic Dispatch

===== Dynamic Dispatch via Virtual Table (VTable)

===== Dynamic Wrappers & Fat Pointers

===== Dynamic Dispatch via Type Parameters

==== Abbreviated Method Invocation

```txt
({<method-name> <obj>} <args>)
```

=== Variants

==== Variant Access

```txt
(variant <obj> <variant-name>)
```

==== Use of Variants

=== Polymorphism

==== Parameterized Polymorphism

We did a little change to the define form to support parameterized polymorphism on types,
by write `(define (foo a) ...)` instead of `(define foo ...)`, where `a` is a type parameter.
You can also write `(define (foo a b) ...)` to define a function with multiple type parameters.
Zero type parameter is also supported, by write `(define (foo) ...)` instead of `(define foo ...)`.

Sometimes you may need to specify the type of a parameterized polymorphic argument,
`(define (foo (a : Functor) ...)` is then added to specify that the type parameter `a` must instance the `Functor` trait.
For multiple type parameters, you can write `(define (foo (a : Functor) (b : Monad) ...)` to specify that the type parameter `a` must instance the `Functor` trait and the type parameter `b` must instance the `Monad` trait.
Furthermore, if multiple constraints are needed for a type parameter,
you can write `(define (foo (a : Num Monad) ...)` to specify that the type parameter `a` must instance both the `Num` and `Monad` traits.

That is,
e.g.,
```txt
(define (Too (a : Functor))
  (Class)
  (trait ...))
```

`(Class)` annotates that `Too` is a typeclass, which is not belongs to value universe, but belongs to type universe.

This split the semantics into two parts, the type universe and the value universe.

P.S., Later in Macro system description, if we place `(Syntax)` in the place of `(Class)`, then `Too` is a syntax, which is a macro indeed then.

The `(define (<name> <type-parameter-list>) <type> <val>)` form defines generic polymorphic types.
It is adoptive to all the types no matter it is a first-class type or type kind or syntax.
In traditional languages like Rust, it is
```rs
trait <T: Functor> Too {
  ...
}
```
Or in Haskell, it is
```hs
class Functor a => Too a where
  ...
```

Define zero type parameter is also supported, by write `(define (foo) ...)` instead of `(define foo ...)`.
However, since the type parameter list is empty, `(foo)` is kind of `*`, which always downgrade to `Type`,
thus, it is not necessary to write `(define (foo) (Type) ...)` instead of `(define foo (Type) ...)`.

P.S., Actually, `(Type)` here is also the case, for which brackets are not necessary, thus, `(define foo Type ...)` is also valid.
Furthermore, the `(Integer)` used all around also has the same problem.

If you define new type with no type parameter, but with a pair of brackets, the compiler should warn you that the brackets are redundant, and you can remove them.
If you use new type or kind or other higher-rank type that are not type constructors, then the compiler should warn you that the brackets are redundant, and you can remove them.

The definition for type classes is also the same.

---

Or, should we abandon the HM type system and, adopt a more powerful type system, which may support higher-order polymorphism, dependent types, and type-level programming?
Or even we can have first-class types?
we can than define parameterized polymorphic in the way like
```txt
(define poly
  (function ((x : (Type)))
    : ((result : (Type))))
  (lambda (x)
    (trait
      (:foo (function ((x : x))
        : ((result : x)))))))
```
Powerful, but also more complex, reaches the turning incomplete point of the type system, and may be too much for a simple language.

May we use it?

===== Type Parameter

==== Row Polymorphism

==== High-order Polymorphism

=== Implementation
==== Implementation without Traits
==== Implementation with Traits
==== Implementation with Multiple Traits
==== Implementation with Internal Helpers

==== `Self` Type

In the implementation of a type, there is a special kind of type called `Self`, it is a zero parameter generic type, which represents the type that is being implemented.
You may access concrete implemented type by using `(Self)` as other parameterized generic type.

=== Access Control

=== Constraints

=== Implementation of Type System
