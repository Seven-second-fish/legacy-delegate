#!/usr/bin/env bash
# check_delegate_artifacts.sh — legacy-delegate 协议闸门辅助
# 用法:
#   bash check_delegate_artifacts.sh .delegate/<task-slug>
#   bash check_delegate_artifacts.sh --draft .delegate/<task-slug>
#
# 完成路径检查：
#   - 必填文件存在
#   - map complete（或 fast_path）+ 章节标记
#   - evidence_grade 为 L1|L2（非 L0）
#   - 朴素反 stub：章节不能仍是模板占位
# --draft：中途续跑；允许缺 change.md；不强制 evidence / notes 完成态
# 章节名支持中文模板；英文旧产物仍兼容。
set -euo pipefail

DRAFT=0
DIR=""
for arg in "$@"; do
  case "$arg" in
    --draft) DRAFT=1 ;;
    -h|--help)
      echo "用法: $0 [--draft] .delegate/<task-slug>"
      exit 0
      ;;
    *)
      if [[ -z "$DIR" ]]; then DIR="$arg"; else
        echo "多余参数: $arg"
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$DIR" || ! -d "$DIR" ]]; then
  echo "用法: $0 [--draft] .delegate/<task-slug>"
  exit 2
fi

fail=0
need() {
  local f="$1"
  if [[ ! -f "$DIR/$f" ]]; then
    echo "缺失: $DIR/$f"
    fail=1
  fi
}

# Extract body under a ## heading until next ## / EOF; strip code fences for scan.
# heading 可为正则（中|英）。
section_body() {
  local file="$1"
  local heading="$2"
  awk -v h="$heading" '
    BEGIN { IGNORECASE=1; insec=0 }
    /^## / {
      if (insec) exit
      line=tolower($0)
      if (line ~ h) { insec=1; next }
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
  echo "$body" | awk '
    function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
    function is_header_cell(s,   t) {
      t=tolower(trim(s))
      return (t=="path" || t=="symbol" || t=="why" || t=="file" || t=="change" || t=="item" || t=="result" \
        || t=="路径" || t=="符号" || t=="原因" || t=="文件" || t=="改动" || t=="项" || t=="结果")
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

has_section() {
  local file="$1"
  local pattern="$2"
  grep -qiE "^##[[:space:]]+.*(${pattern})" "$file"
}

require_section_substance() {
  local file="$1"
  local heading_re="$2"
  local label="$3"
  if [[ ! -f "$file" ]]; then
    return
  fi
  if ! has_section "$file" "$heading_re"; then
    echo "失败: $label 缺少章节: $heading_re"
    fail=1
    return
  fi
  if ! section_has_substance "$file" "$heading_re"; then
    echo "失败: $label 章节疑似空壳/占位: $heading_re"
    fail=1
  fi
}

need task.md
need map.md
if [[ "$DRAFT" -eq 0 ]]; then
  need change.md
  need notes.md
else
  echo "OK: --draft（允许缺 change.md / notes.md）"
  [[ -f "$DIR/change.md" ]] || true
  [[ -f "$DIR/notes.md" ]] || true
fi

investigate_only=0
if [[ -f "$DIR/task.md" ]]; then
  if grep -qiE 'status:[[:space:]]*investigate_only' "$DIR/task.md"; then
    echo "OK: investigate_only（change.md 可较轻）"
    investigate_only=1
  fi
  if grep -qiE 'status:[[:space:]]*blocked|status:[[:space:]]*aborted' "$DIR/task.md"; then
    echo "OK: blocked/aborted — 跳过完成检查（状态合法即通过）"
    echo "RESULT: OK"
    exit 0
  fi
fi

# 章节别名：中文模板 | 英文旧产物
MAP_TOUCH='触点列表|Touch list'
MAP_BOUNDARY='改动边界|Change boundary'
MAP_CONFIRMED='已证实|Confirmed'
MAP_UNKNOWNS='未知|Unknowns'
MAP_PATH='关键路径|Critical path'
CHG_DIFF='改动摘要|Diff summary'
CHG_VERIFY='验证|Verification'
CHG_CHAR='表征证据|Characterization'
CHG_ROLLBACK='回滚点|Rollback'
NOTES_WHAT='改了什么|What changed'
NOTES_REGRESS='如何回归|How to regress'
TASK_SUCCESS='成功标准|Success criteria'

if [[ -f "$DIR/map.md" ]]; then
  if ! grep -qiE 'status:[[:space:]]*complete' "$DIR/map.md"; then
    if [[ -f "$DIR/task.md" ]] && grep -qiE 'fast_path:[[:space:]]*true' "$DIR/task.md"; then
      echo "警告: map 未 complete 但 fast_path=true — 请确认短 map 含触点列表 + 改动边界"
    elif [[ "$DRAFT" -eq 1 ]]; then
      echo "OK: --draft 且 map 未 complete（中途态）"
    else
      echo "失败: map.md status 不是 complete（且未设 fast_path）"
      fail=1
    fi
  fi
  for section in "$MAP_TOUCH" "$MAP_BOUNDARY" "$MAP_CONFIRMED" "$MAP_UNKNOWNS"; do
    if ! grep -qiE "$section" "$DIR/map.md"; then
      echo "失败: map.md 缺少章节标记: $section"
      fail=1
    fi
  done
  require_section_substance "$DIR/map.md" "$MAP_TOUCH" "map.md"
  require_section_substance "$DIR/map.md" "$MAP_BOUNDARY" "map.md"
  if grep -qiE 'status:[[:space:]]*complete' "$DIR/map.md"; then
    require_section_substance "$DIR/map.md" "$MAP_PATH" "map.md"
    require_section_substance "$DIR/map.md" "$MAP_CONFIRMED" "map.md"
  fi
fi

if [[ "$DRAFT" -eq 1 ]]; then
  # 中途续跑：有 change 则弱检 evidence，无则跳过完成态强制项
  if [[ -f "$DIR/change.md" ]]; then
    if grep -qiE 'evidence_grade:[[:space:]]*L0' "$DIR/change.md"; then
      echo "失败: evidence_grade L0 不得宣称完成"
      fail=1
    fi
  else
    echo "OK: --draft 缺 change.md"
  fi
  if [[ -f "$DIR/notes.md" ]]; then
    : # 不强制 notes 实质
  fi
  # 续跑字段仍校验（见文末）
else
if [[ -f "$DIR/change.md" ]]; then
  if grep -qiE 'evidence_grade:[[:space:]]*L0' "$DIR/change.md"; then
    if [[ "$investigate_only" -eq 1 ]] && grep -qiE 'evidence_grade:[[:space:]]*N/A' "$DIR/change.md"; then
      : # investigate_only 允许 N/A（无改动可验证）
    else
      echo "失败: evidence_grade L0 不得宣称完成"
      fail=1
    fi
  elif [[ "$investigate_only" -eq 0 ]]; then
    if ! grep -qiE 'evidence_grade:[[:space:]]*L[12]' "$DIR/change.md"; then
      echo "失败: change.md 必须设置 evidence_grade L1 或 L2"
      fail=1
    fi
    require_section_substance "$DIR/change.md" "$CHG_DIFF" "change.md"
    require_section_substance "$DIR/change.md" "$CHG_VERIFY" "change.md"
    # refactor：表征证据 + 回滚点必填（非空壳）
    is_refactor=0
    if grep -qiE '^[[:space:]]*type:[[:space:]]*refactor\b' "$DIR/change.md"; then
      is_refactor=1
    elif [[ -f "$DIR/task.md" ]] && grep -qiE '^[[:space:]]*type:[[:space:]]*refactor\b' "$DIR/task.md"; then
      is_refactor=1
    fi
    if [[ "$is_refactor" -eq 1 ]]; then
      require_section_substance "$DIR/change.md" "$CHG_CHAR" "change.md"
      require_section_substance "$DIR/change.md" "$CHG_ROLLBACK" "change.md"
    fi
  fi
fi

if [[ -f "$DIR/notes.md" && "$investigate_only" -eq 0 ]]; then
  require_section_substance "$DIR/notes.md" "$NOTES_WHAT" "notes.md"
  require_section_substance "$DIR/notes.md" "$NOTES_REGRESS" "notes.md"
fi

if [[ -f "$DIR/task.md" ]] && grep -qiE 'status:[[:space:]]*done' "$DIR/task.md"; then
  if grep -qiE "$TASK_SUCCESS" "$DIR/task.md"; then
    if ! section_has_substance "$DIR/task.md" "$TASK_SUCCESS"; then
      echo "失败: task.md 成功标准在 status=done 时疑似空壳"
      fail=1
    fi
  fi
fi
fi # end DRAFT=0 complete-path block

# 续跑弱校验（resume: true）
if [[ -f "$DIR/task.md" ]] && grep -qiE '^[[:space:]]*resume:[[:space:]]*true' "$DIR/task.md"; then
  if ! grep -qiE '^[[:space:]]*last_stage:[[:space:]]*(orient|map|change|leave)\b' "$DIR/task.md"; then
    echo "失败: resume=true 但缺少有效 last_stage（orient|map|change|leave）"
    fail=1
  fi
  if grep -qiE '^[[:space:]]*status:[[:space:]]*in_progress\b' "$DIR/task.md"; then
    if ! grep -qiE '^[[:space:]]*resume_from:[[:space:]]*(orient|map|change|leave)\b' "$DIR/task.md"; then
      echo "失败: 续跑 in_progress 但缺少有效 resume_from"
      fail=1
    fi
  fi
  # done 的续跑任务：Map 仍须 complete 或 fast_path（防止跳闸门宣称完成）
  if grep -qiE '^[[:space:]]*status:[[:space:]]*done\b' "$DIR/task.md"; then
    if [[ -f "$DIR/map.md" ]] && ! grep -qiE 'status:[[:space:]]*complete' "$DIR/map.md"; then
      if ! grep -qiE 'fast_path:[[:space:]]*true' "$DIR/task.md"; then
        echo "失败: 续跑后 status=done 但 map 未 complete 且无 fast_path"
        fail=1
      fi
    fi
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: OK"
exit 0
