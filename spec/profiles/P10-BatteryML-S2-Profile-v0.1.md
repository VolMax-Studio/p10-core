# P10-BatteryML-S2 Profile Specification v0.1

**Document Identifier:** `SPEC-P10-PROFILE-BATTERYML-S2-v0.1`  
**Revision:** `v0.1-draft` (Pre-Freeze Domain Profile)  
**Parent Protocol:** `P10-Core v0.3 — S2 Semantic Core` (Commit: `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`, Tag: `v0.3.0-s2-freeze`)  
**Domain:** Empirical Machine Learning for Battery Health & Degradation (State-of-Health / Remaining Useful Life)  
**Author:** VolMax Studio Lab  

---

## 1. Profile Identity and Scope

This specification formalizes the **BatteryML Domain Profile** for the P10-Core v0.3 S2 adjudication framework.

The profile governs the formal audit of empirical claims regarding the **robustness and generalization of machine learning models for battery degradation across operational protocol boundaries** (e.g. protocol-disjoint splits, cross-chemistry transfer, multi-batch generalization).

It acts as an adapter layer translating raw machine learning experiment artifacts (pre-registration commitments, training receipts, model predictions, evaluation logs, recomputation outputs) into normalized `DecisionView` records for the frozen P10-Core S2 adjudication automaton.

---

## 2. Frozen-Core Binding

This profile binds strictly to the immutable P10-Core S2 kernel:
- **Kernel Tag:** `v0.3.0-s2-freeze`
- **Kernel Commit:** `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4`
- **Kernel Interface:** `P10Core.Model.AdjudicationAutomaton` (`adjudicate : DecisionView → TerminalOutcome`) and `P10Core.Model.DomainAdapter` (`DomainProfile E`).

Under no circumstances may this profile modify, redefine, or bypass the S2 adjudication automaton, the fail-closed precedence ladder, or the six-element terminal outcome space $\Omega = \operatorname{ProtocolError}(\text{reason}) \uplus \mathcal{V}^*$.

---

## 3. Claim Grammar

Every audit under the BatteryML profile must evaluate a structured claim $C$ satisfying the following grammar:

```text
Claim := ProtocolRobustnessClaim
       | TransferabilityClaim
       | ArchitectureInvarianceClaim

ProtocolRobustnessClaim := {
  target_models       : List(ModelFamily),
  split_type          : ProtocolDisjointSplit,
  cell_population     : CellPopulationCommitment,
  prevalence_threshold: Float,   -- Maximum allowed proportion of material performance degradation
  material_shift_def  : ShiftThresholdDef,
  gating_controls     : List(GatingControl)
}
```

The claim is **falsifiable** if and only if:
1. It defines explicit, measurable numerical thresholds $\theta_{\text{shift}}$ and $p_{\text{material}}$ prior to execution;
2. It registers positive controls whose failure directly falsifies pipeline validity;
3. The empirical evaluation procedure admits counterexamples (i.e. model degradation across protocol splits is observable and capable of triggering `NotVerified`).

---

## 4. Obligation Space $\mathcal{O}_{\text{BatteryML}}(P)$

The obligation space $\mathcal{O}_{\text{BatteryML}}(P)$ decomposes the target ML verification into ten atomic, typed obligations partitioned across five classes:

$$\mathcal{O}_{\text{BatteryML}}(P) = \mathcal{O}_{\text{precommit}} \cup \mathcal{O}_{\text{custody}} \cup \mathcal{O}_{\text{execution}} \cup \mathcal{O}_{\text{controls}} \cup \mathcal{O}_{\text{recomputation}}$$

### 4.1 Pre-Registration Commitment Obligations ($\mathcal{O}_{\text{precommit}}$)
1. **`O_SEED_BINDING`:**
   - **Scope:** PRNG seed string and sampler algorithm cryptographic commitment.
   - **Required Evidence:** Preregistered seed digest witness, sampler code artifact, runtime seed receipt.
   - **Admissibility Rule:** SHA-256 digest of runtime seed string matches frozen pre-registration commitment exactly.
   - **Classifier:** Match $\to$ `Satisfied`; Digest mismatch $\to$ `Violated`; Missing receipt $\to$ `Missing`; Unparsable $\to$ `CheckerError`.
   - **Failure Tag:** `F_SEED_MISMATCH`.
2. **`O_HASH_TEST_MEMBERSHIP`:**
   - **Scope:** Complete enumeration and cryptographic commitment of candidate split membership.
   - **Required Evidence:** Frozen test membership commitment file, runtime split generator output table.
   - **Admissibility Rule:** Bit-level equality of the serialized split membership table SHA-256 digest against pre-committed hash.
   - **Classifier:** Match $\to$ `Satisfied`; Hash mismatch $\to$ `Violated`; Missing file $\to$ `Missing`; Corrupted $\to$ `CheckerError`.
   - **Failure Tag:** `F_MEMBERSHIP_FRACTURE`.

### 4.2 Data Custody & Control Dataset Obligations ($\mathcal{O}_{\text{custody}}$)
3. **`O_CONTROL_DATASET_BINDING`:**
   - **Scope:** Immutability and provenance of published training/evaluation control datasets.
   - **Required Evidence:** Remote host API archive listing receipt, control dataset file manifest SHA-256, version pin.
   - **Admissibility Rule:** Remote host listing contains exact published version with matching archive digest and zero uncommitted files.
   - **Classifier:** Verified $\to$ `Satisfied`; Checksum mismatch $\to$ `Violated`; API unavailable $\to$ `Blocked`; Missing receipt $\to$ `Missing`.
   - **Failure Tag:** `F_CUSTODY_MUTATION`.

### 4.3 Execution Integrity Obligations ($\mathcal{O}_{\text{execution}}$)
4. **`O_RUN_EXIT`:**
   - **Scope:** Clean, uncorrupted termination of the scientific driver on the host runner.
   - **Required Evidence:** Host execution log, process termination receipt.
   - **Admissibility Rule:** Process returncode equals `0`, execution duration within pre-registered limits, hardware memory limits respected.
   - **Classifier:** Exit `0` $\to$ `Satisfied`; Exit $\ne 0$ $\to$ `Violated`; Timeout/OOM kill $\to$ `Blocked`; Log missing $\to$ `Missing`.
   - **Failure Tag:** `F_RUNNER_CRASH`.
5. **`O_FIT_COUNT`:**
   - **Scope:** Exhaustive execution of all pre-registered model fits ($K$ splits $\times M$ model families).
   - **Required Evidence:** Execution closure metadata, prediction matrix shape.
   - **Admissibility Rule:** Matrix rows equal expected total fit count, zero dropped or silently skipped fits.
   - **Classifier:** Exact count $\to$ `Satisfied`; Incomplete fits $\to$ `Violated`; Missing closure $\to$ `Missing`.
   - **Failure Tag:** `F_FIT_DROPOUT`.

### 4.4 Gating Control Obligations ($\mathcal{O}_{\text{controls}}$)
6. **`O_CTRL_GATE1` (Positive Control Split A):**
   - **Scope:** Standard randomized or published baseline split (Split A) benchmark reproduction.
   - **Required Evidence:** Split A model evaluation table, published reference error metric bounds.
   - **Admissibility Rule:** Models achieve benchmark performance within pre-registered tolerance $\epsilon_A$ on standard Split A.
   - **Classifier:** Within bounds $\to$ `Satisfied`; Exceeds bound $\to$ `Violated`; Missing predictions $\to$ `Missing`.
   - **Failure Tag:** `F_GATE1_CONTROL_FAILURE`.
7. **`O_CTRL_GATE2` (Reference Split B Control):**
   - **Scope:** Known reference protocol-disjoint split baseline performance.
   - **Required Evidence:** Ref B evaluation output, historical reference boundary metrics.
   - **Admissibility Rule:** Baseline performance on Ref B matches pre-registered historical calibration bounds.
   - **Classifier:** Within bounds $\to$ `Satisfied`; Exceeds bound $\to$ `Violated`; Missing predictions $\to$ `Missing`.
   - **Failure Tag:** `F_GATE2_CONTROL_FAILURE`.

### 4.5 Independent Recomputation Obligations ($\mathcal{O}_{\text{recomputation}}$)
8. **`O_RECOMPUTE_PREDICTIONS`:**
   - **Scope:** Independent, clean-room recalculation of error metrics (MAE, RMSE, $R^2$) directly from raw per-cell prediction CSVs.
   - **Required Evidence:** Independent recomputation script output receipt (`recomputation.json`), raw prediction CSVs.
   - **Admissibility Rule:** Recomputed metrics match reported execution metrics to within floating-point epsilon ($\le 10^{-7}$).
   - **Classifier:** Byte/numeric match $\to$ `Satisfied`; Metric divergence $\to$ `Violated`; Missing raw CSVs $\to$ `Missing`; Script crash $\to$ `CheckerError`.
   - **Failure Tag:** `F_RECOMPUTATION_DISCREPANCY`.
9. **`O_STATISTICAL_PREVALENCE`:**
   - **Scope:** Evaluation of material performance shift prevalence across sampled protocol splits against the pre-registered threshold $p_{\text{material}}$.
   - **Required Evidence:** Recomputation summary distribution table, quantile statistics.
   - **Admissibility Rule:** Model family shift prevalence strictly evaluated against pre-registered threshold rules.
   - **Classifier:** Evaluated deterministically per model family; if universal robustness claimed but prevalence threshold breached $\to$ `Violated`; if verified within bounds $\to$ `Satisfied`.
   - **Failure Tag:** `F_THRESHOLD_EXCEEDED`.
10. **`O_DUMMY_BENCHMARK_SEPARATION`:**
    - **Scope:** Baseline sanity test ensuring non-trivial learning over zero-rule / dummy regressor.
    - **Required Evidence:** Dummy regressor error distribution vs. trained candidate models.
    - **Admissibility Rule:** Candidate models outperform dummy regressor by pre-registered margin $\delta_{\text{dummy}}$ in $\ge 95\%$ of splits.
    - **Classifier:** Separation verified $\to$ `Satisfied`; Dummy parity or inversion $\to$ `Violated`; Missing dummy data $\to$ `Missing`.
    - **Failure Tag:** `F_DUMMY_INVERSION`.

---

## 5. Raw Evidence Classes

An admissible BatteryML evidence bundle $E$ consists of raw structured artifacts:
- `E_PRECOMMIT`: Pre-registration markdown specification, sampler algorithm code, committed seed hash file.
- `E_CUSTODY`: API response headers, dataset archive manifest, SHA-256 tree hashes.
- `E_HOST_LOGS`: Raw stdout/stderr logs from the execution environment, process resource accounting telemetry.
- `E_PREDICTIONS`: Raw CSV/Parquet files containing individual per-cell cycle-life and capacity predictions.
- `E_RECOMPUTATION`: Machine-readable JSON receipt generated by independent, out-of-process verification scripts.

---

## 6. Witness Admissibility Rules

A raw artifact $w \in E$ is an admissible witness for obligation $o$ if and only if:
1. **Cryptographic Binding:** $w$ contains the SHA-256 digest binding it to the pre-registered study target tuple $\langle \text{Repo}, \text{Commit}, \text{DatasetManifest} \rangle$.
2. **Provenance Traceability:** $w$ includes execution timestamp, runner environment metadata, and toolchain identifiers.
3. **Immutability Check:** The artifact hash matches the manifest committed at execution completion.

---

## 7. Witness to WitnessClass Classifiers

For each obligation $o \in \mathcal{O}_{\text{BatteryML}}$, the classifier $\operatorname{Classify}(w, o)$ maps an admissible witness to:

$$\operatorname{Classify}(w, o) \in \{\texttt{Satisfied}, \texttt{Violated}, \texttt{Blocked}, \texttt{CheckerError}\}$$

- **`CheckerError`:** Unhandled exceptions, JSON/CSV parser crashes, division-by-zero, or missing numeric columns in the verification harness. (Fail-closed: triggers S2 $\operatorname{ProtocolError}(\texttt{checkerFailure})$).
- **`Violated`:** Check executes successfully and establishes that the empirical condition is falsified (e.g. hash mismatch, gate control failure, metric discrepancy).
- **`Blocked`:** Check cannot complete due to external operational impediments (e.g. host timeout, cloud quota exhaustion, network socket refusal).
- **`Satisfied`:** Check executes successfully and verifies exact satisfaction of the formal requirement.

---

## 8. FailureTag Mapping

Legacy audit failure codes map bijectively to violated obligations:

| Failure Tag | Name | Underlying Obligation | Substantive Verdict |
|---|---|---|---|
| `F_SEED_MISMATCH` | Seed Commitment Fracture | `O_SEED_BINDING` | `NotVerified` |
| `F_MEMBERSHIP_FRACTURE` | Test Split Mutation | `O_HASH_TEST_MEMBERSHIP` | `NotVerified` |
| `F_CUSTODY_MUTATION` | Dataset Custody Failure | `O_CONTROL_DATASET_BINDING` | `NotVerified` |
| `F_RUNNER_CRASH` | Host Execution Abort | `O_RUN_EXIT` | `NotVerified` |
| `F_FIT_DROPOUT` | Incomplete Fit Coverage | `O_FIT_COUNT` | `NotVerified` |
| `F_GATE1_CONTROL_FAILURE` | Split A Calibration Breach | `O_CTRL_GATE1` | `NotVerified` |
| `F_GATE2_CONTROL_FAILURE` | Ref B Benchmark Breach | `O_CTRL_GATE2` | `NotVerified` |
| `F_RECOMPUTATION_DISCREPANCY` | Prediction Discrepancy | `O_RECOMPUTE_PREDICTIONS` | `NotVerified` |
| `F_THRESHOLD_EXCEEDED` | Material Shift Prevalence | `O_STATISTICAL_PREVALENCE` | `NotVerified` |
| `F_DUMMY_INVERSION` | Dummy Regressor Parity | `O_DUMMY_BENCHMARK_SEPARATION` | `NotVerified` |

---

## 9. Limitation Registry $\mathcal{L}^*$

The closed registry of allowable domain limitations distinguishes between bounded generalizability and claim-destroying invalidity:

### 9.1 Pre-Registered Domain Limitations
1. **`L_CHEMISTRY_LFP`:**
   - **Scope:** Electrochemical cell chemistry.
   - **Severity:** `NonBlocking`.
   - **Applicability Rule:** Evaluator confirms training and test cells belong exclusively to Lithium Iron Phosphate (LFP) commercial cells (e.g. Severson et al. dataset).
   - **Disposition:** Limits claim generalizability to LFP chemistries; does not block verification of the protocol-disjoint claim.
2. **`L_MODEL_FAMILY_SCOPE`:**
   - **Scope:** Model family sensitivity.
   - **Severity:** `NonBlocking`.
   - **Applicability Rule:** One or more registered model families (e.g. linear/ridge models) exhibit material performance degradation under protocol-disjoint splits, while non-linear/tree-based architectures remain resilient, and the primary claim permits architecture-bounded robustness.
   - **Disposition:** Replaces pure `Verified` with `VerifiedWithLimitations`.
3. **`L_TEMPERATURE_DRIFT`:**
   - **Scope:** Thermal cycling stability.
   - **Severity:** `Blocking`.
   - **Applicability Rule:** Cell environmental cycling chambers deviate by $> \pm 3^\circ\text{C}$ from nominal test conditions, confounding protocol variation with thermal aging.
   - **Disposition:** Evaluates to `NotVerified` due to experimental invalidation.

---

## 10. Novel-Finding Admissibility

A finding $f$ not cataloged in $\mathcal{L}^*$ alters the adjudication automaton if and only if it satisfies:

$$\operatorname{AdmissibleNovelFinding}(f, P, E) \iff \operatorname{ScopeRelevant}(f) \land \operatorname{BoundToEvidence}(f, E) \land \operatorname{Uncataloged}(f, \mathcal{L}^*)$$

- **Admissible Novel Finding:** Automatically transitions the S2 automaton to $\boxed{\mathcal{V}^* = \texttt{Deferred}}$.
- **Inadmissible Assertion:** Unsubstantiated reviewer assertions or unrecorded speculative caveats have zero weight and are ignored by the automaton.

---

## 11. DecisionView Construction

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
1. If any pipeline fault is detected $\to$ `protocolFault := some fault`;
2. For each $o_i \in \mathcal{O}_{\text{BatteryML}}(P)$, evaluate $\operatorname{Eval}(E, o_i)$ using S2 fail-closed witness aggregation;
3. Evaluate applicability of registered limitations in $\mathcal{L}^*$;
4. Check for admissible novel findings.

The resulting `DecisionView` is passed directly to the frozen `P10Core.Model.AdjudicationAutomaton.adjudicate`.

---

## 12. Protocol-Error Conditions

The BatteryML profile halts execution and issues $\operatorname{ProtocolError}(\text{reason})$ under the following conditions:
- **`checkerFailure`:** Any verification script crashes, throws an unhandled exception, or returns invalid syntax.
- **`integrityFailure`:** Discrepancy between the remote dataset manifest and local evaluation hash.
- **`targetMutation`:** Model weights, prediction files, or split definitions modified after execution timestamp.
- **`environmentMismatch`:** Running on hardware or OS incompatible with pinned toolchain constraints.
- **`preregistrationFracture`:** Attempting to alter thresholds, model definitions, or split sizes post-hoc.

---

## 13. Instance-Binding Requirements

Every instance of an audit under this profile must generate an immutable, machine-readable `instance_manifest.json`:
- Target git repository commit SHA (40-hex);
- Remote host kernel ID and execution receipt SHA-256;
- Control dataset archive SHA-256;
- Recomputation script version and environment digest.

---

## 14. Retrospective Replay Policy

When evaluating historically completed studies (such as `batteryml-protocol-robustness-s3`):
1. **Applicability Demonstration Only:** The retrospective replay serves solely to verify domain adapter functionality, witness classification correctness, and deterministic automaton termination.
2. **No Confirmatory Claim:** A retrospective replay **SHALL NOT** be claimed as a new confirmatory finding or independent scientific validation.
3. **Byte-Exact Input Grounding:** Replay must use verbatim, historically frozen artifacts without regeneration or re-tuning of thresholds.

---

## 15. Prospective-Run Requirements

A genuine confirmatory P10 audit under this profile requires:
1. **Pre-Data Freeze:** This profile specification, the concrete claim, and all numerical thresholds $\theta$ must be committed to Git **prior to acquiring or inspecting test-split data**.
2. **Blind Execution:** Test cell split assignments and ground-truth cycle-life labels must remain blinded to the model training pipeline until training closure is committed.
3. **Deterministic Emission:** The execution must emit the complete `decision_trace.json` conforming to P10-Core v0.3 standards.

---

## 16. Explicit Non-Claims

1. **No Assertion of Physical Truth:** A `Verified` verdict certifies that the specified ML models satisfy the pre-registered protocol-robustness criteria under the specified test distribution; it does not assert that the models constitute universal physical laws of battery degradation.
2. **No Claim of Automated Data Quality:** The profile relies on cryptographic integrity and registered gating controls; it does not audit the physical calibration of laboratory cyclers beyond registered control data.
3. **Adjudication Neutrality Mandate:**
   The success of an audit execution is defined as:
   $$\boxed{\textbf{Success} \iff \text{profile frozen} \land \text{evidence classified by rules} \land \text{core unmodified} \land \text{rule-mandated outcome issued}}$$
   Terminal verdicts of `NotVerified`, `NotDemonstrated`, `Deferred`, or `VerifiedWithLimitations` represent successful executions of the protocol whenever warranted by the evidence.
