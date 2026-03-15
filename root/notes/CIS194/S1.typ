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
