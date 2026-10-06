#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/config.env"

cd "$TARGET_PROJECT"

if [[ ! -x "$RUN_SCRIPT" ]]; then
  echo "Run script not executable or missing: $RUN_SCRIPT"
  exit 1
fi

echo "=== BENCHMARK ==="
echo "Project: $TARGET_PROJECT"
echo "Repeats: ${BENCH_REPEATS:-3}"
echo "Tokens:  ${BENCH_TOKENS:-128}"
echo

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

for i in $(seq 1 "${BENCH_REPEATS:-3}"); do
  echo "--- run $i"
  printf '%s\n' "$BENCH_PROMPT" | timeout 180 "$RUN_SCRIPT" -n "${BENCH_TOKENS:-128}" 2>&1 | tee -a "$tmp"
  echo
done

echo "=== SUMMARY ==="
grep -E 'Prompt:|Generation:' "$tmp" || true
