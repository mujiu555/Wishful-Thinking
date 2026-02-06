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

= Section V: Escher

Pair is closed under the operation of `cons`.
It is able to concatenate data using Pairs.

List is built from nested Pairs. All pairs that have cdr be another pair are treated as lists.

As for map in scheme, it is able to concerning only operations on aggregates, without worrying about the details of how the data is represented.
Another case is the use of stream.

= Section VI: Symbolic Differentiation System: Quotation

To some some large problems, it is not the best way to solve them directly, even with divide and conquer.

It mathematics, it is easier to do differentiation, while integration is harder.

```lisp
(define (deriv exp var)
  (cond
    ((constant? exp var) 0)
    ((same? exp var) 1)
    ((sum? exp)
     (make-sum
       (deriv (a1 exp) var)
       (deriv (a2 exp) var)))
    ((product? exp)
     (make-sum
       (make-product
         (m1 exp)
         (deriv (m2 exp) var))
       (make-product
         (deriv (m1 exp) var)
         (m2 exp))))
    (t '())))
```

In lisp predicate is naming with suffix '?'. A conversion.

With quote, it is able to prevent a expression from being evaluated.
Which embraces the expression as data.
And build a more powerful language upon the lisp, interpreting such data as expressions in the new language.

= Section VII: Pattern-Matching: Rule-Based Substitution

Since the differentiation rules distinguished by the form of the expression.
And each rule is dispatched based on the pattern of the expression.

Thus we can find the rules can be described as "Pattern => Skeleton".
And after matching the pattern, the variables in the skeleton can be replaced by the corresponding parts in the expression, instantiate.

In contrast to build such system using conditionals,
make computer understand such rules directly by build a pattern-matching system is a more general and powerful way.

So we can have (伪代码):
```lisp
(define derive-rules
  `(((dd (?c c) (? v)) 0)
    ((dd (?v v) (? v)) 1) ;; ? is the pattern variable
    ((dd (?v u) (? v)) 0)

    ((dd (+ (? x1) (? x2)) (? v))
     (+ (dd (: x1) (: v))
        (dd (: x2) (: v))))
   ...
  ))
```
For which we can define some rules that describes pattern matching syntax.
For the rule part, we can have symbol matches itself,
pattern variable matches any sub-expression and binding it to some variable, and finally
`?v` matches the variable v.
For the skeleton part, `(: x1)` means to substitute the variable x1 with the corresponding part in the expression.

There are two parts in such system:
- A pattern-matching engine that can match an expression against a pattern, and extract the bindings for the pattern variables.
- A substitution engine that can take a skeleton and a set of bindings, and produce a new expression by substituting the pattern variables in the skeleton with their corresponding values from the bindings.

But since we cannot promise that the expression always simplest form,
We then can build a simplification system that can simplify the expression after each differentiation step.
If the expression is a unit, then process it using unit simplification rules.
Else, extract all components, simplify them recursively, and then reassemble the expression.

= Section VIII: Generic Operators

In previous sections, there introduced a key idea that create abstraction barriers to separate different layers of the system.
When something is used in upper layers, it is not needed to know how it is implemented in lower layers.
By which separate the tasks of implementation and usage.

However, it is not that effective in develop large systems.
Thus there must have a barrier that not only separates different layers,
but also create barriers that separate different implementations of the same abstraction.

E.g., interface of numbers.
We have polar and rectangular representation of complex numbers.
And we'd build operations upon such numbers, such as addition, multiplication, and so on.

Thus, we shall have typed data, which contains type tags to indicate the type of the data.

This method, is called "dispatch on type tag".
However, such method increases the complexity of the system, without providing much benefit.

To solve such problem, we can build a generic operator system.
Operators, or interfaces in OOP, are defined in terms of the operations they support.

The organization of such system is not unique.
From above we use a table, a manager, to manage the relationships between types and operations.
However it is also possible to associate operations directly with types and objects.
The second method here is called message passing, which is widely used in OOP.
P.S., In c++, such mechanism is called virtual functions.

= Section IX: Assignment, State & Side Effects

Functional programming is a kind of encoding of mathematical facts.
But it's stateless.
In real world programming, it is necessary to have state to record the changes of the system over time.

== Environment Model

We say that a variable v is bound in an expression E if
the meaning of E is unchanged
by the uniform replacement of a variable w that not occurring in E
for every occurrence of v in E.

P.S., The semantic context of a variable is not determined solely by its name, but the environment in which it is evaluated.
P.S., Alpha conversion in lambda calculus.

With the lambda, we can define the scope of variables as the body of the lambda that they appears.

One lambda expression may have is own environment,
all bounded variables in such lambda expression are defined in such environment,
and other free variables are defined in the environment where such lambda expression is defined,
and thous environments are linked together to form a chain of environments, which is called the environment model.

When we search for a symbol that appears in an expression, we search for it in the current environment,
if not found, then search in the parent environment, and so on, until we reach the global environment,
which is the top-level environment that contains all the global definitions.

== Object

When organize the data into objects, it can have its own state,
thus states we need to represent the state of the system, and the changes of the system over time is less than
those we coupling different objects as a whole.

When the two variables are combined together, we may need totally product of the states, the Cartesian product.
However, if we can separate the two variables into two objects, then the state of the system is the sum of the states of the two objects, which is much smaller than the Cartesian product.

Most objects are independent of each other, and they have no necessary to take care of the states of other objects.
But when two objects have interactions, some of their states are coupled together.

How can we distinct two objects?
Change one and the other does not change, thus they are different objects.

In real world, if we want a random number generator,
if we treat it as a pure function, then it will always return the same number, which is not what we want.
However, if we treat it as an object, which has its own state, then it can return different numbers each time we call it.
But it is not a pure function, since it has side effects, which is the change of the state of the object.
And when it is called at multiple place, the result may be unexpected, since the state of the object always change in between.

= Section X: Computational Objects

Assume that we have a physical world and each object in that world is independent and have their own properties,
we can then have a clear relationship between each pair of objects.

We can build a system, a new language that built upon the lisp, embedded in the lisp, to describe such objects and their interactions.
In contrast to the pattern-matching system, which is a external dsl that is interpreted by the lisp, the system here is an internal dsl that is directly executed by the lisp.

In which, we can build a circuit system that can describe the behavior of the circuit
by connecting each component with wires, letting each component has the ability to send and receive signals through the wires,
broadcasting the signals to all connected components, and update the state of the component based on the received signals.
With event-driven programming, the states stored by each component can be updated when a wire have updated.

All this includes the use of assignment, to update the state of the component, and side effects, to change the state of the system over time.
When input signals updated and the state of the components changes, broadcast to all connected components, which then update their states, and so on, thus the system can have a complex behavior.

In real world, the idea is similar.
The changes of states that happening in the real world in time is organized as the time in computer.
Thus when a even happened after another, the corresponding events happens in the same order in the computer.

By adopting assignment, we can organize time in the computer.
Agenda.

We still needs assignments.

After introduced assignment, the regular substitution model is no longer valid, since the value of a variable can change over time.
With the ability to share data, assignment can lead to unintended consequences, since the change of one variable can affect other variables that share the same data.

In scheme, we can assign cons with `set-car!` and `set-cdr!`,

In mathematics, with Church encoding, it is possible to represent data using functions.
```lisp
(define (cons car cdr)
  (lambda (M) (M car cdr))

(define (car x)
  (x (lambda (a d) a)))

(define (cdr x)
  (x (lambda (a d) d)))
```
However, instead of the original definition of cons, we can add some assignments:
```lisp
(define (cons car cdr)
  (lambda (M)
    (M car
       cdr
       (lambda (val) (set! car val))
       (lambda (val) (set! cdr val))))

(define (car x)
  (x (lambda (a d sa sd) a)))

(define (cdr x)
  (x (lambda (a d sa sd) d)))
```
Above all, we have same properties as the original cons, but we can also change the value of car and cdr by calling the corresponding setter functions:
We can assume the thing provided for cons is a permission, a permission to change the value of car and cdr, which is similar to the getter and setter in OOP languages.
P.S., in those languages we use properties to control the access to the internal state of the object,
however, in this case, any one that have the permission can change the value of car and cdr.
```lisp
(define (set-car! x val)
  (x (lambda (a d sa sd) (sa val))))

(define (set-cdr! x val)
  (x (lambda (a d sa sd) (sd val))))
```






























