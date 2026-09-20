import P10Core.Model.AdjudicationAutomaton

namespace P10Core.Model.DomainAdapter

open P10Core.Model.AdjudicationAutomaton

/-- A DomainProfile formalizes the bridge between raw domain evidence of type `E`
    and the normalized `DecisionView` required by the S2 adjudication automaton. -/
structure DomainProfile (E : Type) where
  domainName : String
  normalize : E → DecisionView

/-- Execution of an audit profile against raw evidence:
    the raw evidence is normalized by the profile and then adjudicated
    by the frozen S2 adjudication automaton. -/
def runProfile {E : Type} (p : DomainProfile E) (e : E) : TerminalOutcome :=
  adjudicate (p.normalize e)

/-- Domain Profile Extensionality Theorem:
    Any two profiles or runs that yield an identical normalized `DecisionView`
    deterministically produce the identical terminal outcome under S2 semantics,
    proving domain-independence of the frozen adjudication kernel. -/
theorem profile_extensionality {E₁ E₂ : Type}
    (p₁ : DomainProfile E₁) (p₂ : DomainProfile E₂)
    (e₁ : E₁) (e₂ : E₂)
    (h : p₁.normalize e₁ = p₂.normalize e₂) :
    runProfile p₁ e₁ = runProfile p₂ e₂ := by
  unfold runProfile
  rw [h]

end P10Core.Model.DomainAdapter
