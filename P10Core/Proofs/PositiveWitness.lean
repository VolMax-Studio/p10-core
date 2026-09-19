import P10Core.Proofs.Composition

namespace P10Core.Proofs.PositiveWitness

open P10Core.Spec P10Core.Model
open P10Core.Instances.FourEvidence
open P10Core.Instances.FourEvidence.Composition
open P10Core.Proofs.Composition

def P0 : Protocol := { id := 7 }

def c0 : Claim :=
  { expected := 4, operationalizable := true }

def e0 : Evidence :=
  { entries := [true, true, true, true]
    externalReady := true
    admissible := true }

def κ0 : Certificate :=
  { protocolId := P0.id
    boundClaim := c0
    boundEvidence := e0
    preflight := runPreflight e0
    target := formalize c0
    checked := inspect e0
    verdict := .verified }

def x0 : Stage0 :=
  { claim := c0, evidence := e0 }

def x1 : Stage1 :=
  { claim := c0, evidence := e0, target := formalize c0 }

def x2 : Stage2 :=
  { claim := c0
    evidence := e0
    checked := inspectTarget (formalize c0) e0 }

def x3 : Stage3 :=
  { claim := c0
    evidence := e0
    checked := x2.checked
    certificate := κ0
    verdict := .verified }

def τ1 : Option TransitionCertificate1 :=
  some { targetWitness := x1.target }

def τ2 : Option TransitionCertificate2 :=
  some { checkedWitness := x2.checked }

def τ3 : Option TransitionCertificate3 :=
  some { certificateWitness := κ0 }

theorem positiveCheck1 : check1 τ1 x0 x1 = true := by
  decide

theorem positiveCheck2 : check2 τ2 x1 x2 = true := by
  decide

theorem positiveCheck3 : check3 concreteDigestModel P0 τ3 x2 x3 = true := by
  decide

theorem positiveComposable :
    Composable concreteDigestModel P0 τ1 τ2 τ3 x0 x1 x2 x3 := by
  exact ⟨positiveCheck1, positiveCheck2, positiveCheck3⟩

theorem positiveGlobalSupport : GlobalSupport P0 x0 x1 x2 x3 := by
  exact fourEvidenceComposes concreteDigestModel P0 τ1 τ2 τ3
    x0 x1 x2 x3 positiveComposable

#eval check1 τ1 x0 x1
#eval check2 τ2 x1 x2
#eval check3 concreteDigestModel P0 τ3 x2 x3

end P10Core.Proofs.PositiveWitness
