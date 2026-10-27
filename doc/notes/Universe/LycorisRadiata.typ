#import "@local/tysty:0.1.0": meta, mkdoc
#import "../aut.typ": mujiu

#meta(
  title: [Lycoris Radiata --- The Grammar of Authorization: A Composable Model for Access Control Systems],
  date: datetime(year: 2025, month: 8, day: 21, hour: 4, minute: 18, second: 0),
  authors: (mujiu,),
  id: "dflat-lycoris radiata",
  parent_id: "index",
  abstract: "",
)

#mkdoc[

== Introduction

=== Motivation
=== Contributions

== Background: Existing Systems

=== Unix DAC
==== Owner/ Group/ Mode
==== Kernel Enforcement
==== Target/ Static Semantics

=== Windows DACL
==== ACE and Security Descriptor
==== Access Token and AccessCheck
==== Target/ Static Semantics

=== OpenBSD pledge/unveil
==== Process-Level Restrictions

=== RBAC/ABAC
==== Role-Based Computation
==== Attribute-Based Computation
==== Target/ Dynamic Computed Semantics

=== FreeBSD Capsicum
==== File Descriptor Capabilities
==== Capability Transfer and Restriction

=== seL4 Kernel
==== Capability Operations
==== Delegation and Revocation

=== SELinux
==== Security Server and Object Manager
==== Access Vector Cache

=== Summary
==== Common Requirements
==== Independent Design Dimensions

== Analysis

=== System Separation
==== Privilege Storage
==== Privilege Computation
==== Privilege Verification
==== Trusted Enforcement

=== Assumptions
==== Trust Boundaries
==== Authorization Scope

=== Entities
==== Resource
==== Privilege Instance
==== Privilege Handler
==== Check Rules
==== Relations

=== Operations
==== Check
==== Handler Resolve
==== Proxy and Restrict
==== Instance Fetch
==== Enable and Revoke

=== Behaviours/ Semantics
==== Handler Lifecycle
==== Authorization Correctness
==== Delegation and Restriction
==== Revocation Consistency
==== Composition

== Specification

=== Formal State Model
=== Operation Contracts
=== Safety Invariants

== Sample Systems

=== Website Authorization System
==== Privilege Instance Structure
==== Privilege Handler
==== Privilege Instance Resolution
==== Privilege Handler Computation
==== Privilege Validation
==== Shadow API
===== Internal API
===== Public API
===== Parallelism
==== Cache

=== Unix DAC simulation

=== SELinux Simulation

== Comparison
=== Static Permission Models
=== Capability-Based Systems
=== Rule-Based Systems
=== Expressiveness and Composition
=== Performance and Complexity

== Conclusion
]
