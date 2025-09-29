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
- Scaling: for $f(x)$, $(a f)(x) = a(f(x))$

== Midpoint

$(arrow(u) + arrow(v)) / 2$

== Norm of a vector

Magnitude, scale or norm:
the length or magnitude of a vector: $|arrow(u)|$

It has some nature properties:
- $|arrow(u)| >= 0$
- it should be zero only for the zero vector
- as the vector scaled by a factor $c$,
  its norm should scale by the same amount:
  $|arrow(v)| = 0 <=> arrow(v) = arrow(0)$
- As the shortest path between two point is always along a straight way:
  $|arrow(u)| + |arrow(v)| >= | arrow(u) + arrow(v) |$

Euclidean Norm: 
$|arrow(u)| = |(u_1, ..., u_n)| := sqrt(Sigma^n_(i=1) u^2_i) $

== $LL^2$ Norm of Functions

Total magnitude of a function.

For a real-value functions on the unit interval [0,1]
whose square has a well defined integral.
(to avoid the function has no difference)
The $LL^2$ Norm is:
$ ||f|| := sqrt(integral^1_0 (f(x)^2) d x) $

== Inner Product

How much two vector are lined up.

Notation: $<arrow(u), arrow(v)>$ or $arrow(u) dot arrow(v)$

$ arrow(u) dot arrow(v) = |arrow(u)| * |arrow(v)| * 2 cos(theta)$

- Symmetry: $arrow(u) dot arrow(v) = arrow(v) dot arrow(u)$
- Projection:
  Measures the extent of one one vector along the direction of another.
- Scaling: $<2 arrow(u), arrow(v)> = 2 <arrow(u), arrow(v)>$
- Positivity: $<arrow(u), arrow(u)> = 1$, for unit vector,
  for a vector always align with itself
  $arrow(u) dot arrow(u) >= 0$
- $<arrow(u) + arrow(v), arrow(w)> = <arrow(u), arrow(w)> + <arrow(v), arrow(w)>$

$ < arrow(u), arrow(v)> = Sigma_(i=1)^n u_i v_i $

== $LL^2$ Inner Product for Functions

$ <<f,g>> := integral_0^1 f(x) g(x) d x $

== Linear Map

Linear are study of vector space and linear maps between them.

- a map is linear if it maps vectors to vectors, 
  and for all vectors $arrow(u)$, $arrow(v)$
  has:
  - $f(arrow(u) + arrow(v)) = f(arrow(u)) + f(arrow(v))$
  - $f(a arrow(u)) = a f(arrow(u))$
- if the function reverse the operation in linear space,
  then it is a linear map.
- For maps between $RR^m$ and $RR^n$, it is linear if it can be express as:
  $ f(u_1, ..., u_m) = Sigma_(i=1)^m u_i arrow(a)_i $
- If it is a linear combination of a fixed set of vectors $a_i$.

== Affine Maps

- like linear function, but can shift origin.

== Span

Span is the set of linear combination of all vectors.
$ "Span"(arrow(u)_1, ..., arrow(u)_k) = {arrow(x) in V | arrow(x) = Sigma_(i=1)^k a_i arrow(u)_i, a_1, ..., a_k in RR} $

The image of any linear map is the span of some collection of vectors.
The "Image" in mathematics is all points that can be reached
by applying some specify map.

The span of a map are linear space constructed by the base of matrix.

== Basis

If, there are exactly n vectors $arrow(e)_1, ..., arrow(e)_n$
such that $"span"(arrow(e)_1, ..., arrow(e)_n) = RR^n$.
Then those vectors are a basis of $RR^n$

NOTE. If and only if there are exactly n vectors, neither more or less.

- The vectors are linear independent
- Maybe orthogonal: 正交

== Orthogonal Basis

When two vectors has zero as their result for dot product,
the two vectors are orthogonal.
For two vector in $RR^2$ Space, they are orthogonal if they has $theta = 90degree$

For vectors $arrow(e)_1, ..., arrow(e)_n$ are basis vectors and
$ angle.l arrow(e)_i, arrow(e)_j angle.r = brace ^(1, i = j,)_(0, "otherwise".) $

== Gram-Schmidt method

To gain a orthogonal basis of a plant with non-orthogonal basis,
use Gram-Schmidt method.

+ normalize first vector: divide by its length
  $arrow(e)_1 := arrow(u)_1 / (|arrow(u)_1|)$
+ subtract any component of the 1st vector from the 2nd one
  $arrow(u)_2 := arrow(u)_2 - angle.l arrow(u)_2, arrow(e)_1 angle.r arrow(e)_1$
+ normalize 2nd
+ until all normalized

PS. For float numbers, using qr decomposition.

== Fourier Transform

Project onto basis of sinusoids: $sin(n x), cos(m x), m, n in NN$

$LL^2$ Linear map of those two are orthogonal.

A linear map from one basis to another.
Projecting a signal onto different frequent.

== System of Linear Equations

A bunch of equations where left hand is a linear function,
and right hand side is constant.

- Degrees of freedom: unknown values, columns in left side of augmented matrix
- Constraints: equations
- Goal: solve for DOFs that simultaneously satisfied constraint.

Review:
- Row Rank: non-zero line
- Pivot: first non-zero value's position of a line in reduced echelon form.
  Pivots must existed in different columns and different rows.
- $"col" = "row-rank" + "free-variables" = "DOFs"$

== Visualization

== Uniqueness, existence of Solutions

== Matrices in Linear Algebra
