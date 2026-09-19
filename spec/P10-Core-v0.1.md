# P10-Core v0.1 — Minimal Formal Specification

**Status:** research draft; not yet an implementation standard  
**Purpose:** define the smallest auditable object that can support a P10 verdict without identifying protocol support with truth  
**Normative language:** `MUST`, `MUST NOT`, `SHOULD`, and `MAY` are requirements of this draft

## 1. Scope

P10-Core is a protocol for deciding whether a finite evidence bundle satisfies pre-frozen conditions for a scoped verdict about a claim.

It does **not** define an internal truth predicate, prove the global reliability of P10, or make human ratification infallible.

The core distinction is:

\[
\operatorname{Truth}_{M}(c)
\quad\neq\quad
\operatorname{Supports}_{P}(e,c,v).
\]

`Truth_M(c)` is an external semantic assertion relative to a model or intended interpretation \(M\). `Supports_P(e,c,v)` is a checkable protocol judgement: under frozen protocol instance \(P\), evidence bundle \(e\) supports verdict \(v\) about claim \(c\).

## 2. Core object

A protocol instance is the tuple

\[
P=(C,E,R,F,\mathcal V,D,H),
\]

where:

- \(C\) is the space of scoped claims;
- \(E\) is the space of finite, content-addressed evidence bundles;
- \(R\) is the set of admissibility, transformation, checking, and decision rules;
- \(F\) is an immutable freeze record binding a particular run to fixed inputs and rules;
- \(\mathcal V\) is the verdict vocabulary;
- \(D\) is a deterministic decision procedure over canonical inputs;
- \(H\) is an external human-ratification relation.

The six symbols proposed in the motivating discussion, \((C,E,R,F,V,H)\), are therefore retained in substance, but \(V\) is split into a verdict vocabulary \(\mathcal V\) and a decision procedure \(D\). This avoids conflating possible outputs with the function that selects one.

### 2.1 Claim

A claim is a record

\[
c=(\text{id},\text{text},\text{formal target},\text{scope},\text{quantifiers},
\text{units},\text{time window},\text{boundary},\text{refutation conditions}).
\]

A claim MUST identify what would count as success, failure, and non-evaluability. Ambiguous natural-language text MAY be retained for provenance, but the decision procedure MUST operate on the frozen formal target and scope.

### 2.2 Evidence bundle

An evidence bundle \(e\in E\) is a finite manifest plus referenced artifacts. Every item MUST include:

- a content digest;
- a media/schema identifier;
- source and acquisition provenance;
- source-time and acquisition-time when applicable;
- a transformation lineage or an explicit declaration that it is raw;
- the checker result for every required integrity and admissibility rule.

The bundle identity is the digest of a canonical manifest. Mutating an item creates a new bundle.

### 2.3 Rules

Rules are divided into four disjoint classes:

\[
R=R_{adm}\cup R_{trans}\cup R_{check}\cup R_{dec}.
\]

- \(R_{adm}\): which sources and artifacts are admissible;
- \(R_{trans}\): permitted transformations and their parameters;
- \(R_{check}\): executable checks and certificate formats;
- \(R_{dec}\): the mapping from checked results to verdicts.

Every rule MUST have a stable identifier and version. An implementation-dependent rule MUST also bind the executable or environment digest needed to replay it.

### 2.4 Freeze record

The freeze record is

\[
F=(h_C,h_R,h_D,h_{env},t_f,\pi,\mu),
\]

where the hashes bind the claim, rules, decision procedure, and execution environment; \(t_f\) is the freeze event; \(\pi\) is the evidence-selection policy; and \(\mu\) is the amendment policy.

The record MUST be signed or otherwise made tamper-evident. It MUST state which evidence, if any, was known before freezing. “Preregistered” MUST NOT be used when the target evidence or result was inspected before \(t_f\), unless that exposure is explicitly recorded.

Any substantive amendment creates a new protocol instance \(P'\) and MUST NOT silently replace \(P\).

### 2.5 Verdict vocabulary

The minimal vocabulary is

\[
\mathcal V_0=\{\mathbf{Verified},\mathbf{NotDemonstrated},
\mathbf{UnfalsifiableAsStated},\mathbf{Deferred}\}.
\]

Their meanings are procedural:

- `Verified`: all frozen affirmative conditions are satisfied by admissible evidence and all mandatory checks succeeded;
- `NotDemonstrated`: the claim was evaluable and the run completed, but the admissible evidence did not satisfy the frozen conditions for `Verified`;
- `UnfalsifiableAsStated`: the frozen claim lacks an operational target or failure condition needed for evaluation;
- `Deferred`: the run could not complete because a declared prerequisite, source, execution, or review condition remained unresolved.

In particular,

\[
\mathbf{NotDemonstrated}(c)\not\Rightarrow\neg\operatorname{Truth}_{M}(c).
\]

Projects MAY extend the vocabulary, but each additional verdict MUST have disjoint entry conditions or an explicit precedence rule.

## 3. Judgements

P10-Core has three separate judgements.

### 3.1 Mechanical acceptance

\[
P\vdash_{\mathrm{check}}(e,c)\Downarrow(v,\kappa)
\]

means that the frozen checker deterministically evaluates canonical \((e,c)\), produces verdict \(v\), and emits certificate \(\kappa\).

### 3.2 Protocol support

\[
\operatorname{Supports}_{P}(e,c,v)
\]

holds iff all of the following hold:

1. the digests of \(c,R,D\), and the environment match \(F\);
2. the evidence manifest is canonical and its item digests verify;
3. every admitted item satisfies \(R_{adm}\);
4. every transformation is permitted by \(R_{trans}\) and linked to its inputs;
5. every mandatory check in \(R_{check}\) has a valid result or certificate;
6. \(D(F,c,e)=v\) under \(R_{dec}\);
7. \(\kappa\) commits to all material inputs, outputs, versions, and check results.

This judgement is about compliance with \(P\), not about truth in \(M\).

### 3.3 Issued verdict

\[
\operatorname{Issued}_{P}(e,c,v,h)
\;\overset{def}{\Longleftrightarrow}\;
\operatorname{Supports}_{P}(e,c,v)\land H(h,\kappa,\mathrm{accept}).
\]

Human ratification MAY accept or reject a supported result, but MUST NOT turn an unsupported result into a P10-Core verdict. An override, if governance permits it, MUST be recorded as `ManualOverride`, outside the P10-Core judgement.

Human ratification is therefore a declared trust boundary, not a proof rule establishing \(\operatorname{Truth}_{M}(c)\).

## 4. Transition-chain model

A run is a typed chain

\[
x_0\xrightarrow{T_1}x_1\xrightarrow{T_2}\cdots
\xrightarrow{T_n}x_n,
\]

with the reference decomposition

\[
\text{claim}\to\text{formal target}\to\text{assumptions}
\to\text{implementation}\to\text{execution}\to\text{evidence}
\to\text{verdict}.
\]

Each transition record is

\[
\tau_i=(x_{i-1},x_i,T_i,a_i,q_i),
\]

where \(a_i\) identifies the responsible agent or component and \(q_i\) is a locally checkable certificate.

The checker MUST verify:

\[
\operatorname{Check}_i(F,x_{i-1},x_i,q_i)=1
\]

for every mandatory transition. Missing mandatory certificates MUST fail closed to a non-`Verified` verdict.

## 5. Two soundness levels

### 5.1 Procedural soundness

Procedural soundness is internal and intentionally modest:

\[
\operatorname{Issued}_{P}(e,c,v,h)
\Rightarrow
\operatorname{Supports}_{P}(e,c,v).
\]

It follows from the definition of `Issued`, provided the certificate checker and ratification binding behave as specified. This establishes that the verdict was produced according to the frozen protocol.

### 5.2 Semantic lifting

For each transition, let \(S_i(x_{i-1},x_i)\) be the intended external semantic relation. A bridge assumption has the form

\[
B_i:\quad \operatorname{Check}_i(F,x_{i-1},x_i,q_i)=1
\Rightarrow S_i(x_{i-1},x_i).
\]

If all required \(B_i\) hold and their relational composition entails the target interpretation,

\[
S_1;S_2;\cdots;S_n\subseteq G_v,
\]

then:

\[
\operatorname{Supports}_{P}(e,c,v)
\land\bigwedge_i B_i
\Rightarrow G_v(c,e).
\]

For a project that intends `Verified` to imply truth, it must additionally justify

\[
G_{\mathbf{Verified}}(c,e)\Rightarrow\operatorname{Truth}_{M}(c).
\]

This is a **relative, conditional guarantee**. P10-Core itself MUST NOT collapse these bridge assumptions into the internal axiom

\[
\operatorname{Supports}_{P}(e,c,\mathbf{Verified})
\Rightarrow\operatorname{Truth}_{M}(c).
\]

Every published semantic claim MUST list the bridge assumptions on which it depends.

## 6. Determinism, replay, and immutability

For fixed canonical inputs and a bound environment, the mechanical layer MUST satisfy:

\[
D(F,c,e)=v_1\land D(F,c,e)=v_2\Rightarrow v_1=v_2.
\]

Each run MUST produce a replay manifest containing all bound digests and declared nondeterministic inputs. If exact replay is impossible, the run MUST state the weaker reproducibility property actually tested.

A completed run is immutable. New evidence, corrected code, changed rules, or a different environment creates a new run with a new identifier. Later runs MAY supersede earlier ones but MUST preserve the earlier record.

## 7. Fail-closed requirements

The system MUST NOT emit `Verified` when any of the following holds:

- a required digest, rule version, or environment binding is absent or mismatched;
- evidence required by the freeze is missing or inadmissible;
- a mandatory transition certificate is absent or invalid;
- the decision procedure crashes, times out beyond the frozen limit, or returns an unrecognized value;
- two mandatory check results conflict and the frozen conflict rule does not resolve them;
- the human ratifier did not receive the same certificate committed to by the issued record.

The frozen rules MUST map each failure to a non-`Verified` verdict or to a protocol-error state. A protocol error MUST NOT be presented as evidence that the claim is false.

## 8. Certificate

Every supported verdict has a certificate

\[
\kappa=(h_F,h_C,h_E,h_R,h_D,h_{env},Q,v,t,a),
\]

where \(Q\) is the ordered set of transition and check results, \(t\) is timing metadata, and \(a\) records relevant agents/components.

An independent checker SHOULD be able to validate \(\kappa\) without trusting the producer that assembled it. Requiring two implementations is an optional engineering policy, not a theorem of P10-Core; any such policy MUST declare what “independent” means and which dependencies remain shared.

## 9. Minimal invariants

Any conforming implementation MUST preserve:

1. **Separation:** `Supports` is never serialized or described as an unqualified truth predicate.
2. **Freeze integrity:** verdict-relevant inputs are bound before evaluation and amendments create a new instance.
3. **Provenance closure:** every material output is traceable to admitted inputs and declared transformations.
4. **Determinism:** fixed canonical inputs and bound environment yield the same mechanical verdict.
5. **Fail-closed verification:** missing or invalid mandatory checks cannot yield `Verified`.
6. **Verdict non-explosion:** failure to verify does not entail falsity.
7. **Ratification non-escalation:** a human cannot convert an unsupported result into a P10-Core verdict.
8. **Assumption visibility:** every semantic lifting claim exposes its bridge assumptions and trust boundary.
9. **Run immutability:** revisions and new evidence produce new, linked runs.
10. **Scope binding:** a verdict applies only to the frozen claim, evidence bundle, rules, environment, and run.

## 10. P10-audit-P10 profile

A self-audit is an ordinary P10 run in which the target is a fixed P10 implementation or protocol version. It MUST use a distinct meta-protocol instance \(P^*\), even if some tools are shared.

The target MUST be a finite property, for example:

- deterministic replay for a declared corpus;
- rejection of every malformed certificate in an adversarial suite;
- absence of `Verified` on cases violating one frozen mandatory condition;
- complete provenance linkage for every artifact in a test corpus;
- agreement between a reference semantics and an implementation on a bounded domain.

A valid conclusion is scoped:

\[
\operatorname{Supports}_{P^*}(e^*,
\text{“implementation }I\text{ version }z\text{ satisfies property }p
\text{ on domain }d\text{”},v).
\]

It MUST NOT be generalized to “P10 is globally sound” or “all P10-Verified claims are true.” Shared dependencies between \(P^*\) and the target MUST be listed as part of the trust boundary.

### 10.1 Pre-registered failure conditions

At minimum, a self-audit fails its target if it produces any of the following:

1. `Verified` with a missing mandatory artifact or failed check;
2. different mechanical verdicts for identical canonical inputs and bound environment;
3. a certificate that does not commit to a verdict-relevant input;
4. acceptance of evidence excluded by the frozen admissibility policy;
5. an unrecorded post-freeze rule or threshold change;
6. a reported semantic guarantee whose bridge assumptions are absent;
7. an inability to distinguish `NotDemonstrated` from claim falsity in the serialized result.

Passing a finite adversarial suite establishes only the frozen test claim over that suite. It is not a proof that no counterexample exists outside the tested domain.

## 11. Reference evaluation algorithm

```text
evaluate(P, c, e):
    require hashes_match(P.F, c, P.R, P.D, environment)
        else return protocol_error

    require canonical_manifest(e) and verify_all_digests(e)
        else return non_verified_by_frozen_policy

    if not operationalizable(c, P.F):
        return UnfalsifiableAsStated

    if unresolved_required_prerequisite(c, e, P.F):
        return Deferred

    require all_admissible(e, P.R_adm)
        else return non_verified_by_frozen_policy

    Q := run_mandatory_checks(P.F, c, e, P.R)

    if Q is incomplete, invalid, or unresolved:
        return non_verified_by_frozen_policy

    if verified_conditions_hold(Q, P.R_dec):
        return Verified with certificate

    return NotDemonstrated with certificate
```

`non_verified_by_frozen_policy` is deliberately not fixed globally: a project must preregister whether a given failure is `NotDemonstrated`, `Deferred`, or a distinct protocol-error result. It can never default to `Verified`.

## 12. Conformance record

A conforming deployment publishes or archives:

- the serialized claim and freeze record;
- the evidence manifest and availability status of each artifact;
- rule, checker, and environment versions/digests;
- the complete certificate and mechanical verdict;
- the ratification record or explicit absence of ratification;
- all bridge assumptions behind any semantic interpretation;
- known shared dependencies and trust boundaries;
- supersession links to earlier or later runs.

## 13. What remains open after v0.1

This draft intentionally leaves the following as explicit research or project parameters rather than hiding them inside `Verified`:

- the formal language used for claims and transition relations;
- how bridge assumptions are justified or tested;
- whether evidence accumulation is monotone for a given verdict policy;
- conflict resolution between sources and checkers;
- quantitative assurance and correlated-failure models;
- the precise authority and accountability model for human ratification;
- mechanization in Lean, Coq, or another proof assistant;
- a compositional theorem for a concrete, fully instantiated P10 chain.

The next formal step is to instantiate one bounded case, define each \(S_i\) and \(B_i\), and prove the conditional composition theorem for that case. Only after that should a P10-audit-P10 experiment be frozen.

## 14. Compact claim discipline

The strongest claim justified by P10-Core alone is:

> For the identified claim, evidence bundle, rules, decision procedure, environment, and run, the certificate checks and the frozen protocol yields the recorded verdict.

Any stronger statement—especially that the claim is true, that the protocol is globally sound, or that the verifier certifies its own reliability—requires separately stated external assumptions or evidence.
