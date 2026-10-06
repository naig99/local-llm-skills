#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/configs/m3-8gb.env"

ok(){ printf 'OK   %s\n' "$*"; }
warn(){ printf 'WARN %s\n' "$*"; }
fail(){ printf 'FAIL %s\n' "$*"; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "Run this on macOS."
[[ "$(uname -m)" == "arm64" ]] || fail "This profile requires Apple Silicon."
RAM_BYTES="$(sysctl -n hw.memsize)"
RAM_GB=$((RAM_BYTES/1024/1024/1024))
(( RAM_GB >= 8 )) && ok "Apple Silicon with ${RAM_GB} GB unified memory" || fail "Less than 8 GB memory detected"

LLAMA="$ROOT/third_party/llama.cpp/build/bin/llama-cli"
[[ -x "$LLAMA" ]] && ok "llama-cli built" || fail "llama-cli not found; run install_m3_8gb.sh"
MODEL="$ROOT/models/$MODEL_FILE"
[[ -f "$MODEL" ]] && ok "Qwen GGUF present" || fail "Model missing; run download_model.sh"

if [[ -f "$MODEL" ]]; then
  ACTUAL="$(shasum -a 256 "$MODEL" | awk '{print $1}')"
  [[ "$ACTUAL" == "642a1eda167db5f55de673cbd19fd8b4aac69c766d01bdbeaf5820f457c7790d" ]]     && ok "Qwen GGUF SHA256 verified" || fail "Qwen GGUF SHA256 mismatch"
fi

ok "MoE profile: ${MOE_SLOTS} slots/layer, ${MOE_LAYERS} layers, ubatch=${UBATCH}, ctx=${CTX}"
warn "8 GB is a hard memory limit; long contexts or other apps may cause macOS memory pressure."
