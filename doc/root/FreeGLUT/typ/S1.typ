= 计图入门之FreeGLUT (1)

#set math.mat(delim: "[")
#set math.vec(delim: "[")

== Intro

本文为计图入门的第一篇, 主要以介绍 `FreeGLUT` 为主.

前文 #link("./S0.typ")["计图入门之FreeGLUT(0)"] .

=== Background

说实话中文互联网里, 有关于 `FreeGLUT` 的资料不多,
基本是初学计图的Blog.

唯一可以找到的相关资料是 
#link("https://learnopengl-cn.github.io/")[主页 - LearnOpenGL CN],
而且它也是以 `glew` 为主要介绍目标.

同时, 不知道是否是搜索能力不足, 没办法找到 `FreeGLUT` 的完整API文档.
目前可见的 #link("https://freeglut.sourceforge.net/docs/api.php")[文档] 并不完整.

所以本文参考资料主要来源于
- #link("https://paroj.github.io/gltut/index.html")[Learning Modern 3D Graphics Programming]
- #link("https://openglbook.com/")[openglbook.com]

=== 吐槽

不过说真的, 用 `FreeGLUT` 画动画实在有点折磨的.

== Conventions

本文将遵循类似 "Learning Modern 3D Graphics Programming" 中的规则描述代码,
(但是很多地方不一样!)

- _defined term_: 术语表中有定义
- *FunctionNames*: 函数命名, Pascal风格
- nameOfVariables: 变量命名, 小驼峰风格
- GL_ENUMERATORS: 枚举常量
- /Paths/And/Files: 路径
- `<K>`: 按键 "K", `<S-K>` 才会得到字母 "K"

== 数学基础

=== Vector Math

从几何上来看, 向量可以表示一个特定空间中的位置或方向.
向量的位置表示了空间中的一个特定位置.

向量同样可以表示方向, 方向向量没有原点, 只是表示了空间中的位置.
所有位置向量只要方向和长度相同, 即可认为相同.

从代数角度来看, 向量是一系列的数字, 每一个表示一个维度的信息.
所以二维向量有两个数值, 三维向量有三个, 依此类推.

比如, 一个三维向量可以是 $angle.l X, Y, Z angle.r$, 而作为等式中的一部分时,
可以是
$ arrow(a) = vec(x, y, z) $

- 向量加法遵循平行四边形原则 (三角形原则), 从代数来看, 就是直接将对应维数相加.
- 向量的反向和减法, 直接取负向量即可反向向量, 减法可以通过加上一个负向量实现.
- 向量/标量乘法, 标量乘以对应维数.

向量运算遵循交换律, 结合律, 分配律.

向量的长度表示了向量的值大小, 终点到起点的距离, 在欧几里得坐标系内, 向量的范数为:
$ |arrow(a)| = sqrt(sum_(i=1)^n a_i^2) $

单位向量由自身除以范数得到, $ hat(arrow(a)) = 1/ (|arrow(a)|) $

=== 栅格化器流水线

所有计算机屏幕上被展示出来的东西都是通过二维的像素矩阵表示的.
当放大仔细看屏幕的时候, 可以看出来, 模糊的由三种不同颜色小灯泡展示的小方块.
这种小方块就是像素, "#text([*Pic*])ture #text([*El*])ement".
这种二维像素矩阵就组成了图像.

图形学的作用在于, 确定哪些颜色需要被放到哪些像素上.
当所有的图像都被映射到2D平面, 如何处理3D的对象? 将3D对象处理成为2D图像的过程,
被称作渲染.

有多种方式渲染3D图像, 一种可以实时应用图形硬件, 如, 显卡, 
