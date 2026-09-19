import P10Core.Model.Calculus
import P10Core.Model.Rules

namespace P10Core.Instances.FourEvidence

open P10Core.Spec P10Core.Model

structure Claim where
  expected : Nat := 4
  operationalizable : Bool := true
  deriving DecidableEq, Repr

structure Evidence where
  entries : List Bool
  externalReady : Bool := true
  admissible : Bool := true
  deriving DecidableEq, Repr

/-- A lossless synthetic digest for the bounded seed model.
It is deliberately not a cryptographic hash. -/
structure Digest where
  evidence : Evidence
  deriving DecidableEq, Repr

structure Protocol where
  id : Nat
  deriving DecidableEq, Repr

structure FormalTarget where
  expected : Nat
  deriving DecidableEq, Repr

structure CheckedEvidence where
  satisfying : Nat
  deriving DecidableEq, Repr

structure PreflightResult where
  ok : Bool
  deriving DecidableEq, Repr

inductive Blocker where
  | sourceUnavailable
  deriving DecidableEq, Repr

structure DigestModel where
  digest : Evidence → Digest
  injective : Function.Injective digest

def concreteDigestModel : DigestModel where
  digest := fun e => { evidence := e }
  injective := by
    intro a b h
    cases h
    rfl

structure Certificate where
  protocolId : Nat
  boundClaim : Claim
  boundEvidence : Evidence
  preflight : PreflightResult
  target : FormalTarget
  checked : CheckedEvidence
  verdict : Verdict
  deriving DecidableEq, Repr

def formalize (c : Claim) : FormalTarget :=
  { expected := c.expected }

def inspect (e : Evidence) : CheckedEvidence :=
  { satisfying := e.entries.count true }

def verifiedSem (input : Claim × Evidence) : Prop :=
  (inspect input.2).satisfying = input.1.expected

def verifiedRule : Rule (Claim × Evidence) :=
  { sem := verifiedSem
    check := fun input => decide ((inspect input.2).satisfying = input.1.expected) }

theorem verifiedRule_sound : verifiedRule.Sound := by
  intro input h
  change (inspect input.2).satisfying = input.1.expected
  change decide ((inspect input.2).satisfying = input.1.expected) = true at h
  exact of_decide_eq_true h

theorem verifiedRule_false (input : Claim × Evidence)
    (h : verifiedRule.check input = false) : ¬verifiedSem input := by
  intro hp
  change (inspect input.2).satisfying = input.1.expected at hp
  have ht : verifiedRule.check input = true := by
    change decide ((inspect input.2).satisfying = input.1.expected) = true
    exact decide_eq_true hp
  rw [ht] at h
  contradiction

def decideVerdict (c : Claim) (e : Evidence) : Verdict :=
  if c.operationalizable = false then
    .unfalsifiableAsStated
  else if e.externalReady = false then
    .deferred
  else if verifiedRule.check (c, e) then
    .verified
  else
    .notDemonstrated

def runPreflight (e : Evidence) : PreflightResult :=
  { ok := e.admissible }

def semantics (P : Protocol) :
    Semantics Claim Evidence Certificate PreflightResult Blocker where
  preflightOK := fun _ e pf => pf = runPreflight e ∧ pf.ok = true
  commitsPreflight := fun κ pf => κ.preflight = pf
  certificateBinds := fun c e v κ =>
    κ.protocolId = P.id ∧ κ.boundClaim = c ∧ κ.boundEvidence = e ∧ κ.verdict = v
  evaluable := fun c => c.operationalizable = true
  operationalizable := fun c => c.operationalizable = true
  runCompleted := fun _ _ => True
  checksSucceeded := fun _ _ => True
  transitionsValid := fun c e κ =>
    κ.target = formalize c ∧ κ.checked = inspect e ∧ κ.verdict = decideVerdict c e
  verifiedConditions := fun c e => verifiedSem (c, e)
  externalBlocker := fun _ e b => b = .sourceUnavailable ∧ e.externalReady = false
  noProtocolFault := fun _ e => e.admissible = true
  certifiesUnfalsifiable := fun κ => κ.verdict = .unfalsifiableAsStated
  certifiesBlocker := fun κ b => κ.verdict = .deferred ∧ b = .sourceUnavailable

end P10Core.Instances.FourEvidence
