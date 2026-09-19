# v0.2.0-composition

Added:

- a bounded four-stage, three-transition typed chain;
- explicit semantic contracts and fidelity relations per transition;
- machine-checked `LocalSound1..3` and `Fidelity1..3` obligations;
- conditional and fully discharged composition theorems;
- protocol-only `GlobalSupport` with endpoint claim/evidence preservation;
- adversarial non-composition theorems for missing certificates, failed
  contracts, and broken fidelity;
- an updated source and kernel-axiom audit.

Unchanged:

- the frozen FourEvidence checker theorem;
- its digest-injectivity trust boundary;
- all seed calculus and checker definitions.

Not claimed:

- semantic truth;
- global P10 soundness;
- cryptographic collision resistance;
- unbounded-chain composition.
