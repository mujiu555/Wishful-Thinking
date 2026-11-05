#import "@preview/tysty:0.1.0": embed, entry
#import "../aut.typ": mujiu
#import "../tags.typ": topics

#entry(
  title: [FreeGLUT 入门归纳],
  id: "freeglut",
  parent-id: "index",
  date: datetime(year: 2026, month: 10, day: 31),
  authors: (mujiu,),
  tags: (topics.children.se.children.graphic.tag,),
)[
  这组笔记从搭建可运行的图形程序开始，逐步进入渲染所需的数学与流水线。建议先完成环境与项目初始化，再阅读顶点、坐标变换和光栅化。

]

#embed(include "S0.typ")
#embed(include "S1.typ")
