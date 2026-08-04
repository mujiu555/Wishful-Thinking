-- | A small, applicative parsing library
module ParserCombinators
  ( Parser,
    doParse,
    get,
    eof,
    filter,
    parse,
    parseFromFile,
    satisfy,
    alpha,
    digit,
    upper,
    lower,
    space,
    char,
    string,
    int,
    chainl1,
    chainl,
    choice,
    between,
    sepBy1,
    sepBy,
  )
where

import Control.Applicative (Alternative (..))
import Control.Monad (guard)
import Data.Char (isAlpha, isDigit, isLower, isSpace, isUpper)
import System.IO (IOMode (ReadMode), hGetContents, openFile)
import Prelude hiding (filter)

---------------------------------------------------------------
---------------------------------------------------------------
-- definition of the parser *abstract* type
-- The `P` data constructor is not exported by this library
-- so clients cannot know how the `Parser` type is implemented
-- Instead, clients *must* use the functions defined in this
-- file to construct and use parsers.
newtype Parser a = P {doParse :: String -> Maybe (a, String)}

instance Functor Parser where
  fmap :: (a -> b) -> Parser a -> Parser b
  fmap f p = P $ \s -> do
    (c, cs) <- doParse p s
    return (f c, cs)

instance Applicative Parser where
  pure :: a -> Parser a
  pure x = P $ \s -> Just (x, s)
  (<*>) :: Parser (a -> b) -> Parser a -> Parser b
  p1 <*> p2 = P $ \s -> do
    (f, s') <- doParse p1 s
    (x, s'') <- doParse p2 s'
    return (f x, s'')

instance Alternative Parser where
  empty :: Parser a
  empty = P $ const Nothing
  (<|>) :: Parser a -> Parser a -> Parser a
  p1 <|> p2 = P $ \s -> doParse p1 s `firstJust` doParse p2 s
    where
      firstJust :: Maybe a -> Maybe a -> Maybe a
      firstJust (Just x) _ = Just x
      firstJust Nothing y = y

-- There is no Monad instance for Parser so that you will be
-- forced to practice with `(<*>)`.

-- | Return the next character from the input
get :: Parser Char
get = P $ \s -> case s of
  (c : cs) -> Just (c, cs)
  [] -> Nothing

-- | This parser *only* succeeds at the end of the input.
eof :: Parser ()
eof = P $ \s -> case s of
  [] -> Just ((), [])
  _ : _ -> Nothing

-- | Filter the parsing results by a predicate
filter :: (a -> Bool) -> Parser a -> Parser a
filter f p = P $ \s -> do
  (c, cs) <- doParse p s
  guard (f c)
  return (c, cs)

---------------------------------------------------------------
---------------------------------------------------------------
-- After this point, the rest of the file treats the Parser
-- type as abstract. i.e., it does not use the `P` data
-- constructor, but instead defines all of the functions below
-- in terms of the definitions above.
---------------------------------------------------------------
---------------------------------------------------------------

type ParseError = String

-- | Use a parser for a particular string. Note that this parser
-- combinator library doesn't support descriptive parse errors, but we
-- give it a type similar to other Parsing libraries.
parse :: Parser a -> String -> Either ParseError a
parse parser str = case doParse parser str of
  Nothing -> Left "No parses"
  Just (a, _) -> Right a

-- | parseFromFile p filePath runs a string parser p on the input
-- read from filePath using readFile. Returns either a
-- ParseError (Left) or a value of type a (Right).
parseFromFile :: Parser a -> String -> IO (Either ParseError a)
parseFromFile parser filename = do
  handle <- openFile filename ReadMode
  str <- hGetContents handle
  pure $ parse parser str

-- | Return the next character if it satisfies the given predicate
satisfy :: (Char -> Bool) -> Parser Char
satisfy p = filter p get

-- | Parsers for specific sorts of characters
alpha, digit, upper, lower, space :: Parser Char
alpha = satisfy isAlpha
digit = satisfy isDigit
upper = satisfy isUpper
lower = satisfy isLower
space = satisfy isSpace

-- | Parses and returns the specified character
-- succeeds only if the input is exactly that character
char :: Char -> Parser Char
char c = satisfy (c ==)

-- | Parses and returns the specified string.
-- Succeeds only if the input is the given string
string :: String -> Parser String
string = foldr (\c p -> (:) <$> char c <*> p) (pure "")

-- | succeed only if the input is a (positive or negative) integer
int :: Parser Int
int = read <$> ((++) <$> string "-" <*> some digit <|> some digit)

-- | Parses one or more occurrences of @p@ separated by bindary operator
-- parser @pop@.  Returns a value produced by a /left/ associative application
-- of all functions returned by @pop@.
-- See the end of the Parsers lecture for explanation of this operator.
chainl1 :: Parser a -> Parser (a -> a -> a) -> Parser a
p `chainl1` pop = foldl comb <$> p <*> rest
  where
    comb x (op, y) = x `op` y
    rest = many ((,) <$> pop <*> p)

-- | @chainl p pop x@ parses zero or more occurrences of @p@, separated by @pop@.
-- If there are no occurrences of @p@, then @x@ is returned.
chainl :: Parser b -> Parser (b -> b -> b) -> b -> Parser b
chainl p pop x = chainl1 p pop <|> pure x

-- | Combine all parsers in the list (sequentially)
choice :: [Parser a] -> Parser a
choice = foldr (<|>) empty

-- | @between open close p@ parses @open@, followed by @p@ and finally
--   @close@. Only the value of @p@ is returned.
between :: Parser open -> Parser a -> Parser close -> Parser a
between open p close = open *> p <* close

-- | @sepBy p sep@ parses zero or more occurrences of @p@, separated by @sep@.
--   Returns a list of values returned by @p@.
sepBy :: Parser a -> Parser sep -> Parser [a]
sepBy p sep = sepBy1 p sep <|> pure []

-- | @sepBy1 p sep@ parses one or more occurrences of @p@, separated by @sep@.
--   Returns a list of values returned by @p@.
sepBy1 :: Parser a -> Parser sep -> Parser [a]
sepBy1 p sep = (:) <$> p <*> many (sep *> p)
