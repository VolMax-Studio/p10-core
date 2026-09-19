import P10Core.Proofs.Composition
import P10Core.Proofs.PositiveWitness

namespace GateProbe

open P10Core.Spec P10Core.Model
open P10Core.Instances.FourEvidence
open P10Core.Instances.FourEvidence.Composition
open P10Core.Proofs.Composition
open P10Core.Proofs.PositiveWitness

-- Protocol
def P : Protocol := { id := 7 }

-- Probe A (G-05): GlobalSupport holds for NotDemonstrated chain while semantic condition is false
def cA : Claim := { expected := 4, operationalizable := true }
def eA : Evidence := { entries := [true, true, true], externalReady := true, admissible := true }

def targetA : FormalTarget := formalize cA
def checkedA : TargetChecked := inspectTarget targetA eA

def certA : Certificate := {
  protocolId := P.id
  boundClaim := cA
  boundEvidence := eA
  preflight := runPreflight eA
  target := targetA
  checked := checkedA.result
  verdict := .notDemonstrated
}

def a0 : Stage0 := { claim := cA, evidence := eA }
def a1 : Stage1 := { claim := cA, evidence := eA, target := targetA }
def a2 : Stage2 := { claim := cA, evidence := eA, checked := checkedA }
def a3 : Stage3 := {
  claim := cA
  evidence := eA
  checked := checkedA
  certificate := certA
  verdict := .notDemonstrated
}

def tauA1 : Option TransitionCertificate1 := some { targetWitness := a1.target }
def tauA2 : Option TransitionCertificate2 := some { checkedWitness := a2.checked }
def tauA3 : Option TransitionCertificate3 := some { certificateWitness := certA }

theorem probeA_check1 : check1 tauA1 a0 a1 = true := by decide
theorem probeA_check2 : check2 tauA2 a1 a2 = true := by decide
theorem probeA_check3 : check3 concreteDigestModel P tauA3 a2 a3 = true := by decide

theorem probeA_checks : Composable concreteDigestModel P tauA1 tauA2 tauA3 a0 a1 a2 a3 :=
  ⟨probeA_check1, probeA_check2, probeA_check3⟩

theorem probeA_globalSupport : GlobalSupport P a0 a1 a2 a3 :=
  fourEvidenceComposes concreteDigestModel P tauA1 tauA2 tauA3 a0 a1 a2 a3 probeA_checks

theorem probeA_claim_is_false : ¬verifiedSem (cA, eA) := by
  intro h
  simp [verifiedSem, inspect, cA, eA] at h

-- Probe B: Missing certificate 1 is rejected
theorem probeB_missing_cert_rejected :
    ¬ Composable concreteDigestModel P none tauA2 tauA3 a0 a1 a2 a3 := by
  intro h
  have hc1 := h.1
  revert hc1
  decide

-- Probe C: Stale target in certificate is rejected by check3
def certCStaleTarget : Certificate := {
  certA with target := { expected := 99 }
}
def a3StaleTarget : Stage3 := {
  a3 with certificate := certCStaleTarget
}
def tauA3StaleTarget : Option TransitionCertificate3 := some {
  certificateWitness := certCStaleTarget
}

theorem probeC_stale_target_rejected :
    check3 concreteDigestModel P tauA3StaleTarget a2 a3StaleTarget = false := by
  decide

-- Probe D: Mismatched targetWitness in transition certificate 1 is rejected
def cStale : Claim := { expected := 99, operationalizable := true }
theorem probeD_mismatched_witness_rejected :
    check1 (some { targetWitness := formalize cStale }) a0 a1 = false := by
  decide

-- Probe E: Mismatched checkedWitness in transition certificate 2 is rejected
def checkedStale : TargetChecked := { target := targetA, result := { satisfying := 99 } }
theorem probeE_mismatched_witness_rejected :
    check2 (some { checkedWitness := checkedStale }) a1 a2 = false := by
  decide

-- Probe F (G-06): Verified GlobalSupport forces verifiedSem on original Stage0 claim & evidence
theorem probeF_verified_forces_conditions_at_origin
    (Q : Protocol) (y0 : Stage0) (y1 : Stage1) (y2 : Stage2) (y3 : Stage3)
    (h : GlobalSupport Q y0 y1 y2 y3) (hv : y3.verdict = .verified) :
    verifiedSem (y0.claim, y0.evidence) := by
  have hSupp : Supports (semantics Q) y3.evidence y3.claim y3.certificate .verified := by
    have pSupp := h.protocolSupport
    rw [hv] at pSupp
    exact pSupp
  have hCond := P10Core.Proofs.FourEvidence.supports_verified_implies_conditions Q y3.evidence y3.claim y3.certificate hSupp
  have hcp := h.claimPreserved
  have hep := h.evidencePreserved
  rw [hcp, hep] at hCond
  exact hCond

end GateProbe
