# Axiom and trust audit — v0.2.0-composition

Audit target: Lean 4.34.0, `P10Core.Proofs.Composition`.

## Source scan

All `.lean` sources were scanned. They contain no `sorry`, `admit`, or
user-declared `axiom` command.

## Lean kernel report

```text
'P10Core.Proofs.FourEvidence.checkCert_sound' depends on axioms: [propext, Quot.sound]
'P10Core.Proofs.Composition.conditionalComposition' does not depend on any axioms
'P10Core.Proofs.Composition.fourEvidenceComposes' depends on axioms: [propext, Quot.sound]
'P10Core.Proofs.Composition.missingCertificateCannotCompose' does not depend on any axioms
'P10Core.Proofs.Composition.failedContractCannotCompose' does not depend on any axioms
'P10Core.Proofs.Composition.brokenFidelityCannotCompose' depends on axioms: [propext]
```

`conditionalComposition` itself is constructive once its six named obligations
are supplied. `fourEvidenceComposes` discharges those obligations and inherits
only the standard Lean foundations already reported by the unchanged seed
theorem.

## Explicit residual premise

`DigestModel.injective : Function.Injective digest` remains the explicit
domain-specific premise. It is a structure field supplied to the theorem, not a
global or hidden axiom. No new residual premise is introduced by composition.

## Frozen-seed verification

The original `P10Core/Proofs/FourEvidence.lean` and
`P10Core/Model/Calculus.lean` compare byte-for-byte equal with the frozen seed.
The full seed tree was hashed before and after implementation and its manifest
did not change.

## Claim boundary

`GlobalSupport.protocolSupport` extracts the existing `Supports` judgement.
Neither the type nor any composition theorem contains `Truth_M`.
