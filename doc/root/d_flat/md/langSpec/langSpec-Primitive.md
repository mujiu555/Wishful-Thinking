# D-Flat Language Spec (Primitive)

## Primitive Syntax

### Primitive Expression Types

#### Literals

#### Variable Reference

#### Procedure Call

``` scheme
<call>          => (<operator> <operand> ...)
<operator>      => <expression>
<operand>       => [ '#&' <name> ] <expression>
```

#### Method Call

For static dispatch:

``` scheme
((method <object> <operator-name>) <object> <operand> ...)
```

For dynamic dispatch:

``` scheme
(invoke <object> <operator-name> <operand> ...)
```

#### Method Call Abbreviation

``` scheme
({<operator-name> <object>} <operand> ...)
;; which is same as
((method <object> <operator-name>) <object> <operand> ...)

({<operator-name> <class>} <operand> ...)
;; which is same as
((method <class> <operator-name>) <operand> ...)
```

#### Chained Calls Abbreviation

Returning value of last expression (calling) will be placed at the place-holder,
and then evaluate the next expression.

Each expression in a chained call must have and only have one place-holder appeared.

Place-holder are `:~` in this case.

``` scheme
<chain>         => '(' 'chain' <object> <calling> { <calling> } ')'
<calling>       => '(' <operator> { <place-holder> | <argument> } ')'
                |  '(' '{' <name> '}' { <arguemnt> } ')'
<name>          => <symbol>
```

### Annotation

``` scheme
<Annotation>    => '#@(' <name> { <operand> } ')'
<name>          => <symbol>
```

### Procedure Macro

### Reader Macro

### Syntax Rules

### Expander
