{-
---
fulltitle: The State Monad!
date: October 28, 2024
---

Set-up
------

In this lecture, we'll continue our study of monads via examples of *specific*
monads to try to understand how they work. Today we will look at a monadic interface
to State transformers -- a way to model imperative algorithms using purely functional
code. While this approach is not the most *efficient* way to implement mutable
algorithms in Haskell (you can just use the `IO` for that) it does
provide a *model* of how to think about imperative code in a mathematical
setting. But it is not a bad implementation, and it comes with benefits
over IO, so you'll see it often used in practice.

Also, don't be concerned if this module is hard to follow the first time through.
At this point in the semester, a lot of ideas are coming together all at once.
Give yourself enough time and space to work through this module properly --- we'll
be building off this module in many ways the rest of the semester.

-}

module StateMonad where

import Control.Monad (ap, liftM)
import Data.IORef qualified as IO
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Maybe qualified as Maybe
{-
This module depends on an auxiliary module [State](State.html) that we will define later.
We'll qualify imports from this module with `S.` so that you can see where they
come from.
-}

import State qualified as S

{-
State Transformations
---------------------

Now let us consider the problem of writing functions that manipulate
some kind of mutable data. We're going to start with some examples of state
manipulation, written in an awkward style, and then show how monads
can cleanly abstract the sequencing necessary for such programs.

By way of an example, let's go back to binary trees whose *leaves* contains
values of some type `a`:
-}

data Tree a = Leaf a | Branch (Tree a) (Tree a)
  deriving (Eq, Show)

{-
Here is a simple example:
-}

tree :: Tree Char
tree = Branch (Branch (Leaf 'a') (Leaf 'b')) (Leaf 'c')

{-
A functional programmer would count the number of leaves in a tree
like so:
-}

countF :: Tree a -> Int
countF t = case t of
  (Leaf _) -> 1
  (Branch t1 t2) -> countF t1 + countF t2

{-
(Or, they might just use the `length` operation from the `Foldable` type class!)

On the other hand, consider how a C programmer would count the number of
leaves in a tree. They might create a local (mutable) variable and then then
walk the tree, incrementing that variable at each leaf.

In Haskell, we could write such code in the `IO` monad using `IORef`s. The
operation `newIORef` creates a new mutable variable, which can be read
(`readIORef`) and written (`writeIORef`) and updated (`modifyIORef`). If you
are familiar with OCaml, `IORef`s are like the `ref` type in that language.
These mutable references are available in the [Data.IORef](https://hackage.haskell.org/package/base-4.19.0.0/docs/Data-IORef.html)
module.
-}

countIO :: Tree a -> IO Int
countIO t = do
  -- create a mutable variable, initialize to 0
  count <- IO.newIORef 0
  -- function to visit every node in the tree
  let aux :: Tree a -> IO ()
      aux t = case t of
        (Leaf _) ->
          -- increment count variable (i.e. count++)
          IO.modifyIORef count (+ 1)
        (Branch t1 t2) -> do
          aux t1
          aux t2
  -- call function on tree
  aux t
  -- return the total count
  IO.readIORef count

-- >>> countIO tree

{-
I haven't shown you `IORef`s before because I've wanted you to become
comfortable with functional programming. I don't want you to reach for mutable
variables as your first attempt to solve a problem.

In pure code, we *cannot* modify the values of any variables. However, we can
emulate this pattern with a *state transformer* -- a function that takes an
initial state (i.e. the initial value stored in the variable) as an input and
returns the new state at every step.

In this example, the state is an `Int` (representing the current count) and
a state transformer is a function of type `Int -> Int`. These two types get
confusing so in this module, we call the first type `Store`  (for the type
of the stored values) and variations of the second type
`ST` or `State` (for state/store transformer, see below).
-}

-- | The number of leaves in the tree that we have currently counted
type Store = Int

countI :: Tree a -> Int
countI t = aux t 0 -- start with 0
  where
    aux :: Tree a -> (Store -> Store)
    aux (Leaf _) = (+ 1) -- we found a leaf
    aux (Branch t1 t2) = \s ->
      let s' = aux t1 s -- pass through in
          s'' = aux t2 s' -- each recursive call
       in s''

{-
Once you understand the implementation above, test it on the sample tree
above.
-}

-- >>> countI tree

{-
At this point, you might be wondering what the point of this all is.
Certainly the `countF` or `length` implmentation is much nicer. However, in
the next example, we'll add another twist, which is slightly more difficult.

Now consider the problem of defining a function that labels each leaf with
its `count` or position in the iteration.
-}

labelIO :: Tree a -> IO (Tree (a, Int))
labelIO t = do
  -- create a mutable variable, initialize to 0
  count <- IO.newIORef 0
  -- visit every node in the tree, modifying the variable
  let aux (Leaf x) = do
        -- access count before modification
        c <- IO.readIORef count
        IO.modifyIORef count (+ 1)
        return (Leaf (x, c))
      aux (Branch t1 t2) = do
        t1' <- aux t1
        t2' <- aux t2
        return (Branch t1' t2')
  -- traverse and return the tree
  aux t

-- >>> labelIO tree

{-
We can also implement this operation with purely functional code by taking
the state transformer code above, which always has access to the current
count as we traverse the tree, and making it return a new tree in the
process. See if you can figure out how to do this.
-}

label1 :: Tree a -> Tree (a, Int)
label1 t = fst (aux t 0)
  where
    aux :: Tree a -> Store -> (Tree (a, Int), Store)
    aux = undefined

{-
Once you have completed the implementation, again test it on the sample tree
above.
-}

-- >>> label1 tree

{-
Your result should be:

        Branch (Branch (Leaf ('a',0)) (Leaf ('b',1))) (Leaf ('c',2))
-}

--     SPOILER SPACE BELOW
--
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |
--      |

{-
Here's my version:
-}

label1' :: Tree a -> Tree (a, Int)
label1' t = fst (aux t 0)
  where
    aux :: Tree a -> Store -> (Tree (a, Int), Store)
    aux (Leaf x) = \s -> (Leaf (x, s), s + 1)
    aux (Branch t1 t2) = \s ->
      let (t1', s') = aux t1 s
          (t2', s'') = aux t2 s'
       in (Branch t1' t2', s'')

{-
In general, a state transformer takes a current store as its argument, and
produces a modified store as its result, where the modified store reflects any
side effects performed by the function.

This example demonstrates that in general, we may wish to return a
result value in addition to updating the store. For this reason, we
generalize our type of store transformers to also return a result
value, with the type of such values being a parameter of the `ST`
type:

-}

type ST a = Store -> (a, Store)

{-
The reason we are talking about state transformers is that this
parameterized type `ST` is a *monad*.

What are its definitions of `return` and `bind`? If you
get stuck, I've expanded the definition of `ST a` in the commented version
of the types below.
-}

returnST :: a -> ST a
-- returnST :: a -> Store -> (a, Store)
returnST = undefined

bindST :: ST a -> (a -> ST b) -> ST b
-- bindST :: (Store -> (a,Store)) -> (a -> (Store -> (b, Store))) -> (Store -> (b, Store))
bindST st f = undefined

{-
That is, `returnST` converts a value into a state transformer by simply
returning that value without modifying the state.

In turn, `bindST` provides a means of sequencing state transformers: `bindST
st f` applies the state transformer `st` to an initial state `s`, then applies
the function `f` to the resulting value `x` to give a second state transformer
`(f x)`, which is then applied to the modified store `s'` to give the final
result. It is similar to function composition, except that we need to pass two
results to the second argument.

Now, see if you can rewrite this slight modification to `label1` above. (We
have changed the type annotation for `aux` and moved the `s` argument to the
RHS.) Try to replace the RHS of `aux (Branch t1 t2)` with applications of
`bindST` and `returnST`.  (Don't try to do the same with the `Leaf`, we'll
need something else for this case.)
-}

label2 :: Tree a -> Tree (a, Int)
label2 t = fst (aux t 0)
  where
    aux :: Tree a -> ST (Tree (a, Int))
    aux (Leaf x) = \s -> (Leaf (x, s), s + 1)
    aux (Branch t1 t2) = \s ->
      let (t1', s') = aux t1 s
          (t2', s'') = aux t2 s'
       in (Branch t1' t2', s'')

{-
Because the `ST` parameterized type has definitions for return and bind, we should
be able to make it an instance of the Monad type class. And we can do so!
However, in the process we must address two technicalities.

1. We would like to just say:

~~~~~{.haskell}
type ST a = Store -> (a, Store)

instance Monad ST where
   -- return :: a -> ST a
   return    = returnST

   -- (>>=)  :: ST a -> (a -> ST b) -> ST b
   st >>= f  = bindST st f
~~~~~

   However, in Haskell, types defined using the `type` mechanism cannot be
   made into instances of classes.  Therefore, in order to make ST into an
   instance of the Monad class, in reality it needs to be redefined
   using the "data" (or `newtype`) mechanism, which requires introducing a
   dummy constructor that we'll call `S` for brevity.

   It is also convenient to define `runState` that lets us
   access the state transformer from this newtype.
-}

newtype ST2 a = S (Store -> (a, Store))

runState :: ST2 a -> (Store -> (a, Store))
runState (S f) = f

{-
~~~~~~~~~~~~~~~{.haskell}
ghci> :type S
S     :: (Store -> (a,Store)) -> ST2 a
~~~~~~~~~~~~~~~

   `ST2` can now be defined as a monadic type (i.e. an instance of the `Monad`
     class) as follows:
-}

instance Monad ST2 where
  return :: a -> ST2 a
  return x = S (x,) -- this tuple section (x,) is equivalent to \y -> (x,y)

  (>>=) :: ST2 a -> (a -> ST2 b) -> ST2 b
  f >>= g = S $ \s ->
    let (a, s') = runState f s
     in runState (g a) s'

{-
2. All monads in Haskell must also be applicative functors. So along with our
   instance of the `Monad` class, we also need to define instances for `Functor`
   and `Applicative`. However, once we have identifed the monadic operations,
   we can declare these instances easily using the library functions `ap` and
`  liftM` which are defined in `Control.Monad.`
-}

instance Functor ST2 where
  fmap :: (a -> b) -> ST2 a -> ST2 b
  fmap = liftM

instance Applicative ST2 where
  pure :: a -> ST2 a
  pure = return

  (<*>) :: ST2 (a -> b) -> ST2 a -> ST2 b
  (<*>) = ap

{-
Now, let's rewrite the tree labeling function with the `ST2`
monad. Looking at the `labelIO` version for inspiration, we need
two new functions: an analogue to `getIORef` and an analogue to
`putIORef`.
-}

getST2 :: ST2 Store
getST2 = S $ \s -> (s, s)

putST2 :: Store -> ST2 ()
putST2 s = S $ \_ -> ((), s)

{-
These functions are additional useful operations for the `ST2` type. (The fact
that `ST2` is a monad is not the *only* important property of this type.)

Using these two definitions, together with the `Monad` operations, it is now
straightforward to define our tree labeling function.
-}

mlabel :: Tree a -> ST2 (Tree (a, Int))
mlabel (Leaf x) = undefined -- use `getST2` and `putST2` here
mlabel (Branch t1 t2) = undefined

{-
Try to implement `mlabel` both with and without `do`-notation.

The advantage of the monadic interface is that
programmers do not have to deal with the plumbing of labels, a tedious and
error-prone task, as this is handled automatically by the monad.

Finally, we can now define a function that labels a tree by
simply applying the resulting state transformer with zero as
the initial state, and then discarding the final state:
-}

label :: Tree a -> Tree (a, Int)
label t = undefined

{-
For example, `label tree` gives our expected result:
-}

-- >>> label tree

{-
A Generic State Transformer
===========================

Often, the *store* that we want to have will have multiple components
-- e.g., multiple variables whose values we might want to update. This
is easily accomplished by using a different type for `Store` above,
for example, if we want two integers, we might use the definition

~~~~~{.haskell}
type Store = (Int, Int)
~~~~~

and so on.

Therefore, we would like to write reusable code that will work with
\*any* type of store.

The file [State](State.html) contains a generic library for that purpose.
You should switch to that file now and read it before moving on.
The code below will *use* those definitions. (Recall that all definitions
from this library will be qualified by `S.`)

Using a Generic state transformer
=================================

Let's use our generic state monad to rewrite the tree labeling function
from above. Note that the actual type definition of the generic transformer
type (`S.State`) is *hidden* from us, so we must use only the publicly
exported functions, including `S.get` and `S.modify` and the `Monad` type class
operations.

Now, the labeling function with our generic `State` monad is straightforward.
-}

mlabelS :: Tree t -> S.State Int (Tree (t, Int))
mlabelS t = case t of
  (Leaf x) -> do
    c <- S.get
    S.modify (+ 1)
    return (Leaf (x, c))
  (Branch t1 t2) -> do
    t1' <- mlabelS t1
    t2' <- mlabelS t2
    return (Branch t1' t2')

{-
Easy enough!

-}

-- >>> S.runState (mlabelS tree) 0

{-
We can run the action from any initial state of our choice

-}

-- >>> S.runState (mlabelS tree) 1000

{-
Now, what's the point of a generic state transformer if we can't have richer
states? Next, let us extend our `label` functions so that

- each node gets its label (as before), and

- the state also contains a map of the *frequency* with which each
  leaf value appears in the tree.

Thus, our state will now have two elements, an integer denoting the *next*
fresh integer, and a `Map a Int` denoting the number of times each leaf
value appears in the tree. (Documentation for the [Data.Map module](http://www.haskell.org/ghc/docs/latest/html/libraries/containers/Data-Map.html). )
-}

-- | A store that contains the next label and the frequency that
-- a particular value appears in the tree
data MySt a = M
  { index :: Int,
    freq :: Map a Int
  }
  deriving (Eq, Show)

{-
We can write an action that returns the current index (and increments it).
-}

updateIndexM :: S.State (MySt a) Int
updateIndexM = do
  m <- S.get
  let i = index m
  S.put (m {index = i + 1}) -- create a new record like m, but index as given
  return i

{-
Similarly, we want an action that updates the frequency of a given
element `k`.
-}

updFreqM :: (Ord a) => a -> S.State (MySt a) ()
updFreqM = undefined

{-
And with these two, we are done
-}

mlabelM :: (Ord a) => Tree a -> S.State (MySt a) (Tree (a, Int))
mlabelM (Leaf x) = do
  c <- updateIndexM
  updFreqM x
  return (Leaf (x, c))
mlabelM (Branch t1 t2) = do
  t1' <- mlabelM t1
  t2' <- mlabelM t2
  return (Branch t1' t2')

{-
Now, our *initial* state will be something like
-}

initM :: MySt a
initM = M 0 Map.empty

{-
and so we can label the tree
-}

tree2 :: Tree Char
tree2 = Branch tree tree

lt :: Tree (Char, Int)
s :: MySt Char
(lt, s) = S.runState (mlabelM tree2) initM

-- >>> lt

-- >>> s

{-
Credit
------

The first part of the lecture is a revised version of the lecture notes by
[Graham Hutton][0], January 2011

[0]: http://www.cs.nott.ac.uk/~gmh/monads, now revised as http://www.cs.nott.ac.uk/~pszgmh/pih.html
-}
