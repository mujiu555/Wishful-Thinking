
#import "@local/tysty:0.1.0": meta, mkdoc
#import "../aut.typ": mujiu

#meta(
  title: [Myosotis Sylvatica --- Resource-Oriented File Systems: A Compositional Model for Naming, Entries, and Resource Access],
  date: datetime(year: 2026, month: 10, day: 19, hour: 0, minute: 0, second: 0),
  authors: (mujiu,),
  id: "dflat-myosotis sylvatica",
  parent_id: "index",
  abstract: "",
)

#mkdoc[

== Introduction

== Analysis

=== Assumptions

Assumptions specify the boundary of system.

=== Entities

+ Privilege: Atomic Permission
+ Resource:
  $("entries": cal(P)(("name": "String") arrow.bar ("resource": "Resource"))) times ("content": "Byte Stream") times ("meta data": "Meta data")$
+ Meta data:
  $("resource Id": "Integer") times
  ("file Type": "String") times
  ("owner": "Resource") times
  ...$
+ Privilege Instance:
  $("resource Subject": "Resource") times
  ("resource Object": "Resource") times
  ("privileges": cal(P)("Privilege"))$
+ Uri:
  $("schema": "String") times ("host": "String") times ("path": "String")$

=== Relations

+ `lookup(resource: Resource, target: String) -> Maybe Resource`:
  lookup a resource's entries, and try to find target resource using resource name
+ `resolve(path: Uri) -> Maybe Resource`:
  resolve the target resource, parse path Uri, and follow the lookup process
+ `write(resource: Resource, content: Byte Stream) -> Boolean`:
  write data into the content of resource

E.g., if `file://local/file` can find file `file`, then we can access its privilege metadata using `file://local/file/acl`, for some special user,
`file://local/file/acl/{user:#name}/write` for write permission...
E.g., if we have tag `foo` and a file called `file` can be referred by it: `file://local/{tag:foo}/file`
tags and users are just resources like normal file.
`tag:` and `user:` and other similar presentation are just URI.
Furthermore, since the file are just listed in the entries, and referring only resource, we may finally find they refers to same resource,
that is, maybe, `file://local/file0` and `file://local/{tag:foo}/file2` are same resource, both files or both other things...
Just like hard link, but, not only tags can be hard linked, metadata, block device, and anything others that can be seen as resource can all be linked.

=== Behaviours

=== Sub-Systems

=== System architecture

==

]