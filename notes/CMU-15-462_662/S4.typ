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

Consider a band-limited signal: has no frequencies above some threshold
$omega_0$.

The signal can be perfectly reconstructed if sampled with period
$T = 1/(2omega_0)$.
Using "sinc filter".

Ideal filter with no frequencies above cutoff, and also infinite extent.

Sinc filter is $sinc(x) = 1 / (pi x)$.
Wave goes forever.

== Sampling in computer graphics

Signal are often not band-limited in computer graphics.

When there exists sharp edge, to add higher and higher infinite series of
frequencies, till it eventually approximate looks like a piecewise constant function.
分段函数

When there exists a disconnected in image, like sharp edge, the input 
have infinite frequencies.

Also, ideal reconstruct filter is imparactical
for efficient implementations.
For n samples in image, for each samples must calculate the contribution to 
other samples, using sinc filter.
The $O(n^2)$ algorithm too expansive.

== Aliasing artifacts in images

== How to reduce aliasing

Integrate signal into pixels.


Increase frequency of sampling converge signal.

Super sampling: Rather than just take one sampling for coverage signal,
takes more sample for same pixel, with some location.

== Resampling

Converting from one discrete sampled representation to another.

From sampling value, to the coarsely value,
so that it can be drawn in the screen.

- Sampling in a very high frequency, ->
- Dense sampling of reconstructed signal, -> 
- reconstruct into coarsely value

So that, for a pixel:
- All covered ,If all sample are covered,
- None-covered, if non of which are covered,
- some percentage covered, if average by sampling numbers.

== Checkerboard - Exact Solution.

== How actually evaluate coverage(x, y)

How to check if a given point q is inside a triangle.

Check if it is contained in three half planes associated with the edges.

Given points $P_i$, $P_j$, along an edge and a query point $q$.
Find whether q is to the left or right of the line from $P_i$, $P_j$.

=== Incremental traversal

Visit pixels along a special order

=== Parallel coverage tests

Test all samples in triangle in parallel

=== Hybrid approach: tiled triangle traversal

Traversal a large blocks, intersect the triangle.
- If there has no pixels in a triangle, skip the block.
- If the block is contained inside the block, all should be drawn.
- If some of which in the block are inside the triangle,
  sample points parallel.

=== Hierarchical strategies

Check if the Triangle intersect with large Three Blocks.
And split it into smaller blocks till all small blocks reaches pixel size.
