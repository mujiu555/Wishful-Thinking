#import "/lib/_lib.typ/lib.typ": *

#meta(
  title: [CIS 5520: Advanced Programming],
  date: datetime(year: 2026, month: 7, day: 5, hour: 23, minute: 0, second: 0),
  author: link("https://github.com/mujiu555")[GitHub\@mujiu555],
  id: "cis5520",
  parent_id: "index",
)

#mkheader()

== Introduction

#quote[
  *Good* programmers get the job done.

  *Excellent* programmers
  - write code that other people can understand, maintain and modify
  - rewrite/refactor code to make it clear and *simple*
  - use and create *abstractions* to capture fundamental designs
  - can explain *semantics* precisely: what their code does and why
]

== Haskell Basis

A Haskell module is a list of definitions.

The "Unit" type in Haskell has only one value, which is also the "unit", denoted by `()`.
The unit type is treated as a trivial type since it has no information content.
Once it found that a value has type `()`, it can be known that the value is `()`.

The meaning for trivial type is that in Haskell, each "function" is literally the function in mathematics.
Since a function maps input to the output, it must returns some concrete value for any input.
However, not every function has a meaningful output.
The trivial type is used to act as a placeholder for the output of such functions, representing the fact that the output is meaningless.

=== Abstractions

Pattern Recognition: extracting the common structure from some expressions.
Generalizing the patterns into functions by defining equations.

==== Functions

Functions have types, just like all expressions appearing in Haskell.

In Haskell, symbolic named functions are infix.
Parentheses around symbolic-named functions will turn them into prefix functions, which are regular.

In Haskell, arguments are passed by name, which is differ from the common "call by value" or "call by reference" in other languages.
This makes Haskell a lazy language.

=== Do Things

Using `IO a`.
And just `do` them.

=== Structured Data

Tuples, functions can accept one tuple as an argument.
It is not encouraged.

Optional, `Maybe a` is a type that can either be `Just a` or `Nothing`.

Lists, `[a]` is a type that can either be `[]` or `a : [a]`.

Strings, syntactic sugar for `[Char]`, which is a list of characters.


