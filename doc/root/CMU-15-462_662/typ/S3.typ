= CMU 15-462/662

== Vector Calculus

Much of mordern graphics formulated in terms of 
partial differential equations.

== Euclidean Norm

In $RR^3$ Space:

- Norm: measures total size, length, volume, intensity, etc...
- Euclidean norm: notion of length preserved by
  rotations/translation/reflections of space:
  not concerning coordinate.
- In orthonormal coordinates:
  $|arrow(u)| := sqrt(arrow(u)_1^2 + ... + arrow(u)_n^2)$
  square root of the sum of all square of component.
  勾股定理

== Euclidean Inner Product / dot Product

Inner Product: notion of alignment.
For n-dimensional vectors,
Euclidean inner product:
$angle.l arrow(u), arrow(v) angle.r := |arrow(u)| |arrow(v)| cos(theta)$

For orthonormal Cartesian coordinates,
Dot product:
$arrow(u) dot arrow(v) := u_1 v_1 + ... + u_n v_n$

== Cross Product

Cross Product: takes two vectors and produce a scalar.
- $arrow(u) times arrow(v) = det mat(arrow(i), arrow(j), arrow(k); arrow(u) ...; arrow(v) ...)$
- magnitude equals to parallelogram area
- direction orthogonal to both vectors
- Generates Normal Vector.
- only in $RR^3$

Normal Vector: some vector vertical (perpendicular) to a plant,
for which two non-orthonormal vectors can define a plant.

$
sqrt(det(arrow(u), arrow(v), arrow(u) times arrow(v))) =
|arrow(u)| |arrow(v)| sin(theta)
$

$
arrow(u) times arrow(v) :=
det mat(
  arrow(i), arrow(j), arrow(k);
  u_1,      u_2,      u_3;
  v_1,      v_2,      v_3;
)
= mat(
  u_2 v_3 - u_3 v_2;
  u_3 v_1 - u_1 v_3;
  u_1 v_2 - u_2 v_1)
$

== Quarter Rotation

Cross product with a unit vector N is equivalent to a quarter-rotation in the plane with normal N

和平面法向量相乘, 获得逆时针90°新向量

== Matrix Representation of Dot Product

$
arrow(u) dot arrow(v)
= arrow(u)^T arrow(v)
= mat(u_1, ..., u_n) mat(u_1; ...; u_n)
= sum_(i=1)^n u_i v_i
$

== Matrix Representation of Cross Product

$
arrow(u):=(u_1, u_2, u_3)
=> hat(arrow(u))
:= det mat(0, -u_3, u_2; u_3, 0, -u_1; -u_2, u_1, 0)
$

Also, $arrow(u) times arrow(v) = - arrow(v) times arrow(u)$

== Determinant

$det(arrow(u),arrow(v),arrow(w))$ encodes signed volume of
parallelepiped with edge vectors $arrow(u), arrow(v), arrow(w)$.

$
M = mat(a, b, ..., c; d, ..., ..., ...; ..., ..., ..., g; h, ..., i, j)
=>
det M
= a det M_(1,1) + b det M_(1,2) + ... + c det M_(1,c)
= ...
$

$M_(m,n)$ is sub-matrix discard the row and column of m,n.

$det(u,v,w)=(u times v) dot w = (v times w) dot u = (w times u) dot v$

PS. Order of product can't be switched.

== Linear Maps via Matrices

== Triple Products

Jacobi identity for cross product:

$
arrow(u) times (arrow(v) times arrow(w)) +
arrow(v) times (arrow(w) times arrow(u)) +
arrow(w) times (arrow(u) times arrow(v)) =
0
$

Lagrange's identity:

$
arrow(u) times (arrow(v) times arrow(w)) =
arrow(v) (arrow(u) dot arrow(w)) - arrow(w) (arrow(u) dot arrow(v))
$

== Differential Operations


