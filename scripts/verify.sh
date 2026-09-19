#!/bin/sh
set -eu

lake build

if command -v rg >/dev/null 2>&1; then
  if rg -n '\bsorry\b|\badmit\b|^\s*axiom\b' -g '*.lean' P10Core audit; then
    echo 'Forbidden proof placeholder or user axiom found.' >&2
    exit 1
  fi
else
  if find P10Core audit -name '*.lean' -type f -exec \
      grep -nE '(^|[^[:alnum:]_])(sorry|admit)([^[:alnum:]_]|$)|^[[:space:]]*axiom[[:space:]]' {} +; then
    echo 'Forbidden proof placeholder or user axiom found.' >&2
    exit 1
  fi
fi

lake env lean audit/AxiomAudit.lean

if [ -f manifests/SHA256SUMS_v0.2.1-gatefix ]; then
  sha256sum -c manifests/SHA256SUMS_v0.2.1-gatefix
fi
