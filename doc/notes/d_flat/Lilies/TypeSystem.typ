
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
    (:bar (function ((x #:type (Integer))
                     (y #:type (Integer)))
      #:returns ((result #:type (Integer)))))))
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

===== Type Parameter

==== Row Polymorphism

==== High-order Polymorphism

=== Implementation

```txt
(impl <type>
  <definitions>)
```

e.g.,
```txt
(impl foo (trait-foo)
  (define :bar
    (function ((x #:type (Integer))
               (y #:type (Integer)))
      #:returns ((result #:type (Integer))))
    (fn
      (lambda (x y) (+ x y)))))
```

==== Implementation without Traits

==== Implementation with Traits

==== Implementation with Multiple Traits

==== Implementation with Internal Helpers

==== Implementation with Type Parameters

=== Access Control

=== Constraints

=== Implementation of Type System
