
== Introduction & Core Concepts

=== Introduction

==== Background

==== Design Targets

==== Design Guidelines

==== Comparison with Other Languages

===== ML, Lisp, and Haskell

===== Rust

==== History of the Language

==== Overview of the Language

=== Notational Conventions

==== Surface Syntax, Character Set, Encoding, and Lexical Structure

==== S-Expression Syntax

==== M-Expression Syntax

==== Decision: S-Expression

==== Reader & Formatter

===== Quote Syntax

===== Quasiquote Syntax

===== Extension for Reader

===== Literal Symbol

```txt
#:<symbol-name>
```

===== Pretty printing

====== Functions

```txt
#<function <function-name>: <function-address>>
```

==== Comment Syntax

===== One Line Comment

```txt
; This is a one-line comment. Always placed at the end of a line, after the code.
;; This is a one-line comment. Always placed aligned with the code, at the beginning of a line.

;;; This is a documentation comment. Always placed at the beginning of code.
```

===== Multi-Line Comment

```txt
#|
  This is a multi-line comment.
  It can span multiple lines.
|#
```

===== Nested Comment

```txt
#|
  #|
    This is a nested multi-line comment.
    It can also span multiple lines.
  |#
  Outside of the nested comment.
|#
```

===== Documentation Comment

```txt
#;|<doctype>
 ;
#;|end
```

Within the documentation comment, you can use `;` to write documentation content.
The content can span multiple lines and can include various formatting elements
such as headings, lists, code blocks, etc.
The `<doctype>` can be any identifier that indicates the type of documentation being provided
(e.g., `TODO`, `NOTE`, `EXAMPLE`, etc.).

You can write documentation comments for various purposes,
such as providing explanations, examples, or notes about the code.
The documentation comments can be placed before or after the code they are documenting.

There are some notation for documentation comments:
```txt
@param <param-name> <description>
@return <description>
@brief <brief-description>
@status <status>

@sample <sample-name> <lang>
  ; first line of sample code
  ; ...

@ref <documentation-reference>

@link(<url>)[<description>]
```
Those part will be organized into a structured documentation format,
which can be used to generate documentation for the codebase.

The other textual content within the documentation comment can be formatted
using Markdown-like syntax.
This allows for rich documentation that can be easily read and understood by developers.

The documentation comment can be visited in repl using the `doc` command,
which will display the documentation content in a structured format.
This can be useful for quickly accessing relevant information about the code without having to navigate through the source files.

e.g.,
```txt
#;|TODO!
 ; This is a documentation comment for TODO items.
 ; It can span multiple lines.
#;|end
```

We also have one line documentation comment,
but only for explaining the code, not for generating documentation.

```txt
#;TODO! This is a one-line documentation comment for TODO items.
```

==== Annotation Syntax

===== Language Annotation

```txt
#!lang <language>
```

```txt
#!extension <extension>
```

```txt
#!option <option>
```

===== Code Annotation

Internal code annotation, used for marking code with specific attributes or metadata.
```txt
#@[annotation]
```

Outer code annotation, used for provide metadata for current compilation unit.
```txt
#+[annotation]
```

