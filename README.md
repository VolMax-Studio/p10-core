# P10-Core — A Certificate-Carrying Verification Protocol with Explicit Trust Boundaries

<p align="center">
  <img src="assets/p10_core_banner.png" alt="P10-Core Verification Protocol" width="100%">
</p>

**Current Milestone:** `P10-Core v0.3.0 — S2 Semantic Core`  
**Current Frozen Tag:** [`v0.3.0-s2-freeze`](https://github.com/VolMax-Studio/p10-core/tree/v0.3.0-s2-freeze)  
**Frozen Semantic Commit:** `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`  
**Status:** $\boxed{\textbf{PUBLIC / FROZEN}}$  
**Author:** VolMax Studio Lab / Nestorov, Ivan (ORCID: [`0009-0006-7940-9539`](https://orcid.org/0009-0006-7940-9539))  
**Contributors:** Ivan Nestorov, Sol, Astra, Ananke  
**Toolchain:** Lean 4.34.0 (`leanprover/lean4:v4.34.0`), Lake 5.0.0  
**License:** Apache 2.0  
**Predecessor Milestones:** `v0.2.2-gateclosure`, `v0.2.1-gatefix`, `v0.2.0-composition`, `v0.1.0-four-evidence`  

---

## 1. Overview & Milestone Lineage

**P10-Core** is a formal, certificate-carrying verification protocol designed to adjudicate empirical and operational claims under pre-registered, immutable evidentiary rules.

Rather than acting as an ungrounded or autonomous "truth machine," P10-Core formalizes the strict mathematical demarcation between ontological truth and evidentiary support:

$$\mathrm{Truth}_M(c) \neq \mathrm{Supports}_P(e, c, \kappa, v)$$

A positive verification indicates that an admissible evidence bundle $e$, evaluated under frozen protocol rules $P$, deterministically yields certificate $\kappa$ supporting verdict $v$. When evidence is insufficient, the protocol does not declare falsehood; it strictly and soundly outputs `NotDemonstrated`.

### Milestone Lineage:
- **v0.1 — FourEvidence Seed (`v0.1.0-four-evidence`):** Fully verified, synthetic `FourEvidence` instance establishing executable checker soundness against a declarative calculus.
- **v0.2 — Bounded Composition & Gate Closure (`v0.2.2-gateclosure`):** Bounded four-stage transition chain with machine-checked local soundness, agreement, and gate closure (subject of empirical audit [`P10-audit-P10-s1`](https://github.com/VolMax-Studio/p10-audit-p10-s1)).
- **v0.3 — Deterministic S2 Adjudication Semantics (`v0.3.0-s2-freeze`):** **Current frozen semantic core.** Machine-checked witness aggregation, total `DecisionView` adjudication automaton, fail-closed precedence, and demarcation soundness (`Missing ≠ CheckerError ≠ Violated`).

### Relationship Between Protocol Core and Audit Evidence Repositories:
- **`p10-core` = What P10 is:** The specification, formal model, mechanized proofs, and reference semantics of the P10 protocol family.
- **`p10-audit-p10-s1` = Empirical audit evidence:** A separate, historically sealed repository containing the pre-registration, execution traces (`run-001`), and final ratification of an empirical audit conducted on `p10-core` at `v0.2.2-gateclosure`.
- The empirical lessons from S1 (eliminating Step 5 human interpretive discretion, formalizing witness classification, separating checker failures from substantive violations, and mechanizing the limitation calculus) directly informed the design of **S2** in `p10-core`.
- Future empirical audits of S2 will be instantiated in dedicated audit repositories (e.g. `p10-audit-p10-s2`) targeting the frozen `p10-core@fa7878a...` commit.

> **Frozen Scope (v0.3.0):** The machine-checked S2 witness-aggregation and adjudication semantics at commit `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`. The freeze does not assert correctness of external evidence acquisition, cryptographic implementations, network sources, or domain-specific empirical checkers beyond their separately recorded execution evidence.

---

## 2. Formal Architecture

P10-Core formalizes the assurance process as an explicit tuple:

$$\mathbf{P10} = (C, E, R, F, \mathcal{V}, D, H)$$

where:
- **$C$ (Claim):** The proposition under audit;
- **$E$ (Evidence Bundle):** The external, hashed input dataset;
- **$R$ (Rules):** The formal admissibility and semantic transformation rules;
- **$F$ (Frozen Protocol):** The pre-registered cryptographic commitment;
- **$\mathcal{V}$ (Verdicts):** The discrete, mutually disjoint verdict type.
  For the current S2 semantic core:
  $$\mathcal{V}^* = \{\texttt{Verified}, \texttt{VerifiedWithLimitations}, \texttt{NotVerified}, \texttt{NotDemonstrated}, \texttt{UnfalsifiableAsStated}, \texttt{Deferred}\}$$
  *(Note: The legacy v0.2 `P10Core.Spec.Verdict` remains unchanged for predecessor compatibility; S2 introduces its own `S2Verdict` type in the adjudication layer [`P10Core.Model.AdjudicationAutomaton`](P10Core/Model/AdjudicationAutomaton.lean)).*
- **$D$ (Decision Procedure):** The computable function mapping inputs to a run outcome:
  $$\mathrm{RunOutcome} = \mathrm{Verdict}(v, \kappa) \uplus \mathrm{ProtocolError}(\epsilon, \rho)$$
  In S2, this is unified under the total outcome space:
  $$\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$$
- **$H$ (Human Ratification):** The terminal socio-technical act separating mechanical execution from binding legal/institutional issuance:
  $$\mathrm{IssuanceOutcome} = \mathrm{Issued} \uplus \mathrm{RejectedByRatifier} \uplus \mathrm{RatificationError}$$

---

## 3. The Mechanized Layers

### Layer 1: The Frozen Checker Seed (`FourEvidence`)
*Mechanized in [`P10Core/Proofs/FourEvidence.lean`](P10Core/Proofs/FourEvidence.lean) (Immutable baseline from `v0.1.0`)*:

- **Checker Soundness (Core Theorem):**
  ```lean
  theorem checkCert_sound
      (D : DigestModel) (P : Protocol) (c : Claim) (e : Evidence)
      (κ : Certificate) (v : Verdict)
      (hcheck : CheckCert D P c e κ v = true) :
      Supports (semantics P) e c κ v
  ```
- **Semantic Alignment Invariants & Disjointness:**
  - `supports_verified_implies_conditions`
  - `supports_notDemonstrated_implies_not_conditions`
  - `supports_deferred_implies_external_blocker`
  - `verified_not_notDemonstrated` (mathematically forbids simultaneous verification and non-demonstration without axioms).

---

### Layer 2: The Bounded Composition Layer (`v0.2.1-gatefix`)
*Mechanized in [`P10Core/Proofs/Composition.lean`](P10Core/Proofs/Composition.lean), [`P10Core/Instances/FourEvidence/Composition.lean`](P10Core/Instances/FourEvidence/Composition.lean), and [`P10Core/Proofs/PositiveWitness.lean`](P10Core/Proofs/PositiveWitness.lean)*:

#### 1. Typed Multi-Stage Pipeline
The concrete execution pipeline transitions through four typed stages:

```text
Stage0 (claim, evidence)
  -- T1: formalize -->
Stage1 (claim, evidence, target)
  -- T2: inspectTarget(target, evidence) -->
Stage2 (claim, evidence, target-bound checked result)
  -- T3: certificate commits to Stage2 -->
Stage3 (claim, evidence, target, checked, κ, verdict)
  -- unchanged CheckCert -->
Supports (semantics P) e c κ v
```

Each transition $T_i$ enforces:
- An executable local checker (`check1`, `check2`, `check3`);
- A semantic preservation relation (`AgreementRel1`, `AgreementRel2`, `AgreementRel3`);
- A claim/evidence fidelity relation (`FidelityRel1`, `FidelityRel2`, `FidelityRel3`);
- A witness-bearing transition certificate (`TransitionCertificate1`, `TransitionCertificate2`, `TransitionCertificate3`).  
  *G-07 Disclosure:* Certificate witnesses (`targetWitness`, `checkedWitness`, `certificateWitness`) **gate acceptance and bind the certificate to the stage it certifies** (`check = false` upon mismatch); they serve as structural guards rather than redundant semantic premises in theorem conclusions.

#### 2. Local Soundness & Fidelity Obligations
All six local obligations are machine-checked:
- `localSound1`, `localSound2`, `localSound3`
- `fidelity1`, `fidelity2`, `fidelity3`
- `compositionObligations`: Proves the conjunction $\mathrm{CompositionObligations}(D, P)$ for this instance without opaque assumptions.

#### 3. The Composition Theorems
- **Conditional Composition:**
  ```lean
  theorem conditionalComposition
      (D : DigestModel) (P : Protocol)
      (τ1 : Option TransitionCertificate1) (τ2 : Option TransitionCertificate2) (τ3 : Option TransitionCertificate3)
      (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
      (hObligations : CompositionObligations D P)
      (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
      GlobalSupport P x0 x1 x2 x3
  ```
  *(Kernel report: depends on **zero axioms**).*
- **Fully Discharged Instance:**
  ```lean
  theorem fourEvidenceComposes
      (D : DigestModel) (P : Protocol)
      (τ1 : Option TransitionCertificate1) (τ2 : Option TransitionCertificate2) (τ3 : Option TransitionCertificate3)
      (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
      (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
      GlobalSupport P x0 x1 x2 x3
  ```
- **Terminal Protocol Support & Origin Conditions (Promoted Theorem):**
  ```lean
  theorem verifiedGlobalSupport_implies_originConditions
      (P : Protocol) (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
      (h : GlobalSupport P x0 x1 x2 x3) (hv : x3.verdict = Verdict.verified) :
      verifiedSem (x0.claim, x0.evidence)
  ```
  *(Kernel report: depends on **zero axioms**).*  
  When a composed pipeline legitimately concludes with `Verified`, the empirical condition `verifiedSem` is mathematically guaranteed to hold on **Stage 0's original claim and evidence**.
- **Epistemic Meaning of `GlobalSupport` (G-05 Disclosure):**  
  `GlobalSupport` means that the protocol adjudication procedure has executed soundly and is fully justified under the frozen rules for the given verdict. It does **not** assert that the claim is verified: `GlobalSupport` legitimately and soundly holds when the verdict is `NotDemonstrated`, `UnfalsifiableAsStated`, or `Deferred`. The protocol contains **no $\mathrm{Truth}_M$ predicate**.

#### 4. Adversarial Non-Composition Theorems
Negative theorems are rigorously strengthened to directly refute `Composable`:
- **`missingCertificate1CannotCompose`:** If transition certificate 1 is missing, $\neg\mathrm{Composable}$.
- **`missingCertificate2CannotCompose`:** If transition certificate 2 is missing, $\neg\mathrm{Composable}$.
- **`missingCertificate3CannotCompose`:** If transition certificate 3 is missing, $\neg\mathrm{Composable}$.
- **`failedAgreementCannotCompose`:** If intermediate agreement $\neg\mathrm{AgreementRel2}$ fails, $\neg\mathrm{Composable}$.
- **`brokenFidelityCannotCompose`:** If claim/evidence fidelity $\neg\mathrm{FidelityRel3}$ is broken, $\neg\mathrm{Composable}$.

#### 5. Concrete Inhabitation & Non-Vacuity Witnesses
- **`concreteDigestModel`:** Inhabited model with proven injectivity (`fun {e1 e2} h => by cases h; rfl`).  
  *G-01 Disclosure:* The synthetic `Digest` structure is a lossless representation (`evidence : Evidence`) demonstrating mathematical non-vacuity and inhabitation; it does **not** model cryptographic hash compression or collision resistance.
- **`positiveComposable`:** Explicit constructive term satisfying `Composable` (depends on **zero axioms**).
- **`positiveGlobalSupport`:** Discharged global support witness.
- **Three Executable Checks:** `#eval check1`, `#eval check2`, `#eval check3` all evaluate to `true` at compile time.

#### 6. Synthetic Instance Disclosure (G-04)
The `FourEvidence` formalization is a **synthetic bounded instance** designed to establish mathematical checker-soundness and composition, rather than a full empirical instantiation of all generic P10 predicates:
- `runCompleted := fun _ _ => True` and `checksSucceeded := fun _ _ => True` are trivially satisfied.
- `evaluable` and `operationalizable` coincide (`fun c => c.operationalizable`).
- `noProtocolFault c e := e.admissible = true` is implied by the preflight check.

---

### Layer 3: Deterministic S2 Adjudication Automaton (`v0.3.0-s2-freeze`)
*Mechanized in [`P10Core/Model/AdjudicationAutomaton.lean`](P10Core/Model/AdjudicationAutomaton.lean) and [`P10Core/Proofs/AutomatonSoundness.lean`](P10Core/Proofs/AutomatonSoundness.lean)*:

#### 1. Total Witness Classification & Fail-Closed Aggregation
- **Four-Valued Witness Class:** `satisfied | violated | blocked | checkerError`.
- **Five-Valued Obligation Status:** `satisfied | violated | blocked | missing | checkerError`.
- **Aggregation Precedence:**
  $$\texttt{CheckerError} \succ \texttt{Violated} \succ \texttt{Blocked} \succ \texttt{Satisfied} \succ \texttt{Missing}$$
  Admissible witness classifications are aggregated deterministically: empty admissible set yields `Missing`, any checker fault triggers fail-closed `ProtocolError(checkerFailure)`, and substantive violation strictly dominates blockers and satisfactions.

#### 2. Total Adjudication Automaton over `DecisionView`
- **Full Observational Input (`DecisionView`):** Structured record encoding protocol integrity status, claim falsifiability, obligation evaluation vector, limitation registry vector, and admissible novel findings.
- **Terminal Outcome Space $\Omega$:**
  $$\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$$
  where $\mathcal{V}^* = \{\texttt{Verified}, \texttt{VerifiedWithLimitations}, \texttt{NotVerified}, \texttt{NotDemonstrated}, \texttt{UnfalsifiableAsStated}, \texttt{Deferred}\}$.
- **Pure Decision Function:** `adjudicate (dv : DecisionView) : TerminalOutcome` is total, unique, and strictly deterministic ($|\operatorname{Next}(s)| = 1$).

#### 3. Formal Demarcation Theorems (All Axiom-Free)
- **`missing_not_notVerified`:** Proves `Missing` evidence never collapses into `NotVerified`.
- **`violated_not_notDemonstrated`:** Proves substantive violation never collapses into `NotDemonstrated`.
- **`evalVector_completeness_invariance`:** Completeness depends solely on absence of `Missing` obligations.
- **`decisionView_representation_invariance`:** Evaluator representation invariance holds over the full `DecisionView`.

#### 4. Adversarial Reference Oracle Conformance
- **`corpus625_oracle_conformity`:** All $5^4 = 625$ adversarial obligation permutations verified against the reference oracle, proven by Lean 4 kernel reflection (`by rfl`).
- **Exhaustive Bounded Conformance Evaluation:** All 80,000 bounded `DecisionView` states evaluated at compile-time (`#eval fullDecisionViewSpace.all ...`), confirming complete conformance against `oracleAdjudicate`.

---

## 4. Trust Boundaries & Axiom Audit

This repository adheres to the fundamental P10 principle: **never hide trust—explicitly bound and name it.**

As audited in [`AXIOM_AUDIT.md`](AXIOM_AUDIT.md) and [`S2_FREEZE_RECORD.md`](S2_FREEZE_RECORD.md):
- **Zero `sorry` / zero `admit`:** Scanned across the entire codebase.
- **Zero user-declared `axiom`:** No custom axioms exist in the Lean environment.
- **S2 Automaton Soundness:** All 17 theorems in `P10Core.Proofs.AutomatonSoundness` depend on **zero axioms** (`[]`).
- **Kernel Axiom Report:**
  ```text
  'P10Core.Proofs.Composition.conditionalComposition' does not depend on any axioms
  'P10Core.Proofs.Composition.verifiedGlobalSupport_implies_originConditions' does not depend on any axioms
  'P10Core.Proofs.PositiveWitness.positiveComposable' does not depend on any axioms
  'P10Core.Proofs.FourEvidence.checkCert_sound' depends on axioms: [propext, Quot.sound]
  'P10Core.Proofs.Composition.fourEvidenceComposes' depends on axioms: [propext, Quot.sound]
  'P10Core.Proofs.PositiveWitness.positiveGlobalSupport' depends on axioms: [propext, Quot.sound]
  ```
  `propext` (propositional extensionality) and `Quot.sound` (quotient soundness) are standard foundational axioms of Lean 4.

---

## 5. Explicit Epistemic Boundaries (What is NOT Claimed)

To prevent overclaims and maintain strict scientific hygiene:
1. **No Claim of Ontological Truth:** Verifying composition proves that the transition chain faithfully preserves agreements and fidelity down to `Supports`; it does not prove physical truth outside the specified bridge assumptions ($B_i$).
2. **No Global P10 Soundness:** Proved for the bounded `FourEvidence` multi-stage pipeline and the bounded S2 automaton, not as a universal metatheorem over arbitrary untyped programs.
3. **No Cryptographic Collision Resistance:** Evidence digests remain in the abstract model.
4. **No Verification of External Acquisition:** Lean certifies the mathematical adjudication logic over abstract records; correctness of operating system I/O, hash binaries, network fetching, and empirical checkers remains outside the formal verification boundary.

---

## 6. Repository Structure

```text
p10-core/
├── assets/
│   └── p10_core_banner.png        # Official project banner
├── audit/
│   └── AxiomAudit.lean            # Standalone kernel axiom audit harness
├── baselines/
│   ├── P10-Core-v0.2.0-composition.zip        # Frozen predecessor snapshot
│   └── P10-Core-v0.2.0-composition.zip.sha256 # Predecessor checksum
├── manifests/
│   ├── SHA256SUMS_v0.2.0-composition          # Predecessor file manifest
│   ├── SHA256SUMS_v0.2.1-gatefix              # Predecessor file manifest
│   └── SHA256SUMS_v0.2.2-gateclosure          # v0.2.2 gate closure manifest
├── reviews/
│   └── GATE_v0.2.0-composition_CLAUDE_001.md  # Original adversarial gate report
├── scripts/
│   └── verify.sh                  # Clean-room build, axiom audit & checksum verification
├── spec/
│   ├── P10-Core-v0.1.md           # v0.1 specification
│   ├── P10-Core-v0.2.md           # v0.2 specification
│   ├── P10-Core-v0.2.1.md         # v0.2.1 specification
│   └── P10-Core-v0.3-S2-Semantics.md # Current v0.3 S2 specification
├── AXIOM_AUDIT.md                 # Complete kernel trust boundary audit
├── GATE_CLOSURE.md                # Gate 002 remediation & closure audit
├── GATE_RESPONSE.md               # Point-by-point response to Gate 001 findings
├── RATIFICATION.md                # Formal human ratification record of v0.2.2
├── S2_FREEZE_MANIFEST.sha256      # Frozen S2 artifact checksum manifest (44 files)
├── S2_FREEZE_RECORD.md            # Sealed S2 clean-room freeze record
├── README.md                      # Primary project documentation
├── lakefile.toml                  # Lake package definition
├── lake-manifest.json             # Pinned package dependencies
├── lean-toolchain                 # Pinned Lean toolchain (v4.34.0)
├── P10Core.lean                   # Top-level module import
└── P10Core/
    ├── Spec/
    │   └── Core.lean              # Core P10 data types and legacy v0.2 verdict definitions
    ├── Model/
    │   ├── Calculus.lean          # Declarative Supports calculus
    │   ├── Rules.lean             # Rule definitions and soundness interfaces
    │   └── AdjudicationAutomaton.lean # v0.3 S2 witness aggregation & adjudication automaton
    ├── Instances/
    │   └── FourEvidence/
    │       ├── Model.lean         # Concrete instance & inhabited DigestModel
    │       ├── Checker.lean       # Executable certificate checker
    │       └── Composition.lean   # Multi-stage typed chain, agreements & fidelity
    └── Proofs/
        ├── FourEvidence.lean      # Kernel-checked checker soundness & disjointness
        ├── Composition.lean       # Conditional & discharged composition theorems
        ├── PositiveWitness.lean   # Positive constructive witnesses & #eval checks
        └── AutomatonSoundness.lean # v0.3 S2 automaton soundness, demarcation & oracles
```

---

## 7. Clean-Room Reproduction

To verify and recompile the entire formalization from source using Lean 4.34.0:

```bash
# Automated clean-room verification (build, checks, axiom scan, checksums):
./scripts/verify.sh

# Or manual Lake build:
lake build
```
