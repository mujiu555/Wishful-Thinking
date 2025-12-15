#import "@preview/zh-kit:0.1.0": *

#show: doc => setup-base-fonts(doc)
#set par(first-line-indent: 0em)

#show raw: set text(font: (
  (name: "FiraCode Nerd Font Mono", covers: "latin-in-cjk"),
))

= CPT205 Computer Graphics

== Frame Buffer

- Frame Buffer: A block of memory, dedicated to graphics output, that holds the content of what will  be displayed.
- Pixel: an element of the frame buffer.
- Bit depth: number of bits allocated per pixel in a buffer.

True Colour: 32 bits RGBA
- 8 bits for red, green, blue and alpha
- potential for 256 reds, greens and blues
- total colours: 16,777,216 (more than the eye can distinguish)

Framebuffer -> monitor:
- The values in the framebuffer are converted from a digital (1s and 0s representation, the bits) to an analog signal that goes out to the monitor.
- This is done automatically (not controlled by your code), and the conversion can be done while writing to the framebuffer.

== Pixels

Pixel: The most basic addressable image element in a screen
- CRT - Colour triad (RGB phosphor dots)
- LCD - Single colour element
Screen Resolution - measure of number of pixels on a screen (m by n)
- m - Horizontal screen resolution
- n - Vertical screen resolution

Video formats:
- NTSC - 525x480, 30f/s, interlaced
- PAL - 625x480, 25f/s, interlaced
- VGA - 640x480, 60f/s, non-interlaced
- SVGA - 800x600, 60f/s non-interlaced
- RGB - 3 independent video signals and synchronization signal, vary in resolution and refresh rate
- Interlaced - scan every other line at a time, or scan odd and even lines alternatively; the even scan lines are drawn and then the odd scan lines are drawn on the screen to make up one video frame.

Raster display
- Cathode Ray Tubes (CRTs), most “tube” monitors you might see. Used to be very common, but big and bulky.
- Liquid Crystal Displays (LCDs), there are two types: transmissive (laptops, those snazzy new flat panel monitors) and reflective (wrist watches).

=== Cathode ray tubes (CRTs)

- Heating element on the yolk
- Phosphor coated screen
- Electrons are boiled off the filament and drawn to the focusing system.
- The electrons are focused into a beam and “shot” down the cylinder.
- The deflection plates “aim” the electrons to a specific position on the screen.
- Strong electrical fields and high voltage
- Very good resolution
- Heavy, not flat

=== Liquid crystal displays (LCDs)

Also divided into pixels, but without an electron gun firing at a screen; LCDs have cells that either allow light to flow through, or block it.

- LCDs use small flat chips which change their transparency properties when a voltage is applied.
- LCD elements are arranged in an n x m array called the LCD matrix.
- The level of voltage controls grey levels.
- LCDs elements do not emit light; use backlights behind the LCD matrix.
- Colour is obtained by placing filters in front of each LCD element.
- Image quality dependent on viewing angle.
- Flat
- Light weight
- Low power consumption

== Graphics software
- How to talk to the hardware? Algorithms, Procedures, Toolkits and Packages (Low Level High Level)
- Programming API (helps to program, for our labs)
  - OpenGL (our focus)
  - JOGL (Open GL for Java)
  - OpenCV
  - DirectX
  - …
- Special purpose software (not our focus)
  - Excel, Matlab, …
  - AutoCAD, Studio Max, Unity, Maya, …
  - Medical visualisation, modelling, …

=== OpenGL

- First introduced in 1992.
- The OpenGL graphics system is a software interface to graphics hardware (GL stands for Graphics Library).
- For interactive programs that produce colour images of moving three-dimensional objects.
- It consists of over 400 distinct commands that you can use to specify the objects and operations needed to produce interactive three-dimensional applications.
- OpenGL is designed as a streamlined, hardware-independent interface to be implemented on many different hardware platforms.
- Similarly, OpenGL does not provide high-level commands for describing models of three-dimensional objects.
- With OpenGL, you must build up your desired model from a small set of geometric primitives - points, lines, and polygons.
- With OpenGL, you can control computer-graphics technology to produce realistic pictures or ones that depart from reality in imaginative ways.
- OpenGL has become the industry standard for graphics applications and games.

== Line

“Good” discrete lines
- No gaps in adjacent pixels
- Pixels close to ideal line
- Consistent choices; same pixels in same situations
- Smooth looking
- Even brightness in all orientations
- Same line for $P_0 P_1$ as for $P_1 P_0$
- Double pixels stacked up?

Line algorithms

"while" loop
```c
x = x1 while x <= x2 do {
  DrawPoint(x,y)
  x = x + 1
}
```

"for"-loop
```c
for x = x1 to x2 Do {
  DrawPoint(x,y)
}
```
generator
```c
DrawLine(x1 to x2, y)
```

Drawing a horizontal line from (x1,y) to (x2,y) are easy ... just increment along x

DA – Digital Differential Algorithm
$ y = m x + b $
$ m = (y_2 – y_1 ) / (x_2 – x_1) = Delta y / Delta x $
$ ∆y = m ∆x $
As we move along x by incrementing $x, Delta x = 1$, so $Delta y = m$
When $0 <= |m| <= 1$
```c
int x;
float y=y1;
for(x=x1; x<=x2; x++){
  write_pixel(x, round(y), line_color);
  y+=m;
}
```

When |m| > 1, we swap the roles of x and y ($∆y = m∆x "so" ∆x = ∆y/m = 1/m$).
```c
int y;
float x=x1;
for(y=y1; y<=y2; y++){
  write_pixel(y, round(x), line_color);
  x+=1/m;
}
```

The Bresenham line algorithm
- The Bresenham algorithm is another incremental scan conversion algorithm.
- It is accurate and efficient.
- Its big advantage is that it uses only integer calculations (unlike DDA which requires float-point additions).
- The calculation of each successive pixel requires only an addition and a sign test.
- It is so efficient that it has been incorporated as a single instruction ongraphics chips.

== Circles

In Cartesian co-ordinates:
$ (x - x_c)^2 + (y - y_c)^2 = r^2 $

The position of points on the circle circumference can be calculated
by stepping along the x axis in unit steps from $x_c - r$ to $x_c + r$ and
calculating the corresponding y value at each position as
$ y = y_c plus.minus sqrt(r^2 - (x - x_c)^2) $

Considerable amount of
computation.
- The spacing between plotted pixel positions is not uniform.
- This could be adjusted by interchanging x and y (stepping through y values and calculating the x values) whenever the absolute value of the slope of the circle is greater than 1.
- However this simply increases the computation and processing required by the algorithm.

In polar co-ordinates
$
  cases(
    delim: brace,
    x = x_c + r cos(theta),
    y = y_c + r sin(theta)
  )
$
- When a display is generated with these equations using a fixed angular step size, a circle is plotted with equally spaced points along the circumference.
- To reduce calculations, a large angular separation can be used between points along the circumference and connect the points with straight-line segments to approximate the circle path.
- For a more continuous boundary on a raster display, the angular step size can be set at 1/r. This plots pixel positions that are approximately one unit apart

Computational work can be reduced by considering the symmetry of the circle.
- If the curve positions in the first quadrant are determined, the circle section in the second quadrant can be generated by noting that the two circle sections are symmetric with respect to the y axis.
- Circle sections in the third and fourth quadrants can be obtained from the sections in the first and second quadrants by considering the symmetry about the x axis.
- Taking this one step further, it can be noted that there is also symmetry between octants. Circle sections in adjacent octants within one quadrant are symmetric with respect to the 45° line dividing the two octants.

Considering symmetry conditions between octants, a point at position (x, y) on a one-eighth circle sector is mapped into the seven circle points in the other seven octants of the x-y plane.
- Taking the advantage of the circle symmetry in this way, all pixels around a circle can be generated by calculating only the points within the sector from x = r to x = y.
- The slope of the curve in this octant has an absolute magnitude equal to or larger than 1.

Determining pixel positions along a circle circumference using symmetry and the equation either in Cartesian or polar co-ordinates, still requires a good deal of computation.
- The Cartesian equation involves multiplication and square root calculations.
- The parametric equations contain multiplications and trigonometric calculations.
- More efficient circle algorithms are based on incremental calculation of decision parameters, which involves only simple integer operations

将整个平面均分成八份, 以 $+45degree$ 为基准, 对称到其他部分.


== Geometric primitives – polygons and triangles

- The basic graphics primitives are points, lines and polygons
- A polygon can be defined by an ordered set of vertices
- Graphics hardware is optimised for processing points and flat polygons
- Complex objects are eventually divided into triangular polygons (a process called tessellation)
- Because triangular polygons are always flat

== Scan conversion - rasterization
• The output of the rasterizer is a set of potential pixels (fragments) for each primitive, which carry information for colour and location in the frame buffer, and depth information in the depth buffer for further processing.
• The 3D to 2D projection gives us 2D vertices (points) to define 2D graphic primitives.
• We need to fill in the interior
- the rasterizer must determine which pixels in the framebuffer are inside the polygon.

Polygon fill is a sorting problem, where we sort all the pixels in the frame buffer into those that are inside the polygon and those that are not.
- Rasterize edges into framebuffer.
- Find a seed pixel inside the polygon.
- Visit neighbours recursively and colour if they are not edge pixels.
- There are different polygon-fill algorithms:
  - Flood fill
  - Scanline fill
  - Odd–even fill

== Geometric Transformation

=== Translation

Translating a point from P(x, y) to P’(x’, y’) along vector T

Only transform the two endpoints of a line segment and let the
implementation draw the line segment between the transformed endpoints.

$
  P = vec(x, y), P' = vec(x', y'), T = vec(t_x, t_y)
$
$=>$
$
  P'=P+T
$

=== Rotation

Rotating a point from $P(x, y)$ to $P’(x’, y’)$ about the origin by
angle $θ$ - radius stays the same, and angle increases by $θ$.

$
  x = r cos φ,\
  y = r sin φ
$
$=>$
$
  x’ = r cos(φ + θ) = x cos(θ)- y sin(θ), \
  y’ = r sin(φ + θ) = x sin(θ)+ y cos(θ)
$
$
  x' = x cos(theta) - y sin(theta),\
  y' = x sin(theta)+ y cos(theta)
$

Rotation about a fixed point rather than the origin
- Move the fixed point to the origin
- Rotate the object
- Move the fixed point back to its initial position
- $M = T(p_f) R(θ) T(-p_f)$

=== Scaling

$
  x' = x dot s_x,\
  y' = y dot s_y
$

$
  P' = S dot P => vec(x', y') = mat(s_x, 0; 0, s_y) dot vec(x, y)
$

=== Reflection

Corresponding to negative scale factors.

=== Shearing

$
  x’ = x + y cot(θ),\
  y’ = y,\
  z’ = z
$

$
  vec(x', y') = mat(1, cot(theta); 0, 1) dot vec(x, y)
$

== 2D homogeneous coordinates

Regular 2d point, $vec(x, y) => vec(w x, w y, w)$
- Translation: $vec(x', y', 1) = mat(1, 0, t_x; 0, 1, t_y; 0, 0, 1) dot vec(x, y, 1)$
- Rotation: $vec(x', y', 1) = mat(cos(theta), -sin(theta), 0; sin(theta), cos(theta), 0; 0, 0, 1) dot vec(x, y, 1)$
- Scaling: $vec(x', y', 1) = mat(s_x, 0, 0; 0, s_y, 0; 0, 0, 1) dot vec(x, y, 1)$
- Shearing: $vec(x', y', 1) = mat(1, cot(theta), 0; 0, 1, 0; 0, 0, 1) dot vec(x, y, 1)$

== 2D composite transformation

=== General rotation about the origin

A rotation by q about an arbitrary axis can be decomposed into the concatenation of rotations about
the x, y, and z axes.
$R(q) = R_z(q_z) R_y(q_y)R_x(q_x)$
where $q_x$, $q_y$ and $q_z$ are called the Euler angles.

== View

Viewing requires three basic elements
- One or more objects
- A viewer with a projection surface
- Projectors that go from the object(s) to the projection surface

Classical views are based on the relationship among these elements
The viewer picks up the object and orients the object in a way that it is to be seen.

Each object is constructed from flat principal faces
Buildings, polyhedra, manufactured objects, etc.

#figure(image("./img/CPT205-L5-1.png"))

=== Planar geometric projection

Standard projections project onto a plane.

Projectors are lines that either converge at a centre of projection or are parallel.
Such projections preserve lines but not necessarily angles.
Non-planar projections are needed for applications such as map construction.

#figure(image("./img/CPT205-L5-2.png"))

Perspective vs parallel
投影透视 vs. 平行透视
- Computer graphics treats all projections in the same way and implements them with a single pipeline.
- Classical viewing has developed different techniques for drawing each type of projection.
- The fundamental distinction is between parallel and perspective viewing even though mathematically parallel viewing is the limit of perspective viewing.

==== Perspective

Perspective projection generates a view of 3-dimensional scene by projecting points to the view plane along converging paths.
投影到视平面

This results in the objects further from the viewing position to be displayed smaller than the objects of the same size that are nearer to the viewing position.
近大远小

A scene generated using perspective projection appears more realistic since this is the way that human eyes and cameras form images.

Vanishing points

Parallel lines (not those parallel to the projection plane) on the object converge at a single point in the projection (the vanishing point).
Drawing simple perspectives by hand uses the vanishing point(s).

===== Frustum perspective projection

By adding near and far clipping planes that are parallel to
the viewing plane, parts of the infinite perspective view
volume are chopped off to form a truncated pyramid or
frustum.

The near and far clipping planes can be used simply to
enclose objects to be displayed. These clipping planes can
be optional for some systems.

The near clipping plane can be used to take out large
objects close to the viewing plane, which could be projected
into unrecognisable shapes in the clipping window.
Likewise, the far clipping plane can cut out objects that may
be projected to small blots.

Some systems restrict the placement of the viewing plane
relative to the near and far planes, and other systems allow it
to be placed anywhere except at the position of the viewing
origin (viewing point, viewing position, eye position or camera
position).

If the viewing plane is behind the viewing point, objects are
inverted on the view plane.

If the viewing plane is behind the objects, the objects are
simply enlarged as they are projected away.

When the viewing point is very far away from the view plane, a
perspective projection approaches to a parallel projection.

==== Parallel projection

This method projects points on the object surface along parallel lines.
It is usually used in engineering and architecture drawings to represent an object with a set of views showing accurate dimensions.

==== 正交透视

The projectors are orthogonal to projection surface

Orthogonal (orthographic) projection is a
transformation of object descriptions to a view plane
along lines parallel to the view-plane normal vector N.

It is often used to produce the front, side and top views
of an object.

Engineering and architectural drawings commonly
employ these orthographic projections since the
lengths and angles are accurately depicted and can be
measured from the drawings.

==== Axonometric projection
轴测投影

一个图像显示所有三围,

Allow projection plane to move relative to the object.

If the projection plane is placed symmetrically with respect to the three principal faces that meet at a corner of our rectangular object, then we have an isometric view.

If the projection plane is placed symmetrically with respect to two of the principal faces, then the view is dimetric.

The general case is a trimetric view.

#figure(image("./img/CPT205-L5-3"))

==== Oblique projection

#figure(image("./img/CPT205-L5-4.png"))


== 3D viewing co-ordinate parameters (1)

A world co-ordinate position $P_0(x_0, y_0, z_0)$ is selected as the viewing origin
(also called viewing point, viewing position, eye position or camera position).

The direction from a reference point $P_"ref"(x_"ref", y_"ref", z_"ref" )$ to
the viewing origin $P_0(x_0, y_0, z_0)$ can be taken as
the viewing direction (vector),
and the reference point is termed the look-at point.

The viewing plane can then be defined with a normal vector N,
which is the viewing direction, usually the negative $z_"view"$ axis.


Once the viewing plane normal vector N is defined, the
direction for view-up vector V can be set to establish the
positive $x_"view"$ axis.

Since N defines the direction for z view, V must be
perpendicular to N (i.e., parallel to the xview -y view plane).

But it is generally difficult to determine V precisely,
so viewing routines typically adjust the user defined value of V
(e.g., projecting it onto a plane perpendicular to N).

Any direction can be used for V as long as it is not parallel to N.

== Parametric curves

Explicit representation: $y = a_0 + a_1 x$

Parametric representation:
$
  x = x_1 + t(x_2 – x_1) (0 ≤ t ≤ 1),\
  y = y_1 + t(y_2 – y_1)
$
when $t = 0, x = x_1$ and $y = y_1$,
when $t = 1, x = x_2$ and $y = y_2$.

Parametric equation of a circle:

Implicit representation:
$ x_2 + y_2 = r_2 (r = "radius") $

Parametric equation:
$ x = r cos(360t), y = r sin(360t), (0 ≤ t ≤ 1) $



























