import P10Core.Proofs.FourEvidence
import P10Core.Instances.FourEvidence.Composition

namespace P10Core.Proofs.Composition

open P10Core.Spec P10Core.Model
open P10Core.Instances.FourEvidence
open P10Core.Instances.FourEvidence.Composition

theorem localSound1 : LocalSound1 := by
  intro τ x0 x1 h
  exact (of_decide_eq_true h).2.1

theorem fidelity1 : Fidelity1 := by
  intro τ x0 x1 h
  exact (of_decide_eq_true h).2.2

theorem localSound2 : LocalSound2 := by
  intro τ x1 x2 h
  exact (of_decide_eq_true h).2.1

theorem fidelity2 : Fidelity2 := by
  intro τ x1 x2 h
  exact (of_decide_eq_true h).2.2

theorem localSound3 (D : DigestModel) (P : Protocol) : LocalSound3 D P := by
  intro τ x2 x3 h
  have parts := Bool.and_eq_true_iff.mp h
  exact FourEvidence.checkCert_sound D P x3.claim x3.evidence
    x3.certificate x3.verdict parts.2

theorem fidelity3 (D : DigestModel) (P : Protocol) : Fidelity3 D P := by
  intro τ x2 x3 h
  have parts := Bool.and_eq_true_iff.mp h
  exact (of_decide_eq_true parts.1).2

theorem compositionObligations (D : DigestModel) (P : Protocol) :
    CompositionObligations D P := by
  exact ⟨localSound1, localSound2, localSound3 D P,
    fidelity1, fidelity2, fidelity3 D P⟩

theorem conditionalComposition
    (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
    (hObligations : CompositionObligations D P)
    (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
    GlobalSupport P x0 x1 x2 x3 := by
  rcases hObligations with ⟨hLS1, hLS2, hLS3, hF1, hF2, hF3⟩
  rcases hChecks with ⟨h1, h2, h3⟩
  have local1 := hLS1 τ1 x0 x1 h1
  have local2 := hLS2 τ2 x1 x2 h2
  have local3 := hLS3 τ3 x2 x3 h3
  have fid1 := hF1 τ1 x0 x1 h1
  have fid2 := hF2 τ2 x1 x2 h2
  have fid3 := hF3 τ3 x2 x3 h3
  refine ⟨local1, local2, local3, ?_, ?_⟩
  · exact fid3.1.trans (fid2.1.trans fid1.1)
  · exact fid3.2.1.trans (fid2.2.1.trans fid1.2)

theorem fourEvidenceComposes
    (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
    (hChecks : Composable D P τ1 τ2 τ3 x0 x1 x2 x3) :
    GlobalSupport P x0 x1 x2 x3 := by
  exact conditionalComposition D P τ1 τ2 τ3 x0 x1 x2 x3
    (compositionObligations D P) hChecks

theorem missingCertificateCannotCompose
    (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
    (hMissing : τ1.present = false) :
    ¬CompositionWitness D P τ1 τ2 τ3 x0 x1 x2 x3 := by
  intro h
  have hcheck := h.checks.1
  have hgate := (of_decide_eq_true hcheck).1.1
  rw [hMissing] at hgate
  contradiction

theorem failedContractCannotCompose
    (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
    (hBroken : ¬ContractRel2 x1 x2) :
    ¬CompositionWitness D P τ1 τ2 τ3 x0 x1 x2 x3 := by
  intro h
  exact hBroken (localSound2 τ2 x1 x2 h.checks.2.1)

theorem brokenFidelityCannotCompose
    (D : DigestModel) (P : Protocol)
    (τ1 τ2 τ3 : TransitionCertificate)
    (x0 : Stage0) (x1 : Stage1) (x2 : Stage2) (x3 : Stage3)
    (hBroken : ¬FidelityRel3 x2 x3) :
    ¬CompositionWitness D P τ1 τ2 τ3 x0 x1 x2 x3 := by
  intro h
  exact hBroken (fidelity3 D P τ3 x2 x3 h.checks.2.2)

end P10Core.Proofs.Composition
