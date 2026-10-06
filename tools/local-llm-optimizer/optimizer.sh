#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT/config.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "Missing $CONFIG"
  echo "Run: cp config.env.example config.env"
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

TARGET_PROJECT="${TARGET_PROJECT:-$HOME/local-llm-skills/MacStrata-Qwen3-M3-8GB}"

if [[ ! -d "$TARGET_PROJECT" ]]; then
  echo "Target project not found: $TARGET_PROJECT"
  exit 1
fi

case "${1:-}" in
  inspect)
    "$ROOT/inspect.sh"
    ;;
  benchmark)
    "$ROOT/benchmark.sh"
    ;;
  patch)
    [[ -n "${2:-}" ]] || { echo "Usage: ./optimizer.sh patch FILE.patch"; exit 2; }
    cd "$TARGET_PROJECT"
    git diff --quiet || {
      echo "Target project has uncommitted changes."
      echo "Commit/stash intentionally before applying an optimizer patch."
      exit 3
    }
    git apply --check "$2"
    git apply "$2"
    echo "Patch applied. Review with:"
    echo "  cd $TARGET_PROJECT"
    echo "  git diff"
    ;;
  status)
    cd "$TARGET_PROJECT"
    git status --short --branch
    ;;
  *)
    echo "Usage:"
    echo "  ./optimizer.sh inspect"
    echo "  ./optimizer.sh benchmark"
    echo "  ./optimizer.sh patch FILE.patch"
    echo "  ./optimizer.sh status"
    exit 2
    ;;
esac
