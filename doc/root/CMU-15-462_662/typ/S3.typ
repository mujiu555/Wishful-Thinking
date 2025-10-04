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

== Differential Operators

Derivative act on vector fields.

Geometric problems are expressed in terms of relative rate of change,
in the form of ordinary differential equations
or partial differential equations.

i.e. Gradient or slope.

== Derivative as Slop

For a function $f(x):R->R$

Thus: $
f'(x_0) := lim_(epsilon->0) (f(x_0 + epsilon) - f(x_0)) / epsilon.
$

Thus: $
f^+(x_0) := lim_(epsilon->0^+) (f(x_0 + epsilon) - f(x_0)) / epsilon,
$
$
f^-(x_0) := lim_(epsilon->0^-) (f(x_0) - f(x_0 - epsilon)) / epsilon.
$
When meets singular at $x_0$, $f(x)$ is non-differentiable at $x_0$.
Aka. When $f^+(x_0) == f^-(x_0)$ at $x_0$, it is differentiable.

== Best Linear Approximation

Any smooth function $f(x)$ can be expressed as a Taylor series.

+ Concerning a point $x_0$, assume function can be approximated as a constant:
  $f(x) = f(x_0) + ...$
+ Slope \* delta, linear: the very close value of $f(x)$ at $x = x_0$:
  $f(x) = f(x_0) + f'(x_0)(x - x_0) + ...$
+ Quadratic: $f(x) =f(x_0) + f'(x_0)(x - x_0) + (x - x_0)^2 / 2! f''(x_0) + ...$
+ ...: $+ (x-x_0)^n/n! f^((n))(x_0)$

== Multiple variables

== Directional Derivative

For a function $f(x_1, x_2)$, takes "slice", through the function along same line.
i.e. Fix one parameter.
$ D_arrow(u) f(x_0) := lim_(epsilon->0)(f(x_0 + epsilon arrow(u)) - f(x_0)) / epsilon $
The function along vector $arrow(u)$ is just normal function along the line.
Then apply usual derivative.

== Gradient

Given a multivariable function $f(arrow(x))$,
Gradient $gradient f(arrow(x))$ assigns a vector at each point:
PS. "Nabla" for $gradient$

== Gradient in Coordinates

List of partial derivatives.

$ gradient f = mat(
  (partial f) / (partial x_1);
  (partial f) / (partial x_2);
  ...;                    
  (partial f) / (partial x_n)
)
$

Problems:
- Role of inner product is not clear
- not possible to differentiate function of functions F(f),
  i.e. cannot treat function as vectors.

E.g. For function $f(x): x_1^2 + x_2^2$, exists:
$(partial f) / (partial x_1) = (partial) / (partial x_1) x_1^2 + (partial) / (partial x_1) x_2^2 = 2 x_1$,
$(partial f) / (partial x_2) = (partial) / (partial x_2) x_1^2 + (partial) / (partial x_2) x_2^2 = 2 x_2$,
Thus, $gradient f(arrow(x)) = mat(2 x_1 ; 2 x_2) = 2 arrow(x)$

== Gradient as Best Linear Approximation

For point $x_0$, gradient is the vector $gradient f(x_0)$ that leads to the best possible approximation.

$
f(x) approx f(x_0) + gradient f(x_0) dot (x - x_0)
$

PS. Let $z = f(x, y)$, and $P(x_0, y_0, z_0)$ be a point in the surface.
$
d z =
z - z_0 =
f_x(x_0, y_0)(x - x_0) + f_y(x_0, y_0)(y - y_0) =
f_x(x_0, y_0)d x + f_y(x_0, y_0) d y
$
$
=>
d z = d f(x, y) = f_x(x, y) d x + f_y(x, y) d y= gradient f dot angle.l d x, d y angle.r
$

== Gradient takes uphill

Direction of steepset ascent.

== Gradient and Directional Derivative

$ angle.l gradient f(x), arrow(u) angle.r = D_arrow(u) f (arrow(x)) $

E.g. $f:=arrow(u)^T arrow(v)$, i.e. $f(arrow(v)) = f$,
then it has $gradient_arrow(u) f = arrow(v)$

== Gradient for a function: $LL^2$ Gradient

Given a function $F(f)$ that accept a function.
$ angle.l.double gradient F, u angle.r.double = D_u F $
$ D_u F(f) = lim_(epsilon->0) (F(f + epsilon u) - F(f)) / epsilon $

E.g. $F(f) := angle.l.double f, g angle.r.double$; for $ f,g: [0,1]->R$.
The gradient is $gradient_f F = g$

Proof required....
I finished indeed.

Given function $F(F) := ||f||^2$ for arguments $f: [0,1]->R$,
result to $gradient F(f_0) = 2 f_0$

== Vector Fields

Assign a vector to each point.
