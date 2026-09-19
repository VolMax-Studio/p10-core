namespace P10Core.Model

structure Rule (Input : Type) where
  sem : Input → Prop
  check : Input → Bool

def Rule.Sound {Input : Type} (r : Rule Input) : Prop :=
  ∀ x, r.check x = true → r.sem x

def decidableRule {Input : Type} (p : Input → Prop) [DecidablePred p] : Rule Input where
  sem := p
  check := fun x => decide (p x)

theorem decidableRule_sound {Input : Type} (p : Input → Prop) [DecidablePred p] :
    (decidableRule p).Sound := by
  intro x h
  change p x
  change decide (p x) = true at h
  exact of_decide_eq_true h

theorem decidableRule_false {Input : Type} (p : Input → Prop) [DecidablePred p]
    (x : Input) (h : (decidableRule p).check x = false) : ¬p x := by
  intro hp
  have ht : (decidableRule p).check x = true := by
    simp [decidableRule, hp]
  rw [ht] at h
  contradiction

end P10Core.Model
