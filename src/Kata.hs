--------------------------------------------------------------------------------
-- Problem (Data Munging Kata)
--------------------------------------------------------------------------------

module Kata where

-- libraries

import Data.Char qualified as Char
import Data.List qualified as List
import Data.Maybe qualified as Maybe
import Text.Read (readMaybe)

-- Part One: Weather

-- >>> weatherProgram "dat/jul24.dat"
-- "12"
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

-- Part Two: Soccer League Table

-- >>> soccerProgram "dat/soccer23.dat"
-- "West Ham United"

soccer :: String -> Maybe String
soccer = error "unimplemented"

soccerProgram :: String -> IO String
soccerProgram file = do
  str <- readFile file
  return $ case soccer str of
    Just result -> result
    Nothing -> "Cannot read file"

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
