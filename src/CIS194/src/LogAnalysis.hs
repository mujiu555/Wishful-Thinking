-- | OPTIONS_GHC -Wall -xc

module LogAnalysis where

import Data.Char (isDigit, digitToInt)
import Data.Maybe (fromJust)

import Log

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

height :: MessageTree -> Int
height Leaf = 0
height (Node lt _ rt) = 1 + max (height lt) (height rt)

balance :: MessageTree -> Int
balance Leaf = 0
balance (Node lt _ rt) = height lt - height rt

rotate :: MessageTree -> MessageTree
rotate Leaf = Leaf
rotate tree@(Node ltree _ rtree)
  | balance tree > 1 && balance ltree > 0  = right tree
  | balance tree < -1 && balance rtree < 0 = left tree
  | balance tree > 1 && balance ltree < 0  = leftright tree
  | balance tree < -1 && balance rtree > 0 = rightleft tree
  | otherwise                        = tree
  where
    right (Node (Node llt lv rlt) v rt) = Node llt lv (Node rlt v rt)
    right t = t
    left (Node lt v (Node lrt rv rrt)) = Node (Node lt v lrt) rv rrt
    left t = t
    leftright (Node (Node Leaf lv (Node lrlt rlv rrlt)) v Leaf) =
      Node (Node Leaf lv lrlt) rlv (Node rrlt v Leaf)
    leftright t = t
    rightleft (Node Leaf v (Node (Node llrt lrv rlrt) rv Leaf)) =
      Node (Node Leaf v rlrt) lrv (Node llrt rv Leaf)
    rightleft t = t

insert :: LogMessage -> MessageTree -> MessageTree
insert (Unknown _) tree = tree
insert msg Leaf = Node Leaf msg Leaf
insert msg (Node lt (Unknown _) rt) = (Node lt msg rt)
insert msg@(LogMessage _ timestamp _) (Node lt omsg@(LogMessage _ v _) rt)
  | v > timestamp = rotate (Node (insert msg lt) omsg rt)
  | v < timestamp = rotate (Node lt omsg (insert msg rt))
  | otherwise     = rotate (Node lt msg rt)

build :: [LogMessage] -> MessageTree
build = foldr insert Leaf

inOrder :: MessageTree -> [LogMessage]
inOrder Leaf           = []
inOrder (Node lt v rt) = inOrder lt ++ [v] ++ inOrder rt

whatWentWrong :: [LogMessage] -> [String]
whatWentWrong s = [ info | (LogMessage log_level _ info) <- s,
                    (case log_level of
                       Info -> False
                       Warning -> False
                       Error i -> i > 50
                    )]
