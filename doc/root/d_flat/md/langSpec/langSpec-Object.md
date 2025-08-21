# D-Flat Language Spec (Object)

## Object System

+ Class:

``` scheme
<class>          =>
'(' 'class' <inherits>
   [ '#:super' <super> ]
   [ '#:self' <self> ]
   { <fields> }
   { <properties> } ')'

<inherits>       => '(' { <class> } ')' 
; Always null for all class are defined as final
; and inherits Object by default
; The inherits trait here only means this class inherits sth.
<fields>         =>
'(' ':fields' <deffield> { <deffield> } ')'
<properties>     =>
'(' ':properties' <defprop> { <defprop> } ')'

<deffield>       =>
'(' 'define' <name> [ '#:type' ] <type> [ <init> ] ')'
<defprop>        =>
'(' 'define' <name> [ '#:type' ] <type> <init> <getter> <setter> ')'
```

+ Field & property

``` scheme
<get>            => '(' 'get' <name> <object> ')'
<name>           => <symbol>
<object>         => <expression>
```

+ Type Self Reference

``` scheme
<Self>           => '&Self'
```

+ Interface

``` scheme
<interface>      =>
'(' 'interface' <inherits>
   <methods>
  { <methods> } ')'
```

To drop a implement for some interface of a type in some case,
use `drop`.

``` scheme
<drop>           => '(' 'drop' <type> <interface> { <interface> } ')'
```

+ Method

``` scheme
<method>         => '(' 'define' <name> <lambda> ')'
<lambda>         => '(' 'lambda' <formals> [ '#:returns' <types> ] <body> ')'
<formals>        => '(' { <param> } ')'
                 |  <param>
                 |  '(' <param> . <param> ')'
<param>          => '(' [ <pass> ] <name> <type> [ <initial> ] [ <constraint> ] ')'
                 |  [ <pass> ] <self>
<pass>           => '#:ref'         ; pass by reference
                 |  '#:in'          ; pass by reference, read only
                 |  '#:out'         ; pass by reference, ignore value
                 |  '#:val'         ; pass by value
                 |  '#:move'        ; do ownership move
```

+ Implement

``` scheme
<implement>      =>
'(' 'implement' <class> [ <interface> ]
   <method>
   { <method> } ')'
```

+ Generic
