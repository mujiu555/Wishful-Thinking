{-
---
fulltitle: "In class exercise: QuickCheck properties for lists"
date: October 4, 2023
---
-}

module QuickList where

import Data.List as List
import Test.QuickCheck

{-
Testing List Functions
----------------------

In this problem, you'll be writing QuickCheck properties to specify
various list manipulation functions.  For each property that you write, you
should also include a buggy implementation of the tested function that
_does not_ satisfy the property you wrote.  We'll be asking you to
write your properties in a very particular way.  For instance, suppose
you are testing the
[`const`](http://hackage.haskell.org/package/base-4.17.1.0/docs/Prelude.html#v:const)
function, which takes two arguments and returns the first one.  Here's
how you'd normally test (a type-restricted version of) it.  First, we
write an appropriate property:
-}

prop_const' :: Eq a => a -> a -> Bool
prop_const' a b = const a b == a

{-
Then we see what QuickCheck thinks of the property by entering this in GHCi:

       ghci> quickCheck (prop_const' :: Char -> Char -> Bool)

(The type annotation is needed because `prop_const` is polymorphic;
QuickCheck wouldn't know what type of test data to generate if we left
it off. Also, recall that you must run this in ghci instead of in directly
in your IDE because `quickCheck` requires the IO monad.)

Below, we'll be asking you to fill in most of the definition and the type
signature, given code snippets such as

~~~~{.haskell}
prop_const :: (a -> a -> a) -> Undefined
prop_const const' = undefined
~~~~

where the property is parameterized by a version of the function to test
(i.e. `const'`) and where `Undefined` is a dummy Testable type that
will emit an error if used:
-}

data Undefined

instance Testable Undefined where
  property = error "Unimplemented property"

{-
Filling in the property will then involve

  * Adding parameters,
  * Replacing the body, and
  * Replacing the `Undefined` type with the desired type of the property.
    This might involve adding new constraints to the type variables or
    new arguments to the function type.

That will look, for instance, like so:
-}

prop_const :: Eq a => (a -> a -> a) -> a -> a -> Bool
prop_const const' a b = const' a b == a

{-
You'll fill in the types of all the parameters plus the return type,
and you can add any type class constraints you want.

By parameterizing these properties with the functions to test, and
writing tests that use the passed in parameter (here `const'`) instead
of the real function (here `const`), we are able to test buggy
implementations in addition to the correct ones.  For instance,
suppose that you have:
-}

constBug :: a -> a -> a
constBug _ b = b -- Oops: this returns the *second* argument, not the first.

{-
Then you'll be able to test your property on both `const` (where it will pass)
and `constBug` (where it will not):

    ghci> quickCheck (prop_const const :: Char -> Char -> Bool)
    +++ OK, passed 100 tests.
    ghci> quickCheck (prop_const constBug :: Char -> Char -> Bool)
    *** Failed! Falsifiable (after 1 test and 2 shrinks):
    'a'
    'b'

Random Generation and Shrinking
--------------------------------

Note above that when QuickCheck detects a property violation, it produces a counterexample.
In this case, the counterExample is the two arguments 'a' and 'b',

    ghci> prop_const constBug 'a' 'b'
    False
    ghci> constBug 'a' 'b'
    'b'

Although QuickCheck is based on testing with random arguments, it is not a coincidence
that this is the counterexample that QuickCheck finds. QuickCheck tries to report *small*
counterexamples to programmers, to make it easy to figure out the bug. What it means for
a counterexample to be small dependends on its type.

Recall that the key to QuickCheck is the `Arbitrary` type class. This class has two members,
one for generating elements to use with tests and another for "shrinking" them once a
counterexample has been found.

     class Arbitrary a where
        -- generator for an arbitrary value of type a
        arbitrary :: Gen a

        -- produce a list of values that are "smaller" than the input
        shrink :: a -> [a]
        shrink _ = []

Let's see how this works with built-in types. The sample function can be used with
`arbitrary` to produce and print out 10 random elements of a type.

      ghci> sample (arbitrary :: Gen Char)
      'c'
      'x'
      'V'
      '\DC2'
      '\34532'
      'M'
      '\DLE'
      '['
      '6'
      '-'
      '\DLE'

Running sample again in ghci will produce a different result. (And if you tried to do this yourself,
you probably saw different characters in your terminal.)

When QuickCheck tests `prop_const` it will generate two chars using `arbitrary`. If they are
different from eachother, then they will be a counterexample. However, QuickCheck doesn't stop there,
it then runs the shrink operation on these two chars to get a list of potential alternates to try
instead.

      ghci> shrink 'c'
      "ab"
      ghci> shrink 'x'
      "abc"

For `Char` these alternates are all at the beginning of the alphabet so it is likely that we'll see
counterexamples mentioning 'a' and 'b' instead of 'x' and '\34532'. (Note also that the list for 'c'
doesn't include 'c' itself! QuickCheck will shrink multiple times if necessary, trying to find
the smallest counterexample and we don't want it to get into an infinite loop.)

Now play around with `arbitrary` and `shrink` on built-in types so that you get a sense of what is
happening behind the scenes with QuickCheck.

Finally, if you look close at the definition of the `Arbitrary` class, you'll see that there is a
default definition for `shrink` --- just return the empty list. This definition disables shrinking
for a particular type. (The empty list means that there are no smaller elements, so nothing more
to try.)  We recommend that you always implement `shrink` as it is a useful way to

-- Part a

Define a property showing that
[`minimum`](http://hackage.haskell.org/package/base-4.17.1.0/docs/Prelude.html#v:minimum)
really returns the smallest element in a list; also, write a buggy
implementation of `minimum` that doesn't satisfy your property.
(Don't forget to fill in the type signature for `prop_minimum`!)
-}

prop_minimum :: Ord a => ([a] -> a) -> Undefined
prop_minimum minimum' = undefined

{-
Also define a buggy implementation that can be identified by your property.
-}

minimumBug :: Ord a => [a] -> a
minimumBug = undefined

{-
Be careful when testing your code with ghci. Make sure that you provide
a type annotation for any polymorphic functions that you are testing.

     ghci> quickCheck (prop_minimum (minimumBug :: [Char] -> Char))

If you leave off the type annotation, you could get some
strange results. For example, it is possible for this check to succeed
even though the property is correct and the buggy version is indeed buggy.

      ghci> quickCheck (prop_minimum minimumBug)

The issue is that if `prop_minimum minimumBug` has a polymorphic type, then
ghci will default any remaining type variables to `()` (i.e. the unit
type). This is a problem because *any* element of a list of unit values is the
minimum element.

If you enable the warning about defaulting in ghci, it will alert you when this
happens

      ghci>  :set -Wtype-defaults
      ghci> quickCheck (prop_minimum minimumBug)
      <interactive>:90:1-37: warning: [-Wtype-defaults]
        • Defaulting the following constraints to type ‘()’
           (Arbitrary a0)
             arising from a use of ‘quickCheck’ at <interactive>:90:1-37
           (Show a0)
             arising from a use of ‘quickCheck’ at <interactive>:90:1-37
           (Ord a0)
             from a use of ‘prop_minimum’ at <interactive>:90:14-37
-}

{-
-- Part b

Define a property specifying the
[`replicate`](http://hackage.haskell.org/package/base-4.17.1.0/docs/Prelude.html#v:replicate)
function from the standard library, and a buggy implementation that
violates this spec.  Recall that `replicate k x` is a list containing
`k` copies of `x`.

One QuickCheck feature that will be important here
(and later) is the use of `newtype`s, such as
[`NonNegative`](http://hackage.haskell.org/package/QuickCheck-2.14.2/docs/Test-QuickCheck-Modifiers.html#t:NonNegative),
to restrict the domain of arbitrarily generated values:

    ghci> sample (arbitrary :: Gen Int)
    1
    -2
    4
    -7
    -9
    -20
    -1
    22
    60
    -1780
    3770
    ghci> sample (arbitrary :: Gen NonNegative Int)
    NonNegative {getNonNegative = 1}
    NonNegative {getNonNegative = 0}
    NonNegative {getNonNegative = 1}
    NonNegative {getNonNegative = 8}
    NonNegative {getNonNegative = 32}
    NonNegative {getNonNegative = 5}
    NonNegative {getNonNegative = 28}
    NonNegative {getNonNegative = 23}
    NonNegative {getNonNegative = 662}
    NonNegative {getNonNegative = 584}
    NonNegative {getNonNegative = 0}

However, simply using `NonNegative Int` won't work here, as
generating, say, a million-element list will take far too long (try
it!).

So, your job is to define a `newtype` for generating *small*
non-negative integers (say, in the range 0 to 1000):

-}

newtype SmallNonNegInt = SmallNonNegInt Int deriving (Eq, Ord, Show, Read)

{-
When you make a quickcheck instance, you should define both `arbitrary` and
`shrink` for the `SmallNonNegInt` type. Note: the shrink function in this instance can
be derived from shrinking the int inside.  Try it out first:

     ghci> shrink (10 :: Int)
     [0,5,8,9]

Then implement your definition so that you get the following behavior:

     ghci> shrink (SmallNonNegInt 10)
     [SmallNonNegInt 0,SmallNonNegInt 5,SmallNonNegInt 8,SmallNonNegInt 9]
-}

instance Arbitrary SmallNonNegInt where
  arbitrary = undefined
  shrink = undefined

{-
Now, use this type to define your property specifying `replicate`.
-}

prop_replicate :: (Int -> a -> [a]) -> Undefined
prop_replicate replicate' = undefined

replicateBug :: Int -> a -> [a]
replicateBug = undefined

{-
-- Part c

Define two properties specifying
[`group`](http://hackage.haskell.org/package/base-4.17.1.0/docs/Data-List.html#v:group);
the first one should say that "the concatenation of the result is
equal to the argument", and the second should say that "each sublist
in the result is non-empty and contains only equal elements".  Also
write a buggy version of `group` that violates both of them.
-}

prop_group_1 :: Eq a => ([a] -> [[a]]) -> Undefined
prop_group_1 group' = undefined

prop_group_2 :: Eq a => ([a] -> [[a]]) -> Undefined
prop_group_2 group' = undefined

groupBug :: Eq a => [a] -> [[a]]
groupBug = undefined

{-
-- Part d

Write two interesting properties about
[`reverse`](http://hackage.haskell.org/package/base-4.17.1.0/docs/Prelude.html#v:reverse).
Write two different buggy versions, one which violates each property.
-}

prop_reverse_1 :: ([a] -> [a]) -> Undefined
prop_reverse_1 reverse' = undefined

prop_reverse_2 :: ([a] -> [a]) -> Undefined
prop_reverse_2 reverse' = undefined

reverseBug_1 :: [a] -> [a]
reverseBug_1 = undefined

reverseBug_2 :: [a] -> [a]
reverseBug_2 = undefined

{-
Once you've written all of these, evaluating `main` in GHCi should
produce the expected output:
-}

main :: IO ()
main = do
  let qcName name prop = do
        putStr $ name ++ ": "
        quickCheck prop

  putStrLn "The following tests should all succeed:"
  qcName "const" $ prop_const (const :: Char -> Char -> Char)
  qcName "minimum" $ prop_minimum (minimum :: String -> Char)
  qcName "replicate" $ prop_replicate (replicate :: Int -> Char -> String)
  qcName "group_1" $ prop_group_1 (group :: String -> [String])
  qcName "group_2" $ prop_group_2 (group :: String -> [String])
  qcName "reverse_1" $ prop_reverse_1 (reverse :: String -> String)
  qcName "reverse_2" $ prop_reverse_2 (reverse :: String -> String)

  putStrLn ""

  putStrLn "The following tests should all fail:"
  qcName "const" $ prop_const (constBug :: Char -> Char -> Char)
  qcName "minimum" $ prop_minimum (minimumBug :: String -> Char)
  qcName "replicate" $ prop_replicate (replicateBug :: Int -> Char -> String)
  qcName "group_1" $ prop_group_1 (groupBug :: String -> [String])
  qcName "group_2" $ prop_group_2 (groupBug :: String -> [String])
  qcName "reverse_1" $ prop_reverse_1 (reverseBug_1 :: String -> String)
  qcName "reverse_2" $ prop_reverse_2 (reverseBug_2 :: String -> String)
