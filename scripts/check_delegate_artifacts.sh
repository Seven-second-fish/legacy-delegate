#!/usr/bin/env bash
# check_delegate_artifacts.sh — protocol gate helper for legacy-delegate
# Usage: bash check_delegate_artifacts.sh .delegate/<task-slug>
#
# Checks (done path):
#   - required files exist
#   - map complete (or fast_path) + section markers
#   - evidence_grade L1|L2 (not L0)
#   - naive anti-stub: sections not left as template placeholders
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

# Extract body under a ## heading until next ## / EOF; strip code fences for scan.
section_body() {
  local file="$1"
  local heading="$2"
  awk -v h="$heading" '
    BEGIN { IGNORECASE=1; insec=0 }
    /^## / {
      if (insec) exit
      if (index(tolower($0), tolower(h)) > 0) { insec=1; next }
    }
    insec { print }
  ' "$file" | sed '/^```/d'
}

# True if section has at least one "substance" line (not blank, not lone -, not empty table cells).
section_has_substance() {
  local file="$1"
  local heading="$2"
  local body
  body="$(section_body "$file" "$heading")"
  if [[ -z "${body//[[:space:]]/}" ]]; then
    return 1
  fi
  # Drop markdown table separator rows and pure placeholder bullets/cells
  # Drop markdown table separator/header-only rows, nested headings, and pure placeholders
  echo "$body" | awk '
    function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
    function cell_empty(s) { s=trim(s); return (s=="") }
    function is_header_cell(s,   t) {
      t=tolower(trim(s))
      return (t=="path" || t=="symbol" || t=="why" || t=="file" || t=="change" || t=="item" || t=="result")
    }
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*#{1,6}[[:space:]]/ { next }
    /^[[:space:]]*\*\*[^*]+\*\*:?[[:space:]]*$/ { next }
    /^[[:space:]]*\|[[:space:]]*[-:]+[[:space:]]*(\|[[:space:]]*[-:]+[[:space:]]*)+\|[[:space:]]*$/ { next }
    /^\|/ {
      n=split($0, a, "|")
      nonempty=0; all_header=1; any_cell=0
      for (i=2; i<n; i++) {
        c=trim(a[i])
        if (c=="") continue
        any_cell=1
        if (!is_header_cell(c)) all_header=0
        nonempty++
      }
      if (!any_cell) next
      if (all_header) next
      found=1; exit
    }
    /^[[:space:]]*\|([[:space:]]*\|)+[[:space:]]*$/ { next }
    /^[[:space:]]*-[[:space:]]*$/ { next }
    /^[[:space:]]*\*[[:space:]]*$/ { next }
    /^[[:space:]]*[0-9]+\.[[:space:]]*$/ { next }
    { found=1; exit }
    END { exit found ? 0 : 1 }
  '
}

require_section_substance() {
  local file="$1"
  local heading="$2"
  local label="$3"
  if [[ ! -f "$file" ]]; then
    return
  fi
  if ! grep -qiE "^##[[:space:]]+.*${heading}" "$file"; then
    echo "FAIL: $label missing section: $heading"
    fail=1
    return
  fi
  if ! section_has_substance "$file" "$heading"; then
    echo "FAIL: $label section looks empty/stub: $heading"
    fail=1
  fi
}

need task.md
need map.md
need change.md
need notes.md

investigate_only=0
if [[ -f "$DIR/task.md" ]]; then
  if grep -qiE 'status:[[:space:]]*investigate_only' "$DIR/task.md"; then
    echo "OK: investigate_only (change.md may be light)"
    investigate_only=1
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
  # Anti-stub on map (always when map present and not aborted)
  require_section_substance "$DIR/map.md" "Touch list" "map.md"
  require_section_substance "$DIR/map.md" "Change boundary" "map.md"
  if grep -qiE 'status:[[:space:]]*complete' "$DIR/map.md"; then
    require_section_substance "$DIR/map.md" "Critical path" "map.md"
    require_section_substance "$DIR/map.md" "Confirmed" "map.md"
  fi
fi

if [[ -f "$DIR/change.md" ]]; then
  if grep -qiE 'evidence_grade:[[:space:]]*L0' "$DIR/change.md"; then
    echo "FAIL: evidence_grade L0 cannot claim done"
    fail=1
  elif [[ "$investigate_only" -eq 0 ]]; then
    if ! grep -qiE 'evidence_grade:[[:space:]]*L[12]' "$DIR/change.md"; then
      echo "FAIL: change.md must set evidence_grade L1 or L2"
      fail=1
    fi
    require_section_substance "$DIR/change.md" "Diff summary" "change.md"
    require_section_substance "$DIR/change.md" "Verification" "change.md"
  fi
fi

if [[ -f "$DIR/notes.md" && "$investigate_only" -eq 0 ]]; then
  require_section_substance "$DIR/notes.md" "What changed" "notes.md"
  require_section_substance "$DIR/notes.md" "How to regress" "notes.md"
fi

# task.md success criteria should not be only empty checkboxes when status=done
if [[ -f "$DIR/task.md" ]] && grep -qiE 'status:[[:space:]]*done' "$DIR/task.md"; then
  if grep -qiE 'Success criteria' "$DIR/task.md"; then
    if ! section_has_substance "$DIR/task.md" "Success criteria"; then
      echo "FAIL: task.md Success criteria looks empty/stub while status=done"
      fail=1
    fi
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: OK"
exit 0
