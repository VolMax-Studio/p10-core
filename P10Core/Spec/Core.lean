namespace P10Core.Spec

inductive Verdict where
  | verified
  | notDemonstrated
  | unfalsifiableAsStated
  | deferred
  deriving DecidableEq, Repr

inductive ProtocolError where
  | bindingMismatch
  | schemaFailure
  | integrityFailure
  | admissibilityViolation
  | checkerFailure
  | certificateFailure
  | transitionContractFailure
  | inconsistentRunState
  deriving DecidableEq, Repr

structure ErrorRecord where
  code : Nat
  deriving DecidableEq, Repr

inductive RunOutcome (Certificate : Type) where
  | verdict : Verdict → Certificate → RunOutcome Certificate
  | protocolError : ProtocolError → ErrorRecord → RunOutcome Certificate

inductive RatificationError where
  | noVerdictToRatify
  | certificateMismatch
  | ratifierFailure
  deriving DecidableEq, Repr

inductive IssuanceOutcome (Certificate Ratifier : Type) where
  | issued : Verdict → Certificate → Ratifier → IssuanceOutcome Certificate Ratifier
  | rejectedByRatifier : Verdict → Certificate → Ratifier → IssuanceOutcome Certificate Ratifier
  | ratificationError : RatificationError → IssuanceOutcome Certificate Ratifier

end P10Core.Spec
