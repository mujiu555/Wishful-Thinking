#import "/lib/lib.typ": *

#show: schema.with("page")

#title[CIS 194: Introduction to Haskell]
#date[2026-03-14 22:08]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Haskell Basics

Haskell is:
+ Functional: first-class functions, expressions
+ Pure: referentially transparent, no mutation, no side effects, same calling result in same output.
+ Lazy: lazy evaluation,
  - easy to define new control flow
  - easy to define infinite data structures
  - enable more compositional programming style
+ Statically typed

== Declaration & Variables

use:
```hs
x :: Int
x = 3
```

`::` represents "has type" here.
With `=`, x defined to be 3 and will never get changed.

== Comments

```hs
-- is line comments

{-
multiple line comments
-}
```

== Basic Types

- Int: max sized integer
- Integer: Big Integer
- Double
- Float
- Bool: True/False
- Char: Unicode Characters: 'x'
- String: Char String: "..."

== Arithmetic

=== Integer:

+ `+`:
+ `-`:
+ `*`:
+ `/`: Float point division
+ `div`: Integer division
+ `mod`:
+ `^`: power
+ `(-)`: negative

If you place prefix inside a pair of "\`", the function will be turned into infix operator.
If you place infix operator in brackets and in front of other operands, it will be turned into a function call.

=== Boolean

+ `&&`
+ `||`
+ `not`

+ `>`
+ `<`
+ `>=`
+ `<=`

=== If

`if <b> then <t> else <f>`

Haskell prefer to use pattern match or guards instead of if expressions.

== Functions

```hs
sumtorial :: Integer -> Integer
sumtorial 0 = 0
sumtorial n = n + sumtorial (n - 1)
```

`Integer -> Integer` means taking a integer as input and response with another integer as output.

When calling a function, each clause is checked in order from top to bottom.
The first one which matches the arguments is chosen.

Or, similarly:
```hs
hailstone :: Integer -> Integer
hailstone n
  | n `mod` 2 == 0 = n `div` 2
  | otherwise      = 3 * n + 1
```

Based on arbitrary boolean expression using guards.
Some guards associated with each clause of a function definition, and if clause's pattern match, and the first one guard evaluated to True is chosen.

As for,
```hs
foo :: Integer -> Integer
foo 0 = 16
foo 1
  | "Haskell" > "C++" = 3
  | otherwise         = 4
foo n
  | n < 0             = 0
  | n `mod` 17 == 2   = -43
  | otherwise         = n + 3
```

thus:
```hs
foo (-3) -- > 0
foo 0    -- > 16
foo 1    -- > 3
foo 36   -- > -43
foo 38   -- > 41
```

=== Tuples

Type `(T, T2, ...)`, together with value `(v, v2, ...)`

=== Currying

In Haskell it is suggested to have:
```hs
f :: Int -> Int -> Int -> Int
f x y z = x + y + z
```

And calling with:
```hs
f 3 17 8
```

Which is same as:
```hs
f :: Int -> (Int -> (Int -> Int))
f x y z = x + y + z
((f 3) 17) 8
```

== Combining functions

= Algebraic Data Types

#link("book.realworldhaskell.org")[Real World Haskell]

== Enumeration Types

```hs
data Thing = Shoe
           | Ship
           | SealingWax
           | Cabbage
           | King
   deriving Show
```

Declares a new type called `Thing` with 5 data constructors. They are only values of type `Thing`.
`deriving Show` is a magical incantation to generate code automatically.

```hs
shoe :: Thing
shoe = Shoe

list0'Things :: [Thing]
list0'Things = [Shoe, Ship, SealingWax, Cabbage, King]
```

Thus we can have functions:
```hs
isSmall :: Thing -> Bool
isSmall Shoe = True
isSmall Ship = False
isSmall SealingWax = True
isSmall Cabbage = True
isSmall King = False
```
Which can be simplified to:
```hs
isSmall :: Thing -> Bool
isSmall Ship = False
isSmall King = False
isSmall _    = True
```

Haskell provides more general algebraic data types,
```hs
data FailableDouble = Failure
                   | OK Double
   deriving Show
```
Failure takes no argument, while OK takes a Double as argument.
Thus Failure is a value of type `FailableDouble`, OK not.

Data constructors can have more than one arguments.

== Pattern Matching

To match a constructor with more than one parameter, wrap entire pattern with parentheses.
Underscore `_` is a wildcard pattern, which matches anything but doesn't bind to a name.
To match whole pattern while each part of it is still matched by `pat`, using `x@pat`.
Patterns can be nested.

e.g., to match failable double:
```hs
f :: FailableDouble -> Double
f Failure = 0
f (OK d) = d
```

== Case

```hs
case "Hello" of
  []    -> 3
  (x:s) -> length s
  _     -> 7
```

== Recursive data types

Define data types in terms of themselves.

= Recursion patterns, polymorphism, and the Prelude.

`map`, `filter`, `foldr`, `zip`...

== Polymorphism

=== Polymorphic data types

With free variable in data definition, for which, those variables are called type parameter,
we can define polymorphic data types.

=== polymorphic functions

When writing polymorphic functions, it is needed to keep in mind that caller can determine the type of callee.

So polymorphic functions must work for every possible input type.

== Total and partial functions.

Functions which are well defined for every possible input and respond with a value of the correct type are called total functions.

Functions which may crash with some specified input or may recurse forever are called partial functions.

It is never suggested to write partial functions.


