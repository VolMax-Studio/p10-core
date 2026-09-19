# GATE RESULT — P10-Core v0.2.0-composition (adversarial external gate)

- **Target Commit:** `b4aef60`
- **Target Tag:** `v0.2.0-composition`
- **Reviewer:** Claude (Adversarial External Gatekeeper)
- **Date:** 2026-09-19
- **Verdict:** `BLOCKED`

---

## Scope Actually Reviewable

Received: `README.md`, `RELEASE_NOTES.md`, `AXIOM_AUDIT.md`, `P10Core.lean`, plus pasted Lean sources (`Instances/FourEvidence/Composition.lean` and `Proofs/Composition.lean`).

**Not received in evaluation container:** `P10Core/Spec/*`, `P10Core/Model/Calculus.lean`, `Instances/FourEvidence/Checker.lean`, `Proofs/FourEvidence.lean`, `lakefile.*`, `lean-toolchain`, `lake-manifest.json`, standalone bundle `SHA256SUMS`. Every load-bearing identifier (`Supports`, `semantics`, `Truth_M`, `CheckCert`, `checkCert_sound`, `DigestModel`, `formalize`, `inspect`, `Claim`, `Evidence`, `Certificate`, `Verdict`) is defined in seed files.

---

## BLOCKERS

**C-01 — Five of ten gate items are undischargeable from the shipped set**
- Severity: BLOCKER · Class: reproducibility + claim-boundary
- Location: artifact set as a whole
- Claim affected: task items 3, 4, 7, 9, 10
- Evidence: uploaded set lacked full seed dependencies. `Proofs/Composition.lean` line 24 calls `FourEvidence.checkCert_sound`, whose full definition was not in the reviewed container. Item 3 ("does not hide equivalent assumptions elsewhere") and Item 4 (`Truth_M` definition audit) cannot be fully discharged without the complete seed.

**C-02 — Toolchain pin and build are agent self-reports**
- Severity: BLOCKER · Class: reproducibility
- Location: `README.md` §Build — "Pinned toolchain: Lean 4.34.0"; `AXIOM_AUDIT.md` §Lean kernel report
- Evidence: no `lean-toolchain`, no `lakefile`, no `lake-manifest.json` in the evaluated upload. The six `#print axioms` lines are transcribed text, not reproduced output in that container. An agent stating "`does not depend on any axioms`" is a claim, not proof, until the checker is run against a pinned toolchain.

**C-03 — Byte-identity claim published without a single digest**
- Severity: BLOCKER · Class: reproducibility
- Location: `AXIOM_AUDIT.md` §Frozen-seed verification
- Claim affected: "compare byte-for-byte equal with the frozen seed"; "the full seed tree was hashed before and after implementation and its manifest did not change"
- Evidence: the section asserts a hash comparison and then publishes no hash, no manifest, and no manifest path in the text. A byte-identity claim that carries no digest is unverifiable by construction. Minimal fix: publish `SHA256SUMS` for the seed tree at `v0.1.0-four-evidence` and at `v0.2.0-composition`, plus the diff command.

**C-09 — Non-vacuity is undemonstrated at two independent points**
- Severity: BLOCKER · Class: theorem-boundary (vacuity risk, unresolved)
- Location: `Proofs/Composition.lean` — `fourEvidenceComposes`; `Instances/.../Composition.lean` — `Composable`
- Claim affected: task item 1 ("is not vacuous")
- Evidence (a): the release contains no `example`, no `#eval`, no witness exhibiting any tuple with `Composable D P τ1 τ2 τ3 x0 x1 x2 x3`. If `CheckCert` is never `true` on any input, `fourEvidenceComposes` is vacuously true and the release proves nothing.
- Evidence (b), sharper: every main and adversarial theorem is universally quantified over `(D : DigestModel)`, and `AXIOM_AUDIT.md` states the residual premise is `DigestModel.injective : Function.Injective digest`. **No inhabitant of `DigestModel` is exhibited anywhere in the set.** If `digest` has a fixed-width codomain over an unbounded `Evidence` domain, injectivity is false by pigeonhole, `DigestModel` is empty, and all six theorems are vacuously true — including the three adversarial ones. Minimal fix: ship `example : DigestModel := …` and one positive `#eval check3 … = true` trace.

---

## FIXES (not blocking, but the README is ahead of the proofs)

**C-04 — `TransitionCertificate` fields are semantically inert**
- Severity: MAJOR · Class: claim-boundary
- Location: `Instances/.../Composition.lean` — `TransitionCertificate`, `transitionGate`, `check1/2/3`
- Claim affected: README — "an explicit transition certificate with presence, contract, and fidelity flags"
- Evidence: `transitionGate τ := τ.present = true ∧ τ.contractOK = true ∧ τ.fidelityOK = true`. Nothing connects `contractOK` to `ContractRelᵢ` or `fidelityOK` to `FidelityRelᵢ` — the relations are decided independently as separate conjuncts of `checkᵢ`. So the three booleans are free flags: an adversary sets them `true` at zero cost. The certificate carries no evidence; it is a gate flag wearing the word "certificate."

**C-05 — `missingCertificateCannotCompose` excludes a boolean, not a missing certificate**
- Severity: MAJOR · Class: claim-boundary
- Location: `Proofs/Composition.lean` — `missingCertificateCannotCompose`
- Claim affected: README — "adversarial non-composition theorems for missing certificates"
- Evidence: the hypothesis is `τ1.present = false` and the proof is `rw [hMissing]; contradiction` — it covers only `τ1` and only the `present` field. `τ2`, `τ3`, `contractOK`, and `fidelityOK` are uncovered.

**C-06 — `ContractRel1/2` are function-agreement equations, not semantic contracts**
- Severity: MAJOR · Class: claim-boundary
- Location: `Instances/.../Composition.lean` — `ContractRel1`, `ContractRel2`
- Claim affected: README — "a semantic `ContractRelᵢ`"
- Evidence: `ContractRel1 x0 x1 := x1.target = formalize x0.claim`; `ContractRel2 x1 x2 := x2.checked = inspect x1.evidence`. These are syntactic equality against a designated total function. `LocalSound1/2` therefore establish only "the stage output equals `formalize`/`inspect` applied to the stage input" — adequacy of `formalize` is neither stated nor proved. Suggested rename: `AgreementRelᵢ`.

**C-07 — Stages 1 and 2 do not constrain the conclusion**
- Severity: MAJOR · Class: claim-boundary
- Location: `Instances/.../Composition.lean` — `ContractRel3`, `GlobalSupport.protocolSupport`; `check3`
- Claim affected: README — "bounded four-stage, three-transition typed chain"
- Evidence: `ContractRel3 P x3` is unary in stages — it ignores `x2` entirely, unlike `ContractRel1/2`. `CheckCert D P x3.claim x3.evidence x3.certificate x3.verdict` never reads `target` or `checked`. `GlobalSupport.protocolSupport` is literally `h.local3`. Net: the entire content of `conditionalComposition` beyond the frozen seed theorem is two `Eq.trans` chains transporting `claim` and `evidence` from `x3` back to `x0`. The verdict is asserted at the endpoint and endpoint identity is carried back; it is not carried *through* stages 1 and 2. `localSound3` and `fidelity3` both bind `τ` and `x2` and then use neither in the conclusion.

**C-08 — The three negative theorems are stated weaker than their own proofs support**
- Severity: MAJOR · Class: theorem-statement-weaker-than-claim
- Location: `Proofs/Composition.lean` — all three adversarial theorems
- Evidence: each concludes `¬CompositionWitness …`, where `CompositionWitness` is `checks ∧ global`. All three proofs use only `h.checks.1`, `h.checks.2.1`, `h.checks.2.2` — never `h.global`. They therefore prove the strictly stronger `¬Composable …`. Minimal fix: restate with `Composable` as the negated hypothesis.

**C-10 — Axiom scan is narrower than the audit's own method**
- Severity: MINOR · Class: reproducibility
- Location: `AXIOM_AUDIT.md` §Lean kernel report
- Evidence: `#print axioms` is published for six theorems but not for `localSound1..3`, `fidelity1..3`, or `compositionObligations`. Substantively covered transitively via `fourEvidenceComposes` `[propext, Quot.sound]`, so no gap in fact; a gap in the audit documentation.

**C-11 — File→path mapping is not established**
- Severity: MINOR · Class: documentation/provenance
- Evidence: provenance defect in submission bundle.

---

## CLEAN (checked, held — within reviewed files)

- **Item 2 holds exactly:** `CompositionObligations D P` consists of the six intended obligations.
- **Item 6 attack surface is clean:** `FidelityRel1/2/3` are plain structural equalities between fields of identical types. No index transport, no `cast`, no `Eq.mpr` coercion, no `HEq`, no unconstrained existential witness, no type-equality shortcut. Fidelity is not trivially satisfiable.
- **Identity chains typecheck by inspection:** `x3.claim = x0.claim` and `x3.evidence = x0.evidence` via `Eq.trans`.
- **No illicit `decide` on an undecidable proposition:** `ContractRel3` deliberately routes through `CheckCert`.
- **No `sorry`, `admit`, or `axiom` in reviewed files.**
- **`RELEASE_NOTES.md` "Not claimed" block is correctly scoped:** semantic truth, global P10 soundness, collision resistance, unbounded-chain composition are all genuinely not proved, and the release explicitly says so.

---

## VERDICT: **BLOCKED**

Blocked on C-01, C-02, C-03, C-09. Nothing theorem-breaking found in reviewed code; block is based on incomplete bundle, unexecuted build/axiom audits, missing digest for byte-identity, and unproven non-vacuity.
