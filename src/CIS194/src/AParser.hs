-- |

module AParser where

import Data.Char

newtype Parser a =
  Parser { runParser :: String -> Maybe (a, String) }

satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser f
  where
    f [] = Nothing -- fail on the empty input
    f (x:xs) -- check if x satisfies the predicate
      -- if so, return x along with the remainder
      -- of the input (that is, xs)
      | p x = Just (x, xs)
      | otherwise = Nothing -- otherwise, fail

char :: Char -> Parser Char
char c = satisfy (== c)

posInt :: Parser Integer
posInt = Parser f
  where
    f xs
      | null ns = Nothing
      | otherwise = Just (read ns, rest)
      where (ns, rest) = span isDigit xs

-- Exercise I
first :: (a -> b) -> (a,c) -> (b,c)
first f (a,b) = (f a, b)

instance Functor Parser where
  fmap f (Parser p) = Parser $ fmap (first f) . p
