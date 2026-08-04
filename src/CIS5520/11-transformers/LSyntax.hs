{-
---
fulltitle: "In class exercise: LSyntax"
date: November 13, 2024
---

This file defines the abstract syntax for a simple imperative programming (L)
 language extended with exceptions.

It is meant to go with the in-class exercise on monad transformers (TransExercise)[TransExercise.hs].
-}

module LSyntax where

{-
Syntax
======

-}

type Var = String -- only global variables, no tables

newtype Block
  = Block [Statement] -- s1 ... sn
  deriving (Eq, Show)

instance Semigroup Block where
  (<>) :: Block -> Block -> Block
  Block s1 <> Block s2 = Block (s1 <> s2)

instance Monoid Block where
  mempty :: Block
  mempty = Block []

{-

-}

data Statement
  = Assign Var Expression -- x = e
  | If Expression Block Block -- if e then s1 else s2
  | While Expression Block -- while e s
  | Try Block Var Block -- try s1 handle x in s2
  | Throw Expression -- throw e
  deriving (Eq, Show)

data Expression
  = Var Var -- x
  | Val Value -- v
  | Op2 Expression Bop Expression -- e1 op e2
  deriving (Eq, Show)

data Bop
  = Plus -- `+`  :: Int -> Int -> Int
  | Minus -- `-`  :: Int -> Int -> Int
  | Times -- `*`  :: Int -> Int -> Int
  | Divide -- `//` :: Int -> Int -> Int
  deriving (Eq, Show, Enum)

data Value
  = IntVal Int -- literal ints
  | NilVal -- `nil`
  deriving (Eq, Show)
