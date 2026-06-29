
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

```txt
(function (<parameter-list>) : (<returning-list>))
(function (<parameter-list>) : (<returning-list>) . <effects>)
```

Parameter-list and returning-list can be empty, but the `function` form must have a parameter list and a returning list.
Effects is optional and can be multiple.

e.g.,
```txt
(define foo
  (function ((x : (Integer))
             (y : (Integer)))
    : ((result : (Integer))))
  (fn
    (lambda (x y) (+ x y))))
```

==== Parameter List

```txt
()
((<parameter-name> : <parameter-type>) ...)
((<parameter-name> : <parameter-type>) ... . <rest-parameter-name>)

(:self)
(:self (<parameter-name> : <parameter-type>) ...)
(:self (<parameter-name> : <parameter-type>) ... . <rest-parameter-name>)
```

The parameter list represents what a function takes as input,
it can be empty, or it can have multiple parameters, even with a optional rest parameter.

If the function is defined within a `impl` form, then it can have a `:self` parameter,
which represents the instance of the type that the function is defined in.

===== Type Signature

==== Returning List

===== Named Return Values

==== Effect Signature

=== Function Definition

==== Function Signature

==== `fn`

`fn` just allows you to use multiple lambda expressions to define a function,
which is useful for pattern matching in function definition.

e.g.,
```txt
(define foo
  (function ((x : (Integer))
             (y : (Integer)))
    : ((result : (Integer))))
  (fn
    (lambda (x y) (+ x y))))

(define foo
  (function ((x : (Integer))
             (y : (Integer)))
    : ((result : (Integer))))
  (fn
    (lambda (1 0) 0)
    (lambda (x y) (+ x y))))
```

==== `lambda`

`lambda` is indeed the only way to define a function.
You may use pattern matching in the parameter list of `lambda`,
however, it is not possible for you to declare all possible patterns in the one `lambda` expression,
thus, if you want to define a function with multiple patterns, you need to use `fn`.
Otherwise, if you can cover all patterns, or just follow the signature of the function,
you can just use one `lambda` expression to define the function.

If you define a function without covering all possible patterns, then the compiler will complain about it, throwing an error.

e.g.,
```txt
(define foo
  (function ((x : (Integer))
             (y : (Integer)))
    : ((result : (Integer))))
  (fn
    (lambda (x y) (+ x y))))
;; equals to
(define foo
  (function ((x : (Integer))
             (y : (Integer)))
    : ((result : (Integer)))
  (lambda (x y) (+ x y))))
```

==== Parameter List: Pattern Matching List

==== Body: Single Expression Function

In a lambda expression, you can write only one expression as the body of the function.
If you want to write multiple expressions, you must use `sequence` expression to create a sequence execution block.

==== Returning value

The `lambda` expression will treat the returning value of the body as its returning value by default.

==== Returning Early: `:return` Expression

If the signature marks the function as returning multiple values,
then you must use `:return` expression to return it.

Otherwise, in regular function, `:return` can be used to return early from the function, and the value will be returned as the result of the function.

=== Generic Function

Similar to the chapter in Type System.
There are two possible ways to define a generic function.
Which is not determined to use which yet.

If we choose to use the first way, then we can define a generic function like this:
```txt
(define (foo a)
  (function ((x : a))
    : ((result : a)))
  (lambda (x) x))
```

When use this generic function, we may specify the type parameter like this:
```txt
((foo (Integer)) 1)
```
Or, we can left it for auto type inference, like this:
```txt
(foo 1)
```

Otherwise if we have first-class type, we can have:
```txt
(define foo
  (function ((x : (Type)))
    : ((result : (function ((a : x)) : ((result : x)))))
  (lambda (x) x))
```

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
