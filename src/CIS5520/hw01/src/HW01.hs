module HW01 where

import Prelude hiding (all, concat, reverse, takeWhile, zip, (++))

--------------------------------------------------------------------------------
-- Problem (Good Style)
--------------------------------------------------------------------------------

-- >>> abc True False True
-- True
-- >>> abc True False False
-- False
-- >>> abc False True True
-- False
abc :: Bool -> Bool -> Bool -> Bool
abc x y z = x && (y || (x && z))

-- >>> arithmetic ((1,2),3) ((4,5),6)
-- (-3,6,-3)
-- >>> arithmetic ((3,2),1) ((4,5),6)
-- (7,-14,7)
arithmetic :: ((Int, Int), Int) -> ((Int, Int), Int) -> (Int, Int, Int)
arithmetic x1 x2 =
  let a = fst (fst x1)
   in let b = snd (fst x1)
       in let c = snd x1
           in let d = fst (fst x2)
               in let e = snd (fst x2)
                   in let f = snd x2
                       in ( ( ( ( ((b * f) - (c * e)),
                                  ( ( c
                                        * d
                                    )
                                      - (a * f)
                                  ),
                                  ((a * e) - (b * d))
                                )
                              )
                            )
                          )

-- >>> reverse [3,2,1]
-- [1,2,3]
reverse :: [a] -> [a]
reverse l = reverseAux l []
  where
    reverseAux (x:xs) acc = reverseAux xs (x:acc)
    reverseAux [] acc     = acc

-- >>> zip "abc" [True,False,True]
-- [('a',True),('b',False),('c',True)]
-- >>> zip [1,2] "a"
-- [(1,'a')]
zip :: [a] -> [b] -> [(a, b)]
zip xs ys = g 0 xs ys
  where
    g n lxs lys =
      if n == length lxs || n == length lys
        then []
        else (lxs !! n, lys !! n) : g (n + 1) lxs lys

--------------------------------------------------------------------------------
-- Problem (List recursion)
--------------------------------------------------------------------------------

-- | The 'minimumMaybe` function computes the mininum value of a
-- nonempty list. If the list is empty, it returns Nothing.
--
-- >>> minimumMaybe [2,1,3]
-- Just 1
-- >>> minimumMaybe []
-- Nothing
minimumMaybe :: [Int] -> Maybe Int
minimumMaybe []      = Nothing
minimumMaybe l       = Just (minimum l)

-- | The 'startsWith' function takes two strings and returns 'True'
-- iff the first is a prefix of the second.
--
-- >>> "Hello" `startsWith` "Hello World!"
-- True
-- >>> "World" `startsWith` "Hello World!"
-- False
-- >>> "Helo" `startsWith` "Hello World!"
-- False
startsWith :: String -> String -> Bool
startsWith [] []           = True
startsWith _ []            = False
startsWith [] _            = True
startsWith (s: ss) (p: ps) = (s == p) && (startsWith ss ps)

-- | The 'isSubsequenceOf' function takes two strings and returns 'True'
-- when all characters in the first are contained within the second, in order.
--
-- >>> "Hello" `isSubsequenceOf` "Hello World!"
-- True
-- >>> "World" `isSubsequenceOf` "Hello World!"
-- True
-- >>> "Helo" `isSubsequenceOf` "Hello World!"
-- True
-- >>> "Wello" `isSubsequenceOf` "Hello World!"
-- False
isSubsequenceOf :: String -> String -> Bool
isSubsequenceOf [] [] = True
isSubsequenceOf _ []  = False
isSubsequenceOf [] _  = True
isSubsequenceOf (s: ss) (p: ps) = ((s == p) && (isSubsequenceOf ss ps)) || (isSubsequenceOf (s: ss) ps)

-- | The 'countSub' function returns the number of (potentially overlapping)
-- occurrences of a substring sub found in a string.
-- Note: You can use other functions that you have defined in this file in
-- your solution.
--
-- >>> countSub "aa" "aaa"
-- 2
-- >>> countSub "" "aaac"
-- 5
countSub :: String -> String -> Int
countSub s (p: ps)   = (if (startsWith s (p: ps)) then 1 else 0) + (countSub s ps)
countSub [] [] = 1
countSub _  [] = 0

-- | The 'transpose' function transposes the rows and columns of its argument.
-- If the inner lists are not all the same length, then the extra elements
-- are ignored. You may assume that the input list is non-empty, and that each
-- of the sublists is also non-empty.
-- (i.e. we won't test your code on `transpose []` or `transpose [[]]`)
-- Note, this function should *not* have the same behavior as the library version
-- of transpose (i.e. the version of transpose from Data.List), which retains
-- extra elements in the output.
-- >>> transpose [[1,2,3],[4,5,6]]
-- [[1,4],[2,5],[3,6]]
-- >>> transpose [[3,4,5]]
-- [[3],[4],[5]]
-- >>> transpose [[1,2],[3,4,5]]
-- [[1,3],[2,4]]

-- (WARNING: this one is tricky!)
transpose :: [[a]] -> [[a]]
-- NOTE: Since the basic idea to solve this problem is construct new vector from each list's head.
-- And zipWith will automatically ignore the longer part and !! construct new list according
-- to the method provided
-- then it is possible to extract all list's element using
-- `zipWith (:) a (repeat [])`
-- and, furhtermore, cols,
-- `zipWith (:) a (zipWith (:) b (repeat []))`
transpose = foldr (\x y -> zipWith (:) x y) (repeat [])

--------------------------------------------------------------------------------
-- Problem (Defining higher-order functions)
--------------------------------------------------------------------------------

-- | `takeWhile`, applied to a predicate `p` and a list `xs`,
-- returns the longest prefix (possibly empty) of `xs` of elements
-- that satisfy `p`.
--
-- >>> takeWhile (< 3) [1,2,3,4,1,2,3,4]
-- [1,2]
-- >>> takeWhile (< 9) [1,2,3]
-- [1,2,3]
-- >>> takeWhile (< 0) [1,2,3]
-- []
takeWhile :: (a -> Bool) -> [a] -> [a]
takeWhile _ []      = []
takeWhile f (x: xs) = if (f x) then (x : takeWhile f xs) else (takeWhile f xs)

-- | `find pred lst` returns the first element of the list that
-- satisfies the predicate. Because no element may do so, the
-- answer is returned in a `Maybe`.
--
-- >>> find odd [0,2,3,4]
-- Just 3
-- >>> find odd [0,2,4,6]
-- Nothing
find :: (a -> Bool) -> [a] -> Maybe a
find _ [] = Nothing
find f (x: xs) = if (f x) then (Just x) else (find f xs)

-- | `all pred lst` returns `False` if any element of `lst`
-- fails to satisfy `pred` and `True` otherwise.
--
-- >>> all odd [1,2,3]
-- False
all :: (a -> Bool) -> [a] -> Bool
all _ [] = True
all f (x: xs) = (f x) && (all f xs)

-- | `map2 f xs ys` returns the list obtained by applying `f` to
-- to each pair of corresponding elements of `xs` and `ys`. If
-- one list is longer than the other, then the extra elements
-- are ignored.
-- i.e.
--   map2 f [x1, x2, ..., xn] [y1, y2, ..., yn, yn+1]
--        returns [f x1 y1, f x2 y2, ..., f xn yn]
--
-- >>> map2 (+) [1,2] [3,4]
-- [4,6]
--
-- NOTE: `map2` is called `zipWith` in the Prelude
map2 :: (a -> b -> c) -> [a] -> [b] -> [c]
map2 f (x: xs) (y: ys) = (f x y) : (map2 f xs ys)
map2 _ _ _             = []

-- | Apply a partial function to all the elements of the list,
-- keeping only valid outputs.
--
-- >>> mapMaybe root [0.0, -1.0, 4.0]
-- [0.0,2.0]
--
-- (where `root` is defined below.)
mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe f = foldr (\x y ->
                      case (f x) of
                        Nothing  -> y
                        (Just v) -> (v : y))
             []

root :: Double -> Maybe Double
root d = if d < 0.0 then Nothing else Just $ sqrt d

--------------------------------------------------------------------------------
-- Problem (map and foldr practice for lists)
--------------------------------------------------------------------------------

-- | The concatenation of all of the elements of a list of lists
--
-- >>> concat [[1,2,3],[4,5,6],[7,8,9]]
-- [1,2,3,4,5,6,7,8,9]
concat :: [[a]] -> [a]
concat = foldr (<>) []

-- | The 'startsWithHO' function takes two strings and returns 'True'
-- iff the first is a prefix of the second. This is the same as `startsWith` above
-- except this time you need to use `foldr` to define it.
--
-- >>> "Hello" `startsWithHO` "Hello World!"
-- True
--
-- >>> "Hello" `startsWithHO` "Wello Horld!"
-- False
startsWithHO :: String -> String -> Bool
startsWithHO pat s = foldr step base pat s
  where
    -- base case: pattern is empty, so every string has it as prefix
    base = \_ -> True
    -- step: for each character p in the pattern, build a function that
    -- checks the remaining string t.
    step p f = \t ->
      case t of
        []       -> False          -- pattern longer than string
        (x : xs) -> p == x && f xs -- match head and continue with tail

-- INTERLUDE: para

-- | foldr variant that provides access to each tail of the list
para :: (a -> [a] -> b -> b) -> b -> [a] -> b
para _ b [] = b
para f b (x : xs) = f x xs (para f b xs)

-- | The 'tails' function calculates all suffixes of a give list and returns them
-- in decreasing order of length. For example:
--
-- >>> tails "abc"
-- ["abc","bc","c",""]
tails :: [a] -> [[a]]
tails [] = [[]]
tails (x : xs) = (x : xs) : tails xs

-- | The 'countSubHO' function returns the number of (potentially overlapping)
-- occurrences of a substring sub found in a string.
--
-- >>> countSubHO "aa" "aaa"
-- 2
-- >>> countSubHO "" "aaac"
-- 5
countSubHO :: String -> String -> Int
countSubHO pat s = foldr (\x y -> (case (startsWithHO pat x) of
                                       True -> 1
                                       False -> 0
                                    ) + y) 0 (tails s)
