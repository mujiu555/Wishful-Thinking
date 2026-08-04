{-
---
fulltitle: Parsing with Applicative Functors
date: November 4, 2024
---
-}

module Parsers where

import Control.Applicative
import Control.Monad (guard)
import Data.Char (isAlpha, isDigit, ord)
import Text.Read (readMaybe)
import Prelude hiding (filter)

{-
What is a Parser?
-----------------

A parser is a piece of software that takes a raw `String` (or sequence of
bytes/characters) and returns some structured object -- for example, a list
of options, an XML tree or JSON object, a program's Abstract Syntax Tree, and
so on.  Parsing is one of the most basic computational tasks.

For example, we use parsers in:

- Shell Scripts (command-line options)
- Web Browsers (duh!)
- Games (level descriptors)
- Routers (packets)
- etc.

(Indeed I defy you to find any serious system that does *not* do some
parsing somewhere!)

The simplest way to think of a parser is as a function -- i.e., its
type should be roughly this:

~~~~~{.haskell}
type Parser = String -> StructuredObject
~~~~~

Composing Parsers
-----------------

The usual way to build a parser is by specifying a grammar and using a
parser generator (e.g., yacc, bison, antlr) to create the actual
parsing function. Despite its advantages, one major limitation of the
grammar-based approach is its lack of modularity. For example, suppose
we have two kinds of primitive values, `Thingy` and `Whatsit`.

    Thingy : ...rule...   { ...action... } ;

    Whatsit : ...rule...  { ...action... } ;

If we want a parser for *sequences of* `Thingy` and `Whatsit` we have
to painstakingly duplicate the rules:

    Thingies : Thingy Thingies  { ... }
               EmptyThingy      { ... } ;

    Whatsits : Whatsit Whatsits { ... }
               EmptyWhatsit     { ... } ;

That is, the languages in which parsers are usually described are
lacking in features for modularity and reuse.

In this lecture, we will see how to *compose* mini-parsers for
sub-values to get bigger parsers for complex values.

To do so, we will generalize the above parser type a little bit, by
noting that a (sub-)parser need not (indeed, in general will not)
consume *all* of its input, in which case we need to have the parser
return the unconsumed part of its input:

~~~~~{.haskell}
type Parser = String -> (StructuredObject, String)
~~~~~

Of course, it would be silly to have different types for parsers for
different kinds of structured objects, so we parameterize the `Parser`
type over the type of structured object that it returns:

~~~~~{.haskell}
type Parser a = String -> (a, String)
~~~~~

One last generalization is to observe that not all strings are
parseable. Therefore, we allow a parser to fail by wrapping the result in Maybe.

~~~~~{.haskell}
type Parser a = String -> Maybe (a, String)
~~~~~

As the last step, let's wrap this type definition up as a `newtype` and
define a record accessor to let us conveniently extract the parser:
-}

newtype Parser a = P {doParse :: String -> Maybe (a, String)}

-- >>> :t doParse
-- doParse :: Parser a -> String -> Maybe (a, String)

{-
This type definition will make sure that we keep parsers distinct from other
values of this type and, more importantly, will allow us to make parsers an
instance of one or more typeclasses, if this turns out to be convenient
(spoiler alert, it will!).

Below, we will define a number of operators on the `Parser` type, which will
allow us to build up descriptions of parsers compositionally.  The actual
parsing happens when we use a parser by applying it to an input string, using
`doParse`.

Now, the parser type might remind you of something else... Remember this?

~~~~~{.haskell}
newtype State s a = S { runState :: s -> (a, s) }
~~~~~

Indeed, a `Parser`, like a state transformer, is a monad! There are good
definitions of the `return` and `(>>=)` functions.

However, most of the time, we don't need the full monadic structure for parsing.
Just deriving the applicative operators for this type will allow us to parse
any context-free grammar. So in the material below, keep your eye out for
\*applicative* structure for this type.

Now all we have to do is build some parsers!

We'll start with some primitive definitions, and then generalize.

Parsing a Single Character
--------------------------

Here's a *very* simple character parser that returns the first `Char`
from a (nonempty) string.  Recall the parser type:

~~~~~{.haskell}
newtype Parser a = P { doParse :: String -> Maybe (a, String) }
~~~~~

So we need a function that pattern matches its argument, and pulls out
the first character of the string, if there is one. There is at most one unique
character at the beginning of the String, so in the successful case we return
a single result of that character and the rest of the (unparsed) string.
-}

get :: Parser Char
get = P $ \s -> case s of
  (c : cs) -> Just (c, cs)
  [] -> Nothing

{-
Try it out!

-}

-- >>> doParse get "hey!"

-- >>> doParse get ""

{-
See if you can modify the above to produce a parser that looks at the first
char of a (nonempty) string and interprets it as an int in the range
0-9. (Hint: remember the `readMaybe` function.)
-}

oneDigit :: Parser Int
oneDigit = undefined

-- >>> doParse oneDigit "1"
-- Just (1,"")

-- >>> doParse oneDigit "12"
-- Just (1,"2")

-- >>> doParse oneDigit "hey!"
-- Nothing

{-
And here's a parser that looks at the first char of a string and interprets it
as the unary negation operator, if it is `'-'`, and an identity function if it
is `'+'`.
-}

oneOp :: Parser (Int -> Int)
oneOp = P $ \s -> case s of
  ('-' : cs) -> Just (negate, cs)
  ('+' : cs) -> Just (id, cs)
  _ -> Nothing

{-
Can we generalize this pattern? What if we pass in a function that specifies whether
the character is of interest?  The `satisfy` function constructs a parser that succeeds
if the first character satisfies the predicate.

-}

satisfy :: (Char -> Bool) -> Parser Char
satisfy f = undefined

-- >>>  doParse (satisfy isAlpha) "a"
-- Just ('a',"")

-- >>> doParse (satisfy isUpper) "a"
-- Nothing

--    SPOILER SPACE
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |
--     |

{-
Here's how I implemented `satisfy`, taking advantage of the Maybe monad. (The
`do` notation below is syntactic sugar for the `Maybe` monad's bind operation.)
-}

satisfy' :: (Char -> Bool) -> Parser Char
satisfy' f = P $ \s -> do
  (c, cs) <- doParse get s
  guard (f c)
  return (c, cs)

{-
With this implementation, we can see that we can generalize again, so that it
works for any parser, not just `get`...
-}

filter :: (a -> Bool) -> Parser a -> Parser a
filter f p = P $ \s -> do
  (c, cs) <- doParse p s
  guard (f c)
  return (c, cs)

{-
Parsing nothing!
===============

Now let's write a parser that only succeeds if we have reached the end of the
input. If there are *no* characters in the input, then it returns a
successful parse of a unit value and the remaining string (still
nil). Otherwise, if there are any characters at all, this parser fails.
-}

eof :: Parser ()
eof = P $ \s -> case s of
  [] -> Just ((), [])
  _ : _ -> Nothing

{-
Parser is a Functor
===================

The name `filter` is directly inspired by the `filter` function for lists. And
indeed, just like we can think of `[a]` as a way to get values of type `a`, we
can likewise think of `Parser a` as a way to potentially get a value of type
`a`.

So, are there other list-like operations that our parsers should support?

Of course! Like lists, the type constructor `Parser` is a functor.

-}

instance Functor Parser where
  fmap :: (a -> b) -> Parser a -> Parser b
  fmap = undefined

{-
With `get`, `satisfy`, `filter`, and `fmap`, we now have a small library
to build new (single character) parsers.

For example, we can write some simple parsers for particular sorts of
characters.  The following definitions parse alphabetic and numeric characters
respectively.
-}

alphaChar, digitChar :: Parser Char
alphaChar = satisfy isAlpha
digitChar = satisfy isDigit

-- >>> doParse alphaChar "123"
-- Nothing

-- >>> doParse digitChar "123"
-- Just ('1',"23")

{-
Similarly, finish this parser that should parse just one specific `Char`:
-}

char :: Char -> Parser Char
char c = undefined

-- >>> doParse (char 'a') "ab"
-- Just ('a',"b")

-- >>> doParse (char 'a') "ba"
-- Nothing

{-
And now let's use `fmap` to rewrite `oneDigit`:
-}

oneDigit' :: Parser Int
oneDigit' = cvt <$> digitChar -- <$> is fmap!
  where
    cvt :: Char -> Int
    cvt c = ord c - ord '0'

-- >>> doParse oneDigit' "92"
-- Just (9,"2")

-- >>> doParse oneDigit' "cat"
-- Nothing

{-
Parser Composition
==================

What if we want to parse more than one character from the input?

Using `get` we can write a composite parser that returns a pair of
the first two `Char` values from the front of the input string.
Again, we'll use `do` notation with the `Maybe` monad.

-}

twoChar0 :: Parser (Char, Char)
twoChar0 = P $ \s -> do
  (c1, cs) <- doParse get s
  (c2, cs') <- doParse get cs
  return ((c1, c2), cs')

-- >>> doParse twoChar0 "ab"
-- Just (('a','b'),"")

{-
More generally, we can write a *parser combinator* that takes two
parsers and returns a new parser that uses first one and then the
other and returns the pair of resulting values...
-}

pairP0 :: Parser a -> Parser b -> Parser (a, b)
pairP0 = undefined

{-
and use that to rewrite `twoChar` more elegantly like this:
-}

twoChar1 :: Parser (Char, Char)
twoChar1 = pairP0 get get

-- >>> doParse twoChar1 "hey!"

-- >>> doParse twoChar1 ""

-- >>> doParse (pairP0 oneDigit get) "1a"

-- >>> doParse (pairP0 oneDigit get) "a1"

{-
Parser is an Applicative Functor
================================

Suppose we want to parse *two* characters, where the first should be a sign
(i.e. '+' or '-') and the second a digit?

We've already defined single character parsers that should help. We just need
to put them together.

~~~~~{.haskell}
oneOp    :: Parser (Int -> Int)
oneDigit :: Parser Int
~~~~~

And we put them together in a way that looks a bit like `fmap` above. However,
instead of passing in the function as a parameter, we get it via parsing.
-}

signedDigit0 :: Parser Int
signedDigit0 = P $ \s -> do
  (f, cs) <- doParse oneOp s
  (x, cs') <- doParse oneDigit cs
  return (f x, cs')

-- >>> doParse signedDigit0 "-1"
-- Just (-1,"")

-- >>> doParse signedDigit0 "+3"
-- Just (3,"")

{-
Can we generalize this pattern? What is the type when `oneOp` and `oneDigit`
are arguments to the combinator?
-}

apP :: Parser (t -> a) -> Parser t -> Parser a
apP p1 p2 = P $ \s -> do
  (f, s') <- doParse p1 s
  (x, s'') <- doParse p2 s'
  return (f x, s'')

{-
Does this type look familiar?

Whoa! That is the type of the `(<*>)` operator from the `Applicative` class.
What does this combinator do?  It grabs a function value out of the
first parser (if one exists) and then grab the argument (using the remaining part of
the string) from the second parser, and then returns the application.

What about `pure`?

The definition of `pure` is very simple -- we can let the types guide us. This
parser always succeeds and produces a specific character without consuming
any of the input string.

-}

pureP :: a -> Parser a
pureP x = P $ \s -> Just (x, s)

{-
So we can put these two definitions together in our class instance.
-}

instance Applicative Parser where
  pure :: a -> Parser a
  pure = pureP
  (<*>) :: Parser (a -> b) -> Parser a -> Parser b
  (<*>) = apP

{-
Let's go back and reimplement our examples with the applicative combinators:
-}

twoChar :: Parser (Char, Char)
twoChar = pure (,) <*> get <*> get

signedDigit :: Parser Int
signedDigit = oneOp <*> oneDigit

-- >>> doParse twoChar "hey!"

-- >>> doParse twoChar ""

-- >>> doParse signedDigit "-1"

-- >>> doParse signedDigit "+3"

{-
Now we're picking up speed.  First, we can use our combinators to rewrite
our more general pairing parser (`pairP`) like this:
-}

pairP :: Parser a -> Parser b -> Parser (a, b)
pairP p1 p2 = pure (,) <*> p1 <*> p2

{-
Or, more idiomatically, we can replace `pure f <*>` with `f <$>`. (The `hlint`
tool will suggest this rewrite to you.)
-}

pairP' :: Parser a -> Parser b -> Parser (a, b)
pairP' p1 p2 = (,) <$> p1 <*> p2

{-
We can even dip into the `Control.Applicative` library and write `pairP` even
more succinctly using this `liftA2` combinator:

< liftA2 :: (a -> b -> c) -> Parser a -> Parser b -> Parser c
< liftA2 f p1 p2 = pure f <*> p1 <*> p2
-}

pairP'' :: Parser a -> Parser b -> Parser (a, b)
pairP'' = liftA2 (,)

{-
And, `Control.Applicative` gives us even more options for constructing
parsers. For example, it also includes a definition of `liftA3`.
-}

tripleP :: Parser a -> Parser b -> Parser c -> Parser (a, b, c)
tripleP = liftA3 (,,)

{-
The `*>` and `<*` operators are also defined in `Control.Applicative`. The
first is the `Applicative` analogue of the `(>>)` operator for `Monads`.

< -- sequence actions, discarding the value of the first action
< (*>) :: Applicative f => f a -> f b -> f b

The second is the dual to the first---it keeps the first result but discards
the second.

< -- sequence actions, discarding the value of the second action
< (<*) :: f a -> f b -> f a

Here's an example of a parser that uses both operators. When we parse something
surrounded by parentheses, don't want to keep either the opening or closing
characters.
-}

-- | Parse something surrounded by parentheses
parenP :: Parser a -> Parser a
parenP p = char '(' *> p <* char ')'

-- >>> doParse (parenP get) "(1)"

{-
Monadic Parsing
---------------

Although we aren't going to emphasize it in this module, the `Parser` type is
also a `Monad`. Just like `State` and list, we can make `Parser` an instance
of the `Monad` type class. To make sure that you get practice with the
applicative operators, such as `<*>`, we won't do that here. However, for practice,
see if you can figure out an appropriate definition of `(>>=)`.
-}

bindP :: Parser a -> (a -> Parser b) -> Parser b
bindP = undefined

twoChar' :: Parser (Char, Char)
twoChar' = bindP get $ \c1 ->
  bindP get $ \c2 ->
    pure (c1, c2)

-- >>> doParse twoChar' "hey!"
-- Just (('h','e'),"y!")

{-
Recursive Parsing
-----------------

However, to parse more interesting things, we need to add some kind of
recursion to our combinators. For example, it's all very well to parse
individual characters (as in `char` above), but it would a lot more fun if we
could recognize whole `String`s.

Let's try to write it!
-}

string :: String -> Parser String
string "" = pure ""
string (x : xs) = (:) <$> char x <*> string xs

{-
Much better!

-}

-- >>> doParse (string "mic") "mickeyMouse"

-- >>> doParse (string "mic") "donald duck"

{-
For fun, try to write `string` using `foldr` for the list recursion.
-}

string' :: String -> Parser String
string' = foldr undefined undefined

{-
Furthermore, we can use natural number recursion to write a parser that grabs
`n` characters from the input:
-}

grabn :: Int -> Parser String
grabn n = if n <= 0 then pure "" else (:) <$> get <*> grabn (n - 1)

-- >>> doParse (grabn 3) "mickeyMouse"
-- Just ("mic","keyMouse")

-- >>> doParse (grabn 3) "mi"
-- Nothing

{-
Choice
======

The `Applicative` operators give us sequential composition of parsers
(i.e. run one parser then another). But what about parallel composition
(i.e. run both parsers on the same input)?

Let's write a combinator that takes two sub-parsers and chooses between them.
-}

chooseFirstP :: Parser a -> Parser a -> Parser a
p1 `chooseFirstP` p2 = P $ \s -> doParse p1 s `firstJust` doParse p2 s

{-
How to write it?  Well, we want to return a successful parse if *either*
parser succeeds. The order of the subparsers matters here --- we want to try
the second parser only if the first parser fails. So we need to be careful about
how we compose the results together. Due to laziness, we will *only* try out
the second parser in the case that the first parser fails.
-}

firstJust :: Maybe a -> Maybe a -> Maybe a
firstJust (Just x) _ = Just x
firstJust Nothing y = y

{-
In the definition of `chooseFirstP`, note how we duplicate the input string
`s` and give the same string to both parsers. This code naturally implements
backtracking. If the first parser fails, we go back to the state of the
input where it started and then continue with the second parser.

Example: We can use the above combinator to build a parser that
returns either an alphabetic or a numeric character
-}

alphaNumChar :: Parser Char
alphaNumChar = alphaChar `chooseFirstP` digitChar

-- >>> doParse alphaNumChar "cat"

-- >>> doParse alphaNumChar "2cat"

{-
Parsing multiple inputs
-----------------------

Let's write a combinator that takes a parser `p` that returns an `a` and
 constructs a parser that recognizes a sequence of strings (each recognized by
 `p`) and returns a *list* of `a` values. That is, it keeps grabbing `a`
 values as long as it can and returns them in a list of type `[a]`.

We can do this by writing a parser that either parses one thing and then calls
itself recursively (if possible) or succeeds without consuming any input. In
either case, the result is a list.
-}

manyP :: Parser a -> Parser [a]
manyP p = ((:) <$> p <*> manyP p) `chooseFirstP` pure []

-- >>> doParse (manyP oneDigit) "12345a"

-- >>> doParse (manyP alphaChar) "12345a"

{-
Look out! What happens if we swap the order of the arguments to `chooseFirstP`?
-}

manyP' :: Parser a -> Parser [a]
manyP' p = pure [] `chooseFirstP` ((:) <$> p <*> manyP p)

{-
We don't want to do this --- the `pure []` parser always succeeds, so the result
will always be `[]`.

-}

-- >>> doParse (manyP' oneDigit) "12345a"

{-
Alternative
-----------

We can use choice and failure together to make the `Parser` type
an instance of the `Alternative` type class from
[Control.Applicative](https://hackage.haskell.org/package/base-4.8.1.0/docs/Control-Applicative.html).

The `Alternative` type class has two methods:

< class Applicative f => Alternative f where
<   empty :: f a
<   (<|>) :: f a -> f a -> f a

where `empty` is an applicative computation with zero results, and `(<|>)`, a
"choice" operator that combines two computations.  The `Alternative` type
class laws require the choice operator to be associative but it need not be
commutative (and it isn't here).

The `empty` computation should be an identity for the choice operator. In other words
we should have

    empty <|> a   === a

and

    a  <|> empty  === a

For parsers, this means that we need to have a *failure* parser that never
parses anything (i.e. one that always returns `Nothing`):
-}

failP :: Parser a
failP = P $ const Nothing

{-
Putting these two definitions together gives us the Alternative instance.
-}

instance Alternative Parser where
  empty = failP -- always fail
  (<|>) = chooseFirstP -- try the left parser, if that fails then try the right

{-
The `Alternative` type class automatically gives definitions for functions `many` and
`some`, defined in terms of `(<|>)`.

The `many` operation corresponds to running the applicative computation zero
or more times, whereas `some` runs the computation one or more times. Both
return their results in a list.

< many :: Alternative f => f a -> f [a]
< many v = some v <|> pure []

< some :: Alternative f => f a -> f [a]   --- result list is guaranteed to be nonempty
< some v = (:) <$> v <*> many v

For parsing, the `many` combinator returns a single, maximal sequence produced by iterating
the given parser, zero or more times
-}

-- >>> doParse (many digitChar) "12345a"

-- >>> doParse (many digitChar) ""

-- >>> doParse (some digitChar) "12345a"

-- >>> doParse (some digitChar) ""

{-
This sequence is maximal because the definition of `many` tries `some v`
before returning `Nothing`. If the definition had been the other way around, then
the result would always be the empty list (because `pure []` always succeeds).

Let's use `some` to write a parser that will return an entire natural number
(not just a single digit.)
-}

oneNat :: Parser Int
oneNat = fmap read (some digitChar) -- know that read will succeed because input is all digits

-- >>> doParse oneNat "12345a"

-- >>> doParse oneNat ""

{-
Challenge (will not be on the quiz): use the `Alternative` operators to
implement a parser that parses zero or more occurrences of `p`, separated by
`sep`.
-}

sepBy :: Parser a -> Parser b -> Parser [a]
sepBy p sep = undefined

-- >>> doParse (sepBy oneNat (char ',')) "1,12,0,3"
-- Just ([1,12,0,3],"")

-- >>> doParse (sepBy oneNat (char ',')) "1"
-- Just ([1],"")

-- >>> doParse (sepBy oneNat (char ',')) "1,12,0,"
-- Just ([1,12,0],",")

-- >>> doParse (sepBy oneNat (char '8')) "888"
-- Just ([888],"")

-- >>> doParse (sepBy (char '8') (char '8')) "888"
-- Just ("88","")

-- >>> doParse (sepBy oneNat (char ',')) ""
-- Just ([],"")

{-
Parsing Arithmetic Expressions
==============================

Now let's use the above to build a small calculator that parses and
evaluates arithmetic expressions. In essence, an expression is either
a binary operand applied to two sub-expressions or else an integer.

First, we parse arithmetic operations as follows:
-}

intOp :: Parser (Int -> Int -> Int)
intOp = plus <|> minus <|> times <|> divide
  where
    plus = char '+' *> pure (+)
    minus = char '-' *> pure (-)
    times = char '*' *> pure (*)
    divide = char '/' *> pure div

{-
Note how this parser returns a *binary function* if it succeeds.  Then we
parse simple expressions by parsing a digit followed by an operator and
another calculation, or by parsing a single digit alone.
-}

infixAp :: (Applicative f) => f a -> f (a -> b -> c) -> f b -> f c
infixAp = liftA3 (\i1 o i2 -> i1 `o` i2)

calc1 :: Parser Int
calc1 = infixAp oneNat intOp calc1 <|> oneNat

{-
This works pretty well...

-}

-- >>> doParse calc1 "1+2+33"

-- >>> doParse calc1 "11+22-33"

{-
But things get a bit strange with minus:

-}

-- >>> doParse calc1 "11+22-33+45"

{-
Huh?  Well, if you look back at the code, you'll realize the
above was parsed as

~~~~~{.haskell}
11 + (22 - (33 + 45))
~~~~~

because in each binary expression we require the left operand to be an
integer. In other words, we are assuming that each operator is *right
associative* hence the above result.  Making this parser left
associative is harder than it looks — we can't just swap `oneNat` and
'calc1', as below.
-}

calcBad :: Parser Int
calcBad = infixAp calc1 intOp oneNat <|> oneNat

{-
If you try this parser out, you'll see that it hangs on all inputs.

Furthermore, things also get a bit strange with multiplication:

-}

-- >>> doParse calc1 "10*2+100"

{-
This string is parsed as:

~~~~~{.haskell}
10 * (2 + 100)
~~~~~

But the rules of precedence state that multiplication should bind tighter that
addition. Our `calc1` doesn't do anything different between multiplication
and addition operators. So we have two problems to solve: precendence and
associativity.

Precedence
----------

We can introduce precedence into our parsing by stratifying the parser into
different levels.  Here, let's split our binary operations into addition-like
and multiplication-like ones.
-}

addOp :: Parser (Int -> Int -> Int)
addOp = char '+' *> pure (+) <|> char '-' *> pure (-)

mulOp :: Parser (Int -> Int -> Int)
mulOp = char '*' *> pure (*) <|> char '/' *> pure div

{-
Now, we can stratify our language into mutually recursive sub-languages, where
each top-level expression is parsed first as an addition expression (`addE`)
starting with a multiplication expressions (`mulE`). Multiplication
expressions must then start with a basic factors: either natural numbers or
arbitrary expressions inside parentheses.
-}

calc2 :: Parser Int
calc2 = addE

addE :: Parser Int
addE = infixAp mulE addOp addE <|> mulE

mulE :: Parser Int
mulE = infixAp factorE mulOp mulE <|> factorE

factorE :: Parser Int
factorE = oneNat <|> parenP calc2

{-
Now our parser is still right associative, but multiplication binds tighter
than addition.
-}

-- >>> doParse calc2 "1+10*2+100"

-- >>> doParse calc2 "1+10*(2+100)"

{-
Do you understand why the first parse returned `121`?

Parsing Pattern: Associativity via Chaining
-------------------------------------------

But we're still not done: we need to fix the associativity problem.
-}

-- >>> doParse calc2 "10-1-1"

{-
Ugh! I hope you understand why: it's because the above was parsed as
`10 - (1 - 1)` (right associative) and not `(10 - 1) - 1` (left
associative). You might be tempted to fix that simply by flipping the order
in `infixAp`, thus

~~~~~{.haskell}
addE = infixAp addE addOp mulE <|> mulE
~~~~~

but this would be disastrous. Can you see why?  The parser for `addE`
directly (recursively) calls itself *without consuming any input!*
Thus, it goes off the deep end and never comes back.

Let's take a closer look at what is going on with our current definitions. In
essence, an `addE` is of the form:

    mulE + ( mulE + ( mulE + ... mulE ))

That is, we keep chaining together `mulE` values and adding them for
as long as we can. Similarly a `mulE` is of the form

    factorE * ( factorE * ( factorE * ... factorE ))

where we keep chaining `factorE` values and multiplying them for as
long as we can.

Instead, we want to parse the input as starting with a multiplication expression followed by
any number of addition operators and multiplication expressions.
We can temporarily store the operators and expressions in a list of pairs.
Then, we'll `foldl` over this list, using each operator to combine the current
result with the next number.
-}

type IntOp = Int -> Int -> Int

addE1 :: Parser Int
addE1 = process <$> first <*> rest
  where
    {-

    -}

    -- start with a multiplication expression
    first :: Parser Int
    first = mulE1
    {-

    -}

    -- parse any number of `addOp`s followed
    -- by a multiplication expression
    -- return the result in a list of tuples
    rest :: Parser [(IntOp, Int)]
    rest = many ((,) <$> addOp <*> mulE1)

    -- process the list of tuples with a left fold
    process :: Int -> [(IntOp, Int)] -> Int
    process = foldl comb

    -- combine each operator and argument with
    -- the current value of the parser
    comb :: Int -> (IntOp, Int) -> Int
    comb x (op, y) = x `op` y

mulE1 :: Parser Int
mulE1 = foldl comb <$> factorE1 <*> rest
  where
    comb x (op, y) = x `op` y
    rest = many ((,) <$> mulOp <*> factorE1)

factorE1 :: Parser Int
factorE1 = oneNat <|> parenP addE1

{-
The above is indeed left associative:

-}

-- >>> doParse addE1 "10-1-1"

{-
Also, it is very easy to spot and bottle the chaining computation
pattern: the only differences are the *base* parser (`mulE1` vs
`factorE1`) and the binary operation (`addOp` vs `mulOp`).  We simply
make those parameters to our *chain-left* combinator:
-}

-- chainl1 :: Parser Int -> Parser IntOp -> Parser Int
p `chainl1` pop = foldl comb <$> p <*> rest
  where
    comb x (op, y) = x `op` y
    rest = many ((,) <$> pop <*> p)

{-
after which we can rewrite the grammar in three lines:
-}

addE2, mulE2, factorE2 :: Parser Int
addE2 = mulE2 `chainl1` addOp
mulE2 = factorE2 `chainl1` mulOp
factorE2 = parenP addE2 <|> oneNat

-- >>> doParse addE2 "10-1-1"

-- >>> doParse addE2 "10*2+1"

-- >>> doParse addE2 "10+2*1"

{-
Of course, we can generalize `chainl1` even further so that it is not
specialized to parsing `Int` expressions. Try to update the type above so that
it is more polymorphic.

This concludes our exploration of applicative parsing, but what we've covered
is really just the tip of an iceberg. Though parsing is a very old problem,
studied since the dawn of computing, algebraic structures in Haskell bring a
fresh perspective that has now been transferred from Haskell to many other
languages.
-}
