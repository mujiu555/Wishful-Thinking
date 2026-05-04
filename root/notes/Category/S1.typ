#import "/lib/lib.typ": *

#show: schema.with("page")

#title[[Bartosz Milewski] Category theory for programmers (Part I)]
#date[2026-04-19 21:27]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

Why category theory is important?
- Functional programming: Functors,

Programming Methods:
- Tell the computer exactly what to do, something related to the Turing machine,
- Church encoding: lambda calculus, describes how something are executed.
  However, it is almost not possible to be used in practice.
- Higher level, procedure programming,
- Objective programming, compose objects together
  without really care about how they are implemented.
  The basic idea is to chop bigger problems into smaller ones,
  and combine solution together.
- Abstraction, hide details

Concurrent code and parallel codes, it suffer the object oriented programming
because objects hide the wrong details.
Thus they are not composable.
Since they hide the mutation, mutatable states, from which we cannot know what they mutate,
they also hide the shared data, and mixing sharing and mutation course the data race.

Category theory, it try to find similarities between different sets,
unification of different areas of mathematics.
Abstract bits, and other things into the lambda calculus,
In computer science they may be categorized as types, from which we can introduce type theory...
Furthermore, there are logic,
what ever you do in logic, you can do the same way in type theory, and vice versa.
Finally, we can find those area, category theory, type theory, logic and so on, they are all the same.


