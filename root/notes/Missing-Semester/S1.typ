#import "/lib/lib.typ":

#show: schema.with("page")

#title[The Missing Semester of Computer Education]
#date[2025-12-18 21:24]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")


= Section I

除了算法, 工具可以有效提升工作效率,
这是一个尝试, 教授如何掌握工具, 以及提供(可能)不清楚但是有用的工具.

这会跟进很多领域(11)

仅会介绍少量极其有用的工具

= Shell

Shell是与计算机交互的一个重要途径

可以组合文本操作,

1. 可以直接在shell中输入指令
2. 可以通过参数临时修改程序执行的行为(由程序自身决定)
3. 参数通过空格隔开

Shell可以通过PATH路径找到可以使用的指令
PATH是用来在计算机中找到可执行文件的方式

1. 绝对路径: 一个文件的全部路径
2. 相对路径: 文件相对于当前工作目录的路径 (pwd)
3. `.`: 当前目录
4. `..`: 上一级目录
5. `~`: 家目录
6. `-`: 上一次`cd`的目录

命令的参数:

1. 一般通过`--help`查询
2. `-` flag, 一般为短开关, 可以自由组合
3. 方括号一般表示内部是可选的

权限:

1. 第一位表示目录/普通文件/套接字
2. ugo: 所有者, 所有者组, 其他:
3. 一共由9位二进制表示: 每三位表示对应对应用户(组)的权限, 读/写/执行
4. 目录的写权限仅影响是否可以删除修改其内部的文件

== Most used Commands

1. `mv`:
1. `cp`:
1. `mv`:
1. `mkdir`:
1. `rmdir`:
1. `man`:

PS. `info`:

Short cut:
`Ctrl-L`: clear

== Shell Stream

iostream redirection

1. `< file`: input redirection (from file)
2. `> file`: output redirection (into file)
3. PS. `<< label`: input redirection (until read lable)
4. `>> file`: output append into file
5. `prog1 | prog2`: pipe, output redirection to another program

== Root user

Super administrator

`sudo`: super user do (do as super user)

== `/sys`

vfs: kernel variables

1. `tee`: ```sh echo < file | sudo tee /target```

== Shell Scripting

语法,

= VIM

我用的是NeoVim (LazyVim distro)

仓库地址: [My LazyVim](https://github.com/mujiu555/my-lazyvim)


= Section IV

- grep
- less
- sed
  - regular expression
- sort
- head
- tail
- uniq
- wc
- paste
- awk
- bc

- xargs
- parallel


= Command Line

Short cut for shell

- Ctrl-C: SIGINT
- Signal: kill

== Tmux

== Dot files

Configurations

- alias
- .bashrc
- PS1


= Debugging

== Logger

Log, like printf, but with more information.

It is possible to print with colour.

Using ASCII escape codes to draw color.

It is possible to use third party log system.
Most of which may be placed in `/var/log`.
`Journalctl` will place log in `/var/log/journal`

== Debugger

Step debuggers: `GDB`, and so on.

It is possible to walk through the execution

== Static checker

Try to detect errors without actually execute a program.

== Inspect

== Profiling

Count time is useful.

And real time: the time program cost to execute to finish.
User time: the cpu time a program used.
System time: the system cost during the program executes.

=== CPU profiling

Tracing: record all information during program executes.
Sampling: regularly inspect program.

Thus tracing will result to performance decrease.

Liner profiler: cost for each line's execute.

=== Memory profiling

==== Analysis

`Perf`:

- list:
- stat:
- record:
- report:

=== Visualize

- Flame Graph
- Call Graph

=== Resource profiling


= Meta programming

DSL everywhere.

== Build systems

- Describe how to build
- Encode Rules

Make: GNU Make, BSD Make, NMake

== Make Rules

== Repositories

== Version

Semantic Version

== CI/CD

Continuously Integration & Continuously Distribution

- Recipe:
- Behaviour when something happened

== Auto Testing

- Test Suit: a large collection of tests
- Unit Test:
- Integration Test:
- Regression Test:
- Mocking:


= Security

Password need to be hight information entropy

== Hash functions

- non-invertible
- collision resistant

Hash in git, need no conflict, compared to old hash method.

== Key derivation functions

== Symmetric key cryptography

- keygen() -> key
- encrypt(plain text, key) -> cipher text
- decrypt(cipher text, key) -> plain text

== Asymmetric key cryptography

- keygen() -> (public key, private key)
- encrypt(P, public key) -> C
- decrypt(C, private key) -> P

- sign(msg, private key) -> signature
- verify(msg, sig, public key) -> ok?


= Misc

== Change keyboard mapping

Remap fn keys, caplock, shortcuts.

== daemons

run commands in background

== fuse

== background

== API

== WM

== MD

== Boot

== Docker

== Interactive Notepad Programming

== GitHub
