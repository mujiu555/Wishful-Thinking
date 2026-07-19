{-
---
fulltitle: User-defined datatypes and Trees
date: September 16, 2024
---
-}

module Datatypes where

import Test.HUnit
import Prelude hiding (Either, Just, Left, Maybe, Nothing, Right)

-- https://www.seas.upenn.edu/~cis5520/current/lectures/stub/02-trees/Datatypes.html

{-
User-defined datatypes
======================

So far, we've mostly talked about how to use the types that appear in
the Haskell standard library.  We also discussed a few type synonyms,
like

    type XY = (Double, Double)

from the last lecture, but we haven't described any ways to define
really _new_ types.

Days
----

As a motivating example, suppose you are writing an application that
deals with calendars, and you need to represent the days of the week.
You might be tempted to `String` or `Int`, but both of these choices
have downsides.  If you use

    type Day = String

there will be lots of `Day`s that don't actually represent real days.
Also, you will need to devise and adhere to some sort of
standardization - is Monday represented by `"Monday"`, `"monday"`,
`"MONDAY"`, or `"Mon"`?  Should you handle more than one of these?

The choice

    type Day = Int

has similar problems.  There are lots of integers that won't represent
valid days.  And you'll have to remember whether you pick Sunday or
Monday to be the first day of the week, and whether it is represented
by 0 or 1.

Haskell has a better solution: user-defined datatypes.
-}

data Day
  = Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday
  deriving (Show, Eq)

{-
The new values (`Monday`, `Tuesday`, etc.) are called "constructors" or "data
constructors".  This is a very simple example of a datatype (basically just an
enumeration), but we'll see more examples soon.

The `deriving` line enables printing and equality for this datatype. We'll see
more about this next week, but it is common to do this for every datatype.
(If we leave this line off, we won't be able to use the `==` operator or
`show` function with these values. This is particularly important for working
with ghci (which uses `show` to print out the result of evaluation) and
`HUnit` which uses `==` to test equality.)

The great thing about datatype is that we can define functions by pattern
matching!  For example:
-}

nextWeekday :: Day -> Day
nextWeekday Monday = Tuesday
nextWeekday Tuesday = Wednesday
nextWeekday Wednesday = Thursday
nextWeekday Thursday = Friday
nextWeekday Friday = Monday
nextWeekday Saturday = Monday
nextWeekday Sunday = Monday

{-
This is great.  Now we don't have to worry about the difference between
`"Monday"` and `"monday"` or which integer corresponds to which day.  If we
make a typo (for example, write `Frday` instead of `Friday`), the compiler will
tell us _at compile time_.  If we forget to handle one of the days in some
function, the compiler will warn us about that too (via the incomplete patterns
warning, which we have enabled at the top of this file).

Let's write one more function on `Day`s, to compute when a package
will arrive by "two day shipping":
-}

twoBusinessDays :: Day -> Day
twoBusinessDays d = undefined

{-
Shapes
------

Datatypes can carry data values, too.  For example, here is a datatype
for representing shapes:
-}

data Shape
  = Circle Double Double Double
  | Rectangle Double Double Double Double
  deriving (Eq, Show)

{-
Here, `Circle` and `Rectangle` are the constructors - every `Shape`
value must be one or the other.  Each constructor takes some
arguments:

- A `Circle` is specified by three `Doubles`.  These represent the x
  and y coordinates of the center and the radius.

- A `Rectangle` is specifed by four `Doubles`.  The first two are
  the coordinates of the lower left corner, and the second two are the
  coordinates of the upper right corner.

We can pattern match on shapes.  For example, here is a function that
computes the area of any `Shape`:
-}

area :: Shape -> Double
area (Circle x y r) = pi * r * r
area (Rectangle llx lly urx ury) = width * height
  where
    width = urx - llx
    height = ury - lly

{-
Note that constructors are first-class Haskell values, and
-- like any value -- they have types.

For example the types of `Monday` and `Tuesday` shouldn't surprise you:

    Monday  :: Day
    Tuesday :: Day

The constructors that take arguments have _function_ types.  For
example, you must apply `Circle` to three `Double`s to get a `Shape`:

    Circle    :: Double -> Double -> Double -> Shape

    Rectangle :: Double -> Double -> Double -> Double -> Shape

However, note that although data constructors have types that look like
functions, they are not functions. From a syntactic point of view, the names
of data constructors start with capital letters so that they cannot be
confused with normal variables, which might be the names of functions.

Like functions, they can be applied to arguments. However, they have a
\*special power* that normal functions do not have: they can be used in pattern
matching. If we have a `Shape` we can see what data constructor we used to
create that `Shape`.

Datatype values also look different from function values. If we ask Haskell to
evaluate an expression of type `Day`, we are going to get one of the data
constructors. (i.e. `Monday`, `Tuesday`, etc.) On the other hand, function
values are lambda expressions (i.e. `\x -> x + 3`) or primitive operators.

Datatypes vs. Objects
=====================

At this point, you might think a little about the comparison between
representing shapes via datatypes in Haskell or via objects in a language like
Java. Maybe your introductory Java class uses subtyping to represent the same
relationship between Circle's and Rectangles. One way it could have done so is
with this code.

    interface Shape {
       public double area();
    }
    class Circle implements Shape {
       // fields
       private final double x;
       private final double y;
       private final double r;

       // constructor definition omitted

       public double area() {
         return Math.pi * r * r;
       }
    }
    class Rectangle implements Shape {
       // fields
       private final double llx;
       private final double lly;
       private final double urx;
       private final double ury;

       // constructor definition omitted

       public double area() {
          double width  = urx - llx;
          double height = ury - lly;
          return width * height;
       }
    }

In these class definitions, we have two object types `Circle` and `Rectangle`
that carry their associated data. The constructors for these objects act like
the data constructors of a datatype. The `area` method works for both circles
and rectangles, using dynamic dispatch instead of pattern matching to select
the appropriate code.

One difference between these two implementations is that Haskell datatypes are
easy to extend with new operations but harder to extend with new variants. If
we want a new operation on `Shape`s, we need only define a new function by
pattern matching. However, to add a new kind of `Shape` we need to add a new
variant to the datatype definition and update each of the function definitions
with a new case in the pattern matching. (The compiler will tell us if we miss
any.)

In Java, it is the reverse situation. We can easily add a new kind of `Shape`
by adding a new object that implements the interface. However, to add a new
operation, we need to edit the interface to include the new method and then
update all of the existing classes with the new method definition. (The
compiler will tell us if we miss any.)

This contrast between these two ways of defining data types is commonly called
\*the expression problem*.

Records
=======

One nice feature of the Java implementation is that it gives names to the
individual fields.

Suppose we would like to represent a point in space, using its `x` and `y`
coordinates. One way we might do so is with the following datatype definition:

        data Point = NewPoint Double Double

This line defines the `Point` type as the application of the data constructor `NewPoint`
to two `Double`s, the `x` and `y` coordinates of the point.
However, when we construct a point using this data constructor, we need to remember
that the first double corresponds to the `x` value and the second corresponds to the
`y` value.
-}

point :: Point
point = NewPoint 2.0 1.0 -- Be careful, the order matters

{-
We can do better in Haskell by giving *names* to the individual arguments of data
constructors, like this:
-}

data Point = NewPoint {x :: Double, y :: Double}
  deriving (Show, Eq)

{-
This form of datatype definition is called a *record*.

The names `x` and `y`, are called *field names* and provide more documentation about the type.
They let us know that we intend the first argument to be the `x` coordinate and the
second to be the `y` coordinate. We construct a `Point` we can use these names
for better readability.
-}

point1 :: Point
point1 = NewPoint {x = 2.0, y = 1.0} -- explicit field names

{-
We can also use these names for more flexibility during construction. For example, we can
swap the order of the arguments.
-}

point2 :: Point
point2 = NewPoint {y = 1.0, x = 2.0} -- Same as `point1`

{-
Furthermore, each field name also defines a *selector* for that component of the data
structure. The selector is a function with the same name as the field that can be
used to directly extract that component from the type.
-}

x1 :: Double
x1 = x point1

-- Access the x component of point2
-- >>> x point2

{-
When taking arguments that use records, we can either use the
record selectors to access their components, or use pattern-matching.
-}

distFromOrigin :: Point -> Double
distFromOrigin NewPoint {x = px, y = py} = sqrt (px * px + py * py)

{-
Now, rewrite this function using selectors `x` and `y`:
-}

distFromOrigin' :: Point -> Double
distFromOrigin' p = undefined

{-
Which version is easier to read? Opinions differ.

Things to watch out for with records in Haskell:

 * Records must be defined as part of a datatype definition.

 * The selectors are first-class functions. This is really great for
   higher-order programming, i.e.
   we can easily access all of the `x` components from a list of points
   with

          map x points

 * Record selectors must be *unique* within a module. If `Point` has an `x`
   field name, then no other datatype in that module can use `x` as a field
   name.

 * Record selectors are just normal variable names. So if `Point` has an `x`
   component, there cannot be another top-level definition in the module
   called `x`.  (Recall that all toplevel definitions in a module must be
   unique, but local definitions may shadow toplevel definitions. )

 * It's idiomatic to "pun" when pattern matching records. For example, we name
   the variables using the same names as the selectors. (Note that this can
   also be confusing, and some Haskellers advise against this practice.)
-}

distFromOrigin'' :: Point -> Double
distFromOrigin'' NewPoint {x = x, y = y} = sqrt (x * x + y * y)

{-
 * Records are immutable in Haskell. There is no way to modify
   a component when it is created. However, there is an easy way to
   construct new values that share components with existing structures.
-}

point3 :: Point
point3 = point1 {x = 2.0}

{-
   This syntax is called *record update*. It is a purely functional way to
   create a new record value by reusing the components of an existing record.
   Above, `point3` is a `Point with `x` component equal to 2.0, and all other
   components (which is only `y` here) the same as `point1`. When records have
   many components, this can be a very useful feature.

 * Haskell's record system is far from perfect. It's strange that records must
   be defined as part of data constructors. The fact that different record
   types in the same module cannot share fields names can be awkward. It can
   be tedious to work with purely functional record update when you have
   nested records.  Some of these issues are addressed by language extensions
   (such as
   [`DuplicateRecordFields`](https://downloads.haskell.org/ghc/latest/docs/html/users_guide/glasgow_exts.html#duplicate-record-fields))
   and by sophisticated
   [libraries](http://hackage.haskell.org/package/lens). However, these are
   advanced topics so we won't be covering them here.

Recursive Datatypes
===================

Datatypes can be defined recursively.  That is, their constructors can
take other elements of the same type as arguments.

For example, we could define a type representing *nonempty* lists of integers:
-}

data IntListNE
  = ISingle Int
  | ICons Int IntListNE

{-
So that the list `[1,2,3]` is represented as:
-}

oneTwoThree :: IntListNE
oneTwoThree = ICons 1 (ICons 2 (ISingle 3))

{-
For comparison with Haskell's built-in lists, it might help to think
of this as:
-}

oneTwoThree' :: IntListNE
oneTwoThree' = 1 `ICons` (2 `ICons` ISingle 3) -- backticks for infix

{-
Nonempty lists are great in that we can write a total `head` function (i.e. this version
of `head` is not partial like the one for regular lists.)
-}

-- >>> safeHead oneTwoThree
-- 1
safeHead :: IntListNE -> Int
safeHead = undefined

{-
We can define functions by recursion on `IntListNE`s too, of course. Write a function
to calculate the sum of a non-empty list of integers.
-}

-- >>> sumOfIntListNE oneTwoThree
-- 6
sumOfIntListNE :: IntListNE -> Int
sumOfIntListNE = undefined

{-
Polymorphic Datatypes
=====================

It would sure be annoying to have a seperate kind of list for each
type of data!  Luckily, we know Haskell's list type is polymorphic:
you can have a list of type `[a]` for any `a`.

We can define new polymorphic datatypes too. For example, we can
easily make the non-empty lists above polymorphic.

As another example, here is the definition of the `Maybe` type (from the
Prelude) that we've used in past lectures:
-}

data Maybe a = Nothing | Just a

{-
Notice that the type `Maybe` itself takes an argument: the type
variable `a`.  We're also allowed to use that type variable in the
constructors.  So `Just` is a constructor that can be applied to
values of any type and will create a `Maybe` with the same type:

    Just :: a -> Maybe a

Thus, `Just` and `Nothing` work at any type:
-}

noInt :: Maybe Int
noInt = Nothing

justTrue :: Maybe Bool
justTrue = Just True

justThree :: Maybe Int
justThree = undefined

{-
A number of other polymorphic datatypes appear in the standard
library.  For example, here's a standard datatype to carry around values that
could have either of two types:
-}

data Either a b = Left a | Right b

{-
`Either` is often useful for error handling.  Sometimes, returning a
`Maybe a` isn't quite good enough because you'd like to give a helpful
error message.  `Either String a` works a little better:
instead of `Nothing`, use `Left msg` in the case of an error,
and instead of `Just v`, use `Right v` in case things are... all right.

For example, here's a safer integer division function:
-}

safeDiv :: Int -> Int -> Either String Int
safeDiv _ 0 = Left "You can't divide by zero, silly."
safeDiv x y = Right $ x `div` y

{-
Of course, `Either` is more useful when things can go wrong in more
than one way.

Trees
=====

Now let's play a bit with a bigger example: trees.  Here's one way to
define binary trees that have data at the internal nodes in Haskell:
-}

data Tree a
  = Empty -- No data
  | Branch a (Tree a) (Tree a) -- data of type a, left and right subtrees
  deriving (Eq, Show)

{-
For example, we can represent the following tree

              5
            /   \
           2     9
          / \     \
         1   4     7

like this:
-}

exTree :: Tree Int
exTree =
  Branch
    5
    (Branch 2 (Branch 1 Empty Empty) (Branch 4 Empty Empty))
    (Branch 9 Empty (Branch 7 Empty Empty))

{-
We can write simple functions on trees by recursion:
-}

-- | increment all integers in the tree
-- >>> treePlus (Branch 2 Empty Empty) 3
-- Branch 5 Empty Empty
treePlus :: Tree Int -> Int -> Tree Int
treePlus = undefined

{-
We can accumulate all of the elements in a tree into a list:
-}

-- >>> infixOrder exTree
-- [1,2,4,5,9,7]
infixOrder :: Tree a -> [a]
infixOrder Empty = []
infixOrder (Branch x l r) = infixOrder l ++ [x] ++ infixOrder r

{-
... visiting the nodes in different orders ....
-}

-- >>> prefixOrder exTree
-- [5,2,1,4,9,7]

prefixOrder :: Tree a -> [a]
prefixOrder = undefined

{-
(NOTE: This is a simple way of defining a tree walk in Haskell, but it is not
the best way. In particular, the `infixOrder` function is *not* linear in the
number of nodes in the tree. Why?  Can you think of a way to rewrite
`infixOrder` so that it runs in linear time?)

But, of course, what we should really do is reimplement our
higher-order patterns for trees!
-}

treeMap :: (a -> b) -> Tree a -> Tree b
treeMap f Empty = Empty
treeMap f (Branch x l r) = Branch (f x) (treeMap f l) (treeMap f r)

{-
So that, for example, to increment each node in a `Tree Int` by one, we could
write this:
-}

-- >>> treeIncr (Branch 1 (Branch 2 Empty Empty) Empty)
-- Branch 2 (Branch 3 Empty Empty) Empty
treeIncr :: Tree Int -> Tree Int
treeIncr = treeMap (+ 1)

main :: IO ()
main = do
  runTestTT $
    TestList
      [ "safeHead" ~: safeHead oneTwoThree ~?= 1,
        "sumOfIntListNE" ~: sumOfIntListNE oneTwoThree ~?= 6,
        "treeIncr"
          ~: treeIncr (Branch 1 (Branch 2 Empty Empty) Empty)
          ~?= Branch 2 (Branch 3 Empty Empty) Empty,
        "treePlus" ~: treePlus (Branch 2 Empty Empty) 3 ~?= Branch 5 Empty Empty,
        "infixOrder" ~: infixOrder exTree ~?= [1, 2, 4, 5, 9, 7],
        "prefixOrder" ~: prefixOrder exTree ~?= [5, 2, 1, 4, 9, 7]
      ]
  return ()

{-
Part of this lecture is taken from ["Learn You a Haskell for Great Good"](http://learnyouahaskell.com/).
-}
