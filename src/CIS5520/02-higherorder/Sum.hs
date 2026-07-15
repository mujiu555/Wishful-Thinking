{-
---
fulltitle: "Optional exercise: foldr vs. foldl"
date: September 11, 2024
---

This module contains some quick examples demonstrating the difference between
`foldr` and `foldl`. It is advanced material for CIS 5520, designed for those who
have seen `fold` and tail recursion before, such as in CIS 1200.
-}

module Sum where

-- https://www.seas.upenn.edu/~cis5520/current/lectures/stub/02-higherorder/Sum.html

import Prelude hiding (foldl, foldr)

{-
Let's start with a concrete example of a fold --- the "sum" function that adds
together all numbers in a list. We can write this function in four different
ways. The first two are the standard recursive definitions of sum. The third
and fourth use a helper function that includes an accumulator.
-}

sum1 :: [Int] -> Int
sum1 [] = 0
sum1 (x : xs) = x + sum1 xs

sum2 :: [Int] -> Int
sum2 [] = 0
sum2 (x : xs) = sum2 xs + x

sum3 :: [Int] -> Int
sum3 = sumAux 0
  where
    sumAux acc [] = acc
    sumAux acc (x : xs) = sumAux (acc + x) xs

sum4 :: [Int] -> Int
sum4 = sumAux 0
  where
    sumAux acc [] = acc
    sumAux acc (x : xs) = sumAux (x + acc) xs

{-
All of these functions give us the same result because (+) is associative and
commutative. However, none of these functions give us exactly the same
\*computation*: they each process the list in a different order.

         sum1 [1,2,3]
           == 1 + (2 + (3 + 0))
         sum2 [1,2,3]
           == ((0 + 3) + 2) + 1
         sum3 [1,2,3]
           == ((0 + 1) + 2) + 3
         sum4 [1,2,3]
           == (3 + (2 + (1 + 0)))

Generalizing Fold
------------------

We can generalize the examples above to create several different
recursion patterns over lists. Compare these definitions with
the variants of `sum` above. Then try to write the missing fourth
variant`.
-}

-- | Generalization of recursion pattern in `sum1`
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr f b = go
  where
    go [] = b
    go (x : xs) = x `f` go xs

foldrFlip :: (b -> a -> b) -> b -> [a] -> b
foldrFlip f b = go
  where
    go [] = b
    go (x : xs) = go xs `f` x

foldl :: (b -> a -> b) -> b -> [a] -> b
foldl f = go
  where
    go acc [] = acc
    go acc (x : xs) = go (acc `f` x) xs

foldlFlip :: (a -> b -> b) -> b -> [a] -> b
foldlFlip f = undefined

sum1' :: [Int] -> Int
sum1' = foldr (+) 0

sum2' :: [Int] -> Int
sum2' = foldrFlip (+) 0

sum3' :: [Int] -> Int
sum3' = foldl (+) 0

{-

-}

sum4' :: [Int] -> Int
sum4' = foldlFlip (+) 0

{-
Now see what happens when you use these general operations
with the `(:)` operator. Unlike `(+)`, `(:)` is
associative but not *commutative* so not all of the
results will be the same.
-}

-- >>> foldr (:) [] [1,2,3]

-- >>> foldrFlip (flip (:)) [] [1,2,3]

-- >>> foldl (flip (:)) [] [1,2,3]

-- >>> foldlFlip (:) [] [1,2,3]

{-
On the other hand, the `(-)` operator is both
not associative and not commutative,
so again the results will be different.
-}

-- >>> foldr (-) 0 [1,2,3]

-- >>> foldrFlip (-) 0 [1,2,3]

-- >>> foldl (-) 0 [1,2,3]

-- >>> foldlFlip (-) 0 [1,2,3]

{-
Tail Recursion
--------------

Somewhat surprisingly, the definitions of `sum3` and `sum4` are *not* tail recursive. The
problem is due to laziness: the argument in the recursive call to `sumAux`
is not evaluated until the result is needed. To get an actual tail recursive function
in Haskell, we need to evaluate this accumulator before `sumAux` is called recursively.
Therefore, we will redefine `sum4` using the operation `($!)` which overrides laziness
and forces call-by-value function application. In otherwords, with this operator, GHC
will compile the code to evaluate the argument before making a recursiove call.
-}

sum5 :: [Int] -> Int
sum5 = sumAux 0
  where
    sumAux acc [] = acc
    sumAux acc (x : xs) = (sumAux $! (x + acc)) xs

{-
We can generalize this pattern by adding a strictness annotation to the definition
of foldl. This is the definition of `foldl'` in the standard library.
-}

foldl' :: (b -> a -> b) -> b -> [a] -> b
foldl' f = go
  where
    go acc [] = acc
    go acc (x : xs) = (go $! acc `f` x) xs

{-
Microbenchmarks
----------------

Here are some micro-benchmarks for thinking about laziness and saved
computation.

If you would like to better understand the performance of various folds,
you can use the `:set +s` command in GHCi to get timing and allocation
information for each evaluation that you do.

To do so, first load the definitions in this module into GHCi. To do so,
start the terminal in VS Code, and then use the command

      stack ghci Sum.hs

to start ghci and load the module.

Next, in GHCi you can type

    Sum> :set +s

to cause GHCi to report timing and allocation data. If you make changes
to any of the definitions in this file, you will need to reload it in
ghci using the command

    Sum> :r

For example, to compare the performance of the sum functions we can
call them with large lists:
-}

c1, c2, c3, c4, c5 :: Int
c1 = sum1 [1 .. 1000000]
c2 = sum2 [1 .. 1000000]
c3 = sum3 [1 .. 1000000]
c4 = sum4 [1 .. 1000000]
c5 = sum5 [1 .. 1000000]

{-
When you ask GHCi to evaluate each of these computations, you will see
both the timing and the number of bytes allocated.

        ghci> c1
        500000500000
        (0.38 secs, 226,778,360 bytes)

However, remember that GHC is lazy, so it will save the result. If you
ask for the same value again, it will take much less time and space.

        ghci> c1
        500000500000
        (0.00 secs, 315,144 bytes)

Here are some other examples to try. What can you learn about Haskell's execution
model from these examples?
-}

-- A potentially big computation
h1 :: Int -> Int
h1 y = sum1 [1 .. y * 100000]

-- A potentially big computation (ignore first argument)
f1 :: Int -> Int -> Int
f1 _x y = sum1 [1 .. y * 100000]

-- A potentially big computation (don't ignore first argument)
g1 :: Int -> Int -> Int
g1 x y = if x > 0 then sum1 [1 .. y * 100000] else sum2 [1 .. y * 100000]

-- Call h1 with same argument multiple times.
u1 :: Int
u1 = h1 1 + h1 1 + h1 1

-- Call f1 with same and different arguments multiple times.
v1 :: Int
v1 = f1 0 1 + f1 1 1 + f1 2 1

v2 :: Int
v2 = f1 0 1 + f1 0 1 + f1 0 1

-- Call g1 with same and different arguments multiple times.
w1 :: Int
w1 = g1 0 1 + g1 1 1 + g1 2 1

w2 :: Int
w2 = g1 0 1 + g1 0 1 + g1 0 1
