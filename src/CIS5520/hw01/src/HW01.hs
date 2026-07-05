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
abc x y z =
  if x
    then
      if y
        then True
        else if (x && z) then True else False
    else False

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
reverse l = reverseAux l []
  where
    reverseAux l acc =
      if null l
        then acc
        else reverseAux (tail l) (head l : acc)

-- >>> zip "abc" [True,False,True]
-- [('a',True),('b',False),('c',True)]
-- >>> zip [1,2] "a"
-- [(1,'a')]
zip xs ys = g 0 xs ys
  where
    g n xs ys =
      if n == length xs || n == length ys
        then []
        else (xs !! n, ys !! n) : g (n + 1) xs ys

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
minimumMaybe = undefined

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
startsWith = undefined

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
isSubsequenceOf = undefined

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
countSub = undefined

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
transpose = undefined

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
takeWhile = undefined

-- | `find pred lst` returns the first element of the list that
-- satisfies the predicate. Because no element may do so, the
-- answer is returned in a `Maybe`.
--
-- >>> find odd [0,2,3,4]
-- Just 3
-- >>> find odd [0,2,4,6]
-- Nothing
find :: (a -> Bool) -> [a] -> Maybe a
find = undefined

-- | `all pred lst` returns `False` if any element of `lst`
-- fails to satisfy `pred` and `True` otherwise.
--
-- >>> all odd [1,2,3]
-- False
all :: (a -> Bool) -> [a] -> Bool
all = undefined

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
map2 = undefined

-- | Apply a partial function to all the elements of the list,
-- keeping only valid outputs.
--
-- >>> mapMaybe root [0.0, -1.0, 4.0]
-- [0.0,2.0]
--
-- (where `root` is defined below.)
mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe = undefined

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
concat = undefined

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
startsWithHO = undefined

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
countSubHO = undefined
