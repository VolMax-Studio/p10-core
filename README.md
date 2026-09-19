# P10-Core v0.2.1-gatefix

Adversarial-gate remediation for the frozen `v0.2.0-composition` release.
The prior release remains unchanged and is recorded as `BLOCKED — Claude Gate
001`; the original report is included under `reviews/`.

## What changed

- Added a concrete inhabited `DigestModel`. Its digest is lossless synthetic
  data, not a cryptographic hash; injectivity is proved by construction.
- Added an executable positive chain whose three checks evaluate to `true`, a
  `positiveComposable` term, and a machine-checked `positiveGlobalSupport`.
- Replaced inert transition flags with typed witness-bearing certificates.
  Certificate absence is represented by `Option.none`.
- Renamed the first two transition relations from semantic contracts to
  `AgreementRel1/2`; they prove agreement with `formalize` and target-indexed
  `inspectTarget`, not external semantic adequacy.
- Made Stage2 explicitly depend on the Stage1 formal target.
- Made Stage3 and its final P10 certificate commit to the exact Stage2 target
  and checked result.
- Strengthened adversarial conclusions to `¬Composable`.
- Added missing-certificate theorems for all three transitions.
- Expanded `#print axioms` coverage to all six local obligations,
  `compositionObligations`, composition theorems, adversarial theorems, and
  positive witnesses.

## Load-bearing chain

```text
Stage0 (claim, evidence)
  -- formalize -->
Stage1 (formal target)
  -- inspectTarget(target, evidence) -->
Stage2 (target-bound checked result)
  -- certificate commits to Stage2 -->
Stage3 (P10 certificate, verdict)
  -- unchanged CheckCert -->
Supports
```

`AgreementRel3 P x2 x3` is binary and requires:

1. Stage3 carries the exact Stage2 checked object;
2. the final certificate target equals the Stage2 target;
3. the final certificate checked result equals the Stage2 result;
4. the unchanged seed checker establishes `Supports`.

`GlobalSupport.protocolSupport` returns only that `Supports` judgement. No
`Truth_M` predicate exists in the Lean sources.

## Positive executable trace

`P10Core/Proofs/PositiveWitness.lean` defines concrete values for the digest
model, protocol, claim, evidence, certificate, four stages, and three transition
certificates. During `lake build`, all three `#eval` lines print:

```text
true
true
true
```

## Build

Pinned toolchain: Lean 4.34.0.

```sh
lake build
```

See `GATE_RESPONSE.md`, `AXIOM_AUDIT.md`, `manifests/`, and the complete ZIP
artifact for independent reproduction. `baselines/` contains a separately
hashed, complete snapshot of the unchanged `v0.2.0-composition` predecessor.
