# D-Flat Language Spec

## Lilies S-Expression IR Layer

### Introduction

#### basic types

`Variable` refers to a specified memory space.

Each `Symbol` represents those `Variables`.

All `Variable` contains an instance of specified class.

Except basic types and user-defined types,
there are two other different types, syntax type and structure internal type.

Built-in types (aka: basic types) are those used to compose a whole program and
provided by the environment.

Customer one (aka: user-defined) are those defined with `class` keyword.

Syntax type is used to construct macro,
which has the ability to change AST.

Structure internal type is something used in
parser/compiler and expression tree generator.

Built-in types are listed as follow:

- Boolean: the logical type, with only two available value, `#True` and `#False`, `none` value and `default` value are defined as `#False`
- Integer: the basic number type template, accept at most one argument, which is the bitwidth. `none` value and `default` value are `0` and has two extra public field, `max_val` and `min_val`,  which are the maxium value of the n-bit number and the minimal one.
- Unsigned: the unsigned number type template, similar to `Integer`.
- Float: the basic float point number template, accept at most two arguments, which are total length and cooresponding exponent bits. `none` value and `default` value are `0`
- Number: the large number type, similar to `float`.
- PS. All three numeric types can be presented in Decimal Form `[1-9][0-9,]*`, Hexdecimal form `0x0-9a-f,]+` or `0X[0-9A-F,]+`, Octal form `0[0-7,]+`, Binary form `0b[01,]+` and scientific form `[1-9][0-9,]*e[1-9][0-9,]`.
- Character: 32-bit character. Presented in the form of `#\'<Char>` or escaped form of `#\<character-description>`, ASCII form `#\a<Integer 8>`, Unicode form `#\u<Integer 32>`
- String: a ordered list of character, together with corresponding utilities.
- Symbols: name of some data, it is a objects itself.
- Pair: Container of two val pair.
The type shown above are most commonly used. There are other types constructs the basic structure of Db IR:
- Object: the basic class of all other classes, provides the dynamic programming ability.
  - get_type
  - name
- Class: Meta class, 'the class of class', provides the reflection ability.
  - name
- Function: callable objects, provide `invoke` method and `parameters`, `returing` meta class list. Using a pointer to handle function address.
- Pointer: a pointer points to some address, with a field `type` records the type of object points to, `none` and `default` value are defined as `(field (pointer) 'null')`. Comparation can only done between two pointer.
- Expression: a class records expression strucutre.
- Delegate:
- Interface: Base class for Interface, a kind of special class
- Record: Base class for Record, a kind of special class
The type(interface) shown after are provided in standard library:
- Vector: Constant length linear container with all elements share same type.
- <TODO>: Variable length linear container with different (possibily) type.
- List: Variable length linear container with all elements same type.
  - ArrayList:
  - LinkedList:
- Tuple: Constant length linear container with different (possibily) type.
- Enumerable: Iterable container.
- PS. Variable length linear container with different type can be implemented using pair.

User can define their own types through `class` keyword:

```
(class (<template-parameters> ... [. <template-parameters>])
    [#:extends (<inherits> ...)]
    [#:implements (<interface> ...)]
    [#:super <symbol>]
    [#:self <self>]
  (<self> <parameter-definition>
    <expression>)
  (:fields
    <accessibility> ...
    <field-definition> ...)
  (:properties
    <accessibility> ...
    <properties-definition> ...)
  (:methods
    <accessibility> ...
    <methods-definition> ...))

template-parameters   ::= <symbol>
                      |   (<symbol> [#:type-constraint <class>]
                                    [#:default <value>]
                                    [#:constraint <expression>])
inherits              ::= <class>
                      |   (<class> #:accessibility <accessibility>)
accessibility         ::= private | public | protected | internal
definition            ::= (define <name>
                             [#:initial <value>]
                             [#:type-constraint <class>])
                      |   (inherit <name>)
annotations           ::= #@\[<accessibility> <name>\]
field-definition      ::= <definition>
properties-definition ::= <definition>
methods-definition    ::= <definition>

(decorator ())

(interface ())

(records ())

(enumerator
  <enumerated-element-type> ...)
t
enumerated-element-type ::= <symbol>
                        |   (<symbol> <type-specifier>)
```

Any function defined within class with first parameter whose name is same as the :self parameter, is seen as method.
User defined classes can not inherit or be inherited by any other classes.
Methods can be implemented outside the class definition, let it contains declarations only.

User can also define interface using `interface`, most part of interface definition is same as class definition.
User is able to define `record`, they are some special class whose member cannot be modified.
User is able to define `enumerator`, they are some types that has only fixed number of named instence.
Enumerators elements can own their own type, and can be used to get enumeration number...
User can also define union using `class`, togther with `#@[offset ...]` annotation.

It is possible to use annotation to define destory method, the desotry method will be called each time the instance exit their life time.
Each class must provide empty instance, and cooresponding comparation method.
A class must provide `set` method if it is assignable.

Annotations can be user defined to give some variables attribution.

Syntax types are those used in macro definition, used to keep macro hygienic.
Syntax types has Macro, Syntax, Syntax-object, Immediate-syntax-mark, Immediate-Annotation-mark.

Internal types are those used to parser code, generate AST and generate assembly code.
Internal types may include Attribute, Reflector, Conditional, Lambda, Token, AST, and so on.

There are types outside the description above, which are meta type like int64, int32, word, double-word, byte, they are response to assembly language.

Outside tuple, the language provides multiple-value to return multiple value.

It is possible to 'static class', static class are collection of methods.

Enumerator's element also has its own type, for containing some special data together with the enumeration information.
Eg.

```
(define e-foo
  (enumerator
    base
    (type1 (integer 8))
    (tppe2 (string))
    ...))

({name e-foo} ({fetch e-foo} 'base)) ;; => 'base
({enum-val e-foo} ({fetch e-foo} 'type1)) ;; => 1
(define foo (new ({fetch e-foo} 'type2) "type2 str"))
({enum-val e-foo} foo) ;; => 2
({val foo}) ;; => "type2 str"
;; last two expression are executable because of static reflection
```

#### Symbols

Symbols are literal expression of all elements presented in the program text.
numbers's symbol are their literal value itself.
character string's (sentences) symbol are those presented within the quotations.

#### Annotations

Annotation are some special function used to specify the attribution of some variable or fields.
Annotation always have the pattern of  `#@[...]`.
For example, it is possible to implement `union` in c programming language with annotation `#@[offset <var> <offset-in-bytes>]`.
Annotation will generate a value which owns a internal type after executed within the compile progress.

#### Expression

The base of language is expression. Expressions can be calculated, evaluated, and generate on or multiple value.
Expression can be:

- constant / immediate / literal expression
  - `#True` / `#False`
  - `#\'a` / `#\escape` / `#\a0x61` / `#\a141` / ...
  - `1` / `1.0` / `1e10` / ...
  - `"str"` / ...
  - `'sym` / ...
  - ...
- function evaluation expression
  - `(add 0 1)` / ...
- macro expension expression
  - ...
- syntax expression
  - `(if <cond> <then> <else>)`
  - `(define <name> <init> <type>)`
  - `(lambda <parameter> <expression>)`
  - ...
Except literal expression, other three types of expression are combination.

#### Binding, Variable, Reference and Value pass

Variable are some specific memory space that contains effective infomation.
Use `define`, `rebind` and `let` (and its variations) to create binding between symbols and variables.
Variables are allocated by `allocate` (`allocate:stack`) and `allocate:heap`, or `instance:new` and `instance:initialize`.
allocate and its variations will assign space only, yet the new will perform construction as well.
The initialize will do construction on given space.
Use `address` to get the address of a variable.
A variable can be assigned with some value using `set`, if the class implements `set` method.
Otherwise, a exception will be thrown.
A more safe way to pass a varialbe into other function is reference.
Use #:ref mark in parameter definition will result in reference definition..
`destory` can clean a variable and free it. Otherwise, it is needed to check wether garbage collection is enabled.

Every instance allocated within stack may be cleaned after exit their function scope automatically (may be not available to access before the function exit, it also don't meant to not clean the variable until function exit).
Every instance allocated within heap may calculate their life time during compile time.
Only if the function has `#:ref` mark for the parameter, the ownership of heap-allocated variable will be moved.
Other wise, the value will be passed.
Thus, for some special case, the heap-allocated variable can be seen as managed by `unique_ptr` in c++.

`pointer` type are reference-counting variable manage method.

The symbol binding (to variables) are lexicial scope.

```
(define <name>
  <var>)

(defvar <name>
  <var>
  [doc])

(defun (<name> [parameters ...] [. rest])
  <expression>
  [doc])

(defun* (<head> [parameters ...] [.rest])
  <expression>
  [doc])
head     ::= <name>
         |   (<head> [parameters] [. rest])
define a currying function

(defclass (<name> [template-parameters ...] [. rest])
  (:fields
    <definition> ...)
  (:properties
    <definition> ...)
  (:methods
    <definition> ...))
defclass will fill reflection instructions automatically.

(defrule (<name> [patameters ...] [. rest])
  (rule ([patterms ...])
    <rules> ...))

(rebind <name>
  <var>)

(let (<definition> ...)
  <Expression>)
(letfwd (definition> ...)
  <Expression>)
(letrec (<definition> ...)
  <Expression>)
```

Use `define` will disable overload ability.
The `defun` can do auto overload detaction.
all `defun`, `defvar`, `defmacro` are child of `define`, and can be seen as short for `define:function`, `define:variable` and `define:macro`. So did `let` and other operations.

`let` creates local binding, the variable will only seen inside its body, so do its variants.
`define` creates binding inside closure.
Moreover, `dynamic` to define dynamic scope variables.

Define variables globally does not meaning export them.
Use `provide` to export symbol.
In case provide all symbol to the outside are ugly, it is possible to combine all symble about to be expot togther into a module.
`module` specified structure of symbols want to be exported.
`require` is used to import symbol.
Yet it is possible to import a module, which need `import` to extract, if wanted.

```
(set <instance>
  <val>)

(cast <instance>
  <type>)
```

It is also possible to cast one value to another, using `case` then.

It is possible to use annotation `#@[before_destory_hook]` to add compiler hook to a variable, when the variable is about to be destoried, the compiler will automatically invoke the hook function on the variable.
the annotation can also take effect on class, so that all instances of some special class will invoke callback function before exit automatically.

#### Form

All expressions are forms literally.
Expressions may execute sequencially using `sequence`.

```
(sequence [#:tag <symbol>]
  <expression> | (:return <value>) ...)
```

#### Comment

One-line comment starts with `;` mark.
Multiple line comment starts with `#;|` and ends with `|#`.

#### Function, method, macro, and calling

`lambda` expression is abstraction to procedure.
`function` is higher wrap to lambda expression.
`method` is some function whose first argument presents the object itself.

Every parameter are passed to function by value. Only and only if `#:ref` or `#:out` presented, the arguments will be treated as  reference.
`lambda` provides no wrap.

```
(lambda <parameter-definition>
  <Expression>
  <Return-declaration>)
parameter-definition ::= <parameter>
                     |   (<parameter> ... [. <parameter>])
                     |   (<parameter> ... [#&rest <parameter>])
parameter            ::= (<symbol> [<reference>]
                                   [#:type <class>]
                                   [#:default <val>]
                                   [#:constraint <expression>])
               |    (list <symbol> [#:type <class>])
               |    (array <symbol> [#:type <class>])
reference            ::= #:ref
                     |   #:out
return-declaration   ::= (<returning> ...)
returning            ::= <type>
```

Once the lambda expression done, it generates a function object.
Each time the function called, it indicates stack variable allocation by default if there are return values
thus, it is possible to catch the return value b `define` or `let` family.
functions, is possible to return multiple values by `values` expression.
Those expression will generate multiple value returning structure.
For simple, is a `Tuple`, but allocated in the stack directly without having objct structure.
Which means, multiple value structure has only compile time information.
the multiple value returning can be passed as arguments for another function directly, for which, it will replace the cooresponding parameter.
Eg.

```
(define foo
  (lambda ((a) (b))
     (values a b)))
;; A function that accepts two arguments which are 'a and 'b
;; 'a, 'b has no type specifier

(defun (bar (c #:type (integer 32))
            (d #:type (integer 16))
  (print (format '((:num c) (:num d)) c d)))
;; define another function called 'bar
;; which accepts two arguments, with type of integer

;; thus it is possible to:
(bar (foo 1 2))
;; for foo returns multiple value 1 and 2
;; and the values are treated as a series of variables that just appear in the stack
;; which has same effect as pushing values into the stack before calling a function
```

macro are something used to adjust AST when programming.
To define a macro, just wrap a lambda expression using `macro`.

macros are hygiene, which means the symbol inside the macro will never affect outside the macro.

macro has four types, for which are:

1. rule macro, which matches patterns appears in the code, and expend them into other module accrding to the rule.
2. syntex, a special macro affect the code generate, which, will impact syntax internal variables.
3. reader macro, which take its effect during the tokenizer process, transorm some form into another one.
4. compiler macro,

```
(macro
  <lambda-Expression>)

(syntax-case <syntax-object> (<reserve-object>)
  <pattern> ...)
```

It is possible to define methods for a class outside its class definition.
`defmethod` is able to implement a method.
and `defgeneric` can associate the method with an existing trait method.

#### apply & eval

`apply` and `eval` are two procedure that enpower the language.
Just as traditional Lisp, `apply` accepts a function and its argument list,
but forthermore, it can cooperate with key-argument pair
also, due to the function calling method, the apply also accepts a tuple as the last argument.

```
(apply <fn> [optional-parameters ...] <arguement-list>)
argument-list  ::= <list>
```

Eg.

```
(apply foo '(1 2))
(apply foo #:key '(:a :b) #:param '(1 2))
```

#### tail recursion

#### branch expression

- if cond then else

  ```
  (if <cond>
    <then>
    <else>)
  ```

- switch ... case : ...

  ```
  (switch <value>
    ((<value>+) [:case <tag>] <Expression>)
    (:else <Expression>))
  <Expresion> ::= <Expression> | (:goto <tag>) | (:break <expression>)
  ```

- case

  ```
  (case <value>
    ((<value>+) <Expression>) ...
    ((<value>+) => <lambda>) ...
    [(:else <Expression>)])
  ```

- condition

  ```
  (cond
    (<cond> <expression>) ...
    [(:else <expression>)])
  ```

#### loop

- loop

  ```
  (loop <Expression>)
  expression ::= <expression> | (:break <expression>)
  ```

- for

  ```
  (for <symbol> (<definition>*)
    <Expression>)
  ```

- while

  ```
  (while <cond>
    <Expression>)
  expression ::= <expression> | (:continue) | (:break <expression>)
  ```

- iter

  ```
  (iter (<symbol> <iterable>)
    <Expression>)
  expression ::= <expression> | (:continue) | (:break <expression>)
  ```

- map
- foldl
- foreach
- filter
- select
- distinct
- except
- groupby
- where

#### member, index & reference

`member` mthod is used to find some named field (or method) within a class (or namespace/ module/ etc.).
`index` method used to index a continous area of memory, or, other way, index some unnamed variable within linear structure.

Defination creates binding between variable and symbol.
Life time calculation calculates viriable only, which will not concerning symbol.
define one symbol with another one will result in create two reference to one variable.

variable declared to be defined in heap are auto moved.
`#:ref` mark will result in owner ship movement.
`#:in` mark will not, any way. For it will create only static reference.

#### method, field, property & fetch

`method` method is used to fetch method of some clas.
use brackets for short.
Eg.

```
(method (array (integer 8)) index)
;; same as
{index (array (integer 8))}
```

#### get, set

`get` method is able to get a property of a object
and `set` method is used to modify the value of a object (and property inside it).

```
({get obj} 'val)
({set obj} 'val new-val)
(set obj new-val)
```

#### reflection

##### static reflection

##### dynamic reflection

#### Continuation

#### Exception handling

#### Syntax / Syntax object

#### Library

#### Top-level

### Requirement

#### Syntax

##### literal

##### Data

#### Symbol

## Margaret

### Introduction

#### Basic types

#### Functions

```
function ([parameter-types ...]) [=> <return-types> ...]{
  <body>
}
```
