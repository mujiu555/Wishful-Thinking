= CMU 15-462/662 Computer Graphic

== Section I

== What is Computer graphic

For A more visual way to express the output.
Human-Computer communication way.

To express information to human.

== Why we need graphic information

Human has more ability to digest visual information.

Turn digital information to visual information can help people understand.

Extended computer graphic: synthesize and manipulate sensory information.

Computer vision: turning real information into digital.

ACM SIGGRAPH conference.

== Foundations of computer graphics

- Demand sophisticated theory & systems,
- Theory:
  - basic representations: how to encode shape and motion.
  - sampling & aliasing: how to navigating acquiring & reproducing a signal.
    So that the signals can presented thing acquired.
  - numerical methods:
  - radiometry & light transport:
  - perception: how those related to humans
- System:
  - parallel, heterogeneous processing: how to process data effectively
  - graphics-specific programming languages: shaders

== How to modeling and draw a cube

*Goal*: generate a realistic drawing of a cube

+ Modeling: how to describe the cube
+ Rendering: how to transfer a digit described cube into image.

Suppose:
- centered at the origin
- has dimensions 2x2x2
- edges aligned with x/y/z

How to describe a cube:
+ vertices:
+ edges:

How to render a cube as 2D image:
+ Just throw a coordinate: lose lot of information
+ Projection: map 3d into 2d points, and connect each 2d points.

== Perspective projection

- Objects look smaller as they get further away: perspective
- pinhole model: let point p=(x,y,z), and projection q=(u,v): 小孔成像
- Assume camera has unit size, origin at pinhole c
- Similar triangle
- then v/1=y/z
- and u/1-x/z

== Cube Rendering

Assume camera at c=(2,3,5)
and convert (X,Y,Z) of both endpoints to (u,v):
+ Subtract camera c from vertex (X,Y,Z) to get (x,y,z):
  to get each point's relative coordinate to camera
+ And, divide (x,y) by z, then get (u,v)
+ Draw a line between (u1,v1) and (u2,v2)

== How to draw a line on computer (screen)

Grid: little picture elements (pixels) on screen.
Little block red, green and blue light turn on and off,
and to different degree.

Simple abstraction to screen:
raster display:
things drawn, or rasterized into grid that has columns and rows.
Image are composed with the numerical value stored in the grid.
Each cell of grid represents a colour.
There exists map between number and colour.

== Rasterization

The process turning high-level object that continuous into a discrete represented raster grid.

+ All pixels intersected by the line:
+ Diamond rule: turn a pixel if and only if the line passes through
  the diamond created by connect midpoint of each edges
+ the algorithm may be seen as good enough if it can 
  match the requirement, and maybe there exists many many other ways.

How to implement the algorithm: diamond rule:

+ check every single pixel in the image
+ incremental line rasterization: 
  - Assume two integer endpoints: $(u_1,v_1)$, $(u_2,v_2)$
  - the slop of the line: s = $(v_2-v_1)/(u_2-u_1)$
  - assume $u_1 < u_2$ , $v_1 < v_2$, and 0 < 1 < 1
  So that can:
  + draw a point from vertex 1 $(u_1,v_1)$
  + add the slop into v
  + draw the point at (u, round(v))
  + until reach the end of line

