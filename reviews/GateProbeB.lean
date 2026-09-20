import P10Core.Proofs.Composition
import P10Core.Proofs.PositiveWitness

namespace GateProbeB

open P10Core.Spec P10Core.Model
open P10Core.Instances.FourEvidence
open P10Core.Instances.FourEvidence.Composition
open P10Core.Proofs.Composition

/- Restoration of Gate 002 probe B, which the archived suite replaced with a
   missing-certificate restatement. Probe B is the negative test that matters:
   evidence that does NOT satisfy the claim, with a certificate asserting
   `verified`. The checker must refuse it. -/

def P : Protocol := { id := 7 }
def cB : Claim := { expected := 4, operationalizable := true }
def eB : Evidence := { entries := [true, true, true], externalReady := true, admissible := true }

def targetB : FormalTarget := formalize cB
def checkedB : TargetChecked := inspectTarget targetB eB

def certVerified : Certificate :=
  { protocolId := P.id, boundClaim := cB, boundEvidence := eB,
    preflight := runPreflight eB, target := targetB,
    checked := checkedB.result, verdict := .verified }

def b2 : Stage2 := { claim := cB, evidence := eB, checked := checkedB }
def b3 : Stage3 :=
  { claim := cB, evidence := eB, checked := checkedB,
    certificate := certVerified, verdict := .verified }

/-- The checker rejects a `verified` certificate over unsupporting evidence. -/
theorem probeB_forged_verified_rejected :
    check3 concreteDigestModel P (some { certificateWitness := certVerified }) b2 b3 = false := by
  decide

/-- And no chain through this Stage3 can compose. -/
theorem probeB_forged_verified_cannot_compose
    (τ1 : Option TransitionCertificate1) (τ2 : Option TransitionCertificate2)
    (x0 : Stage0) (x1 : Stage1) :
    ¬Composable concreteDigestModel P τ1 τ2
      (some { certificateWitness := certVerified }) x0 x1 b2 b3 := by
  intro h
  have h3 : check3 concreteDigestModel P (some { certificateWitness := certVerified }) b2 b3 = true := h.2.2
  rw [probeB_forged_verified_rejected] at h3
  exact Bool.noConfusion h3

end GateProbeB
