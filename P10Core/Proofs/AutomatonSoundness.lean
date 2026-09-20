import P10Core.Model.AdjudicationAutomaton

namespace P10Core.Proofs.AutomatonSoundness

open P10Core.Model.AdjudicationAutomaton

set_option maxRecDepth 500000

/-!
### 1. Witness Aggregation Theorems
Proof that witness aggregation implements strict, fail-closed precedence.
-/

theorem aggregate_empty_yields_missing (ws : List WitnessClass) (h : ws = []) :
    aggregateWitnessClasses ws = EvalStatus.missing := by
  unfold aggregateWitnessClasses
  rw [h]
  rfl

theorem aggregate_checkerError_dominance (ws : List WitnessClass)
    (h_ne : ws ≠ [])
    (h_chk : ws.contains WitnessClass.checkerError = true) :
    aggregateWitnessClasses ws = EvalStatus.checkerError := by
  unfold aggregateWitnessClasses
  have h_emp : ws.isEmpty = false := by
    cases ws with
    | nil => contradiction
    | cons _ _ => rfl
  rw [h_emp, h_chk]
  rfl

theorem aggregate_violation_dominance (ws : List WitnessClass)
    (h_ne : ws ≠ [])
    (h_nochk : ws.contains WitnessClass.checkerError = false)
    (h_viol : ws.contains WitnessClass.violated = true) :
    aggregateWitnessClasses ws = EvalStatus.violated := by
  unfold aggregateWitnessClasses
  have h_emp : ws.isEmpty = false := by
    cases ws with
    | nil => contradiction
    | cons _ _ => rfl
  rw [h_emp, h_nochk, h_viol]
  rfl

theorem aggregate_blocked_dominance (ws : List WitnessClass)
    (h_ne : ws ≠ [])
    (h_nochk : ws.contains WitnessClass.checkerError = false)
    (h_noviol : ws.contains WitnessClass.violated = false)
    (h_block : ws.contains WitnessClass.blocked = true) :
    aggregateWitnessClasses ws = EvalStatus.blocked := by
  unfold aggregateWitnessClasses
  have h_emp : ws.isEmpty = false := by
    cases ws with
    | nil => contradiction
    | cons _ _ => rfl
  rw [h_emp, h_nochk, h_noviol, h_block]
  rfl

theorem aggregate_unanimous_satisfaction (ws : List WitnessClass)
    (h_ne : ws ≠ [])
    (h_nochk : ws.contains WitnessClass.checkerError = false)
    (h_noviol : ws.contains WitnessClass.violated = false)
    (h_noblock : ws.contains WitnessClass.blocked = false) :
    aggregateWitnessClasses ws = EvalStatus.satisfied := by
  unfold aggregateWitnessClasses
  have h_emp : ws.isEmpty = false := by
    cases ws with
    | nil => contradiction
    | cons _ _ => rfl
  rw [h_emp, h_nochk, h_noviol, h_noblock]
  rfl

/-!
### 2. Adjudication Automaton Meta-Theorems
Proof that the decision ladder implements deterministic precedence.
-/

/-- Totality & Determinism: every DecisionView yields a unique TerminalOutcome -/
theorem adjudicate_total_unique (dv : DecisionView) :
    ∃ (x : TerminalOutcome), adjudicate dv = x ∧ ∀ y, adjudicate dv = y → y = x := by
  refine ⟨adjudicate dv, ⟨rfl, fun y hy => hy.symm⟩⟩

/-- Checker error dominance: checker failure yields ProtocolError checkerFailure -/
theorem checkerError_yields_protocolError (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_chk : dv.obligations.contains EvalStatus.checkerError = true) :
    adjudicate dv = TerminalOutcome.protocolError S2ProtocolError.checkerFailure := by
  unfold adjudicate
  rw [h_prot]
  dsimp only []
  rw [h_chk]
  rfl

/-- Substantive violation yields NotVerified -/
theorem violated_yields_notVerified (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_viol : dv.obligations.contains EvalStatus.violated = true) :
    adjudicate dv = TerminalOutcome.verdict S2Verdict.notVerified := by
  unfold adjudicate
  rw [h_prot]
  dsimp only []
  rw [h_nochk, h_viol]
  rfl

/-- Unfalsifiable audit yields UnfalsifiableAsStated -/
theorem unfalsifiable_yields_unfalsifiableAsStated (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_noviol : dv.obligations.contains EvalStatus.violated = false)
    (h_unfals : dv.falsifiable = false) :
    adjudicate dv = TerminalOutcome.verdict S2Verdict.unfalsifiableAsStated := by
  unfold adjudicate
  rw [h_prot]
  dsimp only []
  rw [h_nochk, h_noviol, h_unfals]
  rfl

/-- Operational blockage yields Deferred -/
theorem blocked_yields_deferred (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_noviol : dv.obligations.contains EvalStatus.violated = false)
    (h_fals : dv.falsifiable = true)
    (h_block : dv.obligations.contains EvalStatus.blocked = true) :
    adjudicate dv = TerminalOutcome.verdict S2Verdict.deferred := by
  unfold adjudicate
  rw [h_prot]
  dsimp only []
  rw [h_nochk, h_noviol, h_fals, h_block]
  rfl

/-- Missing evidence yields NotDemonstrated -/
theorem missing_yields_notDemonstrated (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_noviol : dv.obligations.contains EvalStatus.violated = false)
    (h_fals : dv.falsifiable = true)
    (h_noblock : dv.obligations.contains EvalStatus.blocked = false)
    (h_miss : dv.obligations.contains EvalStatus.missing = true) :
    adjudicate dv = TerminalOutcome.verdict S2Verdict.notDemonstrated := by
  unfold adjudicate
  rw [h_prot]
  dsimp only []
  rw [h_nochk, h_noviol, h_fals, h_noblock, h_miss]
  rfl

/-- Demarcation: missing evidence without violation does not yield NotVerified -/
theorem missing_not_notVerified (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_noviol : dv.obligations.contains EvalStatus.violated = false)
    (h_fals : dv.falsifiable = true)
    (h_noblock : dv.obligations.contains EvalStatus.blocked = false)
    (h_miss : dv.obligations.contains EvalStatus.missing = true) :
    adjudicate dv ≠ TerminalOutcome.verdict S2Verdict.notVerified := by
  rw [missing_yields_notDemonstrated dv h_prot h_nochk h_noviol h_fals h_noblock h_miss]
  intro h
  contradiction

/-- Demarcation: violation does not yield NotDemonstrated -/
theorem violated_not_notDemonstrated (dv : DecisionView)
    (h_prot : dv.protocolFault = none)
    (h_nochk : dv.obligations.contains EvalStatus.checkerError = false)
    (h_viol : dv.obligations.contains EvalStatus.violated = true) :
    adjudicate dv ≠ TerminalOutcome.verdict S2Verdict.notDemonstrated := by
  rw [violated_yields_notVerified dv h_prot h_nochk h_viol]
  intro h
  contradiction

/-- DecisionView representation invariance -/
theorem decisionView_representation_invariance (dv1 dv2 : DecisionView)
    (h : dv1 = dv2) : adjudicate dv1 = adjudicate dv2 := by
  rw [h]

/-- EvalVector completeness invariance -/
theorem evalVector_completeness_invariance (obs1 obs2 : List EvalStatus)
    (h : obs1 = obs2) : evidenceComplete obs1 = evidenceComplete obs2 := by
  rw [h]

/-!
### 3. Adversarial Outcome Oracle & Exhaustive Corpus Verification
-/

/-- All 5 valid EvalStatus values -/
def allEvalStatuses : List EvalStatus :=
  [EvalStatus.satisfied, EvalStatus.violated, EvalStatus.blocked, EvalStatus.missing, EvalStatus.checkerError]

/-- Adversarial corpus: exhaustive 5^4 = 625 4-obligation permutations -/
def corpus625 : List (List EvalStatus) :=
  allEvalStatuses.flatMap fun s1 =>
  allEvalStatuses.flatMap fun s2 =>
  allEvalStatuses.flatMap fun s3 =>
  allEvalStatuses.map fun s4 => [s1, s2, s3, s4]

/-- Baseline test DecisionView -/
def testDecisionView (obs : List EvalStatus) : DecisionView :=
  { protocolFault := none,
    falsifiable := true,
    obligations := obs,
    hasBlockingLimitation := false,
    hasNonBlockingLimitation := false,
    admissibleNovelFinding := false }

/-- Exhaustive reference conformance oracle for test DecisionViews -/
def expectedAdversarialOutcome (obs : List EvalStatus) : TerminalOutcome :=
  if obs.contains EvalStatus.checkerError then
    TerminalOutcome.protocolError S2ProtocolError.checkerFailure
  else if obs.contains EvalStatus.violated then
    TerminalOutcome.verdict S2Verdict.notVerified
  else if obs.contains EvalStatus.blocked then
    TerminalOutcome.verdict S2Verdict.deferred
  else if obs.contains EvalStatus.missing then
    TerminalOutcome.verdict S2Verdict.notDemonstrated
  else
    TerminalOutcome.verdict S2Verdict.verified

/-- Machine-checked proof that the corpus has exactly 625 elements -/
theorem corpus625_cardinality : corpus625.length = 625 := by rfl

/-- Real, non-tautological adversarial oracle proof:
    every single one of the 625 obligation vectors yields the exact expected precedence outcome -/
theorem corpus625_oracle_conformity :
    corpus625.all (fun obs => adjudicate (testDecisionView obs) == expectedAdversarialOutcome obs) = true := by rfl

/-!
### 4. Full 80,000-State Space Evaluation
Full permutation over 8 protocol states × 2 falsifiability states × 2 blocking limitation states
× 2 non-blocking limitation states × 2 novel finding states × 625 obligation vectors = 80,000 states.
-/

def allProtocolFaults : List (Option S2ProtocolError) :=
  [none,
   some S2ProtocolError.checkerFailure,
   some S2ProtocolError.integrityFailure,
   some S2ProtocolError.targetMutation,
   some S2ProtocolError.environmentMismatch,
   some S2ProtocolError.preregistrationFracture,
   some S2ProtocolError.prematureExecution,
   some S2ProtocolError.boundaryOverclaim]

def allBools : List Bool := [true, false]

def oracleAdjudicate (dv : DecisionView) : TerminalOutcome :=
  match dv.protocolFault with
  | some err => TerminalOutcome.protocolError err
  | none =>
    if dv.obligations.contains EvalStatus.checkerError then
      TerminalOutcome.protocolError S2ProtocolError.checkerFailure
    else if dv.obligations.contains EvalStatus.violated then
      TerminalOutcome.verdict S2Verdict.notVerified
    else if !dv.falsifiable then
      TerminalOutcome.verdict S2Verdict.unfalsifiableAsStated
    else if dv.obligations.contains EvalStatus.blocked then
      TerminalOutcome.verdict S2Verdict.deferred
    else if dv.obligations.contains EvalStatus.missing then
      TerminalOutcome.verdict S2Verdict.notDemonstrated
    else if dv.admissibleNovelFinding then
      TerminalOutcome.verdict S2Verdict.deferred
    else if dv.hasBlockingLimitation then
      TerminalOutcome.verdict S2Verdict.notVerified
    else if dv.hasNonBlockingLimitation then
      TerminalOutcome.verdict S2Verdict.verifiedWithLimitations
    else
      TerminalOutcome.verdict S2Verdict.verified

def fullDecisionViewSpace : List DecisionView :=
  allProtocolFaults.flatMap fun pf =>
  allBools.flatMap fun fals =>
  allBools.flatMap fun blockLim =>
  allBools.flatMap fun nonblockLim =>
  allBools.flatMap fun novel =>
  corpus625.map fun obs =>
    { protocolFault := pf,
      falsifiable := fals,
      obligations := obs,
      hasBlockingLimitation := blockLim,
      hasNonBlockingLimitation := nonblockLim,
      admissibleNovelFinding := novel }

#eval corpus625.length
#eval corpus625.all (fun obs => adjudicate (testDecisionView obs) == expectedAdversarialOutcome obs)
#eval fullDecisionViewSpace.length
#eval fullDecisionViewSpace.all (fun dv => adjudicate dv == oracleAdjudicate dv)

end P10Core.Proofs.AutomatonSoundness
