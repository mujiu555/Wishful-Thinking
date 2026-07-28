{-
---
fulltitle: "In class exercise: IOExercise"
---

In-class exercise (IO Monad)
-}

module IOExercise where

import System.FilePath

{-
Rewrite these programs so that they do not use 'do'.
(Make sure that you do not change their behavior!)
-}

simpleProgram :: IO ()
simpleProgram =
  putStrLn "This is a simple program that does IO." >>
  putStrLn "What is your name?" >>
  getLine >>=
  (\inpStr -> putStrLn ("Welcome to Haskell, " ++ inpStr ++ "!"))

lengthProgram :: IO Int
lengthProgram =
  let x = length ([1, 2, 3, 4, 5, 6] :: [Int]) in
    putStrLn ("The length of the list is" ++ show x) >>
    return x

{-
>
-}

anotherProgram :: IO ()
anotherProgram =
  putStrLn "What is your name?" >>
  getLine >>= (\inpStr  ->
    if inpStr == "Haskell"
      then
        putStrLn "You rock!" >>
        return ()
      else (putStrLn ("Hello " ++ inpStr)) >>
    putStrLn "That's all!")
