{-
---
fulltitle: Red Black Trees (Redux)
date: October 16, 2024
---

This module implements a persistent version of a common balanced tree
structure: red-black trees.

In lecture, we will demonstrate how to use *GADTs* to statically enforce the RBT invariants using
the type checker, using this version as our starting point.

The definitions below are the same as the RedBlack module from last week, except that

(a) we use standalone deriving for Show & Foldable, and give an explicit instance of Eq
(b) we use the alternative GADT syntax to define the Color & RBT datatypes
(c) we only do the insert function (we won't have time to demonstrate deletion)
(d) we've slightly refactored balance and blacken

Below, most of the code should be familiar.

In preparation for the demo, we'll include a few additional language features, for GADTs,
using datatypes in kinds, for type-level functions (new) and to easily run all of the
QuickCheck properties in the file.
-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module RedBlackGADT0 where

{-
We'll make the following standard library functions available for this
implementation.
-}

import Data.Foldable qualified as Foldable
import Data.Kind (Type)
{-
And we'll use QuickCheck for testing.
-}

import Test.QuickCheck hiding (elements)

{-
API preview
-----------

Our goal is to use red-black trees to implement a finite set data structure, with a similar interface to Java's [SortedSet](https://docs.oracle.com/javase/8/docs/api/java/util/SortedSet.html)
or Haskell's [Data.Set](http://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Set.html).

This module defines the following API for finite sets:

<    type RBT a  -- a red-black tree containing elements of type a

<    empty         :: RBT a
<    insert        :: Ord a => a -> RBT a -> RBT a
<    member        :: Ord a => a -> RBT a -> Bool
<    elements      :: RBT a -> [a]

This interface specifies a *persistent* set of ordered elements. We can tell
that the implementation is persistent just by looking at the types of the
operations. In particular, the empty operation is not a function, it is just
a set --- there is only one empty set. If we were allowed to mutate it, it
wouldn't be empty any more. Furthermore, the `insert` and `delete` operations
return a new set instead of modifying their argument.

Red-black trees
---------------

Here, again, are the invariants for red-black trees:

  1. The empty nodes at the leaves are black.

  2. The root is black.

  3. From each node, every path to a leaf has the same number of black nodes.

  4. Red nodes have black children.

Tree Structure
--------------

If it has been a while since you have seen red-black trees, [refresh your
memory](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree).

A red-black tree is a binary search tree where every node is marked with a
color (red `R` or black `B`).  For brevity, we will abbreviate the standard
tree constructors `Empty` and `Branch` as `E` and `N`.

These are the same definitions as before, but use the GADT syntax.
-}

data Color where
  R :: Color
  B :: Color

data T (a :: Type) where
  E :: T a
  N :: Color -> T a -> a -> T a -> T a

{-
We define the RBT type by distinguishing the root of the tree.
-}

data RBT (a :: Type) where
  Root :: T a -> RBT a

{-
Type class instances
--------------------

When we modify the definitions above to use GADTs, we need to use "standalone deriving".
These lines derive the usual `Show` and `Foldable` instances, as if we had
added `deriving (Show,Foldable)` in the datatype definitions above.
-}

-- Show instances

deriving instance Show Color

deriving instance (Show a) => Show (T a)

deriving instance (Show a) => Show (RBT a)

-- Foldable instances

deriving instance Foldable T

deriving instance Foldable RBT

{-
We give the full definition of the equality definition for colors, so that we can
discuss its interaction with GADTs
-}

-- Eq instance

instance Eq Color where
  (==) :: Color -> Color -> Bool
  R == R = True
  B == B = True
  _ == _ = False

{-
Simple operations
-----------------

We can access all of the elements of the red-black tree with an inorder tree
traversal, directly available from the `Foldable` instance.
-}

-- | List all of the elements of the finite set, in ascending order
elements :: RBT a -> [a]
elements = Foldable.toList

{-
Note above that we did not derive the Eq instance in the definition of `RBT`.
Instead, we will define two red-black trees to be equal when they contain
the same elements.
-}

instance (Eq a) => Eq (RBT a) where
  (==) :: (Eq a) => RBT a -> RBT a -> Bool
  t1 == t2 = elements t1 == elements t2

{-
Every tree has a color, determined by the following function.
-}

-- | access the color of the tree
color :: T a -> Color
color t = case t of
  (N c _ _ _) -> c
  E -> B

{-
We can also calculate the "black height" of a tree -- i.e. the number of black
nodes from the root to every leaf. It is an invariant that this number is the
same for every path in the tree, so we only need to look at one side.
-}

-- | calculate the black height of the tree
blackHeight :: T a -> Int
blackHeight t = case t of
  E -> 1
  (N c a _ _) -> blackHeight a + (if c == B then 1 else 0)

{-
Implementation
--------------

Not every value of type `RBT a` is a *valid* red-black tree.

Red-black trees must, first of all, be binary search trees. That means that
the data in the tree must be stored in order.

Furthermore, red-black trees must satisfy also the following four invariants
about colors.

  1. Empty trees are black

  2. The root (i.e. the topmost node) of a nonempty tree is black

  3. From each node, every path to an `E`
     has the same number of black nodes

  4. Red nodes have black children

\* The first invariant is true by definition of the `color` function above. The
  others we will have to maintain as we implement the various tree
  operations.

\* Together, these invariants imply that every red-black tree is "approximately
  balanced", in the sense that the longest path to an `E` is no more than
  twice the length of the shortest.

\* From this balance property, it follows that the `member`, `insert` and
    `delete` operations will run in `O(log_2 n)` time.

Sample Trees
------------

Here are some example trees; only the first one below is actually a red-black
tree. The others violate the invariants above in some way.
-}

good1 :: RBT Int
good1 = Root $ N B (N B E 1 E) 2 (N B E 3 E)

{-
Here is one with a red Root (violates invariant 2). We want this definition to
 be rejected by the type checker.
-}

bad1 :: RBT Int
bad1 = Root $ N R (N B E 1 E) 2 (N B E 3 E)

{-
Here's one that violates the black height requirement (invariant 3). We want
 this definition to be rejected by the type checker.
-}

bad2 :: RBT Int
bad2 = Root $ N B (N R E 1 E) 2 (N B E 3 E)

{-
Here's a red-black tree that has a red node with a red child (violates
 invariant 4). We want this definition to be rejected by the type checker.
-}

bad3 :: RBT Int
bad3 = Root $ N B (N R (N R E 1 E) 2 (N R E 3 E)) 4 E

{-
Here's a red-black tree that isn't a binary search tree (i.e. the *values*
stored in the tree are not in strictly increasing order). We won't use GADTs to
enforce this property.
-}

bad4 :: RBT Int
bad4 = Root $ N B (N B E 1 E) 3 (N B E 2 E)

{-
All sample trees, plus the empty tree for good measure.
-}

trees :: [(String, RBT Int)]
trees =
  [ ("good1", good1),
    ("bad4", bad4),
    ("empty", empty)
  ]

{-
Checking validity for red-black trees
-----------------------------------

We can write QuickCheck properties for each of the invariants above.

First, let's can define when a red-black tree satisfies the binary search tree
condition. There are several ways of stating this condition, some of which
are more efficient to check than others. Hughes suggests using an `O(n^2)`
operation, because it obviously captures the invariant.

Here, we'll use a linear-time operation, and leave it to you to convince yourself
that it is equivalent [4].
-}

-- | A red-black tree is a BST if an inorder traversal is strictly ordered.
isBST :: (Ord a) => RBT a -> Bool
isBST = orderedBy (<) . elements

-- | Are the elements in the list ordered by the provided operation?
orderedBy :: (a -> a -> Bool) -> [a] -> Bool
orderedBy op (x : y : xs) = x `op` y && orderedBy op (y : xs)
orderedBy _ _ = True

{-
Now we can also think about validity properties for the colors in the tree.

1. The empty tree is black. (This is trivial, nothing to do here.)

2. The root of the tree is black.
-}

isRootBlack :: RBT a -> Bool
isRootBlack (Root t) = color t == B

{-
3.  For all nodes in the tree, all downward paths from the node to `E` contain
 the same number of black nodes. (Define this yourself, making sure that your
 test passes for `good1` and fails for `bad2`.)
-}

consistentBlackHeight :: RBT a -> Bool
consistentBlackHeight (Root t) = aux t
  where
    aux :: T a -> Bool
    aux (N _ a _ b) = blackHeight a == blackHeight b && aux a && aux b
    aux E = True

{-
4. All children of red nodes are black.
-}

noRedRed :: RBT a -> Bool
noRedRed (Root t) = aux t
  where
    aux :: T a -> Bool
    aux (N R a _ b) = color a == B && color b == B && aux a && aux b
    aux (N B a _ b) = aux a && aux b
    aux E = True

{-
We can combine the predicates together using the following definition:
-}

valid :: (Ord a) => RBT a -> Bool
valid t = isRootBlack t && consistentBlackHeight t && noRedRed t && isBST t

{-
Take a moment to try out the properties above on the sample trees by running
the `testProps` function in ghci. The good trees should satisfy all of the
properties, whereas the bad trees should fail at least one of them.
-}

testProps :: IO ()
testProps = mapM_ checkTree trees
  where
    checkTree (name, tree) = do
      putStrLn $ "******* Checking " ++ name ++ " *******"
      quickCheck $ once (counterexample "RB2" $ isRootBlack tree)
      quickCheck $ once (counterexample "RB3" $ consistentBlackHeight tree)
      quickCheck $ once (counterexample "RB4" $ noRedRed tree)
      quickCheck $ once (counterexample "BST" $ isBST tree)

{-
For convenience, we can also create a single property that combines all four
 color invariants together along with the BST invariant. The `counterexample`
 function reports which part of the combined property fails.

We will specialize all of the QuickCheck properties that we define to
 red-black trees that only contain small integer values.
-}

type A = Small Int

prop_Valid :: RBT A -> Property
prop_Valid tree =
  counterexample "RB2" (isRootBlack tree)
    .&&. counterexample "RB3" (consistentBlackHeight tree)
    .&&. counterexample "RB4" (noRedRed tree)
    .&&. counterexample "BST" (isBST tree)

{-
Arbitrary Instance
------------------
-}

instance (Ord a, Arbitrary a) => Arbitrary (RBT a) where
  arbitrary :: Gen (RBT a)
  arbitrary = foldr insert empty <$> (arbitrary :: Gen [a])

  shrink :: RBT a -> [RBT a]
  shrink (Root E) = []
  shrink (Root (N _ l _ r)) = [hide l, hide r]
    where
      hide :: T a -> RBT a
      hide E = Root E
      hide n@N {} = blacken n

{-
Implementation
--------------------
-}

blacken :: T a -> RBT a
blacken t = case t of
  (N _ l v r) -> Root (N B l v r)
  E -> error "only blacken result of ins"

empty :: RBT a
empty = Root E

member :: (Ord a) => a -> RBT a -> Bool
member x0 (Root t) = aux x0 t
  where
    aux :: (Ord a) => a -> T a -> Bool
    aux x E = False
    aux x (N _ a y b)
      | x < y = aux x a
      | x > y = aux x b
      | otherwise = True

insert :: (Ord a) => a -> RBT a -> RBT a
insert x (Root t) = blacken (ins x t)

ins :: (Ord a) => a -> T a -> T a
ins x E = N R E x E
ins x s@(N c a y b)
  | x < y = balanceL c (ins x a) y b
  | x > y = balanceR c a y (ins x b)
  | otherwise = s

{-
The original `balance` function looked like this:
-}

-- Original version of balance
{-
balance (N B (N R (N R a x b) y c) z d) = N R (N B a x b) y (N B c z d)
balance (N B (N R a x (N R b y c)) z d) = N R (N B a x b) y (N B c z d)

balance (N B a x (N R (N R b y c) z d)) = N R (N B a x b) y (N B c z d)
balance (N B a x (N R b y (N R c z d))) = N R (N B a x b) y (N B c z d)
balance t = t
-}

{-
The first two clauses handled cases where the left subtree was
unbalanced as a result of an insertion, while the last two handle
cases where a right-insertion has unbalanced the tree.

Here, we split this function in two to recognize that we have information from
`ins` above. We know exactly where to look for the red/red violation! If we
inserted on the left, then we should balance on the left. If we inserted on
the right, then we should balance on the right.
-}

balanceL :: Color -> T a -> a -> T a -> T a
balanceL B (N R (N R a x b) y c) z d = N R (N B a x b) y (N B c z d)
balanceL B (N R a x (N R b y c)) z d = N R (N B a x b) y (N B c z d)
balanceL c a x b = N c a x b

balanceR :: Color -> T a -> a -> T a -> T a
balanceR B a x (N R (N R b y c) z d) = N R (N B a x b) y (N B c z d)
balanceR B a x (N R b y (N R c z d)) = N R (N B a x b) y (N B c z d)
balanceR c a x b = N c a x b

{-
This version is slightly more efficient than the previous version and will
be easier for us to augment with more precise types.

What properties should we test with QuickCheck?
---------------------------------------------

\* Validity Testing

We already have defined `prop_Valid` which tests whether its argument is a
valid red-black tree. When we use this with the `Arbitrary` instance that we
defined above, we are testing if the `empty` tree is valid and if the
`insert` function preserves this invariant.

However, we also need to make sure that our `shrink` operation
   preserves invariants.
-}

prop_ShrinkValid :: RBT A -> Property
prop_ShrinkValid t = conjoin (map prop_Valid (shrink t))

{-
\* Metamorphic Testing
-}

prop_InsertEmpty :: A -> Bool
prop_InsertEmpty x = elements (insert x empty) == [x]

prop_InsertInsert :: A -> A -> RBT A -> Bool
prop_InsertInsert x y t =
  insert x (insert y t) == insert y (insert x t)

prop_MemberEmpty :: A -> Bool
prop_MemberEmpty x = not (member x empty)

prop_MemberInsert :: A -> A -> RBT A -> Bool
prop_MemberInsert k k0 t =
  member k (insert k0 t) == (k == k0 || member k t)

{-
Running QuickCheck
------------------

Using the `TemplateHaskell` extension, the following code below defines an
operation that will invoke QuickCheck with all definitions that start with
`prop_` above. This code must come *after* all of the definitions above (and
`runTests` is not in scope before this point).
-}

return []

runTests :: IO Bool
runTests = $quickCheckAll
