# D-Flat Language Spec (Prelude)

## Prelude 预加载环境

### Primitive Types

### Definition

``` scheme
<define>        => '(' 'define' <name> [ '#:type' <type> ] <init> ')'
```

+ constants:
  When `<init>` for definition is a constant,
  then the symbol `<name>` represented that constant.
+ variable:
  `alloc:` family will allocate a space for specified type,
  and `new` family will allocate that space,
  and do default construct.
+ array:
  `alloc:` family function can allocate space for
  more than only one slot, this continuous space,
  traditionally, is call array.
  Provide an array directly to a function needs
  single value is not allowed.
  Array can be indexed or provide to a function in whole.
  Each array has its own type.
+ function
+ generic
+ macro
+ syntax rule

### Drop a value

``` scheme
<ignore>         => '(' 'ignore' ')'
```

### Intern

### Expression

#### Quotation

``` scheme
<quotation>      => '(' 'quote' <datum> ')'
```

#### Function

``` scheme
<lambda>         => 
'(' 'lambda' <formals> [ ('#:returns' <returning>) | ('=>' <returning>) ] 
    <body> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
<name>           => <symbol>
<type>           => <expression>
<initial>        => <literals>
<constraint>     => <expression>
<returning>      => '(' { <type> } ')'
                 |  <nil>
                 |  <type>
<body>           => <expression>
```

``` scheme
[<variable>] for value pass
<variable> for reference
(address <variable>) for pointer
```

``` scheme
<function>       => '(' 'function' <formals> <returning> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
<name>           => <symbol>
<type>           => <expression>
<initial>        => <literals>
<constraint>     => <expression>
<returning>      => '(' { <type> } ')'
                 |  <nil>
                 |  <type>
```

#### Logical Expression

``` scheme
<and>            => '(' 'and' { <test> } ')'
<or>             => '(' 'or' { <test> } ')'
<xor>            => '(' 'xor' { <test> } ')'
<not>            => '(' 'not' <test> ')'
```

#### Conditionals

``` scheme
<if>             => '(' 'if' <test> <consequent> [ <alternate> ] ')'
```

``` scheme
<cond>           => '(' 'cond' <entry> { <entry> } ')'
<entry>          => '(' <test> <consequent> ')'
                 |  '(' ':else' <consequent> ')'
```

``` scheme
<case>           => '(' 'case' <val> <entry> { <entry> } ')'
<val>            => <expression>
<entry>          => '(' <pattern> <consequent> ')'
                 |  '(' ':else' <consequent ')'
<pattern>        => <expression>
```

Pattern match utility:

``` scheme
<match>          => '(' 'match' <val> <entry> { <entry> } ')'
<val>            => <expression>
<entry>          => '(' <pattern> <consequent> ')'
                 |  '(' '_' <consequent ')'
<pattern>        => <expression>
```

#### Loop

``` scheme
<iter>           => '(' 'iter' '(' <binding-lst> { <binding-lst> } ')'  <body> ')'
<binding-lst>    => '(' <name> <enumerable> ')'
```

#### Assignment

`set!` is a generic function that works for any type
that implements `Assignable` interface.

``` scheme
<set!>           => '(' 'set!' <variable> <value> ')'
<variable>       => <expression>
<value>          => <expression>
```

Assignable

#### Binding Structures

``` scheme
<let>            => '(' 'let' '(' { <binding-lst> } ')' <body> ')'
<binding-lst>    => '(' <variable> [ '#:type' <type> ] [ <init> ] ')'

<let:fwd>        => '(' 'let:fwd' '(' { <binding-lst> } ')' <body> ')'
<let:rec>        => '(' 'let:rec' '(' { <binding-lst> } ')' <body> ')'
<let:rec:fwd>    => '(' 'let:rec:fwd' '(' { <binding-lst> } ')' <body> ')'

<for>            => '(' 'for' <name> '(' { <binding-lst> } ')' <body> ')'
```

#### Sequence

``` scheme
<sequence>       => '(' 'sequence' [ '#:tag' <name> ] <body> ')'
<body>           => <expression>
                 |  '(' ':break' [ '#:tag' <name> ] [ <value> ] ')'
<value>          => <expression>
```

#### Equivalent Predicate

``` scheme
<equal?>         => '(' 'equal?' <value1> <value2> ')'
```

### Number

+ Integer
+ Float
+ Bit Decimal

### Boolean

### Symbol

### Pair

### Character

### String

### Array

Array is some structure that is fixed-length and same-type-inside.

Array actually hold an array in literal.

### List

### Slice

### Error

### `alloc:stack`, `alloc:heap` & `new`

``` scheme
(alloc:stack <type> {<dimensions>})
(alloc:heap <type> {<dimensions>})
(new <type> ({<constructor parameters>}) {<dimensions>})
```

### Type

#### Interfaces

+ Assignable
+ Mutable

### Multiple Values

### `apply`

### `call/cc`

### `cc:values`

### `call/values`

### Tail Call & Tail Context
