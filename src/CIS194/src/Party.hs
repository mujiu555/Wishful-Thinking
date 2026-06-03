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
treeFold :: (a -> [b] -> b) -> Tree a -> b
treeFold f (Node val forest) = f val (map (treeFold f) forest)

-- Exercise III
nextLevel :: Employee -> [(GuestList, GuestList)] -> (GuestList, GuestList)
nextLevel e l = let r = foldr (<>) mempty l in
  (glCons e (snd r), fst r)

-- Exercise IV
maxFun :: Tree Employee -> GuestList
maxFun l = maximum $ treeFold nextLevel l
