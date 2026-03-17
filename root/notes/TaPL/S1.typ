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
+ if $t_1 in Tau$, then ${"succ" t_1, "pred" t_1, "iszero" t_1} subset.eq Tau$
+ If $t_1 in Tau$, $t_2 in Tau$, $t_3 in Tau$, then $"if" t_1 "then" t_2 "else" t_3 in Tau$

In this way, we defined the language as a smallest set of terms that satisfy the above conditions.
Formally, the definition defines T as the set of tree, rather than strings.

Or: defined by rules:

Axioms:
$ #true in T $
$ #false in T $
$ 0 in T $

Rules:
$ (t_1 in T) / ("succ" t_1 in T) $
$ (t_1 in T) / ("pred" t_1 in T) $
$ (t_1 in T) / ("iszero" t_1 in T) $

Rules with multiple premises:
$ (t_1 in T, t_2 in T, t_3 in T) / ("if" t_1 "then" t_2 "else" t_3 in T) $

If the condition above the line is satisfied, then statement below the line is true.
The term above the line is called "premise", and the term below the line is called "conclusion".

Something without predicate is called "axiom", which is always true.

Finally, we can define terms using set operations, which gives a more specific process of finding elements in the set:
#html.align(center, table(
  columns: 3,
  stroke: none,

  $S_0$, $=$, $emptyset$,
  $S_(i+1)$, $=$, ${#true, #false, 0}$,
  $$, $$, $union {"succ" t_1, "pred" t_1, "iszero" t_1 | t_1 in S_i}$,
  $$, $$, $union {"if" t_1 "then" t_2 "else" t_3 | t_1, t_2, t_3 in S_i}$,
))
And let $S = union_(i) S_i$ for $i in N$, then $S$ is the set of all terms.

== Induction on Terms

With definition above we can find some properties for all terms,
If $t in T$, then we can give inductive definitions of functions over the set of terms.
Thus,

Def: The set of constants appearing in the term $t$, denoted as $"Consts"(t)$, is defined as follows:
$ "Consts"(#true) = {#true} $
$ "Consts"(#false) = {#false} $
$ "Consts"(0) = {0} $

$ "Consts"("succ" t) = "Consts"(t) $
$ "Consts"("pred" t) = "Consts"(t) $
$ "Consts"("iszero" t) = "Consts"(t) $

$ "Consts"("if" t_1 "them" t_2 "else" t_3) = "Consts"(t_1) union "Consts"(t_2) union "Consts"(t_3) qed $

Also, size, and depth:
Def: The size of a term $t$, denoted as $"size"(t)$, is defined as follows:
$ "size"(#true) = 1 $
$ "size"(#false) = 1 $
$ "size"(0) = 1 $

$ "size"("succ" t) = "size"(t) + 1 $
$ "size"("pred" t) = "size"(t) + 1 $
$ "size"("iszero" t) = "size"(t) + 1 $

$ "size"("if" t_1 "them" t_2 "else" t_3) = "size"(t_1) + "size"(t_2) + "size"(t_3) + 1 qed $

Def: The depth of a term $t$, denoted as $"depth"(t)$, is defined as follows:
$ "depth"(#true) = 1 $
$ "depth"(#false) = 1 $
$ "depth"(0) = 1 $
$ "depth"("succ" t) = "depth"(t) +1 $
$ "depth"("pred" t) = "depth"(t) +1 $
$ "depth"("iszero" t) = "depth"(t) +1 $
$ "depth"("if" t_1 "them" t_2 "else" t_3) = max("depth"(t_1), "depth"(t_2), "depth"(t_3)) + 1 qed $

Thus we can assume:
Lemma: The number of distinct constants in a term $t$ is less than or equal to the size of $t$.

Idea: to prove the lemma, it is needed to show that for any term smaller than t, the lemma holds, and then show that the lemma holds for t.
Since the depth of t is defined by induction.
Thus we must have fully considered all cases.

Proof: By induction on the depth of $t$, assume the lemma holds for all terms with depth less than $d$, and let $t$ be a term with depth $d$.
1. Case: $t "is a constant"$,
Immediate: $|"Consts"(t)| = 1 <= "size"(t) = 1$.
2. Case $t = "succ" t_1, "pred" t_1, "iszero" t_1$,
By the induction hypothesis (assumption),
$ |"Consts"(t)| = |"Consts"(t_1)| <= "size"(t_1) < "size"(t) $.
3. Case $t = "if" t_1 "then" t_2 "else" t_3$,
$ |"Consts"(t)| = |"Consts"(t_1) union "Consts"(t_2) union "Consts"(t_3)| $
$ <= |"Consts"(t_1)| + |"Consts"(t_2)| + |"Consts"(t_3)| <= "size"(t_1) + "size"(t_2) + "size"(t_3) < "size"(t) $.

== Semantic Style

+ Operational semantics: defines the behaviour of a pl by define abstract machine (automata).
  - Small-step (structural operational) semantics: defines transitions, with a t in language, it will always transition to another, simplifying until it reaches final.
  - Big-step (natural) semantics: defines the behaviour of a pl by define a relation between terms. Evaluation a term directly to its final state.
+ Denotational semantics: defines the meaning of a pl by letting each term denote a mathematical object,
  and then collect those objects into a semantic domains, find corresponding interpretation function that mapping terms into elements of those domains.
  Abstracts from the details of evaluation, highlight the essential concepts of the language.
  The properties of selected domains can reasoning about the behaviour of the pl.
  Prove the two program have exactly the same behaviour.
  Knowing some thing is not possible in a pl.
+ Axiomatic semantics: two method before defines the behaviour of programs first and then derive the laws from the definition.
  While axiomatic semantics take the laws as the definition for language.
  The meaning of terms is just what can be proved about them.

== Evaluation

Given:

Syntax:
```
t ::=                             ;; terms
  true                            ;; constant true
  | false                         ;; constant false
  | if t then t else t            ;; conditional
;; and
v ::=                             ;; values
  true                            ;; true value
  false                           ;; false value
```

First set of rules, is just the repetition of the syntax,
and the second set defines a subset of terms called values, the possible results of evaluation.

And we have the evaluation relation on terms:

Evaluation: $t -> t'$

$ "if" #true "then" t_2 "else" t_3 -> t_2 $[E-IfTrue]
$ "if" #false "then" t_2 "else" t_3 -> t_3 $[E-IfFalse]
$ (t_1 -> t'_1) / ("if" t_1 "then" t_2 "else" t_3 -> "if" t'_1 "then" t_2 "else" t_3) $[E-If]

If $t$ is a state of the abstract machine at a given moment, then the machine can make a step of computation and change its state to $t'$.

+ `E-IfTrue` says that if the condition of an if expression is true, then the whole expression evaluates to the "then" branch.
+ `E-IfFalse` does the similar thing for false condition.
+ `E-If` have if the guard $t_1$ evaluates to $t'_1$, then the whole expression evaluates to another, which in terms of abstract machine, the machine can step to another state if another machine says $t_1$ can step to $t'_1$.

What the rules not said it as important as what they said.
+ `true` or `false` will not evaluate to any other thing since they are not appearing in the left hand side of any rule,
+ the branch of `if` will not be evaluated until the guard is evaluated to a value.

Formally, we can define the evaluation relation:

- Def: an instance of an interface rule is obtained by consistently replacing each metavariable by the same term in the rule's conclusion and all its premises.
- Def: a rule is satisfied by a relation if, for each instance of the rule, either the conclusion is in the relation or one of the premises is not.
  对于每个规则的实例, 要么结论在关系中, 要么前提之一不在关系中
  即, 对于每个可能满足规则的组合, 要么满足结论(在ranges中), 要么不满足前提(不在domain中)
  如, universe_d = { 1, 2, 3 }, universe_r = { 4, 5, 6 } and d = { 1, 3 }, r = { 4, 6 }, aRb = { (1, 4), (3, 6) },
- Def: a one-step evaluation relation $->$ is the smallest binary relation on terms satisfying the three rules above.
  When the pair $(t, t')$ is in the evaluatoin relation, we say that the "evaluation statement (or judgment) $t -> t'$ is derivable".
  最小, 表示仅有满足规则的组合, 没有其他组合满足,
- Theorem: If $t -> t'$ and $t -> t''$, then $t' = t''$. Determinacy of one-step evaluation. 单步求值的确定性
  Proof: By induction on the derivation of $t -> t'$.
  + Case `E-IfTrue` or `E-IfFalse`, the conclusion is determined by the rule, thus $t' = t''$.
  + Case `E-If`, the conclusion is determined by the evaluation of $t_1$, thus $t' = t''$.
- Def: If a term $t$ has no evaluation rule applies to it, it is in normal form.
- Theorem: Every value is in normal form.
- Theorem: IF t is in normal form, then t is a value.
- Def: The multiple step evaluation relation $->*$ is the reflexive, transitive closure of one-step evaluation.
  + if $t -> t'$, then $t ->* t'$
  + $t->* t$ for all $t$
  + if $t ->* t'$ and $t' ->* t''$, then $t ->* t''$
- Theorem: If $t->*u$ and $t ->* u'$, where u and $u'$ are both normal forms, then $u = u'$.
- Theorem: For every term t there is some normal form $t'$ such that $t ->* t'$.

Add new definition to previous syntax:
```txt
t ::=                             ;; terms
  true                            ;; constant true
  | false                         ;; constant false
  | if t then t else t            ;; conditional
  | 0                             ;; zero
  | succ t                        ;; successor
  | pred t                        ;; predecessor
  | iszero t                      ;; zero test

v ::=                             ;; values
  true                            ;; true value
  | false                         ;; false value
  | nv                            ;; numeric value

nv ::=                            ;; numeric values
  0                               ;; zero
  | succ nv                       ;; successor of a numeric value
```

Rules:
$ "if" #true "then" t_2 "else" t_3 -> t_2 $[E-IfTrue]
$ "if" #false "then" t_2 "else" t_3 -> t_3 $[E-IfFalse]
$ (t_1 -> t'_1) / ("if" t_1 "then" t_2 "else" t_3 -> "if" t'_1 "then" t_2 "else" t_3) $[E-If]
$ (t_1 -> t'_1) / ("succ" t_1 -> "succ" t'_1) $[E-Succ]
$ "pred" 0 -> 0 $[E-PredZero]
$ "pred" ("succ" "nv") -> "nv" $[E-PredSucc]
$ (t_1 -> t'_1) / ("pred" t_1 -> "pred" t'_1) $[E-Pred]
$ "iszero" 0 -> #true $[E-IsZeroZero]
$ "iszero" ("succ" "nv") -> #false $[E-IsZeroSucc]
$ (t_1 -> t'_1) / ("iszero" t_1 -> "iszero" t'_1) $[E-IsZero]

The "pred (succ nv) -> nv" rule indicates that there does not exist something like "pred (succ (pred 0)) -> pred 0",
thus, the evaluation of this term will have following derivation tree:
```txt

--------------------------------------- E-PredZero
               pred 0 -> 0
--------------------------------------- E-Succ
          succ (pred 0) -> succ 0
--------------------------------------- E-Pred
 pred (succ (pred 0)) -> pred (succ 0)

```

- Def: A closed term is stuck if it is in normal form but not a value.
  If a term is stuck, it means that the evaluation of the term cannot proceed, but it is not a value, thus it is an error.
- Another way to deal with stuck is introducing an explicit error term, and add rules to propagate the error.
