-- |

module Golf where

-- Exercise I

skips :: [a] -> [[a]]
skips lst = [
  [ s | (i, s) <- zip [1..] lst , i `mod` n == 0]
  | n <- [1..length lst]
  ]


-- Exercise II

localMaxima :: [Integer] -> [Integer]
localMaxima []        = []
localMaxima [_]       = []
localMaxima [_, _]    = []
localMaxima (a: b: c: rs)
  | a < b && b > c    = b : localMaxima (b: c: rs)
  | otherwise         = localMaxima (b: c: rs)

-- Exercise III

histogram :: [Integer] -> String
histogram lst = helper nl
  where
    l = [ sum [ 1 | i <- lst, i == n ] | n <- [0..9] ]
    m = maximum l
    nl = [ replicate (m - n) ' ' ++ replicate n '*' | n <- l ]
    helper :: [[Char]] -> String
    helper [[], [], [], [], [], [], [], [], [], []] = "==========\n123456789\n"
    helper [x0:x0s,
            x1:x1s,
            x2:x2s,
            x3:x3s,
            x4:x4s,
            x5:x5s,
            x6:x6s,
            x7:x7s,
            x8:x8s,
            x9:x9s] =
      x0:x1:x2:x3:x4:x5:x6:x7:x8:x9: '\n':
      helper [x0s,x1s,x2s,x3s,x4s,x5s,x6s,x7s,x8s,x9s]
    helper _ = []

histogram2 :: [Integer] -> String
histogram2 xs =
  unlines ([[[' ', '*'] !! fromEnum (n >= h) | n <- c ] | h <- [m, m-1 .. 1]]
          ++ ["==========", "0123456789"])
  where
    c = map (\d -> length (filter (== d) xs)) [0..9]
    m = maximum (0:c)
