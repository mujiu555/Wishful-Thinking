
== Procedure, Evaluation & Control Flow

=== Procedure, First-Class Functions, and Higher-Order Functions

=== Closure

==== Capturing

==== Capture via Move

==== Capture via Value

==== Change the value of a captured variable

=== Partial Evaluation & Currying

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

The basic sequence execution form is `sequence`,
which allows you to execute multiple expressions in order,
and the returning value of the last expression will be the returning value of the whole sequence.

===== Named Sequence

With `do` form, you can define a named sequence execution block,
thus, you can use `:return` expression to return early from the sequence execution block.

This could be a syntax sugar for immediately invoked lambda expression, but it is more readable and easier to use.

===== Pipeline Sequence

Just like the `&` in Haskell or the `|>` in F\#,
the pipeline sequence form `then` allows you to pass the returning value of the previous expression as the first argument of the next expression.

```txt
(then <expression1>
  <partial-expression1>
  ...
  <partial-expressionN>)
```

Partial-expression is any legal expression,
the function or form invoked in the partial-expression must have at least one free parameter
and will be filled with the returning value of the previous expression.
If the expression have more returning values, then the returning values will be passed in order as 2nd, 3rd, ... arguments of the next expression.

By contrast, if you want to pass the returning value as the last argument of the next expression, you can use `then:last` form.
Most part are the same as `then` form,
but the returning value of the previous expression will be passed as the last argument of the next expression.

===== Named Pipeline Sequence

`pipe` form is specially designed for named pipeline sequence execution block,
it allows you to leave placeholder for the returning value of the previous expression in the next expression,

Each partial-expression in the `pipe` form can have individual-counted placeholders.
`:1`, `:2`, `:3`, ... will be replaced by the returning values of the previous expression in order.
`:*` will be replaced by all returning values of the previous expression in order.

This allows for flexible and powerful chaining of function calls,
especially when dealing with functions that return multiple values.

You can even handle expression with different number of returning values in the same `pipe` form.
E.g.,
```txt
(pipe 1
  (+ :1 1)       ;; this will return 2
  (div :1 2)     ;; this will return quotient and remainder
  (print :1 :2)) ;; return nothing
```

===== Conditional Pipeline Sequence

Or, you can use `pass` form for customized handling of the returning values of the previous expression,

```txt
(pass <initial-expression>)
  (<pattern1> <paritial-expression1>)
  ...
  (<patternN>))
```

If the pattern is match and the guard is satisfied, then the corresponding partial-expression will be executed, otherwise the next pattern will be checked.

This means all returning value of the expressions must have same type.

===== Chain Call Sequence

Since we have "methods", and the syntax sugar for calling single method is not that convenient to use when we need to call multiple methods in a chain,
thus we have `chain` form to allow you to call multiple methods in a chain.

```txt
(chain <object>
  (<method-name1> <arg1> <arg2> ...)
  ...
  (<method-nameN> <arg1> <arg2> ...))
```

This can be replaced by forms described in the previous sections, but it is more readable and easier to use.

E.g.,
```txt
(chain 1   ;; 1 is a instance implementing the `Number` trait
  (add 1)
  (mul 2)
  (sub 3))
```

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

When we have a value, we can use switch expression to check if the value is equal to any of the expected values,
it is a simplified version of case expression.

===== Case Expression

```txt
(case <value>
  (<pattern> <then-expression>)
  ...
  (:otherwise <else-expression>))
```

Case expression is a pattern-based conditional expression,
if the value matches any of the expected patterns, it will execute the corresponding then-expression.

===== Decision: Switch Expression vs Case Expression

Switch expression is a value-based conditional expression,
while case expression is a pattern-based conditional expression.

Switch expression looks mostly like `case` in traditional scheme,
if the value meets any of the expected values, it will execute the corresponding then-expression.
However, case expression is more powerful than switch expression,
it is a pattern-based conditional expression, which means it can match the value with a pattern,
extract the value from the pattern, and bind the extracted value to a variable.

Remarkable, `case` is not that convenient to match multiple number of values.

You may even use guard pattern in case expression to add more conditions to the pattern matching.
The underline `_` will represent the value to be matched.

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
