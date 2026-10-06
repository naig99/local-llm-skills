#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/config.env"

cd "$TARGET_PROJECT"

echo "=== TARGET ==="
pwd
echo

echo "=== GIT ==="
git status --short --branch
echo
git log -5 --oneline

echo
echo "=== CONFIG ==="
for f in configs/m3-8gb.env configs/m3-8gb.baseline.env; do
  if [[ -f "$f" ]]; then
    echo "--- $f"
    cat "$f"
  fi
done

echo
echo "=== MODEL ==="
ls -lh models/*.gguf 2>/dev/null || true

echo
echo "=== LLAMA.CPP ==="
if [[ -d third_party/llama.cpp ]]; then
  git -C third_party/llama.cpp status --short --branch
  git -C third_party/llama.cpp rev-parse HEAD
fi

echo
echo "=== SELF CHECK ==="
if [[ -x scripts/self_check.sh ]]; then
  ./scripts/self_check.sh
fi
