{-
---
fulltitle: "Extra practice: Tree folds"
---
-}

module TreeFolds where

-- https://www.seas.upenn.edu/~cis5520/current/lectures/stub/03-trees/TreeFolds.html
{-
>
-}

import Data.DList qualified as DL
import Test.HUnit

{-
This exercise is about efficiently iterating over tree-structured data.
Recall the basic type of binary trees.
-}

-- | a basic tree data structure
data Tree a = Empty | Branch a (Tree a) (Tree a) deriving (Show, Eq)

{-
And also the `infixOrder` function from the Datatypes module.
-}

infixOrder :: Tree a -> [a]
infixOrder Empty = []
infixOrder (Branch x l r) = infixOrder l ++ [x] ++ infixOrder r

{-
For example, using this tree

              5
            /   \
           2     9
          / \     \
         1   4     7
-}

exTree :: Tree Int
exTree =
  Branch
    5
    (Branch 2 (Branch 1 Empty Empty) (Branch 4 Empty Empty))
    (Branch 9 Empty (Branch 7 Empty Empty))

{-
the infix order traversal produces this result.
-}

testInfixOrder :: Test
testInfixOrder = "infixOrder" ~: infixOrder exTree ~?= [1, 2, 4, 5, 9, 7]

{-
However, as in the DList exercise, the (++) in the definition of
 `infixOrder` should bother you. What if the tree is terribly skewed?

                 1
                /
               2
              /
             3
            /
           4
          /
         5
        /
      ...
-}

-- | A big "right-skewed" tree
bigRightTree :: Int -> Tree Int
bigRightTree m = go 0
  where
    go n = if n <= m then Branch n Empty (go (n + 1)) else Empty

-- | A big "left-skewed" tree
bigLeftTree :: Int -> Tree Int
bigLeftTree m = go 0
  where
    go n = if n <= m then Branch n (go (n + 1)) Empty else Empty

{-
If you turn on benchmarking, you can observe the difference between a left
skewed and right skewed tree in ghci.  At this scale, the time taken to print
these trees dominates the computation, but take a look at the difference in
allocation!

        ghci> :set +s
        ghci> sum (infixOrder (bigRightTree 10000))
        50005000
        (0.02 secs, 7,102,016 bytes)
        ghci> sum (infixOrder (bigLeftTree 10000))
        50005000
        (0.97 secs, 4,305,693,360 bytes)

We can improve things by using `DList`s while traversing the tree. Try to
complete this version so that the number of bytes used for traversing t1 and
t2 is more similar to the version above...
(NOTE: There is an implementation of `DList`s in the standard library, and we
have imported it above. So you can try this out even if you have not completed the
`DList` exercise.)
-}

infixOrder1 :: Tree a -> [a]
infixOrder1 = undefined

tinfixOrder1 :: Test
tinfixOrder1 = "infixOrder1a" ~: infixOrder1 exTree ~?= [1, 2, 4, 5, 9, 7]

{-
       ghci> sum (infixOrder1 (bigRightTree 10000))
       50005000
       (0.02 secs, 9,016,880 bytes)
       ghci> sum (infixOrder1 (bigLeftTree 10000))
       50005000
       (0.02 secs, 9,016,880 bytes)

Now, let's inline the `DList` definitions above to get rid of the use of library functions.
If you have completed the `DList` exercise you can rewrite your code from `infixOrder1`
replacing the uses of `DL.toList`, `DL.empty`, `DL.singleton`, `DL.append` with your
definitions in that file.
-}

infixOrder2 :: Tree Int -> [Int]
infixOrder2 = undefined

{-
On my microbenchmark, this also sped up the traversal!

       ghci> sum (infixOrder2 (bigLeftTree 10000))
       50005000
       (0.01 secs, 6,696,624 bytes)

Foldable Trees
--------------

Does this idea generalize to other forms of tree recursion? You betcha.

Let's generalize the "base case" and "inductive step" of the definition above, separating
the recursion from the specific operation of traversal. Now turn your definition
of `infixOrder2` into a generic definition of `foldrTree`, specialized to the operations
that we need for an infix traversal:
-}

foldrTree :: (a -> b -> b) -> b -> Tree a -> b
foldrTree f b t = undefined

{-
>
-}

infixOrder3 :: Tree a -> [a]
infixOrder3 = foldrTree (:) []

{-
       ghci> sum (infixOrder3 (bigLeftTree 10000))
       50005000
       (0.01 secs, 6,856,728 bytes)

This fold function is general. We can use it define *many* different tree operations.
-}

sizeTree :: Tree Int -> Int
sizeTree = foldrTree (const (1 +)) 0

sumTree :: Tree Int -> Int
sumTree = foldrTree (+) 0

anyTree :: (a -> Bool) -> Tree a -> Bool
anyTree f = foldrTree (\x b -> f x || b) False

allTree :: (a -> Bool) -> Tree a -> Bool
allTree f = foldrTree (\x b -> f x && b) True

{-
Extra challenge
---------------

Now use `foldrTree` as an inspiration to define a `foldlTree` function, which
folds over the tree in the opposite order.
-}

foldlTree :: (b -> a -> b) -> b -> Tree a -> b
foldlTree = undefined

revOrder :: Tree a -> [a]
revOrder = foldlTree (flip (:)) []

trevOrder :: Test
trevOrder = "revOrder" ~: revOrder exTree ~?= [7, 9, 5, 4, 2, 1]

{-
Note: Although they are efficient and useful, neither `foldlTree` nor `foldrTree` capture the general principle of tree recursion.
-}

foldTree :: (a -> b -> b -> b) -> b -> Tree a -> b
foldTree _ e Empty = e
foldTree f e (Branch a n1 n2) = f a (foldTree f e n1) (foldTree f e n2)

{-
Define `foldrTree` and `foldlTree` in terms of `foldTree`. (This is challenging!)
-}

foldrTree' :: (a -> b -> b) -> b -> Tree a -> b
foldrTree' = undefined

tree1 :: Tree Int
tree1 = Branch 1 (Branch 2 Empty Empty) (Branch 3 Empty Empty)

tfoldrTree' :: Test
tfoldrTree' = "foldrTree'" ~: foldrTree' (+) 0 tree1 ~?= 6

foldlTree' :: (b -> a -> b) -> b -> Tree a -> b
foldlTree' = undefined

tfoldlTree' :: Test
tfoldlTree' = "foldlTree'" ~: foldlTree' (+) 0 tree1 ~?= 6
