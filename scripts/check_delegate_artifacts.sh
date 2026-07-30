#!/usr/bin/env bash
# check_delegate_artifacts.sh — protocol gate helper for legacy-delegate
# Usage: bash check_delegate_artifacts.sh .delegate/<task-slug>
set -euo pipefail

DIR="${1:-}"
if [[ -z "$DIR" || ! -d "$DIR" ]]; then
  echo "usage: $0 .delegate/<task-slug>"
  exit 2
fi

fail=0
need() {
  local f="$1"
  if [[ ! -f "$DIR/$f" ]]; then
    echo "MISSING: $DIR/$f"
    fail=1
  fi
}

need task.md
need map.md
need change.md
need notes.md

if [[ -f "$DIR/task.md" ]]; then
  if grep -qiE 'status:[[:space:]]*investigate_only' "$DIR/task.md"; then
    echo "OK: investigate_only (change.md may be stub)"
    # still require files exist
  fi
  if grep -qiE 'status:[[:space:]]*blocked|status:[[:space:]]*aborted' "$DIR/task.md"; then
    echo "OK: blocked/aborted — skip done checks"
    exit 0
  fi
fi

if [[ -f "$DIR/map.md" ]]; then
  if ! grep -qiE 'status:[[:space:]]*complete' "$DIR/map.md"; then
    if [[ -f "$DIR/task.md" ]] && grep -qiE 'fast_path:[[:space:]]*true' "$DIR/task.md"; then
      echo "WARN: map not complete but fast_path=true — ensure short map has touch list + boundary"
    else
      echo "FAIL: map.md status is not complete (and fast_path not set)"
      fail=1
    fi
  fi
  for section in "Touch list" "Change boundary" "Confirmed" "Unknowns"; do
    if ! grep -qi "$section" "$DIR/map.md"; then
      echo "FAIL: map.md missing section marker: $section"
      fail=1
    fi
  done
fi

if [[ -f "$DIR/change.md" ]]; then
  if grep -qiE 'evidence_grade:[[:space:]]*L0' "$DIR/change.md"; then
    echo "FAIL: evidence_grade L0 cannot claim done"
    fail=1
  elif ! grep -qiE 'evidence_grade:[[:space:]]*L[12]' "$DIR/change.md"; then
    echo "FAIL: change.md must set evidence_grade L1 or L2"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: OK"
exit 0
