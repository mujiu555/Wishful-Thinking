module Main where

import Test.HUnit ( runTestTT, Test(TestList) )
import qualified Test.DocTest as DT


{-

This module is the "entry point" for this assignment and runs the tests 
for each homework problem. You should not edit this file. 
Instead, your goal is to complete each problem in the `HW01` and `Kata` modules 
so that all of the tests pass. You can run this file with the command 

     stack run

at the terminal.

-}

main :: IO ()
main = do
    putStrLn "Running test cases ..."
    DT.doctest ["-isrc"]
    return ()
