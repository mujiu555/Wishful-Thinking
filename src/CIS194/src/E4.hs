-- |

module E4 where

-- Exercise I

fun1o :: [Integer] -> Integer
fun1o []      = 1
fun1o (x:xs)
  | even x    = (x-2) * fun1o xs
  | otherwise = fun1o xs

fun1 :: [Integer] -> Integer
fun1 = product . map (flip (-) 2) . filter even

fun2o :: Integer -> Integer
fun2o 1 = 0
fun2o n | even n    = n + fun2o (n `div` 2)
        | otherwise = fun2o (3 * n + 1)

fun2 :: Integer -> Integer
fun2 = sum . filter even . takeWhile (/= 1) . iterate
  (\x -> if even x then x `div` 2 else 1 + 3 * x)

-- Exercise II

data Tree a =
  Leaf
  | Node Integer (Tree a) a (Tree a)
  deriving (Show, Eq)

height :: Tree a -> Integer
height Leaf           = 0
height (Node _ l _ r) = 1 + max (height l) (height r)

balance :: Tree a -> Integer
balance Leaf           = 0
balance (Node h l _ r) = height l - height r

balanced :: Tree a -> Bool
balanced = (<= 0) . balance

rotate :: Tree -> Tree
rotate Leaf = Leaf
rotate tree@(Node h ltree _ rtree)
  | balance tree > 1 && balance ltree > 0  = right tree
  | balance tree < -1 && balance rtree < 0 = left tree
  | balance tree > 1 && balance ltree < 0  = leftright tree
  | balance tree < -1 && balance rtree > 0 = rightleft tree
  | otherwise                        = tree
  where
    right (Node (Node llt lv rlt) v rt) = Node llt lv (Node rlt v rt)
    right t = t
    left (Node lt v (Node lrt rv rrt)) = Node (Node lt v lrt) rv rrt
    left t = t
    leftright (Node (Node Leaf lv (Node lrlt rlv rrlt)) v Leaf) =
      Node (Node Leaf lv lrlt) rlv (Node rrlt v Leaf)
    leftright t = t
    rightleft (Node Leaf v (Node (Node llrt lrv rlrt) rv Leaf)) =
      Node (Node Leaf v rlrt) lrv (Node llrt rv Leaf)
    rightleft t = t

insert :: Tree a -> val -> Tree a
insert Leaf a           = Node 1 Leaf a Leaf
insert (Node h lt v rt) = . -- TODO

foldTree :: [a] -> Tree a
foldTree = foldr insert Leaf
