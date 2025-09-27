= CMU 15-462/662

== Linear Algebra in Computer Graphics

Vector spaces, and linear maps between them:
$arrow(u), arrow(v), arrow(w)$ are vectors and $a, b$ are scalars.
- $arrow(u) + arrow(v) = arrow(v) + arrow(u)$
- $arrow(u) + (arrow(v) + w) = (arrow(u) + arrow(v)) + w$
- There exists a zero vector $"0"$ such that $arrow(v) + 0 = 0 + arrow(v) = arrow(v)$
- For every arrow(v) there is a vector "$-arrow(v)$" such that $arrow(v) + (-arrow(v)) = 0$
- $1 arrow(v)=arrow(v)$
- $a(b arrow(v))= (a b) b$
- $a(arrow(u) + arrow(v)) = a arrow(u) + a arrow(v)$
- $(a + b)arrow(v) = a arrow(v) + b arrow(v)$

== vector

What is a vector:

What can vector encode:
+ direction & magnitude: $r$, $theta$ like polar coordinates

The base of vector:
- based of origin
- has fix base point in differential geometric

Does $r$ and $theta$ has same in any coordinate system:
- only meaningful to specify coordinate

How can vector be encoded:
- In components of a vector respect to some chosen coordinates:
  Cartesian coordinates.
- PS. Using matrix with only one column (or row)

How to deal vector:
- end to end: $arrow(u) + arrow(v)$:
  $arrow(u) + arrow(v) = arrow(v) + arrow(u)$
- Scaling: $2 arrow(u)$
- Addition & Scaling: $a(arrow(u) + arrow(v)) = a arrow(u) + a arrow(v)$
- ...

Any object that can satisfying all of properties is a vector space.

== Euclidean Vector Space

Typically denoted by $RR^n$: n real numbers

== Functions as Vectors

Operations:
- Addition: for $f(x)$, $g(x)$, $(f+g)(x):=f(x) + g(x)$
-Scaling: for $f(x)$, $(a f)(x) = a(f(x))$
