#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Types and Programming Lnaguages]
#date[2026-02-13 23:45]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Chapter III: Untyped Calculation Expressions

```
type ::                                   ;; Term
  | true                                  ;; True
  | false                                 ;; False
  | if type then type else type           ;; If
  | 0                                     ;; Zero
  | succ type                             ;; Successor
  | pred type                             ;; Predecessor
  | iszero type                           ;; IsZero
```

The type appeared in right part of syntax is called "meta variable", which can be replaced by any valid type.
For example, the meta variable "type" in "if type then type else type" can be replaced by "true",
"false", "0", "succ 0", etc.
The meta variable is a placeholder for any valid type, and it allows us to define the syntax of the language in a more general way.

== Syntax

The formal definition for the grammar is defined by induction.
+ ${"true", "false", 0} subset.eq Tau$
+ if $t_1 in Tau$, then ${"succ" t_1, pred t_1, "iszero" t_1} subset.eq Tau$
+ If $t_1 in Tau$, $t_2 in Tau$, $t_3 in Tau$, then $"if" t_1 "then" t_2 "else" t_3 in Tau$



