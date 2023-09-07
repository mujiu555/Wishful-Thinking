module HW01 where

-- libraries for Kata problem (only)

import qualified Data.Char as Char
import qualified Data.List as List
import qualified Data.Maybe as Maybe
import Test.HUnit
  ( Assertion,
    Test (TestList),
    assertFailure,
    runTestTT,
    (@?=),
    (~:),
    (~=?),
    (~?=),
  )
import Text.Read (readMaybe)
import Prelude hiding (all, concat, reverse, takeWhile, zip, (++))

--------------------------------------------------------------------------------
-- Problem (Good Style)
--------------------------------------------------------------------------------

testStyle :: Test
testStyle =
  "testStyle"
    ~: TestList [tabc, tarithmetic, treverse, tzip]

abc x y z =
  if x
    then
      if y
        then True
        else if (x && z) then True else False
    else False

tabc :: Test
tabc =
  "abc"
    ~: TestList
      [ abc True False True ~?= True,
        abc True False False ~?= False,
        abc False True True ~?= False
      ]

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

tarithmetic :: Test
tarithmetic =
  "arithmetic"
    ~: TestList
      [ arithmetic ((1, 2), 3) ((4, 5), 6) ~?= (-3, 6, -3),
        arithmetic ((3, 2), 1) ((4, 5), 6) ~?= (7, -14, 7)
      ]

reverse l = reverseAux l []
  where
    reverseAux l acc =
      if null l
        then acc
        else reverseAux (tail l) (head l : acc)

treverse :: Test
treverse =
  "reverse"
    ~: TestList
      [ reverse [3, 2, 1] ~?= ([1, 2, 3] :: [Int]),
        reverse [1] ~?= ([1] :: [Int])
      ]

zip xs ys = g 0 xs ys
  where
    g n xs ys =
      if n == length xs || n == length ys
        then []
        else (xs !! n, ys !! n) : g (n + 1) xs ys

tzip :: Test
tzip =
  "zip"
    ~: TestList
      [ zip "abc" [True, False, True] ~?= [('a', True), ('b', False), ('c', True)],
        zip "abc" [True] ~?= [('a', True)],
        zip [] [] ~?= ([] :: [(Int, Int)])
      ]

--------------------------------------------------------------------------------
-- Problem (List recursion)
--------------------------------------------------------------------------------

testLists :: Test
testLists =
  "testLists"
    ~: TestList
      [tminimumMaybe, tstartsWith, tendsWith, ttranspose, tcountSub]

-- | The 'minimumMaybe` function computes the mininum value of a
-- nonempty list. If the list is empty, it returns Nothing.
--
-- >>> minumumMaybe []
-- Nothing
-- >>> minumumMaybe [2,1,3]
-- Just 1
minimumMaybe :: [Int] -> Maybe Int
minimumMaybe = undefined

tminimumMaybe :: Test
tminimumMaybe =
  "minimumMaybe" ~: (assertFailure "testcases for minimumMaybe" :: Assertion)

-- | The 'startsWith' function takes two strings and returns 'True'
-- iff the first is a prefix of the second.
--
-- >>> "Hello" `startsWith` "Hello World!"
-- True
--
-- >>> "Hello" `startsWith` "Wello Horld!"
-- False
startsWith :: String -> String -> Bool
startsWith = undefined

tstartsWith :: Test
tstartsWith = "startsWith" ~: (assertFailure "testcase for startsWith" :: Assertion)

--

-- | The 'endsWith' function takes two lists and returns 'True' iff
-- the first list is a suffix of the second. The second list must be
-- finite.
--
-- >>> "ld!" `endsWith` "Hello World!"
-- True
--
-- >>> "World" `endsWith` "Hello World!"
-- False
endsWith :: String -> String -> Bool
endsWith = undefined

tendsWith :: Test
tendsWith = "endsWith" ~: (assertFailure "testcase for endsWith" :: Assertion)

-- | The 'transpose' function transposes the rows and columns of its argument.
-- If the inner lists are not all the same length, then the extra elements
-- are ignored.
-- You may assume that the input list is non-empty, and that each of the sublists
-- is also non-empty.
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

ttranspose :: Test
ttranspose = "transpose" ~: (assertFailure "testcase for transpose" :: Assertion)

-- | The 'countSub' function returns the number of (potentially overlapping)
-- occurrences of a substring sub found in a string.
--
-- >>> countSub "aa" "aaa"
-- 2
-- >>> countSub "" "aaac"
-- 5
countSub :: String -> String -> Int
countSub = undefined

tcountSub :: Test
tcountSub = "countSub" ~: (assertFailure "testcase for countSub" :: Assertion)

--------------------------------------------------------------------------------
-- Problem (Defining higher-order functions)
--------------------------------------------------------------------------------

testHO :: Test
testHO = TestList [ttakeWhile, tfind, tall, tmap2, tmapMaybe]

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

ttakeWhile :: Test
ttakeWhile = "takeWhile" ~: (assertFailure "testcase for takeWhile" :: Assertion)

-- | `find pred lst` returns the first element of the list that
-- satisfies the predicate. Because no element may do so, the
-- answer is returned in a `Maybe`.
--
-- >>> find odd [0,2,3,4]
-- Just 3
find :: (a -> Bool) -> [a] -> Maybe a
find = undefined

tfind :: Test
tfind = "find" ~: (assertFailure "testcase for find" :: Assertion)

-- | `all pred lst` returns `False` if any element of `lst`
-- fails to satisfy `pred` and `True` otherwise.
--
-- >>> all odd [1,2,3]
-- False
all :: (a -> Bool) -> [a] -> Bool
all = undefined

tall :: Test
tall = "all" ~: (assertFailure "testcase for all" :: Assertion)

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

tmap2 :: Test
tmap2 = "map2" ~: (assertFailure "testcase for map2" :: Assertion)

-- | Apply a partial function to all the elements of the list,
-- keeping only valid outputs.
--
-- >>> mapMaybe root [0.0, -1.0, 4.0]
-- [0.0,2.0]
--
-- (where `root` is defined below.)
mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe = undefined

tmapMaybe :: Test
tmapMaybe = "mapMaybe" ~: (assertFailure "testcase for mapMaybe" :: Assertion)

root :: Double -> Maybe Double
root d = if d < 0.0 then Nothing else Just $ sqrt d

--------------------------------------------------------------------------------
-- Problem (map and foldr practice for lists)
--------------------------------------------------------------------------------

testFoldr :: Test
testFoldr = TestList [tconcat, tstartsWithHO, tendsWithHO, ttails, tcountSubHO]

-- | The concatenation of all of the elements of a list of lists
--
-- >>> concat [[1,2,3],[4,5,6],[7,8,9]]
-- [1,2,3,4,5,6,7,8,9]
concat :: [[a]] -> [a]
concat = undefined

tconcat :: Test
tconcat = "concat" ~: (assertFailure "testcase for concat" :: Assertion)

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

tstartsWithHO = "tstartsWithHO" ~: (assertFailure "testcase for startsWith" :: Assertion)

-- INTERLUDE: para

-- | foldr variant that provides access to each tail of the list
para :: (a -> [a] -> b -> b) -> b -> [a] -> b
para _ b [] = b
para f b (x : xs) = f x xs (para f b xs)

-- | The 'tails' function calculates all suffixes of a give list and returns them
-- in decreasing order of length. For example:
--
-- >>> tails "abc"
-- ["abc", "bc", "c", ""],
tails :: [a] -> [[a]]
tails [] = [[]]
tails (x : xs) = (x : xs) : tails xs

tails' = undefined

ttails :: Test
ttails =
  "tails"
    ~: TestList
      [ "tails0" ~: tails' "abc" ~?= ["abc", "bc", "c", ""],
        "tails1" ~: tails' "" ~?= [""],
        "tails2" ~: tails' "a" ~?= ["a", ""]
      ]

-- | The 'endsWithHO' function takes two lists and returns 'True' iff
-- the first list is a suffix of the second. The second list must be
-- finite.
--
-- >>> "ld!" `endsWithHO` "Hello World!"
-- True
--
-- >>> "World" `endsWithHO` "Hello World!"
-- False
endsWithHO :: String -> String -> Bool
endsWithHO = undefined

tendsWithHO :: Test
tendsWithHO = "endsWithHO" ~: (assertFailure "testcase for endsWithHO" :: Assertion)

-- | The 'countSubHO' function returns the number of (potentially overlapping)
-- occurrences of a substring sub found in a string.
--
-- >>> countSubHO "aa" "aaa"
-- 2
-- >>> countSubHO "" "aaac"
-- 5
countSubHO :: String -> String -> Int
countSubHO = undefined

tcountSubHO = "countSubHO" ~: (assertFailure "testcase for countSubHO" :: Assertion)

--------------------------------------------------------------------------------
-- Data Munging Kata
--------------------------------------------------------------------------------

-- Part One: Weather

-- >>> weatherProgram "dat/jul23.dat"
-- "16"

weather :: String -> Maybe String
weather str = error "unimplemented"

weatherProgram :: String -> IO String
weatherProgram file = do
  str <- readFile file
  return
    ( case weather str of
        Just result -> result
        Nothing -> "Cannot read file"
    )

-- | Use this function to parse Ints
readInt :: String -> Maybe Int
readInt = readMaybe

testWeather :: Test
testWeather =
  TestList
    [ "jul23" ~: do
        str <- readFile "dat/jul23.dat"
        weather str @?= Just "16",
      "jul22" ~: do
        str <- readFile "dat/jul22.dat"
        weather str @?= Just "26",
      "jul21" ~: do
        str <- readFile "dat/jul21.dat"
        weather str @?= Just "18",
      "jul20" ~: do
        str <- readFile "dat/jul20.dat"
        weather str @?= Just "10",
      "jul19" ~: do
        str <- readFile "dat/jul19.dat"
        weather str @?= Just "8"
    ]

-- >>> runTestTT testWeather
-- Counts {cases = 5, tried = 5, errors = 0, failures = 0}

-- Part Two: Soccer League Table

soccer :: String -> Maybe String
soccer = error "unimplemented"

soccerProgram :: String -> IO String
soccerProgram file = do
  str <- readFile file
  return $ case soccer str of
    Just result -> result
    Nothing -> "Cannot read file"

testSoccer :: Test
testSoccer =
  TestList
    [ "soccer22" ~: do
        str <- readFile "dat/soccer22.dat"
        soccer str @?= Just "Fulham",
      "soccer21" ~: do
        str <- readFile "dat/soccer21.dat"
        soccer str @?= Just "Leicester City",
      "soccer20" ~: do
        str <- readFile "dat/soccer20.dat"
        soccer str @?= Just "Aston Villa",
      "soccer19" ~: do
        str <- readFile "dat/soccer19.dat"
        soccer str @?= Just "Burnley",
      "soccer18" ~: do
        str <- readFile "dat/soccer18.dat"
        soccer str @?= Just "Everton"
    ]

-- >>> runTestTT testSoccer
-- Counts {cases = 4, tried = 4, errors = 0, failures = 0}

-- Part Three: DRY Fusion

weather2 :: String -> Maybe String
weather2 = undefined

soccer2 :: String -> Maybe String
soccer2 = undefined

-- Kata Questions

-- To what extent did the design decisions you made when writing the original
-- programs make it easier or harder to factor out common code?

shortAnswer1 :: String
shortAnswer1 = "Fill in your answer here"

-- Was the way you wrote the second program influenced by writing the first?

shortAnswer2 :: String
shortAnswer2 = "Fill in your answer here"

-- Is factoring out as much common code as possible always a good thing? Did the
-- readability of the programs suffer because of this requirement? How about the
-- maintainability?

shortAnswer3 :: String
shortAnswer3 = "Fill in your answer here"
