import P10Core.Instances.FourEvidence.Checker

namespace P10Core.Instances.FourEvidence.Composition

open P10Core.Spec P10Core.Model P10Core.Instances.FourEvidence

structure Stage0 where
  claim : Claim
  evidence : Evidence
  deriving DecidableEq, Repr

structure Stage1 where
  claim : Claim
  evidence : Evidence
  target : FormalTarget
  deriving DecidableEq, Repr

/-- Stage-2 output explicitly binds the formal target used by inspection. -/
structure TargetChecked where
  target : FormalTarget
  result : CheckedEvidence
  deriving DecidableEq, Repr

structure Stage2 where
  claim : Claim
  evidence : Evidence
  checked : TargetChecked
  deriving DecidableEq, Repr

structure Stage3 where
  claim : Claim
  evidence : Evidence
  checked : TargetChecked
  certificate : Certificate
  verdict : Verdict
  deriving DecidableEq, Repr

def inspectTarget (target : FormalTarget) (evidence : Evidence) : TargetChecked :=
  { target := target, result := inspect evidence }

/-- Transition certificates carry recomputable witness data, not free OK flags. -/
structure TransitionCertificate1 where
  targetWitness : FormalTarget
  deriving DecidableEq, Repr

structure TransitionCertificate2 where
  checkedWitness : TargetChecked
  deriving DecidableEq, Repr

structure TransitionCertificate3 where
  certificateWitness : Certificate
  deriving DecidableEq, Repr

/-- Agreement with the designated formalization function; not semantic adequacy. -/
def AgreementRel1 (x0 : Stage0) (x1 : Stage1) : Prop :=
  x1.target = formalize x0.claim

def FidelityRel1 (x0 : Stage0) (x1 : Stage1) : Prop :=
  x1.claim = x0.claim ∧ x1.evidence = x0.evidence

/-- Agreement with target-indexed inspection; not an external semantic claim. -/
def AgreementRel2 (x1 : Stage1) (x2 : Stage2) : Prop :=
  x2.checked = inspectTarget x1.target x1.evidence

def FidelityRel2 (x1 : Stage1) (x2 : Stage2) : Prop :=
  x2.claim = x1.claim ∧
  x2.evidence = x1.evidence ∧
  x2.checked.target = x1.target

/-- The final certificate must commit to the exact Stage-2 checked result. -/
def AgreementRel3 (P : Protocol) (x2 : Stage2) (x3 : Stage3) : Prop :=
  x3.checked = x2.checked ∧
  x3.certificate.target = x2.checked.target ∧
  x3.certificate.checked = x2.checked.result ∧
  Supports (semantics P) x3.evidence x3.claim x3.certificate x3.verdict

def FidelityRel3 (x2 : Stage2) (x3 : Stage3) : Prop :=
  x3.claim = x2.claim ∧
  x3.evidence = x2.evidence ∧
  x3.checked = x2.checked

instance (x0 : Stage0) (x1 : Stage1) : Decidable (AgreementRel1 x0 x1) := by
  unfold AgreementRel1
  infer_instance

instance (x0 : Stage0) (x1 : Stage1) : Decidable (FidelityRel1 x0 x1) := by
  unfold FidelityRel1
  infer_instance

instance (x1 : Stage1) (x2 : Stage2) : Decidable (AgreementRel2 x1 x2) := by
  unfold AgreementRel2
  infer_instance

instance (x1 : Stage1) (x2 : Stage2) : Decidable (FidelityRel2 x1 x2) := by
  unfold FidelityRel2
  infer_instance

instance (x2 : Stage2) (x3 : Stage3) : Decidable (FidelityRel3 x2 x3) := by
  unfold FidelityRel3
  infer_instance

def check1 (τ : Option TransitionCertificate1) (x0 : Stage0) (x1 : Stage1) : Bool :=
  match τ with
  | none => false
  | some cert => decide (
      cert.targetWitness = x1.target ∧
      AgreementRel1 x0 x1 ∧
      FidelityRel1 x0 x1)

def check2 (τ : Option TransitionCertificate2) (x1 : Stage1) (x2 : Stage2) : Bool :=
  match τ with
  | none => false
  | some cert => decide (
      cert.checkedWitness = x2.checked ∧
      AgreementRel2 x1 x2 ∧
      FidelityRel2 x1 x2)

def check3 (D : DigestModel) (P : Protocol) (τ : Option TransitionCertificate3)
    (x2 : Stage2) (x3 : Stage3) : Bool :=
  match τ with
  | none => false
  | some cert =>
      decide (
        cert.certificateWitness = x3.certificate ∧
        x3.checked = x2.checked ∧
        x3.certificate.target = x2.checked.target ∧
        x3.certificate.checked = x2.checked.result ∧
        FidelityRel3 x2 x3) &&
      CheckCert D P x3.claim x3.evidence x3.certificate x3.verdict

def LocalSound1 : Prop :=
  ∀ τ x0 x1, check1 τ x0 x1 = true → AgreementRel1 x0 x1

def LocalSound2 : Prop :=
  ∀ τ x1 x2, check2 τ x1 x2 = true → AgreementRel2 x1 x2

def LocalSound3 (D : DigestModel) (P : Protocol) : Prop :=
  ∀ τ x2 x3, check3 D P τ x2 x3 = true → AgreementRel3 P x2 x3

def Fidelity1 : Prop :=
  ∀ τ x0 x1, check1 τ x0 x1 = true → FidelityRel1 x0 x1

def Fidelity2 : Prop :=
  ∀ τ x1 x2, check2 τ x1 x2 = true → FidelityRel2 x1 x2

def Fidelity3 (D : DigestModel) (P : Protocol) : Prop :=
  ∀ τ x2 x3, check3 D P τ x2 x3 = true → FidelityRel3 x2 x3

def CompositionObligations (D : DigestModel) (P : Protocol) : Prop :=
  LocalSound1 ∧ LocalSound2 ∧ LocalSound3 D P ∧
  Fidelity1 ∧ Fidelity2 ∧ Fidelity3 D P

structure GlobalSupport (P : Protocol)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3) : Prop where
  local1 : AgreementRel1 x0 x1
  local2 : AgreementRel2 x1 x2
  local3 : AgreementRel3 P x2 x3
  claimPreserved : x3.claim = x0.claim
  evidencePreserved : x3.evidence = x0.evidence

theorem GlobalSupport.protocolSupport
    {P : Protocol} {x0 : Stage0} {x1 : Stage1} {x2 : Stage2} {x3 : Stage3}
    (h : GlobalSupport P x0 x1 x2 x3) :
    Supports (semantics P) x3.evidence x3.claim x3.certificate x3.verdict :=
  h.local3.2.2.2

def Composable (D : DigestModel) (P : Protocol)
    (τ1 : Option TransitionCertificate1)
    (τ2 : Option TransitionCertificate2)
    (τ3 : Option TransitionCertificate3)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3) : Prop :=
  check1 τ1 x0 x1 = true ∧
  check2 τ2 x1 x2 = true ∧
  check3 D P τ3 x2 x3 = true

end P10Core.Instances.FourEvidence.Composition
