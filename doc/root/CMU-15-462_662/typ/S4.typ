= CMU 15-462/662

== Drawing a Trangle

Two major techniques for getting stuff on the screen:

Rasterization: 
- for each primitive (triangle), which pixels light up?
- fast
- harder to photorealism
- 2D vector arch, fonts, quick 3D preview

Ray tracing:
- for each pixel, which primitives are seen
- easier to get photorealism
- slower

== Rasterization Pipeline

Pipeline: structure computation as a series of stages,
each stage accepts some fixed data,
to simplify and optimize computation in each stage.

- Inputs: what image want to draw, the structure describe 3d object
- Stages: sequence of transformations from input to output
- Outputs: final image

Rasterization pipeline:
- Input: triangles (may with additional attributes)
- Output: bitmap image( with depth, alpha,)

== Triangles

Rasterization pipeline converts all primitives to triangles:
- can approximate any shape
- planar, well-defined normal, all points within only one plane
- easy to interpolate data at corners: barycentric coordinates

Once everything reduced to triangles,
can focus on making an extremely  well-optimized pipeline for drawing them.

== Sketch

- transform/position objects in the world
- project objects onto the screen
- sampling triangle converage
- interpolate triangle attributes at covered samples
- sample texture maps/ evaluate shaders
- combine sample into final image

== Draw triangle

- Coverage: what pixels does the triangle overlap
- Occlusion: which triangle is closest to the camera in each pixel,
  which triangle to be showing

Visibility:

- coverage computing: project each vertices of a triangle into 2d position
- which pixel to light up

Cover the pixel:
- compute fraction of pixel area covered by triangle,
  then color pixel according to the fraction.
- Sampling, test a collection of sample points, to get an estimate

Sampling: taking measurement of a signal, fetch some of the points

Reconstruction: given a set of samples,
how to to reconstruct the original signal $f(x)$,
- Piecewise constant approximation:
- linear interpolation between values of two closest samples to x
- take more sample

Summary:
- Sampling = measurement of a signal
  - Encode signal as discrete set of samples
  - in principle, represent values at specific points of true value
- Reconstruction: generating signal from a discrete set of samples
  - construct a function that interpolates or approximates function values
  - piecewise constant/"nearest neighbor", piecewise linear

What function are used to sampling:
Measure the sample for
$"coverage"(x,y) := brace^(1, "triangle contains point (x,y)")_(0, "otherwise")$

Edge cases: if two triangle has both edge in same pixel.
- Breaking ties: when edge falls directly on screen sample point the sample is classified as within triangle if the edge is a "top edge" or "left edge"
  - Top edge: horizontal edge that is above all other edges
  - Left edge: an edge  that is not exactly horizontal and is on the left side of the triangle. Thus triangle may have one or more left edges

To have a clear definition for behaviour.

== Aliasing

1D signal can be expressed as a superposition of frequencies.
Sin ware

High frequencies in the original signal masquerade as low frequencies after reconstruction due to undersampling.

== Nyquist-Shannon theorem
