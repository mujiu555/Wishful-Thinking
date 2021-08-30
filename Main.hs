{-
HW 1 - Haskell List Processing and recursion
============================================

This is the first homework assignment for CIS 552. It provides practice with
the basic built-in data structures of Haskell, including lists, tuples and
maybes, as well as recursion and pattern matching.  It also covers the basics
of Haskell code style and test-driven development. If you have not read the
[`Basics`](https://www.cis.upenn.edu/~cis552/current/lectures/stub/01-intro/Basics.html)
module, and completed the associated quiz, you should do that first.

This page is a "literate" Haskell program, meaning that explanation is
interspersed with actual Haskell code. To complete your assignment, access
your private hw01 repo, edit `Main.hs` and submit it through
Canvas/Gradescope.

This file starts by first declaring that we
 are creating a module called `Main` and are using functions defined in the
 modules
 [`Prelude`](https://downloads.haskell.org/~ghc/latest/docs/html/libraries/base-4.14.1.0/Prelude.html),
 [`Test.HUnit`](http://hackage.haskell.org/packages/archive/HUnit/1.6.0.0/doc/html/Test-HUnit.html),
 [`Data.List`](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-List.html)
 and
 [`Data.Char`](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Char.html).

The `Prelude` line imports all except for the functions listed (which you will
write). The module `Prelude` is special in that it is always imported by
default, so the the point of this line is not to import more functions, but
rather to exclude a few functions. (Haskell does not allow functions to be
redefined in the same module.)

The `Test.HUnit` line imports all functions defined in that module. The line
`Data.List` imports all functions from that module, but makes them available
with qualified names, such as `List.intersperse`, etc.
-}

module Main where

-- libraries for Kata problem (only)

import qualified Data.Char as Char
import qualified Data.List as List
import qualified Data.Maybe as Maybe
import Test.HUnit
import qualified Text.Read as Read
import Prelude hiding (concat, reverse, zip, (++))

{-
The main "entry point" for this assignment runs the tests for each homework
problem below. You should not edit this definition. Instead, your goal is to
modify the problems below so that all of the tests pass. Note that the
definitions in Haskell modules do not need to come in any particular order;
here, the main function uses the definitions `testStyle`, `testLists`, etc,
even though their definitions come much later in the file.
-}

main :: IO ()
main = do
  _ <-
    runTestTT $
      TestList
        [ testStyle,
          testLists,
          testWeather,
          testSoccer
        ]
  return ()

{-
Now that we have the preliminaries out of the way, we can start the
actual problems.

Recall that you can load this file into ghci with the command `stack ghci Main.hs`.
Or, you can build the executable first with `stack build` and then run the test
cases above with the command line `stack exec -- hw01`. (For each of these, make
sure that you are in the hw01 subdirectory.)
-}

--------------------------------------------------------------------------------
-- Problem (Good Style)
--------------------------------------------------------------------------------

testStyle :: Test
testStyle =
  "testStyle"
    ~: TestList [tabc, tarithmetic, treverse, tzip]

{-
All of the following Haskell code does what it is supposed to do (i.e. the
tests pass), but it is difficult to read.  Rewrite the following expressions
so that they exactly follow the [style guide](../../styleguide.html).
Be careful: the style guide includes quite a few rules, and we've broken most
of them in what follows!  (You don't need to rewrite the test following each
part, but you do need to make sure that you don't break the code as you
refactor it!)

**NOTE**: Do not change the *name* of any of the top level declarations below,
even if you think that they aren't very good (they aren't). We will be using
automatic testing to ensure that you do not break anything when you rewrite
these functions. On the other hand, local variables (such as function
parameters and those bound by `let` and `where`) can and should be renamed.

**NOTE**: If you have [set up VSCode and hlint](../../haskell-vscode.html)
correctly, your IDE should give you a few hints on how to improve these
functions. But, it won't tell you everything.

-}

-- Part One

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

-- Part Two

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

-- Part Three

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

-- Part Four

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
-- Problem (List library chops)
--------------------------------------------------------------------------------

{-
Define, debug and test the following functions. Some of these functions are
part of the Haskell standard prelude or standard libraries like `Data.List`.
Their solutions are readily available online. You should *not* google for this
code: instead, implement them yourself.

For each part of this problem, you should replace the testcase for that part
based on the description in the comments.  Make sure to test with multiple
inputs using `TestList`. We will be grading your test cases as well as the
correctness and style of your solutions!  HINT: your testing code should
include any tests that we give you in the the comments!

Do *not* use any list library functions in this problem. This includes
any function from the Prelude or from `Data.List` thats take arguments
or returns a result with a list type. Note that `(:)` and `[]` are
data constructors for the list type, not functions, so you are free
to use them.
-}

testLists :: Test
testLists =
  "testLists"
    ~: TestList
      [tminimumMaybe, tstartsWith, tendsWith, ttranspose, tcountSub]

-- Part One

-- | The 'minimumMaybe` function computes the mininum value of a
-- nonempty list. If the list is empty, it returns Nothing.
--
-- >>> minumumMaybe []
-- Nothing
-- >>> minumumMaybe [2,1,3]
-- 1
minimumMaybe :: [Int] -> Maybe Int
minimumMaybe = undefined

tminimumMaybe :: Test
tminimumMaybe =
  "minimumMaybe" ~: (assertFailure "testcases for minimumMaybe" :: Assertion)

-- Part Two

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

-- Part Three

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

-- Part Four

-- | The 'transpose' function transposes the rows and columns of its argument.
-- If the inner lists are not all the same length, then the extra elements
-- are ignored. Note, this is *not* the same behavior as the library version
-- of transpose (i.e. the version of transpose from Data.List).
--
-- >>> transpose [[1,2,3],[4,5,6]]
-- [[1,4],[2,5],[3,6]]
-- >>> transpose []
-- []
-- >>> transpose [[]]
-- []
-- >>> transpose [[3,4,5]]
-- [[3],[4],[5]]
-- >>> transpose [[1,2],[3,4,5]]
-- [[1,3],[2,4]]
-- (WARNING: this one is tricky!)
transpose :: [[a]] -> [[a]]
transpose = undefined

ttranspose :: Test
ttranspose = "transpose" ~: (assertFailure "testcase for transpose" :: Assertion)

-- Part Five

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
-- Data Munging Kata
--------------------------------------------------------------------------------

{-
A Code Kata is an exercise that helps an experienced programmer hone their
skills. The coding exercise is usually not difficult---what is important is
the analysis and design of the problem as well and the practice and repetition
that lead to good coding habits. This exercise comes from website devoted to
[Code Kata](http://codekata.com/kata/kata04-data-munging/)s and is not
specific to Haskell.

Unlike the exercises above, for this problem you are *allowed* to use
functions from Haskell's standard libraries. In particular, you *may* use list
functions from the
[Prelude](https://hackage.haskell.org/package/base-4.14.1.0/docs/Prelude.html),
or from
[Data.List](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-List.html)
in your solution. You may also use functions from
[Data.Char](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Char.html).

This problem is an exercise in three parts to do with real world data. For
that reason, we aren't expecting you to produce a robust solution. You can
expect input that is in a similar format to the data files that we provide
(same number and ordering of columns, same header and footer
layout). However, your code should be able to deal with reasonable changes
(different number of days in a month, different number of teams in the
league).

However, remember that you shouldn't use partial functions. There shouldn't be
an input that causes your program to error. Definitely avoid functions such as
`(!!)`, `read`, or `minimum`.

This problem also is about refactoring, so try hard not to read ahead---do each
of the three parts below in turn and then reflect on your experience.
-}

-- Part One: Weather

{-
In `jul21.dat` (in the repository) you'll find daily weather data for
Philadelphia, PA for July 2021. This data is taken from
[NOAA](http://w2.weather.gov/climate/index.php?wfo=phi).

Your job is to write a program to output the day number (column one) with the
smallest temperature spread (the maximum temperature is the second column,
the minimum the third column).

We've given you the I/O parts of the program---opening the file and then
printing the final result. You need to write the `weather` function below,
that takes the string containing the text of the file and processes it to find
the answer. Your program should work for any text file with the same format as
this one. If the format is different, the behavior is unspecified (i.e. your
program can throw an error, return a garbage string, etc.). We will discuss
better approaches to error handling later in the semester.
-}

weather :: String -> Maybe String
weather str = error "unimplemented"

weatherProgram :: IO ()
weatherProgram = do
  str <- readFile "jul21.dat"
  putStrLn
    ( case weather str of
        Just result -> result
        Nothing -> "Cannot read file"
    )

{-
You should use the (overloaded) `Read.readMaybe` function to help you convert strings into
integers. We've given it a new name and type signature to make it easier to
use.
-}

-- | Use this function to parse Ints
readInt :: String -> Maybe Int
readInt = Read.readMaybe

{-
Here is the test case for this part. If this test fails because it cannot find
the input file, you need to use the `:cd` command in ghci to make sure that
you are in the right directory.
-}

testWeather :: Test
testWeather =
  "weather" ~: do
    str <- readFile "jul21.dat"
    weather str @?= Just "18"

-- Part Two: Soccer League Table

{-
The file `soccer21.dat` contains the results from the English Premier League
 for 2020/2021. This data is taken from
 [SkySports](https://www.skysports.com/premier-league-table/2020).The columns
 labeled "F" and "A" contain the total number of goals scored for and against
 each team in that season (so Liverpool scored 68 goals against opponents, and
 had 42 goals scored against them). Write a program to print the name of the
 team with the smallest (absolute) difference in "for" and "against" goals.

Your program should work with all similar input files (same columns, same info
 in footer).
-}

soccer :: String -> Maybe String
soccer = error "unimplemented"

soccerProgram :: IO ()
soccerProgram = do
  str <- readFile "soccer20.dat"
  putStrLn
    ( case soccer str of
        Just result -> result
        Nothing -> "Cannot read file"
    )

testSoccer :: Test
testSoccer =
  "soccer" ~: do
    str <- readFile "soccer20.dat"
    soccer str @?= Just "Everton"

-- Part Three: DRY Fusion

{-
Now, take the two programs written previously and factor out as much common
code as possible, leaving you with two smaller programs and some kind of
shared functionality.
-}

weather2 :: String -> Maybe String
weather2 = undefined

soccer2 :: String -> Maybe String
soccer2 = undefined

-- Kata Questions

{-
Fill in the strings below with your answers.
-}

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
