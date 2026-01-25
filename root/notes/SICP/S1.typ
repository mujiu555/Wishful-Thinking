/// TAG: programming paradigm, scheme
#import "@preview/zh-kit:0.1.0": *
#import "/lib/lib.typ": *

#show: schema.with("page")

#title[MIT 6.001: Structure and Interpretation of Computer Programs (SICP)]
#date[2025-12-17 15:56]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

#show: doc => setup-base-fonts(doc)

#quote[
  Computer science is not about computers, any more than astronomy is about telescopes, or biology about microscopes.
]

Computer is neither about science nor about computers,
instead of a subject that helps explore the nature of computation itself, it is a engineering discipline that focuses on building systems that perform computations,
aka., how to use computers to solve problems.

Likely geometry, which originally focused on measuring land, later evolved into a abstract mathematical discipline that studies the properties of space and shapes.

The main problem the computer science tries to solve is to describe the process of computation.

In mathematics, functions are used to describe relationships between quantities.
In this aspect, a equation cannot tell us how to compute the value of a function.
And computer science can provide us a way to describe such process, to compute and solve the functions.

The main purpose is to find the way to formalize such process, to describe the process of computation itself.
In some case, the systems can be such large and complex that nobody can fully understand the whole system.
And that's why we need to build abstractions to help us manage the complexity of such systems.
What make this possible is the idea of procedures, which can be used to build abstractions.
A technique to manage complexity.

Computer is a virtual environment that will not affect by real world constraints, such that the system can be built in any way we want.
The only limitation is our imagination and creativity.
A ideal system.

= Preface

= Section 1: Building Abstractions with Procedures

The first way to build abstraction is black boxes, aka., procedures.
Which accepts some inputs, and produce some outputs, without revealing the internal details of how the procedure works.
This way is called encapsulation nowadays.

Fix points:
A fix point of a function is a value that does not change under the application of the function.
And in this case, what we want to do is to find a way that can compute such fix points.
Package the process into procedures.
And how can we archive this is a instructive knowledge.
How about to apply such procedure?
How about to use such procedure to find the fix points of other functions?
And how about to build new procedures that build upon such procedure?

In this chapter, we'd talk about several topics:
- Primitive Elements
- Combinations
- Abstract and how to build new abstractions
- Extract common patterns

== Lisp

The main purpose to have such section is not to programming in Lisp, rather than to learn how to think about programming.
What is about to learn is a general framework, which compose of primitives, means of combination, and the means of abstraction.

The combination of Lisp expressions are organized in a tree structure, aka., S-expressions.
P.S., in compiler, such tree structure is called Abstract Syntax Tree (AST).

== `define`

The way to build new abstractions is using `define`.
By extract general ideas from specific examples, it is possible to create new procedures.














