#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LLAMA_DIR="$ROOT/third_party/llama.cpp"
LOCK="$ROOT/third_party/llama.cpp.lock"
source "$ROOT/configs/m3-8gb.env"

log(){ printf '\n[MacStrata] %s\n' "$*"; }
fail(){ echo "ERROR: $*" >&2; exit 1; }

[[ "$(uname -m)" == "arm64" ]] || fail "This profile is for Apple Silicon (arm64)."
command -v xcode-select >/dev/null || fail "Xcode Command Line Tools are required: xcode-select --install"
xcode-select -p >/dev/null 2>&1 || fail "Xcode Command Line Tools are not installed: xcode-select --install"
command -v git >/dev/null || fail "git is required."
command -v cmake >/dev/null || fail "cmake is required. Install with: brew install cmake"

RAM_BYTES="$(sysctl -n hw.memsize)"
RAM_GB=$((RAM_BYTES / 1024 / 1024 / 1024))
log "Detected memory: ${RAM_GB} GB"
(( RAM_GB >= 8 )) || fail "Expected at least 8 GB unified memory."

REPO="$(grep '^REPOSITORY=' "$LOCK" | cut -d= -f2-)"
COMMIT="$(grep '^COMMIT=' "$LOCK" | cut -d= -f2-)"

if [[ ! -d "$LLAMA_DIR/.git" ]]; then
  mkdir -p "$LLAMA_DIR"
  log "Fetching pinned llama.cpp commit $COMMIT"
  git -C "$LLAMA_DIR" init
  git -C "$LLAMA_DIR" remote add origin "$REPO"
  git -C "$LLAMA_DIR" fetch --depth 1 origin "$COMMIT"
  git -C "$LLAMA_DIR" checkout --detach "$COMMIT"
else
  CURRENT="$(git -C "$LLAMA_DIR" rev-parse HEAD 2>/dev/null || true)"
  if [[ "$CURRENT" != "$COMMIT" ]]; then
    log "Resetting llama.cpp to pinned commit $COMMIT"
    git -C "$LLAMA_DIR" fetch --depth 1 origin "$COMMIT"
    git -C "$LLAMA_DIR" checkout --detach "$COMMIT"
  fi
fi

log "Building llama.cpp with Metal + Accelerate"
cmake -S "$LLAMA_DIR" -B "$LLAMA_DIR/build"   -DCMAKE_BUILD_TYPE=Release   -DGGML_METAL=ON   -DGGML_ACCELERATE=ON
cmake --build "$LLAMA_DIR/build" -j"$(sysctl -n hw.ncpu)" --target llama-cli llama-server

log "Building MacStrata cache library/tests"
cmake -S "$ROOT" -B "$ROOT/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "$ROOT/build" -j"$(sysctl -n hw.ncpu)"
ctest --test-dir "$ROOT/build" --output-on-failure

log "Runtime build is ready. Next: ./scripts/download_model.sh"
