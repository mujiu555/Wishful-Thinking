#import "@preview/tysty:0.1.0": entry, num
#import "../aut.typ": mujiu

#entry(
  title: [Proposal: A Composable Model for Access Control Systems],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  authors: ("2363107",),
  id: "proposal",
  abstract: "
  ",
)[
  #show: num.with(pattern: "1.")

  = The Grammar of Authorization: A Composable Abstraction for Authorization Systems

  == Background

  Decades of research have produced diverse authorization models and security architectures,
  including ACL, RBAC, ABAC, Unix DAC, Windows DACL, SELinux, and capability-based systems.

  Although these systems differ in how authority is represented, computed, and enforced,
  they share several underlying mechanisms,
  such as privilege computation, policy evaluation, delegation, authorization checking, and authorization-state management.

  Existing research has also demonstrated that authorization policies can be independently specified
  and composed through common orchestration mechanisms, as illustrated by Crampton and Huth's work on modular authorization policies.

  == Motivation

  Existing abstractions primarily focus on particular authorization models or individual mechanisms,
  especially policy evaluation, rather than the composition of complete authorization systems.

  However, an authorization system involves not only deciding whether an operation is permitted,
  but also determining how privileges are obtained, transferred, checked, and maintained as authorization state evolves.
  Inspired by "Build Systems à la Carte",
  this research aims to identify a common set of independently defined mechanisms through
  which existing authorization architectures can be characterized and new ones can be constructed compositionally.

  == Research Question

  How can the fundamental mechanisms shared by different authorization systems be expressed as
  independent, composable abstractions,
  allowing diverse authorization models and security architectures to be constructed
  while preserving their intended authorization semantics and security properties?


  == Expected Outcomes

  The expected outcomes of this research are summarized as follows:

  + *A decomposition of authorization systems into fundamental mechanisms*:

    Identify and formalize five essential mechanisms of authorization
    systems: privilege checking, privilege computation, rule retrieval,
    authority transfer, and authorization-state management.

    Define their responsibilities, interfaces, and interactions,
    separating the functional structure of authorization systems
    from the implementation of individual mechanisms.

  + *A composable authorization architecture with a common privilege handle.*

    Develop a compositional abstraction in which essential authorization
    mechanisms can be independently implemented and combined through
    well-defined interfaces.

    Rule retrieval and privilege computation are separated from the
    checking of API-declared privilege requirements through a common
    privilege handle. Authorization-state management and authority
    transfer are defined as orthogonal mechanisms within the same
    architecture.

    The abstraction aims to support different authorization models
    without requiring changes to the common authorization-checking
    interface.

  + *A characterization and evaluation of authorization architectures.*

    Instantiate representative authorization architectures, including
    ACL, RBAC, ABAC, and capability-based systems, using the proposed
    mechanisms.

    Evaluate whether the abstraction can express their authorization
    semantics, support alternative implementations of individual
    mechanisms, and preserve the intended security properties under
    valid compositions.
]

