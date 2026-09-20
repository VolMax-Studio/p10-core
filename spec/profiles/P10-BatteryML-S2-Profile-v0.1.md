# P10-BatteryML-S2 Profile Specification v0.1

**Document Identifier:** `SPEC-P10-PROFILE-BATTERYML-S2-v0.1`  
**Revision:** `v0.1-retro-candidate` (Pre-Freeze Domain Profile)  
**Parent Protocol:** `P10-Core v0.3 — S2 Semantic Core` (Commit: `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`, Tag: `v0.3.0-s2-freeze`)  
**Adapter Implementation:** `p10-core` (`P10Core.Model.DomainAdapter`)  
**Domain:** Protocol-Disjoint Cycle-Life Prediction Robustness in Laboratory Lithium-Ion Battery Cells  
**Author:** VolMax Studio Lab  

---

## 1. Profile Identity and Scope

This specification formalizes the **BatteryML Domain Profile** for the P10-Core v0.3 S2 adjudication framework.

### 1.1 Narrowed Operational Scope (v0.1)
The v0.1 profile strictly governs the adjudication of claims asserting **protocol-disjoint cycle-life prediction robustness of machine learning models on laboratory-cycled lithium-ion battery cells**.

It explicitly excludes from this initial profile version:
- Open-ended State-of-Health (SOH) or Remaining Useful Life (RUL) claims outside laboratory cycling;
- Unspecified multi-chemistry transfer claims;
- Multi-batch generalization claims lacking explicit checker implementations.

The profile acts as a deterministic adapter layer translating raw machine learning experiment artifacts (pre-registration commitments, training telemetry, per-cell prediction tables, gating control outputs, and clean-room recomputation receipts) into normalized `DecisionView` records for the frozen S2 adjudication automaton.

---

## 2. Frozen-Core Binding & Triple-Anchor Provenance

To preserve strict cryptographic lineage without retroactively altering frozen code or relying on ephemeral branch names, this profile establishes a **Triple-Anchor Provenance Model**:

1. **Frozen Semantic Core (`P10Core.Model.AdjudicationAutomaton`):**
   - **Canonical Commit Object ID:** `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`
   - **Annotated Tag:** `v0.3.0-s2-freeze`
   - **Scope:** Immutable Lean 4 specification and verified adjudication automaton. Defines `DecisionView`, witness aggregation precedence, totality of `adjudicate`, and demarcation soundness. Contains zero domain-specific types.
2. **Domain Adapter & Profile Implementation Source (`P10Core.Model.DomainAdapter`):**
   - **Canonical Identity:** Fixed by the final 40-character Git commit SHA sealing the profile and adapter source code.
   - **Scope:** Implements `DomainProfile E` and verifies the `profile_extensionality` theorem proving domain-source invariance conditional on an equal normalized `DecisionView`.
3. **Profile Specification Digest:**
   - **Canonical Identity:** SHA-256 cryptographic digest of `spec/profiles/P10-BatteryML-S2-Profile-v0.1.md`.
   - **Scope:** Canonical text defining the obligation set, failure tags, and normalization rules.

These three anchors are permanently recorded in the external manifest `BATTERYML_S2_PROFILE_FREEZE_RECORD.md` and sealed under the annotated Git tag `batteryml-s2-profile-v0.1-retro-freeze`.

Under no circumstances may this profile modify, redefine, or bypass the S2 adjudication automaton, the fail-closed precedence ladder, or the unified terminal outcome space $\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$.

---

## 3. Claim Grammar

Every audit under the BatteryML profile must evaluate a single, structured `ProtocolRobustnessClaim`:

```text
ProtocolRobustnessClaim := {
  claim_id            : String,
  target_models       : List(ModelFamily),            -- Explicitly enumerated candidate model architectures
  split_type          : ProtocolDisjointSplitDef,     -- Definition of protocol-disjoint partitioning
  cell_population     : CellPopulationCommitment,     -- Target cell identifiers and laboratory provenance
  shift_threshold     : Float,                        -- Numerical margin defining a "material" error increase (e.g. ΔMAE)
  prevalence_limit    : Float,                        -- Maximum tolerable proportion of splits exhibiting material shift (p_material)
  gating_controls     : List(GatingControlSpec)       -- Pre-registered baseline benchmark checks (e.g. Split A, Ref B)
}
```

The claim is **falsifiable** if and only if:
1. It defines explicit, measurable numerical thresholds $\theta_{\text{shift}}$ and $p_{\text{material}}$ prior to execution;
2. It registers positive controls whose failure directly halts issuance or issues `NotVerified`;
3. The empirical evaluation procedure admits observable degradation across protocol splits capable of triggering substantive violation.

---

## 4. Obligation Space $\mathcal{O}_{\text{BatteryML}}(P)$

The obligation space $\mathcal{O}_{\text{BatteryML}}(P)$ decomposes the ML protocol verification into ten atomic, typed obligations partitioned across five classes:

$$\mathcal{O}_{\text{BatteryML}}(P) = \mathcal{O}_{\text{precommit}} \cup \mathcal{O}_{\text{custody}} \cup \mathcal{O}_{\text{execution}} \cup \mathcal{O}_{\text{controls}} \cup \mathcal{O}_{\text{recomputation}}$$

### 4.1 Pre-Registration Commitment Obligations ($\mathcal{O}_{\text{precommit}}$)
1. **`O_SEED_BINDING`:**
   - **Scope:** PRNG seed string and sampler algorithm cryptographic commitment.
   - **Required Evidence:** Pre-registered seed digest witness, runtime execution receipt.
   - **Admissibility:** Receipt is schema-valid, authentically signed by runner telemetry, and bound to the target commit.
   - **Substantive Evaluator:** Compares runtime seed digest with frozen pre-registration commitment.
     - Match $\to$ `Satisfied`.
     - Digest mismatch $\to$ `Violated` (indicates pre-registration fracture).
   - **Failure Tag:** `F_SEED_MISMATCH`.
2. **`O_HASH_TEST_MEMBERSHIP`:**
   - **Scope:** Enumeration and cryptographic commitment of candidate split membership.
   - **Required Evidence:** Frozen test membership commitment digest, runtime split generator output table.
   - **Admissibility:** Generator table is schema-valid, uncorrupted, and bound to target run.
   - **Substantive Evaluator:** Compares computed SHA-256 digest of runtime partition table with pre-committed digest.
     - Match $\to$ `Satisfied`.
     - Hash mismatch $\to$ `Violated` (indicates test split mutation).
   - **Failure Tag:** `F_MEMBERSHIP_FRACTURE`.

### 4.2 Data Custody Obligations ($\mathcal{O}_{\text{custody}}$)
3. **`O_CONTROL_DATASET_BINDING`:**
   - **Scope:** Integrity and immutability of published training/evaluation control datasets.
   - **Required Evidence:** Remote host API archive listing receipt, dataset file manifest SHA-256, version pin.
   - **Admissibility:** API receipt is authentic, timestamped post-execution, and contains exact remote resource slug.
   - **Substantive Evaluator:**
     - Remote listing confirms exact published version with matching archive digest and zero uncommitted files $\to$ `Satisfied`.
     - Remote API unavailable or host connection dropped $\to$ `Blocked` (operational impediment $\implies \texttt{Deferred}$).
     - Archive hash mismatch, file corruption, or uncommitted files detected $\to$ Target data custody is compromised. The adapter directly sets:
       $$\text{DecisionView}.\text{protocolFault} := \operatorname{some}(\operatorname{S2ProtocolError}.\text{integrityFailure})$$
       (This immediately halts adjudication at S2 Step 1).
   - **Failure Tag:** N/A (halted via `ProtocolError(integrityFailure)`).

### 4.3 Execution Integrity Obligations ($\mathcal{O}_{\text{execution}}$)
4. **`O_RUN_EXIT`:**
   - **Scope:** Clean, uncorrupted termination of the scientific driver on the host runner.
   - **Required Evidence:** Host runner execution log, process termination receipt.
   - **Admissibility:** Host telemetry log is uncorrupted, parseable, and complete from process start to termination.
   - **Substantive Evaluator (Deterministic Partition):**
     - Returncode equals `0` and execution ran to completion within timeout/resource budget $\to$ `Satisfied`.
     - Process interrupted by external host constraint (OOM killer signal, host wall-clock timeout, cloud quota termination) documented in host telemetry $\to$ `Blocked` (operational interruption $\implies \texttt{Deferred}$).
     - Process terminated abnormally with non-zero exit code, unhandled driver exception, or aborted before completing all stages without an external host bloker $\to$ Incomplete/failed execution; the adapter directly sets:
       $$\text{DecisionView}.\text{protocolFault} := \operatorname{some}(\operatorname{S2ProtocolError}.\text{prematureExecution})$$
     - Host log artifact missing or absent $\to$ `Missing` (leads to `NotDemonstrated`).
     - Checker script crashes while parsing an admissible host log $\to$ `CheckerError` (triggers $\operatorname{ProtocolError}(\texttt{checkerFailure})$).
   - **Failure Tag:** N/A (managed via `Blocked` or `ProtocolError`).
5. **`O_FIT_COUNT`:**
   - **Scope:** Complete execution of all pre-registered model fits ($K$ splits $\times M$ model families).
   - **Required Evidence:** Execution closure metadata, prediction matrix row count.
   - **Admissibility:** Closure metadata and prediction matrix are parseable tables cryptographically bound to runner logs.
   - **Substantive Evaluator (Deterministic Partition):**
     - Matrix rows equal expected total fit count ($K \times M$) with zero dropped models $\to$ `Satisfied`.
     - Matrix rows $< K \times M$ AND host runner telemetry confirms an external interruption (host timeout, OOM killer signal, cloud quota termination) $\to$ `Blocked` (operational interruption $\implies \texttt{Deferred}$).
     - Matrix rows $< K \times M$ AND execution completed (returncode 0 or internal worker crash) without external host interruption $\to$ Incomplete execution; the adapter directly sets:
       $$\text{DecisionView}.\text{protocolFault} := \operatorname{some}(\operatorname{S2ProtocolError}.\text{prematureExecution})$$
     - Prediction matrix file missing or absent $\to$ `Missing` (leads to `NotDemonstrated`).
     - Checker script crashes while counting rows in an admissible prediction matrix $\to$ `CheckerError` (triggers $\operatorname{ProtocolError}(\texttt{checkerFailure})$).
   - **Failure Tag:** N/A (managed via `Blocked` or `ProtocolError`).

### 4.4 Gating Control Obligations ($\mathcal{O}_{\text{controls}}$)
6. **`O_CTRL_GATE1` (Positive Control Split A):**
   - **Scope:** Standard randomized or published baseline split benchmark reproduction.
   - **Required Evidence:** Split A model evaluation table, pre-registered error metric tolerance $\epsilon_A$.
   - **Admissibility:** Split A table contains predictions for all candidate models on identical test cells.
   - **Substantive Evaluator:**
     - All candidate models achieve benchmark performance within pre-registered tolerance $\epsilon_A$ $\to$ `Satisfied`.
     - One or more models fail baseline benchmark bounds $\to$ `Violated` (indicates invalid baseline training).
   - **Failure Tag:** `F_GATE1_CONTROL_FAILURE`.
7. **`O_CTRL_GATE2` (Reference Split B Control):**
   - **Scope:** Historical reference protocol-disjoint split baseline performance.
   - **Required Evidence:** Ref B evaluation output table, pre-registered historical calibration bounds.
   - **Admissibility:** Ref B table is complete and bound to target dataset version.
   - **Substantive Evaluator:**
     - Performance on Ref B reproduces pre-registered historical calibration metrics within tolerance $\epsilon_B$ $\to$ `Satisfied`.
     - Performance breaches historical calibration bounds $\to$ `Violated` (indicates pipeline drift).
   - **Failure Tag:** `F_GATE2_CONTROL_FAILURE`.

### 4.5 Independent Recomputation Obligations ($\mathcal{O}_{\text{recomputation}}$)
8. **`O_RECOMPUTE_PREDICTIONS`:**
   - **Scope:** Independent, clean-room recalculation of error metrics (MAE, RMSE) directly from raw per-cell prediction CSVs.
   - **Required Evidence:** Independent recomputation script output (`recomputation.json`), raw prediction CSVs.
   - **Admissibility:** Recomputation receipt was produced out-of-process from raw prediction files without access to reported summary logs.
   - **Substantive Evaluator:**
     - Recomputed metrics match reported driver metrics to within numerical tolerance ($\le 10^{-6}$) $\to$ `Satisfied`.
     - Recomputed metrics diverge from reported metrics $\to$ `Violated` (indicates calculation or reporting discrepancy).
     - Verification script crashes or encounters an unhandled internal exception $\to$ `CheckerError` (triggers $\operatorname{ProtocolError}(\texttt{checkerFailure})$).
   - **Failure Tag:** `F_RECOMPUTATION_DISCREPANCY`.
9. **`O_STATISTICAL_PREVALENCE`:**
   - **Scope:** Verification that material performance shift prevalence across protocol-disjoint splits does not exceed pre-registered limit $p_{\text{material}}$ for all target model families in the claim.
   - **Required Evidence:** Validated recomputation summary distribution table, quantile shift metrics.
   - **Admissibility:** Summary distribution table derives from verified per-cell prediction tables.
   - **Substantive Evaluator:**
     - Every model family in `target_models` has material shift prevalence $p \le p_{\text{material}}$ $\to$ `Satisfied`.
     - Any model family in `target_models` has material shift prevalence $p > p_{\text{material}}$ $\to$ `Violated` (claim of robust generalization is falsified).
   - **Failure Tag:** `F_THRESHOLD_EXCEEDED`.
10. **`O_DUMMY_BENCHMARK_SEPARATION`:**
    - **Scope:** Non-triviality check ensuring candidate models significantly outperform a zero-rule dummy regressor.
    - **Required Evidence:** Dummy regressor error distribution vs. trained candidate models across all $K$ splits.
    - **Admissibility:** Dummy regressor evaluated on identical cell splits under identical metric definitions.
    - **Substantive Evaluator:**
      - Candidate models outperform dummy regressor by pre-registered margin $\delta_{\text{dummy}}$ in $\ge 95\%$ of splits $\to$ `Satisfied`.
      - Candidate models exhibit dummy parity or inversion $\to$ `Violated` (trivial or non-learning pipeline).
    - **Failure Tag:** `F_DUMMY_INVERSION`.

---

## 5. Raw Evidence Classes

An admissible BatteryML evidence bundle $E$ consists of raw structured artifacts:
- `E_PRECOMMIT`: Pre-registration specification markdown, sampler code, pre-committed seed hash and membership table hash files.
- `E_CUSTODY`: Remote host API archive listing receipt, dataset file manifest SHA-256.
- `E_HOST_LOGS`: Raw execution stdout/stderr logs, process telemetry, closure metadata.
- `E_PREDICTIONS`: Raw CSV/Parquet files containing individual per-cell cycle-life predictions.
- `E_RECOMPUTATION`: Machine-readable JSON receipt generated by independent, out-of-process verification scripts.

---

## 6. Strict Separation: Protocol Faults vs. Inadmissible Artifacts vs. Checker Crashes

To eliminate any ambiguity or overlapping paths, evidence evaluation strictly enforces the canonical tri-part pipeline:

$$\text{Raw Evidence } E \longrightarrow \begin{cases} \textbf{Stage 1: Protocol Fault Detection} \implies \text{DecisionView}.\text{protocolFault} := \operatorname{some}(\text{fault}), \\ \textbf{Stage 2: Admissibility Gate} \implies \begin{cases} \text{Inadmissible Artifact (malformed/corrupt/unparseable)} \implies \operatorname{Eval}(E, o) = \texttt{Missing}, \\ \text{Admissible Witness} \implies \textbf{Stage 3: Checker Execution} \begin{cases} \text{Checker Tool Crash (internal bug in checker)} \implies \texttt{CheckerError}, \\ \text{Substantive Evaluation} \implies \texttt{Satisfied} \mid \texttt{Violated} \mid \texttt{Blocked}. \end{cases} \end{cases} \end{cases} \longrightarrow \text{DecisionView} \longrightarrow \boxed{\operatorname{adjudicate}_{\text{fa7878a}}}$$

### 6.1 Stage 1: Protocol Fault Detection (Global Pipeline Integrity)
Before obligation-level evaluation, the domain adapter inspects global pipeline integrity:
- If target dataset archive hash mismatches or custody is corrupt $\to$ `DecisionView.protocolFault := some S2ProtocolError.integrityFailure`.
- If pre-registration parameters or split generator were modified post-hoc $\to$ `DecisionView.protocolFault := some S2ProtocolError.preregistrationFracture`.
- If execution was aborted or driver crashed without an external host bloker $\to$ `DecisionView.protocolFault := some S2ProtocolError.prematureExecution`.
- If model artifacts were modified post-run $\to$ `DecisionView.protocolFault := some S2ProtocolError.targetMutation`.
- If runtime environment contradicts frozen constraints $\to$ `DecisionView.protocolFault := some S2ProtocolError.environmentMismatch`.

### 6.2 Stage 2: Admissibility Gate (Artifact Validity)
A candidate raw artifact $w \in E$ is evaluated at the admissibility boundary:
- **Valid vs. Inadmissible Artifact:** Ingestion parsers safely validate file format and schema. If an artifact is unparseable (e.g. malformed JSON syntax, corrupt CSV line, empty or truncated file, missing required schema keys), the artifact is flagged as **inadmissible** and discarded.
- **Cryptographic & Temporal Binding:** The artifact must have authentic SHA-256 digests bound to the execution session.
- **Epistemic Consequence:** If no admissible witness exists for an obligation $o$, then $\operatorname{Eval}(E, o) = \texttt{Missing}$. S2 Step 5 deterministically adjudicates this as $\boxed{\mathcal{V}^* = \texttt{NotDemonstrated}}$, never as `NotVerified` and never as `ProtocolError`.

### 6.3 Stage 3: Checker Execution (Substantive vs. Tool Crash)
For every *admissible* witness:
- **Checker Tool Crash (`EvalStatus.checkerError`):** The artifact itself is admitted and valid, but the external checker/audit script crashes due to an internal bug (e.g. unhandled python exception, division by zero, syntax or type error inside the verification code) $\implies \operatorname{Eval}(E, o) = \texttt{CheckerError}$. S2 Step 1 deterministically issues $\boxed{\operatorname{ProtocolError}(\texttt{checkerFailure})}$.
- **Substantive Classification:** The verification script executes normally to completion over the admissible artifact:
  - $\texttt{Satisfied}$: Empirical condition mathematically verified;
  - $\texttt{Violated}$: Empirical condition mathematically refuted $\implies \boxed{\mathcal{V}^* = \texttt{NotVerified}}$ at Step 2;
  - $\texttt{Blocked}$: Operationally blocked by documented host constraints $\implies \boxed{\mathcal{V}^* = \texttt{Deferred}}$ at Step 4.

There is **zero overlap** between an inadmissible artifact (which safely yields `Missing`) and a checker tool failure (which strictly signifies a crash of the verification program itself over an admitted artifact).

---

## 7. Substantive FailureTag Mapping

Substantive violations map bijectively to failure tags:

| Failure Tag | Underlying Obligation | Description | Substantive Verdict |
|---|---|---|---|
| `F_SEED_MISMATCH` | `O_SEED_BINDING` | Runtime seed differs from pre-registration | `NotVerified` |
| `F_MEMBERSHIP_FRACTURE` | `O_HASH_TEST_MEMBERSHIP` | Split membership table altered post-hoc | `NotVerified` |
| `F_GATE1_CONTROL_FAILURE` | `O_CTRL_GATE1` | Models fail standard Split A baseline | `NotVerified` |
| `F_GATE2_CONTROL_FAILURE` | `O_CTRL_GATE2` | Models fail historical Ref B baseline | `NotVerified` |
| `F_RECOMPUTATION_DISCREPANCY` | `O_RECOMPUTE_PREDICTIONS` | Reported metrics contradict raw predictions | `NotVerified` |
| `F_THRESHOLD_EXCEEDED` | `O_STATISTICAL_PREVALENCE` | Target model exceeds material shift limit | `NotVerified` |
| `F_DUMMY_INVERSION` | `O_DUMMY_BENCHMARK_SEPARATION` | Candidate models fail to outperform dummy | `NotVerified` |

---

## 8. Limitation Registry $\mathcal{L}^*$ & Strict Non-Softening Invariant

The limitation registry $\mathcal{L}^*$ enumerates domain-specific boundary conditions.

### 8.1 The Strict Non-Softening Invariant
> **CRITICAL PROTOCOL RULE:** A registered limitation in $\mathcal{L}^*$ **MUST NOT** be used to soften, pardon, or convert a violated primary obligation into `VerifiedWithLimitations`. If any obligation evaluates to `Violated`, S2 precedence mandates immediate issuance of `NotVerified` at Step 2, completely bypassing limitation evaluation at Step 6.

### 8.2 Pre-Registered Domain Limitations (v0.1 Closed Set)
In v0.1, the registry contains exclusively limitations with explicit, verified evaluation paths:

1. **`L_CHEMISTRY_LFP`:**
   - **Scope:** Electrochemical cell chemistry boundary.
   - **Severity:** `NonBlocking`.
   - **Applicability Rule:** Evaluator confirms training and test cells belong exclusively to Lithium Iron Phosphate (LFP) commercial cells (e.g. Severson et al. dataset).
   - **Disposition:** Limits claim generalizability to LFP chemistries; does not block verification of the protocol-disjoint claim within that chemistry.
2. **`L_MODEL_FAMILY_SCOPE`:**
   - **Scope:** Architecture-bounded generalization.
   - **Severity:** `NonBlocking`.
   - **Applicability Rule:** Applicable **ONLY** when the pre-registered claim explicitly defines architecture-bounded robustness (e.g. asserting robustness specifically for tree-based architectures like XGBoost and Variance), while transparently disclosing that unasserted architectures (e.g. linear/ridge models) exhibit protocol sensitivity.
   - **Disposition:** Replaces pure `Verified` with `VerifiedWithLimitations` to demarcate the architecture boundary.

*(Note: Physical environmental parameters such as cycling chamber temperature drift are omitted from the v0.1 limitation registry because the current obligation space does not include a mandatory continuous thermal logging obligation. A limitation cannot be evaluated as `false` without an explicit evidentiary obligation establishing non-applicability).*

---

## 9. Novel-Finding Admissibility

A finding $f$ not cataloged in $\mathcal{L}^*$ alters the adjudication automaton if and only if it satisfies:

$$\operatorname{AdmissibleNovelFinding}(f, P, E) \iff \operatorname{ScopeRelevant}(f) \land \operatorname{BoundToEvidence}(f, E) \land \operatorname{Uncataloged}(f, \mathcal{L}^*)$$

- **Admissible Novel Finding:** Automatically transitions the S2 automaton to $\boxed{\mathcal{V}^* = \texttt{Deferred}}$.
- **Inadmissible Assertion:** Unsubstantiated reviewer assertions or unrecorded speculative caveats have zero weight and are ignored by the automaton.

---

## 10. DecisionView Construction

The BatteryML adapter normalizes the evaluated evidence into the canonical S2 `DecisionView`:

```text
DecisionView = {
  protocolFault           : Option(S2ProtocolError),
  falsifiable             : Bool,
  obligations             : List(EvalStatus),  -- Length 10
  hasBlockingLimitation   : Bool,
  hasNonBlockingLimitation: Bool,
  admissibleNovelFinding  : Bool
}
```

The construction follows strict precedence:
1. **Pipeline & Custody Fault Inspection:**
   - If control dataset archive hash mismatch or corrupt custody $\to$ `protocolFault := some S2ProtocolError.integrityFailure`;
   - If pre-registration parameters or thresholds altered post-hoc $\to$ `protocolFault := some S2ProtocolError.preregistrationFracture`;
   - If execution session was truncated without external blocker $\to$ `protocolFault := some S2ProtocolError.prematureExecution`;
   - If model files or predictions modified after completion $\to$ `protocolFault := some S2ProtocolError.targetMutation`;
   - If runtime hardware or OS violates toolchain constraints $\to$ `protocolFault := some S2ProtocolError.environmentMismatch`.
2. **Obligation Evaluation:**
   For each $o_i \in \mathcal{O}_{\text{BatteryML}}(P)$, evaluate $\operatorname{Eval}(E, o_i)$ using S2 fail-closed witness aggregation.
3. **Limitation Evaluation:**
   Evaluate applicability of registered limitations in $\mathcal{L}^*$ under the non-softening invariant.
4. **Novel Finding Scan:**
   Check for admissible novel findings.

The resulting `DecisionView` is passed directly to `P10Core.Model.AdjudicationAutomaton.adjudicate`.

---

## 11. Protocol-Error Disentanglement

To ensure deterministic fail-closed halting without conflating administrative or infrastructural faults with scientific falsification:

| Event | Mechanism | S2 Outcome | Epistemic Meaning |
|---|---|---|---|
| Verification script crash / unhandled exception | Obligation `CheckerError` | `ProtocolError(checkerFailure)` | Checker pipeline broke; cannot evaluate claim. |
| Control dataset archive hash mismatch | Direct `protocolFault` | `ProtocolError(integrityFailure)` | Target data custody compromised; cannot evaluate claim. |
| Model files modified post-execution | Direct `protocolFault` | `ProtocolError(targetMutation)` | Target changed during audit; cannot evaluate claim. |
| Toolchain / OS version mismatch | Direct `protocolFault` | `ProtocolError(environmentMismatch)` | Runtime does not match preregistered environment. |
| Preregistration thresholds altered post-hoc | Direct `protocolFault` | `ProtocolError(preregistrationFracture)` | Protocol rules altered after seeing data. |
| Truncated or aborted execution session | Direct `protocolFault` | `ProtocolError(prematureExecution)` | Driver stopped before executing all fits. |
| External cloud quota exhaustion / OOM | Obligation `Blocked` | `Deferred` | Operational impediment; run may be retried. |
| Positive control benchmark failure | Obligation `Violated` | `NotVerified` | Baseline model training failed; pipeline invalid. |
| Material shift threshold exceeded | Obligation `Violated` | `NotVerified` | Substantive scientific refutation of the claim. |

---

## 12. Instance-Binding Requirements

Every audit execution under this profile must generate an immutable `instance_manifest.json`:
- Target git repository commit SHA (40-hex);
- Remote host kernel ID and execution receipt SHA-256;
- Control dataset archive SHA-256;
- Recomputation script version and environment digest.

---

## 13. Retrospective Replay Policy

When evaluating historically completed studies (such as `batteryml-protocol-robustness-s3`):
1. **Applicability Demonstration Only:** The retrospective replay serves solely to verify domain adapter functionality, witness classification correctness, and deterministic automaton termination.
2. **No Confirmatory Claim:** A retrospective replay **SHALL NOT** be claimed as a new confirmatory finding or independent scientific validation, because the empirical results were already known prior to profile authoring.
3. **Byte-Exact Input Grounding:** Replay must use verbatim, historically frozen artifacts without regeneration or post-hoc re-tuning of thresholds.

---

## 14. Prospective-Run Requirements

A genuine confirmatory P10 audit under this profile requires:
1. **Pre-Data Freeze:** This profile specification, the concrete claim, and all numerical thresholds $\theta$ must be committed to Git **prior to acquiring or inspecting test-split data**.
2. **Blind Execution:** Test cell split assignments and ground-truth cycle-life labels must remain blinded to the model training pipeline until training closure is committed.
3. **Deterministic Emission:** The execution must emit the complete `decision_trace.json` conforming to P10-Core v0.3 standards.

---

## 15. Explicit Non-Claims

1. **No Assertion of Physical Truth:** A `Verified` verdict certifies that the specified ML models satisfy the pre-registered protocol-robustness criteria under the specified test distribution; it does not assert that the models constitute universal physical laws of battery degradation.
2. **No Claim of Automated Data Quality:** The profile relies on cryptographic integrity and registered gating controls; it does not audit the physical calibration of laboratory cyclers beyond registered control data.

---

## 16. Adjudication Neutrality Mandate

The success of an audit execution is defined strictly as:

$$\boxed{\textbf{Success} \iff \text{profile frozen} \land \text{evidence classified by rules} \land \text{core unmodified} \land \text{rule-mandated outcome issued}}$$

Terminal verdicts of `NotVerified`, `NotDemonstrated`, `Deferred`, or `VerifiedWithLimitations` represent successful executions of the protocol whenever warranted by the evidence. An adjudication protocol does not exist to produce positive verifications; it exists to deterministically enforce pre-registered epistemic boundaries.
