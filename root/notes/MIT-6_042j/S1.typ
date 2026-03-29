/// TAG: Discrete Mathematics
#import "@preview/cetz:0.4.2" as cetz
#import "@preview/cetz-plot:0.1.3"
#import "@preview/cetz-venn:0.1.4"
#import "@preview/finite:0.5.0": automaton
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/tablex:0.0.9": *

#import "/lib/lib.typ": *

#show: schema.with("page")

#title[MIT 6.042 Mathematics in Computer Science (junior)]
#date[2026-02-20]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Section I:

What proof is?
A proof is a method for ascertaining the truth.

- Experimentation & Observation:
- Sampling & Counter Examples:
- Judge; jury:

In mathematics, a proof is a verification of a proposition by a chain of logical deductions from a set of axioms and previously established theorems. A proof is a demonstration that a statement is necessarily true, given the assumptions.

Def: A proposition is a statement that is either true or false.

Ex., 1 + 4 = 5
ex., $forall n in n, n^2 + n + 41 "is a prime number"$
