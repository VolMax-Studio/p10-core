import P10Core

namespace GateProbe

open P10Core.Spec P10Core.Model
open P10Core.Instances.FourEvidence
open P10Core.Instances.FourEvidence.Composition
open P10Core.Proofs.Composition

/- Probe A: a chain whose evidence does NOT satisfy the claim.
   If it still composes, GlobalSupport is not a verification. -/

def P : Protocol := { id := 7 }
def cA : Claim := { expected := 4, operationalizable := true }
def eA : Evidence := { entries := [true, true, true], externalReady := true, admissible := true }

def κA : Certificate :=
  { protocolId := P.id, boundClaim := cA, boundEvidence := eA,
    preflight := runPreflight eA, target := formalize cA,
    checked := inspect eA, verdict := .notDemonstrated }

def a0 : Stage0 := { claim := cA, evidence := eA }
def a1 : Stage1 := { claim := cA, evidence := eA, target := formalize cA }
def a2 : Stage2 := { claim := cA, evidence := eA, checked := inspectTarget (formalize cA) eA }
def a3 : Stage3 := { claim := cA, evidence := eA, checked := a2.checked,
                     certificate := κA, verdict := .notDemonstrated }

theorem probeA_composes :
    Composable concreteDigestModel P
      (some { targetWitness := a1.target })
      (some { checkedWitness := a2.checked })
      (some { certificateWitness := κA }) a0 a1 a2 a3 := by
  refine ⟨by decide, by decide, by decide⟩

theorem probeA_globalSupport : GlobalSupport P a0 a1 a2 a3 :=
  fourEvidenceComposes concreteDigestModel P _ _ _ a0 a1 a2 a3 probeA_composes

theorem probeA_claim_is_false : ¬verifiedSem (cA, eA) :=
  verifiedRule_false (cA, eA) (by decide)

/- Probe B: same false evidence, but the certificate asserts `verified`.
   The checker must reject it. -/

def κB : Certificate := { κA with verdict := .verified }
def b3 : Stage3 := { a3 with certificate := κB, verdict := .verified }

theorem probeB_check3_rejects :
    check3 concreteDigestModel P (some { certificateWitness := κB }) a2 b3 = false := by
  decide

/- Probe C: certificate whose target is stale (formalized from a different claim). -/

def cStale : Claim := { expected := 9, operationalizable := true }
def κC : Certificate := { κA with target := formalize cStale }
def c3 : Stage3 := { a3 with certificate := κC }

theorem probeC_check3_rejects :
    check3 concreteDigestModel P (some { certificateWitness := κC }) a2 c3 = false := by
  decide

/- Probe D: transition certificate that does not commit to the stage it certifies. -/

theorem probeD_check1_rejects :
    check1 (some { targetWitness := formalize cStale }) a0 a1 = false := by
  decide

/- Probe E: the safety property that actually matters.
   A `verified` verdict anywhere in a composed chain forces the semantic condition. -/

theorem probeE_verified_forces_conditions
    (Q : Protocol) (y0 : Stage0) (y1 : Stage1) (y2 : Stage2) (y3 : Stage3)
    (h : GlobalSupport Q y0 y1 y2 y3)
    (hv : y3.verdict = .verified) :
    verifiedSem (y3.claim, y3.evidence) := by
  have hs := GlobalSupport.protocolSupport h
  rw [hv] at hs
  exact P10Core.Proofs.FourEvidence.supports_verified_implies_conditions
    Q y3.evidence y3.claim y3.certificate hs

/- Probe F: and it transports back to Stage0. -/

theorem probeF_verified_forces_conditions_at_origin
    (Q : Protocol) (y0 : Stage0) (y1 : Stage1) (y2 : Stage2) (y3 : Stage3)
    (h : GlobalSupport Q y0 y1 y2 y3)
    (hv : y3.verdict = .verified) :
    verifiedSem (y0.claim, y0.evidence) := by
  have hc := h.claimPreserved
  have he := h.evidencePreserved
  have hcond := probeE_verified_forces_conditions Q y0 y1 y2 y3 h hv
  rw [hc, he] at hcond
  exact hcond

end GateProbe
