{-
---
fulltitle: A Poor Man's Concurrency Monad
date: November 18, 2024
---

NOTE: We will work through the `undefined` parts of this lecture together in
class. To prepare, please checkout the github repo and make sure that you
can load the file in the terminal. (A lot of the examples in this file use I/O
so inline doctests won't work.)

           stack ghci Concurrency.hs

To use this module, you will also need the the [Client](Client.html) module.
-}
{-# LANGUAGE FunctionalDependencies #-}

module Concurrency where

import Control.Monad (ap, liftM)
import Data.IORef qualified as IO
import Network.Socket qualified as Socket -- from the `network` library
import System.IO qualified as IO

{-
In this lecture, we'll combine a number of ideas from recent lectures (monads
and monad transformers) to build a simple monad for concurrent computation.

The basis for this lecture is the following paper:

    Koen Claessen, A Poor Man's Concurrency Monad, JFP 1999.

The specific form of concurrency that we'll be working with is called
_cooperative multithreading_.  The "cooperative" part means that the
thread that has the processor at the moment will continue running
until it voluntarily yields control back to the scheduler and allows
another thread to run.

Haskell also provides sophisticated built-in facilities for preemptive
concurrency (where the scheduler interrupts threads after they've been
running for a certain length of time) as well as various mechanisms
for expressing parallel algorithms that share work across the
processing units of a multicore machine.  Here's where today's lecture
(marked in **bold**) fits in this picture:

  - Deterministic computation               (one thread of control, one output)
  - Nondeterministic computation            (many possible outputs)
      - Single-threaded                     (one thread with many possible outputs)
      - Concurrent                          (many threads...)
          - Uniprocessor                    (... on one CPU)
              - **Cooperative scheduling**  (threads decide when to yield control)
              - Preemptive scheduling       (scheduler decides)
          - Parallelism                     (... on many CPUs)

There are several reasons why a cooperative multithreading monad is
interesting.

- First, it is interesting to see how easy it is to implement
concurrency as a user-level library in a single-threaded language.
This idea has been applied many times to build "lightweight
concurrency" libraries in a variety of languages.

- Second, cooperative multithreading (compared to preemptive
concurrency and parallel programming) greatly simplifies issues of
locking and atomicity, since each thread can be interrupted *only* at
specific points (that it gets to control).

- Finally, since this library is all user-level code, it gives us easy
access to internals such as the thread-scheduling algorithm. If we
have an application that requires specific control over how thread
scheduling works, there is no need to change the Haskell run-time
system: we can just change a few lines of code in the library.

Representing Concurrent Computation
-----------------------------------

The standard technique for running multiple threads on a single core
is *interleaving*, i.e. running a bit of one thread, then suspending
it and allowing another thread to run, etc.

To suspend a thread we need access to its "future computation" --
i.e., its *continutation* -- so that we can return to it later.  By
programming in continuation-passing style (CPS), we can ensure that all
computations have access to their continuations.

Moreover, we can make programming in CPS more convenient by packaging
the continuation in a monad.  A computation in the concurrency monad
is a function whose first argument is its continuation, i.e., a
function that the computation should call when it wants to "return"
its value.

We're going to divide up computations into slices called *actions*.
All computations in this monad should be `Action`s, and their
continuations should likewise produce new `Action`s.  An action can be
an atomic action, a `Fork`, which splits the current thread into two new
threads, or a `Stop` action that halts the thread.
-}

data Action
  = Atomic (IO Action) -- an atomic computation, returning a new action
  | Fork Action Action -- create a new thread
  | Stop -- terminate this thread

{-
Let's look at some example actions.  For example, this one writes out a
single string in one go.
-}

atomicWrite :: String -> Action
atomicWrite s = Atomic (putStr s >> return Stop)

{-
And this one writes out a string letter by letter.
-}

writeAction :: String -> Action
writeAction "" = Stop
writeAction (c : cs) = Atomic $ do
  putChar c
  return $ writeAction cs

{-
How do we run these programs?

Running Threads
===============

At any moment, the status of the computation is modeled by a
collection of (concurrently running) threads. Each thread is
represented by its current `Action`.

For simplicity, we'll represent the collection of threads as a list
and, for round-robin scheduling, treat that list as a queue.  (In a
production system we would use a more efficient queue implementation.)

The job of the thread scheduler is to run the threads in the queue.

   * If the first thread is an atomic action, the scheduler runs it to
     its next "quiescent state." It then puts this the new state at the
     back of the queue and continues to process the rest of the queue.

   * If the action is a `Fork`, the thread scheduler puts both
     sub-actions at the back of the queue and continues.

   * If the action is `Stop`, that means that the current thread has
     finished its computation. The thread scheduler just continues with the
     rest of the threads in the queue.
-}

sched :: [Action] -> IO ()
sched [] = return ()
sched (Atomic io : cs) = do
  a <- io
  sched (cs ++ [a])
sched (Fork a1 a2 : cs) = sched (cs ++ [a2, a1])
sched (Stop : cs) = sched cs

{-
To make sure that we get the full effect of concurrency, we'll
first turn off buffering on the standard input and output sources.
-}

--    ghci> import System.IO
--    ghci> hSetBuffering stdout NoBuffering
--    ghci> hSetBuffering stdout NoBuffering

{-
Then we can use the schedular to run the program:
-}

--    ghci> sched [ Fork (atomicWrite "Hello\n") (atomicWrite "CIS 5520\n") ]

--    ghci> sched [ Fork (writeAction "Hello\n") (writeAction "CIS 5520\n") ]

{-
Writing Programs, compositionally
=================================

Suppose you wanted to write a program that does the following: writes "Hello"
and *then* writes "CIS 5520". We would love to have some sort of sequence
operation, that would run one action after another, thus:
-}

sequenceAction :: Action -> Action -> Action
sequenceAction a1 a2 = error "Hypothetical. Don't try to write me."

hello5520 :: Action
hello5520 = writeAction "Hello" `sequenceAction` writeAction "CIS 5520"

{-
Unfortunately, there isn't a good way to do this with our current set-up.
Actions run piece-by-piece until they stop. There is no way to stitch the
pieces together.

We'll fix this by factoring out the "last step".  Above, the definition of
`writeAction` fixes the last action to be `Stop`. We'll make that last action
a parameter to the system, called `k`. Note that we if are asked to write
an empty string, then there is nothing to do. So we just return the action that
is passed in.

In the case that the string is nonnil, the function should atomically write a
single character then calls itself recursively on the tail of the string
passing the "last action" along.
-}

writeComputation :: String -> Action -> Action
writeComputation "" k = k
writeComputation (c : cs) k = undefined

{-
For example, we can put actions together by successively passing them in
as the "last action".
-}

prog3 :: Action
prog3 = writeComputation "Hello" (writeComputation " CIS 5520\n" Stop)

{-
Let's see what happens with this program.
-}

--    ghci> sched [prog3]

{-
We can then sequence "parameterized actions" together using this function.
-}

sequenceComputation ::
  (Action -> Action) ->
  (Action -> Action) ->
  (Action -> Action)
sequenceComputation = undefined

{-
For example, here is the `hello5520` sequence above:
-}

hello5520Computation :: Action -> Action
hello5520Computation =
  writeComputation "Hello"
    `sequenceComputation` writeComputation "CIS 5520\n"

{-
We can run "parameterized actions" by giving them the "Stop" action as their
last step. Here are some examples:

    ghci> sched [ hello5520Computation Stop ]
    ghci> sched [ Fork (hello5520Computation Stop) (hello5520Computation Stop) ]
    ghci> let bomb = writeComputation "bomb" bomb
    ghci> sched [ bomb ]

Concurrency Monad
=================

One more twist, sometimes when we sequence things, we'd like to pass
information from the first parameterized action to the second.

For example, `writeComputation` doesn't return any information from the IO
monad, but if we had a parameterized computation for reading, it should pass
that character to the next action.
-}

readComputation :: (Char -> Action) -> Action
readComputation = undefined

{-
So, to be polymorphic over the result type of the action, we would like our
parameterized action type to be:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.haskell}
    (a -> Action) -> Action
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

and give our sequence operation this type:
-}

sequenceComp ::
  ((a -> Action) -> Action) -> -- last action takes an arg.
  (a -> (b -> Action) -> Action) -> -- pass to another
  (b -> Action) ->
  Action
sequenceComp m f = undefined

{-
To sequence computations, we first abstract the current continuation
`k`, then run the first computation `m`, giving it a continuation that
next runs `f` with the value produced by `m` and the original
continuation.

See if you can put this together above.
-}

--      |
--      |  spoiler space, no peeking
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
--      |

{-
Here's my solution. First let's abbreviate the type, to make it easier to
write:
-}

type CM a = (a -> Action) -> Action

sequenceCompM :: CM a -> (a -> CM b) -> CM b
sequenceCompM m f = \k -> m (`f` k)

{-
Hmmm, doesn't that type look familiar?

It is also useful to create a "trivial" computation that just passes the
result to the next one in line.
-}

returnCompM :: a -> ((a -> Action) -> Action)
returnCompM x = undefined

{-
Putting this all together, we can define a monadic type using a newtype:
-}

newtype C a = MkC {runC :: (a -> Action) -> Action}

{-
We can show that `C` is a monad using essentially the same code as
above, after taking account of the newtype constructor.
-}

instance Monad C where
  (>>=) :: C a -> (a -> C b) -> C b
  m >>= f = MkC $ \k -> runC m (\v -> runC (f v) k)

{-
>
-}

instance Applicative C where
  pure :: a -> C a
  pure x = MkC $ \k -> k x

  {-
  >
  -}

  (<*>) :: C (a -> b) -> C a -> C b
  (<*>) = ap

{-
>
-}

instance Functor C where
  fmap :: (a -> b) -> C a -> C b
  fmap = liftM

{-
Monadic computation library
---------------------------

Let's define some actions that can help us build and run computations in the
`C` monad.

The `atomic` function turns an arbitrary computation in the IO monad
into an atomic action in `C`. An atomic action is one that that runs
the monadic computation and then passes its result to the
continuation.  (We know that the monadic computation `m` will not be
interrupted; that is why this is called "atomic".)
-}

atomic :: IO a -> C a
atomic = undefined

{-
For thread spawning, there are multiple possible primitives -- we'll present
just one here.  This primitive turns its argument into a separate "top-level"
action and then continues the current computation, in a similar way to the UNIX
OS fork command.
-}

-- Create a fork action with the given computation (stopping on completion)
-- and the current continutation.
fork :: C () -> C ()
fork m = MkC (\k -> Fork (runC m (const Stop)) (k ()))

{-
Finally, running a computation is merely turning it into an action and then
giving it to the thread scheduler.
-}

run :: C a -> IO ()
run m = sched [runC m (const Stop)]

{-
Example - Concurrent Output
===========================

Now let's go back to our examples of concurrency with this monad! The first
example involves concurrent output---two threads writing to the screen at the
same time.

Next, for flexibility, we need to define classes that characterize the
operations of the monads that we wish to use. That will allow us to develop
code that is the same, no matter whether it is run single-threaded or using
cooperative concurrency.

For example, consider a class of monads that support text
output. These are the ones that have a `write` operation.
-}

class (Monad m) => OutputMonad m where
  write :: String -> m ()

{-
For example, we can make the 'IO' monad a member of this class.
-}

instance OutputMonad IO where
  write :: String -> IO ()
  write = putStr

{-
We can also make the concurrency monad a member of
the `OutputMonad` class, using `atomic`. This definition
outputs the given string atomically.
-}

instance OutputMonad C where
  write :: String -> C ()
  write s = atomic (putStr s)

{-
Let's look at example program that works in an `OutputMonad`.
Here is an infinite loop that just prints its argument over and
over.
-}

infloop :: (OutputMonad m) => String -> m ()
infloop = undefined

{-
If we run this loop from the ghci toplevel (in the IO monad) we don't get
to do anything else.

        ghci> infloop "CIS 5520"

But in the concurrency monad, we can make this loop run in parallel with other
computations.
-}

example :: C ()
example = do
  write "It's raining..."
  fork (infloop "dog\n")
  infloop "cat\n"

{-
We run this computation by giving it to the scheduler.

        ghci> run example

Note that our implementation of `write` for the concurrency monad determines
how much interleaving is possible between two different simultaneous
writes. Each use of `atomic` creates an action that cannot be
interrupted.

If we prefer, we can redefine `write` so that the atomic actions are
single-character writes instead of whole strings at a time.
-}

-- instance OutputMonad C where
--    write []     = atomic (write [])
--    write (x:xs) = atomic (write [x]) >> write xs

{-
Or, if we wanted to use both, we could keep the old `write` and define
a new operation `writeLetterByLetter` that breaks up the write into
character-sized chunks in this way.

Concurrent Input and Output
===========================

Now suppose we would like threads to read as well as write.  To do
that we need a class for *asynchronous* (i.e. nonblocking) input.  The
single method in this class reads a chunk of input as long as there is
one ready.  If there is no input available, it immediately returns
`Nothing`.
-}

class (Monad m) => InputMonad m where
  input :: m (Maybe String)

{-
To implement nonblocking input in the IO monad, we first test to see
if there is at least one character ready to read from the standard
input (using `hReady`) before we use the standard blocking operation
(`getLine`).
-}

instance InputMonad IO where
  input :: IO (Maybe String)
  input = do
    x <- IO.hReady IO.stdin
    if x then Just <$> getLine else return Nothing

{-
And, once we have an IO instance, we can use `atomic` to lift this
operation to the concurrency monad.
-}

instance InputMonad C where
  input :: C (Maybe String)
  input = atomic input

{-
Let's look at a program that is parametric in the Input and Output
monad. For example, we can write a loop that prints out a string until a
line is entered in the keyboard.
-}

ioloop :: (InputMonad m, OutputMonad m) => String -> m String
ioloop s = do
  i <- input
  case i of
    Just x -> return $ "Thread " ++ s ++ ":" ++ x
    Nothing -> do
      write s
      ioloop s

{-
Try it out in GHCi!

        ghci> ioloop "CIS 5520"   -- defaults to IO monad

With the instance for the concurrency monad, we can run this
program in parallel with other threads.
-}

example2 :: C ()
example2 = do
  fork $ ioloop "a" >>= write
  ioloop "b" >>= write

{-
Try it out!

        ghci> run example2

Shared State
============

Sometimes threads may wish to communicate with each other by passing
messages through some shared state.

We can describe this behavior with the following types.

First, we'll define a short language of messages to send back and
forth....
-}

data Msg
  = Add
  | Reset
  | Print
  | Quit

{-
Then, a class of monads that can create mailboxes for these messages
and send and receive messages through these mailboxes.
-}

class (Monad m) => MsgMonad b m | m -> b where
  newMailbox :: m b
  sendMsg :: b -> Msg -> m ()
  checkMsg :: b -> m (Maybe Msg)

{-
This type class is parameterized by two types: the monad type `m` and a mailbox
type `b`, which is a potentially empty memory location. Initially,
the location is empty, but it can be updated to contain
information using `sendMsg`.  When the memory location is read via
`checkMsg`, then the data is removed (atomically), so that the mailbox
becomes empty until it is next written.

For example, we can create an instance of this class for the `IO` monad
using the `IORef` type. This type describes Haskell's type of
"reference cells" -- mutable heap cells, in the style of ML
-- with read and write operations that live in the IO monad.
-}

type Mailbox = IO.IORef (Maybe Msg)

instance MsgMonad Mailbox IO where
  newMailbox :: IO Mailbox
  newMailbox = IO.newIORef Nothing
  sendMsg :: Mailbox -> Msg -> IO ()
  sendMsg v a = IO.writeIORef v (Just a)
  checkMsg :: Mailbox -> IO (Maybe Msg)
  checkMsg = undefined

{-
With this instance making the operations available in the `IO` monad, we can also lift them into the concurrency monad, using the following instance.
-}

instance MsgMonad Mailbox C where
  newMailbox :: C Mailbox
  newMailbox = atomic newMailbox

  sendMsg :: Mailbox -> Msg -> C ()
  sendMsg k m = atomic (sendMsg k m)

  checkMsg :: Mailbox -> C (Maybe Msg)
  checkMsg k = atomic (checkMsg k)

{-
Mailboxes are a good primitive for concurrent programming, because we don't have
to worry about race conditions. Note that even though `checkMsg` includes both a
read and a write, we don't have to worry about race conditions because the computation will be run atomically by the thread scheduler.

Now here is an example that uses our simple form of
message passing. We have two threads that communicate via
messages. One thread will be running a "simulation", the other will be
the "user interface."

The simulation just manages the value of an integer, either
incrementing it, resetting it, or printing it based on the messages
received from the interface.
-}

simulation :: Mailbox -> Integer -> C ()
simulation mv i = do
  x <- checkMsg mv
  case x of
    Just Add -> do
      write "Adding...\n"
      simulation mv (i + 1)
    Just Reset -> do
      write "Resetting...\n"
      simulation mv 0
    Just Print -> do
      write ("Current value is " ++ show i ++ "\n")
      simulation mv i
    Just Quit -> do write "Done\n"
    Nothing -> simulation mv i

{-
The interface reads keys from the keyboard and parses them into
messages for the simulation.
-}

interface :: Mailbox -> C (Maybe String) -> C ()
interface mv getInput = loop
  where
    loop = do
      maybeKey <- getInput
      case maybeKey of
        Just "a" -> sendMsg mv Add >> loop
        Just "r" -> sendMsg mv Reset >> loop
        Just "p" -> sendMsg mv Print >> loop
        Just "q" -> sendMsg mv Quit
        Just s -> write ("Unknown command: " ++ s ++ "\n") >> loop
        Nothing -> loop

{-
We put the two together by creating an MVar and then running the
interface concurrently with the interface.
-}

example6 :: C ()
example6 = do
  mv <- newMailbox
  fork $ simulation mv 0
  interface mv input

--   ghci> run example6

{-
What about multiple sources of inputs?
-------------------------------------

What if we wanted to have multiple interfaces to the same simulation?
For example, what if we want to have a "remote control" client that
can send commands to the simulation via the network, in addition to
the local interface?

We could do that with an additional, network interface. This code sets
up a socket to listen for commands sent via the code in
[Client.hs](Client.html).
-}

-- | Create an interface to the server that communicates via a socket
-- on the specified port
network :: String -> Mailbox -> C ()
network port mv = do
  handle <- atomic $ Socket.withSocketsDo $ do
    putStrLn "Opening a socket."
    addr <- resolve
    sock <- open addr
    (conn, _peer) <- Socket.accept sock
    putStrLn "Connected to socket."
    Socket.socketToHandle conn IO.ReadMode
  interface
    mv
    ( atomic $ do
        x <- IO.hReady handle
        if x
          then Just <$> IO.hGetLine handle
          else return Nothing
    )
  atomic $ do
    IO.hClose handle
    putStrLn "Socket closed."
  where
    resolve = do
      let hints =
            Socket.defaultHints
              { Socket.addrFlags = [Socket.AI_PASSIVE],
                Socket.addrSocketType = Socket.Stream
              }
      addrInfos <- Socket.getAddrInfo (Just hints) Nothing (Just port)
      case addrInfos of
        [] -> error "resolve returned no results"
        (addrInfo : _) -> return addrInfo
    open addr = do
      sock <- Socket.socket (Socket.addrFamily addr) (Socket.addrSocketType addr) (Socket.addrProtocol addr)
      Socket.setSocketOption sock Socket.ReuseAddr 1
      Socket.withFdSocket sock Socket.setCloseOnExecIfNeeded
      Socket.bind sock $ Socket.addrAddress addr
      Socket.listen sock 1024
      return sock

{-
Then, we can run this code concurrently with the original simulation and
interface.

Here's our code that starts the server.
-}

example7 :: String -> C ()
example7 port = do
  mv <- newMailbox
  fork (simulation mv 0)
  fork (interface mv input)
  network port mv

{-
To make this example work, first start the server

        ghci> run $ example7 "1025"

This example will work just like `example6` above. You can send it commands locally
(because it has a local copy of the interface). Keep it running.

Then, in another terminal, load the client code into GHC. If everything goes
well, the `client` function will return a handle that can be used to
communicate with the server.

          *Client> h <- client local "1025"

This handle can be used with the `send` command.

          *Client> send h "p"
          *Client> send h "a"   -- no output here, all effects are shown on the server
          *Client> send h "r"
-}
