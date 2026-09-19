import P10Core.Spec.Core

namespace P10Core.Model

open P10Core.Spec

structure Semantics
    (Claim Evidence Certificate Preflight Blocker : Type) where
  preflightOK : Claim → Evidence → Preflight → Prop
  commitsPreflight : Certificate → Preflight → Prop
  certificateBinds : Claim → Evidence → Verdict → Certificate → Prop
  evaluable : Claim → Prop
  operationalizable : Claim → Prop
  runCompleted : Claim → Evidence → Prop
  checksSucceeded : Claim → Evidence → Prop
  transitionsValid : Claim → Evidence → Certificate → Prop
  verifiedConditions : Claim → Evidence → Prop
  externalBlocker : Claim → Evidence → Blocker → Prop
  noProtocolFault : Claim → Evidence → Prop
  certifiesUnfalsifiable : Certificate → Prop
  certifiesBlocker : Certificate → Blocker → Prop

inductive Supports
    {Claim Evidence Certificate Preflight Blocker : Type}
    (S : Semantics Claim Evidence Certificate Preflight Blocker)
    (e : Evidence) (c : Claim) (κ : Certificate) : Verdict → Prop where
  | verified (pf : Preflight) :
      S.preflightOK c e pf →
      S.commitsPreflight κ pf →
      S.evaluable c →
      S.runCompleted c e →
      S.checksSucceeded c e →
      S.transitionsValid c e κ →
      S.verifiedConditions c e →
      S.certificateBinds c e .verified κ →
      Supports S e c κ .verified
  | notDemonstrated (pf : Preflight) :
      S.preflightOK c e pf →
      S.commitsPreflight κ pf →
      S.evaluable c →
      S.runCompleted c e →
      S.checksSucceeded c e →
      S.transitionsValid c e κ →
      ¬S.verifiedConditions c e →
      S.certificateBinds c e .notDemonstrated κ →
      Supports S e c κ .notDemonstrated
  | unfalsifiableAsStated (pf : Preflight) :
      S.preflightOK c e pf →
      S.commitsPreflight κ pf →
      ¬S.operationalizable c →
      S.certifiesUnfalsifiable κ →
      S.certificateBinds c e .unfalsifiableAsStated κ →
      Supports S e c κ .unfalsifiableAsStated
  | deferred (pf : Preflight) (b : Blocker) :
      S.preflightOK c e pf →
      S.commitsPreflight κ pf →
      S.operationalizable c →
      S.externalBlocker c e b →
      S.noProtocolFault c e →
      S.certifiesBlocker κ b →
      S.certificateBinds c e .deferred κ →
      Supports S e c κ .deferred

theorem Supports.verified_conditions
    {Claim Evidence Certificate Preflight Blocker : Type}
    {S : Semantics Claim Evidence Certificate Preflight Blocker}
    {e : Evidence} {c : Claim} {κ : Certificate}
    (h : Supports S e c κ .verified) : S.verifiedConditions c e := by
  cases h with
  | verified _ _ _ _ _ _ _ hcond _ => exact hcond

theorem Supports.notDemonstrated_not_verified
    {Claim Evidence Certificate Preflight Blocker : Type}
    {S : Semantics Claim Evidence Certificate Preflight Blocker}
    {e : Evidence} {c : Claim} {κ : Certificate}
    (h : Supports S e c κ .notDemonstrated) : ¬S.verifiedConditions c e := by
  cases h with
  | notDemonstrated _ _ _ _ _ _ _ hcond _ => exact hcond

theorem Supports.deferred_has_blocker
    {Claim Evidence Certificate Preflight Blocker : Type}
    {S : Semantics Claim Evidence Certificate Preflight Blocker}
    {e : Evidence} {c : Claim} {κ : Certificate}
    (h : Supports S e c κ .deferred) : ∃ b, S.externalBlocker c e b := by
  cases h with
  | deferred _ b _ _ _ hblock _ _ _ => exact ⟨b, hblock⟩

theorem Supports.verified_not_notDemonstrated
    {Claim Evidence Certificate Preflight Blocker : Type}
    {S : Semantics Claim Evidence Certificate Preflight Blocker}
    {e : Evidence} {c : Claim} {κ₁ κ₂ : Certificate}
    (hv : Supports S e c κ₁ .verified)
    (hn : Supports S e c κ₂ .notDemonstrated) : False := by
  exact (Supports.notDemonstrated_not_verified hn) (Supports.verified_conditions hv)

end P10Core.Model
