#import "@preview/zh-kit:0.1.0": *

#show: doc => setup-base-fonts(doc)
#set par(first-line-indent: 0em)

#show raw: set text(font: (
  (name: "FiraCode Nerd Font Mono", covers: "latin-in-cjk"),
))

= CPT205 FreeGLUT Programming

== Geometric primitives

=== `glBegin(parameters)`

#figure(image("./img/CPT205-L3-1"))

- `GL_POINTS`: individual points
- `GL_LINES`: pairs of vertices interpreted as individual line segments
- `GL_LINE_STRIP`: series of connected line segments
- `GL_LINE_LOOP`: same as above, with a segment added between last and first vertices
- `GL_TRIANGLES`: triples of vertices interpreted as triangles
- `GL_TRIANGLE_STRIP`: linked strip of triangles
- `GL_TRIANGLE_FAN`: linked fan of triangles
- `GL_QUADS`: quadruples of vertices interpreted as four-sided polygons
- `GL_QUAD_STRIP`: linked strip of quadrilaterals
- `GL_POLYGON`: boundary of a simple, convex polygon

```c
glBegin(GL_XXX);
glVertex2f(0f,0f);
//...
glEnd();
```

#figure(image("./img/CPT205-L3-2.png"))

== matrices

=== 为什么用 4×4 矩阵（齐次坐标）

- OpenGL 用 4×4 齐次矩阵来统一表示三维的平移、旋转、缩放、投影等变换。把三维点 (x,y,z) 表示为四维齐次向量 (x,y,z,1)，矩阵乘法即可同时完成线性变换和位移。
- 投影需要引入 w 分量，之后做视锥裁剪和透视除法（x/w,y/w,z/w）得到 NDC（规范化设备坐标）。

=== 常见坐标空间（变换链）

- 模型空间 / 局部空间（Object/Local）：物体自身坐标。
- 世界空间（World）：把物体放到场景中的位置。
- 视图/相机空间（View / Eye）：把世界坐标变换到相机坐标系（相机位于原点，朝向 -Z）。
- 裁剪空间（Clip）：应用投影矩阵后的空间，进行齐次裁剪（根据 w 判断是否可见）。
- 规范化设备坐标 NDC：透视除法后的坐标，范围 x,y,z 在 [-1,1]（OpenGL 传统）。
- 窗口/屏幕空间（Window/Viewport）：NDC 经视口变换映射到像素坐标和深度缓存范围。

=== 三类主要矩阵（现代渲染常见）

- Model（或 ModelMatrix）：把顶点从对象空间变换到世界空间。
- View（或 ViewMatrix）：把世界空间变换到相机/视点空间；通常是相机变换的逆（如果你有相机位置/朝向，通过构造 LookAt 再求逆或直接构造 view 矩阵）。
- Projection（或 ProjectionMatrix）：透视投影或正交投影，把视锥变换到裁剪空间（例如 glFrustum/gluPerspective/glOrtho）。

常用把它们组合为 MVP = Projection \* View \* Model，然后在顶点着色器里做 pos_clip = MVP \* vec4(position,1.0).

- Model-View (GL_MODELVIEW)
- Projection (GL_PROJECTION)
- Texture (GL_TEXTURE)
- Color (GL_COLOR)
Single set of functions for manipulation
Select which to be manipulated by
- `glMatrixMode(GL_MODELVIEW);`
- `glMatrixMode(GL_PROJECTION);`

=== 矩阵布局与乘法约定（OpenGL 的惯例）

- 内存布局：OpenGL 与 GLSL 默认使用列主序（column-major）。也就是矩阵在内存中按列依次存储。
- 向量位置：OpenGL 习惯把向量视为列向量，数乘形式为 v' = M \* v（M 是 4×4，v 是 4×1）。
- `glMultMatrixf` 的语义：当前矩阵 C ← C × M（右乘）
  因此，如果你依次调用 `glTranslate`, `glRotate`, 最终的 $C = I \* T \* R$.
  对顶点 v 的变换是 $C \* v = T \* R \* v$, 即先应用 R（旋转），再应用 T（平移）.
  这导致“调用顺序对应变换的相反应用顺序”的常见理解——最后调用的变换在乘法链里更靠右,
  先被应用。
- 在上传给 `glUniformMatrix4fv` 时有一个 transpose 参数:
  如果你用列主序并且 GLSL 也期望列主序,
  传 `transpose = GL_FALSE;`
  如果你的数据是行主序或想让 GL 在上传时转置可以设置为 GL_TRUE。

Conceptually there is a 4x4 homogeneous coordinate
matrix, the current transformation matrix (CTM) that is part
of the state and is applied to all vertices that pass down the pipeline.
- The CTM is defined in the user program and loaded into a transformation unit.
- The CTM can be altered either by loading a new CTM (e.g., Identity matrix) or by postmutiplication.
- OpenGL has a model-view and a projection matrix in the pipeline which are concatenated together to form the CTM.
- The CTM can manipulate each by first setting the correct matrix mode.

==== CTM Operations

The CTM can be altered either by loading a new CTM or by postmutiplication.
- Load an identity matrix: C ← I
- Load an arbitrary matrix: C ← M
- Load a translation matrix: C ← T
- Load a rotation matrix: C ← R
- Load a scaling matrix: C ← S
- Postmultiply by an arbitrary matrix: C ← CM
- Postmultiply by a translation matrix: C ← CT
- Postmultiply by a rotation matrix: C ← CR
- Postmultiply by a scaling matrix: C ← CS

We can load and multiply by matrices defined in the application program
- `glLoadMatrixf(m)`
- `glMultMatrixf(m)`

Matrix m is a one-dimension array of 16 elements
which are the components of the desired 4 x 4
matrix stored by columns.

In `glMultMatrixf`, m multiplies the existing matrix on the right.

CTM is not just one matrix but a matrix stack with the
“current” at top.

In many situations we want to save transformation matrices for use later.
- Traversing hierarchical data structures
- Avoiding state changes when executing display lists

Pre 3.1 OpenGL maintains stacks for each type of matrix.
Access present type (as set by `glMatrixMode`) by `glPushMatrix()`, `glPopMatrix()`

Right now just 1-level CTM

We can also access matrices (and other parts of the state) with query functions
- glGetIntegerv()
- glGetFloatv()
- glGetBooleanv()
- glGetDoublev()
- glIsEnabled()

For matrices, we use as
- double m[16];
- glGetFloatv(GL_MODELVIEW, m);

Functions:
- `glTranslate*()`: Specify translation parameters
- `glRotate*()`: Specify rotation parameters for rotation about any axis through the origin
- `glScale*()`: Specify scaling parameters with respect to the co-ordinate origin
- `glMatrixMode()`: Specify current matrix for geometric-viewing, projection, texture or colour transformations
- `glLoadIdentity()`: Set current matrix to identity
- `glLoadMatrix*(elems)`: Set elements of current matrix
- `glMultMatrix*(elems)`: Post-multiply the current matrix by the specified matrix
- `glGetIntegerv()`: Get max stack depth or current number of matrices in the stack for selected matrix mode
- `glPushMatrix()`: Copy the top matrix in the stack and store copy in the second stack position
- `glPopMatrix()`: Erase top matrix in stack and move second matrix to top stack
- `glPixelZoom()`: Specify 2D scaling parameters for raster operations


=== 基本变换矩阵（4×4）

- 平移 (tx,ty,tz):
  `[1 0 0 tx
   0 1 0 ty
   0 0 1 tz
   0 0 0 1]`
- 统一缩放 s:
  `[s 0 0 0
   0 s 0 0
   0 0 s 0
   0 0 0 1]`
- 非均匀缩放 (sx,sy,sz): 对角线为 sx,sy,sz,1
- 绕 X 轴旋转 θ:
  [1    0       0    0
  0  cosθ  -sinθ   0
  0  sinθ   cosθ   0
  0    0      0    1]
  （Y、Z 轴类似）
- 绕任意单位轴 u = (ux,uy,uz) 旋转 θ（Rodrigues / 轴角公式），可写出 3×3 子矩阵再扩展为 4×4。
- 正交投影 glOrtho(left,right,bottom,top,near,far):
  对角项与平移按公式设置，把视盒映射到裁剪盒，Z 映射到 [-1,1]。
- 透视投影（glFrustum 或 gluPerspective）: 一般形式的 4×4，把近裁剪面 near、远裁剪面 far、视角和宽高比等映射到裁剪空间，使得深度在 [-1,1]（OpenGL 的约定）。

（可在需要时给出具体数值公式：glFrustum 的矩阵元素、gluPerspective 如何由 fovy/aspect 计算）。

=== 透视裁剪与透视除法

- 投影矩阵将顶点变换得到 clip-space 坐标 (x_c,y_c,z_c,w_c)。裁剪在 -w_c <= x_c,y_c,z_c <= w_c 进行。
- 然后对坐标做透视除法： (x_ndc,y_ndc,z_ndc) = (x_c/w_c, y_c/w_c, z_c/w_c) 得到 NDC，随后做视口变换得到屏幕像素坐标。
- 因此视点的远近和 near/far 的选择会影响深度分辨率与精度。

=== 深度范围与坐标系统差异

- 传统 OpenGL NDC z 范围是 [-1,1]（对应 glClipPlane 后的行为）。很多现代图形 API（Direct3D）使用 [0,1]。
- 在使用多种库或 API 时要注意深度范围差异，某些 math 库或引擎会为不同 API 构造不同的 projection 矩阵。

=== 法线矩阵（normal matrix）

- 顶点位置用 ModelMatrix 变换，但法线向量不能直接用相同矩阵变换（尤其遇到非均匀缩放时）。
- 正确做法是用 ModelMatrix 的上左 3×3 的逆转置（inverse(transpose(M3x3))) 来变换法线。在着色器里经常传一个 3×3 的 normalMatrix = transpose(inverse(mat3(modelView)))。
- 如果 ModelMatrix 只包含旋转与均匀缩放（或正交变换），inverse(transpose(R)) = R（或只需缩放的逆因子），可简化处理。

=== OpenGL 旧固定管线的矩阵栈（已弃用）

- 早期 OpenGL 提供矩阵堆栈：GL_MODELVIEW、GL_PROJECTION、GL_TEXTURE 等，通过 glMatrixMode/glLoadIdentity/glPushMatrix/glPopMatrix/glTranslate/glRotate/glScale 等操作管理。
- 现代 OpenGL（Core profile）中已弃用，推荐自己在 CPU 构造矩阵（glm 等库）并作为 uniform 上传到着色器。

=== 常见实践与建议

- 在 CPU 端预先计算组合矩阵（MVP），避免在顶点着色器里重复做相同的矩阵乘法（节省带宽与计算）。
- 注意矩阵乘法的顺序与你使用的向量约定（行向量 vs 列向量）。GLSL 默认列向量，矩阵在表达式中按列主序。
- 始终把 near 值设为尽可能大（不为 0，且不要太小），以提高深度精度；far 应设置为尽可能小的需要值。
- 对法线使用 inverse-transpose 矩阵；如果只做旋转，则直接用模型矩阵的上左 3×3 即可。
- 上传矩阵给 shader 时，确认是否需要转置（glUniformMatrix4fv 的 transpose 参数）；如果你用列主序数据且 GLSL 默认列主序，通常传 GL_FALSE。
- 使用 double 精度矩阵只有在极大坐标范围或高精度需要时才有意义（大多数 GPU 着色器只使用 float）。

=== 举例（常见 API）

- 构造 View（LookAt）：
  1. 给出 eye（相机位置）、center（目标点）、up（上向量）。
  2. 计算 z = normalize(eye - center)、x = normalize(cross(up, z))、y = cross(z, x)。
  3. 形成旋转矩阵 R = [x y z]（作为列）和平移 t = -R \* eye，最后把 R,t 组合成 4×4 view 矩阵。
- 构造透视（类似 gluPerspective）：
  f = 1 / tan(fovy/2)
  然后矩阵元素按公式设置，使得 x 和 y 根据 aspect & f 缩放，z 根据 near/far 映射到 [-1,1]，并在第四列产生 w = -z（产生透视效果）。


== Projection

`gluLookAt(eye_position, look_at, look_up)`
`GLAPI void GLAPIENTRY gluLookAt (GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ);`
Specify three-dimensional viewing parameters
`eyeX`, `eyeY`, `eyeZ` for 视点
`centerX`, `centerY`, `centerZ` for 视线
`upX`, `upY`, `upZ`, for 视角, 头顶朝向, 相机正方向

Set view pointer and view direction.

`glOrtho( GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)`
Specify parameters for a clipping window and the near
and far clipping planes for an orthogonal projection

`glFrustum( GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)`
Specify parameters for a clipping window and the near
and far clipping planes for a perspective projection
(symmetric or oblique).

`gluPerspective( GLfloat fov, GLfloat aspect, GLfloat near, GLfloat far)`
Specify field-of-view angle (fov which is a matrix) in
the y-direction, aspect ratio of the near and far
planes; it is less often used than `glFrustum()`

