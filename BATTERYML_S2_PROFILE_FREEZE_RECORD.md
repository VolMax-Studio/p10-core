# BatteryML S2 Domain Profile v0.1 Freeze Record

**Record Identifier:** `RECORD-P10-PROFILE-BATTERYML-S2-FREEZE-v0.1`  
**Date:** 2026-09-20  
**Authority:** VolMax Studio Lab & Adjudication Working Group  
**Status:** **FROZEN FOR RETROSPECTIVE REPLAY**  
**Tag:** `batteryml-s2-profile-v0.1-retro-freeze`  

---

## 1. Provenance & Cryptographic Lineage

This freeze record seals the **BatteryML Domain Profile (v0.1)** under the Triple-Anchor Provenance Model:

| Anchor | Description | Canonical Cryptographic Identity |
|---|---|---|
| **Frozen S2 Core** | Lean 4 Adjudication Core & Metatheory | `fa7878a538f56ee9b3c8008ca71e93c04c69ecf4` (Tag: `v0.3.0-s2-freeze`) |
| **Profile Source Commit** | DomainAdapter & Profile Source Repository | `dd88e6222fc717b557b7b5c2ebf6b1d725b50891` (Tag: `batteryml-s2-profile-v0.1-retro-freeze`) |
| **Profile Spec SHA-256** | `spec/profiles/P10-BatteryML-S2-Profile-v0.1.md` | `d120f64339cd4a5eac8dd8ff26a3501986cdd7a36ddaa5632747bc84b0468f49` |

---

## 2. Hardening Invariants & Semantic Knots Resolved

The v0.1 profile was frozen after resolving all four semantic knots:

1. **Direct `protocolFault` Disentanglement:**
   - In the frozen S2 semantic core (`fa7878a...`), obligation status `EvalStatus.checkerError` maps bijectively and strictly to `ProtocolError(checkerFailure)`.
   - Domain-level protocol faults (`integrityFailure`, `prematureExecution`, `targetMutation`, `environmentMismatch`, `preregistrationFracture`) cannot be triggered via obligation statuses; they must be and are directly populated into `DecisionView.protocolFault` by the domain adapter prior to adjudication.
2. **Total and Deterministic `O_FIT_COUNT` Partitioning:**
   - Discretionary or ambiguous conditions have been eliminated.
   - Fits $N = K \times M \implies \texttt{Satisfied}$.
   - Fits $N < K \times M$ with documented external host interruption (timeout, OOM killer signal, cloud quota termination) $\implies \texttt{Blocked}$ (evaluates to $\texttt{Deferred}$).
   - Fits $N < K \times M$ with completed execution (returncode 0 or internal worker crash) without external bloker $\implies \text{adapter sets } \texttt{DecisionView.protocolFault} := \operatorname{some}(\operatorname{S2ProtocolError}.\text{prematureExecution})$.
   - Matrix artifact absent $\implies \texttt{Missing}$ (evaluates to $\texttt{NotDemonstrated}$).
   - Checker script crash over admissible matrix $\implies \texttt{CheckerError}$ (evaluates to $\operatorname{ProtocolError}(\texttt{checkerFailure})$).
3. **Mutual Exclusivity: Admissibility Gate vs. Checker Failure:**
   - Inadmissible raw artifacts (malformed JSON/CSV, schema mismatch, corrupt formatting) are rejected at the admissibility gate, producing $\operatorname{Eval}(E, o) = \texttt{Missing}$ (deterministically adjudicating to `NotDemonstrated`).
   - Checker failure (`EvalStatus.checkerError`) is reserved strictly for internal faults or unhandled exceptions thrown by the verification tool itself when inspecting an admitted, valid artifact.
4. **Epistemic Integrity in Limitation Registry:**
   - `L_TEMPERATURE_DRIFT` is excised from the v0.1 limitation registry because the current obligation space does not include continuous chamber telemetry. `hasBlockingLimitation = false` must strictly mean "verified not applicable", never "unmeasured/missing data".

---

## 3. Epistemic Demarcation

$$\boxed{\textbf{RETROSPECTIVE CONFORMANCE DEPLOYMENT} \neq \textbf{NEW CONFIRMATORY BATTERY RESULT}}$$

1. **No Confirmatory Scientific Claim:** This freeze governs the retrospective replay of historical artifacts (e.g. `batteryml-protocol-robustness-s3`). Because experimental results were known prior to profile authoring, this deployment serves solely as a demonstration of domain adapter correctness, witness aggregation validity, and automaton determinism.
2. **Profile Immutability During Replay:** The profile and adapter shall not be tuned, relaxed, or patched to achieve a favored outcome during replay.
3. **Neutrality of Outcome:** If the replay yields `ProtocolError`, `Deferred`, `NotDemonstrated`, or `NotVerified`, that outcome is accepted as an authoritative, successful execution of the S2 protocol.
