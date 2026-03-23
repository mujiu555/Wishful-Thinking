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

= Higher-order programming and type inference

Anonymous function:
Beginning with `\` and any number of parameters,
the body of lambda is just after `->`.

E.g., to have
`greaterThan100 :: [Int] -> [Int]`
we can write:
```hs
greaterThan100 xs = filter (\x -> x > 100) xs
```

Another way to do that is provide `(> 100)`, which is same as `\x -> x > 100`.
`(?y)` is same as `\x -> x ? y`, while `(y?)` is same as `\x -> y ? x`.

== function composition

Function x dot (`.`) function y, gives function x (function y).

== Currying and partial application

Every function in Haskell is lambda expression that accepts only one argument,
thus multiple parameter functions are curried.

Thus if we provides only some of the arguments, we get back a function that takes the remaining arguments.
This is called partial application.

== Wholemeal programming

Prefer to combine functions rather than work deep inside.

Point-free style says that define a function without reference to its arguments.

= more polymorphism and type classes

Haskell has a special type of polymorphism called parametric polymorphism.
Which means that polymorphic functions must work uniformly for any input type.

== Parametricity

With type mentioned before: `a -> a -> a`, since `a` is a lowercase parameter, it is not a Type but a type variable, which can stand for any type.

The problem is that, if we have something like:
```hs
f :: a -> a -> a
f x y = x && y
```
Which will throw an error, since `&&` only works for `Bool`, but `a` can be any type.
As the `a -> a -> a` is just a promise, that a function with this signature will work no matter what type the caller chooses.

== Type Classes

Double arrow like `(+) :: Num a => a -> a -> a` is type-class-constrainted type signature.
E.g., in definition of `Eq`,
```hs
class Eq a where
  (==) :: a -> a -> Bool
  (/=) :: a -> a -> Bool
```
Eq is declared to be a type class with a single parameter, `a`.
Any type `a` that wants to be an instance of `Eq` must provide definitions for `(==)` and `(/=)`.

So,
when any type class method is called, the compiler will infer which implementation of that method will be used.
Likely overloaded method in OOP.

And what if we'd implement a new instance?
```hs
data Foo = F Int | G Double

instane Eq Foo where
  (F i1) == (F i2) = i1 == i2
  (G c1) == (G c2) = c1 == c2
  _ == _ = False

  foo1 /= foo2 = not (foo1 == foo2)
```

For which, it is also possible to define default implementations of methods in terms of other methods.

Thus `Eq` can be defined as:
```hs
class Eq a where
  (==) :: a -> a -> Bool
  (/=) :: a -> a -> Bool
  x /= y = not (x == y)
```
And the actually declaration of `Eq` in Prelude is:
```hs
class Eq a where
  (==), (/=) :: a -> a -> Bool
  x == y = not (x /= y)
  x /= y = not (x == y)
```

Type classes can have more parameters than only one.
Which looks like generic function in Common Lisp CLOS.

= Lazy Evaluation

== Strict evaluation

Contrast to lazy evaluation, strict evaluation means that an expression is evaluated as soon as it is bound to a variable.
When we try to call a function with strict evaluation, the arguments will be evaluated before the function is called.

The strict evaluation policy, aka. call-by-value may lead to some side effects, since we cannot control when the arguments are evaluated as lazy evaluation does.

== Side effects and purity

Side effects are anything chat causes evaluation of an expression to interact with something outside itself.
The root issue is that sch outside interactions are time-sensitive.

== Lazy evaluation

Arguments in lazy evaluation strategy are not evaluated until they are actually used in the body of the function.

== Pattern matching drives evaluation

= Folds and monoids

Monoids, in Chinese, is called "幺半群", which is a set with an associative binary operation and an identity element.

== Folds, again

For each `Fold*` function, that there is a take-away message that we can implement a fold for may data types.
The fold for T will take one higher-order argument for each of T's constructors,
encoding how to turn the values stored by that constructor into a value of the result type.

Assuming that any recursive occurrences of T have already been folded into a result.

== Monoids

In `Data.Monoid`, there is a type class `Monoid`,
where there are:
```hs
class Monoid m where
  mempty  :: m -- m empty
  mappend :: m -> m -> m -- m append, which is associative

  mconcat :: [m] -> m
  mconcat = foldr mappend mempty

(<>) :: Monoid m => m -> m -> m
(<>) = mappend
```

New type:
```hs
newtype Sum a = Sum a
  deriving (Eq, Ord, Read, Show, Num)

getSum :: Sum a -> a
getSum (Sum x) = x

instance Num a => Monoid (Sum a) where
  mempty  = Sum 0
  mappend = (+)

newtype Product a = Product a
  deriving (Eq, Ord, Read, Show, Num)

getProduct :: Product a -> a
getProduct (Product x) = x

instance Num a => Monoid (Product a) where
  mempty  = Product 1
  mappend = (*)
```

P.S., `newtype` is used for defining a new type that has exactly one constructor with exactly one field.
It is used to add type class instances to an existing type without having to define a new data type and wrap it in a constructor.

P.S., `type` can be used to define a type synonym, which is just an alias for an existing type. It does not create a new type, but simply gives a new name to an existing type.

P.S.,
```hs
fun_a . fun_b . fun_c a $ b
```
is equivalent to:
```hs
(fun_a (fun_b (fun_c a))) b
```

= IO

With lazy evaluation, Haskell is purely functional, however it means that any Haskell program can do nothing but waste CPU time.
Since functional can have no external effects and shall not depend on any external state or stuffs.

== The IO type

To solve the problem, there is a special type called `IO`.
Values of type `IP a` are descriptions of effectful computations (多副作用表达式计算),
which, will generate some IO operations and produce a value of type `a` when those operations are performed.

A value of type `IO a` is a safe thing with no side effects.
It is a description of a computation.
Likely, first-class instructions program. (imperative program)

It is a recipe for generate a value of type `a` when executed.

For ```hs main :: IO ()``` we can pass other IO to `main`.

== Combining IO

To combine two IO computations, we can use `>>` operator, "and then".
It has the type `(>>) :: IO a -> IO b -> IO b`,

It creates an IO computation consists of performing the first computation, discarding its result, and then performing the second computation, in sequence.

Or, we can have `(>>=) :: IO a -> (a -> IO b) -> IO b`, "bind", which is more powerful than `>>` since it allows us to use the result of the first computation to determine the second computation.

== Record syntax

Suppose we have a data type:
```hs
data D = C T1 T2 T3
```
which is not very convenient to use, since we have to remember the order of the fields and their types.
Thus we can use record syntax to define a data type:
```hs
data D = C { field1 :: T1}
           , field2 :: T2
           , field3 :: T3
           }
```
Which assigns not only the type of each field, but also a name for them.
We can still construct C in pattern matching, but there are some extra benefits:
- field names are automatically defined as functions that extract the corresponding field from a value of type D.
  ```hs
  field1 :: D -> T1
  ```
- Construct, modify, and pattern match on values of type D using field names instead of positional syntax.
  ```hs
  c = C { field1 = v1, field2 = v2, field3 = v3 }
  --
  c' = c { field2 = new_v2 }
  --
  case c of
    C { field1 = f1, field3 = f3 } -> ... f1 ...
  ```

= Functors

What if we can treat types that accepts some type variable as something function-like?
Can we apply some function-like type variables when defining variables?
E.g., can we have ```hs thingMap :: (a -> b) -> f a -> f b```.
In some repeated patterns, the part that is different, is the container being "mapped over", which is what we want.

== Kinds

Types themselves have types, which is called `Kinds` in Haskell.
P.S., There are some other level beyond kinds outside of the Haskell, for example maybe pure type system or universe.

With internal command `:kind` or `:k` in ghci, we can have the type of some types.

Most types that are just concrete types have the kind of `*`, while those who have type parameters may have kind
`* -> *` or more, this is vary similar to functions.

`(->)` have the type of `* -> * -> *`, which means it accepts two types and generates a new one.

What's more, if we have some type like:
```hs
data Funny f a = Funny a (f a)
```
the kind of `f` is `* -> *` and thus, Funny is a higher-order type constructor, just like `map`, a higher-order function.

Kinds can be partially applied, too.

== Functor

The essence (本质) of the mapping pattern we saw was a higher-order function with a type like
```hs thingMap :: (a->b) -> f a -> f b``` where `f` is a type variable standing in for some type of kind `* -> *`.

But how can we use it.

Indeed, we may create a type class called `Functor` traditionally since `thingMap` has to work differently for each `f`.
```hs
class Functor f where
  fmap :: (a -> b) -> f a -> f b
```

Even, we can have
```hs
instance Functor ((->) e) where
  fmap = (.)
```
