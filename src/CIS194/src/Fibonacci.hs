-- |

module Fibonacci where

-- Exercise I
fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib 2 = 1
fib n = fib (n-1) + fib (n-2)

fibs1 :: [Integer]
fibs1 = map fib [0..]

-- Exercise II
fibs2 :: [Integer]
fibs2 = 0: 1: zipWith (+) fibs2 (drop 1 fibs2)
{-
fibs2 = go 1 1
  where
    go a b = a : go b (a+b)
-}

-- Exercise III
data Stream a =
  Cons a (Stream a)

instance Show a => Show (Stream a) where
  show = show . take 20 . streamToList

streamToList :: Stream a -> [a]
streamToList (Cons a b) = a : streamToList b

-- Exercise IV
streamRepeat :: a -> Stream a
streamRepeat a = Cons a (streamRepeat a)

streamMap :: (a -> b) -> Stream a -> Stream b
streamMap f (Cons a b) = Cons (f a) (streamMap f b)

streamFromSeed :: (a -> a) -> a -> Stream a
streamFromSeed f v = Cons v (streamFromSeed f (f v))

-- Exercise V
nats :: Stream Integer
nats = streamFromSeed (+ 1) (1 :: Integer)

interleaveStreams :: Stream a -> Stream a -> Stream a
interleaveStreams (Cons l xs) ys = Cons l (interleaveStreams ys xs)

ruler :: Stream Integer
ruler = rulerFrom 0
  where rulerFrom n = interleaveStreams (streamRepeat n) (rulerFrom (n + 1))

-- Exercise VI
x :: Stream Integer
x =  Cons 0 (Cons 1 (streamRepeat 0))

instance Num (Stream Integer) where
  fromInteger                   = flip Cons (streamRepeat 0)
  negate                        = streamMap negate
  (+) (Cons a xs) (Cons y ys)   = Cons (a + y) (xs + ys)
  (*) (Cons a xs) b@(Cons y ys) = Cons (a * y) (streamMap (* a) ys + (xs *b))
  abs                           = streamMap abs
  signum                        = streamMap (\a -> div a (abs a))

instance Fractional (Stream Integer) where
  (/) (Cons a xs) (Cons b ys) = q
    where
      q = Cons (div a b) ((xs - q * ys) / fromInteger b)
  fromRational _ = x -- NOTE: this is not what it intends to be, just for not implementing it

fibs3 :: Stream Integer
fibs3 = x / (1 - x - x ^ (2:: Integer))

-- Exercise VII:
