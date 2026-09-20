namespace P10Core.Model.AdjudicationAutomaton

/-- 5-valued evaluation status for an individual obligation -/
inductive EvalStatus where
  | satisfied
  | violated
  | blocked
  | missing
  | checkerError
  deriving DecidableEq, Repr, Inhabited

/-- 6-verdict terminal outcome space for S2 -/
inductive S2Verdict where
  | verified
  | verifiedWithLimitations
  | notVerified
  | notDemonstrated
  | unfalsifiableAsStated
  | deferred
  deriving DecidableEq, Repr, Inhabited

/-- Protocol errors that halt execution before substantive evaluation -/
inductive S2ProtocolError where
  | checkerFailure
  | integrityFailure
  | targetMutation
  | environmentMismatch
  | preregistrationFracture
  | prematureExecution
  | boundaryOverclaim
  deriving DecidableEq, Repr, Inhabited

/-- Unified terminal outcome space Ω = ProtocolError ⊎ S2Verdict -/
inductive TerminalOutcome where
  | verdict : S2Verdict → TerminalOutcome
  | protocolError : S2ProtocolError → TerminalOutcome
  deriving DecidableEq, Repr, Inhabited

/-- DecisionView captures the complete observational input for adjudication -/
structure DecisionView where
  protocolFault : Option S2ProtocolError
  falsifiable : Bool
  obligations : List EvalStatus
  hasBlockingLimitation : Bool
  hasNonBlockingLimitation : Bool
  admissibleNovelFinding : Bool
  deriving DecidableEq, Repr, Inhabited

/-- Predicate checking if obligations are complete (no missing evidence) -/
def evidenceComplete (obs : List EvalStatus) : Bool :=
  !obs.contains EvalStatus.missing

/-- Pure, deterministic adjudication function implementing draft-4 precedence -/
def adjudicate (dv : DecisionView) : TerminalOutcome :=
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

end P10Core.Model.AdjudicationAutomaton
