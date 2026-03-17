#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Types and Programming Lnaguages (Solution Set)]
#date[2026-03-09 00:21]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")


= Chapter III: Untyped Calculation Expressions

== Syntax

=== Exercise: How many elements are there in $S_3$?

Answer., $S_0$ is empty, $S_1$ has 3 elements,
$S_2$ has, 'succ true', 'succ false', ..., $3 * 3$, for second rule, and $3*3*3$ for third rule, totally $3 + 3*3 + 3*3*3 = 39$ elements.
And $S_3$ has $39 + 39*3 + 39*39*39 = 59319$ elements.

=== Exercise: Show that the sets $S_i$ are cumulative --- that is, that for each i we have $S_i subset.eq S_(i+1)$.

Proof., we can prove by induction on $i$.
Since $S_0$ is empty, $S_0 subset.eq S_1$ is true.

Assume $S_i subset.eq S_(i+1)$ is true, we need to show that $S_(i+1) subset.eq S_(i+2)$ is true.

According to the definition of $S_(i+2)$,
we have $S_(i+2) = S_(i+1) union { "succ" t | t in S_(i+1) } union { "pred" t | t in S_(i+1) } union { "iszero" t | t in S_(i+1) } union { "if" t_1 "then" t_2 "else" t_3 | t_1 in S_(i+1), t_2 in S_(i+1), t_3 in S_(i+1) }$.
Thus $S_(i+1) subset.eq S_(i+2)$ is true.

Then by induction, we have $S_i subset.eq S_(i+1)$ is true for all $i$.

== Induction on Terms

=== Suppose P is a predicate on terms.

- Induction on depth:
  ```txt
  If, for each term s,
    given P(r) for all r such thet depth(r) < depth(s),
    we can show P(s),
  then P(s) for all s.
  ;; i.e.,
  如果我们能做到以下两点：
    对任何项 (s), 假设所有 "深度比 (s) 小" 的项 (r) 都满足 (P(r))；
    在这个假设下, 我们能证明 (P(s)  成立；
  那么可以推出: 对所有项 (s), (P(s)) 都成立。
  ```
- Induction on size:
  ```txt
  If, for each term s,
    given P(r) for all r such that size(r) < size(s),
    we can show P(s),
  then P(s) for all s.
  ```
- Structural induction:
  ```txt
  If, for each term s,
    given P(r) for all immediate subterm r of s,
    we can show P(s),
  then P(s) for all s.
  ```
  这就是所谓的 "结构归纳法(structural induction)",
  也是在程序语言语法, 类型系统证明中使用最广泛的一种形式.
  它对应"语法树的递归结构:---就像递归定义一样, 归纳证明跟语法结构一一对应.


Induction on depth or size of terms is analogous to complete induction on natural numbers (2.4.2).
对"项的深度(depth)或大小(size)"进行归纳, 其实就类似于自然数的完全归纳法(complete induction).

"完全归纳法"与普通的数学归纳法不同, 它允许你在证明 (P(n)) 时假设 所有比 (n) 小的数 都满足 (P), 而不仅仅是 (P(n-1)).
同样地, 在"项的深度或大小归纳"中, 我们假设所有更小或更浅的项已经满足性质 (P).

就像自然数归纳法有不同的形式一样,
选择哪种 "项的归纳方式" (按深度, 按大小, 按结构) 取决于哪一种能让证明更简单.
形式上，这些归纳原理是可以互相推导的(inter-derivable)


Given for each term s, if we can show P(r) for all r with depth(r) < depth(s) implies P(s), then P(s) for all s.
We must prove that P(s) holds for all s.

Letting $Q(n) = forall s "with" "depth"(s) = n. P(s)$,

Apply natural number induction on n, we need to show that $Q(n)$ holds for all n.

First,
when depth of n is 1, then s is a constant, thus Q(s) holds.

Then, assume $Q(n)$ holds for all n < k, we need to show that $Q(k)$ holds.
When P(r) holds for all r with depth(r) < depth(s), we have P(s) holds, thus Q(k) holds.
Then by natural number induction, we have Q(n) holds for all n, thus P(s) holds for all s.

=== 3.5.10 Exercise: Rephrase Definition 3.5.9 as a set of inference rules.

Given definition:
- Def: The multiple step evaluation relation $->*$ is the reflexive, transitive closure of one-step evaluation.
  + if $t -> t'$, then $t ->* t'$
  + $t->* t$ for all $t$
  + if $t ->* t'$ and $t' ->* t''$, then $t ->* t''$

Then we have:
```txt
    t -> t'     (premise)
--------------- rule 1
   t -> * t'
--------------- rule 2
    t ->* t

  t ->* t'    t' ->* t''
-------------------------
         t->*t''

```

=== 3.5.13 Exercise:

Suppose we add a new rule:
$ "if" #true "then" t_2 "else" t_3 -> t_3 $[E-Funny]
to
$ "if" #true "then" t_2 "else" t_3 -> t_2 $[E-IfTrue]
$ "if" #false "then" t_2 "else" t_3 -> t_3 $[E-IfFalse]
$ (t_1 -> t'_1) / ("if" t_1 "then" t_2 "else" t_3 -> "if" t'_1 "then" t_2 "else" t_3) $[E-If]

Which of the theorems remain valid?

Answer:


Suppose add a new rule:
$ (t_2 -> t'_2) / ("if" t_1 "then" t_2 "else" t_3 -> "if" t_1 "then" t'_2 "else" t_3) $
Which of the theorems remain valid?


