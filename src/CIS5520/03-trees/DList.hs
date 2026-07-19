{-
---
fulltitle: "In class exercise: Difference lists"
---
-}

module DList where

-- https://www.seas.upenn.edu/~cis5520/current/lectures/stub/03-trees/DList.html

{-
Motivation
----------

In this exercise, you will use first-class functions to implement an alternative
version of lists, called `DList`s, short for *difference lists*.

`DList`s support O(1) append operations on lists, making them very
useful for append-heavy uses, such as logging and traversing
tree-like data structures in linear time.  (An implementation of this data
structure is available on [hackage](http://hackage.haskell.org/package/dlist)
but try to complete it on your own. No peeking!)

See the micro-benchmark section for experiments you can do once you
have completed the implementation.

Implementation
--------------

The key idea for difference lists is to represent them using a
\*function* from lists to lists. In otherwords, we will tell Haskell
that the type `[a] -> [a]` can be called a `DList a` for any type
parameter `a`.
-}

type DList a = [a] -> [a]

{-
You can think of a difference list as a data structure where we have "factored
out" the end of the list.

For example, we might write a regular list like this:
-}

list :: [Int]
list = 1 : 2 : 3 : [] -- end is nil

{-
The analogous "difference list" replaces the nil at the end of the list with a
parameter.
-}

dlist :: DList Int
dlist = \x -> 1 : 2 : 3 : x -- end is "x"

{-
This parameterization gives us flexibility. We can always fill in the
parameter with `[]` to get a normal list. However, we can also fill in the
parameter with another list, effectively appending [1, 2, 3] to the beginning
of that other list.

Once we have constructed a `DList`, the *only* way to observe it is to
convert it to a list. This data structure does not support any other form of
pattern matching.
-}

toList :: DList a -> [a]
toList x = x []

{-
See if you can figure out how to define the following standard list operations
for this new type of `DList`s. Remember that `DList a` is just a synonym for `[a] -> [a]`.
-}

-- | Create an empty DList
-- >>> toList empty
-- []
empty :: DList a
empty = undefined

-- | Create a DList containing a single element
-- >>> toList (singleton "a")
-- ["a"]
singleton :: a -> DList a
singleton x = undefined

-- | Append two DLists together
-- >>> toList ((singleton "a") `append` (singleton "b"))
-- ["a","b"]
append :: DList a -> DList a -> DList a
append = undefined

-- | Construct a DList from a head element and tail
-- >>> toList (cons "a" (singleton "b"))
-- ["a","b"]
cons :: a -> DList a -> DList a
cons = undefined

{-
Now write a function to convert a regular list to a `DList` using the above
definitions and `foldr`.
-}

-- | convert a normal list to a DList
-- >>> toList (fromList [1,2,3])
-- [1,2,3]
fromList :: [a] -> DList a
fromList = undefined

{-
Micro-benchmarks
----------------

Remember that you can execute the definitions in this module by loading it
into ghci.  In the terminal, you can use the command

      stack ghci DList.hs

to automatically start ghci and load the module.

If you'd like to see the difference between using (++) with regular lists and
`append` using DLists, in GHCi you can type

    ghci> :set +s

That will cause GHCi to give you timing and allocation information for each
evaluation that you do. Then, after you complete this file, you can test out
these logging micro-benchmarks.

This first example repeatedly appends a single character to its string
parameter with each recursive call.
-}

micro1 :: Char
micro1 = last (t 10000 "")
  where
    t :: Int -> [Char] -> [Char]
    t 0 l = l
    t n l = t (n - 1) (l ++ "s")

{-
    ghci> micro1
    's'
    (2.80 secs, 4,300,584,976 bytes)

This version does the same, except that this time it uses the `DList` operations.
-}

micro2 :: Char
micro2 = last (toList (t 10000 empty))
  where
    t :: Int -> DList Char -> DList Char
    t 0 l = l
    t n l = t (n - 1) (l `append` singleton 's')

{-
     ghci> micro2
     's'
     (0.02 secs, 10,359,248 bytes)

Notice how the second version is *much* faster and uses much less memory. Why
is this the case? The `++` operator for lists takes time proportional to its
first argument. So as the `l` argument of `t` grows in length, adding an `s`
to the end of it takes longer and longer. However, the `DList` `append`
operator doesn't have this behavior. It just remembers that we are going to
add an additional character at each step and then constructs the list all at
once with `toList`. Nifty!

We can also see the effect of using difference lists for *defining* a list
reverse function.

For example, consider this version of the list `reverse` function. This function
is easy to understand, but it is O(n^2), not O(n). Can you see why?
-}

naiveReverse :: [a] -> [a]
naiveReverse = rev
  where
    rev [] = []
    rev (x : xs) = rev xs ++ [x]

{-
Let's use a list containing 10,001 integers to micro-benchmark this function.
-}

bigList :: [Int]
bigList = [0 .. 10000]

{-
Don't skip this next step! Let's look at the last element in this list.  This
command will force GHCi to evaluate the expression above and allocate the list
into memory.  (We don't want our first benchmark below to include time for
constructing this list---we only want to time the reverse operation.)

    ghci> last bigList
    10000
    (0.01 secs, 882,216 bytes)

Let's try to reverse this list. How long does it take? How many bytes? Give it a try.
-}

micro3 :: Int
micro3 = last (naiveReverse bigList)

{-
    ghci> micro3

We can dress up the reverse function a bit using `foldr`, `flip` and the
singleton section `(:[])`, but that doesn't really help. It's fundamentally
the same algorithm. (I also find this 'point-free' version much harder to
understand! Try to convince yourself that this definition really is doing the
same thing as `naiveReverse`!)
-}

ivoryTowerReverse :: [a] -> [a]
ivoryTowerReverse = foldr (flip (++) . (: [])) []

{-
But, the microbenchmark shows that this version is doing about the same amount
of work. Try it out.
-}

micro4 :: Int
micro4 = last (ivoryTowerReverse bigList)

{-
    ghci> micro4

Now watch what happens when we use a `DList` instead. Compare this definition
with the `naiveReverse` one above. It's still easy to read. All we have done
is replace the standard list operations with the `DList` versions, through a fairly mechanical process.
-}

dlistReverse :: [a] -> [a]
dlistReverse = toList . rev
  where
    rev [] = empty
    rev (x : xs) = rev xs `append` singleton x

micro5 :: Int
micro5 = last (dlistReverse bigList)

{-
     ghci> micro5

We can also replace the list operations in ivoryTowerReverse with their DList
analogues, also a mechanical process.
-}

dlistIvoryTowerReverse :: [a] -> [a]
dlistIvoryTowerReverse = toList . foldr (flip append . singleton) empty

micro6 :: Int
micro6 = last (dlistIvoryTowerReverse bigList)

{-
     ghci> micro6

(Of course, it is often better to use the standard library definition of
common operations. How does the built-in operation, which has been optimized
for GHC, compare?)
-}

micro7 :: Int
micro7 = last (reverse bigList)

{-
     ghci> micro7

-}
