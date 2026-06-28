-- |

module AParser where

import Data.Char
import Control.Applicative
import Control.Monad

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
  -- fmap :: (a -> b) -> f a -> f b
  fmap f (Parser p) = Parser $ fmap (first f) . p
  -- p :: String -> Maybe (a, Str)
  -- f :: a -> b
  -- first f :: (a, c) -> (b, c)
  -- fmap :: ((a, b) -> (b, c)) -> f (a, b) -> f (b, c)
  -- fmap (first f) :: f (a, b) -> f (b, c)
  -- \str -> fmap (first f) (p str)

-- Exercise II
instance Applicative Parser where
  -- pure :: Applicative f => a -> f a
  pure a = Parser (\x -> Just (a, x))
  -- pure :: a -> Parser a

  -- <*> :: f (a -> b) -> f a -> f b
  (<*>) (Parser p1) (Parser f2) = Parser $ \src -> do
    (h, src') <- p1 src
    (x, src'') <- f2 src'
    pure (h x, src'')

-- Exercise III
abParser :: Parser (Char, Char)
abParser = (,) <$> char 'a' <*> char 'b'
-- (,) :: a -> b -> (a, b)
-- (,) :: a -> (b -> (a, b))
-- char :: Char -> Parser Char
-- char c :: Parser Char
-- (<$>) :: (a -> b) -> f a -> f b
-- (<$>) :: (a -> b) -> Parser a -> Parser b
-- (<*>) :: f (a -> b) -> f a -> f b
-- (,) <$> :: Parser a -> Parser (b -> (a, b))
-- (,) <$> char 'a' :: Parser (b -> (a, b))
-- (,) <$> char 'a' <*> :: Parser a -> Parser (a, b)

abParser_ :: Parser ()
abParser_ = (\_ _ -> ()) <$> char 'a' <*> char 'b'

intPair :: Parser [Integer]
intPair = (\x _ z -> [x, z]) <$> posInt <*> char ' ' <*> posInt

-- Exercise IV
instance Alternative Parser where
  empty = Parser (const Nothing)
  Parser a <|> Parser b = Parser (\str -> a str <|> b str)

-- Exercise V
intOrUppercase :: Parser ()
intOrUppercase =  void posInt <|> void (satisfy isUpper)
