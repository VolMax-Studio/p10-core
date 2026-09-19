import P10Core.Proofs.FourEvidence
import P10Core.Proofs.Composition

open P10Core.Proofs.FourEvidence
open P10Core.Proofs.Composition

#print axioms checkCert_sound
#print axioms supports_verified_implies_conditions
#print axioms supports_notDemonstrated_implies_not_conditions
#print axioms supports_deferred_implies_external_blocker
#print axioms verified_not_notDemonstrated

#print axioms conditionalComposition
#print axioms fourEvidenceComposes
#print axioms missingCertificateCannotCompose
#print axioms failedContractCannotCompose
#print axioms brokenFidelityCannotCompose
