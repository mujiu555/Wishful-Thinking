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

= Section I: Building Abstractions with Procedures

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

= Section II: Procedure and Processes, Substitution Model

To write effective and usable programs,
it is necessary to have a overall understanding of relationship between procedures and processes.

The model to explain such relationship here is called substitution model,
which is not exactly how the computer works, but a idealized model that helps us understand how procedures work.

In Lisp expressions, there exists NUMBERS, SYMBOLS, LAMBDAS, DEFINITIONS, and CONDITIONALS.
But how to evaluate such expressions?
In substitution model, the way is to
- Evaluate the operator to get the procedure
- Evaluate the operands to get the arguments
- Apply the procedure to the arguments,
  Which is: Copy the body of the procedure, substitute the arguments for the parameters, and evaluate the resulting expression.

The key to computation is ignore unnecessary details, and focus on the important parts.

Two kind of processes:
- Iteration: time grows linearly with the number of steps, and the space required remains constant.
- Recursion: both time and space grow linearly with the number of steps.

The recursion for processes is not the same as recursion for procedures.
Recursive procedures are those that call themselves.

For Iteration processes, it is possible to store the thoughts in a fixed number of state variables.
However, for Recursive processes, it is necessary to keep track of all the previous states, which is the implicitly stored information in the control stack.

As the growth of recursive processes, the time complexity will grow exponentially, since sometimes a already done computation is repeated again and again.
With memorization, it is possible to store the results of such computations, and reuse them later, thus a recursive process can be transformed into an iterative one.
Normally, transforming a recursive process into an iterative one is not trivial,
since it requires to find a way to store the necessary information in a fixed number of state variables.
Thus memorization is a easier way to achieve this.

= Section III: Higher-Order Procedures

Extract a procedure as a parameter and then it enhance extensibility since the procedure can be customized by modifying the procedure taken as argument.

As for square-root procedure, it can be written as a function that
$
  f(y): R^+ -> R^+ = (y + x / y) / 2
$
Thus, there exists a fix point for such function, which is the square root of x.
A fix-point is something that has the property that applying the function to it returns the same value.

The idea is that if there exists a procedure that can find the fix point of a function, then it is possible to use such procedure to find the square root of a number.

= Section IV: Compound Data

Divorce the task of building data structures from the task of implementing them.
The key idea is to build the system in layers, and setup abstraction barriers that isolate the details at the lower layers.

Same for building of data.
The data can be built from primitive data, and combined into compound data using constructors.
To access the data, selectors are used to extract the necessary information from the compound data.

The lisp provides a way to build compound data using pairs.
`cons`, constructs a pair from two elements.
`car`, selects the first element of a pair. Contents of the Address part of Register.
`cdr`, selects the second element of a pair. Contents of the Decrement part of Register.

When define a new data by `cons`, it is treated as box and pointer notion.
By which concatenate conses, Cons cell chain, it is possible to build more complex data structures, such as lists, trees, and so on.









































