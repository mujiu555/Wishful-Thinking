= 计图入门之FreeGLUT (0)

== 导言

计算机图形学, 
传统应用计算机科学里面重要的一部分
(为什么要强调应用计算机科学呢, 因为我更喜欢理论计算机科学, 
就是PLT什么的东西 ... ),
在现代生活的方方面面都起到了至关重要 (indispensable) 的作用 
(好吧什么玩意都是至关重要, 但是谁会关心呢).
所以总之先开一篇. 不过基本没有什么参考价值啦, 相当于是个blog了.

=== 背景

学校最近上到计算机图形学了.
虽然确实没上什么有营养的东西, 不如自己去看 CMU 15-462/662.
但是作业还是要写的.

目前来说, 作业是用freeglut画2d动画, 带交互.
所以不得不去学一下freeglut了.

== 环境配置

为了学习计图
-- 其实完全不涉及到理论方面的东西, 讲了三星期还在讲怎么画线 --
要用到的函数库是 FreeGLUT.

学校要求的IDE是Visual Studio 2022, 不过我平时用不惯VS, 所以就自己配环境了.

个人的平台是Windows 10,
开发环境是 LLVM-MinGW Clang20,
IDE是NeoVim,
工程管理器是xmake.

因为不是常规的开发方式, 所以需要自己配置一下环境.

首先是一个经典的MinGW环境, 因为要用到里面的 mingw32-make, 
所以如果能找到一个能用的make也是不用下MinGW的一大堆的.

首先到 
#link("https://github.com/mstorsjo/llvm-mingw")[LLVM-MinGW GitHub 仓库]
处下载一个最新的发行版, 解压了然后给他添加到PATH里面.

然后确认自己有没有 CMake, 没有也下载一个
#link("https://github.com/Kitware/CMake/releases/download/v4.1.1/cmake-4.1.1-windows-x86_64.zip")[cmake-4.1.1-windows-x86_64.zip] 解压了放到PATH里面.

因为用的既不是传统MinGW GCC, 也不是MSVC, 所以需要自己编译一下 FreeGLUT:

+ 依旧是到 FreeGLUT GitHub 仓库 处下载一个最新的发行版, 选择有且仅有的 freeglut-3.6.0.tar.gz 下载
+ 解压到自己喜欢的位置
+ 创建一个build文件夹
+ 终端进入到build文件夹, 调用
  ```bash cmake -G "MinGW Makefiles" CC=clang CXX=clang++ -D CMAKE_PREFIX=<your favorite path> .. ```
  运行配置
+ ```bash make -j 8``` 编译
+ ```bash make install``` 安装
+ 把include整个拷到目标文件夹 (比如 `C:\FreeGLUT`)
+ 将目标文件夹的bin (如: `C:\FreeGLUT\bin`)添加到 `PATH` 里面去
+ 将目标文件夹的include (如: `C:\FreeGLUT\include`) 添加到 `INCLUDE_PATH` 里面去

现在环境就配置完成了.

写个简单的程序验证一下:

```c 
// constants.h
#ifndef __CONSTANTS_H__
#define __CONSTANTS_H__

#define WINDOW_WIDTH 800
#define WINDOW_HEIGHT 600

#define WINDOW_NAME "Window"

#endif // !__CONSTANTS_H__
```

```c 
// main.c
#include "constants.h"
#include <GL/freeglut.h>

#define UNUSED(x) (void)(x)

void changeViewport(int w, int h) { glViewport(0, 0, w, h); }

void flush(void) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glutSwapBuffers();
}

void init(void) {
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
  glutInitWindowSize(WINDOW_WIDTH, WINDOW_HEIGHT);
  glutCreateWindow(WINDOW_NAME);
  glutReshapeFunc(changeViewport);
  glutDisplayFunc(flush);
}

int main(int argc, char *argv[], char *env[]) {
  UNUSED(env);
  glutInit(&argc, argv);
  init();

  glutMainLoop();
  return 0;
}
```

然后用 ```bash clang -l freeglut -l opengl32 -l glu32 main.c``` 编译一下 , 
如果没有出现链接错误, 且程序可以正常显示, 就是环境配置完成.

== 初始化项目

一直用 clang 命令也不是不行, 就是有点麻烦;
写 Makefile 也不是不行, 也还是那句话, 麻烦.

所以我用xmake.

那为什么不用CMake呢? CMake老是折腾不来工具链和动态库链接. 
虽然FreeGLUT是可以直接用`cmake include`的来着, 不过还是太麻烦了, 
折腾半天搞不好.

依旧是找个喜欢的位置, 然后 `xmake create -l c -t console`

修改项目配置为:

```lua
--- xmake.lua
add_rules("mode.debug", "mode.release")

target("window", function()
	set_kind("binary")
	add_links("opengl32", "freeglut", "glu32")
	add_files("src/*.c")
end)
```

配置一下工具链 ```bash xmake f --toolchain=clang```

最后
```bash git init && git add . && git commit -m "init: initialize repository"```
一下, 
项目初始化就基本完成了.

再把上述两个文件丢到 src 文件夹里面去,
用 xmake b 和xmake r编译运行一下, 验证项目配置是否正常 即可.
