#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/install_m3_8gb.sh"
"$ROOT/scripts/download_model.sh"
"$ROOT/scripts/self_check.sh"
echo
echo "Ready. Start with:"
echo "  ./scripts/run_qwen3.sh"
