#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/configs/m3-8gb.env"
LLAMA="$ROOT/third_party/llama.cpp/build/bin/llama-cli"
MODEL="$ROOT/models/$MODEL_FILE"

[[ -x "$LLAMA" ]] || { echo "Run ./scripts/install_m3_8gb.sh first." >&2; exit 1; }
[[ -f "$MODEL" ]] || { echo "Run ./scripts/download_model.sh first." >&2; exit 1; }

exec "$LLAMA"   -m "$MODEL"   --moe-n-slots "$MOE_SLOTS"   --moe-n-layers "$MOE_LAYERS"   --no-mmap   --no-warmup   -ngl "$GPU_LAYERS"   -b "$BATCH"   -ub "$UBATCH"   -c "$CTX"   -t "$THREADS"   -n "$MAX_NEW_TOKENS"   --temp "$TEMPERATURE"   "$@"
