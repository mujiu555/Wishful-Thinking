{-
---
fulltitle: "In class exercise: General Monadic Functions"
date: October 23, 2024
---
-}

module GenericMonads where

import Data.Char qualified as Char
import Test.HUnit
import Prelude hiding (mapM, sequence)

{-
Generic Monad Operations
========================

This problem asks you to recreate some of the operations in the
[Control.Monad](https://hackage.haskell.org/package/base-4.14.2.0/docs/Control-Monad.html)
library. You should *not* use any of the functions defined in that library to
solve this problem.  (These functions also appear in more general forms
elsewhere, so other libraries that are off limits for this problem include
`Control.Applicative`, `Data.Traversable` and `Data.Foldable`.)

NOTE: because these operations are so generic, the types will really help you
figure out the implementation, even if you don't quite know what the function should do.

For that reason you should also test *each* of these functions with at least two unit test
cases, one using the `Maybe` monad, and one using the `List` monad.  After you
you have tried the function out, try to describe in words what each operation does
for that specific monad.

Here is the first one as an example.
-}

-- (a)

{-
Given the type signature:
-}

mapM :: (Monad m) => (a -> m b) -> [a] -> m [b]
{-
We implement it by recursion on the list argument.
-}

mapM _ [] = return []
mapM f (x : xs) = do
  b <- f x
  bs <- mapM f xs
  return (b : bs)

{-
Then define the following test cases, which make use of the following
helper functions.
-}

maybeUpper :: Char -> Maybe Char
maybeUpper x = if Char.isAlpha x then Just (Char.toUpper x) else Nothing

onlyUpper :: [Char] -> [Char]
onlyUpper = filter Char.isUpper

-- >>> mapM maybeUpper "sjkdhf"
-- Just "SJKDHF"
-- >>> mapM maybeUpper "sa2ljsd"
-- Nothing

-- >>> mapM onlyUpper ["QuickCheck", "Haskell"]
-- ["QH","CH"]
-- >>> mapM onlyUpper ["QuickCheck", ""]
-- []

{-
Finally, we observe that this function is a generalization of List.map, where
the mapped function can return its value in some monad m.
-}

-- (b)

foldM :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
foldM = error "foldM: unimplemented"

-- (c)

sequence :: (Monad m) => [m a] -> m [a]
sequence = error "sequence: unimplemented"

-- (d) This one is the Kleisli "fish operator"
--

(>=>) :: (Monad m) => (a -> m b) -> (b -> m c) -> a -> m c
(>=>) = error ">=>: unimplemented"

-- (e)

join :: (Monad m) => m (m a) -> m a
join = error "join: unimplemented"

-- (f) Define the 'liftM' function

liftM :: (Monad m) => (a -> b) -> m a -> m b
liftM = error "liftM: unimplemented"

-- Thought question: Is the type of `liftM` similar to that of another
-- function we've discussed recently?

-- (g) And its two-argument version ...

liftM2 :: (Monad m) => (a -> b -> r) -> m a -> m b -> m r
liftM2 = error "liftM2: unimplemented"

{-
-------------------------------------------------------------------------

General Applicative Functions
=============================

Which of these functions above can you equivalently rewrite using `Applicative`?
i.e. for which of the definitions below, can you replace `undefined` with
a definition that *only* uses members of the `Applicative` (and `Functor`)
type class. (Again, do not use functions from `Control.Applicative`,
`Data.Foldable` or `Data.Traversable` in your solution.)

If you provide a definition, you should write test cases that demonstrate that it
has the same behavior on `List` and `Maybe` as the monadic versions above.
-}

-- NOTE: you will not be able to define all of these, but be sure to test the
-- ones that you do

mapA :: (Applicative f) => (a -> f b) -> [a] -> f [b]
mapA = undefined

foldA :: forall f a b. (Applicative f) => (a -> b -> f a) -> a -> [b] -> f a
foldA = undefined

sequenceA :: (Applicative f) => [f a] -> f [a]
sequenceA = undefined

kleisliA :: (Applicative f) => (a -> f b) -> (b -> f c) -> a -> f c
kleisliA = undefined

joinA :: (Applicative f) => f (f a) -> f a
joinA = undefined

liftA :: (Applicative f) => (a -> b) -> f a -> f b
liftA f x = undefined

liftA2 :: (Applicative f) => (a -> b -> r) -> f a -> f b -> f r
liftA2 f x y = undefined
