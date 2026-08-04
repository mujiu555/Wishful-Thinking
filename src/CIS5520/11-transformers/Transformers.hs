{-
---
fulltitle: Monad Transformers
date: November 11, 2024
---

-}

module Transformers where

import Control.Monad (ap, liftM)
import Data.Function ((&))
import Data.Kind (Type)
import State (State)
import State qualified as S

{-
How do we use *multiple* monads at once?
========================================

Sometimes, you might need to both use a state transformer and signal
errors. We've seen that individual monads can structure our code nicely,
but what if we want to do more things at once? One solution is to
build a combined monad from scratch, like we saw in the parsing lecture.

Another solution is to use the *monad transformer* library (called `mtl`)
and build the combined monad from reusable components.

We'll demonstrate how that can work today, and discuss how that library is
designed, using a running example of simple *evaluators* for
a simple programming language.

Here is our simple language: only division expressions.
-}

data Expr
  = Val Int
  | Div Expr Expr
  deriving (Show)

{-
Our first evaluator is *unsafe*. It could cause an error
when we run it.
-}

eval :: Expr -> Int
eval (Val n) = n
eval (Div x y) = eval x `div` eval y

{-
Here are two terms that we will use as running examples.
-}

ok :: Expr
ok =
  (Val 1972 `Div` Val 2)
    `Div` Val 23

err :: Expr
err =
  Val 2
    `Div` ( Val 1
              `Div` (Val 2 `Div` Val 3)
          )

{-
The first evaluates properly and returns a valid answer, while the
second fails with a divide-by-zero exception.
-}

-- >>> eval ok

-- >>> eval err

{-
This `eval` function is not very good because it can blow up with a
divide-by-zero error and stop the whole evaluator. And, there is nothing to
do about it: we can't catch the error.

Of course, one way to fix the problem is to detect the error and then
continue with a default value (such as 0).
-}

evalDefault :: Expr -> Int
evalDefault (Val n) = n
evalDefault (Div x y) =
  let m = evalDefault y
   in if m == 0 then 0 else evalDefault x `div` m

{-
But, no one likes this solution. It leads to buggy code.

Error Handling Via Exception Monads
-----------------------------------

Alternatively, we can use the `Either` type to treat the failure case more
gently: a `Left` result, carrying an error message, means that an error happened somewhere, while a
`Right n` result meant that evaluation succeeded yielding `n`.
We saw how this worked in the [`EitherMonad` exercise](08-monads/EitherMonad.hs).

Try to use the `Either` monad (with do notation) to write a better exception-
throwing evaluator, where the helper function `errorS` generates the error string.
-}

errorS :: (Show a) => a -> a -> String
errorS y m = "Error dividing " ++ show y ++ " by " ++ show m

-- | exception-throwing evaluator
evalEx :: Expr -> Either String Int
evalEx (Val n) = return n
evalEx (Div x y) = undefined

{-
When we call this evaluator, we'll format its result into a string using the
following function. For future flexibility, this function is
parameterized by a higher-order function used to display the result.
-}

showEx :: (a -> String) -> Either String a -> String
showEx _ (Left m) = "Raise: " ++ m
showEx s (Right v) = "Result: " ++ s v

{-
And this little function will call the evaluator above and then format
its result.
-}

goEx :: Expr -> String
goEx e =
  evalEx e
    & showEx show -- the `&` operator is reverse application

{-
This version should return `Result: 42` for the `ok` term and
`"Raise: Error dividing..."` for `err`.
-}

-- >>> goEx ok
-- "Result: 42"

-- >>> goEx err
-- "Raise: Error dividing Val 1 by Div (Val 2) (Val 3)"

{-
Counting Operations Using the State Monad
-----------------------------------------

Next, let's stop being paranoid about errors and instead try to do
some *profiling*. Let's imagine that the `div` operator is very
expensive, and that we would like to *count* the number of divisions
that are performed while evaluating a particular expression.

As you might imagine, our old friend the state monad is going to be
just what we need here! The type of store that we'd like to use is
just the count of number of division operations, and we can store that
in an `Int`.
-}

type Store = Int

{-
We'll need a way of incrementing the counter:
-}

tickProf :: State Store ()
tickProf = do
  x <- S.get -- use get and put from the state monad
  S.put (x + 1)

{-
Now we can write a *profiling* evaluator, and observe it at work.
-}

evalSt :: Expr -> State Store Int
evalSt (Val n) = return n
evalSt (Div x y) = do
  m <- evalSt x
  n <- evalSt y
  tickProf
  return (m `div` n)

{-
For flexibility later, we'll define a function that displays the result of
the State monad.
-}

-- | Show the result of runState, parameterized by a function
-- to show the value
showSt :: (a -> String) -> (a, Store) -> String
showSt f (v, cnt) = f v ++ ", count: " ++ show cnt

{-
And put it all together.
-}

goSt :: Expr -> String
goSt e =
  evalSt e
    & flip S.runState 0 -- The `&` operator is reverse application
    & showSt show -- It lets us create a short transformation pipeline

-- >>> goSt ok
-- "42, count: 2"

{-
But... alas!  To get the profiling, we threw out the nifty error
handling that we had put in earlier!!
-}

-- >>> goSt err
-- divide by zero

{-
Transformers: Making Monads Multitask
=====================================

So, at the moment, it seems that monads can do many things, but only *one
thing at a time* -- you can either use a monad to do the error- management
plumbing *or* to do the state-manipulation plumbing, but not both at the same
time.  Is it too much ask for both? I guess we could write a
\*mega-state-and-exception* monad that supports the operations of both, but
that doesn't sound fun!  Especially since, if we later decide to add yet
another feature, then we would have to make up yet another mega-monad.

So we will take a different approach, where we will keep *wrapping* --
or "decorating" -- monads with extra features, so that we can take a
simple monad, and then add the Exception monad's features to it, and
then add the State monad's features and so on.

The key to doing this is to define exception handling, state passing,
etc., not as monads, but rather as *type-level functions from monads
to monads.*

This will require a little more work up-front (most of which is done
already in well-designed libraries), but after that we can add new
features in a modular manner.  For example, to get a mega
state-and-exception monad, we will start with a dummy `Identity`
monad, supply it to the `StateT` monad transformer (which yields
state-passing monad) and pass the result to the `ExceptT` monad
transformer, which yields the desired mega monad.

(Incidentally, if you are a Python programmer, the above may remind
some of you of the [Decorator Design Pattern][2] and other [Python
Decorators][3].)

Step 1: *Describing* Monads With Special Features
-----------------------------------------------

The first step to being able to compose monads is to define typeclasses that
describe monads *with* particular features. For example, the notion of an
\*exception monad* is captured by the typeclass that describes monads that are
also equipped with an appropriate `throwError` function.
-}

class (Monad m) => MonadError e m where
  throwError :: e -> m a

{-
This function takes an error value of type `e` (e.g. `String` for error
messages). The result type is `m a` where `a` is polymorphic --- in
otherwords, we can throw an error in any (monadic) context.

We can make `Either s` an instance of the above class
like this:
-}

instance MonadError s (Either s) where
  throwError :: s -> Either s a
  throwError = Left

{-
Now see what happens if you change `Left` to `throwError` in the
evaluator `evalEx` above and remove the type signature.
What is the new type of the evaluator that GHC infers?

Similarly, we can bottle the key operations of a *state monad* in a typeclass
that describes monads equipped with extraction (get) and modification (put)
functions of appropriate types.
-}

class (Monad m) => MonadState s m where
  get :: m s
  put :: s -> m ()

{-
We can then redefine the ticking operation to work for any state monad:
-}

tickMonadState :: (MonadState Int m) => m ()
tickMonadState = do
  (x :: Int) <- get
  put (x + 1)

{-
Naturally, we can make our `State` monad an instance of the above:
-}

instance MonadState s (State s) where
  get :: State s s
  get = S.get

  {-
  >
  -}

  put :: s -> State s ()
  put = S.put

{-
Now go back and see what happens when you replace `tickProf` with
`tickMonadState` in `evalSt` above and remove the type signature.

Step 2: Using Monads With Special Features
------------------------------------------

Armed with these two typeclasses, we can write our exception-throwing,
step-counting evaluator quite easily:
-}

evalMega :: (MonadError String m, MonadState Int m) => Expr -> m Int
evalMega (Val n) = return n
evalMega (Div x y) = do
  n <- evalMega x
  m <- evalMega y
  if m == 0
    then throwError $ errorS n m
    else do
      tickMonadState
      return (n `div` m)

{-
Note that it is simply the combination of the two evaluators from before -- we
use the error handling from `evalEx` and the profiling from `evalSt`.

Meditate for a moment on the type of the above evaluator; note that it
works with *any monad* that is *both* a exception- and a state- monad!
(Also observe that if you remove this type annotation, GHC can infer it for you.)

Interlude: Creating MegaMonads
-----------------------------

But where do we *get* monads that are both state-manipulating and
exception-handling?

One answer is that we could just define one! Below is the start of the Mega
monad that I alluded to above: it's a bit fiddly to complete these definitions,
but you can generally use the types as your guide.

Next, finish the instances for `Monad`, `MonadError String`, and `MonadState
Int`. Make sure that `evalMega` works with your monad.
-}

newtype Mega a = Mega {runMega :: Int -> Either String (a, Int)}

instance Monad Mega where
  return :: a -> Mega a
  return x = undefined
  (>>=) :: Mega a -> (a -> Mega b) -> Mega b
  ma >>= fmb = undefined

instance Applicative Mega where
  pure = return
  (<*>) = ap

instance Functor Mega where
  fmap = liftM

instance MonadError String Mega where
  throwError :: String -> Mega a
  throwError str = undefined

instance MonadState Int Mega where
  get = undefined
  put x = undefined

{-
Finally, once we have a Mega monad, we can run it and display the result.
-}

goMega :: Expr -> String
goMega e =
  evalMega e
    & flip runMega 0 -- reverse order of arguments
    & showMega
  where
    showMega :: Either String (Int, Store) -> String
    showMega = showEx (showSt show) -- use formatting functions from above

-- >>> goMega ok
-- "Result: 42, count: 2"

-- >>> goMega err
-- "Raise: Error dividing 1 by 0"

{-
In the end, making your own mega-monad is a bit disappointing, since we've
already defined the state- and exception-handling functionality separately.

A better answer is to build this monad (and others like it) piece by piece.
We'll do this by defining some type level functions that will *add* state
manipulation or exception handling to *any* pre-existing monad.

Step 3: Adding Features to Existing Monads
------------------------------------------

To add new features to existing monads, we use *monad transformers* --
type operators `t` that map a monad `m` to a new monad `t m`.

\**A Transformer For Exceptions**

Consider the following datatype declaration:
-}

type ExceptT :: Type -> (Type -> Type) -> Type -> Type
newtype ExceptT e m a = MkExc {runExceptT :: m (Either e a)}

{-
Look closely at the kind of `ExceptT` above.

This type constructor takes a type `e` (the type of the error value, such as
`String`), then an underlying monad `m` and then an argument `a`. It is a lot
like `Either e a` except that we have added a new monad `m` in the middle.

If you look at the definition of `ExceptT` you'll see that this monad *wraps*
the `Either e a` type.

If `m` is a monad, then we can make `ExceptT` a monad. Furthermore, the
instance below looks a lot like the Monad instance for the `Either` type above. We just need
to (a) work with the newtype (using `MkExc` and `runExceptT`) and (b) use return and
`>>=` from the monad `m` to glue computations together.
-}

instance (Monad m) => Monad (ExceptT e m) where
  return :: forall a. a -> ExceptT e m a
  return x = MkExc (return (Right x) :: m (Either e a))

  (>>=) :: ExceptT e m a -> (a -> ExceptT e m b) -> ExceptT e m b
  p >>= f =
    MkExc $
      runExceptT p
        >>= ( \x -> case x of
                Left e -> return (Left e)
                Right a -> runExceptT (f a)
            )

instance (Monad m) => Applicative (ExceptT e m) where
  pure = return
  (<*>) = ap

instance (Monad m) => Functor (ExceptT e m) where
  fmap = liftM

{-
Next, we ensure that the transformer is also an exception monad by
equipping it with `throwError`.

Compare this definition to that of `MonadError e (Either e)` above.
-}

instance (Monad m) => MonadError e (ExceptT e m) where
  throwError :: e -> ExceptT e m a
  throwError msg = MkExc (return (Left msg))

{-
\**A Transformer For State**

Next, we will build a transformer for the state monad, following more or less
the same recipe as we did for exceptions. Here is the definition for the
transformer (preceded by its kind):
-}

type StateT :: Type -> (Type -> Type) -> Type -> Type
newtype StateT s m a = MkStateT {runStateT :: s -> m (a, s)}

{-
The enhanced monad is a variant of the ordinary state monad where a starting
store is mapped to a computation in the monad `m` that returns both a result
of type `a` and a new store.

(Aside: note that the monad transformer is *not* defined like this:

    newtype StateT s m a = MkStateT { runStateT :: m (s -> (a, s)) }

That is, it is not an `m` computation yielding a store transformation.
Why is this not what we want?)

Next, we declare that the transformer's output is a monad. Again, compare the
definitions below to that of the `State` monad.
-}

instance (Monad m) => Monad (StateT s m) where
  return :: a -> StateT s m a
  return x = MkStateT $ \s -> return (x, s)

  (>>=) :: StateT s m a -> (a -> StateT s m b) -> StateT s m b
  p >>= f = MkStateT $ \s -> do
    (r, s') <- runStateT p s
    runStateT (f r) s'

instance (Monad m) => Applicative (StateT s m) where
  pure = return
  (<*>) = ap

instance (Monad m) => Functor (StateT s m) where
  fmap = liftM

{-
And finally we declare that the transformer is a state monad by
equipping it with the operations from `MonadState Int`. You fill
in these definitions.
-}

instance (Monad m) => MonadState s (StateT s m) where
  get :: StateT s m s
  get = MkStateT getIt
    where
      getIt :: s -> m (s, s)
      getIt s = undefined

  put :: s -> StateT s m ()
  put s = MkStateT putIt
    where
      putIt :: s -> m ((), s)
      putIt _ = undefined

{-
Where are we now?

\* If m is a monad, then StateT s m  is a state monad  (i.e. an instance of MonadState)
\* If m is a monad, then ExceptT e m is an error monad (i.e. an instance of MonadError)

But, what about `StateT s (ExceptT e m)`?  We know it is a state monad by the
above.  But, we'd *also* like it to be an error monad.

In other words, we need the following "pass through" properties to hold:

\* If m is a *state* monad, then `ExceptT e` m is still a state monad
\* If m is an *error* monad, then `StateT Int` m is still an error monad

We can do this in a generic way.

Step 4: Preserving Old Features of Monads
------------------------------------------

Of course, we must make sure that the original features of the monads are not
lost in the transformed monads.  The key ingredient of a transformer is that
it must have a function `lift` that takes an `m` operation and turns it into a
`t m` operation. For example, the `State` monad supports `get` and `set`. We
would like to be able to lift `get` and `set` so that they work for `ExceptT e
(State s)` too.

In general, this function will allow us to transfer operations from the old
monad into the transformed monad: any operation on the input monad `m` can be
directly lifted into the transformed monad, and so the transformation
\*preserves* all the operations of the original monad.

-}

class MonadTrans (t :: (Type -> Type) -> Type -> Type) where -- from Control.Monad.Trans (among other places)
  lift :: (Monad m) => m a -> t m a

{-
It is easy to formally state that `ExceptT e` is a bona-fide transformer by
making it an instance of the `MonadTrans` class:

-}

instance MonadTrans (ExceptT e) where
  lift :: (Monad m) => m a -> ExceptT e m a
  -- Recall the type of MkExc
  -- MkExc :: m (Either e a) -> ExceptT e m a
  lift = MkExc . lift_
    where
      lift_ :: (Monad m) => m a -> m (Either e a)
      lift_ mt = Right <$> mt

{-
Similarly, for the state monad transformer:
-}

instance MonadTrans (StateT s) where
  lift :: (Monad m) => m a -> StateT s m a
  -- Recall the type of MkStateT
  -- MkStateT  :: (s -> m (a,s)) -> StateT s m a
  lift ma = MkStateT $ \s -> do
    r <- ma
    return (r, s)

{-
Using `lift`, we can ensure that, if a monad was already an
"error" monad, then the result of the state transformer is too:
-}

instance (MonadError e m) => MonadError e (StateT s m) where
  throwError :: e -> StateT s m a
  throwError = lift . throwError

{-
Similarly, if a monad was already a state-manipulating monad, then the
result of the exception-transformer is *also* a state-manipulating
monad:
-}

instance (MonadState s m) => MonadState s (ExceptT e m) where
  get :: ExceptT e m s
  get = lift get

  put :: s -> ExceptT e m ()
  put = lift . put

{-
Step 5: Whew! Put It Together and Run
-------------------------------------

Finally, we can put all the pieces together and run the transformers.
We can also *order* the transformations differently (which can have
different consequences on the output, as we will see).

Here are our two evaluators, distingiushed by the order of the transformers
that we use. Note that the code is the same in each case, but the
`MonadState` and `MonadError` constraints in `evalMega` are resolved
differently.
-}

evalExSt :: Expr -> StateT Int (Either String) Int
evalExSt = evalMega

evalStEx :: Expr -> ExceptT String (State Store) Int
evalStEx = evalMega

{-
And here are the two functions that format their results, defined with the
formatting functions from above.
-}

showExSt :: Either String (Int, Int) -> String
showExSt = showEx (showSt show)

showStEx :: (Either String Int, Int) -> String
showStEx = showSt (showEx show)

{-
We can run these interpreters and display their results as follows:
-}

goExSt :: Expr -> String
goExSt e =
  (evalExSt e :: StateT Int (Either String) Int)
    & flip runStateT 0
    & showExSt

goStEx :: Expr -> String
goStEx e =
  (evalStEx e :: ExceptT String (State Store) Int)
    & runExceptT
    & flip S.runState 0
    & showStEx

{-
When everything works, we get the same answer. But look what happens if
we try to divide by zero!
-}

-- >>> goExSt ok
-- "Result: 42, count: 2"

-- >>> goExSt err
-- "Raise: Error dividing 1 by 0"

-- >>> goStEx ok
-- "Result: 42, count: 2"

-- >>> goStEx err
-- "Raise: Error dividing 1 by 0, count: 1"

{-
Step 6: Getting the original monads back
-----------------------------------------

It seems a little silly that the monad definitions for `State` and for
`StateT` share so much code. What if we want a monad that is *only* a state
monad, and not layered on top of something else?

As alluded to above, we can define an `Identity` monad to use under
any other.
-}

newtype Id a = MkId a deriving (Show)

instance Monad Id where
  return x = undefined
  (MkId p) >>= f = undefined

instance Applicative Id where
  pure = return
  (<*>) = ap

instance Functor Id where
  fmap = liftM

type State2 s = StateT s Id -- isomorphic to State s

type Either2 s = ExceptT s Id -- isomorphic to Either s

{-
Step 7: Using the library in your code
---------------------------------------

The `mtl` library wraps contains the definitions of `StateT`, `MonadState`, `ExceptT`, `MonadError`, and the instances described above.

The file [MtlExample](MtlExample.hs) demonstrates how to use this library using the examples in this file.
-}
