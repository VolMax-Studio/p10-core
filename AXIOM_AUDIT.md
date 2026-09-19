# Axiom audit — v0.2.1-gatefix

Lean version: 4.34.0.

All `.lean` sources contain no `sorry`, `admit`, or user-declared `axiom`.

## `#print axioms` results

```text
checkCert_sound: [propext, Quot.sound]
localSound1: [propext]
localSound2: [propext]
localSound3: [propext, Quot.sound]
fidelity1: [propext]
fidelity2: [propext]
fidelity3: [propext]
compositionObligations: [propext, Quot.sound]
conditionalComposition: []
fourEvidenceComposes: [propext, Quot.sound]
missingCertificate1CannotCompose: [propext]
missingCertificate2CannotCompose: [propext]
missingCertificate3CannotCompose: [propext]
failedAgreementCannotCompose: [propext]
brokenFidelityCannotCompose: [propext]
positiveComposable: []
positiveGlobalSupport: [propext, Quot.sound]
```

These are Lean's surfaced foundational dependencies. No opaque local soundness
assumption is used. `conditionalComposition` is constructive once the six named
obligations are supplied; `compositionObligations` proves those obligations for
this instance.

## Digest boundary

The old generic theorem still accepts `DigestModel.injective` explicitly. The
positive model supplies `concreteDigestModel`, whose digest contains the full
synthetic `Evidence` value and whose injectivity is proved. It demonstrates
inhabitation and non-vacuity; it does **not** claim cryptographic collision
resistance.
