
-- Exercise I~IV
doubleOther :: [Int] -> [Int]
doubleOther []           = []
doubleOther (x:xs)       = (if even (length xs) then x else x * 2) : doubleOther xs

digitizeRev :: Int -> [Int]
digitizeRev n
  | n <= 0    = []
  | otherwise = (n `mod` 10) : digitizeRev (n `div` 10)

digitize :: Int -> [Int]
digitize n = reverse (digitizeRev n)

sumDigits :: [Int] -> Int
sumDigits lst = sum (concat [digitize x | x <- lst])

validate :: Int -> Bool
validate n = mod (sumDigits (doubleOther (digitize n))) 10 == 0

-- Exercise V
type Peg = String
type Move = (Peg, Peg)
hanoi :: Integer -> Peg -> Peg -> Peg -> [Move]
hanoi 0 _ _ _ = []
hanoi n a b c = hanoi (n-1) a c b ++ [(a, b)] ++ hanoi (n-1) c b a
