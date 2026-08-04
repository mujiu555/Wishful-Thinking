{-
---
fulltitle: A Generic State Transformer
---

This file goes with [`StateMonad`](StateMonad.html).

Since state is a handy thing to have, the Haskell standard library includes a
[module][1] `Control.Monad.State` that defines a generic version of the
state-transformer that we saw in the [`StateMonad`](StateMonad.html).
This file is a simplified version of that library.

This module defines an *abstract* type, `State` that can only be used according
to its interface. Clients are prevented from knowing the implementation of
the `State` type --- this implmentation is private to this module.

To make this type abstract, the module definition includes an explicit export list.
As a result, only the types and functions listed below will be visible to clients
of the module.  Furthermore, the type `State` is exported without its data constructor
`S`. That means that clients of this module cannot use `S`, not even for pattern
matching.
-}

module State (State, get, put, modify, runState, evalState, execState) where

import Control.Monad (ap, liftM)

{-
The type definition for a generic state transformer is very simple and almost
identical to the `ST2` type from before:
-}

newtype State s a = S (s -> (a, s))

runState :: State s a -> s -> (a, s)
runState (S f) = f

{-
This type is a parameterized state-transformer monad where the state is
denoted by type `s` and the return value of the transformer is the
type `a`. We make the above a monad by declaring it to be an instance
of the `Applicative` and `Monad` typeclasses.
-}

instance Monad (State s) where
  return :: a -> State s a
  return x = S (x,) -- this tuple section (x,) is equivalent to \y -> (x,y)

  (>>=) :: State s a -> (a -> State s b) -> State s b
  st >>= f = S $ \s ->
    let (a, s') = runState st s
     in runState (f a) s'

{-
We also define instances for `Functor` and `Applicative`:
-}

instance Functor (State s) where
  fmap :: (a -> b) -> State s a -> State s b
  fmap = liftM

instance Applicative (State s) where
  pure :: a -> State s a
  pure = return
  (<*>) :: State s (a -> b) -> State s a -> State s b
  (<*>) = ap

{-
There are two other ways of evaluating the state monad. The first only
returns the final result,
-}

evalState :: State s a -> s -> a
evalState st s = fst (runState st s)

{-
and the second only returns the final state.
-}

execState :: State s a -> s -> s
execState st = snd . runState st

{-
Accessing and Modifying State
-----------------------------

Since our notion of state is generic, it is useful to write `get` and
`put` functions with which one can *access* and *modify* the state. We
can easily `get` the *current* state via

-}

get :: State s s
get = S $ \s -> (s, s)

{-
That is, `get` denotes an action that leaves the state unchanged but
returns the state itself as a value. Note that although `get` *does
not* have a function type (unless you peek under the covers of
`State`), we consider it a monadic "action".

Dually, to *update* the state to some new value `s'` we can write
the function
-}

put :: s -> State s ()
put s' = S $ const ((), s')

{-
which denotes an action that ignores (i.e., blows away) the old state
and replaces it with `s'`. Note that the `put s'` is an action that
itself yields nothing interesting (that is, merely the unit value).

For convenience, there is also the `modify` function that maps an old state to
a new state *inside* a state monad. The old state is thrown away.
-}

modify :: (s -> s) -> State s ()
modify f = S $ \s -> ((), f s)

{-
[1]: http://hackage.haskell.org/packages/archive/mtl/latest/doc/html/Control-Monad-State-Lazy.html#g:2
-}
