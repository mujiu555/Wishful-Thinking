= 计图入门之FreeGLUT (1)

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

== Hello Window

