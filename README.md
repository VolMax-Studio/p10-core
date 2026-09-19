# P10-Core — A Certificate-Carrying Verification Protocol with Explicit Trust Boundaries

<p align="center">
  <img src="assets/p10_core_banner.png" alt="P10-Core Verification Protocol" width="100%">
</p>

**Milestone:** `P10-Core / Composition Layer (v0.2.1-gatefix) — Machine-Checked Composition & Gate Remediation`  
**Release Tag:** `v0.2.1-gatefix` (Predecessors: `v0.2.0-composition`, `v0.1.0-four-evidence`)  
**Author:** VolMax Studio Lab / Nestorov, Ivan (ORCID: [`0009-0006-7940-9539`](https://orcid.org/0009-0006-7940-9539))  
**Contributors:** Ivan Nestorov, Sol, Astra, Ananke  
**Toolchain:** Lean 4.34.0 (`leanprover/lean4:v4.34.0`), Lake 5.0.0  
**License:** Apache 2.0  
**Gate Status:** **SPREMNO ZA PONOVNI GEJT** (Adversarial Gate 002)  

---

## 1. Overview

**P10-Core** is a formal, certificate-carrying verification protocol designed to adjudicate empirical and operational claims under pre-registered, immutable evidentiary rules.

Rather than acting as an ungrounded or autonomous "truth machine," P10-Core formalizes the strict mathematical demarcation between ontological truth and evidentiary support:

$$\mathrm{Truth}_M(c) \neq \mathrm{Supports}_P(e, c, \kappa, v)$$

A positive verification indicates that an admissible evidence bundle $e$, evaluated under frozen protocol rules $P$, deterministically yields certificate $\kappa$ supporting verdict $v$. When evidence is insufficient, the protocol does not declare falsehood; it strictly and soundly outputs `NotDemonstrated`.

This repository contains:
1. **The Frozen Seed (`v0.1.0-four-evidence`):** A fully verified, synthetic `FourEvidence` instance establishing executable checker soundness against a declarative calculus.
2. **The Composition Layer (`v0.2.1-gatefix`):** A bounded, typed four-stage transition chain with machine-checked local soundness, agreement, and fidelity obligations, completely remediated against adversarial gate findings (C-01 through C-11).

---

## 2. Formal Architecture

P10-Core formalizes the assurance process as an explicit tuple:

$$\mathbf{P10} = (C, E, R, F, \mathcal{V}, D, H)$$

where:
- **$C$ (Claim):** The proposition under audit;
- **$E$ (Evidence Bundle):** The external, hashed input dataset;
- **$R$ (Rules):** The formal admissibility and semantic transformation rules;
- **$F$ (Frozen Protocol):** The pre-registered cryptographic commitment;
- **$\mathcal{V}$ (Verdicts):** The discrete, mutually disjoint verdict type:
  $$\mathcal{V} = \{\texttt{verified}, \texttt{notDemonstrated}, \texttt{unfalsifiableAsStated}, \texttt{deferred}\}$$
- **$D$ (Decision Procedure):** The computable function mapping inputs to a run outcome:
  $$\mathrm{RunOutcome} = \mathrm{Verdict}(v, \kappa) \uplus \mathrm{ProtocolError}(\epsilon, \rho)$$
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
- A witness-bearing transition certificate (`TransitionCertificate1`, `TransitionCertificate2`, `TransitionCertificate3`) carrying concrete witnesses (`targetWitness`, `checkedWitness`, `certificateWitness`), completely eliminating inert boolean flags.

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
      (τ1 : TransitionCertificate1) (τ2 : TransitionCertificate2) (τ3 : TransitionCertificate3)
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
      (τ1 : TransitionCertificate1) (τ2 : TransitionCertificate2) (τ3 : TransitionCertificate3)
      (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
      (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
      GlobalSupport P x0 x1 x2 x3
  ```
- **Terminal Protocol Support:**
  `GlobalSupport.protocolSupport` extracts the exact declarative $\mathrm{Supports}$ judgement. It contains **no $\mathrm{Truth}_M$ predicate** and makes no claim of metaphysical truth.

#### 4. Adversarial Non-Composition Theorems
Negative theorems are rigorously strengthened to directly refute `Composable`:
- **`missingCertificate1CannotCompose`:** If transition certificate 1 is missing, $\neg\mathrm{Composable}$.
- **`missingCertificate2CannotCompose`:** If transition certificate 2 is missing, $\neg\mathrm{Composable}$.
- **`missingCertificate3CannotCompose`:** If transition certificate 3 is missing, $\neg\mathrm{Composable}$.
- **`failedAgreementCannotCompose`:** If intermediate agreement $\neg\mathrm{AgreementRel2}$ fails, $\neg\mathrm{Composable}$.
- **`brokenFidelityCannotCompose`:** If claim/evidence fidelity $\neg\mathrm{FidelityRel3}$ is broken, $\neg\mathrm{Composable}$.

#### 5. Concrete Inhabitation & Positive Executable Witnesses
To definitively refute vacuous truth:
- **`concreteDigestModel`:** Inhabited model with proven injectivity (`fun {e1 e2} h => by cases h; rfl`).
- **`positiveComposable`:** Explicit constructive term satisfying `Composable` (depends on **0 axioms**).
- **`positiveGlobalSupport`:** Discharged global support witness.
- **Three Executable Checks:** `#eval check1`, `#eval check2`, `#eval check3` all evaluate to `true` at compile time.

---

## 4. Trust Boundaries & Axiom Audit

This repository adheres to the fundamental P10 principle: **never hide trust—explicitly bound and name it.**

As audited in [`AXIOM_AUDIT.md`](AXIOM_AUDIT.md):
- **Zero `sorry` / zero `admit`:** Scanned across the entire codebase.
- **Zero user-declared `axiom`:** No custom axioms exist in the Lean environment.
- **Kernel Axiom Report:**
  ```text
  'P10Core.Proofs.Composition.conditionalComposition' does not depend on any axioms
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
2. **No Global P10 Soundness:** Proved for the bounded `FourEvidence` multi-stage pipeline, not as a universal metatheorem over arbitrary untyped programs.
3. **No Cryptographic Collision Resistance:** Evidence digests remain in the abstract model.
4. **No Unbounded Composition:** The composition theorem covers the specified finite 4-stage chain; unbounded transfinite progressions are explicitly bounded by Gödel/Löb limitative results.

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
│   └── SHA256SUMS_v0.2.1-gatefix              # Current release manifest (22 files)
├── reviews/
│   └── GATE_v0.2.0-composition_CLAUDE_001.md  # Original adversarial gate report
├── scripts/
│   └── verify.sh                  # Clean-room build, axiom audit & checksum verification
├── AXIOM_AUDIT.md                 # Complete kernel trust boundary audit
├── GATE_RESPONSE.md               # Point-by-point response to Gate 001 findings
├── RELEASE_NOTES.md               # v0.2.1 release notes
├── README.md                      # Primary project documentation
├── lakefile.toml                  # Lake package definition
├── lake-manifest.json             # Pinned package dependencies
├── lean-toolchain                 # Pinned Lean toolchain (v4.34.0)
├── P10Core.lean                   # Top-level module import
└── P10Core/
    ├── Spec/
    │   └── Core.lean              # Core P10 data types and verdict definitions
    ├── Model/
    │   ├── Calculus.lean          # Declarative Supports calculus
    │   └── Rules.lean             # Rule definitions and soundness interfaces
    ├── Instances/
    │   └── FourEvidence/
    │       ├── Model.lean         # Concrete instance & inhabited DigestModel
    │       ├── Checker.lean       # Executable certificate checker
    │       └── Composition.lean   # Multi-stage typed chain, agreements & fidelity
    └── Proofs/
        ├── FourEvidence.lean      # Kernel-checked checker soundness & disjointness
        ├── Composition.lean       # Conditional & discharged composition theorems
        └── PositiveWitness.lean   # Positive constructive witnesses & #eval checks
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
