# GATE RESULT — P10-Core v0.2.1-gatefix (Claude Gate 002)

## What I executed myself (not transcribed)

| Action | Result |
|---|---|
| `sha256sum` of submitted ZIP | `88119390bdf1dbdbb213f73e81a342651b6d7a136b3b630f5b0dac250922fbe1` — matches `.sha256` |
| `sha256sum -c manifests/SHA256SUMS_v0.2.1-gatefix` | 22/22 OK, before and after my build |
| Baseline archive digest | `a86501aab0f3…` — matches its `.sha256` |
| Downloaded Lean `v4.34.0` (github release asset), `lake build` | **12/12 jobs, build completed successfully**; commit `293d5d0c0c3f3dded4688b3ccd6a33939ac5102b` |
| `#eval` output during build | `true` / `true` / `true` |
| `lake env lean audit/AxiomAudit.lean` | **17/17 lines identical to the published `AXIOM_AUDIT.md` table** |
| `grep` for `sorry`/`admit`/`axiom`, and for `Truth_M` | none in any `.lean`; `Truth_M` appears only in prose |
| Byte-diff v0.2.0 → v0.2.1 across every baseline file | see G-01 |
| Wrote and compiled my own 6-theorem adversarial probe against the built library | compiles clean, exit 0 — see G-05/G-06 |

The artifact was not modified: the manifest re-verifies 22/22 after the build.

---

## Disposition of Gate 001 findings

**C-01 complete artifact — DISCHARGED.** All 12 modules present and read: `Spec/Core`, `Model/Rules`, `Model/Calculus`, `Instances/FourEvidence/{Model,Checker,Composition}`, `Proofs/{FourEvidence,Composition,PositiveWitness}`, `audit/AxiomAudit`. The previously unseen `checkCert_sound` contains no hidden assumption: it consumes only `CheckCert = true` and `D.injective`, and case-splits exhaustively on `operationalizable / externalReady / verifiedRule.check`.

**C-02 toolchain and axiom report — DISCHARGED, independently.** I built it and ran the audit. The published table is accurate line for line. This is the first claim in this project's Lean track that I can report as measured rather than reported.

**C-03 hashes — DISCHARGED for the gatefix, NOT for the baseline.** See G-02.

**C-09 non-vacuity — DISCHARGED, but by a method that needs disclosing.** `concreteDigestModel` is inhabited, `positiveComposable` and `positiveGlobalSupport` are machine-checked, and the positive chain is substantive: `c0.expected = 4`, `e0.entries = [true,true,true,true]`, so `verifiedSem` genuinely holds and the verdict is genuinely `.verified`. See G-01 for the cost.

**C-04 inert flags — FIXED, with a precise residual.** Free booleans are gone; `TransitionCertificate1/2/3` carry `targetWitness` / `checkedWitness` / `certificateWitness`, compared against the stage output. I confirmed the witness is load-bearing *for acceptance*: probe D proves `check1 (some {targetWitness := formalize cStale}) a0 a1 = false`. Residual (documentation only): no theorem's *conclusion* depends on the witness — `localSound1` discards `agreement.1`. Certificates now identify what they certify; they still add no premise to any proved statement.

**C-05 missing-certificate coverage — FIXED.** `Option.none` at all three positions, three theorems.

**C-06 "semantic contract" — FIXED.** Renamed `AgreementRel1/2` with doc comments explicitly disclaiming adequacy.

**C-07 inert middle stages — FIXED substantively.** `Stage2.checked : TargetChecked` now carries `{target, result}`; `AgreementRel2` is target-indexed; `AgreementRel3` is binary in `(x2,x3)` and forces `x3.certificate.target = x2.checked.target` and `x3.certificate.checked = x2.checked.result`. The chain now closes: `x1.target = formalize x0.claim → x2.checked.target = x1.target → κ.target = x2.checked.target`. Probe C confirms a stale certificate target is rejected (`check3 = false`).

**C-08 weak negative statements — FIXED.** All five negative theorems now conclude `¬Composable`.

**C-10 axiom scan coverage — FIXED and verified.** All six obligations plus the conjunction plus the witnesses.

**C-11 paths — FIXED for the gatefix ZIP.** Not for the embedded baseline: see G-02.

---

## NEW FINDINGS

**G-01 — the frozen seed *was* modified; the release says it was not**
- Severity: MAJOR · Class: claim-boundary + frozen-rule change (doctrine Check 6)
- Location: `P10Core/Instances/FourEvidence/Model.lean`; claim in `GATE_RESPONSE.md` §Frozen predecessor
- Claim affected: "the gatefix **only** supplies a concrete synthetic digest implementation and replaces the composition layer"
- Evidence (`diff -u` of baseline vs gatefix):
```diff
-structure Digest where
-  value : Nat
+structure Digest where
+  evidence : Evidence
```
  Hash: `239bf4595be4…` → `1563e8de798b…`. This is not the supply of an implementation — it is a redefinition of the `Digest` type, moved to after `Evidence` so it can reference it. `Proofs/FourEvidence.lean` is byte-identical (`9456512e6b0a…` in both), but byte-identity of a dependent file does not preserve its proposition when a dependency's *type* changed: `checkCert_sound` in v0.2.1 quantifies over a different `Digest`.
- Second-order consequence, and the one worth stating plainly: the residual premise `DigestModel.injective` was not discharged — it was made trivially satisfiable by widening the type until no compression occurs (`injective := by intro a b h; cases h; rfl`). `AXIOM_AUDIT.md` correctly says "does not claim cryptographic collision resistance," but neither it nor `README.md` says the digest *type* changed, which is what makes injectivity free. Under this model the digest is the identity on evidence and the digest step asserts nothing.
- Minimal fix: a Parametric Changelog entry (old definition, new definition, reason) and one sentence in README: the digest abstraction is now lossless by type, so non-vacuity is demonstrated for a model in which digesting is a no-op.

**G-02 — `BASELINE_MANIFEST.sha256` does not verify against the archive it ships inside**
- Severity: MAJOR · Class: reproducibility / provenance (doctrine Check 1)
- Location: `baselines/P10-Core-v0.2.0-composition.zip → BASELINE_MANIFEST.sha256`; claim in `GATE_RESPONSE.md`: "Its pre/post manifests compare equal"
- Evidence: every path in that file is an absolute path on the author's machine (`/home/volmax-studio/Documents/Codex/2026-09-19/…/outputs/P10-Core/…`), so `sha256sum -c` fails 12/12 anywhere else. Resolving paths by hand, 4 of 12 entries mismatch the archive they ship in:

| file | manifest | actual |
|---|---|---|
| `AXIOM_AUDIT.md` | `a5d39c315f86` | `6d8e1168f6e1` |
| `P10Core.lean` | `aeac638aa3bd` | `5dfe589a490d` |
| `README.md` | `a8cc561e8843` | `581f97a687f2` |
| `lakefile.toml` | `ef68b63f504f` | `550d0d343abe` |

  And it covers neither `P10Core/Instances/FourEvidence/Composition.lean` nor `P10Core/Proofs/Composition.lean` — the two files that *are* the v0.2.0 release — nor `RELEASE_NOTES.md`. The file is almost certainly the v0.1.0 seed snapshot, shipped under a name that asserts it describes v0.2.0.
- The underlying substantive claim is nonetheless TRUE and I verified it independently: `Checker.lean`, `Model/Calculus.lean`, `Model/Rules.lean`, `Proofs/FourEvidence.lean`, `Spec/Core.lean` are `cmp`-identical across the two trees. The claim is right; the evidence file shipped to support it is wrong. That is exactly the failure mode this project has logged before.
- Minimal fix: regenerate with repo-relative paths, over the correct tree, and delete the sentence "pre/post manifests compare equal" or scope it to the seed subset.

**G-03 — manifests are not self-covered**
- Severity: MINOR · Class: reproducibility
- Evidence: `manifests/SHA256SUMS_v0.2.0-composition` is not hashed by any shipped manifest, and nothing outside the ZIP digest attests it. The ZIP digest does cover it transitively; a per-file anchor would be cheaper to check.

**G-04 — the instance collapses four predicates the generic calculus distinguishes**
- Severity: MAJOR · Class: claim-boundary (undisclosed)
- Location: `Instances/FourEvidence/Model.lean`, `def semantics`
- Evidence: `runCompleted := fun _ _ => True`, `checksSucceeded := fun _ _ => True`. `Supports.verified` demands eight premises; in this instance two of them are discharged in `checkCert_sound` by `trivial`. Also `evaluable` and `operationalizable` are the same function, and `noProtocolFault c e := e.admissible = true` is already implied by `preflightOK`. So `Model/Calculus.lean` presents a 13-predicate semantics of which this instance gives four of them zero or redundant content. Nothing is wrong with the proofs; the disclosure is missing. README should say which predicates are inhabited non-trivially in the FourEvidence instance.

**G-05 — `GlobalSupport` is inhabited by chains whose claim is false; nothing says so**
- Severity: MINOR · Class: documentation
- Evidence: I proved it. In my probe, `cA.expected = 4` with `eA.entries = [true,true,true]`:
```lean
theorem probeA_globalSupport : GlobalSupport P a0 a1 a2 a3
theorem probeA_claim_is_false : ¬verifiedSem (cA, eA)
```
  Both compile. The chain composes end to end with verdict `notDemonstrated`. This is correct behaviour — `GlobalSupport` means the protocol *judgement* is supported, not that the claim is verified — and it is exactly what P10's abstention vocabulary should do. But README's "Load-bearing chain" diagram terminating in `Supports` invites the opposite reading. One sentence fixes it.

**G-06 — the release proves a stronger theorem than it states (constructive)**
- Severity: MINOR · Class: claim-boundary, in the release's favour
- Evidence: from shipped material only, in six lines, I proved what should be the headline:
```lean
theorem probeF_verified_forces_conditions_at_origin
    (h : GlobalSupport Q y0 y1 y2 y3) (hv : y3.verdict = .verified) :
    verifiedSem (y0.claim, y0.evidence)
```
  A composed chain that ends in `verified` forces the semantic condition **on Stage 0's original claim and evidence**. That is the property worth publishing; `GlobalSupport` alone is the weaker wrapper. Recommend promoting it into `Proofs/Composition.lean` and into the README.

**G-07 — witness data gates acceptance but appears in no conclusion**
- Severity: MINOR · Class: documentation
- Evidence: probe D shows the witness is checked (`check1 … = false` on mismatch), while `localSound1`'s proof discards `agreement.1`. Accurate phrasing for README: transition certificates bind a certificate to the stage it certifies; they are not premises of any proved statement.

---

## CLEAN (checked, held, with the evidence)

- **Item 1 — non-vacuity: now demonstrated, not asserted.** `positiveCheck1/2/3` evaluate to `true` under my own build; `positiveGlobalSupport` is machine-checked; `Composable` is inhabited.
- **Item 2 — obligations.** `CompositionObligations` is exactly the six-fold conjunction; `compositionObligations` supplies all six; no seventh.
- **Item 3 — no hidden assumptions.** Now verifiable and verified: `checkCert_sound` takes `CheckCert = true` plus the structure field `D.injective` and nothing else. No `sorry`, `admit`, or user `axiom` in any file. Axiom footprint is `propext` / `Quot.sound` only, reproduced by me.
- **Item 4 — no `Truth_M`.** Confirmed by grep across all `.lean` sources: the identifier does not exist. `Supports` bottoms out in `Semantics.verifiedConditions`, instantiated to `verifiedSem (c,e) := (inspect e).satisfying = c.expected` — an internal, decidable arithmetic condition on the synthetic model, not an external truth predicate. The distinction the release draws is real.
- **Item 5 — negative theorems bite.** All five now conclude `¬Composable`, and `failedAgreementCannotCompose` / `brokenFidelityCannotCompose` are genuine contrapositives of `localSound2` / `fidelity3`. My probes B, C, D independently exhibit three concrete rejections by evaluation rather than by proof.
- **Item 6 — fidelity is not trivial.** All fidelity relations are structural equalities between fields of identical types. No index transport, no `cast`, no `Eq.mpr`, no `HEq`, no unconstrained witness. Stage2 is uniquely determined by Stage1 (`AgreementRel2` pins `checked` wholly, `FidelityRel2` pins `claim`/`evidence`); Stage3's certificate is pinned by `CheckCert` on every field.
- **Items 8, 9 (seed subset) — verified by hash and by `cmp`.**
- **Item 10 — no counterexample found, and this is not proof.** I attempted five constructions; the checker rejected the three malformed ones and the two that composed did so correctly. The chain is tight where I could push on it.

---

## VERDICT: **PASS WITH LIMITATIONS**

The Lean artifact passes. No finding is theorem-breaking; all four Gate 001 blockers are materially discharged, and for the first time in this track I discharged the build and the axiom audit by executing them rather than reading a transcript.

The limitations are not in the code — they are in two prose documents that assert things the bytes contradict:

1. **`GATE_RESPONSE.md` must be corrected before publication** (G-01, G-02). Two statements in it are false as written: "only supplies a concrete synthetic digest implementation" (the `Digest` type was redefined) and "Its pre/post manifests compare equal" (they do not; 4 mismatches and 4 uncovered files). The underlying claims are defensible; the sentences are not.
2. **`BASELINE_MANIFEST.sha256` must be regenerated** with repo-relative paths over the correct tree (G-02).
3. **A Parametric Changelog entry for the `Digest` type change** (G-01), plus one README sentence that the digest abstraction is now lossless by type.
4. **Disclose the collapsed predicates** (G-04) and add the two clarifying sentences (G-05, G-07).
5. **Promote `probeF` into the release** (G-06) — it is the theorem worth publishing.
