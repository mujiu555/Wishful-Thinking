# Wishful Thinking

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![conventional commit compliant](https://img.shields.io/badge/git%20commit-conventional%20commit-brightgreen.svg?style=flat-square)](https://www.conventionalcommits.org/en/v1.0.0/#specification)
[![git flow compliant](https://img.shields.io/badge/branch-git%20flow-brightgreen.svg?style=flat-square)](./doc/README.gitflow.md)

Notes and other thoughts.

## Background

This is a project mix all diary, lecture notes, self-learning notes,
my attempts to learn theoretical & applied computer science together.

Most Important part is design for my Lilies Programming Language,
a compiler, an interpreter, REPL for it, an editor using it as default
extension language (though plugin system will developed using native binary,
so that it will support almost all language with given `.h` c header.
Compile a shared library and load it using editor API.
But the support to extend editor with lilies are built-in.), an IDE
layer for corresponding editor, and (maybe) a loadable image for bare
mental language runtime.

This repository contains all my crazy thinkings and related attempts.
This repository will only contains text-based resources though.

For each sub-project, you may find its README and LICENSE on its own
directory.

### Referencing

[CS Plan](https://cs-plan.com)
[CsDiy](https://csdiy.wiki)

## Install

This is (probably) a plain-text project.

I don't think it is worth to installing.

## Structure

The whole project is organized in following structure:

```txt
Root: /                         ; Project root
+- .git/                        ; git repository
+- .github/
|  +- workflows/                ; CI/CD configuration
+- .typsite/                    ; SSG configuration
+- bin/                         ; build results
|  +- deploy.sh
|  +- gen-todos.sh
+- doc/                         ; documentation & copyright information
|  +- licenses/                 ; when adopting other library, place license here
|  +- root/                     ; detailed README for each subproject
|  +- LICENSE                   ; copy of LICENSE adopted by the project
|  +- LICENSE.apache            ; copy of original LICENSE
|  +- README                    ; README for directory `doc`
|  +- README.commit.md          ; git commit convention
|  +- README.gitflow.md         ; git flow convention
|  +- README.release.md         ; semantic versioning 
+- inc/                         ; public header
+- lib/                         ; public library, installed from bin
+- notes/                       ; notes not about to be published
+- publish/                     ; generated site
+- root/                        ; Site root
|  +- lib/                      ;
|  +- notes/                    ; notes to be published
+- src/                         ; source code for each subproject
+- test/                        ; public test files
+- tmp/                         ; temporay files
+- todos/                       ; todo list, from git commit
+- .gitignore
+- .gitmodules
+- LICENSE
+- README.md
```

For each subproject, it will be organize into two parts,

- one is its documentation, it will be placed in the `doc/root/<name>` directory,
- other is its source code, it will be placed in the `src/<name>` directory.

What's more, organize for those sub directory will be:

```txt
Root: doc/root/<name>
+- <ft>/                         ; link, probobly
|  +- Sample.<ft>
|  +- ...
+- LICENSE
+- README.md

Root: src/<name>
+- src/
+- <build-script>
```

## Usage

Most of the notes will be written in markdown, typst, or LaTeX.
But some of which may be done with org-mode.
So, it will be nice to have a configured Emacs.

## Plans

- Applied Computer Science
  - Computer Graphic
    - [ ] CMU-15-462\_662
    - [ ] FreeGLUT
  - Operating System
  - Compiler Principle
- Theoretical Computer Science
  - [ ] ITTCS
  - [ ] SICP
  - [ ] HTDP
  - [ ] MIT-18.404j
  - Theory of Computation
    - [ ] MIT-6.004
  - Pgrogramming Paradigm
    - [ ] Stanford-CS107
  - Type Theory
    - Type System
  - Programming Language Theory
  - Program Theory
  - Lambda Calculus
- Software Engineering
  - [ ] Missing-Semester
  - [ ] tools\_maps
  - [ ] buildYOLisp
  - [ ] Craft Interpreter
  - [ ] c
  - [ ] hecto
  - [ ] d\_flat
  - [ ] leetcode
- Mathematics
  - DiscreteMathematics
    - [ ] MIT-6.042j
  - Category Theory
- [ ] HowToSpeak

## Related Efforts

Not yet. (Laugh

After all, this is just a diary.

## Maintainers

[github@mujiu555(暮玖)](https://github.com/mujiu555)

## Contributing

You may pull all repository and walk through any part you interested in.
Make Pr if you have found any problem or have method to improve those notes.

## License

Apache License ver. 2.
