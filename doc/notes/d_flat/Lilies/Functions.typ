
== Procedure, Evaluation & Control Flow

=== Procedure, First-Class Functions, and Higher-Order Functions

=== Closure

==== Capturing

==== Capture via Move

==== Capture via Value

==== Change the value of a captured variable

=== Currying

=== Lambda Expression

=== Function Type, Function Signature

==== `function`

e.g.,
```txt
(define foo
  (function ((x #:type (Integer))
             (y #:type (Integer)))
    #:returns ((result #:type (Integer))))
  (fn
    (lambda (x y) (+ x y))))
```

==== Parameter List

===== Type Signature

==== Returning List

===== Named Return Values

=== Function Definition

==== Function Signature

==== `fn`

e.g.,
```txt
(define foo
  (function ((x #:type (Integer))
             (y #:type (Integer)))
    #:returns ((result #:type (Integer))))
  (fn
    (lambda (x y) (+ x y))))

(define foo
  (function ((x #:type (Integer))
             (y #:type (Integer)))
    #:returns ((result #:type (Integer))))
  (fn
    (lambda (1 0) 0)
    (lambda (x y) (+ x y))))
```

==== `lambda`

e.g.,
```txt
(define foo
  (function ((x #:type (Integer))
             (y #:type (Integer)))
    #:returns ((result #:type (Integer))))
  (fn
    (lambda (x y) (+ x y))))
;; equals to
(define foo
  (function ((x #:type (Integer))
             (y #:type (Integer)))
    #:returns ((result #:type (Integer)))
  (lambda (x y) (+ x y))))
```

==== Parameter List: Pattern Matching List

==== Body: Single Expression Function

==== Returning Early: `:return` Expression

=== Evaluation Rules

==== Strict Evaluation

==== Lazy Evaluation

==== Decision: Strict Evaluation

==== Lazy Evaluation Methods

=== Tail Call Optimization (TCO)

=== Pattern Matching

==== Pattern Matching in Lambda Expression

==== Pattern Matching in Case Expression

==== Pattern Matching in Let Binding

==== Pattern Types: Literal Pattern, Variable Pattern, Wildcard Pattern, Constructor Pattern, Tuple Pattern, List Pattern, Record Pattern, As Pattern, Or Pattern

==== Guard Pattern

==== Complete Checking & Redundancy Checking

=== Control Flow

==== Sequence Execution

===== Unnamed Sequence

===== Named Sequence

==== Conditional Expression

===== If Expression

```txt
(if <condition> <then-expression> <else-expression>)
```

===== When Expression

```txt
(when <condition> <then-expression>)
```

===== Unless Expression

```txt
(unless <condition> <else-expression>)
```

===== Switch Expression

```txt
(switch <value>
  ((<expected-values>) <then-expression>)
  ...
  (:else <else-expression>))
```

===== Case Expression

```txt
(case <value>)
  (<pattern> <then-expression>)
  ...
  (:ignore <else-expression>))
```

===== Decision: Switch Expression vs Case Expression

Switch expression is a value-based conditional expression,
while case expression is a pattern-based conditional expression.

Switch expression looks mostly like `case` in traditional scheme,
if the value meets any of the expected values, it will execute the corresponding then-expression.
However, case expression is more powerful than switch expression,
it is a pattern-based conditional expression, which means it can match the value with a pattern,
extract the value from the pattern, and bind the extracted value to a variable.

You may even use guard pattern in case expression to add more conditions to the pattern matching.
The underline will represent the value to be matched.

===== Cond Expression

Cond expression is a multi-branch conditional expression, which have same property like scheme r6rs.
It has a list of clauses, each clause is a list of two elements, the first element is a condition, the second element is a then-expression.

```txt
(cond
  (<condition> <then-expression>)
  ...
  (:else <else-expression>))
```

==== Looping Constructs

===== Loop: Infinite Loop

```txt
(loop
  <body>)
```

===== While Loop: Condition Loop

```txt
(while <condition>)
  <body>)
```

===== Until Loop: Negative Condition Loop

```txt
(until <condition>)
  <body>)
```

===== For Loop: Named Iterator Loop (named let in Scheme)

```txt
(for <name> (<bindings>)
  <body>)
```

===== Foreach Loop: Anonymous Iterator Loop

```txt
(foreach ((<name> <collection>) ...)
  <body>)
```

===== Recursion

Recursion is a fundamental concept in programming where a function calls itself to solve a problem.
It can be used to implement loops and iterative processes.
In functional programming languages, recursion is often preferred over traditional looping constructs.

===== Named Loop

The for loop represents a named loop, which allows you to define a function that can be called recursively within the loop body.

Thus, actually, the for loop is a named let expression in scheme.

===== Break the Loop: Break Expression

`:break`

====== Return Values With Break Expression

===== Skip the Current Iteration: Continue Expression

`:continue`

===== Return Values from Loop

===== Map, Reduce, Filter & Fold: Higher-Order Functions for Collection Processing

===== Decision: Looping Constructs vs Higher-Order Functions

=== Continuation & Continuation-Passing Style (CPS)

==== Continuation

==== Continuation-Passing Style

==== First-Class Continuation

==== One-Shot Continuation

==== Delimited Continuation

==== Exception Handling & Error Handling via Continuation

==== Coroutines & Generators

==== Algebraic Effects & Effect Handlers

===== Effect Declaration

===== Effect Invocation

===== Effect Handling

===== How Implement Algebraic Effects Using Continuation
