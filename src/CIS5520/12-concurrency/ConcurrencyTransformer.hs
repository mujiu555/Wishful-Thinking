{-# LANGUAGE FunctionalDependencies #-}
{-
---
fulltitle: "In class exercise: Concurrency Monad Transformer"
date: November 20, 2024
---
-}
{-# LANGUAGE UndecidableInstances #-}

module ConcurrencyTransformer where

import Control.Monad (ap, liftM, (>=>))
import Control.Monad.State qualified as S
import Control.Monad.State.Class
import Control.Monad.Trans (MonadTrans (..))
{-
This exercise depends on the `Sequence` datatype from Haskell's containers
library.  This data structure implements efficient sequential data, with
logorithmic indexing and append operations and constant time access to the
head and tail of the data structure.
-}

import Data.Foldable (toList)
import Data.Function ((&))
import Data.IORef qualified as IO
import Data.Map qualified as Map
import Data.Sequence (Seq)
import Data.Sequence qualified as Seq
import System.IO qualified as IO
{-
Note, today is all about testing.
-}

import Test.HUnit (Test, runTestTT, (~?=))

{-
Testing IO interactions
-----------------------
-}

-- a)

{-
The Input and Output classes from the [Concurrency](../../soln/12-concurrency/Concurrency.html) lecture
are useful not just for implementing concurrent programs, but they are also a
way that we can test monadic computations that do console I/O.

Here are the definitions that we saw before, describing monads that support
non-blocking I/O.
-}

class (Monad m) => Output m where
  output :: String -> m ()

class (Monad m) => Input m where
  input :: m (Maybe String) -- only return input if it is ready

{-
Here is the definition of these operations for the IO monad.
-}

instance Output IO where
  output :: String -> IO ()
  output = putStr

instance Input IO where
  input :: IO (Maybe String)
  input = do
    x <- IO.hReady IO.stdin
    if x then Just <$> getLine else return Nothing

{-
And here is a simple program that does some reading and writing in an arbitrary monad.
-}

-- | Wait for some input to appear, and when it does, repeat it.
echo :: (Input m, Output m) => m ()
echo = do
  ms <- input
  case ms of
    Just str -> output str >> output "\n"
    Nothing -> echo

{-
If I run this program in ghci using the `IO` monad by default, I can see that
it just spits out whatever I type in. (Remember, you can start ghci in the Terminal
using `stack ghci ConcurrencyTransformer.hs`. You will also need to reload this file
into ghci, using `:r`, every time that you modify it.)

            ghci> echo
            Hello        <---- I typed this
            Hello        <---- GHCi printed this

Try it out yourself!

But how can we make a unit test for this (simple) program?

The answer is that we will *mock* the IO monad using a different (pure) monad. This
monad will use a data structure to represent input and output events, and we can
look at that data structure in our tests.

Here's a way to do this. We define a datatype of the IO operations that
record a *trace* of the execution.
-}

data TraceIO a
  = Done a
  | Output String (TraceIO a)
  | Input (Maybe String -> TraceIO a)

{-
For example, the trace of the echo program above looks like this:
-}

echoTrace :: TraceIO ()
echoTrace =
  Input
    ( \ms -> case ms of
        Just str -> Output str (Output "\n" (Done ()))
        Nothing -> echoTrace
    )

{-
A test case can the "run" the trace, with a specific list of inputs to
mock what happens during an execution.
-}

runTraceIO :: TraceIO () -> [Maybe String] -> [String]
runTraceIO = go
  where
    go (Done _) _inputs = []
    go (Output s dio) inputs = s : go dio inputs
    go (Input f) (x : xs) = go (f x) xs
    go (Input f) [] = go (f Nothing) []

-- >>> runTraceIO echoTrace [Nothing, Nothing, Just "hello"]
-- ["hello","\n"]

-- >>> runTraceIO echoTrace [Just "x", Nothing, Nothing, Just "y"]
-- ["x","\n"]

{-
However, for a given program like `echo`, we don't want to have
to construct its trace by hand. We'd like to test the original program.
Fortunately, `echo` is generic over the Monad that we use for execution.
So by making the `TraceIO` type an instance of the `Monad` type class,
we can extract the `echoTrace` definition directly from the `echo` program
itself.
-}

instance Monad TraceIO where
  return :: a -> TraceIO a
  return = Done
  (>>=) :: TraceIO a -> (a -> TraceIO b) -> TraceIO b
  (>>=) = undefined

{-
(As usual, the Applicative and Functor instances can be derived from the
Monad instance.)
-}

instance Applicative TraceIO where
  pure :: a -> TraceIO a
  pure = return
  (<*>) :: TraceIO (a -> b) -> TraceIO a -> TraceIO b
  (<*>) = ap

instance Functor TraceIO where
  fmap :: (a -> b) -> TraceIO a -> TraceIO b
  fmap = liftM

{-
Furthemore, to test the `echo` example, we need instances of the `Input` and `Ouput` classes. These instances use
the data constructors to record the interactions.
-}

instance Output TraceIO where
  output :: String -> TraceIO ()
  output s = Output s (return ())

instance Input TraceIO where
  input :: TraceIO (Maybe String)
  input = Input return

{-
With these instances, we can call `runTraceIO` with the original `echo` program.
The nice thing about this approach is that our tests are pure code.
-}

-- >>> runTraceIO echo [Nothing, Nothing, Just "hello"]
-- ["hello","\n"]

-- >>> runTraceIO echo [Just "x", Nothing, Nothing, Just "y"]
-- ["x","\n"]

{-
Not only can you test them inline, but you can also make them into
unit tests.
-}

testTraceEcho :: Test
testTraceEcho =
  runTraceIO echo [Nothing, Nothing, Just "hello"]
    ~?= ["hello", "\n"]

-- >>> runTestTT testTraceEcho
-- Counts {cases = 1, tried = 1, errors = 0, failures = 0}

testTraceEcho2 :: Test
testTraceEcho2 =
  runTraceIO
    (echo >> echo)
    [Just "hello", Nothing, Just "CIS 5520"]
    ~?= ["hello", "\n", "CIS 5520", "\n"]

-- >>> runTestTT testTraceEcho2
-- Counts {cases = 1, tried = 1, errors = 0, failures = 0}

{-
Now create a test of your own, for a simple IO progam of your own devising.
-}

test3 :: Test
test3 = runTraceIO undefined undefined ~?= undefined

-- >>> runTestTT test3

{-
A generic concurrency monad
---------------------------
-}

-- b)

{-
The Concurrency monad that we presented in class was specialized to atomic
actions in the IO monad. But now that we have a mocked version of the IO
monad, we should be more general. Compare this definition of `Action` to the
one from before; this one is *parameterized* by a monad in which the atomic
actions are run.
-}

data Action m
  = Atomic (m (Action m)) -- an atomic computation, returning a new action
  | Fork (Action m) (Action m) -- create a new thread
  | Stop -- terminate this thread

{-
We add this new `m` as an additional argument to `C`.
-}

newtype C m a = MkC {runC :: (a -> Action m) -> Action m}

{-
Now, make this new type a monad:
-}

instance (Monad m) => Monad (C m) where
  return :: a -> C m a
  return x = undefined
  (>>=) :: (Monad m) => C m a -> (a -> C m b) -> C m b
  m >>= f = undefined

instance (Monad m) => Applicative (C m) where
  pure :: (Monad m) => a -> C m a
  pure = return
  (<*>) :: (Monad m) => C m (a -> b) -> C m a -> C m b
  (<*>) = ap

instance (Monad m) => Functor (C m) where
  fmap :: (Monad m) => (a -> b) -> C m a -> C m b
  fmap = liftM

{-
Next, to make sure you follow how these generalizations work, add the type
signatures for our library of concurrency operations. Of course, vscode will
just add them with a click, but make sure that you understand why these operations
have the types that they do.
-}

atomic m = MkC (\k -> Atomic (fmap k m))

run m = sched [runC m $ const Stop]

fork m = MkC (\k -> Fork (runC m $ const Stop) (k ()))

sched [] = return ()
sched (Atomic m : cs) = m >>= \a -> sched (cs ++ [a])
sched (Fork a1 a2 : cs) = sched (cs ++ [a1, a2])
sched (Stop : cs) = sched cs

{-
Testing concurrent IO
---------------------
-}

-- c)

{-
Next, show how to implement input and output for
this new parameterized concurrency monad.
-}

instance (Input m) => Input (C m) where
  input :: (Input m) => C m (Maybe String)
  input = undefined

instance (Output m) => Output (C m) where
  output :: (Output m) => String -> C m ()
  output = undefined

{-
Let's define and test a *concurrent* program that does IO.

For example, given an output function:
-}

example :: (Output m) => C m ()
example = do
  fork (output "Hello " >> output "5520")
  output "CIS"

{-
We can run it in the IO monad

          ghci>  run (example :: C IO ())
          Hello CIS5520

Or run it in the *Concurrent* FakeIO monad. (We derive the concurrent fake IO monad by transforming the `FakeIO` monad above.)
-}

runCTraceIO :: C TraceIO () -> [Maybe String] -> [String]
runCTraceIO x inputs = undefined

testWrite :: Test
testWrite = runCTraceIO example [] ~?= ["Hello ", "CIS", "5520"]

-- >>> runCTraceIO example []
-- ["Hello ","CIS","5520"]

-- >>> runTestTT testWrite
-- Counts {cases = 1, tried = 1, errors = 0, failures = 0}

{-
Write your own example of a (terminating) concurrent program, and a test
demonstrating what it does.
-}

example2 :: (Input m, Output m) => C m ()
example2 = undefined

testExample2 :: Test
testExample2 = undefined

-- >>> runTestTT testExample2

{-
More generally, note that `C` is a *monad transformer*. We can make the
concurrency monad an instance of the monad transformers class, which will
allow it to work gracefully with other monad transformers.
-}

instance MonadTrans C where
  lift :: (Monad m) => m a -> C m a
  lift = atomic

{-
Testing concurrent message passing
----------------------------------
-}

-- d)

{-
Recall the final example in the Concurrency lecture, which demonstrated
message passing between concurrent threads.

This example relies on the following interface, for monads that
support message passing through shared mailboxes.
-}

class (Monad m) => MsgMonad b m | m -> b where
  newMailbox :: m b
  sendMsg :: b -> Msg -> m ()
  checkMsg :: b -> m (Maybe Msg)

data Msg
  = Add
  | Reset
  | Print
  | Quit

{-
And defines the following simulation and interface code that runs in parallel.
-}

simulation :: (Output m, MsgMonad k m) => k -> Integer -> m ()
simulation mv i = loop i
  where
    loop i = do
      x <- checkMsg mv
      case x of
        Just Add -> output "Adding...\n" >> loop (i + 1)
        Just Reset -> output "Resetting...\n" >> loop 0
        Just Print -> output ("Current value is " ++ show i ++ "\n") >> loop i
        Just Quit -> output "Done\n"
        Nothing -> loop i

interface :: (MsgMonad k m, Input m, Output m) => k -> m ()
interface mv = loop
  where
    loop = do
      maybeKey <- input
      case maybeKey of
        Just "a" -> sendMsg mv Add >> loop
        Just "r" -> sendMsg mv Reset >> loop
        Just "p" -> sendMsg mv Print >> loop
        Just "q" -> sendMsg mv Quit
        Just s -> output ("Unknown command: " ++ s ++ "\n") >> loop
        Nothing -> loop

{-
We can give the same example code below our more general continutation
monad type.
-}

example6 :: (Input m, Output m, MsgMonad k m) => C m ()
example6 = do
  mv <- newMailbox
  fork $ simulation mv 0
  interface mv

{-
We can send messages via `IORefs` as in the Concurrency lecture.
-}

type Mailbox = IO.IORef (Maybe Msg)

instance MsgMonad Mailbox IO where
  newMailbox :: IO Mailbox
  newMailbox = IO.newIORef Nothing
  sendMsg :: Mailbox -> Msg -> IO ()
  sendMsg v a = IO.writeIORef v (Just a)
  checkMsg :: Mailbox -> IO (Maybe Msg)
  checkMsg v = do
    x <- IO.readIORef v
    case x of
      Just y -> IO.writeIORef v Nothing >> return (Just y)
      Nothing -> return Nothing

{-
And then lift the message passing to the concurrency monad, using the `lift` operation (aka atomic).
-}

instance (MsgMonad k m) => MsgMonad k (C m) where
  newMailbox :: (MsgMonad k m) => C m k
  newMailbox = lift newMailbox

  sendMsg :: (MsgMonad k m) => k -> Msg -> C m ()
  sendMsg k m = lift (sendMsg k m)

  checkMsg :: (MsgMonad k m) => k -> C m (Maybe Msg)
  checkMsg k = lift (checkMsg k)

-- run in the Concurrent IO monad, but only in a program or in ghci
--   ghci> run example6

{-
Your job for this part is to replace the `IO` monad with the state monad
and the `traceIO` monad above. Ultimately, instead of `C IO`
you'll use the monad

      C (S.StateT Store TraceIO)

where the store keeps track of the mailboxes that have been allocated and
their current contents.

For example, once you complete this section, you should be able to
pass run the following example:
-}

-- run example in the Concurrent State/TraceIO monad
-- >>> runCState example6 [Just "a", Nothing, Just "a", Just "p",Nothing, Just "r", Just "p", Just "q", Nothing, Just "x" ]
-- ["Adding...\n","Adding...\n","Current value is 2\n","Resetting...\n","Current value is 0\n","Done\n"]

runCState :: C (S.StateT Store TraceIO) () -> [Maybe String] -> [String]
runCState x inputs =
  x
    & run
    & flip S.evalStateT Map.empty
    & flip runTraceIO inputs

testCState :: Test
testCState =
  runCState
    example6
    [ Just "a",
      Nothing,
      Nothing,
      Just "a",
      Just "p",
      Just "r",
      Just "p",
      Just "q",
      Just "x"
    ]
    ~?= [ "Adding...\n",
          "Adding...\n",
          "Current value is 2\n",
          "Resetting...\n",
          "Current value is 0\n",
          "Done\n"
        ]

{-
Or as a test case:
-}

-- >>> runTestTT testCState
-- Counts {cases = 1, tried = 1, errors = 0, failures = 0}

{-
Making this work requires two steps. First, we need to make sure that
we can do Input/Output in the StateT transformer monad.

-}

instance (Output m) => Output (S.StateT s m) where
  output :: (Output m) => String -> S.StateT s m ()
  output str = lift (output str)

instance (Input m) => Input (S.StateT s m) where
  input :: (Input m) => S.StateT s m (Maybe String)
  input = lift input

{-
Second, we need to define the `Store` type and show how to use it to
define message passing. In this case, our store will be a mapping from
mailbox number (i.e. an integer) to mailbox contents.
-}

type Store = Map.Map Int (Maybe Msg)

{-
So the mailbox type will just be `Int` in this case. Creating a new mailbox
means finding an `Int` that is not already in the keys of the store, and
adding a new mapping from that `Int` to `Nothing`. Sending a message is
updating the store with a mapping at the given key to `Just` the message.
Finally, checking for a message requires looking up the key in the store and
returning any messages. Furthermore, as in the `IO` example above, we should
\*remove* the message from the mailbox, so that the next time the mailbox is
checked there won't be any messages available.
-}

instance (Monad m) => MsgMonad Int (S.StateT Store m) where
  newMailbox :: S.StateT Store m Int
  newMailbox = undefined
  sendMsg :: Int -> Msg -> S.StateT Store m ()
  sendMsg k msg = undefined
  checkMsg :: Int -> S.StateT Store m (Maybe Msg)
  checkMsg k = undefined

{-

-}
