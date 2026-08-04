{-# LANGUAGE DataKinds #-}
{-
---
fulltitle: GADTs
date: October 14, 2025
---

Today we are going to talk about two of my favorite GHC extensions. These extensions
are not part of the core language, so they must be explicitly enabled with
`LANGUAGE` pragmas (see above) in any module that uses them.
-}
{-# LANGUAGE GADTs #-}

module GADTs where

import Data.Kind (Type)
import Test.HUnit (Test, (~?=))

{-
\*Generalized Algebraic Datatypes*, or GADTs, are one of GHC's more unusual
extensions to Haskell.  In this module, we'll introduce GADTs and related
features of GHC's type system.

An Untyped Expression Evaluator
-------------------------------

As a motivating example, here is a standard datatype of integer and boolean
expressions. You might use this datatype if you were defining a simple
programming language, such as the formula evaluator in a spreadsheet.
-}

data OExp
  = OInt Int -- a number constant, like '2'
  | OBool Bool -- a boolean constant, like 'true'
  | OAdd OExp OExp -- add two expressions, like 'e1 + e2'
  | OIsZero OExp -- test if an expression is zero
  | OIf OExp OExp OExp -- if expression, 'if e1 then e2 else e3'
  deriving (Eq, Show)

{-
Here are some example expressions.
-}

-- The expression "1 + 3"
oe1 :: OExp
oe1 = OAdd (OInt 1) (OInt 3)

-- The expression "if (3 + -3) == 0 then 3 else 4"
oe2 :: OExp
oe2 = OIf (OIsZero (OAdd (OInt 3) (OInt (-3)))) (OInt 3) (OInt 4)

-- Make an expression for "if true then false else true"
oe3 :: OExp
oe3 = undefined

{-
And here is an evaluator for these expressions. Note that the result type of
this interpreter could either be a boolean or an integer value.
-}

oevaluate :: OExp -> Maybe (Either Int Bool)
oevaluate = go
  where
    go (OInt i) = Just (Left i)
    go (OBool b) = Just (Right b)
    go (OAdd e1 e2) =
      case (go e1, go e2) of
        (Just (Left i1), Just (Left i2)) -> Just (Left (i1 + i2))
        _ -> Nothing
    go (OIsZero e1) =
      undefined
    go (OIf e1 e2 e3) =
      undefined

{-
Ugh. That Maybe/Either combination is awkward.
-}

-- >>> oevaluate oe1

-- >>> oevaluate oe2

{-
Plus, this language admits some strange terms:
-}

-- "True + 1"
bad_oe1 :: OExp
bad_oe1 = OAdd (OBool True) (OInt 1)

-- "if 1 then True else 3"
bad_oe2 :: OExp
bad_oe2 = OIf (OInt 1) (OBool True) (OInt 3)

-- >>> oevaluate bad_oe1

-- >>> oevaluate bad_oe2

{-
A Typed Expression Evaluator
----------------------------

Let's revise our data structure so that it cannot represent terms sucha as `bad_oe1`.

As a first step, we rewrite the definition of the expression
datatype in so-called "GADT syntax".
-}

data SExp :: Type where
  SInt :: Int -> SExp
  SBool :: Bool -> SExp
  SAdd :: SExp -> SExp -> SExp
  SIsZero :: SExp -> SExp
  SIf :: SExp -> SExp -> SExp -> SExp

{-
We haven't changed anything yet (other than the names). This version means
exactly the same as the definition above.  The change of syntax makes
the types of the constructors -- in particular, their result type -- more
explicit in their declarations.  Note that, here, the result type of every
constructor is `SExp`, and this makes sense because they all belong to
the `SExp` datatype.

Now let's refine our datatype, adding a *type index*. We add a new parameter
to the datatype so that its kind is now `Type -> Type` instead of `Type`.
-}

data GExp :: Type -> Type where
  GInt :: Int -> GExp Int
  GBool :: Bool -> GExp Bool
  GAdd :: GExp Int -> GExp Int -> GExp Int
  GIsZero :: GExp Int -> GExp Bool
  GIf :: GExp Bool -> GExp a -> GExp a -> GExp a

{-
Note what's happened: every constructor still returns some kind of
`GExp`, but the type parameter to `GExp` varies. For literal integers
(`GInt`) this type parameter tells us that the expression will evaluate
to an `Int`. But for literal booleans (`GBool`), the result of evaluation should
be a `Bool`. The `GAdd` constructor requires that its two subterms produce
integers and itself produces an integer. Similarly the `GIsZero` constructor
requires an integer, but produces a boolean. Finally the `GIf` constructor
requires a boolean for the first subterm (the condition of the `if`) but
is also polymorphic. Both the `then` and `else` subterms can either be
`Bool` or `Int`, but they should match and the result of the entire expression
is the same.
-}

-- "1 + 3 == 0"
ge1 :: GExp Bool
ge1 = GIsZero (GAdd (GInt 1) (GInt 3))

-- "if True then 3 else 4"
ge2 :: GExp Int
ge2 = GIf (GBool True) (GInt 3) (GInt 4)

{-
Check out the type errors that result if you uncomment these expressions.
-}

-- bad_ge1 :: GExp Int
-- bad_ge1 = GAdd (GBool True) (GInt 1)

-- bad_ge2 :: GExp Int
-- bad_ge2 = GIf (GInt 1) (GBool True) (GInt 3)

-- bad_ge3 :: GExp Int
-- bad_ge3 = GIf (GBool True) (GInt 1) (GBool True)

{-
Now we can give our evaluator a more exact type and write it in a much
clearer way:
-}

evaluate :: forall t. GExp t -> t
evaluate = go
  where
    go :: forall t. GExp t -> t
    go (GInt i) = i
    go (GBool b) = b
    go (GAdd e1 e2) = go e1 + go e2
    go (GIsZero e1) =
      undefined
    go (GIf e1 e2 e3) =
      undefined

{-
Not only that, our evaluator is more efficient [1] because it does not need to
wrap the result in the `Either` datatypes. This means that during execution,
the evaluator does not need to pattern match the `Either` type: it can access the
result of the recursive call immediately.

GADTs with DataKinds
--------------------

Let's look at one more simple example, which also motivates another
GHC extension that is often useful with GADTs.

We have seen that **kinds** describe _types_, just like **types**
describe _terms_. For example, the parameter to `T` below must have
the kind of types with one parameter, written `Type -> Type`.
In other words, `a` must be like `Maybe` or `[]`.

We can write this kind right before our type definition.
-}

type T :: (Type -> Type) -> Type
data T a = MkT (a Int)

{-
The `DataKinds` extension of GHC allows us to use _datatypes_ as kinds.
For example, this _type_, `U` is parameterized by a boolean.
-}

type U :: Bool -> Type
data U a = MkU

{-
That means that the kind of `U` is `Bool -> Type`.  In other words, both `U True`
and `U 'False` are valid types for `MkU` (and different from each other).
-}

exUT :: U True
exUT = MkU

exUF :: U False
exUF = MkU

-- This line doesn't type check because (==) requires arguments with the same types.
-- exEQ = exUT == exUF

{-
Right now, `U` doesn't seem very useful as it doesn't tell us very much.
So let's look at a more informative GADTs.

Consider a version of lists where the flag indicates whether the list is
empty or not. To keep track, let's define a flag for this purpose...
-}

data Flag = Empty | NonEmpty

{-
...and then use it to give a more refined definition of
lists.

As we saw above, GADTs allow the result type of data constructors to
vary. In this case, we can give `Nil` a type that statically declares
that the list is empty.
-}

data List :: Flag -> Type -> Type where
  Nil :: List Empty a
  Cons :: a -> List f a -> List NonEmpty a

deriving instance (Show a) => Show (List f a)

{-
Analogously, the type of `Cons` reflects that it creates a
nonempty list. Note that the second argument of `Cons` can have
either flag -- it could be an empty or nonempty list.

Note, too, that in the type `List 'Empty a`, the _type_ `Flag` has been lifted
to a _kind_ (i.e., it is allowed to participate in the kind expression `Flag
-> Type -> Type`), and the _value_ constructor `Empty` is now allowed to appear in
the _type_ expression `List Empty a`.

(What we're seeing is a simple form of _dependent types_, where values
are allowed to appear at the type level.)
-}

ex0 :: List Empty Int
ex0 = Nil

ex1 :: List NonEmpty Int
ex1 = Cons 1 (Cons 2 (Cons 3 Nil))

{-
The payoff for this refinement is that, for example, the `head`
function can now require that its argument be a nonempty list. If we
try to give it an empty list, GHC will report a type error.
-}

safeHd :: List NonEmpty a -> a
safeHd (Cons h _) = h

-- >>> safeHd ex1

-- >>> safeHd ex0

{-
(In fact, including a case for `Nil` is not only not needed: it is not
allowed!)

Compare this definition to the unsafe version of head.
-}

-- unsafeHd :: [a] -> a
-- unsafeHd (x : _) = x

-- >>> unsafeHd [1,2]

-- >>> unsafeHd []

{-
This `Empty`/`NonEmpty` flag doesn't interact much with some of the list
functions. For example, `foldr` works for both empty and nonempty lists.
-}

foldr' :: (a -> b -> b) -> b -> List f a -> b
foldr' = undefined

{-
But the `foldr1` variant (which assumes that the list is nonempty and
omits the "base" argument) can now _require_ that its argument be
nonempty.
-}

foldr1' :: (a -> a -> a) -> List NonEmpty a -> a
foldr1' = undefined

{-
The type of `map` becomes stronger in an interesting way: It says that
we take empty lists to empty lists and nonempty lists to nonempty
lists. If we forgot the `Cons` in the last line, the function wouldn't
type check. (Though, sadly, it would still type check if we had two
`Cons`es instead of one.)
-}

map' :: (a -> b) -> List f a -> List f b
map' = undefined

{-
For `filter`, we don't know whether the output list will be empty or
nonempty.  (Even if the input list is nonempty, the boolean test might
fail for all elements.)  So this type doesn't work:
-}

-- filter' :: (a -> Bool) -> List f a -> List f a

{-
(Try to implement the filter function and see where you get stuck!)

This type also doesn't work...
-}

-- filter' :: (a -> Bool) -> List f a -> List f' a

{-
... because `f'` here is unconstrained, i.e., this type says that
`filter'` will return *any* `f'`. But that is not true: it will return
only one `f'` for a given input list -- we just don't know what it is!

The solution is to hide the size flag in an auxiliary datatype
-}

data OldList :: Type -> Type where
  OL :: List f a -> OldList a

deriving instance (Show a) => Show (OldList a)

{-
To go in the other direction -- from `OldList` to `List` -- we just
use pattern matching.  For example:
-}

isNonempty :: OldList a -> Maybe (List NonEmpty a)
isNonempty = undefined

{-
Now we can use `OldList` as the result of `filter'`, with a bit of
additional pattern matching.
-}

filter' :: (a -> Bool) -> List f a -> OldList a
filter' = undefined

-- >>> filter' (== 2) (Cons 1 (Cons 2 (Cons 3 Nil)))
-- OL (Cons 2 Nil)

{-
Although these examples are simple, GADTs and DataKinds can also work in much
larger libraries, especially to simulate the effect of *dependent types* [3].

Lecture notes
-------------

[1] The OCaml language also includes GADTs. See this [blog
post](https://blog.janestreet.com/why-gadts-matter-for-performance/) about how
Jane Street uses them to optimize their code.

[2] When data constructors are used in types, we can add a `'` in front of
them. This mark tells GHC that it should be looking for a data constructor
(like `True`) instead of a type constructor (like `Bool`). GHC allows
you to leave this tick off as long as there is no overloading of data
constructor and type constructor names. However, consider `[]`, and `()`, and
`(,)`. These all stand for both data constructors (i.e. the empty list, the
unit value, and the pairing constructor) and type constructors (i.e. the list
type constructor, the unit type, and the pairing type constructor). So if you
are using these values to index GADTS, you must always use a tick when you mean the
data constructor.

[3] [Galois](https://galois.com/), a Haskell-based company, makes heavy use of
these features in their code base and has written up a
[short paper](http://www.davidchristiansen.dk/pubs/dependent-haskell-experience-report.pdf)
about their experiences.

-}
