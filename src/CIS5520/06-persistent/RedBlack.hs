{-
---
fulltitle: Red Black Trees
date: October 7, 2024
---

This module implements a persistent version of a common balanced tree
structure: red-black trees.

It serves as both a demonstration of a *pure* functional data structure
and as an additional use-case for QuickCheck.

Before reading the rest of this module, you should first watch
this keynote presentation by John Hughes, one of the inventors of QuickCheck.

\* [How to Specify It! A guide to writing properties of pure
   functions](https://www.youtube.com/watch?v=G0NUOst-53U)

If you would rather read a paper than watch a talk, John Hughes also has
written a [paper](https://research.chalmers.se/en/publication/517894) about
this talk.

The `06-persistent` quiz covers both the video and the module below.
-}

module RedBlack where

{-
We'll make the following standard library functions available for this
 implementation.
-}

import Data.Foldable qualified as Foldable
{-
And we'll use QuickCheck for testing. We'll import some of the most commonly
used types, operators, and functions without qualification. And then make the
rest of the library available with the prefix `QC.`
-}

import Test.QuickCheck (Arbitrary (..), Gen, Property, quickCheck, (.&&.))
import Test.QuickCheck qualified as QC

{-
API preview
-----------

Our goal is to use red-black trees to implement a finite set data structure, with a similar interface to Java's [SortedSet](https://docs.oracle.com/javase/8/docs/api/java/util/SortedSet.html)
or Haskell's [Data.Set](http://hackage.haskell.org/package/containers-0.6.4.1/docs/Data-Set.html).

This module defines the following API for finite sets:

<    type RBT a  -- a red-black tree containing elements of type a

<    empty         :: RBT a
<    insert        :: Ord a => a -> RBT a -> RBT a
<    delete        :: Ord a => a -> RBT a -> RBT a
<    member        :: Ord a => a -> RBT a -> Bool
<    elements      :: RBT a -> [a]

This interface specifies a *persistent* set of ordered elements. We can tell
that the implementation is persistent just by looking at the types of the
operations. In particular, the empty operation is not a function, it is just
a set --- there is only one empty set. If we were allowed to mutate it, it
wouldn't be empty any more. Furthermore, the `insert` and `delete` operations
return a new set instead of modifying their argument.

Tree Structure
--------------

If it has been a while since you have seen red-black trees, [refresh your
memory](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree).

A red-black tree is a binary search tree where every node is marked with a
color (red `R` or black `B`).  For brevity, we will abbreviate the standard
tree constructors `Empty` and `Branch` as `E` and `N`. (The latter stands for
\*node*.) Using the `DeriveFoldable` language extension we can automatically
make this tree an instance of the `Data.Foldable` type class.
-}

data Color = R | B deriving (Eq, Show)

data T a = E | N Color (T a) a (T a) deriving (Eq, Show, Foldable)

{-
We define the RBT type by distinguishing the root of the tree.
-}

newtype RBT a = Root (T a) deriving (Show, Foldable)

{-
We can access all of the elements of the red-black tree with an inorder tree
traversal, directly available from the `Foldable` instance.
-}

-- | List all of the elements of the finite set, in ascending order
-- >>> elements (Root (N B (N B E 1 E) 2 (N B E 3 E)))
-- [1,2,3]
elements :: RBT a -> [a]
elements = Foldable.toList

{-
Note above that we did not derive the Eq instance in the definition of `RBT`.
Instead, we will define two red-black trees to be equal when they contain
the same elements.
-}

-- >>> (Root (N B (N R E 1 E) 2 E)) == (Root (N B E 1 (N R E 2 E)))
-- True
instance (Eq a) => Eq (RBT a) where
  (==) :: (Eq a) => RBT a -> RBT a -> Bool
  t1 == t2 = elements t1 == elements t2

{-
Every tree has a color, determined by the following function.
-}

-- | access the color of the tree
color :: T a -> Color
color (N c _ _ _) = c
color E = B

{-
We can also calculate the "black height" of a tree -- i.e. the number of black
nodes from the root to every leaf. It is an *invariant* that this number is the
same for every path in the tree, so we only need to look at one side.
-}

-- | calculate the black height of the tree
-- >>> blackHeight (N B (N R E 1 E) 2 (N R E 3 E))
-- 2
blackHeight :: T a -> Int
blackHeight E = 1
blackHeight (N c a _ _) = blackHeight a + (if c == B then 1 else 0)

{-
Valid Red-Black Trees
---------------------

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
Here is one with a red Root (violates invariant 2).
-}

bad1 :: RBT Int
bad1 = Root $ N R (N B E 1 E) 2 (N B E 3 E)

{-
Here's one that violates the black height requirement (invariant 3).
-}

bad2 :: RBT Int
bad2 = Root $ N B (N R E 1 E) 2 (N B E 3 E)

{-
Now define a red-black tree that violates invariant 4.
-}

bad3 :: RBT Int
bad3 = undefined

{-
Now define a red-black tree that isn't a binary search tree (i.e. the *values*
stored in the tree are not in strictly increasing order).
-}

bad4 :: RBT Int
bad4 = undefined

{-
All sample trees, plus the empty tree for good measure.
-}

trees :: [(String, RBT Int)]
trees =
  [ ("good1", good1),
    ("bad1", bad1),
    ("bad2", bad2),
    ("bad3", bad3),
    ("bad4", bad4),
    ("empty", empty)
  ]

{-
Checking validity for binary-search trees
-----------------------------------------

We can write QuickCheck properties for each of the invariants above.

First, let's can define when a red-black tree satisfies the binary search tree
condition. There are several ways of stating this condition, some of which
are more efficient to check than others. Hughes suggests using an `O(n^2)`
operation, because it obviously captures the BST invariant.
-}

-- >>> isBST good1
-- True
-- >>> isBST bad4
-- False
isBST :: (Ord a) => RBT a -> Bool
isBST (Root t) = aux t
  where
    aux E = True
    aux (N _ l k r) =
      aux l
        && aux r
        && all (< k) (elements (Root l))
        && all (> k) (elements (Root r))

{-
Here, we'll use a linear-time operation, and leave it to you to convince yourself
that it more efficient and equivalent to the definition above [4].
-}

-- | A red-black tree is a BST if an inorder traversal is strictly ordered.
isBST' :: (Ord a) => RBT a -> Bool
isBST' = orderedBy (<) . elements

{-
>
-}

-- | Are the elements in the list ordered by the provided operation?
orderedBy :: (a -> a -> Bool) -> [a] -> Bool
orderedBy op (x : y : xs) = x `op` y && orderedBy op (y : xs)
orderedBy _ _ = True

{-
Checking validity for red-black trees
-------------------------------------

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
consistentBlackHeight = undefined

{-
4. All children of red nodes are black.
-}

noRedRed :: RBT a -> Bool
noRedRed (Root t) = aux t
  where
    aux (N R a _ b) = color a == B && color b == B && aux a && aux b
    aux (N B a _ b) = aux a && aux b
    aux E = True

{-
We can combine the predicates together using the following definition:
-}

valid :: (Ord a) => RBT a -> Bool
valid t = isRootBlack t && consistentBlackHeight t && noRedRed t && isBST t

{-
And use it to reassure ourselves that the `empty` tree is valid.
-}

-- >>> valid (empty :: RBT Int)
-- True

{-
Now, take a moment to try out the properties above on the sample trees by running
the `testProps` function in the terminal. The good trees should satisfy all of the
properties, whereas the bad trees should fail at least one of them.
-}

testProps :: IO ()
testProps = mapM_ checkTree trees
  where
    checkTree (name, tree) = do
      putStrLn $ "******* Checking " ++ name ++ " *******"
      quickCheck $ QC.once (QC.counterexample "RB2" $ isRootBlack tree)
      quickCheck $ QC.once (QC.counterexample "RB3" $ consistentBlackHeight tree)
      quickCheck $ QC.once (QC.counterexample "RB4" $ noRedRed tree)
      quickCheck $ QC.once (QC.counterexample "BST" $ isBST tree)

{-
For convenience, we can also create a single property that combines all four
 color invariants together along with the BST invariant. The `counterexample`
 function reports which part of the combined property fails.

We will specialize all of the QuickCheck properties that we define to
 red-black trees that only contain small integer values.
-}

type A = QC.Small Int

prop_Valid :: RBT A -> QC.Property
prop_Valid tree =
  QC.counterexample "RB2" (isRootBlack tree)
    .&&. QC.counterexample "RB3" (consistentBlackHeight tree)
    .&&. QC.counterexample "RB4" (noRedRed tree)
    .&&. QC.counterexample "BST" (isBST tree)

{-
Arbitrary Instance
------------------

Our goal is to use QuickCheck to verify that the RBT-based set operations
preserve these invariants. To do this, we will need an arbitrary instance for
the `RBT` type. However, because we want to verify that `prop_Valid` is an
\*invariant* of our data structure, we only want to test our operations on
trees that satisfy this invariant. And not many do [5]!

Therefore, we will make sure that our `RBT` generator only produces valid
red-black trees. How can we do this?

The key idea is to use a generator based on the `insert` and `empty` operations
that we will define define.  Given a list elements, we can used `foldr` to
construct a red-black tree:
-}

fromList :: (Ord a) => [a] -> RBT a
fromList = foldr insert empty

{-
If our `insert` function preserves the RBT invariants, then we will only
generate valid red-black trees. If it does not, then running QuickCheck with
`prop_Valid` should fail.

Below, we use the operator form of `fmap`, written `<$>` to first generate an
arbitrary list of values, and then fold over that list, inserting them one by
one.
-}

instance (Ord a, Arbitrary a) => Arbitrary (RBT a) where
  arbitrary :: Gen (RBT a)
  arbitrary = fromList <$> (arbitrary :: Gen [a])

  {-
  >
  -}

  shrink :: RBT a -> [RBT a]
  shrink (Root E) = []
  shrink (Root (N _ l _ r)) = [blacken l, blacken r]

{-
The `shrink`` function is used by QuickCheck to minimize counterexamples. The
idea of this function is that it should, when given a tree, produce some
smaller tree. Both the left and right subtrees of a wellformed red-black tree
are red-black trees as long as we make sure that their top nodes are black.
We can ensure that the result is black using the following simple function.
-}

-- | Create an RBT by blackening the top node (if necessary)
blacken :: T a -> RBT a
blacken E = Root E
blacken (N _ l v r) = Root (N B l v r)

{-
What properties should we test with QuickCheck?
-----------------------------------------------

The Hughes talk describes several methods for generating QuickCheck properties
 for an API under test. Here, we will focus on two of them: validity testing
 and metamorphic testing.

\* Validity Testing

We already have defined `prop_Valid` which tests whether its argument is a
 valid red-black tree. When we use this with the `Arbitrary` instance that we
 defined above, we are testing if the `empty` tree is valid and if the
 `insert` function preserves this invariant.

However, we also need properties to make sure that our `delete` and `shrink`
  operations preserve invariants.
-}

prop_DeleteValid :: RBT A -> A -> Property
prop_DeleteValid t x = prop_Valid (delete x t)

prop_ShrinkValid :: RBT A -> Property
prop_ShrinkValid t = QC.conjoin (map prop_Valid (shrink t))

-- Run all validity tests
checkValidity :: IO ()
checkValidity = do
  quickCheck $ QC.withMaxSuccess 10000 prop_Valid
  quickCheck $ QC.withMaxSuccess 10000 prop_DeleteValid
  quickCheck $ QC.withMaxSuccess 10000 prop_ShrinkValid

{-
\* Metamorphic Testing

The idea of metamorphic testing is to describe the relationship between
 multiple function calls in the interface. Focusing on `empty`, `insert`,
 `delete`, and `member`, we can define the following tests:
-}

prop_InsertEmpty :: A -> Bool
prop_InsertEmpty x = elements (insert x empty) == [x]

prop_InsertInsert :: A -> A -> RBT A -> Bool
prop_InsertInsert x y t =
  insert x (insert y t) == insert y (insert x t)

{-
>
-}

prop_InsertDelete :: A -> A -> RBT A -> Bool
prop_InsertDelete k k0 t =
  insert k (delete k0 t)
    == if k == k0 then insert k t else delete k0 (insert k t)

prop_DeleteEmpty :: A -> Bool
prop_DeleteEmpty x = delete x empty == empty

prop_DeleteInsert :: A -> A -> RBT A -> Bool
prop_DeleteInsert k k0 t =
  delete k (insert k0 t)
    == if k == k0
      then if member k0 t then delete k t else t
      else insert k0 (delete k t)

{-
>
-}

prop_DeleteDelete :: A -> A -> RBT A -> Bool
prop_DeleteDelete x y t =
  delete x (delete y t) == delete y (delete x t)

prop_MemberEmpty :: A -> Bool
prop_MemberEmpty x = not (member x empty)

prop_MemberInsert :: A -> A -> RBT A -> Bool
prop_MemberInsert k k0 t =
  member k (insert k0 t) == (k == k0 || member k t)

{-
>
-}

prop_MemberDelete :: A -> A -> RBT A -> Bool
prop_MemberDelete k k0 t =
  member k (delete k0 t) == (k /= k0 && member k t)

-- Run all of the metamorphic tests
checkMetamorphic :: IO ()
checkMetamorphic = do
  quickCheck $ QC.withMaxSuccess 10000 prop_InsertEmpty
  quickCheck $ QC.withMaxSuccess 10000 prop_InsertInsert
  quickCheck $ QC.withMaxSuccess 10000 prop_InsertDelete
  quickCheck $ QC.withMaxSuccess 10000 prop_DeleteEmpty
  quickCheck $ QC.withMaxSuccess 10000 prop_DeleteInsert
  quickCheck $ QC.withMaxSuccess 10000 prop_DeleteDelete
  quickCheck $ QC.withMaxSuccess 10000 prop_MemberInsert
  quickCheck $ QC.withMaxSuccess 10000 prop_MemberDelete

{-
Implementing the API
--------------------

Now that we know what it means for our implementation to be correct,
we can start writing code.

We now just need to implement the API functions for this data
structure.  The `empty`, and `member` operations are
straightforward.
-}

empty :: RBT a
empty = Root E

member :: (Ord a) => a -> RBT a -> Bool
member x (Root t) = aux t
  where
    aux E = False
    aux (N _ a y b)
      | x < y = aux a
      | x > y = aux b
      | otherwise = True

{-
However, `insert` and `delete` are, of course, a bit trickier. We'll define
 them both with the help of auxiliary functions, `ins` and `del`, that can
 violate the red-black invariants temporarily. To make sure that everything
 works out, we `blacken` the result of these helper functions to make sure
 that property 2 holds.
-}

insert :: (Ord a) => a -> RBT a -> RBT a
insert x (Root t) = blacken (ins x t)

delete :: (Ord a) => a -> RBT a -> RBT a
delete x (Root t) = blacken (del x t)

{-
Implementation of insert
------------------------

First, let's consider the implementation of `ins`.

The recursive function `ins` walks down the tree until...
-}

ins :: (Ord a) => a -> T a -> T a
{-
... it gets to an empty tree, in which case
it constructs a new (red) node containing the
value being inserted...
-}

ins x E = N R E x E
{-
... or it gets to a branching node. In this case, it
finds the correct subtree to insert the value, or discovers that the value
being inserted is already in the tree (in which case it returns the input
unchanged):
-}

ins x s@(N c a y b)
  | x < y = balance (N c (ins x a) y b)
  | x > y = balance (N c a y (ins x b))
  | otherwise = s

{-
Note that this definition breaks the RBT invariants in two ways --- it could
create a tree with a red root (when we insert into an empty tree), or create a
red node with a red child (when we insert into a subtree).  The former case is
taken care of with the call to `blacken` at the toplevel definition of the
`insert` function. To repair the second situation, we need to rebalance the
tree.

Balancing
---------

In the recursive calls of `ins`, before returning the new tree, we may need to
rearrange the tree to maintain the red-black invariants. The code to do this is
encapsulated in a helper function `balance`.

\* The key insight in writing the balancing function is that we do not try to
rebalance as soon as we see a red node with a red child. That tree can be
fixed just by blackening the root of the tree, so we return this tree as-is.
(We call such trees, which violate invariant four only at the root
"infrared").

The real problem comes when we've inserted a new red node between a black
parent and a red child. Here we need to rearrange trees that have a
single black-red-red path starting at the root, but are otherwise valid.
Because the root has two children and four grandchildren, there are
four ways in which such a path can happen. (The letters 'a','b','c',
and 'd' below stand for arbitrary subtrees.)

           B             B           B              B
          / \           / \         / \            / \
         R   d         R   d       a   R          a   R
        / \           / \             / \            / \
       R   c         a   R           R   d          b   R
      / \               / \         / \                / \
     a   b             b   c       b   c              c   d

\* The result of rebalancing maintains the black height by converting
all of the trees above to a red parent with black children.

                                     R
                                   /   \
                                  B     B
                                 / \   / \
                                a   b c   d

In code, we can use pattern matching to directly identify the four trees above
and rewrite them to the balanced tree.  All other trees are left alone.
-}

balance :: T a -> T a
balance (N B (N R (N R a x b) y c) z d) = N R (N B a x b) y (N B c z d)
balance (N B (N R a x (N R b y c)) z d) = N R (N B a x b) y (N B c z d)
balance (N B a x (N R (N R b y c) z d)) = N R (N B a x b) y (N B c z d)
balance (N B a x (N R b y (N R c z d))) = N R (N B a x b) y (N B c z d)
balance t = t

{-
Red-Black deletion
------------------

Deletion is more complicated [1].
-}

del :: (Ord a) => a -> T a -> T a
del _x E = E
del x (N _ a y b)
  | x < y = delLeft a y b
  | x > y = delRight a y b
  | otherwise = merge a b
  where
    delLeft c@(N B _ _ _) z d = balLeft (del x c) z d
    delLeft c z d = N R (del x c) z d

    delRight c z d@(N B _ _ _) = balRight c z (del x d)
    delRight c z d = N R c z (del x d)

{-
The `del` function works by first finding the appropriate place in the tree to
delete the given element (if it exists).  At the node where we find the
element, we delete it by merging the two subtrees together.  At other nodes,
we call `del` recursively on one of the two subtrees, using `delLeft` and
`delRight`. If the subtree that we are deleting from is a black node, this
recursive call will change its black height, so we will need to rebalance to
restore the invariants (using `balLeft` and `balRight`).

In other words, we have an invariant that deleting an element from a *black*
tree of height `n + 1` returns a tree of height `n`, while deleting from a
\*red* tree (or an empty tree) preserves the black height.

As above, the final tree that we produce may be red or black, so we blacken
this result to restore this invariant.

\*Rebalancing function after a left deletion from a black-rooted tree*.

There are three cases to consider:
  1. left subtree is red.
  2. both left and right subtrees are black.
  3. left subtree is black and right is red.

These three cases are covered by the following function. In each case, we
produce a balanced tree even though we know that the black height of the left
subtree is one less than the black height of the right subtree.
-}

balLeft :: T a -> a -> T a -> T a
balLeft (N R a x b) y c = N R (N B a x b) y c
balLeft bl x (N B a y b) = balance (N B bl x (N R a y b))
balLeft bl x (N R (N B a y b) z c) =
  N R (N B bl x a) y (balance (N B b z (redden c)))
balLeft _ _ _ = error "invariant violation"

{-
Above, we need the following helper function to reduce the black height of the
subtree `c` reddening the node. This operation should only be called on black
nodes. Here, we know that `c` must be black because it is the child of a red
node, and we know that `c` can't be `E` because it must have the same black
height as `(N B a y b)`.
-}

redden :: T a -> T a
redden (N B a x b) = N R a x b
redden _ = error "invariant violation"

{-
\*Rebalance after deletion from the right subtree.* This function is symmetric
 to the above code.
-}

balRight :: T a -> a -> T a -> T a
balRight a x (N R b y c) = N R a x (N B b y c)
balRight (N B a x b) y bl = balance (N B (N R a x b) y bl)
balRight (N R a x (N B b y c)) z bl =
  N R (balance (N B (redden a) x b)) y (N B c z bl)
balRight _ _ _ = error "invariant violation"

{-
Finally, we need to glue two red-black trees together into a single tree
(after deleting the element in the middle). If one subtree is red and the
other black, we can call merge recursively, pushing the red node
up. Otherwise, if both subtrees are black or both red, we can merge the inner
pair of subtrees together. If that result is red, then we can promote its
value up. Otherwise, we may need to rebalance.
-}

merge :: T a -> T a -> T a
merge E x = x
merge x E = x
merge (N R a x b) (N R c y d) =
  case merge b c of
    N R b' z c' -> N R (N R a x b') z (N R c' y d)
    bc -> N R a x (N R bc y d)
merge (N B a x b) (N B c y d) =
  case merge b c of
    N R b' z c' -> N R (N B a x b') z (N B c' y d)
    bc -> balLeft a x (N B bc y d)
merge a (N R b x c) = N R (merge a b) x c
merge (N R a x b) c = N R a x (merge b c)

{-
Running QuickCheck
------------------

Finally, now that we have completed the implementation, we can
verify that it works by running all of our tests.

main = IO ()
main = do
  putStrLn "Testing: isBST_isBST'"
  quickCheck prop_isBST_isBST'
  putStrLn "Validity tests
  checkValidity
  putStrLn "Metamorphic tests"
  checkMetamorphic

Notes
-----

[0] See also persistant [Java
implementation](http://wiki.edinburghhacklab.com/PersistentRedBlackTreeSet)
for comparison. Requires ~350 lines for the same implementation.

[1] This implementation of deletion is taken from Stefan Kahrs, "Red-black
trees with types", Journal of functional programming, 11(04), pp 425-432, July
2001

[2] Andrew Appel, ["Efficient Verified Red-Black Trees"](http://www.cs.princeton.edu/~appel/papers/redblack.pdf) September
    2011. Presents a Coq implementation of a verified Red Black Tree based on
    Karhs implementation.

[3] Matt Might has a blog post on an alternative version of the [RBT deletion operation](http://matt.might.net/articles/red-black-delete/).

[4] Joachim Breitner's [talk](https://www.youtube.com/watch?v=xcm_H36v_18) develops
 an optimized ordering check for binary trees, showing at each step why it is
 equivalent to the simpler version.

To check whether the two definitions of `isBST` are equal, we can create a
quickcheck property that tests the function on random trees.
-}

prop_isBST_isBST' :: (Ord a) => RBT a -> QC.Property
prop_isBST_isBST' t = QC.property (isBST t == isBST' t)

{-
[5] We can use QuickCheck to find out how many random trees violate the RBT property.

This function is a generator that produces a reasonable distribution of random trees.
-}

-- >>> QC.sample' (anyRBT:: Gen (RBT Int))

anyRBT :: forall a. (Ord a, Arbitrary a) => Gen (RBT a)
anyRBT = Root <$> QC.sized aux
  where
    aux :: Int -> Gen (T a)
    aux 1 = return E
    aux d =
      QC.frequency
        [ (1, return E),
          ( d,
            N
              <$> QC.oneof [return R, return B] -- color
              <*> aux (d `div` 2) -- left subtree
              <*> arbitrary -- value
              <*> aux (d `div` 2) -- right subtree
          )
        ]

{-
>
-}

-- | This property uses QC's `label` function to identify which properties
-- fail for each generated tree. It then calculates the percentages of trees
-- with each label. Only unlabeled trees are valid.
prop_howManyValid :: Property
prop_howManyValid = QC.forAll (anyRBT :: Gen (RBT Int)) $ \t ->
  QC.label
    ( (if not (isRootBlack t) then "RB2 " else "")
        <> (if not (consistentBlackHeight t) then "RB3 " else "")
        <> (if not (noRedRed t) then "RB4 " else "")
        <> (if not (isBST t) then "BST " else "")
    )
    True

{-
Running this property in GHC, with 10000 tests, reveals that only 7% of
the generated trees are valid. The largest category violates all *four*
invariants.

                  +++ OK, passed 10000 tests:
                  42.53% RB2 RB3 RB4 BST
                  39.42% RB3 RB4 BST
                  6.98%
                  4.50% RB3 BST
                  2.39% RB2 RB3 BST
                  0.97% RB2
                  0.92% RB2 RB4 BST
                  0.77% BST
                  0.41% RB4 BST
                  0.29% RB2 BST
                  0.29% RB3
                  0.23% RB2 RB3
                  0.19% RB2 RB4
                  0.09% RB2 RB3 RB4
                  0.02% RB4

-}
