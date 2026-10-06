#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL="$ROOT/models/Qwen3-30B-A3B-Q4_K_M.gguf"
URL="https://huggingface.co/ggml-org/Qwen3-30B-A3B-GGUF/resolve/main/Qwen3-30B-A3B-Q4_K_M.gguf"
EXPECTED="642a1eda167db5f55de673cbd19fd8b4aac69c766d01bdbeaf5820f457c7790d"

fail(){ echo "ERROR: $*" >&2; exit 1; }
command -v curl >/dev/null || fail "curl is required."
command -v shasum >/dev/null || fail "shasum is required."

AVAIL_KB="$(df -Pk "$ROOT" | awk 'NR==2{print $4}')"
(( AVAIL_KB >= 25000000 )) || fail "Need about 25 GB free on the filesystem; found $((AVAIL_KB/1024/1024)) GB."

mkdir -p "$ROOT/models"
if [[ -f "$MODEL" ]]; then
  echo "Checking existing model checksum..."
else
  echo "Downloading 18.6 GB model (resume supported)..."
  curl -L --fail --retry 8 --retry-delay 3 --continue-at - -o "$MODEL" "$URL"
fi

ACTUAL="$(shasum -a 256 "$MODEL" | awk '{print $1}')"
[[ "$ACTUAL" == "$EXPECTED" ]] || {
  echo "SHA256 mismatch" >&2
  echo "Expected: $EXPECTED" >&2
  echo "Actual:   $ACTUAL" >&2
  exit 2
}
echo "Model OK: $MODEL"
