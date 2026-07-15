{-
---
fulltitle: "Optional exercise: SecretCode"
date: September 9, 2024
---

This module is for those who are completely new to functional programming.
It is an optional exercise, and will give you a chance to practice before
the first in-class exercise. If you have questions about this exercise,
please ask on the Ed platform or in office hours.
-}

module SecretCode where

-- https://www.seas.upenn.edu/~cis5520/current/lectures/stub/02-higherorder/SecretCode.html

{-
OK, we're going to write a Haskell program to encode and decode text files
using a secret code.

We'll call it the Brown Fox code.  Here's how it works:

    - Replace each letter according to the following correspondence:

            "abcdefghijklmnopqrstuvwxyz"
        to  "thequickbrownfxjmpsvlazydg"

      But leave any non-letter characters alone.

    - Then reverse the order of the lines in the file.

We start by importing some libraries that we might want to use in our solution.
-}

import Data.Char
import Data.Maybe
import System.FilePath -- library for manipulating FilePaths.

{-
First, we make a lookup list (aka association list) containing each pair of
corresponding letters:
-}

code :: [(Char, Char)]
code = zip ['a' .. 'z'] cypher ++ zip ['A' .. 'Z'] (map toUpper cypher)
  where
    cypher :: String
    cypher = "thequickbrownfxjmpsvlazydg"

{-
Now, how can we use this lookup list?

Association lists seem like they are probably a pretty common idiom,
so let's check Hoogle to see if there is a function to look things up
in them automatically...

What type would such a function have?  In our case, we want something
like:

        [(Char,Char)] -> Char -> Char

That is, the function should take a list that maps `Char`s to `Char`s and a
specific `Char`, and it should return the corresponding `Char` from the list
(if it is present).  The first hit on
[Hoogle](https://hoogle.haskell.org/?hoogle=%5B(Char%2CChar)%5D%20-%3E%20Char%20-%3E%20Char&scope=set%3Ahaskell-platform)
for this type is the standard library function `lookup`:

       lookup :: Eq a => a -> [(a,b)] -> Maybe b

Ignoring the `Eq a` part for now (we'll talk about it next week), this
type makes a lot of sense. It's a bit more general than what we
searched for, allowing the function to be called with different types
for the "keys" and "values" of the association list to take on
different, and `lookup` also returns a `Maybe` type because the thing
we're looking up might not be in the list.

(Recall that a `Maybe a` is either `Just v` for some v of type `a`, or
Nothing.)

So, we can use `lookup` to encode a particular character. If we don't have a mapping for a
character in our code, (i.e. for punctuation) we should leave it alone.
-}

-- >>> encodeChar 'a'
-- 't'
-- >>> encodeChar '.'
-- '.
encodeChar :: Char -> Char
encodeChar c = undefined

{-
We'll next need a way to encode a whole line of text.  Of course, remembering
that `String`s are just lists of `Char`s, there is a perfect higher-order
function in `HigherOrder` that we can use:
-}

-- >>> encodeLine "abc defgh"
-- "the quick"
encodeLine :: String -> String
encodeLine = undefined

{-
And, if we have a list of lines, we can use the same higher-order function
to encode all of them.
-}

-- >>> encodeLines ["abc", "defgh"]
-- ["the","quick"]
encodeLines :: [String] -> [String]
encodeLines = undefined

{-
Finally, we need a function to encode a whole file.  Remember, we want to
reverse the order of the lines (so that the last line is first, and so on),
then swap the letters in each. The
[`reverse`](https://hackage.haskell.org/package/base-4.15.0.0/docs/Prelude.html#v:reverse)
function in the standard library will come in handy.

However, we also need a way to break a file into
lines - we could do this manually by folding over the `String` and checking
for newlines, but this seems like a commonly used function, let's check
[Hoogle](https://hoogle.haskell.org/?hoogle=String+-%3E+%5BString%5D&scope=package%3Abase)
instead.  Indeed, we find several functions of type

       String -> [String]

in the standard library, and the first one, called `lines` looks like it does what we want.  Furthermore, its
counterpart [unlines](https://hoogle.haskell.org/?hoogle=String%20-%3E%20%5BString%5D&scope=package%3Abase)
of type

       [String] -> String

will put the lines back together into one big string.

So... lets use these functions! This definition should not be recursive. Instead, it should put together
the functions that we already have to encode the entire file.
-}

encodeContent :: String -> String
encodeContent = undefined

-- >>> encodeContent "abc\n defgh\n"
-- " quick\nthe\n"

{-
Don't forget that the . operator is function composition.  That is:

      (f . g) x = f (g x)

See if you can simplify your definition of `encodeContent` using this
operator.

OK, now let's construct an IO action that actually reads in a file
from disk, encodes it, and writes it back out.  We can look at the
Haskell [Prelude](https://hackage.haskell.org/package/base-4.12.0.0/docs/Prelude.html#v:readFile)
to find functions for reading and writing files.

        readFile  :: FilePath -> IO String
        writeFile :: FilePath -> String -> IO ()

Your function should read from the file 'f', but shouldn't overwrite the file
with the encoded version. In Haskell, `FilePath`s can be manipulated with
functions in the [System.FilePath
library](https://www.stackage.org/haddock/lts-18.10/filepath-1.4.2.1/System-FilePath-Posix.html).
For example, we can use the `replaceExtension` function to create a new file
name for output.
-}

encodeFile :: FilePath -> IO ()
encodeFile f =
  if takeExtension f == "code"
    then putStrLn "Cannot encode .code files"
    else do
      let outFilePath = replaceExtension f "code"
      undefined

{-
Finally, let's put it all together into a "main" function that reads in
a file name from the standard input stream and swizzles it:
-}

main :: IO ()
main = do
  putStrLn "What file shall I encode?"
  fn <- getLine
  encodeFile fn
  putStrLn "All done!"

{-
Because this main function works in the IO monad, we need to use ghci to see its result.
In the terminal, you can use the command

      stack ghci SecretCode.hs

to automatically start ghci and load the module. Then you can run the main function at the
ghci prompt by just typing its name.

      ghci> main
-}
