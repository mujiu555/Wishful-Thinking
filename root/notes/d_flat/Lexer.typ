#import "/lib/lib.typ": *

#show: schema.with("page")

#title[Lexer: A Lexer Combinator for D Flat System]
#date[2026-02-17 03:54]
#author(link("https://github.com/mujiu555")[GitHub\@mujiu555])
#parent("/index.typ")

= Basic Functionalities

== Node Types

- Character: A node that matches single character
- String: A node that matches a sequence of characters
- Select: A node that matches a range of characters
- Except: A node that matches any character not in a specified range
- Ghost: A node that matches some ghost character like end of line

- Alternative: A node that matches one of several alternatives

- Optional: A node that matches zero or one occurrence of a pattern
- Exist: A node that matches one or more occurrences of a pattern
- Repetition: A node that matches zero or more occurrences of a pattern

- Assert: A node that matches a pattern only if it is followed by another pattern
- Negative Assert: A node that matches a pattern only if it is not followed by another pattern

In this lexer combinator, the optional, exist and repetition nodes always returns all cases can be matched,
not always greedy or non-greedy, but all possible cases.

All nodes can be combined together to create more complex patterns,
which is, concatenate nodes together and build a larger NFA graph.

== Traversal

When trying to match a pattern,
the lexer combinator will create a virtual tree structure, which represents all possible paths that can be taken to match the input string.
The virtual tree is built on the fly during the matching process,
and traversed in a breadth-first manner,
each time the lexer combinator find a way is possible to match the input string, it will add the next possible nodes to the dequeue,
and continue to traverse the virtual tree until it finds a match or exhausts all possibilities.
When a NFA graph inner as condition meet, every possible path of it is returned and attached to the outer traversal dequeue.
