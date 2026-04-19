module E4 where

import Data.List

-- Exercise I

fun1o :: [Integer] -> Integer
fun1o [] = 1
fun1o (x : xs)
    | even x = (x - 2) * fun1o xs
    | otherwise = fun1o xs

fun1 :: [Integer] -> Integer
fun1 = product . map (flip (-) 2) . filter even

fun2o :: Integer -> Integer
fun2o 1 = 0
fun2o n
    | even n = n + fun2o (n `div` 2)
    | otherwise = fun2o (3 * n + 1)

fun2 :: Integer -> Integer
fun2 =
    sum
        . filter even
        . takeWhile (/= 1)
        . iterate
            (\x -> if even x then x `div` 2 else 1 + 3 * x)

-- Exercise II

data Tree a
    = Leaf
    | Node Integer (Tree a) a (Tree a)
    deriving (Show, Eq)

height :: Tree a -> Integer
height Leaf = 0
height (Node _ l _ r) = 1 + max (height l) (height r)

balance :: Tree a -> Integer
balance Leaf = 0
balance (Node _ l _ r) = height l - height r

balanced :: Tree a -> Bool
balanced = (<= 0) . balance

insertT :: a -> Tree a -> Tree a
insertT val Leaf = Node 1 Leaf val Leaf
insertT val (Node _ lt ov rt) =
  Node (1 + max (height lt) (height rt)) Leaf val Leaf
-- TODO: Adopt Tree from Course Work I

foldTree :: [a] -> Tree a
foldTree = foldr insertT Leaf

-- Exercise III

xor :: [Bool] -> Bool
-- xor l = odd (length (foldr (\x y -> if x then x: y else y) [] l))
xor = foldr (\x y -> not (x && y) && (x || y)) False

map' :: (a -> b) -> [a] -> [b]
map' f = foldr (\x y -> f x : y) []

foldl'' :: (a -> b -> a) -> a -> [b] -> a
foldl'' f = foldr (flip f)

-- Exercise IV

cartProd :: [a] -> [b] -> [(a, b)]
cartProd xs ys = [(x, y) | x <- xs, y <- ys]

sieveSundaram :: Integer -> [Integer]
sieveSundaram n = map ((+ 1) . (* 2)) ([1 .. n] \\ [i + j + 2 * i * j | j <- [1 .. n], i <- [1 .. j], i + j + 2 * i * j <= n])
