/// - uid (int): unique id for documents, auto increment
#let uid = state("uid", 0)

/// - nid() -> int: get a new unique id
#let nid() = {
  uid.update(prev => prev + 1)
  context uid.get()
}
