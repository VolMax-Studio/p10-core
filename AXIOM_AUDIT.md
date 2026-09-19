# Axiom audit — v0.2.2-gateclosure

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
verifiedGlobalSupport_implies_originConditions: []
```

These are Lean's surfaced foundational dependencies. No opaque local soundness
assumption is used. `conditionalComposition` and `verifiedGlobalSupport_implies_originConditions`
depend on **zero axioms**. `compositionObligations` proves the six named
obligations for this instance using standard foundational Lean axioms (`propext`, `Quot.sound`).

## Digest boundary (G-01 Disclosure)

The generic theorem accepts `DigestModel.injective` explicitly. The
positive model supplies `concreteDigestModel`, whose digest contains the full
synthetic `Evidence` value (`structure Digest where evidence : Evidence`) and
whose injectivity is proved constructively without axioms (`by intro a b h; cases h; rfl`).
It demonstrates mathematical inhabitation and non-vacuity for a lossless synthetic model;
it does **not** claim cryptographic collision resistance.

