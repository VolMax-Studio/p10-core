import P10Core.Instances.FourEvidence.Checker

namespace P10Core.Proofs.FourEvidence

open P10Core.Spec P10Core.Model P10Core.Instances.FourEvidence

theorem checkCert_sound
    (D : DigestModel) (P : Protocol) (c : Claim) (e : Evidence)
    (κ : Certificate) (v : Verdict)
    (hcheck : CheckCert D P c e κ v = true) :
    Supports (semantics P) e c κ v := by
  have h := of_decide_eq_true hcheck
  rcases h with ⟨hpid, hdigest, hclaim, hpreflight, hpok,
    htarget, hinspect, hverdict, hdecision⟩
  have hevidence : κ.boundEvidence = e := D.injective hdigest
  have hadmissible : e.admissible = true := by
    rw [hpreflight] at hpok
    exact hpok
  have hpf : (semantics P).preflightOK c e κ.preflight := by
    exact ⟨hpreflight, hpok⟩
  have hcommit : (semantics P).commitsPreflight κ κ.preflight := rfl
  have htransitions : (semantics P).transitionsValid c e κ := by
    exact ⟨htarget, hinspect, hverdict.trans hdecision⟩
  have hbind : (semantics P).certificateBinds c e v κ := by
    exact ⟨hpid, hclaim, hevidence, hverdict⟩
  cases hop : c.operationalizable with
  | false =>
      have hv : v = Verdict.unfalsifiableAsStated := by
        simpa [decideVerdict, hop] using hdecision
      have hkverdict : κ.verdict = Verdict.unfalsifiableAsStated :=
        hverdict.trans hv
      have hbind' : (semantics P).certificateBinds c e .unfalsifiableAsStated κ := by
        simpa [hv] using hbind
      rw [hv]
      apply Supports.unfalsifiableAsStated κ.preflight hpf hcommit
      · simp [semantics, hop]
      · exact hkverdict
      · exact hbind'
  | true =>
      cases hready : e.externalReady with
      | false =>
          have hv : v = Verdict.deferred := by
            simpa [decideVerdict, hop, hready] using hdecision
          have hkverdict : κ.verdict = Verdict.deferred :=
            hverdict.trans hv
          have hbind' : (semantics P).certificateBinds c e .deferred κ := by
            simpa [hv] using hbind
          rw [hv]
          apply Supports.deferred κ.preflight Blocker.sourceUnavailable hpf hcommit
          · simp [semantics, hop]
          · exact ⟨rfl, hready⟩
          · exact hadmissible
          · exact ⟨hkverdict, rfl⟩
          · exact hbind'
      | true =>
          cases hrule : verifiedRule.check (c, e) with
          | false =>
              have hv : v = Verdict.notDemonstrated := by
                simpa [decideVerdict, hop, hready, hrule] using hdecision
              have hbind' : (semantics P).certificateBinds c e .notDemonstrated κ := by
                simpa [hv] using hbind
              rw [hv]
              apply Supports.notDemonstrated κ.preflight hpf hcommit
              · simp [semantics, hop]
              · trivial
              · trivial
              · exact htransitions
              · exact verifiedRule_false (c, e) hrule
              · exact hbind'
          | true =>
              have hv : v = Verdict.verified := by
                simpa [decideVerdict, hop, hready, hrule] using hdecision
              have hbind' : (semantics P).certificateBinds c e .verified κ := by
                simpa [hv] using hbind
              rw [hv]
              apply Supports.verified κ.preflight hpf hcommit
              · simp [semantics, hop]
              · trivial
              · trivial
              · exact htransitions
              · exact verifiedRule_sound (c, e) hrule
              · exact hbind'

theorem supports_verified_implies_conditions
    (P : Protocol) (e : Evidence) (c : Claim) (κ : Certificate)
    (h : Supports (semantics P) e c κ .verified) : verifiedSem (c, e) := by
  exact Supports.verified_conditions h

theorem supports_notDemonstrated_implies_not_conditions
    (P : Protocol) (e : Evidence) (c : Claim) (κ : Certificate)
    (h : Supports (semantics P) e c κ .notDemonstrated) : ¬verifiedSem (c, e) := by
  exact Supports.notDemonstrated_not_verified h

theorem supports_deferred_implies_external_blocker
    (P : Protocol) (e : Evidence) (c : Claim) (κ : Certificate)
    (h : Supports (semantics P) e c κ .deferred) :
    ∃ b, (semantics P).externalBlocker c e b := by
  exact Supports.deferred_has_blocker h

theorem verified_not_notDemonstrated
    (P : Protocol) (e : Evidence) (c : Claim) (κ₁ κ₂ : Certificate)
    (hv : Supports (semantics P) e c κ₁ .verified)
    (hn : Supports (semantics P) e c κ₂ .notDemonstrated) : False := by
  exact Supports.verified_not_notDemonstrated hv hn

end P10Core.Proofs.FourEvidence
