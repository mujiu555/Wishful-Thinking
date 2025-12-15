= CMU 15-464/662

#set math.mat(delim: "[")
#set math.vec(delim: "[")

Apply Transform of object on space.

== Spatial Transformation

Basically any function that assigns each point a new location:
$ f: RR^n -> RR^n $

Rotation, Scaling, etc. encoded by linear maps.

Used to:
- position/ deform objects,
- moving camera
- ...

== Linear Maps

Geometrically, maps lines to lines, and preserves the origin.

Algebraically, preserves vector space operations (only for addition & scaling).

- Cheap to apply
- Easy to solve
- Composition of linear transformations is linear
- product many matrics in a singe matrix
- use uniform representation of transformations
- simple for hardware

== Types of transformations

- translation: Moving form one to another place
- scaling: Resize the object
- Rotation: 
- shear

The Transformation is not defined by the formula, but the invariants it preserved.
What quantity remains fixed before and after the Transformation.

#table(
  columns: 3,
  stroke: none,
  table.hline(),
  table.header([Transformation], [invariants],[algebraic description]),
  table.hline(stroke: 0.5pt),
  [linear], [straight lines / origin], $f(a arrow(x) + arrow(y)) = a f (arrow(x)) + f(arrow(y))$,
  [translation], [differences between pair of points], $f(arrow(x)-arrow(y)) = arrow(x) - arrow(y)$,
  [scaling], [lines through origin / direction vector], $f(arrow(x)) / (|f(arrow(x))|) = arrow(x) / (|arrow(x)|)$,
  [Rotation], [origin / distances between points / orientation], $|f(arrow(x)) - f(arrow(y)) = |arrow(x) - arrow(y)|, det(f) > 0$,
  table.hline()
)

== Rotation

- Keeps origin fixed
- Preserves distances
- preserves orientation

=== 2D Rotation

2d rotation by an angle $theta$ maps each point $arrow(x)$ to a point
$f_theta(arrow(x))$ on the circle of radius $|arrow(x)|$

$ arrow(x) = angle.l x_1, x_2 angle.r = x_1 angle.l 1, 0 angle.r + x_2 angle.l 0, 1 angle.r $
So, as rotation on basic vectors are linear,
$ f(arrow(x)) = x_1 angle.l cos(theta), sin(theta) angle.r + x_2 angle.l -sin(theta), cos(theta) angle.r $

=== 3D Rotation

Concerning rotate only around one axis.
Just apply the same transformation of $x_1$, $x_2$, and keep $x_3$ fixed.

=== Transpose as Inverse

Original matrix represents a object in 3d:
$
R = mat(|,|,|;e_1,e_2,e_3;|,|,|) = mat(1,0,0;0,1,0;0,0,1)
$
Thus,
$
R_T = mat(-,e_1^T,-;-,e_2^T,-;-,e_3^T,-;) = mat(1,0,0;0,1,0;0,0,1)\
R^T R = mat(1,0,0;0,1,0;0,0,1) = I
$

=== Orthogonal Transformation

Transformation that preserves distances and the origin

Represented by matrix, $Q^T Q = I$
- Rotations additionally preserve orientation: $det(q) > 0$
- Reflection reverse orientation: $det(q) < 0$

=== Scaling

Each vector $arrow(u)$ gets mapped to a scalar multiple.

Preserves the direction of all vectors

Build a diagonal matrix D, with a along the diagonal:
$
mat(a,0,0;0,a,0;0,0,a) vec(u_1,u_2,u_3) = vec(a u_1, a u_2, a u_3)
$

It is also possible to own a none-uniformed scaling.

To scratch a object, transpose it into $R$,
and do scaling,
finally multiple $R&T$ to get back into original axis:
$f(x,y,z) = R^T D R arrow(x)$

$
A:= R^T D R
$

=== Spectral Theorem

Symmetric matrix $A = A^T$ has:
- orthonormal eigenvectors $e_1, ..., e_n in RR^n$,
- Real eigenvalues $lambda_1, ... lambda_n in RR$.

Then,
$A e_i = lambda_i e_i$
for A is Symmetric and diagonal matrix.

Also, $A R = R D$, when
$ R = [e_1 ... e_n] , D = mat(lambda_1,,;,dots.down,;,,lambda_n) $

Every symmetric matrix performs a non-uniform scaling along some set of orthogonal axes.

== Shear

Displaces each point x in a direction $arrow(u)$ according to its distance
(which is $arrow(x)$) along a fixed vector $arrow(v)$:
$ f_(arrow(u), arrow(v)) = arrow(x) + angle.l arrow(v), arrow(x) angle.r arrow(u) $

The more x align with v, the more it moves.
$
f_(arrow(u), arrow(v)) =
arrow(x) + angle.l arrow(v), arrow(x) angle.r arrow(u) =
I arrow(x) + 
A_(arrow(u), arrow(v)) 
$


