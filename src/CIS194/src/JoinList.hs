-- |

module JoinList where

import Sized
import Scrabble
import Buffer

data JoinList m a = Empty
  | Single m a
  | Append m (JoinList m a) (JoinList m a)
  deriving (Eq, Show)

jlToList :: JoinList m a -> [a]
jlToList Empty = []
jlToList (Single _ a) = [a]
jlToList (Append _ l r) = jlToList l ++ jlToList r

-- Exercise I

tag :: Monoid m => JoinList m a -> m
tag Empty          = mempty
tag (Single m _)   = m
tag (Append m _ _) = m

(+++) :: Monoid m => JoinList m a -> JoinList m a -> JoinList m a
(+++) l r = Append (mappend (tag l) (tag r)) l r

-- Exercise II
indexJ :: (Sized m, Monoid m) => Int -> JoinList m a -> Maybe a
indexJ idx _ | idx < 0           = Nothing
indexJ _ Empty                   = Nothing
indexJ 0 (Single _ a)            = Just a
indexJ _ (Single _ _)            = Nothing
indexJ idx (Append _ a b)
  | getSize (size (tag a)) > idx = indexJ idx a
  | otherwise                    = indexJ (idx - getSize (size (tag a))) b

dropJ :: (Sized m, Monoid m) => Int -> JoinList m a -> JoinList m a
dropJ cnt l | cnt <= 0           = l
dropJ _ Empty                    = Empty
dropJ cnt l@(Single _ _)
  | cnt > 0                      = Empty
  | otherwise                    = l
dropJ cnt (Append _ a b)
  | getSize (size (tag a)) > cnt = dropJ cnt a +++ b
  | otherwise                    = dropJ (cnt - getSize (size (tag a))) b

takeJ :: (Sized m, Monoid m) => Int -> JoinList m a -> JoinList m a
takeJ cnt _ | cnt <= 0           = Empty
takeJ _ Empty                    = Empty
takeJ cnt l@(Single _ _)
  | cnt > 0                      = l
  | otherwise                    = Empty
takeJ cnt (Append _ a b)
  | getSize(size (tag a)) > cnt  = takeJ cnt a
  | otherwise                    = a +++ takeJ (cnt - getSize (size (tag a))) b

-- Exercise III
scoreLine :: String -> JoinList Score String
scoreLine s = Single (scoreString s) s

-- Exercise IV

-- 将 String 转换为 JoinList (Score, Size) String
fromStringToJoinList :: String -> JoinList (Score, Size) String
fromStringToJoinList str =
    let linesList = lines str
    in foldr (\line acc ->
        let annotation = (scoreString line, Size 1)
        in Single annotation line +++ acc
    ) Empty linesList

-- 获取文档总分
documentScore :: JoinList (Score, Size) String -> Int
documentScore doc = case tag doc of
    (Score s, _) -> s

-- 获取文档总行数
documentLines :: JoinList (Score, Size) String -> Int
documentLines doc = case tag doc of
    (_, Size n) -> n

-- 替换指定行
replaceLineJ :: Int -> String -> JoinList (Score, Size) String -> JoinList (Score, Size) String
replaceLineJ n newLine doc
    | n < 0 || n >= documentLines doc = doc
    | otherwise =
        let before = takeJ n doc
            rest = dropJ n doc
            after = dropJ 1 rest
            newChunk = Single (scoreString newLine, Size 1) newLine
        in before +++ newChunk +++ after

-- Buffer 实例
instance Buffer (JoinList (Score, Size) String) where
  toString = concat . jlToList
  -- value: 返回文档的总 Scrabble 分数
  value = documentScore

  -- numLines: 返回文档的总行数
  numLines = documentLines

  -- line: 返回指定行的内容
  line = indexJ

  -- replaceLine: 替换指定行的内容
  replaceLine = replaceLineJ

  -- fromString: 从字符串创建文档
  fromString = fromStringToJoinList
