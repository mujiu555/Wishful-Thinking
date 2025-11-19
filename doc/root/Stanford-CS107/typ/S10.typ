= Stanfrod CS107: Programming Paradigms

== activate record: function call frame

If have: prototype:
```c
void foo(int bar, int * baz) {
  char sninke[4];
  short * why;
  // ...
}
```

The argument of corresponding parameter and the local variables are placed in
almost close place.

```text
4 byte
        |         | baz
        |         | bar
        | < ret > |
        |         | snike
        |         | why
```

When calling within other functions: like `main`:

```c
int main (int argc, char * argv[]) {
  int i = 4;
  foo(i, &i);
  return 0;
}
```

We may have:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC <- sp
```
at initial.

Then, allocate space for variable `i`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |         |      <- sp
```
Assign for `i`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |    4    | i    <- sp
```

When calling `foo`:
pushing argument to stack for `foo`:
```txt
4 byte
0xffff  |         | argv -> |  ||||
0xfffc  |         | argc
        | < ret > | Saved PC
        |         | i
        | argument| i
        | argument| &i   <- sp
```


