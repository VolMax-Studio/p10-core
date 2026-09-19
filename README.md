# P10-Core — A Certificate-Carrying Verification Protocol with Explicit Trust Boundaries

<p align="center">
  <img src="assets/p10_core_banner.png" alt="P10-Core Verification Protocol" width="100%">
</p>

**Milestone:** `P10-Core / Composition — Bounded Transition Chain & Compositional Soundness`  
**Release Tag:** `v0.2.0-composition`  
**Previous Seed Tag:** `v0.1.0-four-evidence` (frozen, byte-for-byte preserved)  
**Author:** VolMax Studio Lab / Nestorov, Ivan (ORCID: [`0009-0006-7940-9539`](https://orcid.org/0009-0006-7940-9539))  
**Contributors:** Ivan Nestorov, Sol, Astra, Ananke  
**Toolchain:** Lean 4.34.0 (`leanprover/lean4:v4.34.0`), Lake 5.0.0  
**License:** Apache 2.0  

---

## 1. Overview

**P10-Core** is a formal, certificate-carrying verification protocol designed to adjudicate empirical and operational claims under pre-registered, immutable evidentiary rules.

Rather than acting as an ungrounded or autonomous "truth machine," P10-Core formalizes the strict mathematical demarcation between ontological truth and evidentiary support:

$$\mathrm{Truth}_M(c) \neq \mathrm{Supports}_P(e, c, \kappa, v)$$

A positive verification indicates that an admissible evidence bundle $e$, evaluated under frozen protocol rules $P$, deterministically yields certificate $\kappa$ supporting verdict $v$. When evidence is insufficient, the protocol does not declare falsehood; it strictly and soundly outputs `NotDemonstrated`.

This release (`v0.2.0-composition`) builds upon the frozen `v0.1.0-four-evidence` seed to introduce a **machine-checked compositional verification layer** across a multi-stage transition chain.

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
*Mechanized in [`P10Core/Proofs/FourEvidence.lean`](P10Core/Proofs/FourEvidence.lean) (Unchanged from `v0.1.0`)*:
- **Checker Soundness:**
  ```lean
  theorem checkCert_sound
      (D : DigestModel) (P : Protocol) (c : Claim) (e : Evidence)
      (κ : Certificate) (v : Verdict)
      (hcheck : CheckCert D P c e κ v = true) :
      Supports (semantics P) e c κ v
  ```
- **Semantic Invariants & Disjointness:**
  - `supports_verified_implies_conditions`
  - `supports_notDemonstrated_implies_not_conditions`
  - `supports_deferred_implies_external_blocker`
  - `verified_not_notDemonstrated` (proves $\mathrm{Supports}(\text{verified}) \land \mathrm{Supports}(\text{notDemonstrated}) \implies \bot$ without axioms).

---

### Layer 2: The Bounded Composition Layer (`v0.2.0-composition`)
*Mechanized in [`P10Core/Proofs/Composition.lean`](P10Core/Proofs/Composition.lean) and [`P10Core/Instances/FourEvidence/Composition.lean`](P10Core/Instances/FourEvidence/Composition.lean)*:

#### 1. Typed Multi-Stage Pipeline
The concrete execution pipeline transitions through four typed stages:
$$\text{Stage0}(c, e) \xrightarrow{T_1} \text{Stage1}(c, e, \text{target}) \xrightarrow{T_2} \text{Stage2}(c, e, \text{target}, \text{checked}) \xrightarrow{T_3} \text{Stage3}(c, e, \text{target}, \text{checked}, \kappa, v)$$

Each transition $T_i$ enforces:
- An executable local checker (`check1`, `check2`, `check3`);
- A semantic preservation contract (`ContractRel1`, `ContractRel2`, `ContractRel3`);
- A claim/evidence fidelity relation (`FidelityRel1`, `FidelityRel2`, `FidelityRel3`);
- An explicit transition certificate (`TransitionCertificate`) verifying gate conditions.

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
      (τ1 τ2 τ3 : TransitionCertificate)
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
      (τ1 τ2 τ3 : TransitionCertificate)
      (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
      (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
      GlobalSupport P x0 x1 x2 x3
  ```
- **Terminal Protocol Support:**
  `GlobalSupport.protocolSupport` extracts the exact declarative $\mathrm{Supports}$ judgement. It contains **no $\mathrm{Truth}_M$ predicate** and makes no claim of metaphysical truth.

#### 4. Adversarial Non-Composition Theorems
To ensure the composition gate cannot be vacuously satisfied:
- **`missingCertificateCannotCompose`:** If any certificate is missing ($\tau_1.\text{present} = \text{false}$), the chain strictly cannot compose to `CompositionWitness`.
- **`failedContractCannotCompose`:** If intermediate semantic contract $\neg\mathrm{ContractRel2}$ is violated, composition is strictly refuted.
- **`brokenFidelityCannotCompose`:** If claim/evidence fidelity $\neg\mathrm{FidelityRel3}$ is broken, composition is strictly refuted.

---

## 4. Trust Boundaries & Axiom Audit

This repository maintains absolute evidentiary transparency. As audited in [`AXIOM_AUDIT.md`](AXIOM_AUDIT.md):

- **Zero `sorry` / zero `admit`:** Scanned across all source files.
- **Zero user-declared `axiom`:** No custom axioms are introduced.
- **Lean Kernel Report (`#print axioms`):**
  ```text
  'P10Core.Proofs.FourEvidence.checkCert_sound' depends on axioms: [propext, Quot.sound]
  'P10Core.Proofs.Composition.conditionalComposition' does not depend on any axioms
  'P10Core.Proofs.Composition.fourEvidenceComposes' depends on axioms: [propext, Quot.sound]
  'P10Core.Proofs.Composition.missingCertificateCannotCompose' does not depend on any axioms
  'P10Core.Proofs.Composition.failedContractCannotCompose' does not depend on any axioms
  'P10Core.Proofs.Composition.brokenFidelityCannotCompose' depends on axioms: [propext]
  ```
- **Explicit Domain Premise:** Evidence digest injectivity (`DigestModel.injective`) remains the sole explicit domain hypothesis. Composition introduces **zero new residual premises**.

---

## 5. Explicit Epistemic Boundaries (What is NOT Claimed)

1. **No Claim of Ontological Truth:** Verifying composition proves that the transition chain faithfully preserves contracts and fidelity down to `Supports`; it does not prove physical truth outside the specified bridge assumptions ($B_i$).
2. **No Global P10 Soundness:** Proved for the bounded `FourEvidence` multi-stage pipeline, not as a universal metatheorem over arbitrary untyped programs.
3. **No Cryptographic Collision Resistance:** Evidence digests remain in the abstract model.
4. **No Unbounded Composition:** The composition theorem covers the specified finite 4-stage chain; unbounded transfinite progressions are explicitly bounded by Gödel/Löb limitative results.

---

## 6. Repository Structure

```text
p10-core/
├── assets/
│   └── p10_core_banner.png        # Official project banner
├── AXIOM_AUDIT.md                 # Complete axiom and trust boundary audit (v0.2.0)
├── CITATION.cff                   # Academic citation metadata
├── LICENSE                        # Apache 2.0 License
├── P10Core.lean                   # Top-level module import
├── README.md                      # Primary project overview
├── RELEASE_NOTES.md               # v0.2.0 release notes
├── lakefile.toml                  # Lake package definition
├── lake-manifest.json             # Pinned package dependencies
├── lean-toolchain                 # Pinned Lean toolchain (v4.34.0)
├── P10Core/
│   ├── Spec/
│   │   └── Core.lean              # Core P10 data types and verdict definitions
│   ├── Model/
│   │   ├── Calculus.lean          # Declarative Supports calculus
│   │   └── Rules.lean             # Rule definitions and soundness interfaces
│   ├── Instances/
│   │   └── FourEvidence/
│   │       ├── Model.lean         # Concrete FourEvidence instance model
│   │       ├── Checker.lean       # Executable certificate checker
│   │       └── Composition.lean   # Multi-stage typed chain, contracts & fidelity
│   └── Proofs/
│       ├── FourEvidence.lean      # Kernel-checked checker soundness & disjointness
│       └── Composition.lean       # Conditional & discharged composition theorems
├── scripts/
│   ├── AxiomAudit.lean            # Standalone axiom verification script
│   └── reproduce.sh               # Clean-room build and audit runner
└── spec/
    ├── P10-Core-v0.1.md           # Architectural specification v0.1
    ├── P10-Core-v0.2.md           # Specification v0.2 (Disjoint verdicts & contracts)
    └── P10-Core-v0.2.1.md         # Specification v0.2.1 (Decoupled PreflightResult)
```

---

## 7. Clean-Room Reproduction

To verify and recompile the entire formalization from source using Lean 4.34.0:

```bash
# Automated clean-room verification:
./scripts/reproduce.sh

# Or manual build:
lake build
lake env lean scripts/AxiomAudit.lean
```
