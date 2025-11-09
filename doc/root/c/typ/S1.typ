#import "@preview/zh-kit:0.1.0": *

= From The C Programming Language To Theoretical Computer Science

#show raw: set text(font: (
  (name: "FiraCode Nerd Font Mono", covers: "latin-in-cjk"),
  "Noto Sans CJK SC"
))

#show: doc => setup-base-fonts(doc)

Author: #text("GitHub@mujiu555").

Address: #link("https://github.com/mujiu555/Wishful-Thinking.git")[mujiu555/Wishful-Thinking].

The book, has not extracted from my Misc Repository.
Waiting for finishing.

#outline()

== Section I: C Programming Language

To have a glance to computer science, we must have known a programming language, and then it could lead you to
understand some key concept within the computer and programming language design.

== Intro

C语言, 历史悠长, 自从它于80年代伴随 Unix 出现,
便成为了全世界开发者的心头好. 至今为止都依然被广泛使用.
上到各种琳琅满目的应用程序, 下到操作系统内核, 都可以由C编写,
都依赖C的代码.

举个例子: 世界上的绝大多数服务器, 都是由 `Linux` 承载着的, 而 `Linux`
的内核, 几乎只有 `C` 所编写的代码. 当然, 在大家的手机上,
任何一部安卓手机, 它的内核, 其实也是Linux, 可以说,
C 驱动着世界上绝大多数设备的运行.
(之所以不用Windows举例, 一是Windows是一个闭源产品,
二是Windows内核主要由微软自己魔改的C++代码编写)

C是一门高级语言, 但是何为高级语言?

== High Level Language

高级语言是相对于低级语言而言的. 一般而言, 我们所说的低级语言,
是各个不同设备上面的汇编语言, 这些语言非常强大, 可以操作 CPU,
也非常基础, 一旦没有它们, 任何后续的工作都无法进行.

但是它们的问题也非常严重. 那就是它们与平台极度绑定, 一段代码,
只能在特定平台上工作. 即便逻辑相似, 或者完全一致,
但是你还是不得不按照不同平台的规定, 为它们依次适配.
这仅仅只是开发过程, 就已经可以体会到通过低级语言开发程序的麻烦了.
而到了软件升级这一步骤, 这样的一套流程就更加恐怖, 复杂度直线上升.

而高级语言, 是一种对于低级语言共同特征的抽象,
帮助程序员写出可以在不同平台间无痛或相对轻松移植的代码.

低级语言, 就像是专门为特定的设备编写的特制工具, 只能在某台设备上面使用.
它们虽然可以直接操作硬件设备, 但是写起来非常复杂.
而高级语言, 比如C或者Python, 可以让程序员使用更加容易理解的方式写出程序.
系统可以帮你, 将你的代码, "翻译" 成为机器可以理解的指令,
这样即便不担心底层的细节, 也能让程序在不同的设备上运行.

当通过C编程语言进行工作的时候, 我们可以抽象出加减乘除等操作,
分别对应操作不同位数数据的汇编指令; 可以抽象出各种变量,
直接对应内存中的一段空间.

比如: 
如果只是以两数相加举例的话,
对于C而言, 无论哪个平台的加法都可以通过 `a + b` 来完成, 但是对于
`IBM` 兼容机型的 `x86_64` 架构 `intel` 语法宏汇编 (好长的定语) 而言,
则可能是 `ADD AH, BH`, `ADD AX, BX`, `ADD EAX, EBX`, 乃至于
`ADD RAX, RBX` 这里甚至只是考虑到只有两个通用寄存器参与运算的情况,
如果还有内存, 还要复杂的多. (其实如果用 `AT&T` 语法还能更复杂些, 毕竟
`AT&T` 还要考虑指令名的问题).

这就为程序的移植提供了极大的方便, 不再需要手动为不同的平台进行适配.

=== Mid-Level Language

C语言虽然名义上是一个高级语言, 但是很多人并不这么认为,
因为C语言并不提供一种通用的内存管理方案.
所有的内存都需要由程序员自己来手动管理. 这为系统编程提供了便利,
但也造成了不少内存泄漏等问题. 依旧需要考虑与低级语言汇编相似的边界问题.

因此, 便有人将C语言称作中级语言, 过渡语言. 不过,
这不过是称呼上的差别而已.

=== Compile & Interpret

CPU 实际上只能够理解和运行二进制的机器码.
因此, 直接以人类可读形式写出来的代码, 计算机没有办法直接执行.
这就需要对代码进行 `编译`, 或者 `解释`.

#grid(
  columns: 7,
  rect[源代码],
  [$stretch(-->)^("编译")$],
  rect[汇编文件],
  [$stretch(-->)^("汇编")$],
  rect[目标二进制],
  [$stretch(-->)^("链接")$],
  rect[目标可执行]
)


1. 编译, 是将代码编译到汇编语言 (或其他语言),
  再通过汇编器生成对应二进制代码, 最后链接, 产生原生可执行程序
  (该可执行程序会最终包含操作系统需要的结构) 的一种过程.

#grid(
  columns: 7,
  rect[源代码],
  [$stretch(-->)$],
  rect[解释器],
  [$stretch(-->)$],
  rect[输出]
)

2. 解释, 则是不经过编译过程, 通过虚拟机, 或者解释器,
  随读入源文件执行代码的过程.

实际上, 对于现代语言, 编译型语言和解释型语言的区别并没有特别大.
比如, `Java` 语言就既需要编译到`JVM bytecode`,
也需要用 `JVM` 解释字节码运行.

而我们, 会因为一门语言更倾向于如何运行, 来说这个语言是编译型语言,
或解释型语言.
比如, C语言, 就是一门会要求编译, 再运行的语言, 因此,
我们认为, C语言, 是一门编译型语言.
再如, 大家或许熟悉的 Python语言,
便是通过解释器执行的, 因此才认为 python语言 是一门编译型语言.

== Environment And IDE

不知道大家是否喜欢玩 PC 上的游戏, 有时候玩游戏会提示缺少 `DirectX`
运行时环境, 编程也和玩游戏一样, 是需要环境的. 一般而言,
我们将这种专门用于开发程序的环境, 称作开发环境.
而将所有开发所需要的工具和开发环境本身, 一起打包, 并预先配置的软件系统,
就称作集成式开发环境(IDE).

在 Windows 平台上, 最常用的C语言 IDE 是 Microsoft (C) Visual Studio,
不过这个 IDE 以及它配套的编程环境, 都是为了 C++ 和 C\# 而量身设计的,
并不太适用于 C 语言, 而它强制要求的工程管理, 以及提供的过多功能,
也容易导致初学者眼花缭乱, 忽视C语言学习的核心.

而 MacOS 平台上, 苹果公司提供了 Xcode IDE, 不过除了不得不写 Swift,
也几乎没有人使用它.

Linux 平台, 最常用的 "IDE" 是 (Neo)Vim 和 Emacs, 不过,
并不适合所有人使用.

鉴于平台相对不易统一, 而以上三个平台, 均提供了相对简单的方式以
`LLVM-Clang` 编译器作为 C语言 的编程环境, 在此处,
我们将采用手动配置环境的方式, 来作为学习C语言的第一步. 这也是大多数教程,
机构, 学校, 并不会教授, 而对于后续编程学习至关重要的一个部分.

另两个个人认为相对重要的部分是工具的使用和工具与知识的区别, 分别可以在
"计算机教育中缺失的一课 (The Missing Semester of Your Computer Science
Education)" 和 "理论计算机导论 (Introduction to Theoretical Computer
Science)" 中找到.

=== Environment Variables

环境变量可以被视为程序的设置, 它们告诉程序该如何工作,
比如, 配置 "PATH" 可以帮助程序找到需要的文件或者指令.

简单的理解, 对于程序而言, 这就是字典的索引, 当我试图索引一些信息的时候,
可以先去目录找到 "键", 然后根据 "键" 取得 "值".

而这些组合, 可以控制程序的行动. 目前需要了解,
并且对于今后都非常重要的一些环境变量分别是:

- `PATH`: PATH 变量就像是指示牌, 告诉了系统到哪些地方找到你输入的指令
- 例如:
  当你希望去通过 gcc 来编译程序的时候, 系统就会到 path 指定的文件夹中,
  查找 gcc 程序. 如果没有办法找到, 就会报错.
- 当我们在控制台(命令行) 输入一些指令, 并试图执行它们的时候,
  操作系统就会通过 Path 环境变量搜索, 如果可以找到,
  就执行对应找到的指令, 如果没有, 则会报错.
- 当然,
  不只是我们自己执行指令的时候需要用到Path, 很多其他的程序也会通过 PATH
  来找到它需要的程序. 比如动态链接器 (`ld-linux-x86_64.so`)
- 好吧其实目前只用知道 PATH 一个就够了 (

=== Windows

对于 Windows 而言, 环境变量的修改非常便捷安全:

打开 文件资源管理器 (Explorer), 右键点选 "此电脑", 并在弹出菜单中选择
"属性" - "高级系统设置" - "高级" - "环境变量"
即可看见环境变量的配置窗口.

如果需要编辑任何之一, 只需要双击点选项目, 就可以看见对应修改界面了.

那么, 如果需要手动安装C语言的开发环境, 就需要先下载对应编译器,
然后将编译器本身所在的路径通过以上的方式加入PATH环境变量中.
不过, 相对于其他方式来说, 这种方式不仅不方便, 当需要更新开发环境的时候,
也会非常麻烦.

当然, windows也有更简单的方法去安装 C语言 的编程环境, 那就是通过 WSL.

WSL的全称是 "Windows Subsystem for Linux",
是微软创造出来, 用于提升开发者体验的一个工具.
凭借WSL, 我们可以非常容易的, 像直接使用Linux一样的安装和管理开发环境.

如果需要在Windows上安装WSL, 我们首先需要:
+ 通过管理员权限, 打开一个控制台. ```cmd Windows+X A```, 
  #figure(image("img/F1-Console.png"), caption: [Open a console])
+ 在弹出的窗口中选择允许
  #figure(image("img/F2-Admin-Console.png"), caption: [Opened console])
+ 并输入 ```pwsh wsl --install``` 和 ```pwsh wsl --update```
  #figure(image("img/F3-Install.png"), caption: [Install `WSL`])
  #figure(image("img/F4-Update.png"), caption: [Check Update])
+ 此时, 我们需要按照指示, 重新启动电脑, 以满足系统更新需求
+ 完成后, 运行 `WSL` (或者, 在开始菜单找到`Ubunut`), 运行,
  并按照指示, 创建初始用户, 注意:
  输!入!密!码!的!时!候!并!不!会!显!示!已!经!输!入!了!多!少!
  请盲打输入密码, 当完成一遍输入以后按下回车完成输入
  一共需要输入两遍密码, 两遍输入的密码需要相同
  #figure(image("img/F5-ubuntuinstall.png"), caption: [Initializing `WSL`])
  - 以下为示例文本:
    ```txt
    Installing, this may take a few minutes...
    Installation successful!
    Please create a default UNIX user account. The username does not need to match you Windows username.
    For more information visit: https://aka.ms/wslusers
    Enter new UNIX username:
    ```
  - 看见这个界面, 或者文本, 即可开始输入用户名称, 如
    ```txt
    Enter new UNIX username: dot
    ```
  - 此时, dot即为我输入的用户名, 这个用户名不需要与Windows的用户名相同,
    但是须满足, 
    1) 仅包含小写字母, 下划线, 或数字, 
    2) 数字不在开头,
    3) 用户名中不包含空格.
    当按下回车, 会显示:
    ```txt
    Enter new password:
    ```
  - 此时就应当开始输入密码:
    输入完成后, 仍然只会呈现 `Enter new password:`字样,
    此时按下回车, 就完成了第一遍的密码输入:
    ```txt
    Enter new password again:
    ```
  - 这时就需要开始进行第二次密码输入.
  当输入完成后, 就会进入到我们的正常环境,
  如果存在, 输入完成后, 用户为root的, 说明安装失败, 需要重新安装.
  重新安装的步骤为:
  - 打开任意终端:
    按下 "Win键+R键", 看到运行窗口:
    #figure(image("img/F6-Run.png"))
    #figure(image("img/F7-cmd.png"), caption: [Run Cmd])
  - 运行删除指令:
    ```bat
    wsl --unregister Ubuntu
    ```
    取消 `WSL` 发行版注册
  - 再次运行安装指令
    ```bat
    wsl --install
    ```
    或,
    打开微软商店, 搜索 "Ubuntu",
    #figure(image("img/F9-Store.png"), caption: [Store])
    选中 "Ubuntu", 或 "Ubuntu-24.04 lts", 此处以 "Ubuntu" 为例:
    #figure(image("img/F10-Ubuntu.png"), caption: [Ubuntu `WSL`])
    点击获取, 即可开始安装.
+ 完成上述步骤, 即可开始环境配置:
  + 第一步: "换源", Ubuntu默认获取软件的方式是从境外服务器拉取软件,
    这样的速度非常缓慢, 因此, 需要将服务器切换回到中国提供商.

    这里使用清华大学开源软件镜像站为我们提供的免费软件代理服务:
    #link("https://mirror.tuna.tsinghua.edu.cn/help/ubuntu/"),
    在清华的站点, 可以看到, 它对于我们如何进行换源操作有完整的介绍:
    注意: 对于安装了 "Ubuntu" 或 "Ubuntu-24.04 lts" 的同学而言,
    需要使用的是清华镜像站使用帮助中的 "DEB822格式" 下的文本:
    #figure(image("img/F11-Mirror.png"), caption: [tuna.Tsinghua mirror help])

    - 打开Ubuntu, 输入指令:
    ```bash
    sudo su
    ```
    这时候会提示输入密码:
    ```txt
    [sudo] enter password for dot:
    ```
    因为我的用户名为"dot", 所以提示的是输入 "dot" 这个用户的密码.
    当输入完成后, 就会进入 "root" 用户的终端中.
    此时, 输入:
    ```bash
    cat > /etc/apt/sources.list.d/ubuntu.sources
    ```
    #figure(image("./img/F12-root.png"), caption: [Substitute Mirror])
    运行完以后, 将从清华开源软件镜像站处拷贝的文本,
    直接粘贴 (右键) 终端当中:
    #figure(image("./img/F13-paste.png"))
    当粘贴完成后, 按下回车, 同时按下 "Ctrl键+D键", 即可完成换源工作.
    #figure(image("./img/F14-paste-result.png"), caption: [paste result])

    最后, 需要输入 ```bash exit``` 退出 "root" 用户环境.

  + 第二步是更新源信息: 刚刚的步骤仅仅只是告诉系统, 应该用哪里的服务器,
    但是实际上, 并没有更新具体还可以安装哪些软件, 因此需要更新源信息:
    ```bash
    sudo apt update && sudo apt upgrade
    ```
    通过这个指令, 即可更新源信息. 在这以后, `WSL` 才真正可以正常使用.
    #figure(image("img/F15-update.png"), caption: [Update repository information])
    #figure(image("img/F16-upgrade.png"), caption: [Running update])

    当更新进行一半的时候, 系统会提示是否确定更新, 此时直接按下回车即可:
    #figure(image("img/F17-confirm.png"), caption: [Confirm])

  + 完成初始之后, 就可以安装编程环境了:
    ```bash sudo apt install build-essential gdb clang```
    在这一步, 也是会提示输入密码的
    #figure(image("img/F18-install.png"), caption: [Install required tools])

    同样的, 在执行到一半的时候, 会要求确定操作, 直接回车即可.

完成了上述的操作, 就可以架设自己的IDE了,
比如, 可以使用 "Visual Studio Code", 并加装微软提供的 "C/C++" 插件.
或者直接在WSL中安装 NeoVim, Emacs 等 Linux 传统开发工具.

+ 对于 `VSCode`, 我们需要先安装好需要的插件 "C/C++",
  #figure(image("img/F19-C_Cpp.png"), caption: [Install C/C++ Plugin])
+ 然后选择界面左下角处的远程连接
  + !第一步: 选择左下角按钮,
  + !第二步: 选择Connect to WSL, 或 WSL, 后者会自动装插件
  #figure(image("img/F20-Connect.png"), caption: [Connect to Ubuntu])
  #figure(image("img/F21-Ubuntu-Vsc.png"), caption: [确认连接建立])
+ 最后, 再次选中插件页面, 此时找到 "C/C++", 选择, "Install for Ubuntu"
  安装完成以后, 应当可以看见如下图所示插件列表:
  #figure(image("img/F22-Plugins.png"), caption: [Plugin lists])
+ 然后打开终端:
  - 通过Visual Studio Code 的 "终端-新建终端" 菜单, 创建新终端:
    #figure(image("img/F23-Manual.png"), caption: [Open a new terminal])
  - 然后找到终端(下图红框中), 并点击进入对终端的输入模式.
    #figure(image("img/F24-Terminal.png"), caption: [Terminal])
  - 输入 ```bash mkdir -p prj```
+ 选择左侧文件浏览器 "File Explorer" 处的 "打开文件夹" (或 "Open folder").
  #figure(image("img/F25-OpenFolder.png"), caption: [Open Folder])

=== Linux, MacOS & \*nix

对于类Unix及Unix系统而言, 环境变量的修改往往和用户配置文件相关联. 不过,
实际上, 要在这类系统上安装 C 的编程环境, 完全不需要对环境变量做过多修改,
而可以简单通过几行命令完成.

以下是一些参考:

- MacOS:

```sh
xcode-select --install
```

- Linux (Debian & Ubuntu \*):

```sh
sudo apt install build-essential clang gdb
```

- Linux (Arch \*):

```sh
sudo pacman -Syy base-devel gcc make gdb clang
```

- Linux (RHEL & Fedora \*):

```sh
sudo dnf group install "Development Tools" clang
```

- FreeBSD:

```sh
pkg install gcc gdb clang
```

== Hello, World

于是便到了我们的第一个程序: Hello, World!

这是一个来自于 C程序设计语言 (the C Programming Language) 中的例子,
同时, 它也陪伴了一代又一代新生的程序员.
带着我们对自己创造的新世界的欢呼.

"Hello World" 是程序设计中的经典入门例子. 它简单的向屏幕输出一句话, 帮助你了解代码的基本结构和运行流程. 学会了如何编写和运行 "Hello World",
你就可以开始学习更加复杂的程序啦.

```c
#include <stdio.h>

int main(void) {
  printf("Hello, World!\n");
  return 0;
}
```

大家可以用任何笔记本将这段代码写下, 将它保存 (不要放桌面) 为 `hello.c`.

使用Visual Studio Code的同学可以选择,
点击左侧文件浏览器中的 "新建文件"("New File") 按钮,
#figure(image("img/F26-NewFile.png"), caption: ["New File" Button])
创建名为 `hello.c` 的文件
#figure(image("img/F27-Hello.c.png"), caption: [New file])
并回车,
在打开的文本编辑窗口中将以上代码写下并保存.

然后, 我们就可以开始进行编译了:
+ 通过Visual Studio Code 的 "终端-新建终端" 菜单, 创建新终端:
  #figure(image("img/F23-Manual.png"), caption: [Open a new terminal])
  然后找到终端(下图红框中), 并点击进入对终端的输入模式.
  #figure(image("img/F24-Terminal.png"), caption: [Terminal])
+ Enter `dir` to check if there exists file `hello.c`,
  and then type `cat hello.c`,
  just after the command has been inserted,
  the content of whole file will be displayed.
  If the content printed in screen does not match the contents showing
  in your text input area, then you have not save the file properly.
  For example, the command will response with:
  ```txt
  #include <stdio.h>
  
  int main(void) {
    printf("Hello, World");
    return 0;
  }
  ```
  in my computer with my code shown above.
+ 最后, 输入 ```sh clang hello.c -o hello```, and it will give no
  information if there are no syntax error or other problems.

然后我们就会获得一个名为hello的文件
(`hello` 是文件名, `.exe` 叫拓展名).
(you may find it at the file explorer).
这就是我们的目标可执行文件了!

Finally, 大家可以在终端中输入 ```sh ./hello``` 来执行它.
这样, 就可以看到它执行以后的结果啦:

```txt
Hello, World!
```

这样, 你就完成了c程序的基本组成, 下面, 我们将依次简单的介绍,
它们都代表了什么含义.
这样, 你就可以自己尝试, 修改这个程序的内容,
写出独属于自己的 "Hello World".

(Ten mins break.)
Try to change the source code and you may let it print your name.

=== Explanation

Looks fantastic?

Here let us explain the structure of our current program.

The c program always composed in similar order.
For example, we always have the three parts -- header file import, entry, and expression.

我们的 "Hello, World" 程序, 包含了几个部分,
库文件的引入, 入口函数(main), 以及主要的表达式.



=== Library

C语言的内核很小, 只包括了一些非常基础的功能, 而其他的部分则都通过库来提供.
同时又因为它相对比较简陋, 所以当我们使用它的库的时候需要一个描述文件,
这个文件就可以告诉编译器, 这个库提供了哪些功能.

比如说, 这段程序, 首先是一串以 '\#' 号开头的文本, 这句话表示,
我们引入了一个名叫stdio的库的定义.

'\#' 号, 实际上代表了 "预处理指令" 的开始, 这里的预处理指令就是 "include".
Include指令常常被用来包含一个文件, 比如说这里, 就包含了 stdio.h 这个文件.

Stdio, 是 "Standard Input / Output" 的简称,
它定义了常用的输入和输出函数, 它也将会成为后续C语言程序设计中最常用的库.

那么include指令是怎么样确定它需要包含哪些文件的呢?
实际上这取决于他需要包含的文件通过什么包裹.
比如在这里, 我们就使用尖括号 ('\<' 和 '\>') 包裹了 stdio.h,
它表示编译器会从系统路径中查找,
如果找到这个文件, 就将这个文件完整展开在指令处.
而如果我们通过双引号 ('“') 包裹了 stdio.h,
编译器就会先尝试从当前目录查找文件了.

大家可以尝试, 在 `hello.c` 同目录, 创建一个 `stdio.h` 文件,
再重新编译一下这个程序, 看看是否会有区别.

如果将尖括号改成双引号呢?
比如我们下面会说到的 `printf` "函数", 就是由stdio.h文件告知编译器的.

那么什么是函数呢... 先卖个关子, 后面会对函数有详细的解释.

下面就是我们程序的主体了.

=== main

```c
int main(void) {
  // ...
}
```

这部分, 就是我们的程序开始执行的部分.
如果没有它, 我们的程序就没有办法执行.

大家可以试一试, 如果不写这些部分, 只写下中间的 `printf("Hello, World!\n");`
会出现什么情况?
当然, 当我们按下运行按钮的时候, 它会告知, 这段程序并不 "合法".
当然, 这不是在说我们做了违法的事情, 而是这样的程序, 不合C语言的语法.

同时, 如果看到 Visual Studio Code 底部的 "PROBLES" 面板, 也可以看到, 它告知我们, 这个文件, 有许多的问题.
我们将它告知的信息称之为, 错误信息, 或报错.

我们将这个部分称作 "主函数定义".
而这个main, 就是主函数了.

它基本可以被认为是固定格式 (固定格式一共有四种, 托管环境三种, 非托管环境一种, 但是目前只需要会这一种即可).

```c
printf("Hello, World");
```

则是我们程序唯一的主体 --- 我们的程序实际上只干了这一件事 ---
输出 "Hello, World".

=== Function

刚才的两个部分, 我们都提到了一个概念 -- "函数",
函数是什么呢, 函数实际上是一系列代码, 一系列功能的集合,
通过定义函数, 我们可以将一些不同的操作组合在一起.
方便了程序的开发.
同样的, 也可以把这样的函数提供给自己, 或者其他人使用.

比如我们用到的 `printf` 函数, 也比如我们定义的main函数.

和数学里的函数类似, 函数可以接受一些参数, 并且产生一些输出.
就像多元微积分里的向量函数,
$ f(x, y, z): RR^3 -> RR $
就可以接受x,y,z这样的参数, 并且将它们经过一系列的变换,
让它们变成一个普通的一维值.

这里的 ```c printf``` 和它之后的圆括号的组合, 我们将其称作函数调用.
其实也和数学中的函数, 含义一致.

```c Printf(...)``` 的作用是, 将文本按照一定格式打印到屏幕上,
"Print (with) format", 就是这个意思啦.

而这里的 ```c "Hello, World"``` 就是函数调用的参数, 它告诉 `printf` 函数,
要将什么东西给输出到屏幕.

不过这里只是简单介绍它的作用哦, 实际上 `printf` 函数的作用远不止这样简单的!
我们后续会有章节单独介绍它的功能.

```c
return 0;
```

这一句, 用于终止这个函数: "main".
当编译器看见这一句话, 就知道要结束这个函数的执行了... "返回".

这其实也涉及到了一些后面的知识, 所以目前记住主函数的结束, 必须写上这样一句 ```c return 0;```就可以了.

=== Expression: Statement.

大家如果仔细观察了, 就会发现, main函数内部的两个东西, 结尾都是分号.

其实, 分号 (';'), 表示一个语句的结尾.
What is statement, statements are base unit of c programming language.
Every c program are make up with statements
For example, our simplest program is:
```c
int main(){}
```
here, it contains just a function definition statement.
But after all, every c program must have at least one statement.

Statements are colourful, but, the rule for them are relative same.
除了一些特殊情况, C语言中写下的所有代码, 结尾都是有分号的.

语句大致可以被分为五种:
+ 表达式语句
+ 函数调用
+ 流程控制语句
+ 复合表达式
+ 空语句

将会在后面详细讲解各个语句, 不过, 一定要记住, 每个语句的结尾都需要一个分号;

== Types
<types>

C 语言是一门静态类型语言. 那么, 这一句话就涉及到两个新知识点了!
- 什么是类型,
- 什么是静态类型?

作为一门计算机语言, C语言操作的实际上都是一些数值.
对于不同的数值, 我们会人为规定它是什么 "类型".

比如, 我们就将大小在 $-2147483648_((-2^31))~2147483647_((2^31-1))$
之间的整数视为 "整型数 (Integer)". 而同时, 我们也需要表示一些文本, 所以就有了所谓的 "字符(Character)" 类型和 "字符串([Character] String)" 类型.

不过为什么需要将不同类型区别开来呢?
很明显, 字符串是没有办法当作整数来处理的对吧!
#text([
  (除非你把它们当作范畴论范围上面的幺半群来看...
  当然这样也只能统一操作而没有办法让字符串和数字相加哦\~)
], size: 8pt)

那么静态类型是什么呢?

就像数学并不完全是数字的操作, 大部分时候也和未知数相关一样, 
计算机程序也有自己的 "未知数" 需要操作.
当我们需要计算一些东西的时候, 很多时候都需要一个叫做 "变量" 
的东西存储中间结果.
这个 "变量" 既然需要存储数据, 那么它就也需要一个类型.
毕竟, 不同类型的数据, 就上上面刚刚说明的, 有着不同的属性, 完全没有办法用同样的方式存储.

而 C语言 更进一步, 为了避免变量在多次赋值以后, 类型会不清,
干脆让我们在定义变量的时候就固定它可以承载的数据类型了.
#text([
  (实际原因当然不是这样啦, 实际上 C语言 必须有类型的信息,
  才能为变量分配空间, 而不同的类型一般而言需要的空间不同, 自然不可以混用,
  后续将在 "内存模型" 部分详细解说喵\~ >w<)
], size: 8pt)
这就是我们说的 "静态类型" 系统.

=== Literal

字面量, 就像我们在解数学题目的时候, 会写下一些系数, 一些常量,
字面量就是直接出现在程序当中的常量.

不过和常量有一些区别的是, 字面量是真正没有办法被改变的.
而计算机程序中的常量, 则仅仅只是表示一个变量不会被改变而已...
通过一些特殊的手段, 我们也是可以让一个常量打开心扉, 接受新的数值的.

=== Basic Data Types

对于简单的编程任务, C语言定义了一些基本数据类型.
它们涵盖了数字, 文本和逻辑(好吧其实并没有).

==== Integer

我们最常用, 并且也将最先介绍的就是整数家族了:
- `short`: 短整型, 相对于整型, 需要的内存更少, 只有16位空间
  但是相应的,可以表示的数值也越少.
- `int`: 整型, C语言中默认的数据类型, 一般为32位空间,
  也就是可以有31位二进制可以用于表示数据,
  上述的 $-2147483648 ~ 2147483647$ 便是它可以表示数据的范围
- `long`: 长整型, 相对于 `int`, 可能更长, 一般在处理大数据的时候才会用到
- `long long`: 真$dot$长整型, 确定的64位数据.

每当我们在代码里面写下一个整数, 它就会自然具有上述类型之一的信息.
比如:

```c
short s = 0;
int i = 65536;
long l = 2147483647;
long long ll = 2147483648ll;
```
注: 以上代码均写于 主函数 当中!

这里, $0$, $65536$, $2147483647$ 就都是 "int" 类型的 "字面量",
而 $2147483648$ 就是一个 "long long" 类型的字面量了.

不过这些数字前面的类型和等于号都有些什么作用呢... 大家马上也会明白!
不过我们先来了解一下整数的变体们:
- `signed`: 有符号前缀, 表示该类型是一个有符号的数据, 
  一般而言, 整型都是有符号的
- `unsigned`: 有了上一条的提示, 当我们不需要表示数据的负数部分时,
  当然就可以用无符号类型了, 当我们用无符号来修饰一个变量的时候,
  它的表示范围就会从一半正一半负, 变成完全的正数哦, 相当于给 $NN$
  加上了一个$*$的上标, 变成了$NN^*$, 不仅如此, 它正数部分的表示范围也会翻倍
- 不过虽然被称作前缀, 它们其实也是可以 "单干" 的, 当只有前缀出现时,
  实际上 C语言 (标准) 会自动给他补上一个 int 的.

这里可以再来几个例子:

```c
signed int i = 2147483647;
unsigned int u = 2147482647u;
```

Integer may be expressed as:

```txt
<number>*<suffix>     for decimal express     ; 10, 11, 5
0<number>*<suffix>    for octal express       ; 0, 01, 077
0x<number>*<suffix>   for hexadecimal express ; 0x0, 0x1a, 0xff
0b<number>*<suffix>   for binary express      ; 0b1, 0b0, 0b10
```

==== Literal Suffix

有些同学可能就注意到了, 我们有些的数字之后, 跟上了一些字符.
这些字符, 比如 `ll`,`ull`, 被称作字面量后缀, 它的作用是, 给字面量一些修饰,
以方便编译器正确的处理这些数值.

那么, 大家注意到:
```c
long long ll = 2147483648ll;
```
这一行, 大家可以尝试将这一段文本的字面量后缀 `ll` 去掉, 看一下, 会发生什么?
当我们尝试运行程序的时候, 程序报错了.

这是因为, 在C语言中, 我们写下的所有整数, 默认的类型都是int类型,
如果字面量超出了int类型的范围, 那就会出现错误.

==== Real numbers: `float` & `double`

在整数之外, 我们自然还有小数.
在 C语言 中, 我们将小数称之为 "二进制浮点数" 简称 "浮点数".

C语言中的常用浮点数一共有三种, 分别是:
- `float`: 默认浮点数, 一共占用32位字长, 不过相对于整数,
  浮点数并没有精确的表示范围
- `double`: 双精度浮点数, 相对于 `float`, 它的表示精度更高
- `long double`: 双精度的升级版

不过为什么浮点数要叫做浮点数呢?
当然是因为它的小数点不是固定的啦.

不过, 也许还有人会疑惑, 什么叫做固定的小数点?
一般而言, 小数的位数不是无限的吗?
这当然还是因为计算机表示的局限性.

比如, 当我们需要表示金额的时候, 一般都可以写作 "XX元Y角Z分" 对不对, 
那么当我们想要统一在 "元" 表示的时候, 就可以写作 "XX.YZ元" 了.
那么这里, 我们相当于是将所有单位统一到 "元",
而给 "角" 和 "分" 固定在了小数点后两位.
这就是所谓的 "定点数". 或者说, "100倍放缩的定点数".

那么, 有了 "定点数" 的前置理解,
"浮点数" 或者 "动点数" (这是我瞎起的) 就好理解了.
因为定点数太过于固定, 只能适用于某些特殊场景.
所以就可以想到,
如果我们用一些方式, 记录住小数点的位置, 不就可以来表示任意形式的小数了吗.
于是, 浮点数就诞生了.
不过, 上面我们表示的 "定点数", 是以 10 为基底的十进制定点数, 而在计算机里,
我们使用二进制数来表示数据, 因此, 我们实际上使用的浮点数也是二进制表示的.
这就可以解释什么叫做 "二进制浮点数" 了.

==== Type Boost

当然, 在数学之中, 我们也有整数和小数的运算,
大家可以先试一下, 当我们在c语言之中, 进行了可以得到小数的运算之后,
会得到怎么样的结果?

```c
printf("%d", 1 / 2);
```

结果是0, 是不是很奇怪?

因为, 在c语言中, 整数和整数之间的运算, 只会得到整数,
如果需要一个浮点数结果,
就必须让一个浮点数参与运算,
比如
```c
printf("%f", 1 / 2.0);
```
这样, 就得到了0.5.

为什么会这样呢?
因为在 C语言中, 当一个运算涉及的类型不相同的时候, 会将表达范围较小的数据,
转换成为表达范围更大的一个数据, 再去参与运算.
我们将这种过程称作, 自动类型转换.

当这里的int类型的整数, 遇见了2.0这样一个float类型的浮点数,
实际上浮点数的表示范围大于整数, 所以, int就被提升到了float类型,
并且参与运算, 得到 1.0 / 2.0 = 0.5 了.

以下是自动类型转换的图表
#table(
  columns: 7,
  stroke: none,
  table.cell(colspan: 7, )[small `------------------------------------------------------->` large] ,
  [char, short, int], [unsigned int], [long], [long long], [float], [double], [long double]
)
从左到右, 类型依次自动提升.

而从整数开始的类型转换, 被称作 "整型提升".
比如可以看到, char, short, int类型, 均为同样的自动类型转换阶段.
因为对于char, short, 和int类型, 都发生了相同了整型提升,
按照C语言的规则, 会将所有的表示范围小于int的类型,
均提升到int类型的大小来参与运算.

#block[
无论使用什么整数, 都可以在表达式中使用char, short int或 int字段(全部带符号或没有符号)或枚举类型的对象.
如果一个int可以代表原始类型的所有值, 则该值将转换为int;
否则, 该值将转换为unsigned int, 这个过程称为整体提升.
]

这从汇编的角度来看, 其实就是将寄存器由小寄存器, 拼接到相对大的寄存器.
如, 将 `AH`寄存器, 提升到`EAX`寄存器.

==== String & Char

另一部分, 在数值之外, 就是字符类型和字符串了.

我们在数学的学习中, 计算出的结果, 直接写在 "解" 字后面就可以,
这实际是一种得出结果的 "输出" 过程.
那么, 同为进行数学计算的计算机, 要如何组织它的输出呢?
当然就是靠字符串咯:

```c
printf("This Is A String");
```

依旧是熟悉的 `printf`, 不同的是它需要操作的字符串.

字符串, 顾名思义, 是一串连续的字符序列, 一般我们用双引号括住的一串连续文本来表示一个字符串字面量.

那么字符该怎么样表示呢?

很简单, 除了双引号, 我们还有单引号呀.
理想情况下, 所有的单引号包括的单个字符都是一个字符.
不过, 因为有些字符完全没有办法用键盘打出来, 所以我们也提供了另外一些方式:
- `'c'`: 单引号包括字符
- `'\ooo'`: 按8进制表示的字符
- `'\xhhh'`: 按16进制表示的字符

当然咯, 有些字符远超过了字符可以表示的长度(8位), 所以我们还有另一种字符类型:
"长字符" 类型.
- `L'c'`: 单引号包括的长字符
- `L'\ooo'`: 单引号包括的8进制表示长字符
- `L'\xhhhh'`: 单引号包括的16进制长字符

大家其实也可以看出来, 
长字符字面量实际上就是给普通的字符字面量添加了一个"L"前缀罢了.
那么实际上, 我们也可以用同样的方式, 把一个普通的字符串字面量变成长字符串:

```c
wprintf(L"Hello World");
```

注: 实际上中文字符都会超过字符类型可以表示的范围,
但是为什么普通字符串可以表示含有中文的文本呢?
比如, ```c printf("你好, 世界");```.
因为字符串实际上不一定是一个字符变量表示一个字符, 现在看来可能会有些绕口,
但是当我们讲到字符串实际的表示方式的时候, 就会很好理解了.

所以也不是特别需要用长字符串来表示文本了.

对了, 不知道大家有没有注意到, 当我们描述整数类型的时候, 并没有说到8位整数,
对应着其他语言中很常见的 ```java byte``` 类型?
这是因为, c语言用 ```c char```类型代替了8位整数, 所幸,
c语言中并不是很常用到8位的数值, 因此这样的代替也并不是很大的问题.
当我们真的需要它的时候, 也可以临时用 ```c char``` 类型充当一下.

=== Logical Values

当然, 计算机也不总是只处理数值.
作为一堆二三极管, 逻辑门, 晶体管拼接而成的产物,
有有着天生的二进制表示,
二进制逻辑也是计算机程序处理的内容之一.

先从简单的入手, 逻辑一共有两种状态,
是, 或者否, 在 C语言 中, 我们用了一种很简单的方式来表示:
- 数值为0: 否 (`false`),
- 否则: 是 (`true`).

很简单对不对.

=== Void Type

以上的类型, 都还很具体, 不过当我们需要表示 "这里没有东西" 呢?
该怎么办?

这时候我们就需要用到 `void` 类型了.
不过这里不解释太多, 我们将会在应用中见证它的使用.

== Mathematics Operations

有了数字, 并不能让我们进行计算, 我们还需要定义对于这些数字的运算才可以.

所以首先, 对于所有的数值, 不管是整型数家族的, 还是浮点数家族的,
都适用于我们熟悉的四则运算, `+`, `-`, `*`, '/'.

#table(
  columns: 4,
  stroke: none,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`+`], [两数相加, 并返回新的相加后的值], [```c A + B```], [],
  [`-`], [从前数中减去后数, 并返回新的相减后的值], [```c A - B```], [],
  [`*`], [两数相乘, 并返回新的乘积], [```c A * B```], [],
  [`/`], [前数除以后数, 并返回除商],[```c A / B```], [],
  table.hline(),
)

当然了, 由于取余数的操作太有用了,
实际上 C语言 也为整数和浮点数的取余操作定义了两个方式,
并将这种运算称作 "取模":

#table(
  columns: 4,
  stroke: none,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`%`], [取模], [```c A % B```], [],
  [`fmod`], [浮点数取模], [```c fmod(A, B)```], [该方法为函数调用, 仅对`double`类型浮点数生效],
  [`fmodf`], [浮点数取模], [```c fmodf(A, B)```], [该方法为函数调用, 对`float`类型浮点数生效],
  [`fmodl`], [浮点数取模], [```c fmodl(A, B)```], [该方法为函数调用, 对`long double`类型浮点数生效],
  table.hline(),
)

下面则是c语言中, 整型变量特有的四种运算符, 它们被称作 "自增/自减运算符"

#table(
  columns: 4,
  stroke: none,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`++`], [自增], [```c A++```], [先将原始值返回, 再将变量值增加1],
  [`++`], [自增], [```c ++A```], [先将变量值增加1, 再返回增加后的值],
  [`--`], [自减], [```c A--```], [先将原始值返回, 再将变量的值减少1],
  [`--`], [自减], [```c --A```], [先将变量的值减少1, 再返回减少后的值],
  table.hline(),
)

大家可以发现, 自增和自减运算符都是有一定的规律的,
如果运算符的位置在变量的前面, 那么就是先对变量进行操作, 然后再取值,
而如果运算符的位置在变量的后面, 则先取值,
等到值参与完运算以后再给变量自增或自减.

```c
int i = 0;
printf("%d", i++); // => 0, i = 1;
printf("%d", ++i); // => 2, i = 2;
printf("%", i);
printf("%d", i--); // => 2, i = 1;
printf("%d", --i); // => 0, i = 0;
printf("%", i);
```

同样的, 大家也可以看到, 这里对于运算符的描述并不是对数值生效了,
而是对 "变量" 生效.
那么变量是什么东西呢?
正如之前已经提到过的, 变量是一种用来存储数值的东西,
那么既然变量可以存储数值, 并且也可以参与运算,
所以我们就也自然会有一些对于变量本身存储的数值进行操作的运算符,
除了这里讲到的自增自减运算符, 其实还有其他的, 比如赋值运算符.

=== Relation Operations

除了数值运算, 实际上我们也可以对这些数值进行比较,
在 C语言中,
这些用来比较不同数值之间大小关系的运算符, 被称作 "关系运算符".

关系运算符对于所有的数值都生效, 而对于字符串, 由于字符串的比较也非常常用,
因此, 字符串比较的函数也是被纳入到了标准函数库中.
不知道大家是否还记得前面提到的, 什么是 "库".
库, 就是一种由其他人写出来, 而不是由C语言本身提供,
定义了一系列有用的函数以供导入的东西.

好吧, 扯远了, 一下就是所有常用的关系运算符 (和函数):

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`==`], [相等关系], [```c A==B```], [若A等于B, 则返回1],
  [`!=`], [不等关系], [```c A!=B```], [若A不等于B, 则返回1],
  [`>`], [大于关系], [```c A>B```], [若A大于B, 则返回1],
  [`<`], [小于关系], [```c A<B```], [若A小于B, 则返回1],
  [`>=`], [大于等于], [```c A>=B```], [若A大于等于B, 则返回1],
  [`<=`], [小于等于], [```c A<=B```], [若A小于等于B, 则返回1],
  [`strcmp`], [字符串比较], [```c strcmp(A, B)```], [若两字符串相等, 返回0, 否则返回按字典序相减值],
  [`memcmp`], [内存比较], [```c memcmp(A, B)```], [返回两内存空间相减二进制值],
  table.hline(),
)

不过, 必须要注意的一点是, C语言中不存在连续不等式, 也就是说,
C语言中是没有办法写出类似 $A>B>C$ 的这种表达式的.

那么, 如果真的不小心写出了这样的代码, 会发生什么事情呢?
比如说 ```c 1 < a < 10```.

实际上, 这种表达式会被C语言认为是一种连续运算的表达式.
也就是, 前面一个表达式运算完成, 然后再让结果参与下一个表达式的运算,
而这种连续运算, 是存在优先级关系的,
就像数学中, 同时包含加减和乘除的算式中, 永远都是乘除先参与运算一样.

那么, 对于上面的表达式, 就是先进行 ```c 1 < a``` 的运算,
再把结果, 不论是1, 或是0, 交给后面与10的比较.
这样就会导致, 这个表达式的结果, 一定只是1.

因此, 一定要注意, 不要写出 "连续不等式" 哦.

=== Logical Operations

逻辑运算, 也是C语言经常需要进行的运算, 那么什么是逻辑运算呢?

实际上, 逻辑运算就是能够把多个逻辑值串成一串,
确定最后到底结果是真是假的运算.

就比如, 刚刚才提到的, C语言中并没有连续不等式,
那么该怎么样表示连续不等关系呢?
这里就需要用到逻辑运算了.

逻辑运算主要包含了, 或, 与, 非, 三种运算:

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`&&`], [逻辑与], [```c A&&B```], [若A和B都非0, 则返回1],
  [`||`], [逻辑或], [```c A||B```], [若A和B有至少一个非0, 则返回1],
  [`!`], [逻辑非], [```c !A```], [若为0, 则返回1; 若非0, 则返回0],
  table.hline(),
)

从这里, 也可以看出来, 逻辑与或非和逻辑门运算还是非常不同的.
所以后面, 将会单独对按位逻辑运算进行详细介绍...

回到如何表示连续不等关系,
只要这样写即可
```c
1 < a && a < 10
```

值得注意的是, 逻辑运算符, 都是 "短路" 的.
这是什么意思呢?
就是说, 如果逻辑运算符的左边结果, 已经可以决定逻辑运算符整体结果,
那么逻辑运算的右半部分就不会被执行, 而是直接将逻辑运算的结果返回出来.

=== Associativity

正如上面提到的, 运算符结合性决定了连续运算的表达式的执行顺序,
那么, 具体的规则如何呢?

在下表中, 自上而下, 与对应操作相关的表达式被更先进行,
由左而右, 结合性依次减小

#table(
  columns: 3,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Comment]),
  table.hline(stroke: 0.5pt),
  [`() [] -> . ++ --`], [后缀], [从左到右],
  [`+ - ! ~ ++ - - (type)* & sizeof `], [一元], [从右到左],
  [`~`], [按位取反], [从左到右],
  [`* / %`], [乘除], [从左到右],
  [`+ -`], [加减], [从左到右],
  [`<< >>`], [移位], [从左到右],
  [`< > <= >=`], [比较关系], [从左到右],
  [`== !=`], [相等关系], [从左到右],
  [`&`], [按位与], [从左到右],
  [`^`], [按位异或], [从左到右],
  [`|`], [按位或], [从左到右],
  [`&&`], [逻辑与], [从左到右],
  [`||`], [逻辑或], [从左到右],
  [`? :`], [三目运算], [从右到左],
  [`= += -= *= /= %= >>= <<= &= ^= |=`], [赋值], [从右到左],
  [`,`], [逗号], [从左到右],
  table.hline(),
)

很复杂对不对, 但是没有关系, 其实, 当你不确定运算符优先级究竟是如何的,
可以直接将自己希望的运算顺序用括号括出来, 表示它们需要优先进行.
其他的部分, 也是非常符合数学中的直观感受的.

大家也许会发现, 除了我们已经讲过的一些基本数值运算,
这张表中还有一些从未见过的其他运算符,

仔细观察的话, 除了逻辑与和逻辑或, 在这张表中还有按位与或, 异或, 和取反.
很快, 我们将开始了解它们.

PS. 另一个比较重要的则是赋值运算符家族, 将在重新完整介绍完C语言的语法后介绍.

=== Binary Calculation

现在, 就需要一些简单的数学了: 二进制运算.

首先, 什么是二进制运算呢,
实际上, 二进制运算是针对二进制数的运算, 虽然这话听起来好像是废话,
但是它实际上 #strike[也是废话] 却有很多含义.

首先, 它表示了它操作的对象是二进制数, 也就是运算规则为逢二进一的数.

二进制的基数为2, 每一位的数字, 只可能是0或1.

二进制数有一些特别的特性,
其中最显著的优势在于, 它的每一位只有两种状态, 这正好和电路的开关相一致.
这样就方便了计算机的工作.
另外一些特性是, 二进制数可以方便的和十六进制与八进制相互转换,
虽然这些实际上是十六进制和八进制的优势, 因为它们基数均为二的次方.

=== Radix Convert

二进制对于计算机友好, 但是对于人类来说却有些难办了.
因为我们常年都在和十进制打交道.

那么这就需要处理各种 "进制转换" 问题.

二进制和十进制, 同样都表示了同样的数集中的数,
因此它们可以以一定规则互相转换.

二进制转换为十进制, 实际上就是依照每一位, 乘以对应的二的次方.
也许听起来会有些复杂, 但是操作起来非常简单:
如:
我们有二进制数 $1011$, 那么它的十进制就是:
$
(1011)_((2)) =
1 times 2^3 + 0 times 2^2 + 1 times 2^1 + 1 times 2^0 = 
(11)_((10))
$

二进制转换为十进制也是类似的, 就是不断将十进制数除二取余数即可:
$
11 / 2 = 5 ... 1 \
5  / 2 = 2 ... 1 \
2  / 2 = 1 ... 0 \
1  / 2 = 0 ... 1
$
最后将余数从下向上写出即可得到对应二进制数.

上文提到,
二进制和十六进制, 八进制的互相转换非常方便, 那么, 它具体方便到什么程度呢?
对于二进制转十六进制, 只要按四位一组, 高位不足补0, 直接换成十六进制就行.
八进制也类似, 按三位一组, 高位不足补0, 替换成为八进制.

继续以 $1011$ 举例:
$ (1011)_((2)) = (B)_((16)), $
$ (1011)_((2)) = (001'011)_((2)) = (13)_((8)). $

反向操作也极其一致, 非常方便.

=== Bitwise Operations

二进制, 除了常规的十进制运算, 其实也提供了一些特别的运算能力,
在C语言中的表现就是, 按位运算.

在计算机中, 门电路一种可以提供 与门(AND), 或门(OR), 非门(NOT), 与非门(NAND), 或非门(NOR), 异或门(XOR), 同或门(XNOR), 这几种逻辑门.

它们的运算逻辑可以以下表表示:

#table(
  columns: 6,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [A], [B], [Result]),
  table.hline(stroke: 0.5pt),
  [`AND`], [与], [```c A AND B```], [1010], [1100], [1000],
  [`OR`], [或], [```c A OR B```], [1010], [1100], [1110],
  [`XOR`], [异或], [```c A XOR B```], [1010], [1100], [0110],
  [`NAND`], [与非], [```c A NAND B```], [1010], [1100], [0111],
  [`NOR`], [或非], [```c A NOR B```], [1010], [1100], [0001],
  [`XNOR`], [同或], [```c A XNOR B```], [1010], [1100], [1001],
  [`NOT`], [非], [```c NOT A```], [1010], [-], [0101],
  table.hline(),
)

实际上, 它们的规则也非常简单:

- 与门当且仅当两个输入均为1时才输出1, 否则输出0;
- 或门只要有一个输入为1就输出1, 否则输出0;
- 非门将输入取反, 原输入为1, 输出0, 否则输出1;
- 与非门实际上是与门取反, 只在输入不存在, 或有一个1的时候才输出1, 否则0;
- 或非门则是或门取反, 当均为0时才输出1, 否则输出0;
- 异或门的重点在于 "异", 当两个输入相反时, 输出1, 否则输出0;
- 同或则是异或取反, 当输入均相同时, 输出1, 否则输出0.

因此, 实际上, 一切包含非的门电路, 均可以来自于与, 或, 取反,
而其他所有门电路, 则均可以通过NAND门取得.

计算机底层的实现中, 有逻辑门运算, 而C语言中, 也有对应的按位运算.
按位运算是门运算对于多位二进制数的运算, 一共有四种:

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`&`], [按位与], [```c A&B```], [若A和B对应位都非0, 则对应位置1],
  [`|`], [按位或], [```c A|B```], [若A和B对应位有至少一个非0, 则对应位置1],
  [`^`], [按位异或], [```c A^B```], [若A和B对应位有且仅有一个非0, 则对应位置1; 否则, 则对应位置0; 不同为1, 相同为0],
  [`~`], [按位取反], [```c ~A```], [每一位若为0, 则置1; 若非0, 则置0],
  table.hline(),
)

=== Overflow

计算机操作的虽然是二进制数, 但是它的容量却是有限的,
而不能像数学中可以表示理想的无限大整数.

因此, 当数的大小超出了计算机可以表示的范围, 就发生了 "溢出".
在大多数的计算机中, 当发生了溢出, 溢出位会被抛弃,
而只给出一个是否曾发生了溢出的标记.

绝大多数时候, 我们会选择尽可能的避免溢出的发生,
因为它会导致运算结果不符合预期.
因此, 当定义变量的时候, 需要提前估算数据的范围, 为不同的数据选用不同的类型.

但是溢出并不总是坏事, 有时候, 它可以给我们带来一些特殊的优势.
比如著名的 "雷神之锤 III" 平方根倒数速算法,
就为是利用了溢出和微积分线性拟合的典例.

而我们计算机中, 对于负数的表示, 也和溢出有千丝万缕的联系.

=== 2's Completion

计算机可以表示的数据是有限的, 最开始, 一块 CPU 只能计算8位二进制数,
那非常小, 只能表示 $0~255$ 之间的数据.
后来, 直到现在, 计算机也只能表示64位的数据.
当我们只考虑正数的时候, 它并不会出现很大的问题,
在整数范围内, 直接相加即可得到所需的结果.
即便是两数相加发生溢出了, 也可以相对简单的解决.

但是, 当需要考虑负数的时候, 情况就开始不一样起来了.
我们开始必须找到一种方式, 来区分一个数是正数还是负数.

最朴素的想法是, 我们舍弃一位的表示范围, 将这一位用于区分数的正负性.
于是, 我们就有了 "整数的原码表示" (Origin).

在我们需要表示的数值为正时, 原码与真值 (True Value) 相同.
而当需要表示负数的时候, 最高位会被写作1.
也就是说, 将最高位作为符号位, 记录数据是正还是负.

原码表示在数学运算中会导致非常大的问题, 因为, 负数参与运算时, 最高位为1,
与正数进行二进制加法, 可能会得到不正确的结果 --- 一个更大的负数.

```txt
    0000'0000 0000'0111   (+7)
  + 1000'0000 0000'0111   (-7)
 -----------------------
    1000'0000 0000'1110   (-14)
```

所以, 对于一个涉及到负数的运算, 不能直接采用通常的二进制原码表示,
简单的将负数的最高位置为1.

理想的负数表示, 需要保证运算完成后, 可以使得负数与对应正数相加值位0
(最高位产生1位溢出).

于是, 为了达成这样的结果, 我们选择将数值部分原样取反
这样就得到了 "反码" (1's Completion).

但是反码有同样的问题,
虽然可以避免正负数相加得到更大的负数, 但是一个正数, 和对应的负数相加,
得到的却不是原始的0, 而是全1, 这就会造成 $+0$ 和 $-0$ 的问题.

```txt
    0000'0000 0000'0111   (+7)
  + 1111'1111 1111'1000   (-7)
 -----------------------
    1111'1111 1111'1111   (-0xffff)
```

于是, 既然相等负数相加不为0, 那么干脆给它补一个1,
将反码运算中的结果加上一个1, 再经过溢出处理,
最后的结果就是我们想要的真正的0.

为了实用, 将这个1, 加入到反码表示中.
于是, 我们就得到了 "补码" (2's Completion).

当然, 这是实践可以得出的结论, 补码实际上有它更深层次的意义.

=== N's Completion

N的补码, 实际上是模N剩余类加群, 对于
$ Z_n = Z mod n(Z, mod) $, 满足封闭性, 结合性, 则有Z上的模N剩余群.

给定一个n, 有n个模n剩余类, 且有 a, b 满足 $gcd(n, a) = 1, a times r_i + b$,
构成模n完全剩余系.

对于$n in ZZ_n$, 有$b = n - a => a + b = 0$,
若定义 $-a := n - 1$, 存在负数与对应正数模n同余, 则n为互补常量.

有 $a' = -a$的加法逆元, 则, 对 $M$ 求补有 $a' = M - a, M = 10^n$,
对于 `M` 有 $0 = M, 0 = 0$, 在 $M/2$ 上同余.

=== Bitwise Shift

Apart from regular bitwise operations, we have some special ones as well.
Could you image that every digit of a numbers can be shift?

We have mentioned float point numbers before already, right?
You may think that float point can be seen as shift of digits.
But actually, the float point numbers just move the position of decimal point.

In bitwise shift operations, the decimal point will be fixed in `#0.`.
And, move all digits directly right or left.

- Logical Shift Right:
  Shift all digits right based on 0 position. Every number outside 0 will be discarded.
  Padding higher position with 0.
  ```txt
   | 0000'1001 0010'1111 | =>
  0 | 0000'1001 0010'111 | 1 =>
  00 | 0000'1001 0010'11 | 11 =>
  ...
  ```
- Mathematical Shift Right:
  Mostly same as logical shift right operation, but padding higher position based on
  sign bit.
  ```txt
   | 0000'1001 0010'1111 | =>
  0 | 0000'1001 0010'111 | 1 =>
  00 | 0000'1001 0010'11 | 11 =>
  ...
  ```
  For positive numbers, exactly like logical ones.
  ```txt
   | 1111'1001 0010'1111 | =>
  1 | 1111'1001 0010'111 | 1 =>
  11 | 1111'1001 0010'11 | 11 =>
  ...
  ```
  For negative ones, padding number will be 1 instead.
- Shift Left:
  Shift all digits left based on highest position. Every number over highest limit will be discarded.
  Padding 0 position with 0.
  ```txt
     <= | 0000'1001 0010'1111 |
   <= 0 | 000'1001 0010'111 | 0
  <= 00 | 00'1001 0010'11 | 00
  ...
  ```

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [Comment]),
  table.hline(stroke: 0.5pt),
  [`<<`], [SHL], [```c A << B```], [],
  [`>>`], [SHR], [```c A >> B```], [Different machine may choose different SHR method, Logical or mathematical],
  table.hline(),
)

Give a brief knowledge of bitwise shift operations here.
You may find that, shift operations just do multiplication and division indeed.

How?

Actually, `SHL` are some number multiple $2^n$.
`SHR` are some number division $2^n$.

And all discarded numbers are seen as overflow.

== Syntax

C语言, 实际上, 作为一种和计算机进行沟通交流的语言,
实际上也有自己的一套语法规范.

在前面几节中, 我们也看到了, 如果没有按照它的语法规范来书写,
就会遇见 "非法" 报错.

因此, 我们有必要系统了解一下C语言的各种语法规范.

以下是我们的示例程序:

```c
/// file: main.c

// main function, the entry
int main(int argc, char* argv[], char* envp) {
  int integer_value;
  float float_value = 1.0;

  printf("Hello, World!\n" /* comment can appear any where */);
  integer_value = 10;

  printf("Calculate a + b: %d + %f = %f", integer_value, float_value, float_value + integer_value);
  return 0;
}

/* foo function, void parameter and empty body */
void foo(void) {
  // do sth.
}
```

From the program above, we can see that there are several lines that
contains something we haven't met before.

We all explain them all in this chapter.

=== Statements

The first thing I'd like to tell you is definition for statement.

The c program are composed with statements, just as what we have
mentioned before.

Statements define the operation the program will execute.
Each statement may have do something.

According to the C Programming Language Standard, every statement in c
need to end with semi-colon (';').
Unless it is listed detailed that has no necessary to have semi-colon.

For example, we can see,
```c
  int integer_value;
  float float_value = 1.0;
  printf("Hello, World!\n");
  integer_value = 10;
```
they all statements.

Also, multiple statements can be written in same line.
You may see this:
```c
int i; i = 1;
```
From here, we written two statements, `int i;`, and `i = 1;`

So, it is not necessary to add line feed between two different
statements.

They are added for beauty and clear.

Also, because the statement termination will just be determined by
semi-colon, one statement may be written in multiple lines.
```c
int
i
=
10
;
```
They are illegal as well.

But, we'll not write code in this way.
More common usage of this feature will be:
```c
int i = 10,
    j = 20;
```

=== Expression

As we have known statement, another import part of c program is
expression.

From which, a expression is some form that contains different 
operation.

Most basic expression we'd used in program are calculation.
```c
1 + 2
i = 0
printf("Hello, World")
```

They all expressions, and finally get the result of those operation.

Statements may contains expression, but expression cannot construct a 
statement.

Also, most of the time, a expression will generate some value, that
can be used in the following program.

Furthermore, expression is able to be nested.

```c
printf("%d", 1+1)
```

Here, we have two expression, the smaller one `1+1`, and the larger
one, which wraps the small one, `printf("%d", ~)`.

Once we add semi-colon after them, the whole expression will be a
statement.

```c
printf("%d", 1+1);
```

And is ready to do something particular.

You may image, as the function call is a valid expression,
and can be turned into statement.
The calculations, we can also add semi-colon after them, to have a
statement.

```c
1;
8*2;
```

But they are meaningless.

=== Code Block

When we programming, sometimes we may want to
execute some operation at same time
(or intend to execute them at same time).

Then, we need Code Blocks, or "compounded statements".
They are Statements composed and wrapped in one large brackets.
For example:
```c
{
  int x;
  x = 1;
}
```
They are seen as a group,
one large statement later on the rest of program.

And we need no semi-colon at the end of bracket expression.

=== Empty Lines & Space

Not only for beauty, we'll need spaces in code for distinct different
syntax object.

For example, why we always need a space between `int` and `i`?
Because if we dropped it, the compiler will only see `inti`,
which is not a valid name, or anything else.

Just like the reason why we must write space between different words.
(Even in Chinese).

So, at some particular times, if we can say that, the space will not
change the structure of our code, the space is able to be deleted.

Empty lines, the line which contains no code, does relative same as
space.
If it is not necessarily placed there, then it does only for beauty,
and can be removed.

The example here points out, when can we discard the space and empty lines.
```c
int x = 1;
// Equals to
int x=1;
```

=== Comment

Comments are another thing that will not affect anything within our code.
When compiler meets a comment, it will ignore it directly.
Which means, comment will behaviour like a space in our code.

There are two ways for us to write comments.
- `/* ... */`: multiple line comment, but also for inline comment,
  anything inside `/*` and `*/` will be ignored.
- `// ...`: one-line comment, anything follow after will be ignored.

We can see the code above, to have a relative simple understand to comments.

== Variables & Variable space

Here, we comes to the most import part of a program.
We'll know what variable is, how it is defined, and operations done on
them.

First of all, we'd like to see, relation between variable and value.

=== Data, Variable, Value

Data, something that represents something, carrying some information,
always the object we will manipulate in program.

But how can we describe a data?
We may use something called "variable", they are some slot that has
desired space for storing data.

Thus, in general, variable are some space, slot, that can store some
value, carrying some specified data.

=== Definition

Before we use some concrete variable in our program.
We must define them.

The basic forms of variable definition are list below:
```bnf
<variable-type> <variable-name>;
[<decorator>] <variable-type> <variable-name> [= <literal-value>];
```
Also, we have another way to declare a variable:
```bnf
extern <variable-type> <variable-name>;
```

From them all, we can see that, to declare a variable.
We'd have to write in "type name;" form.

Where, type can be any type specifier mentioned above in
#link(<types>)[type] section.

Such that,
```c
int a;
int b;
```

Furthermore, when we have learnt the structure, enumerator, union and
function, we all have more form of types.

=== Variable Name

One must-have element of variable definition is type.
And another one is variable name.

Once we have define a variable, we can then reference it using its
name.

Just like you call one's name.

Variable names in c programming language must follow some rules:
+ start with '\$', '\_' and alphabet,
+ have no space inside,
+ followed by '\$', '\_', alphabet, and numbers.
+ has a total length less than 63 character.
+ not duplicate with any other names defined before or same with
  keywords like 'int'.

Keywords, are some commands will reserve for special usage in c
program, for example, `int`, `if`, `continue`.
And C programming language also have some name reserved for further
usage.
So, for those name, although it is possible to be use, it is not
encouraged to do so.

Here are some mainly used keywords and reserved names:
```c
auto, break, case, char, const, continue, default, do, double, else, enum, extern, float, for, goto, if, inline, int, long, register, restrict, return, short, signed, sizeof, static, struct, switch, typedef, typeof, union, unsigned, void, volatile, while, _Generic
```

Outside those keywords that cannot use, we also have extra naming 
rules.

Names starts with two underscore ('\_') and those start with one
underscore and a capitalized alphabet are reserved for compiler.

Names starts with two underscore and ends with two underscore are
reserved for system-wide standard library.

Names starts with one underscore and a lower-case alphabet, ends with
one underscore are reserved for library.

Names all capitalized alphabet, split by underscore, meaning
constants.

=== Initialize

Once you finished declaration, which doesn't means you finished the
variable definition.

A variable must do initialize, and then can be put into use.
Otherwise, you may get random value when you try to reference it.

First time assignment to a variable are called "initialization".

Only for that, with variable declaration and initialization, we can
say we finished a variable definition.

From list above, we can see that initialization can be done together
with declaration.

```c
int a = 10;
```

=== Assignment Operations

Assignment are some operation special to variable.

Most simple one has notation like `equation` in math.
We call it `assignment operation` directly.

#table(
  columns: 3,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form]),
  table.hline(stroke: 0.5pt),
  [`=`], [Assignment], [```c A = val```],
  table.hline(),
)

After program finish a assignment operation, it value store within
variable will be replaced.

```c
int i = 20;
printf("%d", i);
// => 20
i = 9;
printf("%d", i);
// => 9
```

So, this is the meaning of "variable", a space that can store some value.
And assignment operation just find those space, and then replace the value inside.
Just like the drawer that can store exactly one thing.
You may put one thing inside.
And you may clear the drawer, and put a new one inside.

=== Composed Assignment Operations

Beyond regular assignment operation, we have some advanced ones.
You may compose assignment operation with other mathematics operations.
Thus, we got `compound assignment operation`.

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([Operations], [Description], [Form], [Equivalent Form]),
  table.hline(stroke: 0.5pt),
  [`+=`], [Addition Assignment], [```c A += val```], [```c A = (typeof(A))(A + val)```],
  [`-=`], [Subtraction Assignment], [```c A -= val```], [```c A = (typeof(A))(A - val)```],
  [`*=`], [Multiplication Assignment], [```c A *= val```], [```c A = (typeof(A))(A * val)```],
  [`/=`], [Division Assignment], [```c A /= val```], [```c A = (typeof(A))(A / val)```],
  [`%=`], [Modulus Assignment], [```c A %= val```], [```c A = (typeof(A))(A % val)```],

  [`^=`], [Bitwise XOR Assignment], [```c A ^= val```], [```c A = (typeof(A))(A ^ val)```],
  [`|=`], [Bitwise OR Assignment], [```c A |= val```], [```c A = (typeof(A))(A | val)```],
  [`&=`], [Bitwise AND Assignment], [```c A &= val```], [```c A = (typeof(A))(A & val)```],

  [`<<=`], [SHL Assignment], [```c A <<= val```], [```c A = (typeof(A))(A << val)```],
  [`>>=`], [SHR Assignment], [```c A >>= val```], [```c A = (typeof(A))(A >> val)```],
  table.hline(),
)

Those self-increment operation and self-decrease operations are some kind of same as
addition assignment and subtraction assignment:
```c
int a = 0;
a++;// a=>1
a+=1; // Equivalent, a => 2
--a;// a=>1
a-=1;// a => 0
```

== Type Conversion

As we mentioned before, C is typed language.
Each type's variable occupies different spaces.

So, to have one variable has type `int`, to be used as `long`, we must convert its value into type long.
The way to archive this is called type convert.

In #link(<types>)[Types] section, we have learnt `type boost`, this is a kind of special automatically type conversion.
Auto type conversion always convert type from smaller ranges to larger.
So, that's why we need force type conversion.

To convert a value's type from one to another, add type with brackets before the expression.

```c
(int)10ll; // same as 10
(char)12;  // same as '\14'

char c;
int i = 3000;
c = (int)i;
```

But force type conversion has a serious problem: it may result in resolution lack.
Conversion from `int` to `char`, is a kind of conversion from large range to smaller range.
And it will simply discard higher part of `int` value.
Instead of the case `short` convert to `int`, just put all data into lower part of int and everything is OK.

For example,
```txt
  Short: 0010'0000 1000'0011 =>
  Char:  1000'0011
  Int:   0000'0000 0000'0000-0010'0000 1000'0011
```

This may cause some unexpected results.

Also, conversion from real numbers to integer will also introduce same problem.
All number after decimal point will be dropped directly.

== Input And Output

Programs does not only calculation, but also have to tell the result.
Thus input and output utilities are indispensable.

Most useful input and output function are provided by `printf` and `scanf` function in C.

=== ```c printf```

`printf`, stand for "print with format", a kind of format output method.

So, basically, the function of `printf` is to display some information on screen.
And advanced functions are format output string.

==== Output

Most basic usage of `printf` is written as following:
```c
printf("output string")
```
Anything inside quotations, the string delimiter, except '%', will be displayed as is.

For example, the `printf` here will print "output string" to terminal.
The black-backgrounded window on your computer.

For "terminal", the name came from the hardware long long ago.

One thing you must noticed is that, example shown here is just a expression, but a statement.
So, in order to make it work, you may have to add a semi-colon, ';', after whole expression.

In most case, the system will refresh output with carriage return, line feed, or both.
But `printf` will never add any of which after all content have been printed.
So, to let output looks normal, you need to add a new line mark at the end of string:
```c
printf("string with new line mark at end\n")
```

Outside end of line, new line mark can also added inside a sentence.
```c
printf("string\nwith new line mark inside\n")
```
This may do the same as following:
```c
printf("string\n");
printf("with new line mark inside\n");
```
(why we add semi-colon at the end of sentence? Because you will never able to written two different expression within one statement in such form)

==== Placeholder & format

And how about advanced functions?

The format feature is provided by placeholders.
Have you ever remember I have mentioned '%' before?
Percentage mark works like placeholder here, and that's why it cannot be printed directly using `printf`.
The method to print out '%' into screen is done by writing '%' as "%%" in format string, the first argument provided for `printf`.

Since `printf` has the name "print with format", the placeholder must have not only the function
to prevent percentage mark to be evaluated and printed.
So, let us investigate more about placeholders.

As we all know, C programming language has classified data into different types.
So that placeholders must have different form so that `printf` function can then distinct them.
Those decorator for placeholders are called "type specifier".
And a full placeholder are written according to such syntax:
```txt
<placeholder> ::= '%' [flags] [width] [.precision] [length] <type specifier>
flags         ::= '-' | '+' | space | '#' | '0'
width         ::= <number>
precision     ::= <number>
length        ::= <number>
```
Looks complex? Just quick glance and move forward, examples says more than standard:

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([type specifier], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`a`, `A`], [Output floats in hexadecimal], [```c %a```], [Reals: float, double, double],
  [`d`], [Output integer in decimal], [```c %d```], [Integers: char, short, int],
  [`o`], [Output integer in octal], [```c %o```], [Integers: char, short, int],
  [`x`, `X`], [Output integer in hexadecimal], [```c %x```], [Integers: char, short, int],
  [`u`], [Output unsigned in octal], [```c %u```], [Unsigned Integers: unsigned char, short, int],
  [`f`], [Output reals in decimal], [```c %f```], [Reals: float],
  [`e`, `E`], [Output reals in exponent], [```c %e```], [Reals: float],
  [`g`, `G`], [Output reals in shorter form], [```c %g```], [Reals: float],
  [`c`], [Output Character], [```c %g```], [Character: char],
  [`s`], [Output Character String], [```c %s```], [String: `char[]`],
  [`p`], [Output Address], [```c %p```], [Pointer: `*`],
  table.hline(),
)

And their long version variants:
#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([type specifier], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`ld`], [Output integer in decimal], [```c %ld```], [Integers: long],
  [`lo`], [Output integer in octal], [```c %lo```], [Integers: long],
  [`lx`, `lX`], [Output integer in hexadecimal], [```c %lx```], [Integers: long],
  [`lu`], [Output unsigned in octal], [```c %lu```], [Unsigned Integers: unsigned long],
  [`lld`], [Output integer in decimal], [```c %lld```], [Integers: long long],
  [`llo`], [Output integer in octal], [```c %llo```], [Integers: long long],
  [`llx`, `llX`], [Output integer in hexadecimal], [```c %llx```], [Integers: long long],
  [`llu`], [Output unsigned long long in octal], [```c %llu```], [Unsigned Integers: unsigned long long],
  [`lf`], [Output reals in decimal], [```c %lf```], [Reals: double],
  [`le`, `lE`], [Output reals in exponent], [```c %le```], [Reals: double],
  [`lg`, `lG`], [Output reals in shorter form], [```c %lg```], [Reals: double],
  [`%`], [Output `%`], [```c %%```], [None],
  table.hline(),
)

Here are flags part:
#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([flags], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`-`], [Align left, default right], [```c %-d```], [None],
  [`+`], [Force output '+', default not show for positive], [```c %+d```], [None],
  [` `], [Insert a space before output], [```c % d```], [None],
  [`#`], [Show '0', '0x' or '0X' with 'o', 'x', 'X' descriptor \ force show decimal point with 'e', 'E', 'f' \ or, not remove tailed zero with 'g', 'G'], [```c %#d```], [None],
  [`0`], [Padding 0 instead of space], [```c %0d```], [None],
  table.hline(),
)
Width, .precision and length:
#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([flags], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`(number)`], [minimal number of character to print, padding with space, if output longer than this value, output will not be truncated], [```c %8d```], [None],
  [`*`], [width not specified in format string, but obtained as parameter before argument to be formatted], [```c %*d```], [Integer: char, short, int],
  table.hline(stroke: 0.5pt),
  [`.number`], [for integers (d, i, o, u, x, X): minimal digits to be written, less than this value will padding by 0. Longer than this value will affect nothing. 0 means nothing to print \ for e, E, f: digits after decimal point \ for g, G: maximal digits to be printed \ s: maximal length of a sting, default, all character will be printed, until '\0' \ c: nothing affected \ nothing placed will introduce a 1], [```c %.10d %.f```], [None],
  [`.*`], [precision not specified, but obtained as parameter before argument to be formatted], [```c %.10d %.f```], [Integer: char, short, int],
  table.hline(stroke: 0.5pt),
  [`h`], [parameter as short, for i, d, o, u, x, X], [```c %hd```], [None],
  [`l`], [parameter as long, for i, d, o, u, x, X \ double, for f \ wide char, for c \ wchar string, for s], [```c %ld```], [None],
  [`ll`], [parameter as long long, for i, d, o, u, x, X \ long double, for e, E, f, g, G], [```c %lld```], [None],
  [`L`], [parameter as long long, for e, E, f, g, G \ parameter as long long, for i, d, o, u, x, X], [```c %Lf```], [None],
  table.hline(),
)

And `prinf` will return total character it printed.

You may able to print ASCII code using `printf` now:
```c
#include <stdio.h>

int main(void) {
  for (int i = 0; i < 128; i ++) {
    printf("ASCII: %5d, Char: %c;\n", i, i);
  }
}
```
Definition of `printf` function is written as:
```c
int printf(const char * fmt, ...);
```
So, you can call it using the form:
```c
printf("format string")
printf("format string", arguments)
printf("format string", arguments, arg2)
printf("format string", arguments, arg2, arg3)
...
```

=== ```c scanf```

Once we learnt output part, it is also necessary to have a glance to input part.

The usage of `scanf` is roughly like to `printf`, except function calling methods.
`Scanf` stands for "Scan from format", so, it necessarily needs placeholder as `printf`.

Placeholders are written in this form:
```txt
<placeholder> ::= '%' ['*'] [width][modifiers] <type specifier>
```
Some kind of like to `printf`, right?

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([part], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`*`], [\* stand for discard input, or, simply skip data match the type], [```c %*d```], [None],
  [width], [maximum character to be read], [```c %8d```], [None],
  [modifiers], [decorator for type specifier like `printf`], [```c %ld```], [None],
  [type], [data to be scan as], [```c %d```], [None],
  table.hline(),
)

#table(
  columns: 4,
  stroke: none,
  align: center,
  table.hline(),
  table.header([part], [Description], [Form], [Expected Data]),
  table.hline(stroke: 0.5pt),
  [`a`, `A`], [floats], [```c scanf("%a", &f)```], [floats],
  [`c`], [characters, if width is not 0, read width character and set to parameter], [```c scanf("%c", &c), scanf("%3c", &c1, &c2, &c3)```], [char],
  [`d`], [integer written in decimal, '+' or '-' are optional], [```c scanf("%d", &i)```], [int],
  [`ld`], [integer written in decimal, '+' or '-' are optional], [```c scanf("%ld", &l)```], [long],
  [`lld`], [integer written in decimal, '+' or '-' are optional], [```c scanf("%lld", &ll)```], [long long],
  [`e`, `E`, `f`, `F`, `g`, `G`], [real numbers, '+' or '-' are optional, 'e' for exponent are optional], [```c scanf("%f", &f)```], [float],
  [`i`], [integer], [```c scanf("%i", &i)```], [int],
  [`o`], [integer written octal], [```c scanf("%o", &i)```], [int],
  [`s`], [string, separated by blanks], [```c scanf("%s", s)```], [`char[]`],
  [`u`], [unsigned int], [```c scanf("%u", &u)```], [unsigned int],
  [`x`, `X`], [int written in hexadecimal], [```c scanf("%x", &i)```], [int],
  [`p`], [pointer], [```c scanf("%p", &p)```], [`*`],
  [`[]`], [ranges, simplified regular expression], [```c scanf("%[1-9]", &c)```], [char],
  [`%`], [`%`], [```c scanf("%%")```], [None],
  table.hline(),
)

Sample question: A+B Problem:
```c
#include <stdio.h>

int main(void) {
  int a, b;
  scanf("%d%d",&a, &b);
  printf("%d + %d = %d", a, b, a + b);
  return 0;
}
```

== Conditional Statement

Since the program is not only tool to calculating,
it also helps people to solve problems require decision.

So, scientists introduces conditional statement.
They can decide what to do according to conditions.

=== If

If statement has form of:
```c
if (condition) statement
```

When condition expression part evaluated with true, then statement part will be executed.

```c
if (x < y)
  printf("x less than y");
```
You can see, ```c x < y``` is condition expression,
and if x indeed less than y, the program will output the information.

But this is only the simplest case, what if we want to execute multiple statement within if statement?

Remember code block?
Code block can compose different statements together.
So:
```c
if (max < x) {
  swap(x, max);
  printf("x larger than current max, swap them");
}
```
Here, we execute two statements when x larger than current max value.

=== If-Else

Instead of just "if" statement, sometimes we may need "else" part.
// NOTE: example required
```c
if (condition)
  then-statement
else
  else-statement
```

Just similar to if statements, when condition is not 0, or, acceptable, execute
then-statement, else, execute else-statement.

Also, you may find some case, you may classify different case, so you can written then
like this:
```c
if (cond1)
  then1-statement
else if (cond2)
  then2-statement
else if (cond3)
...
else
  else-statement
```
This is simply nested if-else statements for each "else if" are new if statement place in else part of
further one.
This is for beauty, but you can also write like this:
```c
if (cond1) {
  then1
} else {
  if (cond2) {
    then2
  }
  ...
}
```
Very clear.

=== Ternary if-else operator

三元运算符

Though in most case, if-else statements is enough, it is still the statement but a expression.
Thus in some corner condition, written using if-else may result in more lines of code and complexity.

Thus we introduces ternary if-else operator. With this operator, you got a expression, so you can than
combine them together with other expressions.

Ternary if-else looks like this
```c
condition ? then : else
```
when condition is true, then part will be executed, and if condition is false, else part will be evaluated.
And finally, the value of expression will be return.

So, you may write:
```c
int i = 10;
i = i - 100 < 0 ? 0 : i - 100;
```
or, in c++, you may found you can write like this:
(we must mention c++ here for clear because this style of
ternary is indeed not allowed to be written in pure c,
but most of programmers may not distinct c/c++)
```cpp
int i = 0;
int j = 10;
(i < j ? i : j) = 1;
```
(the second case is correct because every operation in c++ are special methods(functions), so = is actually a function call,
equivalent style is ```cpp int::operator=(i< j ? i : j, 1);```)


They all correct, but second one is not encouraged to use.

=== Switch-Case

Addition to if-else statement, we also have switch-case statements.

```c
switch (object) {
  case label:
    statements
  case label:
  ...
}
```
Label can be one of "case literal-value" or "default", and it is not necessary to add brackets if you have multiple statements in one case.
Each label means an entry, when object matches label, it will execute start from the position of label, until meets `break statements`

Then, a legal switch-case statements may look like:
```c
int i; // for random value
switch (i) {
  case 1:
  case 2:
    printf("less than 3\n");
    break;
  case 4:
    printf("larger than 3\n");
  case 5:
    printf("larger than 4\n");
  default:
    printf("do nothing\n");
    break;
}
```

==== Break statement

But what does break statement do?

Break statements has two variants.
One is here, break statements used to jump out of the switch case statements' execution sequence.

When c finds object matches the label, and it will execute each statements after the label until meets end bracket,
but in some case, actually, most case, you may not want it to do so.
So, break can break whole process, when it executed break statements, it will simply jump out of switch-case statements,
and rest statements inside will not be executed.

Though break statements in switch-case is not mandatory, but it is a good habit to add break for each label.

== Loop

What if you want to execute multiple, same, or equivalent same statements?
Here we needs loop.

Loop are some statements can execute other statements repeatedly according to some condition.

=== While

While loop looks similar to if statement,
```c
while (condition)
  loop-body
```
and works similar to if statement as well.
When condition is true, then loop-body will be executed.

Furthermore, most similar part between while loop and if statement is that body of loop has still single statement.
If you want multiple statements to be evaluated, you must add brackets.

```c
while (1) {
  printf("infinity loop\n");
}
```

=== For

For loop is another type of loop, it may not that clear to have the name "for",
```c
for (initial; condition; update)
  loop-body
```
for loop always have four part.

Initial part give the ability to define loop variable and initialize them inside the loop.
Condition part is same as while loop, if it is true, then body executed, else, just break the process.
Loop-body, still, same as if and while loop, execute if everything OK.
And finally, update, when loop-body finished, the for loop will do update, to update loop variable.

```c
for (int i = 0; i < 10; i ++) {
  printf("%d", i);
}
```

Another important part is that,
for totally four part of for loop, `initial`, `condition`, and `update` parts can be empty.
Thus, you may find in some special case,
```c
for (;;)
  body
```
can be seen as infinity loop.


=== Do-While

But what if we need to execute body at least once?

Then we need do-while loop.
```c
do {
  body
} while (condition);
```

Apart form other statements, do-while loop requires brackets compulsory.

=== Break

Still break, the other form of break is here,
when break statement used within the body of loops, it will jump out of whole loop.
Discard anything after break.
Even update part of for loop.

Similar to switch-case.

=== Continue

Sometimes, you may need to just skip rest of part in body, but not jump out of loop,
then you needs continue statement.

When continue executed, it will just go to another round of loop, do update, test condition, and new execution
process of body.

== Array

When we are dealing with small scale of data, define multiple variables is enough,
but how about sequence of data?

For example, read scores of over 500 students and sort them.

In contrast, average and maximum can be done with only one or two variables, but this requires store all information.

Arrays are linear and continuous data structure for storing same type values.

Definition for one-dimension array written as following:
```c
type name[length];
```

And further, array can be multiple-dimension.
```c
type name[length][length];
type name[length][length][length];
...
```

Once we define an array, then it has length elements stored, you may visit them using index:
```c
name[idx];
```
each element can be seen as a regular variable whose type is same as type used to define whole array.

And we can then traversal array using loop:
```c
int arr[10];
for (int i = 0; i < 10; i ++) {
  arr[i] = i;
}
```

Then, how can we initialize an array?

There are two main ways:
```c
type name[] = {value1, value2, ...};
type name[length] = {value1, value2, ...};

type name[][length] = {value1, value2, ..., value6, ...};
type name[length][length] = {value1 ...};
type name[length][length] = {{value1, ...}, {value_length, ...}};
...
```
One is not write length, but just wrap initial values using brackets,
the final array will have the length of total count of initial values.
The other way is to specify length, and also provide initial value wrapped using brackets.

For multiple-dimension arrays, you must specify other dimension length except first one,
and you can write initial values directly in one pair of brackets, but also, spare each dimension array elements using
different brackets pair.

=== C Style String

Finally, we come to string part.

As we mentioned before, string and character has some special relationship.
Actually, strings in c programming language are array of char.

In C programming language, it will treat char array end with '\0' as a string.

== `sizeof`

Though it is possible to traversal arrays using literals.
It is not that convenient.

To simplify operation, we can use `sizeof` operator:
```c
sizeof(type)
sizeof(variable)
sizeof(array)
```
`sizeof` operator will return the total length of target type/variable/array in bytes.
So, to have the length of array, we can say that:
```c
int len = sizeof(array) / sizeof(type);
```

== Iterator

To traversal arrays, using `idx` traversal variable is one possible method.
The other way to archive the goal is using iterator.
```c
int a[10];
for (int*p = a; p < a + 10; p ++) {
  *p = 1;
}
```
here, we defined p as iterator for array a.
And then, it is able to iterate whole array.

The p here is called, pointer points to int.

More detail will be covered in #link(<Pointers>)[Pointers] section.

== Function

Function, a kind of contract, accepts some input and generate outputs.
Most similar to their mathematical form, any same input provide for a function will result in same output.
Furthermore, the format of function is almost same as that in math:
```c
int func(int R);
```
You may assume it as: $"function" f: N->N$ or $f(x) -> N, x in N$
And
```c
float func(float a, float b);
```
may represents $"function" f: R, R -> R$ for $f(arrow(v)) -> R, arrow(v) = angle.l a, b angle.r, a, b in R$.

Formally, input in C programming language can be zero or more parameters.
And output are something so called "return value".
There may exists more way to pass output value other than regular returning method.

Ideally, a function may not affect anything outside itself, this kind of function are seen as pure functional function.
But, in normal program, they may need to perform operations other than calculation.
For example, I/O. Any operation modify memory, variables outside its own scope, or perform I/O, are defined as side effects of a function.

More particularly, some function in C programming language may have even no returning but side-effects.

=== Definition

To brief understand function in c, first look at the function definition.

Function definition does almost same as variable declaration, but the main purpose
it to tell the compiler about a function's name, return type and its parameters,
rather than allocate a new space indeed.

We call it prototype.
```c
<return-type> <function-name>(<parameters> ...);
```
Usually, prototype are placed within headers.

For example, you may have prototype for function`add` that generate sum of two integer like:
```c
int add (int a, int b);
```
Here we declare the function add, which accepts two arguments, corresponding to parameters a, and b respectively.

And then, as variables must initialized before referenced.
Functions must have finish implementation before being called.

Function implementation roughly like declaration,
but with extra function body part:
```c
<return-type> <function-name> (<parameters> ...) {
  <function-body>...
}
```
Body part may be regular statements, but also possible for `return` statement.

Purpose of `return` statement is tell the program, which value are seen as return value of the function.

Like equation mark in $f(x,y) = x + y$.

Here we implement function `add`:
```c
int add (int a, int b) {
  return a + b;
}
```

=== Function Calling

Once a function has been defined, it can be used in our program with function call syntax.

As we mentioned very early at the beginning of our tutorial, a function call is written in such form:
```c
<function-name> (<arguments> ...)
```
And arguments must match parameter in order and type.

For example, if we have a function add defined before,
```c
int add(int a, int b){
  return a + b;
}
```
Then we can use it like:
```
#include <stdio.h>

int main(void) {
  int a = 10;
  a = add(a, 20);
  printf("%d", a);
  return 0;
}
```
first argument we provide for `add` is integer variable a, which has the same type as parameter `a`,
and second argument is literal value `20`, since any integer literal without suffix will be seen as integer in c,
it has also same type with parameter `b`.
Thus, the function call is acceptable.

But what if we provide arguments less, more, or even has type mismatch?
The C programming language will complain about syntax error.

=== Recursion

Since a function can be called within body of other functions,
it make nonsense to prevent a function calling it self.

A function that calling it self are called recursion function.

=== Function Tail Call Optimization

== Assembly

=== Architecture

==== AMD64 (x86_64)

==== Aarch64 / arm64

==== MIPS / Loong

=== BUS

==== Bridges

=== CPU

=== Intel Syntax, AT&T Syntax

=== Memory Access

=== Commands

=== Direct Memory Access

== Stack

=== Frames

=== Stack Variables, Local Variables

=== Recursion Function Expansion

== Global Variables

== Variable Scope

=== Dynamic Scope

=== Lexical Scope

==== Function Scope

==== Block Scope

== Closure

== Heap Space

=== Variable Allocation

== Memory Management

=== Virtual Memory (OS)

== Function Call

=== Function Stack

=== Function In Assembly

== `goto`

== User Defined Types

=== `Struct`

==== Bit Field

==== Simulate `class` Using Structure

==== Virtual Function Table

=== `Enum`

=== `Union`

== Structure space, Memory Alignment & Offset

== Pointers
<Pointers>

=== Pointer offset, index & linked list

=== Array, Pointers Points To Continuous Memory

=== Function pointers

==== Form

==== Function As Function Pointer

==== Calling With Function Pointer

==== Simplified Function Call

=== Void Pointers

=== Pointer Convert

== Pointer in Assembly

== Exception

=== `setjump`, `longjump`

=== Try-Catch, Throw

=== Seh, Structure exception handler

=== Herbexception

=== Exception spread

=== Condition System

=== Continuous

== Preprocessor

=== Header files, ```c #include```

=== Macro

==== C Style Macro

==== M4 Macro Language

==== C++ Template

==== Rust Procedure Macro

==== Rust Macro Rules

==== Macro Assembly, Pseudocode

==== Common Lisp Expansion Macro

==== Common Lisp Reader Macro

==== Scheme Hygiene Macro System

==== Scheme Syntax Rules

==== Scheme Syntax Case

==== Hygiene for the Unhygienic

=== Compiler Comments

=== ```c #progma```

== Meta-programming

== Compiler

=== Compile Process

=== Compiler Driver

=== Assembler

=== Assemble

=== Assembly Code

=== Linker

=== Link

== Executable File

=== Object

=== Executable

=== Executable File Format

==== Portable Executable (PE)

==== Executable Linkable Format (ELF)

==== Mach-5 (Fat-5)

==== Common Object File Format (COFF)

==== Binary (Bin)

== ABI

=== Function Call Conventions

==== `__cdecl`

==== `__stdcall`

==== `__fastcall`

==== `thiscall`

==== `System V ABI syscall`

=== Function Naming Convention

==== C Function Naming Convention

==== MSVC C++ Function Naming Convention

==== Rust Function Naming Convention

==== Common Lisp Naming Convention

=== Endian

=== Dynamic Linked Library

=== Static Linked Library

=== fPIE, fPIC

== Multiple File Compile

=== Compile Unit

=== Object

== Build Systems

=== C Project Management

=== Makefiles

=== AutoTools

=== CMake

=== VSXMake (VSProj)

=== XMake

== Variable Decorator

== ```c asm volatile (assembly code : output operands : input operands : clobbers)```

== ```c __attribute__((attribute))```

== ```c _Generic```

== ```c ..., va_start, va_arg, va_end``` Macro, stdarg.h

== ```c __VA_ARGS__```

== Variable Length Array

== ASCII, EBCDIC, Unicode/UCS-II
