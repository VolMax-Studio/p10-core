# P10-Core v0.2.1 — Minimal Formal Specification

**Status:** research draft; not yet an implementation standard  
**Purpose:** define the smallest auditable object that can support a P10 verdict without identifying protocol support with truth  
**Normative language:** `MUST`, `MUST NOT`, `SHOULD`, and `MAY` are requirements of this draft

**Changes from v0.2:** certificate-explicit `Supports`; verdict-specific support constructors; error-first preflight; declarative rule semantics with checker-soundness obligations; separate run and issuance outcomes; and explicit freeze bindings for checker, schema, and canonicalization.

## 1. Scope

P10-Core is a protocol for deciding whether a finite evidence bundle satisfies pre-frozen conditions for a scoped verdict about a claim.

It does **not** define an internal truth predicate, prove the global reliability of P10, or make human ratification infallible.

The core distinction is:

\[
\mathrm{Truth}_{M}(c)
\quad\neq\quad
\mathrm{Supports}_{P}(e,c,v,\kappa).
\]

`Truth_M(c)` is an external semantic assertion relative to a model or intended interpretation \(M\). `Supports_P(e,c,v,κ)` is a declarative protocol judgement: under frozen protocol instance \(P\), certificate \(\kappa\) establishes that evidence bundle \(e\) supports verdict \(v\) about claim \(c\).

## 2. Core object

A protocol instance is the tuple

\[
P=(C,E,R,F,\mathcal O,D,H),
\]

where:

- \(C\) is the space of scoped claims;
- \(E\) is the space of finite, content-addressed evidence bundles;
- \(R\) is the set of admissibility, transformation, checking, and decision rules;
- \(F\) is an immutable freeze record binding a particular run to fixed inputs and rules;
- \(\mathcal O\) is the typed run-outcome vocabulary, containing claim verdicts and protocol errors;
- \(D\) is a deterministic decision procedure over canonical inputs;
- \(H\) is an external human-ratification relation.

The six symbols proposed in the motivating discussion, \((C,E,R,F,V,H)\), are therefore retained in substance, but \(V\) is split into a typed outcome vocabulary \(\mathcal O\) and a decision procedure \(D\). This avoids conflating possible outputs with the function that selects one. Claim verdicts and failures of the protocol itself are different constructors of \(\mathcal O\), so a procedural failure cannot be mistaken for evidence about the claim.

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
F=(h_C,h_R,h_D,h_{checker},h_{schema},h_{canon},h_{env},t_f,\pi,\mu),
\]

where the hashes bind the claim, rules, decision procedure, certificate checker, certificate/data schemas, canonical encoding, and execution environment; \(t_f\) is the freeze event; \(\pi\) is the evidence-selection policy; and \(\mu\) is the amendment policy. Checker, schema, and canonicalization bindings MUST NOT be hidden only inside \(h_{env}\).

The record MUST be signed or otherwise made tamper-evident. It MUST state which evidence, if any, was known before freezing. “Preregistered” MUST NOT be used when the target evidence or result was inspected before \(t_f\), unless that exposure is explicitly recorded.

Any substantive amendment creates a new protocol instance \(P'\) and MUST NOT silently replace \(P\).

### 2.5 Typed outcomes and disjoint entry conditions

The minimal claim-verdict vocabulary is

\[
\mathcal V_0=\{\mathbf{Verified},\mathbf{NotDemonstrated},
\mathbf{UnfalsifiableAsStated},\mathbf{Deferred}\}.
\]

Let \(\mathcal K_F\) be the certificate space selected by the frozen schema, \(\mathcal R_P\) the run-error-record space, and \(\mathcal A_H\) the ratifier-identity space. The total mechanical run outcome is the tagged sum

\[
\mathrm{RunOutcome}_0=
\mathrm{Verdict}(\mathcal V_0\times\mathcal K_F)
\;\uplus\;
\mathrm{ProtocolError}(\mathcal E_P\times\mathcal R_P),
\]

where \(\mathcal E_P\) is the set of typed protocol-error witnesses. `ProtocolError` is not a claim verdict.

Human handling is a separate tagged sum:

\[
\mathrm{IssuanceOutcome}_0=
\mathrm{Issued}(\mathcal V_0\times\mathcal K_F\times\mathcal A_H)
\;\uplus\;
\mathrm{RejectedByRatifier}(\mathcal V_0\times\mathcal K_F\times\mathcal A_H)
\;\uplus\;
\mathrm{RatificationError}(\mathcal E_H).
\]

An issuance event cannot retroactively change the immutable `RunOutcome`.

Their meanings are procedural:

- `Verified`: the claim was evaluable; the run completed over admissible evidence; all mandatory checks succeeded; and the frozen affirmative conditions hold;
- `NotDemonstrated`: the claim was evaluable; the run completed over admissible evidence; all mandatory checks succeeded; but the frozen affirmative conditions do not hold;
- `UnfalsifiableAsStated`: the frozen claim lacks an operational target or failure condition needed for evaluation;
- `Deferred`: the protocol remains intact, but evaluation could not complete because an external prerequisite, admissible source, execution dependency, or required review condition remains unresolved;
- `ProtocolError`: the procedure itself failed, including a binding mismatch, invalid certificate, invalid canonical form, inadmissible evidence presented as admissible, checker crash, environment mismatch, or unrecognized output.

The following is a core invariant rather than explanatory prose:

\[
\begin{aligned}
\left(\exists\kappa\in\mathcal K_F,\;
\mathrm{RunOutcome}_P(c,e)=
\mathrm{Verdict}(\mathbf{NotDemonstrated},\kappa)\right)
\Rightarrow{}&\mathrm{Evaluable}_P(c)\\
&\land\mathrm{RunCompleted}_P(c,e)\\
&\land\mathrm{EvidenceAdmissible}_P(e)\\
&\land\mathrm{MandatoryChecksSucceeded}_P(c,e)\\
&\land\neg\mathrm{VerifiedConditions}_P(c,e).
\end{aligned}
\]

Similarly,

\[
\left(\exists\kappa\in\mathcal K_F,\;
\mathrm{RunOutcome}_P(c,e)=
\mathrm{Verdict}(\mathbf{Verified},\kappa)\right)
\Rightarrow
\mathrm{Evaluable}_P(c)\land
\mathrm{RunCompleted}_P(c,e)\land
\mathrm{EvidenceAdmissible}_P(e)\land
\mathrm{MandatoryChecksSucceeded}_P(c,e)\land
\mathrm{VerifiedConditions}_P(c,e).
\]

The constructors of `RunOutcome` and `IssuanceOutcome` are pairwise disjoint. Raw run faults may coexist, but the frozen evaluator MUST return exactly one tagged run outcome using the fixed phase order in Section 11. A missing prerequisite cannot yield `NotDemonstrated`; an internal procedural failure cannot yield `Deferred`.

In particular,

\[
\left(\exists\kappa\in\mathcal K_F,\;
\mathrm{RunOutcome}_P(c,e)=
\mathrm{Verdict}(\mathbf{NotDemonstrated},\kappa)\right)
\not\Rightarrow\neg\mathrm{Truth}_{M}(c).
\]

Projects MAY extend the vocabulary, but every extension MUST preserve typed, pairwise-disjoint terminal outcomes.

## 3. Judgements

P10-Core separates mechanical execution, declarative support, and issuance.

### 3.1 Mechanical run

\[
P\vdash_{\mathrm{run}}(e,c)\Downarrow
\mathrm{Verdict}(v,\kappa)
\]

means that the frozen evaluator deterministically processes canonical \((e,c)\), produces claim verdict \(v\), and emits certificate \(\kappa\). A mechanical failure instead produces

\[
P\vdash_{\mathrm{run}}(e,c)\Downarrow
\mathrm{ProtocolError}(\epsilon,\rho),
\]

where \(\rho\) is an error record. Protocol errors never construct `Supports`.

### 3.2 Verdict-indexed protocol support

\[
\mathrm{Supports}_{P}(e,c,v,\kappa)
\]

is an inductive relation indexed by the verdict. Its constructors are disjoint by construction. Define `PreflightOK` to mean that every frozen binding matches; the certificate and data schemas parse; the evidence manifest is canonical; all supplied digests verify; every supplied item is admissible; and \(\kappa\) commits to the preflight result. `CertificateBinds` additionally means that \(\kappa\) commits to the exact \((P,c,e,v)\) tuple and its verdict-specific witness.

The minimal constructors are:

\[
\frac{
\begin{array}{c}
\mathrm{PreflightOK}_P(c,e,\kappa)\quad
\mathrm{Evaluable}_P(c)\quad
\mathrm{RunCompleted}_P(c,e)\\
\mathrm{MandatoryChecksSucceeded}_P(c,e)\quad
\mathrm{TransitionsValid}_P(c,e,\kappa)\quad
\mathrm{VerifiedConditions}_P(c,e)\quad
\mathrm{CertificateBinds}_P(c,e,\mathbf{Verified},\kappa)
\end{array}}
{\mathrm{Supports}_P(e,c,\mathbf{Verified},\kappa)}
\;\textsc{supportsVerified}
\]

\[
\frac{
\begin{array}{c}
\mathrm{PreflightOK}_P(c,e,\kappa)\quad
\mathrm{Evaluable}_P(c)\quad
\mathrm{RunCompleted}_P(c,e)\\
\mathrm{MandatoryChecksSucceeded}_P(c,e)\quad
\mathrm{TransitionsValid}_P(c,e,\kappa)\quad
\neg\mathrm{VerifiedConditions}_P(c,e)\quad
\mathrm{CertificateBinds}_P(c,e,\mathbf{NotDemonstrated},\kappa)
\end{array}}
{\mathrm{Supports}_P(e,c,\mathbf{NotDemonstrated},\kappa)}
\;\textsc{supportsNotDemonstrated}
\]

\[
\frac{
\mathrm{PreflightOK}_P(c,e,\kappa)\quad
\neg\mathrm{Operationalizable}_P(c)\quad
\mathrm{CertifiesReason}(\kappa,\mathrm{unfalsifiable})\quad
\mathrm{CertificateBinds}_P(c,e,\mathbf{UnfalsifiableAsStated},\kappa)}
{\mathrm{Supports}_P(e,c,\mathbf{UnfalsifiableAsStated},\kappa)}
\;\textsc{supportsUnfalsifiable}
\]

\[
\frac{
\begin{array}{c}
\mathrm{PreflightOK}_P(c,e,\kappa)\quad
\mathrm{Operationalizable}_P(c)\quad
\mathrm{ExternalBlocker}_P(c,e,b)\\
\mathrm{NoProtocolFault}_P(c,e)\quad
\mathrm{CertifiesReason}(\kappa,b)\quad
\mathrm{CertificateBinds}_P(c,e,\mathbf{Deferred},\kappa)
\end{array}}
{\mathrm{Supports}_P(e,c,\mathbf{Deferred},\kappa)}
\;\textsc{supportsDeferred}
\]

`MandatoryChecksSucceeded` means that all required checkers completed with well-formed results, not that every substantive result was affirmative. `Supports` remains a judgement about compliance with \(P\), not truth in \(M\).

### 3.3 Issuance

\[
\mathrm{Issued}_{P}(e,c,v,\kappa,h)
\;\overset{def}{\Longleftrightarrow}\;
\mathrm{Supports}_{P}(e,c,v,\kappa)
\land H(h,\kappa,\mathrm{accept}).
\]

Ratifier rejection produces `RejectedByRatifier`; a mismatched certificate, invalid ratifier binding, or ratification-system failure produces `RatificationError`. Neither changes the earlier mechanical run outcome.

Human ratification MAY accept or reject a supported result, but MUST NOT turn an unsupported result into a P10-Core verdict. An override, if governance permits it, MUST be recorded as `ManualOverride`, outside the P10-Core judgement. Ratification is a declared trust boundary, not a proof rule establishing \(\mathrm{Truth}_{M}(c)\).

## 4. Transition-chain model

A run is a typed chain over artifact types \(X_0,\ldots,X_n\):

\[
x_0:X_0\xrightarrow{T_1}x_1:X_1\xrightarrow{T_2}\cdots
\xrightarrow{T_n}x_n,
\]

with the reference decomposition

\[
\text{claim}\to\text{formal target}\to\text{assumptions}
\to\text{implementation}\to\text{execution}\to\text{evidence}
\to\text{verdict}.
\]

Each transition is a typed partial computation

\[
T_i:X_{i-1}\to \mathrm{Result}(X_i,\mathcal E_i),
\]

and successful composition requires

\[
\mathrm{SuccCod}(T_i)\subseteq X_i
=\mathrm{dom}(T_{i+1}).
\]

Here \(\mathrm{SuccCod}(T_i)\) contains only successful outputs, excluding \(\mathcal E_i\).

Type compatibility is necessary but not sufficient. Each transition therefore also has a preservation contract \(\mathrm{Contract}_i\), an input/output invariant pair \(I_{i-1},I_i\), and a claim-fidelity relation \(\Phi_i(c,x_i)\).

Each transition record is

\[
\tau_i=(x_{i-1},x_i,T_i,\mathrm{Contract}_i,I_i,\Phi_i,a_i,q_i),
\]

where \(a_i\) identifies the responsible agent or component and \(q_i\) is a locally checkable certificate. A conforming transition MUST satisfy the preservation obligations

\[
I_{i-1}(x_{i-1})\land
\mathrm{Contract}_i(x_{i-1},x_i)
\Rightarrow I_i(x_i)
\]

and

\[
\Phi_{i-1}(c,x_{i-1})\land
\mathrm{Contract}_i(x_{i-1},x_i)
\Rightarrow \Phi_i(c,x_i).
\]

The second obligation prevents a well-typed chain from silently changing the claim under evaluation. \(\Phi_i\) MAY be identity, semantic equivalence, or a declared refinement relation, but its meaning and proof obligation MUST be frozen for the instance.

The checker MUST verify:

\[
\mathrm{Check}_i(F,x_{i-1},x_i,
\mathrm{Contract}_i,I_i,\Phi_i,q_i)=1
\]

for every mandatory transition. Missing or invalid mandatory certificates and failed preservation obligations MUST produce `ProtocolError`, never a claim verdict.

## 5. Two soundness levels

### 5.1 Certificate-checker soundness

`Supports` is a declarative relation defined independently of the executable checker. Let

\[
\mathrm{CheckCert}(P,c,e,\kappa,v):\mathrm{Bool}
\]

be the independently executable certificate checker.

Frozen rules have a declarative semantics \(R_{sem}(r,x)\) independent of executable checking. For each rule class, the executable checker

\[
\mathrm{check}_R:R\to\mathrm{Input}\to\mathrm{Bool}
\]

must satisfy the proved lemma

\[
\mathrm{RuleCheckerSound}
\;\overset{def}{\Longleftrightarrow}\;
\forall r\,x,\;
\mathrm{check}_R(r,x)=\mathrm{true}
\Rightarrow R_{sem}(r,x).
\]

The primary procedural theorem obligation is therefore:

\[
\boxed{
\left(A_{parse}\land A_{canon}\land A_{digest}
\land\mathrm{RuleCheckerSound}\right)
\land\mathrm{CheckCert}(P,c,e,\kappa,v)=\mathrm{true}
\Rightarrow
\mathrm{Supports}_{P}(e,c,v,\kappa)
}
\]

The residual implementation assumptions are

\[
A_{parse}\land A_{canon}\land A_{digest},
\]

covering parser correctness, canonicalization correctness, and digest binding/collision assumptions. They MUST appear in the checker's theorem statement or associated trust manifest. `A_rules` is forbidden as an opaque assumption: rule implementation fidelity must be discharged by `RuleCheckerSound` lemmas against \(R_{sem}\). Future mechanization MAY similarly replace the residual assumptions with proofs.

The proof MUST establish at least:

1. every material field required by `Supports` is committed to by \(\kappa\);
2. all frozen bindings match;
3. all transition contracts, invariants, and fidelity relations validate;
4. the checked decision result is \(\mathrm{Verdict}(v)\), not `ProtocolError`;
5. no unchecked producer assertion is used to derive `Supports`.

The earlier statement

\[
\mathrm{Issued}_{P}(e,c,v,\kappa,h)\Rightarrow
\mathrm{Supports}_{P}(e,c,v,\kappa)
\]

remains a definitional corollary of `Issued`; it is not the substantive soundness theorem.

### 5.2 Semantic lifting

For each transition, let \(S_i(x_{i-1},x_i)\) be the intended external semantic relation. A bridge assumption has the form

\[
B_i:\quad \mathrm{LocalValid}_i(F,\tau_i)=1
\Rightarrow S_i(x_{i-1},x_i).
\]

If all required \(B_i\) hold and their relational composition entails the target interpretation,

\[
S_1;S_2;\cdots;S_n\subseteq G_v,
\]

then:

\[
\mathrm{Supports}_{P}(e,c,v,\kappa)
\land\bigwedge_i B_i
\Rightarrow G_v(c,e).
\]

For a project that intends `Verified` to imply truth, it must additionally justify

\[
G_{\mathbf{Verified}}(c,e)\Rightarrow\mathrm{Truth}_{M}(c).
\]

This is a **relative, conditional guarantee**. P10-Core itself MUST NOT collapse these bridge assumptions into the internal axiom

\[
\mathrm{Supports}_{P}(e,c,\mathbf{Verified},\kappa)
\Rightarrow\mathrm{Truth}_{M}(c).
\]

Every published semantic claim MUST list the bridge assumptions on which it depends.

## 6. Determinism, replay, and immutability

For fixed canonical inputs and a bound environment, the mechanical layer MUST satisfy:

\[
D(F,c,e)=o_1\land D(F,c,e)=o_2\Rightarrow o_1=o_2,
\]

where \(o_1,o_2\in\mathcal O\) are typed outcomes.

Each run MUST produce a replay manifest containing all bound digests and declared nondeterministic inputs. If exact replay is impossible, the run MUST state the weaker reproducibility property actually tested.

A completed run is immutable. New evidence, corrected code, changed rules, or a different environment creates a new run with a new identifier. Later runs MAY supersede earlier ones but MUST preserve the earlier record.

## 7. Fail-closed requirements

The system MUST emit `ProtocolError`—and MUST NOT emit any claim verdict—when any of the following run-level conditions holds:

- a required digest, rule version, or environment binding is absent or mismatched;
- supplied evidence violates integrity or admissibility requirements;
- a mandatory transition certificate is absent or invalid;
- the decision procedure crashes, times out beyond the frozen limit, or returns an unrecognized value;
- two mandatory check results conflict and the frozen conflict rule does not resolve them;
- a typed interface, preservation invariant, or claim-fidelity contract fails.

`ProtocolError` has precedence over every claim verdict within the executed run. The evaluator MUST complete a preflight pass over all frozen bindings, schemas, canonical encodings, and supplied evidence before entering claim-verdict logic. A ratification failure is not a run-level `ProtocolError`; it belongs exclusively to `IssuanceOutcome`.

An unresolved external prerequisite or unavailable required source, in the absence of a procedural fault, MUST emit `Deferred`. A completed evaluation over admissible evidence that does not meet the affirmative threshold MUST emit `NotDemonstrated`. These cases MUST NOT be project-remapped into one another. No non-`Verified` outcome is evidence that the claim is false.

## 8. Certificate

Every supported verdict has a certificate

\[
\kappa=(h_F,h_C,h_E,h_R,h_D,h_{checker},h_{schema},h_{canon},
h_{env},Q,K,I,\Phi,w,v,t,a),
\]

where \(Q\) is the ordered set of transition and check results, \(K\) contains the frozen transition contracts, \(I\) the invariant witnesses, \(\Phi\) the claim-fidelity witnesses, \(w\) is the verdict-specific witness (including an early-terminal reason when applicable), \(t\) is timing metadata, and \(a\) records relevant agents/components.

An independent checker MUST be able to validate \(\kappa\) without trusting the producer that assembled it. The certificate language, parser, canonical encoding, and checker semantics MUST be versioned and bound by \(F\). Until those components are formally specified, P10-Core SHOULD be described as a certificate-carrying protocol, not equated without qualification with proof-carrying code.

Requiring two implementations is an optional engineering policy, not a theorem of P10-Core; any such policy MUST declare what “independent” means and which dependencies remain shared.

## 9. Minimal invariants

Any conforming implementation MUST preserve:

1. **Separation:** `Supports` is never serialized or described as an unqualified truth predicate.
2. **Certificate explicitness:** every `Supports` judgement identifies the exact certificate \(\kappa\) that carries it.
3. **Freeze integrity:** verdict-relevant inputs, checker, schemas, canonicalization, and environment are bound before evaluation; amendments create a new instance.
4. **Provenance closure:** every material output is traceable to admitted inputs and declared transformations.
5. **Outcome disjointness:** verdict-specific `Supports` constructors, `Deferred`, and `ProtocolError` cannot be substituted for one another.
6. **Completed-evaluation discipline:** `NotDemonstrated` requires evaluability, admissible evidence, successful mandatory checks, and a completed evaluation.
7. **Error precedence:** preflight protocol errors are resolved before claim-verdict logic.
8. **Typed composition:** every successful transition output inhabits the next transition's input type.
9. **Preservation:** every transition preserves its frozen invariant and claim-fidelity relation.
10. **Determinism:** fixed canonical inputs and bound environment yield the same typed run outcome.
11. **Fail-closed verification:** missing or invalid mandatory checks produce `ProtocolError` and cannot yield a claim verdict.
12. **Rule-checker soundness:** executable rule checks imply their independent declarative semantics.
13. **Certificate-checker soundness:** a successful `CheckCert` entails certificate-explicit declarative `Supports`, relative only to named checker assumptions.
14. **Verdict non-explosion:** failure to verify does not entail falsity.
15. **Issuance isolation:** ratification cannot mutate a completed run outcome.
16. **Ratification non-escalation:** a human cannot convert an unsupported result into a P10-Core verdict.
17. **Assumption visibility:** every semantic lifting claim exposes its bridge assumptions and trust boundary.
18. **Run immutability:** revisions and new evidence produce new, linked runs.
19. **Scope binding:** a verdict applies only to the frozen claim, evidence bundle, certificate, rules, environment, and run.

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
\mathrm{Supports}_{P^*}(e^*,
\text{“implementation }I\text{ version }z\text{ satisfies property }p
\text{ on domain }d\text{”},v,\kappa^*).
\]

It MUST NOT be generalized to “P10 is globally sound” or “all P10-Verified claims are true.” Shared dependencies between \(P^*\) and the target MUST be listed as part of the trust boundary.

### 10.1 Pre-registered failure conditions

At minimum, a self-audit fails its target if it produces any of the following:

1. `Verified` with a missing mandatory artifact or failed check;
2. different mechanical outcomes for identical canonical inputs and bound environment;
3. a certificate that does not commit to a verdict-relevant input;
4. acceptance of evidence excluded by the frozen admissibility policy;
5. an unrecorded post-freeze rule or threshold change;
6. a reported semantic guarantee whose bridge assumptions are absent;
7. an inability to distinguish `NotDemonstrated` from claim falsity in the serialized result;
8. `NotDemonstrated` after an incomplete evaluation, missing prerequisite, or failed mandatory check;
9. failure to distinguish an external deferral from an internal protocol error;
10. a locally accepted transition that violates its type, invariant, or claim-fidelity contract;
11. `CheckCert = true` for a certificate whose declarative `Supports` judgement is false;
12. a freeze record that does not bind the checker, schemas, or canonicalization;
13. a ratification failure that mutates or replaces the mechanical run outcome;
14. reliance on an opaque `A_rules` premise instead of proved rule-checker soundness.

Passing a finite adversarial suite establishes only the frozen test claim over that suite. It is not a proof that no counterexample exists outside the tested domain.

## 11. Reference evaluation algorithm

```text
preflight(P, c, e):
    require hashes_match(
        P.F,
        c, P.R, P.D,
        checker, schemas, canonicalizer, environment)
        else return ProtocolError(BindingMismatch)

    require parse_with_frozen_schemas(c, e)
        else return ProtocolError(SchemaFailure)

    require canonical_manifest(e) and verify_all_supplied_digests(e)
        else return ProtocolError(IntegrityFailure)

    require all_supplied_evidence_admissible(e, P.R_adm)
        else return ProtocolError(AdmissibilityViolation)

    return PreflightOK

evaluate(P, c, e):
    pf := preflight(P, c, e)
    if pf is ProtocolError(err):
        return ProtocolError(err)

    if not operationalizable(c, P.F):
        kappa := certificate(pf, reason = unfalsifiable)
        return Verdict(UnfalsifiableAsStated, kappa)

    if unresolved_required_prerequisite(c, e, P.F):
        kappa := certificate(pf, reason = external_blocker)
        return Verdict(Deferred, kappa)

    Q := run_mandatory_checks(P.F, c, e, P.R)

    if checker_crashed(Q) or invalid_output(Q):
        return ProtocolError(CheckerFailure)

    if missing_or_invalid_certificate(Q):
        return ProtocolError(CertificateFailure)

    if transition_contract_failed(Q):
        return ProtocolError(TransitionContractFailure)

    if unresolved_external_condition(Q):
        kappa := certificate(pf, Q, reason = external_blocker)
        return Verdict(Deferred, kappa)

    if verified_conditions_hold(Q, P.R_dec):
        kappa := certificate(pf, Q, witness = verified_conditions)
        return Verdict(Verified, kappa)

    require run_completed(Q) and all_evidence_admissible(Q)
        and all_mandatory_checks_succeeded(Q)
        else return ProtocolError(InconsistentRunState)

    kappa := certificate(pf, Q, witness = not_verified_conditions)
    return Verdict(NotDemonstrated, kappa)

ratify(run_outcome, h):
    require run_outcome is Verdict(v, kappa)
        else return RatificationError(NoVerdictToRatify)

    require ratifier_received_exact_certificate(h, kappa)
        else return RatificationError(CertificateMismatch)

    if H(h, kappa, accept):
        return Issued(v, kappa, h)

    return RejectedByRatifier(v, kappa, h)
```

The preflight-before-verdict order is normative. Every detectable binding, schema, canonicalization, integrity, and supplied-evidence admissibility error has precedence over every claim verdict. Project-specific subtypes MAY refine an outcome, but MUST NOT reclassify an internal failure as `Deferred` or `NotDemonstrated`, nor an unresolved external dependency as `NotDemonstrated`.

## 12. Conformance record

A conforming deployment publishes or archives:

- the serialized claim and freeze record;
- the evidence manifest and availability status of each artifact;
- rule, decision procedure, checker, schema, canonicalization, and environment versions/digests;
- the complete certificate and mechanical outcome;
- the separate issuance outcome and ratification record, or explicit absence of ratification;
- all bridge assumptions behind any semantic interpretation;
- known shared dependencies and trust boundaries;
- supersession links to earlier or later runs.

## 13. What remains open after v0.2.1

This draft intentionally leaves the following as explicit research or project parameters rather than hiding them inside `Verified`:

- the formal language used for claims and transition relations;
- the concrete syntax and semantics of the certificate language;
- mechanized proofs of parser, canonicalizer, and checker correctness;
- how bridge assumptions are justified or tested;
- whether evidence accumulation is monotone for a given verdict policy;
- conflict resolution between sources and checkers;
- quantitative assurance and correlated-failure models;
- the precise authority and accountability model for human ratification;
- mechanization in Lean, Coq, or another proof assistant;
- a compositional theorem for a concrete, fully instantiated P10 chain.

The next formal step is one deliberately synthetic Lean instance. A suitable seed claim is: “exactly four evidence entries satisfy predicate \(P\).” The instance SHOULD use three or four transitions, a minimal certificate datatype, and an abstract digest with an explicit injectivity assumption rather than a cryptographic implementation.

The first machine-checked target is only:

\[
\mathrm{CheckCert}(P,c,e,\kappa,v)=\mathrm{true}
\Rightarrow
\mathrm{Supports}_P(e,c,v,\kappa)
\]

for that fully instantiated frozen chain, with no `sorry` and no hidden axioms. The sole unproved premise SHOULD be digest injectivity, exposed as an explicit parameter rather than asserted inside the checker. The subsequent target is the conditional composition theorem

\[
\bigwedge_i\mathrm{LocalSound}_i
\land\bigwedge_i\mathrm{Fidelity}_i
\Rightarrow\mathrm{GlobalSupport}.
\]

Only after both targets are discharged should a P10-audit-P10 experiment be frozen.

## 14. Compact claim discipline

The strongest claim justified by a conforming P10-Core checker, relative to its declared checker assumptions, is:

> For the identified claim, evidence bundle, certificate, rules, decision procedure, checker, schemas, canonicalization, environment, and run, the independent certificate check succeeds and the frozen protocol yields the recorded verdict.

Any stronger statement—especially that the claim is true, that the protocol is globally sound, or that the verifier certifies its own reliability—requires separately stated external assumptions or evidence.
