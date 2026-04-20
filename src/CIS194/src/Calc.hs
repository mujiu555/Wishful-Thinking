-- |
{-# LANGUAGE FlexibleInstances #-}

module Calc where

import ExprT
import Parser
import StackVM

import qualified Data.Map as M

-- Exercise: I
eval :: ExprT -> Integer
eval (Lit i)     = i
eval (ExprT.Add e1 e2) = eval e1 + eval e2
eval (ExprT.Mul e1 e2) = eval e1 * eval e2

-- Exercise: II
evalStr :: String -> Maybe Integer
evalStr s = case parseExp Lit ExprT.Add ExprT.Mul s of
  (Just expr) -> Just (eval expr)
  _ -> Nothing

-- Exercise: III
class Expr a where
  lit :: Integer -> a
  mul :: a -> a -> a
  add :: a -> a -> a

reify :: ExprT -> ExprT
reify = id

-- Exercise: IV
instance Expr Integer where
  lit = id
  mul = (*)
  add = (+)

instance Expr Bool where
  lit = (> 0)
  mul = (&&)
  add = (||)

newtype MinMax = MinMax Integer deriving (Eq, Show)
newtype Mod7 = Mod7 Integer deriving (Eq, Show)

instance Expr MinMax where
  lit = MinMax
  mul (MinMax a) (MinMax b) = MinMax (min a b)
  add (MinMax a) (MinMax b) = MinMax (max a b)

instance Expr Mod7 where
  lit = Mod7
  mul (Mod7 a) (Mod7 b) = Mod7 (mod (a * b) 7)
  add (Mod7 a) (Mod7 b) = Mod7 (mod (a + b) 7)

testExp :: Expr a => Maybe a
testExp = parseExp lit add mul "(3 * -4) + 5"

-- Exercise: V
instance Expr Program where
  lit a = [PushI a]
  mul a b = a ++ b ++ [StackVM.Mul]
  add a b = a ++ b ++ [StackVM.Add]

compile :: String -> Maybe Program
compile = parseExp lit add mul

-- Exercise: VI
class HasVars a where
  var :: String -> a

data VarExprT =
  Var String
  | VLit Integer
  | VAdd VarExprT VarExprT
  | VMul VarExprT VarExprT
  deriving (Show)

instance Expr VarExprT where
  lit = VLit
  mul = VMul
  add = VAdd

withVars :: [(String, Integer)] -> (M.Map String Integer -> Maybe Integer) -> Maybe Integer
withVars vs exp = exp $ M.fromList vs

instance HasVars VarExprT where
  var = Var

instance HasVars (M.Map String Integer -> Maybe Integer) where
  var = M.lookup
-- TODO:
