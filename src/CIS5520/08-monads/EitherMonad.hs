{-
---
fulltitle: "In class exercise: The Either Monad"
date: October 23, 2024
---

The goal of this short in-class exercise is to understand the `Either` monad, which is very similar to the `Maybe` monad.
-}

module EitherMonad where

{-
We're going recreate part of Haskell's standard library in this exercise, so we'll
avoid importing it from the prelude.
-}

import Control.Monad (ap)
import Prelude hiding (Either (..))

{-
Compare the `Either` datatype, which represents a choice between two options
-}

data Either a b = Left a | Right b deriving (Show)

{-
with that of the `Maybe` datatype, which represents nothing or something.

~~~~
data Maybe b = Nothing | Just b
~~~~

These two types are similar in their second data constructors. Both `Right`
and `Just` carry values of type `b`. The real difference is in their first
data constructor. In `Either`, `Left` can carry a value, but in `Maybe`, the
`Nothing` data constructor stands alone.

You saw in the [Monads](Monads.html) module that the `Maybe` datatype can be used
to work with functions that may not always produce results. In doing so, the monadic
bind operation `>>=` can help define such functions succinctly.

The `Either` type can also be used for partial functions, instead of returning `Just v`
you can use `Right v` instead. Furthermore, in the case that there is no result to return,
then the `Left` data constructor can return information about *why* there is no result, such
as an error string. And, like `Maybe`, the bind operation helps.

For example, here is `zipTree` written using the `Either` monad. The implementation
is the same as with `Maybe` except for the last line. When the structures of the trees
do not match, then `Either` can produce an informative error message.
-}

data Tree a = Leaf a | Branch (Tree a) (Tree a)
  deriving (Eq, Show)

zipTree5 :: (Show a, Show b) => Tree a -> Tree b -> Either String (Tree (a, b))
zipTree5 (Leaf a) (Leaf b) = return (Leaf (a, b))
zipTree5 (Branch l r) (Branch l' r') = do
  x <- zipTree5 l l'
  y <- zipTree5 r r'
  return (Branch x y)
zipTree5 t1 t2 = Left ("Tree mismatch, found " ++ show t1 ++ " and " ++ show t2)

{-
If you call this function with these two trees:
-}

t1 :: Tree Int
t1 = Branch (Leaf 1) (Branch (Leaf 2) (Leaf 3))

t2 :: Tree Char
t2 = Branch (Leaf 'a') (Branch (Branch (Leaf 'b') (Leaf 'c')) (Leaf 'd'))

{-
then the result should be

          Left "Tree mismatch, found Leaf 2 and Branch (Leaf 'b') (Leaf 'c')"

Your job is to implement the `Monad` instance so that the following test case
returns the message above.
-}

-- >>> zipTree5 t1 t2

{-
But before you do that, take a
very close look at this instance for `Functor`. Note how the code does *not* treat
the two variants (`Left`) and (`Right`) the same. Note also how this instance
is for the partial application `Either a`.
-}

instance Functor (Either a) where
  fmap :: (b1 -> b2) -> Either a b1 -> Either a b2
  fmap f (Left x) = Left x
  fmap f (Right y) = Right (f y)

{-
What this means is that this instance is functorial only in the *second* type parameter
to `Either`. We can use `fmap` to update `Right`, but `fmap` does not do anything
to `Left`.

The reason for this discrepancy is that the `Either` monad has different interpretations
for `Left` and `Right`. The first indicates `Failure` (like `Nothing`) while the second
indicates success (like `Just`). On failure, the monad should stop computation immediately
and return the value carried by `Left` (the error message). On success, the result needs
to be passed to the next computation, via `bind`.
-}

instance Monad (Either a) where
  return :: a2 -> Either a1 a2
  return = undefined
  (>>=) :: Either a1 a2 -> (a2 -> Either a1 b) -> Either a1 b
  (>>=) = undefined

{-
(In this exercise, there is nothing to do for `Applicative`. We'll define it in terms of `Monad`.)
-}

instance Applicative (Either a) where
  pure :: a2 -> Either a1 a2
  pure = return
  (<*>) :: Either a1 (a2 -> b) -> Either a1 a2 -> Either a1 b
  (<*>) = ap
