#!/usr/bin/env bash
# smoke_examples.sh — 批量对 examples/ 跑 check_delegate_artifacts.sh
# 用法: bash scripts/smoke_examples.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$ROOT/scripts/check_delegate_artifacts.sh"
EXAMPLES="$ROOT/examples"

fail=0
checked=0

run_one() {
  local dir="$1"
  local mode="$2" # complete | draft
  checked=$((checked + 1))
  echo "==> $mode: $dir"
  if [[ "$mode" == draft ]]; then
    if bash "$CHECK" --draft "$dir"; then
      echo "    OK (draft)"
    else
      echo "    FAIL (draft)"
      fail=1
    fi
  else
    if bash "$CHECK" "$dir"; then
      echo "    OK"
    else
      echo "    FAIL"
      fail=1
    fi
  fi
}

# 完成态快照
run_one "$EXAMPLES/light-refactor-extract-fn" complete
run_one "$EXAMPLES/resume-interrupted-map/session-2" complete

# 中途态：允许缺 change
run_one "$EXAMPLES/resume-interrupted-map/session-1" draft

echo "checked=$checked"
if [[ "$fail" -ne 0 ]]; then
  echo "SMOKE: FAIL"
  exit 1
fi
echo "SMOKE: OK"
exit 0
