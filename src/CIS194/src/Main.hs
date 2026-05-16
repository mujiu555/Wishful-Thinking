
module Main where

import JoinList
import Editor
import Scrabble
import Sized


main :: IO ()
main = do
  let buffer = Empty :: JoinList (Score, Size) String
  runEditor editor buffer
  return ()
