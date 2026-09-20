# P10-Core / Audit Semantics v0.3 — S2 Specification

**Document Identifier:** `SPEC-P10-CORE-v0.3-S2`  
**Revision:** `draft-4-cleanup`  
**Status:** $\boxed{\textbf{S2 FREEZE CANDIDATE — READY FOR FRESH-CLONE FREEZE RUN}}$  
**Predecessor Lineage:**  
- Seed: `P10-Core-v0.1.0-four-evidence` (Commit: `da2683ba7bfc7a8f97d6c62506a6c2abd2f0b27a`)  
- Composition: `P10-Core-v0.2.2-gateclosure` (Commit: `419175726025f2586dbb65ad92ec8812628880b5`, Asset SHA-256: `96a7e126068d35d29776a785d6581ef07c12f66a52d4a850b8464bf96ac41c88`)  
- Empirical Audit: `P10-audit-P10-s1` (Commit: `1b8c8687be075c717086ddec6713f165cc8e05a6`, Verdict: `VerifiedWithLimitations`)  
- Post-Hoc Blind Concordance: `STRICT-v1` (MISMATCH, evidence-omission) & `STRICT-v2` (MATCH, Step-5 ambiguity identified)  

---

## 1. Executive Summary & Problem Formulation

The empirical execution and subsequent blind review of `P10-audit-P10-s1` established two critical findings:
1. **Blind Concordance on Target Instance:** A fresh verdict-blind evaluator (an independent instance of Claude, disclosing nominal model-family overlap with historical gates) derived the identical terminal verdict (`VerifiedWithLimitations`) when provided with an evidence-complete dossier (`STRICT-v2`).
2. **Residual Decision-Procedure Ambiguity:** The evaluator demonstrated that Step 5 ("Is admissible evidence incomplete or missing for any check?") admitted human discretion because the frozen protocol lacked:
   - A formal definition of *what constitutes an evidentiary check* (obligations vs. arbitrary artifact numbering);
   - A *total decision function* mapping every possible target failure to an explicit terminal branch;
   - A *formal limitation calculus* defining the exact allowable universe of non-blocking limitations for Step 6.

`P10-Core / Audit Semantics v0.3 — S2` specifies mechanisms intended to eliminate these three ambiguities. It transitions the audit protocol from an informal checklist interpreted by human or LLM reviewers into a **deterministic adjudication automaton**.

---

## 2. Formal Adjudicative Obligation Calculus & Witness Classification

In S1, internal evidence numbering (`EV-01`...`EV-14`) created an interpretive dilemma: does the absence of `EV-10` and `EV-14` constitute evidence insufficiency, even if all preregistered substantive checks are satisfied by other witnesses? Furthermore, defining completeness via "satisfaction" conflates *presence of evidence* with *substantive success* (e.g. evidence proving a build failure is complete, but violating).

S2 resolves this by decoupling completeness from file names, anchoring it strictly to **adjudicative obligations**, and formalizing a total witness classification layer with explicit checker-error handling.

### 2.1 The Generic Obligation Space $\mathcal{O}(P)$
Let $P$ be a frozen pre-registration protocol. The obligation space $\mathcal{O}(P)$ is a finite, enumerable set of typed requirements declared by $P$:

$$\mathcal{O}(P) = \{o_1, o_2, \dots, o_n\}$$

Every obligation $o \in \mathcal{O}(P)$ is a structured record:
$$o = \langle \text{id}, \text{scope}, \text{admissibility\_predicate}, \text{evaluator\_spec}, \text{failure\_tag} \rangle$$

### 2.2 Witness Classification Totality & CheckerError
Let $E$ be an evidence bundle. An evidentiary witness $w \in E$ is admissible for obligation $o$ only if it is cryptographically bound to the target identity:

$$\operatorname{AdmissibleWitness}(w, o, P) \iff \operatorname{BoundTo}(w, \operatorname{Identity}(P)) \land \operatorname{AdmissibilityPredicate}_o(w)$$

Let $\mathcal{W}_{\text{adm}}(E, o) = \{w \in E \mid \operatorname{AdmissibleWitness}(w, o, P)\}$.

For every admissible witness $w \in \mathcal{W}_{\text{adm}}(E, o)$, the frozen obligation evaluator yields a classification:

$$\operatorname{Classify}(w, o) \in \{\texttt{Satisfied}, \texttt{Violated}, \texttt{Blocked}, \texttt{CheckerError}\}$$

Totality of $\operatorname{Eval}(E, o)$ is achieved via strict, fail-closed precedence:

1. **Checker Fault:** If any admissible witness produces an execution error or internal classifier failure:
   $$\exists w \in \mathcal{W}_{\text{adm}}(E, o) \text{ s.t. } \operatorname{Classify}(w, o) = \texttt{CheckerError} \implies \operatorname{Eval}(E, o) = \texttt{CheckerError}$$
   *(Triggers $\operatorname{ProtocolError}(\texttt{checkerFailure})$)*.
2. **Substantive Violation Dominance:**
   $$\exists w \in \mathcal{W}_{\text{adm}}(E, o) \text{ s.t. } \operatorname{Classify}(w, o) = \texttt{Violated} \implies \operatorname{Eval}(E, o) = \texttt{Violated}$$
3. **Operational Blockage Dominance:**
   $$\neg (\exists w \text{ violating}) \land (\exists w \in \mathcal{W}_{\text{adm}}(E, o) \text{ s.t. } \operatorname{Classify}(w, o) = \texttt{Blocked}) \implies \operatorname{Eval}(E, o) = \texttt{Blocked}$$
4. **Unanimous Satisfaction:**
   $$\mathcal{W}_{\text{adm}}(E, o) \neq \emptyset \land (\forall w \in \mathcal{W}_{\text{adm}}(E, o), \operatorname{Classify}(w, o) = \texttt{Satisfied}) \implies \operatorname{Eval}(E, o) = \texttt{Satisfied}$$
5. **Missing Evidence:**
   $$\mathcal{W}_{\text{adm}}(E, o) = \emptyset \implies \operatorname{Eval}(E, o) = \texttt{Missing}$$

Thus, $\operatorname{Eval}(E, o) \in \{\texttt{Satisfied}, \texttt{Violated}, \texttt{Blocked}, \texttt{Missing}, \texttt{CheckerError}\}$ is uniquely and totally defined.

### 2.3 Definition of Obligation-Based Completeness
The predicate $\operatorname{EvidenceComplete}(P, E)$ asserts that no obligation lacks admissible evidence; it does not imply successful evaluation or substantive satisfaction:

$$\boxed{\operatorname{EvidenceComplete}(P, E) \iff \forall o \in \mathcal{O}(P), \operatorname{Eval}(E, o) \neq \texttt{Missing}}$$

This strictly preserves the tri-part epistemic demarcation:
$$\text{Missing evidence} \neq \text{checker failure} \neq \text{substantive violation}$$

**EvalVector Invariance Lemma for Completeness:**  
If two evidence bundles $E_1$ and $E_2$ yield identical obligation evaluation vectors:
$$\vec{\operatorname{Eval}}(P, E_1) = \vec{\operatorname{Eval}}(P, E_2) \implies \operatorname{EvidenceComplete}(P, E_1) = \operatorname{EvidenceComplete}(P, E_2)$$

---

## 3. Core Semantics vs. Domain Profile Separation

To prevent domain-specific validation categories from leaking into the universal protocol kernel, P10-S2 separates generic audit semantics from concrete execution profiles.

### 3.1 Generic P10-Core Layer
The core kernel provides:
- The finite obligation framework $\mathcal{O}(P)$, total $\operatorname{Classify}(w, o)$, and fail-closed $\operatorname{Eval}(E, o)$;
- The deterministic adjudication automaton $\operatorname{Next}(s)$;
- The unified terminal outcome space $\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$;
- The mechanized limitation registry $\mathcal{L}^*$ and admissible novel finding rules;
- The structured decision trace schema $\tau$.

### 3.2 Concrete Profile: `P10-Lean-SelfAudit-S2`
For Lean-based mathematical and software self-audits (such as `FourEvidence`), obligations are partitioned into six standardized profile classes:

$$\mathcal{O}(P) = \mathcal{O}_{\mathrm{integrity}} \cup \mathcal{O}_{\mathrm{build}} \cup \mathcal{O}_{\mathrm{axiom}} \cup \mathcal{O}_{\mathrm{carrier}} \cup \mathcal{O}_{\mathrm{demarcation}} \cup \mathcal{O}_{\mathrm{closure}}$$

Where:
- $\mathcal{O}_{\mathrm{integrity}}$: Git commit match, manifest continuity ($M(c) = 1$), baseline archive digest invariant ($H(\mathrm{base}) = h^*$).
- $\mathcal{O}_{\mathrm{build}}$: Toolchain version equality, zero exit code, compile-time evaluation ($\#\mathrm{eval} \to \mathrm{true}$).
- $\mathcal{O}_{\mathrm{axiom}}$: Kernel axiom transparency, empty axiom sets for designated theorems ($\operatorname{Axioms}(\theta) = \emptyset$).
- $\mathcal{O}_{\mathrm{carrier}}$: Verbatim textual presence of designated boundary statements ($B_1 \dots B_m$) in primary carrier documents.
- $\mathcal{O}_{\mathrm{demarcation}}$: Complete AST scan of target code confirming zero occurrences of forbidden symbols ($\mathrm{Truth}_M$, `sorry`, `admit`, user `axiom`).
- $\mathcal{O}_{\mathrm{closure}}$: External gate provenance closure and anti-circularity verification.

*Note:* Non-Lean audits (e.g. Battery ML, ENTSO-E power grid audits) instantiate distinct profile classes without modifying P10-Core semantics.

---

## 4. Total Decision Function & Adjudication Automaton

### 4.1 Exhaustive Target Decomposition & Subsumption of Failure Taxonomy
In S1, legacy failure conditions ($F_{01} \dots F_{08}$) existed as a parallel ad-hoc check mechanism. In S2, target criteria and failure conditions are unified through obligations:

1. Every target criterion $T_i$ is exhaustively decomposed into atomic obligations:
   $$T_i \mapsto \{o_{i1}, o_{i2}, \dots, o_{ik}\} \subseteq \mathcal{O}(P)$$
2. Every failure condition $F_j$ is defined strictly as a named projection over violated obligations:
   $$F_j := \{o \in \mathcal{O}(P) \mid \operatorname{Eval}(E, o) = \texttt{Violated} \land \operatorname{FailureTag}(o) = F_j\}$$

This eliminates duplicate evaluation engines: an F-condition fires if and only if at least one underlying obligation evaluates to $\texttt{Violated}$.

### 4.2 Unified Terminal Outcome Space $\Omega$
The terminal outcome space $\Omega$ unifies protocol halts with formal audit verdicts:

$$\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$$

Where:
$$\mathcal{V}^* = \{\texttt{Verified}, \texttt{VerifiedWithLimitations}, \texttt{NotVerified}, \texttt{NotDemonstrated}, \texttt{UnfalsifiableAsStated}, \texttt{Deferred}\}$$

### 4.3 The DecisionView Construct & Full Representation Invariance
The complete observational input to the adjudication automaton is formalized as a structured record:

$$\operatorname{DecisionView}(P, E) = \left\langle \begin{aligned}
&\text{protocol\_integrity} &:& \operatorname{Option}(\text{ProtocolFault}), \\
&\text{falsifiable} &:& \operatorname{Bool}, \\
&\text{obligation\_vector} &:& \mathcal{O}(P) \to \{\texttt{Satisfied}, \texttt{Violated}, \texttt{Blocked}, \texttt{Missing}, \texttt{CheckerError}\}, \\
&\text{limitation\_vector} &:& \mathcal{L}^* \to \operatorname{Bool}, \\
&\text{novel\_finding} &:& \operatorname{Option}(\text{AdmissibleNovelFinding})
\end{aligned} \right\rangle$$

**Representation Invariance Theorem:**  
The terminal adjudication outcome is uniquely determined by the `DecisionView`:

$$\boxed{\operatorname{DecisionView}(P, E_1) = \operatorname{DecisionView}(P, E_2) \implies \operatorname{Adjudicate}(P, E_1) = \operatorname{Adjudicate}(P, E_2)}$$

*(Note: $\vec{\operatorname{Eval}}$ equality alone guarantees only $\operatorname{EvidenceComplete}$ invariance; full adjudication invariance requires identity of the complete `DecisionView`).*

### 4.4 Automaton State Space and Totality
Let $\mathcal{S}$ be the state of the adjudication automaton:

$$\mathcal{S} = \langle \text{Phase}, \mathcal{O}_{\text{pending}}, \mathcal{F}_{\text{triggered}}, \mathcal{L}_{\text{active}} \rangle$$

**Totality Condition:**
For every reachable state $s \in \mathcal{S}$:
$$|\operatorname{Next}(s)| = 1$$
Every state transitions deterministically to exactly one successor state or one terminal outcome $\omega \in \Omega$.

```
                 [Start: Frozen (P, E)]
                           │
                           ▼
               [1. Protocol Integrity Check]
              /                             \
     Fault Detected                      No Fault
            │                                 │
            ▼                                 ▼
   HALT (ProtocolError)           [2. Substantive Violation Scan]
                                 /                               \
                  ∃ o: Eval(E,o) = Violated             ∀ o: Eval(E,o) ≠ Violated
                                │                                │
                                ▼                                ▼
                        Issue NotVerified             [3. Falsifiability Audit]
                                                     /                         \
                                              Unfalsifiable                Falsifiable
                                                    │                           │
                                                    ▼                           ▼
                                        Issue UnfalsifiableAsStated   [4. Operational Blocker Check]
                                                                     /                              \
                                                            ∃ o: Eval(E,o) = Blocked         ∀ o: Eval(E,o) ≠ Blocked
                                                                    │                                       │
                                                                    ▼                                       ▼
                                                              Issue Deferred             [5. Obligation Completeness]
                                                                                        /                            \
                                                                         ∃ o: Eval(E,o) = Missing          ∀ o: Eval(E,o) = Satisfied
                                                                                │                                    │
                                                                                ▼                                    ▼
                                                                      Issue NotDemonstrated          [6. Mechanized Limitation Calculus]
                                                                                                    /                                   \
                                                                               ∃ f: AdmissibleNovel(f)                   ∀ f: ¬AdmissibleNovel(f)
                                                                                            │                                       │
                                                                                            ▼                                       ▼
                                                                                    Issue Deferred                         [Step 6 Evaluation]
                                                                                                                          /                   \
                                                                                                               ∃ l: Applicable(l)      (∀ l: Applicable ⇒ NonBlocking)
                                                                                                               ∧ Blocking(l)            ∧ (∃ l: Applicable)
                                                                                                                      │                            │
                                                                                                                      ▼                            ▼
                                                                                                              Issue NotVerified      Issue VerifiedWithLimitations
                                                                                                                                                   │
                                                                                                                                         (Zero Applicable)
                                                                                                                                                   │
                                                                                                                                                   ▼
                                                                                                                                            Issue Verified
```

---

## 5. Mechanized Limitation Calculus & Admissible Novel Findings

### 5.1 The Preregistered Limitation Registry $\mathcal{L}^*$
The preregistration must enumerate the closed registry of known, permissible limitation classes:

$$\mathcal{L}^* = \{l_1, l_2, \dots, l_k\}$$

To eliminate evaluator subjectivity, every registered limitation $l \in \mathcal{L}^*$ is typed with an explicit applicability checker and evidence rule:
$$l = \langle \text{id}, \text{scope}, \text{applicability\_checker}, \text{severity}, \text{evidence\_rule} \rangle$$

Where:
$$\operatorname{Severity}(l) \in \{\texttt{NonBlocking}, \texttt{Blocking}\}$$
$$\operatorname{Applicable}(E, l) \in \{\texttt{True}, \texttt{False}\} \quad \text{(determined by frozen evaluator)}$$

### 5.2 Step 6 Adjudication Rule
Given that Steps 1–5 have passed:

1. **Pure Verification:**
   $$\forall l \in \mathcal{L}^*, \neg\operatorname{Applicable}(E, l) \implies \boxed{\mathcal{V}^* = \texttt{Verified}}$$
2. **Verification With Limitations:**
   $$(\exists l \in \mathcal{L}^*, \operatorname{Applicable}(E, l)) \land (\forall l \in \mathcal{L}^*, \operatorname{Applicable}(E, l) \implies \operatorname{Severity}(l) = \texttt{NonBlocking}) \implies \boxed{\mathcal{V}^* = \texttt{VerifiedWithLimitations}}$$
3. **Blocking Limitation Breach:**
   $$(\exists l \in \mathcal{L}^*, \operatorname{Applicable}(E, l) \land \operatorname{Severity}(l) = \texttt{Blocking}) \implies \boxed{\mathcal{V}^* = \texttt{NotVerified}}$$

### 5.3 Admissible Novel Findings Rule
To prevent "Deferred by mere assertion," an evaluator cannot stall issuance by raising arbitrary ungrounded claims. A novel finding $f$ alters the automaton flow if and only if it is admissible:

$$\operatorname{AdmissibleNovelFinding}(f, P, E) \iff \operatorname{ScopeRelevant}(f, P) \land \operatorname{AdmissibleWitness}(f, E) \land \operatorname{Uncataloged}(f, \mathcal{L}^*)$$

If $\exists f \text{ s.t. } \operatorname{AdmissibleNovelFinding}(f, P, E)$:
$$\boxed{\mathcal{V}^* = \texttt{Deferred}}$$

**Epistemic Demarcation on Discovery:**  
The disposition of an admissible declared novel finding is deterministic ($\texttt{Deferred}$); S2 does not claim completeness or reviewer-invariance of novel-finding discovery unless detection itself is fully mechanized. An evaluator has no discretion to unilaterally declare an unregistered finding "non-blocking."

---

## 6. Scope Finiteness for Self-Application Targets

To avoid conflating scope boundaries with transfinite logic, and to prevent cardinal conflation:

### 6.1 Decoupled Cardinalities
The protocol distinguishes between distinct structural dimensions:
- **$N_{\text{stage}} = 4$**: The number of bounded transition stages in the typed composition chain.
- **$N_{\text{evidence}} = 4$**: The cardinality of the Stage 0 synthetic evidence tuple (`FourEvidence`).

Future instances may scale $N_{\text{evidence}}$ or $N_{\text{stage}}$ independently without invalidating semantic types.

### 6.2 Target Constraints
1. **Origin Signature Grounding:**  
   The terminal theorem in the composition chain must conclude directly on the Stage 0 claim-evidence pair:
   $$\vdash \operatorname{VerifiedSem}(x_0.\text{claim}, x_0.\text{evidence})$$
   with $\operatorname{Axioms} = \emptyset$.
2. **Finite Stage Indexing:**  
   The theorem domain is explicitly indexed by a preregistered finite stage set:
   $$\text{Stage} := \operatorname{Fin}(N_{\text{stage}})$$
   No theorem in scope asserts closure under arbitrary or transfinite stage extension.
3. **Carrier Demarcation & Provenance Separation:**  
   Cryptographic signatures or hash witnesses verify the *authenticity and origin* of review records; semantic check rules verify that external verdicts are treated solely as input provenance evidence ($E^*$) and never as internal proofs of global soundness.

---

## 7. The Four S2 Infrastructure Doctrines

Derived directly from the procedural execution of S1 and the blind conformity trials:

1. **Canonical Identity Tuple Doctrine:**  
   Target and audit deliverables are identified by an immutable tuple:
   $$\operatorname{Identity} = \langle \text{Repository}, \text{CommitObjectID}, \text{ArtifactSHA256} \rangle$$
   The commit object ID binds the Git tree and history; the SHA-256 digest binds the distributed archive; tags and release names are mutable navigation aliases.
2. **Generated-Build Hygiene Doctrine:**  
   Regenerable build outputs (`.lake/`, `.olean`, `.c`, `.trace`) MUST NOT be treated as canonical source evidence and SHOULD be excluded from evidentiary repositories unless explicitly preregistered as target deliverables. Admissibility requires verifying clean-room rebuildability from pinned manifests and toolchain specifications.
3. **Blind Package Architecture Doctrine:**  
   A blind conformity bundle must be **outcome-redacted but obligation-complete with respect to the entire frozen target tuple $A^*$**, not merely its archive component. It must strictly exclude the *issued audit report*, *audit ratification record*, and summary PASS matrices to prevent verdict leakage. However, it MUST retain the complete target candidate tuple $A^*$ (including candidate documentation and target-level historical ratifications) and all execution traces necessary to evaluate every obligation in $\mathcal{O}(P)$.
4. **Comprehensive Machine-Readable Decision Trace Doctrine:**  
   Every audit execution must emit a structured `decision_trace.json` recording the complete path of the adjudication automaton:

   ```json
   {
     "protocol_id": "P10-AUDIT-P10-S2",
     "target_identity": {
       "repo": "VolMax-Studio/p10-core",
       "commit": "419175726025f2586dbb65ad92ec8812628880b5",
       "asset_sha256": "96a7e126068d35d29776a785d6581ef07c12f66a52d4a850b8464bf96ac41c88"
     },
     "protocol_integrity": {"status": "PASS", "faults_detected": []},
     "claim_falsifiability": {"status": "FALSIFIABLE"},
     "obligations": [
       {
         "id": "O_BUILD_01",
         "checker_id": "lake_build_v1",
         "evidence_hashes": ["f81cb8dd..."],
         "eval_status": "Satisfied",
         "reason_code": "RC_ZERO_EXIT"
       }
     ],
     "failures": [],
     "blockers": [],
     "limitations": [
       {
         "id": "L_HORIZON_N4",
         "registered_severity": "NonBlocking",
         "applicable": true,
         "evidence_witness": "README.md:189"
       }
     ],
     "novel_findings": [],
     "precedence_path": ["Step1_Integrity", "Step2_Failures", "Step3_Falsifiability", "Step4_Blockers", "Step5_Completeness", "Step6_Limitations"],
     "terminal_outcome": "VerifiedWithLimitations"
   }
   ```

---

## 8. Lean 4 Verification Targets (Pre-Freeze Mandate)

Prior to freezing the S2 protocol specification, the core adjudication automaton must be modeled in Lean 4 and mechanically verified against the following four meta-theorems:

1. **Totality & Determinism:**
   $$\forall s \in \mathcal{S}, \exists! \omega \in \Omega \text{ s.t. } \operatorname{Adjudicate}(s) = \omega$$
2. **Demarcation Soundness:**
   $$\operatorname{EvalStatus} = \texttt{Missing} \not\implies \texttt{NotVerified}$$
   $$\operatorname{EvalStatus} = \texttt{Violated} \not\implies \texttt{NotDemonstrated}$$
3. **DecisionView Representation Invariance:**
   $$\operatorname{DecisionView}(P, E_1) = \operatorname{DecisionView}(P, E_2) \implies \operatorname{Adjudicate}(P, E_1) = \operatorname{Adjudicate}(P, E_2)$$
4. **Adversarial Reference Conformance Verification:**
   Exhaustive test evaluation across all permutations of $\{\texttt{Satisfied}, \texttt{Violated}, \texttt{Blocked}, \texttt{Missing}, \texttt{CheckerError}\}$:
   - $5^4 = 625$ obligation vectors verified against the frozen reference conformance oracle (proven by `rfl` in `AutomatonSoundness.lean`);
   - $80,000$ complete bounded $\operatorname{DecisionView}$ state space permutations verified against the reference conformance oracle. This evaluation is an **exhaustive bounded conformance evaluation** over the current bounded 4-obligation $\operatorname{DecisionView}$ representation with current Boolean and aggregate fields (not an unbounded proof of all possible future P10 profiles).

---

## 9. Formalization Boundary & Trusted External Layer

**Frozen Scope:**  
The machine-checked S2 witness-aggregation and adjudication semantics at the bound commit. The freeze does not assert correctness of external evidence acquisition, cryptographic implementations, network sources, or domain-specific empirical checkers beyond their separately recorded execution evidence.

**Epistemic Boundary Statement:**  
The Lean formalization mathematically certifies:
1. The deterministic witness aggregation logic over abstract `WitnessClass` vectors;
2. The total adjudication automaton $\operatorname{Next}(s)$ and precedence ladder over abstract `DecisionView` records;
3. Demarcation soundness ensuring `Missing` never collapses into `NotVerified` and `Violated` never collapses into `NotDemonstrated`.

Correctness of raw evidence acquisition from operating system filesystems, cryptographic hashing of external disk archives, network fetch validation, domain-specific admissibility predicates, and execution of empirical binary checkers remains outside this Lean theorem boundary and is governed by the frozen profile specification, cryptographic manifests, and execution evidence logs.
