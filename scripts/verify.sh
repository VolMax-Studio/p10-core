#!/bin/sh
set -eu

lake build

# Scan for forbidden proof cheats across all Lean sources
if command -v rg >/dev/null 2>&1; then
  if rg -n '\bsorry\b|\badmit\b|^\s*axiom\b' -g '*.lean' P10Core audit reviews; then
    echo 'Forbidden proof placeholder or user axiom found.' >&2
    exit 1
  fi
  # Verify Truth_M does not appear in any lean code
  if rg -n '\bTruth_M\b' -g '*.lean' P10Core audit reviews; then
    echo 'Forbidden Truth_M identifier found in Lean source.' >&2
    exit 1
  fi
else
  if find P10Core audit reviews -name '*.lean' -type f -exec \
      grep -nE '(^|[^[:alnum:]_])(sorry|admit)([^[:alnum:]_]|$)|^[[:space:]]*axiom[[:space:]]' {} +; then
    echo 'Forbidden proof placeholder or user axiom found.' >&2
    exit 1
  fi
  if find P10Core audit reviews -name '*.lean' -type f -exec \
      grep -nE '\bTruth_M\b' {} +; then
    echo 'Forbidden Truth_M identifier found in Lean source.' >&2
    exit 1
  fi
fi

# Run axiom audit harness
lake env lean audit/AxiomAudit.lean

# Run adversarial gate probe suite
lake env lean reviews/GateProbe.lean

# Check release manifest
if [ -f manifests/SHA256SUMS_v0.2.2-gateclosure ]; then
  sha256sum -c manifests/SHA256SUMS_v0.2.2-gateclosure
elif [ -f manifests/SHA256SUMS_v0.2.1-gatefix ]; then
  sha256sum -c manifests/SHA256SUMS_v0.2.1-gatefix
fi
