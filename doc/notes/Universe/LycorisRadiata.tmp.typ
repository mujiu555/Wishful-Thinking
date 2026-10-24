
=== Assumptions

The following assumptions define the scope, architecture, trust boundaries, and authorization semantics of the system.

==== Authorization Scope

The system determines whether a subject, which is itself a Resource,
possesses the required privileges to access another Resource.
It is responsible for authorization decisions, not for enforcing resource operations.

+ *Resource-Oriented Authorization*:
  Everything within the model is represented as abstract resources
  (Process, CPU time, IO, User, Group, API, Kernel SysCall, and so on).
  The system determines whether the actual subject possesses
  the required privileges to perform a protected operation on the actual object.
+ *Authorization-Execution Separation*:
  The authorization subsystem is responsible for authorization decisions, not for executing resource operations.
  Resource operations are performed by their corresponding trusted API implementations after successful authorization.
+ *Admission-Time Authorization*:
  Authorization must be at least evaluated at the admission point of a protected operation.
  Once an operation has been admitted, subsequent revocation does not retroactively invalidate that authorization decision.
  Continuous authorization during operation execution is outside the scope of this model.
  _The business-level authorization like MAC authorization can reuse such system but not necessarily to do so._
  A successful static authorization decision does not necessarily constitute final admission
  when the trusted API requires additional authorization checks.
+ *Configurable Atomic Privileges*:
  The model does not prescribe a fixed set of atomic privileges or a universal mapping between operations and privileges.
  These are defined by concrete implementations.
  All required privileges must be satisfied for authorization.

==== Architectural Assumptions

+ *Protected Standalone Authorization Service*:
  Its execution environment, memory, and authoritative state are isolated from untrusted subjects by the underlying system.
+ *Trusted API-Based Enforcement*:
  Protected operations are exposed through trusted API implementations.
  These APIs perform authorization before executing their corresponding resource operations.
  Untrusted subjects cannot bypass the trusted API entry points to execute equivalent protected operations.
+ *Kernel Mechanism Separation*:
  When deployed as part of an operating system,
  the kernel provides the trusted mechanisms required for isolation, execution, IPC, and resource management.
  Kernel-internal mechanisms do not require redundant authorization through the user-space authorization service.
  Privileged kernel interfaces used by trusted API services must not be directly accessible to unauthorized subjects.
+ *Trusted Service Execution*:
  Protected operations must undergo all required authorization checks before execution.
  Upper-layer trusted APIs must ensure that protected operations cannot bypass their required authorization checks.
  Trusted API implementations may invoke privileged mechanisms only after all mandatory authorization checks have succeeded.
+ *Trusted Inter-Service Communication*:
  Communication between trusted API implementations and the authorization subsystem preserves the identity, integrity,
  and association of authorization requests and decisions.
  An authorization decision cannot be forged, substituted, replayed, or applied to a different protected operation.
+ *Trusted System Bootstrap*:
  The underlying trusted environment provides the minimum mechanisms required to initialize and operate the authorization subsystem.
  These mechanisms do not constitute unrestricted access to protected application resources.
+ *Fail-Closed Authorization*:
  A protected operation is not permitted when its required authorization cannot be completed successfully.
  Authorization service failure, communication failure, or invalid authorization state must not result in permission being granted.

==== Trust Boundaries

+ *Trusted Privilege Instances*:
  Privilege Instances are obtained from trusted sources.
  Their authenticity, integrity, and subject-object bindings are guaranteed by the surrounding trusted environment.
+ *Trusted Execution Context*:
  The actual subject and object of a protected operation are determined by a trusted execution context.
  And operation invoke subject must be same as handler subject when check happens.
  Same rules apply for objects.
  Untrusted callers cannot impersonate another subject or substitute a different object during authorization.
+ *Trusted Privilege Requirements*:
  Minimum privilege requirements are bound to trusted API implementations and cannot be removed,
  weakened, or bypassed by untrusted callers.
+ *Complete Mediation*:
  Every externally accessible protected operation is intercepted by a trusted enforcement mechanism before execution.
  Internal implementation steps of an already admitted operation do not independently require authorization
  unless they constitute separate protected operations.
+ *Isolated Authorization Subsystem*:
  The authorization subsystem operates behind a trusted boundary.
  External callers cannot construct, inspect, manipulate, retain, or directly transfer authoritative Privilege Handlers,
  or internal privilege computation results.
+ *Trusted State Management*
  Authoritative privilege records are read and updated through trusted mechanisms.
  State transitions are applied consistently and atomically where required.
+ *Authorization Request Lifetime*:
  An authorization request is a single logical authorization transaction initiated by a trusted enforcement point.
  All Privilege Handlers created during the request must be consumed or destroyed before the request completes.
  A request may involve remote trusted components, provided that
  the Handler lifecycle, request identity, and authorization consistency guarantees remain enforced.
  Authorization evidence intended for persistence or deferred use must be represented by a separate explicitly defined mechanism.

==== Privilege Handler Semantics

+ *Internal Privilege Handlers*:
  Privilege Handlers are internal authorization evidence.
  They are created, resolved, checked, proxied, and destroyed exclusively within the trusted authorization subsystem.
  External subjects interact through protected APIs rather than by possessing or transferring Handlers.
+ *Single-Use Handler Semantics*:
  Each Privilege Handler may be consumed by at most one check or proxy invocation.
  Once transferred to either operation, the Handler is consumed regardless of success or failure.
  Concurrent invocations cannot consume the same Handler more than once.
+ *No Persistent Authority from Handler Consumption*:
  Consuming a Handler produces an authorization decision or an internally derived Handler.
  A successful check does not grant the external subject a reusable Handler or persistent resource capability.
+ *Strict Evaluation*:
  Privilege Handlers are resolved, checked, and consumed immediately during ordinary authorization requests.
  For an explicit proxy request, the trusted API determines the intended proxy chain before its execution.
  The authorization subsystem resolves the initial Handler and processes the specified proxy chain sequentially.
  Each proxy invocation consumes its input Handler and, upon success, produces a derived Handler for the next operation in the chain.
  The final Handler is consumed by check.

  All Handlers remain internal to the authorization subsystem throughout this process.
  No Handler may be externally accessed, duplicated, retained beyond its authorized processing lifetime, or replaced by
  independently resolved authority.

==== Privilege Acquisition and Delegation

+ *Explicit Privilege Acquisition*:
  Privilege acquisition and delegation requests are explicitly initiated by program logic.
  The authorization subsystem does not automatically search for alternative authority sources
  or initiate privilege acquisition on behalf of an unauthorized operation.
+ *Request-Driven Delegation*:
  Delegation occurs only in response to an explicit request.
  A subject does not proactively distribute privileges to another subject through the authorization subsystem.
  Multi-stage delegation requests are explicitly arranged by the participating programs or services.
+ *Authorized Proxy Invocation*:
  Proxying is itself a protected operation.
  Possession of authority over a resource does not imply authority to proxy that resource's privileges.
  The caller must satisfy the independent authorization requirements of the proxy API and its receiver.
+ *Privilege Attenuation*:
  A derived Handler may contain only a subset of the source Handler's privileges
  and must preserve the validity constraints inherited from the source authorization evidence.
+ *Trusted Delegation Continuity*:
  Delegated authorization remains within the trusted authorization subsystem.
  A delegated Handler cannot be implicitly replaced by a newly resolved Handler
  that would discard restrictions inherited from its delegation chain.

==== Policy and Business Separation

+ *Policy-Independent Authorization Mechanism*:
  The authorization subsystem does not prescribe a particular ACL, DAC, MAC, RBAC, or ABAC policy model.
  Effective privileges are computed by a configured trusted Privilege Computing System.
+ *External Privilege Acquisition Policy*:
  Business-level policies determine whether a subject may request, acquire, or elevate privileges.
  Such policies may involve group membership, authentication, user confirmation, or other domain-specific conditions.
  Successful business validation does not itself bypass the authorization subsystem.
+ *Trusted Privilege Establishment*:
  Business services may request changes to authoritative privilege state or
  the establishment of delegated authority only through protected mechanisms.
  Privilege expansion must originate from an authorized source and cannot be produced by attenuating
  a Handler with insufficient privileges.

==== Revocation and Consistency

+ *Authorization Evidence Validity*:
  Any authorization evidence evaluated after the policy state from which
  it was derived may have changed must be validated against the applicable authoritative state before admission.

  This may be achieved through an atomic authorization transaction, generation-based validation,
  or another mechanism providing equivalent consistency guarantees.

  Generation-based validation must be atomic with respect to relevant revocation state transitions
  and must not rely on stale local generation values.

  An internally consistent policy snapshot does not by itself establish authorization evidence validity.
  The authorization decision must also satisfy the configured revocation ordering guarantee.
+ *Atomic Authorization State Transitions*:
  Changes that affect authorization validity and their required status updates are applied atomically.
  Privilege resolution and authorization verification cannot observe inconsistent intermediate authorization states.
+ *Scoped Revocation*:
  Revocation is complete for all affected authorization dependencies
  while remaining confined to the explicitly defined affected revocation scopes.

=== Entities

+ *Resource*:
+ *Privilege*:
  Atomic Privilege Properties:
  - Privilege Sets
  - Available Time Period
  - Generation
  - Attachments...
+ *Privilege Instance*:
  A trusted representation of the privilege information obtained for a specific subject–object pair during an authorization request.
  Its structure is defined according the configured Privilege Computing System, which may evaluate dynamic or stateful policies.
  The Privilege Instance must remain consistent with the authorization validity requirements of the request.
+ *Privilege Handler*:
  A handler contains computed privilege properties and be ready to be checked, restricted, and proxied.
  - Contains at least Subject, and Object information
  - Contains At least Privilege Sets
+ *Life Cycle*: The handler existence status

=== Relations

+ `check(handler: Privilege Handler, subject: Resource, object: Resource, rules: P(Privilege arrow.bar Boolean)) -> Boolean`
  `@auto_injected`
  Check the Subject have sufficient permission for Object.
  Must:
  + Check the handler have same subject as current subject
  + Check the handler have same object to current object
  + Check the handler is valid
  Destroy input handler
  - `@check(subject: Resource, priv: P(Privilege)) -> check(@aop(resolve(subject, object, fetch(subject, object))), subject, object, priv)`
    multiple `@check` will result in privilege requirements logical conjunction

+ `resolve(subject: Resource, object: Resource, instance: Privilege Instance) -> Privilege Handler`
  `@auto_injected`
  Resolve concrete Privilege Handler from a existing Privilege Instance
  + compute privilege handler from subject on object,
  + and attaches subject/object, proxy chain information to privilege handler
  Initialize the Privilege Handler
+ `proxy(sender: Resource, receiver: Resource, handler: Privilege Handler) -> Privilege Handler`
  `@check("api:///kernel/system/security/proxy", priv = ACCESS)`
  `@check("user:receiver#receiver", priv = {ACCESS, PROXY})`
  Transfer a handler and its privilege set to another subject.
  Check subject is sender, and sender have the ability to proxy handler to receiver
  + proxy handler own by sender to receiver, subject change to receiver and object keep unchanged,
  + attach a proxy log into proxy chain field of privilege handler,
  old handler destroyed no matter success or not
+ `restrict(handler: Privilege Handler, allowed: P(Privilege)) -> Privilege Handler`
  Limit privilege and alter properties
  + do logic conjunction on privilege so that make sure the privilege is passed shrink-only,
  Destroy input handler
+ `fetch(subject: Resource, object: Resource) -> Privilege Instance`
  `@privileged`
  Retrieves a trusted Privilege Instance associated with the given subject and object.
  The structure and contents of the instance are defined by the configured privilege computing model
  and contain all information required by resolve.
+ `revoke(subject: Resource, object: Resource, privilege: P(Privilege)) -> Boolean`
  `@check("api:///kernel/system/security/revoke", priv = ACCESS)`
  `@check("resource#resource", priv = {READ, ACCESS, WRITE})`
  Revocation is not restricted to a single API.
  It denotes a family of privilege-restricting state transitions that may invalidate previously resolved Privilege Handlers.
  Examples include direct privilege removal, group membership removal, role assignment removal, ACL modification, and delegation revocation.
  Each such transition must atomically update its authoritative state.
  revokes subjects' privilege on resource object, saved as serialized privilege instance, and expires all affected handlers
+ `enable(subject: Resource, object: Resource, privilege: P(Privilege)) -> Boolean`
  `@check("api:///kernel/system/security/enable", priv = ACCESS)`
  `@check("resource#resource", priv = {READ, ACCESS, WRITE})`
  extend a subjects' privilege on resource object, saved as serialized privilege instance

`fetch` is a special privileged api that allow to fetch privilege instance without even need privilege check.
`save`, however, need to be checked.

*Scoped Authorization Invalidation*:

Privilege-restricting state transitions must prevent authorization evidence whose authority is invalidated
by the transition from being successfully accepted after the transition has taken effect.
An implementation may achieve this through transactional isolation,
generation-based validation, cache invalidation, or equivalent mechanisms.

Conservative invalidation is permitted only within the explicitly defined affected authorization scopes.

*On-Demand Authorization and Resolution Caching*:
For ordinary protected operations, each authorization check attempts to obtain a newly resolved Privilege Handler,
which is verified and immediately consumed regardless of the authorization result.

*Delegated Privilege Handlers*:
Existing Privilege Handlers are accepted as authorization inputs only through explicit privilege delegation paths.
A delegated Handler retains its resolved privilege set, subject–object binding and all other information.

Proxying consumes the source Handler, attenuates its privileges, changes the authorized subject to the receiver,
and creates a new Handler preserving all inherited revocation dependencies.

An existing delegated Handler must not be implicitly replaced by a freshly resolved Handler, since doing so could discard restrictions inherited through the delegation chain.

=== Behaviours

This section specifies the observable behaviour and internal state
transitions of the authorization subsystem and its trusted integration
with protected API services.

==== Subject Identification

+ *Subject Registration.*

  The authorization subsystem maintains authoritative subject
  identities independently of individual API wrappers.

  When the trusted execution environment establishes a new subject,
  its authoritative identity is registered or made available to the
  authorization subsystem through a trusted mechanism.

  Untrusted subjects cannot register arbitrary identities on behalf
  of other subjects.

  Subject destruction or invalidation must prevent subsequent
  authorization requests from incorrectly resolving to a different
  subject with a reused external identifier.

+ *Subject Resolution.*

  For every protected invocation, the trusted execution environment
  establishes the actual caller.

  The trusted API wrapper forwards or preserves this authoritative
  identity when requesting authorization.

  The authorization subsystem verifies that the supplied execution
  context corresponds to the authoritative subject identity.

  The wrapper's own identity does not replace the caller's identity
  merely because the wrapper performs the IPC operation.

==== Privilege Fetching

+ `fetch(subject: Resource, object: Resource) -> Privilege Instance`

  `@privileged`

  Fetch retrieves the authoritative Privilege Instance associated
  with the specified subject and object.

  The operation:

  1. Verifies that the invocation originates from an authorized
    trusted internal execution path.

  2. Resolves the supplied subject and object to their authoritative
    Resource identities.

  3. Obtains the relevant static privilege records through the
    configured Privilege Access and Restore System.

  4. Includes all information required by the configured Privilege
    Computing System.

  5. Returns a trusted Privilege Instance.

  Fetch does not grant privileges and does not execute protected
  resource operations.

  Failure to obtain valid authoritative information must not result
  in an implicitly permissive Privilege Instance.

  Fetch is privileged because retrieving authorization state is an
  internal prerequisite of authorization checking and must not itself
  recursively require the same ordinary authorization check.

==== Privilege Resolution

+ `resolve(subject: Resource, object: Resource,
           instance: Privilege Instance) -> Privilege Handler`

  `@auto_injected`

  Resolve transforms a trusted Privilege Instance into an internal
  Privilege Handler.

  The operation:

  1. Verifies the consistency and authoritative binding of the
    Privilege Instance.

  2. Computes the effective atomic privilege set using the
    configured Privilege Computing System.

  3. Identifies the applicable revocation dependencies.

  4. Obtains the corresponding authoritative generations.

  5. Ensures the computed privilege set and captured generations
    belong to a consistent authorization state.

  6. Creates a new internal Privilege Handler.

  7. Binds the Handler to the authoritative subject and object.

  8. Records the effective privileges, captured generations,
    revocation dependencies, and initial lifecycle state.

  An ordinary newly resolved Handler does not inherit an unrelated
  delegation chain.

  Resolve must not reconstruct an existing delegated Handler using
  the receiver's native privileges.

  The resulting Handler remains exclusively inside the trusted
  authorization subsystem.

==== Generation Signaling

+ `signal(generations)`

  Signal obtains the current authoritative generation information
  for the supplied revocation dependencies.

  The operation:

  1. Identifies the applicable revocation scopes.

  2. Obtains a consistent view of their generation states.

  3. Returns the generation information required by verification.

  Signal does not itself authorize an operation.

  Generation information must originate from trusted state.

  If the required generation information cannot be obtained
  consistently, the dependent authorization must not succeed.

==== Handler Verification

+ `verify(handler: Privilege Handler,
          subject: Resource,
          object: Resource,
          minimal_privilege: P(Privilege),
          generations) -> Boolean`

  Verify evaluates whether the supplied Handler is sufficient
  for the requested protected operation.

  The operation verifies:

  1. The Handler is an authoritative internal Handler.

  2. The Handler has not previously been consumed.

  3. The actual subject equals the Handler's subject.

  4. The actual object equals the Handler's object.

  5. The required privilege set is contained in the Handler's
    effective privilege set.

  6. Every applicable captured generation matches the current
    authoritative generation.

  7. Inherited delegation dependencies remain valid.

  8. All applicable Handler lifecycle requirements are satisfied.

  Verify returns TRUE only when every required condition holds.

  Verify is an internal predicate.
  It does not independently establish authorization for an
  external protected operation.

==== Authorization Checking

+ `check(handler: Privilege Handler,
         subject: Resource,
         object: Resource,
         minimal_privilege: P(Privilege)) -> Boolean`

  `@auto_injected`

  Check performs one authorization decision using one internal
  Privilege Handler.

  Upon invocation:

  1. The subsystem atomically acquires exclusive consumption
    ownership of the Handler.

  2. The Handler becomes unavailable to other check or proxy
    invocations.

  3. The subsystem obtains the authoritative generation state.

  4. The subsystem executes the verification procedure.

  5. The subsystem records the resulting authorization decision.

  6. The Handler is destroyed or permanently marked consumed.

  7. The Boolean authorization result is returned to the trusted
    enforcement path.

  The Handler is consumed regardless of whether verification
  succeeds or fails.

  Failure to acquire exclusive consumption ownership results in
  authorization failure.

  A successful check admits only the protected operation to which
  the check belongs.

  A successful check does not expose the Handler or create a
  reusable external authorization capability.

  Subsequent changes to privilege state do not retroactively
  invalidate an operation already admitted by this check.

==== Automatic Authorization Injection

+ `@check(object: Resource, priv: P(Privilege))`

  The trusted API instrumentation automatically injects the
  required static authorization check into the API execution path.

  For an ordinary authorization request:

  1. Establish the authoritative actual subject.

  2. Establish the authoritative target object.

  3. Obtain the required privilege set from the trusted API
    declaration.

  4. Invoke fetch for the actual subject and object.

  5. Invoke resolve to construct a new internal Handler.

  6. Invoke check using that Handler.

  7. Continue only if authorization succeeds.

  A trusted delegated authorization path may provide an existing
  internal delegated Handler associated with the current request.

  Such a Handler must be checked directly and must not be replaced
  by a newly resolved Handler.

  Multiple `@check` declarations are evaluated conjunctively.

  The protected API is not admitted unless all required
  authorization checks succeed.

  Handler resolution and consumption remain internal to the
  authorization subsystem.

==== Privilege Proxy

+ `proxy(sender: Resource,
         receiver: Resource,
         privilege_restrict: P(Privilege),
         handler: Privilege Handler) -> Privilege Handler`

  `@check("api:///kernel/system/security/proxy",
          priv = ACCESS)`

  `@check("user:receiver#receiver",
          priv = ACCESS | PROXY)`

  Proxy transforms an existing internal Handler into a restricted
  Handler bound to another authorized subject.

  The operation:

  1. Establishes the actual sender from the trusted execution
    context.

  2. Verifies the required authorization for the Proxy API.

  3. Verifies the required authorization over the receiver.

  4. Acquires exclusive consumption ownership of the source
    Handler when it is submitted to the internal proxy operation.

  5. Verifies that the source Handler belongs to the actual sender.

  6. Verifies that the source Handler is valid.

  7. Computes the derived privilege set as the intersection of
    the source privilege set and the requested restriction.

  8. Creates a new Handler bound to the receiver while preserving
    the original object.

  9. Preserves all inherited revocation dependencies and captured
    generations.

  10. Appends the applicable delegation information to the
    proxy chain.

  11. Destroys the source Handler.

  12. Makes the derived Handler available exclusively within the
    trusted authorization subsystem for the associated explicit
    delegation request.

  The source Handler is consumed once submitted to the internal
  proxy operation, regardless of success or failure.

  A failed proxy operation must not produce a derived Handler.

  The operation does not automatically search for an authorized
  sender or another delegation source.

  The operation does not expose the derived Handler to the
  requesting external subject.

  A successful proxy does not modify the receiver's ordinary
  static ACL merely by transforming a Handler.

==== Explicit Proxy Requests

+ *Program-Defined Proxy Request.*

  A program requiring delegated authority explicitly invokes
  an appropriate protected service API.

  The request identifies the intended authority source,
  target resource, and requested privilege restriction as
  required by that service's interface.

  The trusted service verifies that the request is admissible
  under its own API requirements.

  The service may initiate an authorized internal proxy operation.

  No delegation is initiated automatically merely because an
  ordinary authorization check has failed.

+ *Multi-Stage Proxy Request.*

  A service receiving a proxy request may explicitly request
  authority from another subject or service.

  Each such request is initiated by the corresponding program
  logic and independently subject to its protected API rules.

  The authorization subsystem does not discover the next
  authority source or automatically traverse a hierarchy
  of subjects.

  Internal delegated authorization state remains associated
  with the corresponding request chain.

  A delegation step can succeed only when the required source
  authority and independent proxy permissions are satisfied.

+ *Proxy Request Rejection.*

  A proxy request may be rejected by the requested service,
  by business policy, or by the authorization subsystem.

  Rejection does not create new authority.

  Any Handler already submitted to an internal proxy operation
  is consumed, regardless of the rejection result.

  A rejected request does not automatically trigger another
  delegation request.

==== Privilege Restriction and Revocation

+ `revoke(subject: Resource,
          object: Resource,
          privilege: P(Privilege)) -> Boolean`

  `@check("api:///kernel/system/security/revoke",
          priv = ACCESS)`

  `@check("resource#resource",
          priv = READ | ACCESS | WRITE)`

  Revoke represents an authorized privilege-restricting
  state transition.

  Revocation includes, but is not limited to, direct privilege
  removal, ACL restriction, group membership removal, role
  assignment removal, and delegation revocation.

  The operation:

  1. Verifies the protected API requirements.

  2. Establishes the authoritative state to be restricted.

  3. Identifies all affected revocation scopes.

  4. Acquires the synchronization necessary to prevent
    inconsistent authorization observations.

  5. Updates the authoritative privilege state.

  6. Advances the required generation counters.

  7. Commits the privilege-state and generation changes
    atomically.

  8. Invalidates or renders unusable inconsistent cached
    privilege computation results.

  9. Releases the acquired synchronization.

  10. Returns the operation result.

  After the transition commits, all affected unconsumed
  Handlers must fail subsequent validation.

  The operation does not retroactively cancel a protected
  operation previously admitted by check.

  The same revocation consistency rules apply to other
  authorized privilege-restricting state transitions.

==== Privilege Expansion

+ `enable(subject: Resource,
          object: Resource,
          privilege: P(Privilege)) -> Boolean`

  `@check("api:///kernel/system/security/enable",
          priv = ACCESS)`

  `@check("resource#resource",
          priv = READ | ACCESS | WRITE)`

  Enable represents an authorized privilege-expanding
  state transition.

  The operation:

  1. Verifies the protected API requirements.

  2. Establishes the authoritative privilege record to
    be modified.

  3. Verifies that the requested modification is permitted
    by the trusted privilege management mechanisms.

  4. Applies the privilege expansion to authoritative state.

  5. Updates the necessary state versions or invalidation
    information so that stale cache entries cannot conceal
    the newly established permissions.

  6. Commits the authorized state transition.

  7. Returns the operation result.

  Enable does not modify a previously created Handler.

  Previously captured Handler privileges remain immutable.

  A subsequent ordinary authorization may resolve the
  newly established effective privileges.

  Enable cannot be invoked merely because a caller has
  requested additional privileges.
  It requires its own independent authorization.

==== Trusted Privilege Persistence

+ `save(instance: Privilege Instance)`

  Save represents the protected persistence of an authoritative
  privilege record.

  The concrete interface and serialization format are defined
  by the Privilege Access and Restore System.

  Save must not be directly accessible as an unrestricted
  operation to untrusted callers.

  The operation:

  1. Verifies the authority of the requesting management path.

  2. Validates the record and its authoritative bindings.

  3. Applies the requested state modification.

  4. Performs all corresponding version or generation updates.

  5. Commits the state transition consistently.

  6. Returns the persistence result.

  If a saved modification restricts privileges, the applicable
  revocation rules must be enforced.

  If a saved modification expands privileges, dependent cache
  consistency must be preserved.

  Save must not provide an alternative path that bypasses
  revoke, enable, or equivalent authorized state-transition
  requirements.

==== Resolution Cache

+ *Ordinary Cache Lookup.*

  During ordinary privilege resolution, the subsystem may
  search its internal resolution cache.

  If a matching cache entry exists:

  1. Verify its subject-object association.

  2. Verify all applicable revocation dependencies.

  3. Verify any additional authoritative version information
    required for cache correctness.

  4. Use the cached computation result only if it remains valid.

  A valid cached result may be used to construct a new Handler.

  The cache does not return a previously consumed live Handler.

+ *Cache Miss or Invalid Entry.*

  If no valid cache entry is available, the subsystem performs
  authoritative privilege computation.

  The newly computed result and its dependencies may be cached.

  An invalid cache entry must not be used to authorize an
  operation.

+ *Cache Invalidation.*

  A committed policy mutation must make every affected
  inconsistent cache entry unusable before it can produce
  an incorrect authorization result.

  The implementation may eagerly remove such entries or
  reject them through authoritative version validation.

==== Concurrent Authorization

+ *Concurrent Check.*

  Multiple authorization requests may execute concurrently
  when they do not violate authoritative state consistency.

  Concurrent attempts to consume the same Handler are serialized
  by the Handler lifecycle mechanism.

  At most one invocation can acquire consumption ownership.

+ *Concurrent Resolve.*

  A Handler must not be constructed from privilege records and
  generations belonging to inconsistent policy states.

  Resolution may use locks, snapshots, version validation, or
  equivalent trusted synchronization mechanisms.

+ *Concurrent Revocation.*

  A privilege-restricting state transition must not expose a
  partially updated privilege record and generation state.

  Authorization operations that overlap a revocation must have
  a consistent ordering relative to that transition.

  An authorization completed before the revocation's effective
  commit point follows admission-time authorization semantics.

  An authorization ordered after the commit must observe the
  updated restrictions.

==== Trusted API Wrapping

+ *Trusted API Invocation.*

  A trusted API service exposes a protected operation to
  external subjects.

  Upon invocation:

  1. The trusted execution environment identifies the
    actual caller.

  2. The API wrapper determines the authoritative target
    Resource and required static privileges.

  3. The wrapper invokes the authorization subsystem using
    the caller's authoritative subject identity.

  4. The subsystem performs its ordinary or delegated
    authorization procedure.

  5. The wrapper receives the authorization decision.

  6. If authorization fails, the protected operation is denied.

  7. If authorization succeeds, the wrapper executes any
    additional mandatory policy verification required by
    the API.

  8. Only after every required verification succeeds may the
    wrapper admit the protected operation.

  9. The trusted API implementation executes the admitted
    operation using the necessary trusted system mechanisms.

  The wrapper does not replace the caller's subject identity
  with its own service identity during authorization.

  The wrapper cannot reuse the authorization result for a
  different operation.

==== Mandatory Policy Verification

+ *Post-Authorization MAC Verification.*

  A trusted API may require mandatory security verification
  after successful static privilege authorization.

  The wrapper invokes the configured MAC verification service
  using trusted subject, object, operation, and security-context
  information.

  The MAC verification service evaluates the configured
  mandatory policy independently of the static authorization
  result.

  The protected operation is admitted only when both checks
  succeed.

  A MAC rejection denies the operation even when static
  privilege authorization succeeded.

  A successful MAC result does not create additional static
  privileges.

  MAC verification failure does not retroactively alter the
  completed static check or restore its consumed Handler.

+ *Trusted Security Context.*

  Dynamic security context is managed by the corresponding
  authorized business or security policy service.

  The MAC verification backend obtains trusted context through
  the configured trusted interface.

  Untrusted callers cannot replace authoritative security
  context by supplying arbitrary attributes.

  The authorization subsystem does not independently interpret
  the domain-specific meaning of that context.

+ *Contextual Policy Revocation.*

  A business or security policy service may change trusted
  context that affects future MAC decisions.

  Subsequent MAC verification uses the applicable updated
  trusted context according to its consistency rules.

  When a contextual change also requires restriction of static
  privileges, the responsible trusted service invokes the
  corresponding protected privilege-state transition.

  Static Handler invalidation is performed only when such
  authoritative static privilege dependencies are affected.

  An already admitted operation is not automatically interrupted
  merely because the dynamic security context later changes.

==== Business-Level Privilege Acquisition

+ *Privilege Acquisition Request.*

  A subject explicitly invokes a business service responsible
  for the desired privilege-acquisition operation.

  The business service first satisfies its own protected API
  authorization requirements.

  The service then evaluates its domain-specific acquisition
  policy using trusted business context.

  Such verification may involve group membership, security
  eligibility, authentication, user confirmation, or another
  defined approval procedure.

  A rejected request does not create authority.

  An approved request permits the business service to invoke
  the corresponding protected privilege management mechanism.

  Approval alone does not bypass static authorization of that
  management mechanism.

+ *Interactive User Authorization.*

  When the explicitly programmed acquisition workflow requires
  user approval, the responsible trusted service obtains a
  decision through an authorized user interaction mechanism.

  The approval is associated with the specific request,
  requested privilege scope, intended subject, and object.

  The approval cannot be substituted into an unrelated request.

  The authorization subsystem does not independently initiate
  user interaction.

+ *Sudo-Like Privilege Elevation.*

  A sudo-like protected service first verifies that the caller
  has permission to invoke its API.

  The business layer then evaluates the configured elevation
  policy, such as membership in an authorized sudoers group.

  It may additionally require authentication or interactive
  confirmation.

  Upon approval, the trusted service invokes authorized
  privilege-management or privileged-execution mechanisms.

  Elevated authority must originate from a trusted authorized
  source.

  A Handler with insufficient privileges cannot be expanded
  through proxy.

  The resulting execution remains subject to the mandatory
  authorization requirements of its protected operations.

==== Kernel and Resource Execution

+ *Trusted Kernel Invocation.*

  A trusted API implementation may invoke an underlying
  privileged kernel mechanism after admitting a protected
  operation.

  The kernel verifies the caller's eligibility to use the
  privileged mechanism through its underlying trusted
  protection facilities.

  The kernel does not need to repeat the application-level
  static authorization computation already performed by
  the trusted API.

+ *Internal Kernel Execution.*

  Internal kernel actions required to implement an admitted
  operation are treated as trusted implementation steps.

  They do not automatically constitute new externally
  accessible protected operations.

  A distinct protected operation requires its own applicable
  authorization before admission.

+ *Operation Completion.*

  Once a protected operation has been admitted, its
  implementation may proceed according to the execution
  semantics of that operation.

  Later static privilege revocation or dynamic context changes
  do not automatically cancel the admitted operation.

  The operation must not use that decision to authorize
  unrelated subsequent operations.

==== Failure Handling

+ *Authorization Failure.*

  Failure of any mandatory static authorization requirement
  prevents admission of the protected operation.

  Any Handler submitted to check is consumed.

+ *Proxy Failure.*

  A failed internal proxy operation does not produce a derived
  Handler.

  Any source Handler submitted to proxy is consumed.

+ *Mandatory Verification Failure.*

  A failed mandatory policy check prevents operation admission.

  It does not undo previously completed Handler consumption.

+ *State Consistency Failure.*

  If authoritative privilege state or required generations
  cannot be obtained consistently, dependent authorization
  must fail closed.

+ *Authorization Service Failure.*

  If the authorization service is unavailable, protected APIs
  requiring its verification must not admit new operations.

  Operations already admitted remain governed by their
  established admission-time execution semantics.

+ *Business Acquisition Failure.*

  Failure of a business-level privilege acquisition request
  does not create authority and does not automatically trigger
  alternative acquisition paths.

  Any additional request requires explicit program logic.

=== Sub-Systems

+ Privilege Authorization System
+ Privilege Computing System
+ Privilege Access and Restore System

=== System architecture

== Module

=== Invariants

The following invariants define the mandatory safety and consistency
properties of the authorization subsystem and its trusted integration
with protected API services.

==== Resource and Subject Identity

+ *Unified Resource Identity.*
  Every authorization subject and object is represented by a Resource.
  Authorization is bound to the identity of a Resource rather than
  to a particular URI, alias, name, or lookup path.

+ *Canonical Object Binding.*
  Multiple references resolving to the same Resource must not produce
  inconsistent authorization identities.
  Authorization decisions are bound to the resolved Resource identity.

+ *Authoritative Subject Registry.*
  The authorization subsystem independently maintains authoritative
  identities for all trusted subjects.
  Subject identities and their authoritative bindings cannot be
  created, modified, or substituted by untrusted callers.

+ *Actual Caller Binding.*
  For every protected API invocation, the authorization subject is
  the actual caller established by the trusted execution environment.
  A trusted API wrapper must preserve this subject when invoking the
  authorization subsystem.
  Its own service identity must not implicitly replace the caller.

+ *Subject Identity Integrity.*
  A subject cannot impersonate another subject by supplying a
  different Resource reference or authorization argument.
  Every subject transition used for authorization must originate
  from an authorized and trusted mechanism.

==== Protected API Enforcement

+ *Complete Mediation.*
  Every protected API invocation must satisfy all authorization
  requirements bound to that API before its protected operation
  is admitted.
  No untrusted invocation path may bypass those requirements.

+ *Trusted Privilege Requirements.*
  The required privilege set of each protected API is determined
  by its trusted implementation.
  Untrusted callers cannot remove, reduce, replace, or suppress
  an authorization requirement.

+ *Conjunctive Authorization.*
  When an API requires multiple authorization checks, all mandatory
  checks must succeed.
  Failure of any mandatory check denies the protected operation.

+ *Decision-Operation Binding.*
  An authorization decision applies only to the protected operation
  and trusted request context for which it was produced.
  It cannot be reused to authorize a different subject, object,
  operation, or invocation.

+ *No Authorization Bypass Through Kernel Primitives.*
  Trusted API implementations may invoke underlying privileged
  kernel mechanisms after authorization.
  Such mechanisms must not expose an equivalent unauthorized
  invocation path to untrusted subjects.
  The kernel is not required to repeat the subsystem's authorization
  computation for the same admitted operation.

+ *Fail-Closed Enforcement.*
  If any mandatory authorization check cannot complete successfully,
  the protected operation must not be admitted.
  Missing, invalid, inconsistent, or unavailable authorization
  information must not be interpreted as permission.

==== Privilege Computation

+ *Trusted Privilege Sources.*
  Privilege Instances must originate from authoritative sources
  managed by trusted mechanisms.
  Untrusted input cannot directly define effective privileges.

+ *Policy-Independent Computation.*
  The authorization mechanism does not depend on a particular
  implementation of ACL, DAC, RBAC, or another static privilege
  computing model.
  The configured backend determines the effective privilege set.

+ *Privilege Sufficiency.*
  A required privilege set is satisfied only if it is a subset
  of the effective privilege set.

+ *No Implicit Privilege Acquisition.*
  A failed privilege check does not automatically initiate privilege
  acquisition, elevation, or delegation.
  Such operations require explicit program-defined requests.

+ *Consistent Resolution.*
  A Privilege Handler must be constructed from privilege information
  and revocation generations belonging to one consistent
  authoritative state.
  A Handler must not combine incompatible state snapshots.

==== Privilege Handler Lifecycle

+ *Internal Handler Isolation.*
  Privilege Handlers exist exclusively within the trusted
  authorization subsystem.
  External subjects cannot construct, inspect, retain, modify,
  duplicate, or directly transfer authoritative Handlers.

+ *Handler Binding.*
  Every Handler is bound to exactly one authorization subject
  and one authorization object.
  A Handler cannot authorize an operation involving a different
  subject or object.

+ *Single-Consumption.*
  Each Handler may be consumed at most once.
  A Handler transferred to check or proxy becomes unavailable
  for any further invocation regardless of operation outcome.

+ *Atomic Consumption.*
  Handler consumption must be atomic.
  Concurrent operations cannot successfully acquire ownership
  of the same Handler more than once.

+ *No Handler Resurrection.*
  A consumed, destroyed, or invalidated Handler cannot be restored
  to an active state.
  Recomputing authorization creates a distinct new Handler.

+ *No External Capability Creation.*
  Consuming a Handler does not expose a reusable authorization
  capability to the external caller.
  The result of check is a decision for a specific operation;
  the result of proxy remains internal to the subsystem.

==== Delegation and Proxy

+ *Explicit Delegation Requests.*
  Every privilege delegation originates from an explicit request
  made by program logic through a protected API.
  The authorization subsystem does not automatically discover
  delegation sources or initiate delegation requests.

+ *Request-Before-Delegation.*
  Delegation must be requested before the corresponding internal
  proxy transformation is performed.
  No subject may proactively distribute a Handler to another
  subject through the authorization subsystem.

+ *Independent Proxy Authorization.*
  Authority over a resource does not imply authority to delegate
  that resource's privileges.
  Proxy invocation must independently satisfy its protected API
  requirements and receiver authorization requirements.

+ *Sender Integrity.*
  The sender of a proxy operation must be the actual authorized
  subject associated with the source Handler.
  An untrusted caller cannot nominate another sender.

+ *Receiver Binding.*
  A successful proxy operation changes the Handler's authorized
  subject to the specified receiver while preserving the object.
  The receiver must correspond to the authorized proxy request.

+ *Privilege Attenuation.*
  The effective privileges of a derived Handler must be a subset
  of those carried by its source Handler.
  Proxying must never amplify source authority.

+ *Delegation Dependency Preservation.*
  A derived Handler must preserve all inherited revocation
  dependencies and their captured generations.
  Delegation cannot remove or refresh an inherited dependency.

+ *No Delegation Re-Resolution.*
  A delegated Handler cannot be replaced by newly computed native
  privileges merely because the receiving subject possesses
  broader independent privileges.

+ *Request-Scoped Delegation Continuity.*
  Internal delegation state must remain associated with the
  explicit request chain that established it.
  It cannot be substituted into an unrelated request chain.

==== Generation and Revocation

+ *Monotonic Generations.*
  Each revocation scope has an authoritative generation counter.
  The counter never decreases or reuses an observable generation
  value within its validity domain.

+ *Immutable Captured Generations.*
  Once a Handler is constructed, its captured dependency generations
  remain immutable throughout its lifetime.

+ *Generation Validity.*
  A Handler is invalid if any captured revocation dependency
  generation differs from the current authoritative generation
  of that dependency.

+ *Atomic Revocation State Transition.*
  A privilege-restricting transition and all required generation
  updates must become visible atomically.
  Concurrent authorization operations cannot observe partially
  committed privilege state.

+ *Revocation Completeness.*
  Every live Handler whose previously resolved authority becomes
  invalid after a committed revocation must be invalidated.

+ *Revocation Locality.*
  Invalidation must remain within the permitted affected revocation
  scopes.
  Unrelated scopes must not be invalidated by that transition.

+ *Conservative Scoped Invalidation.*
  Within an affected scope, the implementation may invalidate
  Handlers whose effective privileges would still be sufficient
  after recomputation.
  Such conservative invalidation must not violate revocation
  locality.

+ *No Delegation-Based Revocation Bypass.*
  Proxying consumes the source Handler and produces a derived Handler bound to the receiver,
  preserving the source authority, inherited restrictions, provenance, and revocation dependencies.

==== Resolution Cache

+ *Cache Non-Authority.*
  Cached computation results are optimization data, not independent
  sources of authorization authority.

+ *Cache Generation Consistency.*
  Cached privilege results may be reused only when their captured
  dependencies remain valid for the authoritative privilege state.

+ *No Live Handler Reuse.*
  The resolution cache must not reuse a consumed or otherwise
  active Handler as a new authorization result.

+ *Policy Mutation Cache Consistency.*
  Any authoritative policy mutation that changes a cached result's
  validity must invalidate, update, or otherwise prevent use of
  the inconsistent cached result.
  This includes permission expansion when cached denials are used.

==== Authorization Time Semantics

+ *Admission-Time Decision.*
  Authorization is evaluated when an operation is admitted.
  Successful admission is final for that particular operation.

+ *No Retroactive Revocation.*
  Revocation after successful admission does not retroactively
  invalidate that operation's completed authorization decision.

+ *Operation Boundary Integrity.*
  An admitted operation cannot silently expand into additional
  independent protected operations without satisfying their
  corresponding authorization requirements.

+ *No Continuous Enforcement Assumption.*
  The authorization subsystem does not guarantee continuous
  reevaluation of privileges throughout operation execution.

==== Trusted Wrapper and Dynamic Policy Integration

+ *Wrapper Subject Preservation.*
  Trusted API wrappers must preserve the actual caller's
  authoritative subject identity when interacting with the
  authorization subsystem.

+ *Independent Mandatory Checks.*
  A trusted wrapper may require additional mandatory checks,
  including MAC verification, after static authorization.
  Successful static authorization cannot bypass a configured
  mandatory verification requirement.

+ *Trusted Business Context.*
  Business-level authorization services manage the trusted
  contextual information required by dynamic policies.
  Such information cannot be substituted by untrusted callers
  during policy verification.

+ *Dynamic Policy Separation.*
  Dynamic business and mandatory policy evaluation is external
  to the static authorization subsystem.
  The static subsystem does not implicitly acquire privileges
  or modify its decisions based on unrequested business workflows.

+ *Business-Controlled Revocation.*
  Business context changes requiring restriction of static
  privileges must invoke authorized state transitions in the
  authorization subsystem.
  Dynamic policy rejection may independently deny admission
  without requiring a static privilege mutation.

+ *Mandatory Policy Non-Bypass.*
  When an API requires dynamic mandatory verification, neither
  static privilege possession nor successful proxying may bypass
  that verification.

+ *Trusted Privilege State Modification.*
  Changes to authoritative static privilege records may occur
  only through authorized trusted management mechanisms.
  Business approval alone does not confer unrestricted write
  access to the authorization subsystem's internal state.

