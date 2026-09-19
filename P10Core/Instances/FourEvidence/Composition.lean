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

structure Stage2 where
  claim : Claim
  evidence : Evidence
  target : FormalTarget
  checked : CheckedEvidence
  deriving DecidableEq, Repr

structure Stage3 where
  claim : Claim
  evidence : Evidence
  target : FormalTarget
  checked : CheckedEvidence
  certificate : Certificate
  verdict : Verdict
  deriving DecidableEq, Repr

structure TransitionCertificate where
  present : Bool
  contractOK : Bool
  fidelityOK : Bool
  deriving DecidableEq, Repr

def ContractRel1 (x0 : Stage0) (x1 : Stage1) : Prop :=
  x1.target = formalize x0.claim

def FidelityRel1 (x0 : Stage0) (x1 : Stage1) : Prop :=
  x1.claim = x0.claim ∧ x1.evidence = x0.evidence

def ContractRel2 (x1 : Stage1) (x2 : Stage2) : Prop :=
  x2.checked = inspect x1.evidence

def FidelityRel2 (x1 : Stage1) (x2 : Stage2) : Prop :=
  x2.claim = x1.claim ∧ x2.evidence = x1.evidence ∧ x2.target = x1.target

def ContractRel3 (P : Protocol) (x3 : Stage3) : Prop :=
  Supports (semantics P) x3.evidence x3.claim x3.certificate x3.verdict

def FidelityRel3 (x2 : Stage2) (x3 : Stage3) : Prop :=
  x3.claim = x2.claim ∧
  x3.evidence = x2.evidence ∧
  x3.target = x2.target ∧
  x3.checked = x2.checked

def transitionGate (τ : TransitionCertificate) : Prop :=
  τ.present = true ∧ τ.contractOK = true ∧ τ.fidelityOK = true

instance (τ : TransitionCertificate) : Decidable (transitionGate τ) := by
  unfold transitionGate
  infer_instance

instance (x0 : Stage0) (x1 : Stage1) : Decidable (ContractRel1 x0 x1) := by
  unfold ContractRel1
  infer_instance

instance (x0 : Stage0) (x1 : Stage1) : Decidable (FidelityRel1 x0 x1) := by
  unfold FidelityRel1
  infer_instance

instance (x1 : Stage1) (x2 : Stage2) : Decidable (ContractRel2 x1 x2) := by
  unfold ContractRel2
  infer_instance

instance (x1 : Stage1) (x2 : Stage2) : Decidable (FidelityRel2 x1 x2) := by
  unfold FidelityRel2
  infer_instance

instance (x2 : Stage2) (x3 : Stage3) : Decidable (FidelityRel3 x2 x3) := by
  unfold FidelityRel3
  infer_instance

def check1 (τ : TransitionCertificate) (x0 : Stage0) (x1 : Stage1) : Bool :=
  decide (transitionGate τ ∧ ContractRel1 x0 x1 ∧ FidelityRel1 x0 x1)

def check2 (τ : TransitionCertificate) (x1 : Stage1) (x2 : Stage2) : Bool :=
  decide (transitionGate τ ∧ ContractRel2 x1 x2 ∧ FidelityRel2 x1 x2)

def check3 (D : DigestModel) (P : Protocol) (τ : TransitionCertificate)
    (x2 : Stage2) (x3 : Stage3) : Bool :=
  decide (transitionGate τ ∧ FidelityRel3 x2 x3) &&
    CheckCert D P x3.claim x3.evidence x3.certificate x3.verdict

def LocalSound1 : Prop :=
  ∀ τ x0 x1, check1 τ x0 x1 = true → ContractRel1 x0 x1

def LocalSound2 : Prop :=
  ∀ τ x1 x2, check2 τ x1 x2 = true → ContractRel2 x1 x2

def LocalSound3 (D : DigestModel) (P : Protocol) : Prop :=
  ∀ τ x2 x3, check3 D P τ x2 x3 = true → ContractRel3 P x3

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
  local1 : ContractRel1 x0 x1
  local2 : ContractRel2 x1 x2
  local3 : ContractRel3 P x3
  claimPreserved : x3.claim = x0.claim
  evidencePreserved : x3.evidence = x0.evidence

theorem GlobalSupport.protocolSupport
    {P : Protocol} {x0 : Stage0} {x1 : Stage1} {x2 : Stage2} {x3 : Stage3}
    (h : GlobalSupport P x0 x1 x2 x3) :
    Supports (semantics P) x3.evidence x3.claim x3.certificate x3.verdict :=
  h.local3

def Composable (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3) : Prop :=
  check1 τ1 x0 x1 = true ∧
  check2 τ2 x1 x2 = true ∧
  check3 D P τ3 x2 x3 = true

structure CompositionWitness (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3) : Prop where
  checks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3
  global : GlobalSupport P x0 x1 x2 x3

end P10Core.Instances.FourEvidence.Composition
