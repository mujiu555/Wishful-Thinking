/// TAG: computation theory
#import "@preview/cetz:0.4.2" as cetz
#import "@preview/cetz-plot:0.1.3"
#import "@preview/cetz-venn:0.1.4"
#import "@preview/finite:0.5.0": automaton
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/tablex:0.0.9": *

#import "/lib/lib.typ": *

#show: schema.with("page")

#title[MIT 18.404j Theory of Computation (junior)]
#date[2025-12-18 21:24]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Applications

= Modules of computation

Capture important aspect of thing we try to understand.

== Finite Automata

Use less memory with limited ability of computation.

#html.align(center, inline(scale: 200%, block(fill: color.white, automaton(
  (
    q1: (q1: 0, q2: 1),
    q2: (q1: 0, q3: 1),
    q3: (q3: "0,1"),
  ),
  final: ("q3",),
  initial: "q1",
))))

Each have different
- Stats: $q_1, q_2, q_3$
- Transitions: $arrow^1$
- Start State: #inline(scale: 100%, block(fill: color.white, automaton((q1: ()), initial: "q1", final: ())))
- Accepted state: #inline(scale: 100%, block(fill: color.white, automaton((q3: ()), initial: (), final: "q3")))

Give finite string as input, and have output of accepted or reject.

Begin at start state, read input symbols, follow corresponding transitions, Accept if end with accept state, Reject if not.

We say that "M_1 accepts exactly those string in A where $A = {w | w "contains substing 11"}$".
And, we have A that is the language accepted by the language $L(M_1)$.
$M_1$ recognize A and $A = L(M_1)$.

=== Define a finite automation

Defn: A finite automaton M is a 5-tuple $(Q, Sigma, delta, q_0, F)$:
- Q: finite set of states
- $Sigma$: finite set of alphabet symbols
- $delta$: transition function $delta: Q times Sigma -> Q$
  $delta$, somehow is, a kind of relation, give a state and a accepted symbol, then returns a (maybe) new state.
  Eg. $delta(q, a) = r =>$  #inline(automaton((q: (r: "a"), r: ()), initial: (), final: ()))
- $q_0$: start state
- $F$: set of accept states

For example above:
- $M_1 = (Q, Sigma, delta, q_1, F)$,
- $Q = {q_1, q_2, q_3}$,
- $Sigma = {0, 1}$,
- $F = {q_3}$.
And have:

#html.align(left, inline(scale: 200%, table(
  columns: 3,
  stroke: none,
  table.hline(),
  table.header([$delta=$], [0], [1]),
  table.hline(stroke: 0.5pt),
  $q_1$, $q_1$, $q_2$,
  $q_2$, $q_1$, $q_3$,
  $q_3$, $q_3$, $q_3$,
  table.hline(),
)))

=== String and languages

- A string (word) is a finite sequence of symbols in $Sigma$ (alphabet),
- A language is a set of strings (finite or infinite),
- A empty string $epsilon$ is a string of length 0
- The empty language $emptyset$ is the set with no strings.

Defn: M accepts string $w = w_1 w_2 ... w_n$ each $w_i in Sigma$
if there is a sequence of states $r_1, r_2, ... r_n in Q$
where:
- $r_0 = q_0$, state sequence starts at initial state,
- $r_i = delta(r_(i-1), w_i) "for" i <= i <= n$, each state transition from previous one defined by transition functions,
- $r_n in F$, whole sequence must be accepted.

Recognizing languages:
- $L(M) = {w|M "accepts" w}$,
- $L(M) "is the language of" M$
- M recognizes L(M)
Every machine can accept many words, but only one language.

Define: a language is regular if some finite automaton recognizes it.

=== Regular Languages

$L(M_1) = {w|w "contains substing 11"} = A$

= Regular Expressions

== Regular Operations

Let A, B be languages:
- Union: $A union B = {w| w in A or w in B}$,
- Concatenation: $A circle B = {x y | x in A and y in B} = A B$,
- Kleene Star: Unary operation: $A^* = {x_1 ... x_k| "each" x_i in A "for" k >= 0}, epsilon in A^*$
Note., empty language won't accept empty string, but Kleene star of empty language will.

== Regular expression

Like mathematical expression comes from combination of mathematical operations and mathematical elements,
regular expression comes form combination of regular operations and languages.

- Built form $Sigma$ (Alphabet), members $Sigma$, $emptyset$ (Empty language), $epsilon$ (empty word), [atomic]
- Using $union$, $circle$, $*$, [Composite]

E.g., $(0 union 1)^* = Sigma^*$ gives all strings over $Sigma$.

Finite automata equivalent to regular expressions.

= Closure Properties for regular languages

If some set are closed under some operation, which means
after applying those operations on objects, the result will still leave in the same class of objects.

== Union:

If $A_1, A_2$ are regular languages, so is $A_1 union A_2$ (closure under $union$)

Proof:
let $M_1 = (Q_1, Sigma, delta_1, q_1, F_1) "recognize" A_1$,\
and $M_2 = (Q_2, Sigma, delta_2, q_2, F_2) "recognize" A_2$.\
Assuming $M = (Q, Sigma, delta, Q_0, F) "recognize" (A_1 union A_2)$,\
$M$ should accept input $w$ if either $M_1$ or $M_2$ accept $w$.

Compose $M_1 "and" M_2$ together,
then components of M: $Q = Q_1 times Q_2 = { (q_1, q_2) | q_1 in Q_1 "and" q_2 in Q_2}$,
$q_0 = (q_1, q_2)$
And, $delta((q, r), a) = (delta_1(q, a), delta_2(r, a))$
$F = (F_1 times Q_2) union (Q_1 times F_2)$

Note., if $F = F_1 times F_2$, then it could be closure under intersection.

== Concatenation:

If $A_1, A_2$ are regular languages, so is $A_1 circle A_2$ (closure under $circle$)

Assuming $M$ accept input $w$, if $w = x y$ where, $M_1 "accepts" x$ and $M_2 "accepts" y$
But failed.

Proof:
Let $M_1 = (Q_1, Sigma, delta_1, q_1, F_1) "recognize" A_1$, and $M_2 = (Q_2, Sigma, delta_2, q_2, F_2) "recognize" A_2$.
Construct $M = (Q, Sigma, delta, q_0, F) "recognize" (A_1 circle A_2)$.

Then the machine $M$ should accept input $w$ if there is a split of w into $x y$ where $M_1$ accepts $x$ and $M_2$ accepts $y$.

#html.align(center, inline(scale: 200%, figure(
  block(
    automaton(
      (
        q1: (),
        q2: (),
        q3: (),
        q4: (),
        q5: (),
      ),
      final: ("q5", "q4"),
    ),
  ),
  caption: $M_1 "accepts" "language" A_1$,
)))

#html.align(center, inline(scale: 200%, figure(
  automaton(
    (
      q1: (),
      q2: (),
      q3: (),
    ),
    final: ("q3",),
  ),
  caption: $M_2 "accepts" "language" A_2$,
)))

And then construct M:

#html.align(center, inline(scale: 200%, figure(
  automaton(
    (
      q1_1: (),
      q1_2: (),
      q1_3: (),
      q1_4: (q2_1: "epsilon"),
      q1_5: (q2_1: "epsilon"),
      q2_1: (),
      q2_2: (),
      q2_3: (),
    ),
    final: ("q2_3",),
    initial: "q1_1",
  ),
  caption: $M "accepts" "language" (A_1 circle A_2)$,
)))

If there are input word $w$, then there should be a split point where $M_1$ reach accept state and jump to $M_2$ via $epsilon$ transition.

Construct a new machine, concatenating $M_1$ and $M_2$ together with $epsilon$ transitions from each accept state of $M_1$ to the start state of $M_2$.

But the first place machine reach accept state may not be the correct split point. M need to have a idea of all possible split points.
= Non-determinism

#html.align(center, inline(scale: 200%, figure(
  automaton(
    (
      q1: (q2: "a", q1: "a"),
      q2: (q1: "b", q3: "b"),
      q3: (q4: "a, epsilon"),
    ),
    final: ("q4",),
    initial: "q1",
  ),
  caption: "A non-deterministic finite automaton",
)))

It is mostly same as deterministic finite automaton,
In deterministic finite automaton, there is exactly one transition for each state and input symbol pair.

The non-deterministic finite automaton may have different transitions for same state and input symbol pair, and this is so called non-determinism.

You may have one transition to go to one state, or another transition to go to another state.

It is also able to have epsilon transitions, which means it can go to another state without consuming any input symbol.

For non-deterministic finite automaton, it can accept inputs if some paths leads to accept states.
If there is one finite machine, accept always prior to reject.
The only possible reject state is when all possible paths lead to non-accept states.

The possible status of a non-deterministic finite automaton can form a tree structure.
Since at each state, there may be multiple possible transitions for same input symbol.

E.g., for input "ab" for given automaton above,
possible status can be:

#html.align(
  center,
  inline(scale: 150%, figure(
    diagram(
      cell-size: 3pt,
      $
        & "start" edge("ld", a, ->) edge("rd", a, ->) & & & \
        q_1 edge("d", "-->")& & q_2 edge("ld", b, ->) edge("rd", b, ->) & & \
        "rejected" & q_1 edge("d", "-->") & & q_3 edge("d", epsilon, ->) & \
        & "rejected" & & q_4 edge("d", "-|>") &\
        &&&"accepted" &
      $,
    ),
    caption: [Tree graph for possible status of non-deterministic finite automaton],
  )),
)

Any way that leads to accept state is accepted.

For "aa", it will never reaches accept state.

== NFA

Defn: A nondeterministic finite automaton, 5-tuple $(Q, Sigma, delta, q_0, F)$:
- Q: finite set of states
- $Sigma$: finite set of alphabet symbols
- $delta$: transition function $delta: Q times Sigma_epsilon (Sigma union {epsilon}) -> P(Q) = {R | R subset.eq Q}$
  $delta$, a kind of relation, give a state and a accepted symbol (or epsilon), then returns a set of (maybe) new states.
  Eg. $delta(q, a) = {r, s} =>$  #inline(automaton((q: (r: "a", s: "a"), r: (), s: ()), initial: (), final: ()))
- $q_0$: start state
- $F$: set of accept states

E.g., in above example:
- $delta(q_1, a) = {q_1, q_2}$
- $delta(q_1, b) = emptyset$

Computation processes of NFA is a kind of BFS:
- Every time the machine read an input symbol, it will branch out to all possible next states.
- Every time the machine find a accept state, it will accept the input immediately.
  Which discard all other possible paths.

Or, you may image the machine can make good guesses at each step,
which always choose the correct transition to reach accept state if there is one.

= NFA and DFA equivalence

NFA and DFA are equivalent in power, which means any language recognized by NFA can also be recognized by DFA, and vice versa.

== NFA to DFA

Theorem: If an NFA recognizes a language L, then L is regular.

Proof:
Let NFA $M = <Q, Sigma, delta, q_0, F>$ recognize L.\
Construct DFA $M' = <Q', Sigma, delta', q_0', F'>$

Basically, DFA $M'$ keeps track of the subset of states in NFA $M$.
Simulate the processes of NFA, every time the symbol is read, DFA $M'$ update its state to the set of possible states that NFA $M$ may reach.

The way to archieve this is to
set a state for every possible subset of states in NFA $M$.
For each state in DFA $M'$, which is a possible subset of states in NFA $M$, remember which subset of states NFA in.

Construction of DFA $M'$:
- $Q' = P(Q) = {R | R subset.eq Q}$, the set of all possible subsets of states in NFA $M$.
- $delta'(R, a) = {q| q in delta(r, a) "for some" r in R}, R in Q$
- $q_0' = {q_0}$
- $F' = {R in Q' | R inter F}$

Then, DFA $M'$ simulates NFA $M$ by keeping track of all possible states that NFA $M$ may reach after reading input string.

From the construction,
Start at the state ${q_0}$ in NFA $M'$, which corresponds to the start state $q_0$ in DFA $M$,
try to attach all possible states that NFA $M$ may reach after reading input string,
Thus a subset of states in NFA $M$ can be formed, which is a state in DFA $M'$.
Then start at each state in NFA $M$, follow the same rule, try all possible transitions for each input symbol,
construct new subset of states in NFA $M$, which is a new state in DFA $M'$.
Then start at each new constructed subsets, search all possible transitions for each input symbol with each state in the subset.
- If any one of the state can reach an new state, then add that new state into the new subset.
- If any one of the state in the subset is an accept state in NFA $M$, then the new subset is also an accept state in DFA $M'$.
Recursely do this until no new subsets can be formed.

P.S., with this construction, some states in DFA $M'$ may be unreachable from the start state ${q_0}$, discard those states.
With this construction, some states in DFA may not able to reach any accept states, those states can be considered as dead states.
Discard those or keep those states as you like.

P.S., If any one of the state have epsilon transitions, then add those reachable states via epsilon transitions into the subset as well.

E.g., for NFA above:

#html.align(center, inline(scale: 200%, table(
  columns: 5,
  stroke: none,
  table.hline(),
  table.header([type], [states], $delta(Q, a)=$, $delta(Q, b)=$, [explain]),
  table.hline(stroke: 0.5pt),
  [start $->$], $q_1$, ${q_1, q_2}$, $emptyset$, [],
  [], ${q_2}$, $emptyset$, ${q_1, q_3, q_4}$, [q_2 reaches q_3, and then via epsilon to q_4],
  [], ${q_3}$, ${q_4}$, $emptyset$, [],
  [], ${q_4}$, $emptyset$, $emptyset$, [end of regular state in NFA],
  //
  table.hline(stroke: 0.5pt),
  [],
  ${q_1, q_2}$, ${q_1, q_2}$, ${q_1, q_3, q_4}$,
  [q_1 and q_2 can only reach q_1 via a;\
    q_2 can reach to q_1 via b, and q_3 via b,\
    then via epsilon to q_4],
  [accepted:], ${q_1, q_3, q_4}$, ${q_1, q_2, q_4}$, $emptyset$, [accepted because contains q_4],
  [accepted:],
  ${q_1, q_2, q_4}$,
  ${q_1, q_2}$,
  ${q_1, q_3, q_4}$,
  [since q_2 can never reach q_3 via a, \
    but b, and then epsilon to q_4],
  table.hline(),
)))

Since no branch sketch to dead state ${q_2}$ or ${q_3}$ or ${q_4}$, those states can be discarded.

Which have a image like:

#html.align(center, inline(scale: 200%, figure(
  automaton(
    (
      "{q1}": ("{q1, q2}": "a"),
      //"{q2}": ("{q1, q3, q4}": "b"),
      //"{q3}": ("{q4}": "a"),
      "{q1, q2}": ("{q1, q2}": "a", "{q1, q3, q4}": "b"),
      "{q1, q3, q4}": ("{q1, q2, q4}": "a"),
      "{q1, q2, q4}": ("{q1, q2}": "a", "{q1, q3, q4}": "b"),
    ),
    final: ("{q1, q3, q4}",),
    initial: "{q1}",
  ),
  caption: [DFA equivalent to NFA],
)))

== Recall for Closure Properties

- Union:
  Construct a new NFA that connect two start states of two NFA via epsilon transitions from a new start state.
  And then everything done.
- Concatenation:
  Construct a new NFA that connect each accept state of first NFA to the start state of second NFA via epsilon transitions.
  And then everything done.
- Star:
  Construct a new NFA that connect each accept state of NFA back to the start state via epsilon transitions.
  Also, add a new start state that is also an accept state, and connect it to the old start state via epsilon transition.
  And then everything done.

== Regular Expression to NFA

Theorem: If R is a regexpr and $A = L(R)$ then A is regular.

Proof:

Basically, Convert R to equivalent NFA $M$,
- If R is atomic:
  - $R = a "for a symbol" a in Sigma$: #inline(automaton((q1: (q2: "a"), q2: ()), initial: "q1", final: "q2"))
  - $R = epsilon$: #inline(automaton((q1: (q2: "epsilon"), q2: ()), initial: "q1", final: "q2")) or #inline(automaton((q1: ()), initial: "q1", final: "q1"))
  - $R = emptyset$: #inline(automaton((q1: ()), initial: "q1", final: ()))
- If R is composite:
  - $R = R_1 union R_2$:
    for #inline(automaton((q1: ()), initial: "q1", final: "q1")) and #inline(automaton((q2: ()), initial: "q2", final: "q2")), exists
    #inline(scale: 100%, automaton(
      (q0: (q1: "epsilon", q2: "epsilon"), q1: (), q2: ()),
      final: ("q1", "q2"),
      initial: "q0",
    ))
  - $R = R_1 circle R_2$:
    for #inline(automaton((q11: (q12: "x")), initial: "q11", final: "q12")) and #inline(automaton((q21: (q22: "y")), initial: "q21", final: "q22")), exists
    #inline(scale: 100%, automaton(
      (q1: (q12: "x"), q12: (q2: "epsilon"), q2: (q22: "y")),
      final: ("q22",),
      initial: "q1",
    ))
  - $R = R_1^*$:
    for #inline(automaton((q1: (q2: "x")), initial: "q1", final: "q2")), exists
    #inline(scale: 100%, automaton(
      (q: (q1: "epsilon"), q1: (q2: "epsilon"), q2: (q: "epsilon")),
      final: ("q", "q2"),
      initial: "q",
    ))

Then, by structural induction on R, we can show that NFA $M$ recognizes A.

== Generalize NFA

Similar to NFA, but will more complex transitions.
GNFA allow transitions labeled with regular expressions.

Assume:
- one accept state, separate from the start state:
  connect all old accept states to new accept state via epsilon transitions,
  and treat old accept states as normal states.
- one arrow from each state to each state, except:
  - only existing the start state
  - only entering the accept state
  - connect states without stransitions via emptyset transitions.

== NFA to regular

Inverse, if a language L is regular, then there is a regexpr R such that $L = L(R)$.

Lemma: Every GNFA G has an equivalent regular expression R.

Proof:

By induction on the number of states in GNFA G.


Basic(k = 2): G = #inline(automaton((q_start: (q_accept: "r"), q_accept: ()), final: ("q_accept",), initial: "q_start")).
Let R = r

Induction step(k > 2): Assume Lemma true for k - 1 states and prove for k states.

Convert k-state GNFA G to (k - 1)-state GNFA G' by removing one state q_rip that neither start nor accept states.
And repair all path may go through q_rip.

= Non-regular languages

== Pumping Lemma for regular languages

To show a language is regular, just give a finite automaton or a regular expression.

To show a language is non-regular, give a proof by contradiction with pumping lemma.

Pumping lemma for regular languages describes a property that all regular languages must satisfy.
If a language fail to satisfy this property, then it is non-regular.

Pumping Lemma: For every regular language A,
there is a number p (the pumping length) such that
if $s in A and |s| >= p$ then $s = x y z$ where
- $x y^i z in A$ for all $i >= 0$,
- $y eq.not epsilon$ (y is not empty),
- $|x y| <= p$,

Informally, any sufficiently long string in a regular language can be pumped (have a middle section repeated any number of times) and still be in the language.

Or, If there is a substring that can be repeated any number of times to produce new strings in the language,
then the language may be regular.

Pumping lemma depends on the fact that if M has p states, and it runs for more than p steps will enter some state at least twice (by pigeonhole principle).

== Using pumping lemma to show non-regularity

=== $D = {0^n 1^n | n >= 0}$

Let $D = {0^n 1^n | n >= 0}$
show: D is not regular.

Proof by contradiction:
Assume D is regular.
Then, by pumping lemma, there is a pumping length p.
Let $s = 0^p 1^p in D$ thus $|s| = 2 p >= p$.

And pumping lemma says that $s = x y z$ where
- $x y^i z in D$ for all $i >= 0$,
- $y eq.not epsilon$,
- $|x y| <= p$,

Assuming $x, y$ contains all 0s, then $y = 0^k$ for some $k >= 1$.
But $x y y z$ has excess 0s than 1s, thus $x y y z in.not D$, contradiction.

Therefore the assumption is false, D is not regular.

=== $F = {w w|w in Sigma^*}$, Sigma = {0, 1}.

Let $F = {w w|w in Sigma^*}$, Sigma = {0, 1}.
Show F is not regular.

Proof by contradiction:
Assume F is regular.
Then, by pumping lemma, there is a pumping length p.
Let $s = 0^p 1 0^p 1 in F$

According to pumping lemma, $s = x y z$ where
- $x y$ holds all 0s in the first half of s,

And $x y y z$ has excess 0s in the first half than the second half,

Contradiction found, thus F is not regular.

=== $B = {w | w "has equal number of" 0's "and" 1's}$

Let $B = {w | w "has equal number of" 0's "and" 1's}$.
Show B is not regular.

Proof by contradiction:
Assume B is regular.
Then, by pumping lemma, there is a pumping length p.

Since we know that $0^* 1^*$ is regular, thus $C = B inter 0^* 1^* = {0^n 1^n | n >= 0}$ is also regular (by closure under intersection).

But for language C, we have already shown it is not regular.

Contradiction found, thus B is not regular.

= Context-free languages

Context free grammar are more powerful than finite machines.

Composed of variables and rules.
- rule: variable -> string of variables and terminals
- variable: non-terminal symbol, appear on left side of some rule
- terminal: symbol in the alphabet or epsilon, appear in only right side of rules
- start variable: special variable that appear in the left side of no rule

Grammar can generate strings by starting with start variable,
then repeatedly replacing some variable with the right side of one of its rules,
until there is no variable left.

The terminals are the base of final strings generated by the grammar.

== Parse Trees

Start at the root with start variable,
then for each rule applied, create child nodes for each symbol in the right side of the rule.

When all leaves are terminals, the parse tree is complete.

== Formal definition of CFG

Defn: A context-free grammar G is a 4-tuple $(V, Sigma, R, S)$ where
- V: finite set of variables
- $Sigma$: finite set of terminal symbols, disjoint from V
- R: finite set of rules of the form $A -> gamma$ where $A in V$ and $gamma in (V union Sigma)^*$
- S: start variable, $S in V$

For $u, v in (V union Sigma)^*$, we say that u directly derives v,
+ $u => v$: u yield v if it can go from u to v in one substitution step in G
+ $u =>^* v$: u yield v if it can go from u to v in zero or more substitution steps in G
  or $u => u_1 => u_2 => ... => v$, called derivation of v from u.
  If $u = S$, then it is a derivation of v from G.

$L(G) = {w in Sigma^* | S =>^* w}$, the language generated by G.

Defn: A is a context-free language if there is a CFG G such that $A = L(G)$.

== Ambiguity

For some CFG, there may be more than one parse tree for some string in the language.
For some string, there may be more than one leftmost derivation or more than one rightmost derivation.

== PDA: pushdown automata

This is a new view of finite automata with a stack memory.

For a pda, there exists a finite controller and a input tape,
the head pointer can always trace input.

PDA are mostly similar to finite automata, but with a stack.

The limitation of finite automata is limited memory, but with a stack, PDA has unlimited memory, used in a restricted way.
And PDA have the ability to push data into the stack, pop out of the stack and used as memory.

Only accepted at the end of input.

Defn: A Pushdown Automata is a 6-tuple: $< Q, Sigma, Gamma, delta, q_0, F >$,
- $Sigma$: inpu alphabet
- $Gamma$: stack alphabet
- $delta$: transition functions: $Q times Sigma_epsilon times Gamma_epsilon -> P(Q times Gamma_epsilon)$
  $delta(q, a, c) = {(r_1, d), (r_2, e)}$
  epsilon here represents read no symbol in input, or read nothing in stack.


E.g., $B = {w w^R | w in {1, 0}^*}$, and sample input: 011110
- read and input input symbols, nodeerministically either repeat or goto 2
- read input symbols and pop stack symbols, compare, if ever not equals to then thread reject.
- and enter accepted state if stack is empty.
Assume, every time the state fork, stack is duplicated for each.

== Convert CFG to PDA

Theorem: If A is a CFL then some PDA recognizes A.
Proof: Convert A's CFG to a PDA.

IDEA:
PDA begins with starting variables and guesses substitutions. It keeps intermediate generated string on stack.
When done, compare with the input.

P.S., Use stack as a kind of cache for intermediate generated string.

If find a terminal on the top of stack, then pop it and compare with input symbol, until there is a variable in the stack.

+ Push the start symbol on the stack.
+ If the top of stack is a variable, non-deterministically choose a rule with that variable on the left side, pop the variable and push the right side of the rule onto the stack.
  Else if the top of stack is a terminal symbol, then pop it and compare with input symbol, if equal, then read next input symbol.
+ If both input and stack are empty, then accept.

== Convert PDA to CFG

Theorem: A is a CFL iff some PDA recognizes A.
Proof need to be done on both PDA can be converted to CFG and CFG can be converted to PDA.

Proof:

