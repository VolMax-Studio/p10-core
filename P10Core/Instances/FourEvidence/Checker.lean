import P10Core.Instances.FourEvidence.Model

namespace P10Core.Instances.FourEvidence

open P10Core.Spec P10Core.Model

def CheckCert (D : DigestModel) (P : Protocol) (c : Claim) (e : Evidence)
    (κ : Certificate) (v : Verdict) : Bool :=
  decide (
    κ.protocolId = P.id ∧
    D.digest κ.boundEvidence = D.digest e ∧
    κ.boundClaim = c ∧
    κ.preflight = runPreflight e ∧
    κ.preflight.ok = true ∧
    κ.target = formalize c ∧
    κ.checked = inspect e ∧
    κ.verdict = v ∧
    v = decideVerdict c e)

end P10Core.Instances.FourEvidence
