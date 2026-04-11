
module Main where


import Golf
import System.Random
import Data.Time

main :: IO ()
main = let lst = take 100000 (randomRs (0, 9) (mkStdGen 42)) in do
  s1 <- getCurrentTime
  return (histogram lst)
  t1 <- getCurrentTime

  s2 <- getCurrentTime
  return (histogram2 lst)
  t2 <- getCurrentTime

  print (diffUTCTime t1 s1)
  print (diffUTCTime t2 s2)

  return ()
