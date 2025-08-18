# editor ui

## components

application (tool-bar + bottom) -> layer -> window -> tab (header + mod-line) -> buffer

Application:
First line are tool-bar
Last line are bottom
Inner are layer(0), open only one window (editor window)
editor window opened two tab, with no header but with mod-line
buffer with line-number shown
each buffer has its own editing-mode.
editing-mode can affect key-maps, behaviour and completions.
some editing-mode can share globally.

```plain
[ED]|file|edit|view|options|help| ------------------------------------------------------------------------------------ [=][X]
|| main.c  * | [untitiled]  x |                                                                                      [0][<|>]
|  0| #include <stdio.h>                                                                                                    |
|  1| I                                                                                                                     |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
|   |                                                                                                                       |
| Insert | Root:>s>main.c                                                                                       < c < 2:0 [ ]
|Layer| [Echo area]                                                                                                  [Notice]
```

Default layout with Folder Browser and Symbol Viewer open.
Totally three windows here.

```plain
[ED]|file|edit|view|mode|options|help| ------------------------------------------------------------------------------- [=][X]
|[ Folders      v ]| main.c  * | [untitiled]  x |                                                                    [0][<|>]
| v src/           |  0| #include <stdio.h>                                                                                 |
|  + main.c        |  1| I                                                                                                  |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| Folder |      [ ]|   |                                                                                                    |
|[ Symbols        ]|   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| LSP |         [ ]| Insert | Root:>s>main.c                                                                    < c < 2:0 [ ]
|Layer| [Echo area]                                                                                                  [Notice]
```

Command Menu can be shown in three ways:

1. pop up from buttom-bar
2. pop up with float-menu near cursor
3. pop up from head-bar with float-menu

Method I:

```plain
|[ED]|file|edit|view|mode|options|help| ------------------------------------------------------------------------------ [=][X]
|[ Folders      v ]| main.c  * | [untitiled]  x |                                                                    [0][<|>]
|                  |  0| #include <stdio.h>                                                                                 |
|                  |  1| I                                                                                                  |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| Folder |      [ ]|   |                                                                                                    |
|[ Symbols        ]|   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|       [ Command: edit sI                                                                                    ]             |
|       [ [Available]                                                                                         ]             |
|       [                                                                                                     ]             |
|       [                                                                                                     ]             |
|       [                                                                                                     ]             |
|       [                                                                                                     ]             |
|       [                                                                                                     ]             |
|       [                                                                                                     ]             |
| LSP | [                                                                                                     ] < c < 2:0 [ ]
|Layer| [Echo area]                                                                                           ]      [Notice]
```

Method II:

```plain
|[ED]|file|edit|view|mode|options|help| ------------------------------------------------------------------------------ [=][X]
|[ Folders      v ]| main.c  * | [untitiled]  x |                                                                    [0][<|>]
|                  |  0| #include <stdio.h>                                                                                 |
|                  |  1| I                                                                                                  |
|                  |   |   [ : e sI                           ]                                                             |
|                  |   |   [ [C]                              ]                                                             |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| Folder |      [ ]|   |                                                                                                    |
|[ Symbols        ]|   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| LSP |         [ ]| Insert | Root:>s>main.c                                                                    < c < 2:0 [ ]
|Layer| [Echo area]                                                                                                  [Notice]
```

Mthod III:
If head-bar is not shown, the line 1 will be seen as head-bar area

```plain
|[ED]|file|edit|view|mode|options|help| ------------------------------------------------------------------------------ [=][X]
|[ Folders      v ]| main.c  * | [untitiled]  x |                                                                    [0][<|>]
|                  |  0| #incl[ Command: edit I                                                            ]                |
|                  |  1|      [ [C]                                                                        ]                |
|                  |   |      [                                                                            ]                |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| Folder |      [ ]|   |                                                                                                    |
|[ Symbols        ]|   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
|                  |   |                                                                                                    |
| LSP |         [ ]| Insert | Root:>s>main.c                                                                    < c < 2:0 [ ]
|Layer| [Echo area]                                                                                                  [Notice]
```
