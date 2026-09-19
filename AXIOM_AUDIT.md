# Axiom and trust audit

Audit target: Lean 4.34.0, `P10Core.Proofs.FourEvidence`.

## Source scan

The project contains no `sorry`, `admit`, or user-declared `axiom` command.

## Lean kernel report

Running:

```lean
#print axioms P10Core.Proofs.FourEvidence.checkCert_sound
#print axioms P10Core.Proofs.FourEvidence.verified_not_notDemonstrated
```

returns:

```text
'P10Core.Proofs.FourEvidence.checkCert_sound' depends on axioms: [propext, Quot.sound]
'P10Core.Proofs.FourEvidence.verified_not_notDemonstrated' does not depend on any axioms
```

`propext` and `Quot.sound` are standard foundations exposed by Lean's own axiom
report. They are recorded here rather than hidden under the phrase “no axioms.”

## Domain-specific premise

`checkCert_sound` quantifies over a `DigestModel`. Its field

```lean
injective : Function.Injective digest
```

is the explicit external premise that permits equal evidence digests to imply
equal evidence values. It is not installed as a global axiom and can later be
replaced by a concrete digest model plus an appropriately scoped assumption or
proof.

## Current theorem boundary

The proof establishes checker soundness for the synthetic `FourEvidence`
instance only. It does not establish cryptographic collision resistance,
semantic truth of arbitrary claims, global P10 soundness, or the later
transition-composition theorem.
