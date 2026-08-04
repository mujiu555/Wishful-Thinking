{-
---
fulltitle: "MtlExample"
---

This file demonstrates the use of the `mtl` library
using the interpreter example from the [Transformers](Transformers.html) module.

-}

module MtlExample where

{-
The definitions of `StateT`, `ExceptT` and `Identity` come from separate modules
in the `mtl` library.
-}

import Control.Monad.Except
  ( ExceptT,
    MonadError (throwError),
    runExceptT,
  )
import Control.Monad.Identity
  ( Identity (runIdentity),
  )
import Control.Monad.State
  ( MonadState (get, put),
    StateT (runStateT),
  )
import Data.Function ((&))

data Expr
  = Val Int
  | Div Expr Expr
  deriving (Show)

-- | evaluates to 42
ok :: Expr
ok =
  (Val 1972 `Div` Val 2)
    `Div` Val 23

-- | divide by zero error
err :: Expr
err =
  Val 2
    `Div` ( Val 1
              `Div` (Val 2 `Div` Val 3)
          )

-- | nicely format the error
errorS :: (Show a) => a -> a -> String
errorS y m = "Error dividing " ++ show y ++ " by " ++ show m

-- | increment the
tickStateInt :: (MonadState Int m) => m ()
tickStateInt = do
  (x :: Int) <- get
  put (x + 1)

{-

-}

eval :: (MonadError String m, MonadState Int m) => Expr -> m Int
eval (Val n) = return n
eval (Div x y) = do
  n <- eval x
  m <- eval y
  if m == 0
    then throwError $ errorS n m
    else do
      tickStateInt
      return (n `div` m)

{-

-}

-- | Show the result of runStateT, parameterized by a function
-- to show the value
showSt :: (a -> String) -> (a, Int) -> String
showSt f (v, cnt) = f v ++ ", count: " ++ show cnt

-- | Show the result of runExceptT, parameterized by a function
-- to show the value
showEx :: (a -> String) -> Either String a -> String
showEx _ (Left m) = "Raise: " ++ m
showEx f (Right v) = "Result: " ++ f v

goExSt :: Expr -> String
goExSt e =
  eval e -- :: StateT Int (ExceptT String Identity) Int
    & flip runStateT 0
    & runExceptT
    & runIdentity
    & showEx (showSt show)

goStEx :: Expr -> String
goStEx e =
  eval e -- :: ExceptT String (StateT Int Identity) Int
    & runExceptT
    & flip runStateT 0
    & runIdentity
    & showSt (showEx show)

-- >>> goExSt ok
-- "Result: 42, count: 2"

-- >>> goExSt err
-- "Raise: Error dividing 1 by 0"

-- >>> goStEx ok
-- "Result: 42, count: 2"

-- >>> goStEx err
-- "Raise: Error dividing 1 by 0, count: 1"
