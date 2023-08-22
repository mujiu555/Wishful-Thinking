module Main where

import HW01 
import Test.HUnit ( runTestTT, Test(TestList) )

{-

This module is the "entry point" for this assignment and runs the tests 
for each homework problem. You should not edit this file. 
Instead, your goal is to complete each problem in the HW01 module 
so that all of the tests pass. 

-}

main :: IO ()
main = do
    putStrLn "Runing test cases for HW01 ..."
    _ <- runTestTT $ TestList [ testStyle,
                                testLists,
                                testHO,
                                testFoldr,
                                testWeather,
                                testSoccer ]
    return ()
