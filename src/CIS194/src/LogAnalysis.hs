-- | OPTIONS_GHC -Wall -xc

module CIS194.LogAnalysis where
import Log
import Data.Char (isDigit, digitToInt)
import Data.Maybe (fromJust)

-- Exercise I

skipWhitespaces :: String -> String
skipWhitespaces [] = []
skipWhitespaces (' ': rest) = skipWhitespaces rest
skipWhitespaces str = str

readIntHelper :: String -> Maybe Int -> (Maybe Int, String)
readIntHelper [] Nothing  = (Nothing, [])
readIntHelper [] (Just n) = (Just n, [])
readIntHelper str@(c:rs) Nothing
  | isDigit c = readIntHelper rs (Just (digitToInt c))
  | otherwise = (Nothing, str)
readIntHelper str@(c:rs) (Just n)
  | isDigit c = readIntHelper rs (Just (n * 10 + digitToInt c))
  | otherwise = (Just n, str)

readInt :: String -> (Maybe Int, String)
readInt s = readIntHelper (skipWhitespaces s) Nothing

isNothing :: Maybe a -> Bool
isNothing Nothing = True
isNothing _ = False

parseString :: String -> LogMessage
parseString str@(e: ' ': rest)
  | isNothing _n = Unknown str
  | e == 'E' = case m of
       Just v -> LogMessage (Error (fromJust _n)) v (skipWhitespaces __rest)
       Nothing -> Unknown str
  | e == 'W' = LogMessage Warning (fromJust _n) (skipWhitespaces __rest)
  | e == 'I' = LogMessage Info (fromJust _n) (skipWhitespaces __rest)
  | otherwise = Unknown str
  where (_n, _rest) = readInt rest
        (m, __rest) = readInt _rest
parseString str = Unknown str

splitByHelper :: Eq a => [a] -> a -> [a] -> [[a]]
splitByHelper [] _ l = [reverse l]
splitByHelper (e: rs) c l
  | e == c = reverse l : splitByHelper rs c []
  | otherwise = splitByHelper rs c (e:l)

splitBy :: Eq a => [a] -> a -> [[a]]
splitBy lst c = splitByHelper lst c []

parseHelper :: [String] -> [LogMessage]
parseHelper = map parseString

parse :: String -> [LogMessage]
parse str = parseHelper (splitBy str '\n')

-- Exercise II
insert :: LogMessage -> MessageTree -> MessageTree
insert (Unknown _) tree = tree

main :: IO ()
main = do
  res <- testParse parse 10 "error.log"
  print res
  return ()
