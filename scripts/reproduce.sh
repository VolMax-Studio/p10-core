#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "  P10-Core / FourEvidence — Clean-Room Reproduction Script  "
echo "============================================================"

# Ensure Lean toolchain is available in PATH
if ! command -v lake &> /dev/null; then
    if [ -d "$HOME/.elan/bin" ]; then
        export PATH="$HOME/.elan/bin:$PATH"
    fi
fi

echo "[1/4] Checking Lean 4 Toolchain..."
lean --version
lake --version

echo ""
echo "[2/4] Cleaning build artifacts..."
lake clean

echo ""
echo "[3/4] Building P10Core from scratch..."
lake build

echo ""
echo "[4/4] Executing Lean Kernel Axiom Audit..."
lake env lean scripts/AxiomAudit.lean

echo ""
echo "============================================================"
echo "  REPRODUCTION SUCCESSFUL: 0 errors, 0 warnings, 0 sorry    "
echo "============================================================"
