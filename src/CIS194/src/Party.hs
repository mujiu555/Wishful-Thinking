-- |

module Party where

import Employee

import Data.List
import Data.Tree

-- Exercise I
glCons :: Employee -> GuestList -> GuestList
glCons e (GL l f) = GL (nub (e:l)) (empFun e + f)

moreFun :: GuestList -> GuestList -> GuestList
moreFun g1@(GL _ f1) g2@(GL _ f2)
  | f1 <= f2  = g2
  | otherwise = g1

-- Exercise II
