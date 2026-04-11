
module E1 where

-- Exercise I I~IV
doubleOther :: [Integer] -> [Integer]
doubleOther []           = []
doubleOther (x:xs)       = (if even (length xs) then x else x * 2) : doubleOther xs

digitizeRev :: Integer -> [Integer]
digitizeRev n
  | n <= 0    = []
  | otherwise = (n `mod` 10) : digitizeRev (n `div` 10)

digitize :: Integer -> [Integer]
digitize = reverse . digitizeRev

sumDigits :: [Integer] -> Integer
sumDigits = sum . concatMap digitize

validate :: Integer -> Bool
validate = (== 0) . flip mod 10 . sumDigits . doubleOther . digitize

-- Exercise I V
type Peg = String
type Move = (Peg, Peg)
hanoi :: Integer -> Peg -> Peg -> Peg -> [Move]
hanoi 0 _ _ _ = []
hanoi n a b c = hanoi (n-1) a c b ++ [(a, b)] ++ hanoi (n-1) c b a

-- Exercise I VI
hanoi4 :: Integer -> Peg -> Peg -> Peg -> Peg -> [Move]
hanoi4 0 _ _ _ _ = []
hanoi4 _ _ _ _ _ = [] -- TODO:
