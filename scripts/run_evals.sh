#!/usr/bin/env bash
# run_evals.sh — legacy-delegate eval 回归 runner
# 用法:
#   bash run_evals.sh prepare [--root DIR]   # 生成 fixture 仓（默认 /tmp/legacy-evals）
#   bash run_evals.sh check   [--root DIR]   # 逐条核对断言（产物需已由 agent 执行生成）
#   bash run_evals.sh list    [--root DIR]   # 打印每条 eval 的 prompt 与目标仓（喂给执行 agent）
#   bash run_evals.sh report  [--root DIR]   # 汇总 PASS/FAIL 并写 evals/results-<date>.md
#   bash run_evals.sh all     [--root DIR]   # prepare + list + check + report（默认）
#
# 设计：fixture 生成与断言核对自动化；「执行 eval」仍需 agent 读 SKILL 跑
# （脚本不调 LLM）。断言 = 机器可核对的产物字段；测试真实性靠人审（与 check 脚本一致）。
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$HERE"
ROOT="${ROOT:-/tmp/legacy-evals}"
MANIFEST="$HERE/evals/manifest.json"
PREPARE="$HERE/evals/prepare_fixtures.sh"
CHECK="$HERE/scripts/check_delegate_artifacts.sh"

usage() { grep -E "^#   bash run_evals" "$0" | sed 's/^#   /  /'; }

cmd="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    prepare|check|list|report|all) cmd="$1" ;;
    --root) ROOT="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1"; usage; exit 2 ;;
  esac
  shift
done

declare -A RESULTS  # slug_dir -> result

# ---------- 工具 ----------
latest_slug_dir() { # <repo> → 最新产物目录（绝对路径）
  local repo="$1" d newest=""
  for d in "$repo"/.delegate/*/; do
    [[ -d "$d" ]] || continue
    if [[ -z "$newest" || "$d" -nt "$newest" ]]; then newest="$d"; fi
  done
  echo "$newest"
}

resolved_slug() { # <repo> <slug-or-*> → 绝对目录；无则空
  local repo="$1" slug="$2" dir
  if [[ "$slug" == "*" ]]; then
    latest_slug_dir "$repo"
  elif [[ "$slug" == "none" ]]; then
    echo ""
  else
    dir="$repo/.delegate/$slug"
    [[ -d "$dir" ]] && echo "$dir" || echo ""
  fi
}

# ---------- 断言（每个返回 0=通过 / 1=失败）----------
a_delegate_artifacts() { # 四件套齐
  local d="$1"; for f in task.md map.md change.md notes.md; do [[ -f "$d/$f" ]] || return 1; done
}
a_map_complete()      { grep -qiE 'status:[[:space:]]*complete' "$1/map.md" 2>/dev/null; }
a_evidence_l1l2()     { grep -qiE 'evidence_grade:[[:space:]]*L[12]' "$1/change.md" 2>/dev/null; }
a_status_done()       { grep -qiE '^[[:space:]]*status:[[:space:]]*done' "$1/task.md" 2>/dev/null; }
a_fast_path_true()    { grep -qiE '^[[:space:]]*fast_path:[[:space:]]*true' "$1/task.md" 2>/dev/null; }
a_no_fast_path()      { ! grep -qiE '^[[:space:]]*fast_path:[[:space:]]*true' "$1/task.md" 2>/dev/null; }
a_type_feature()      { grep -qiE '^[[:space:]]*type:[[:space:]]*feature' "$1/task.md" 2>/dev/null; }
a_type_refactor()     { grep -qiE '^[[:space:]]*type:[[:space:]]*refactor' "$1/task.md" 2>/dev/null; }
a_resume_fields()     { grep -qiE '^[[:space:]]*resume:[[:space:]]*true' "$1/task.md" 2>/dev/null && grep -qiE '^[[:space:]]*resume_from:[[:space:]]*(orient|map|change|leave)' "$1/task.md" 2>/dev/null && grep -qiE '^[[:space:]]*last_stage:[[:space:]]*(orient|map|change|leave)' "$1/task.md" 2>/dev/null; }
a_investigate_only()  { grep -qiE '^[[:space:]]*status:[[:space:]]*investigate_only' "$1/task.md" 2>/dev/null; }
a_char_rollback()     { grep -qiE '表征证据|Characterization' "$1/change.md" 2>/dev/null && grep -qiE '回滚点|Rollback' "$1/change.md" 2>/dev/null; }
a_appeal_append()     { grep -qiE '追诉 ?#?[0-9]*|Appeal' "$1/change.md" 2>/dev/null; }
a_result_chain()      { grep -qiE '意图动作|可观察后果|intent|observable' "$1/task.md" 2>/dev/null; }
a_warmstart_source()  { grep -qiE 'source:[[:space:]]*\.delegate/' "$1/map.md" 2>/dev/null; }
a_new_slug_not_500()  { [[ -d "$2/.delegate/checkout-coupon-500" ]] && [[ "$(basename "$1")" != "checkout-coupon-500" ]]; }
a_no_delegate()       { [[ ! -d "$1/.delegate" ]]; }
a_check_ok() { # 单独跑 check 脚本
  local d="$1" out
  out="$(bash "$CHECK" "$d" 2>&1 | tail -1)"
  [[ "$out" == "RESULT: OK" ]]
}

# ---------- 主流程 ----------
if [[ "$cmd" == "prepare" || "$cmd" == "all" ]]; then
  echo "==> prepare fixtures → $ROOT"
  bash "$PREPARE" "$ROOT"
  touch "$ROOT/.prepare_stamp"
fi

if [[ "$cmd" == "list" || "$cmd" == "all" ]]; then
  echo; echo "==> eval 清单（执行 agent 逐个跑以下 prompt）"
  jq -r '.evals[] | "  #\(.id) \(.name)\n    repo: \(.repo)\n    prompt: \(.prompt)\n"' "$MANIFEST"
fi

if [[ "$cmd" == "check" || "$cmd" == "report" || "$cmd" == "all" ]]; then
  echo; echo "==> 断言核对"
  mkdir -p "$ROOT"
  PASS=0; FAIL=0; SKIP=0
  : > "$ROOT/.eval_results.tsv"
  while IFS= read -r line; do
    id="$(jq -r '.id' <<<"$line")"
    name="$(jq -r '.name' <<<"$line")"
    repo="$(jq -r '.repo' <<<"$line")"
    slug="$(jq -r '.slug' <<<"$line")"
    repo_abs="$ROOT/$repo"
    dir="$(resolved_slug "$repo_abs" "$slug")"
    echo "  #$id $name"
    if [[ -z "$dir" ]]; then
      echo "    SKIP（无产物目录）"
      SKIP=$((SKIP+1)); echo -e "$id\tSKIP\t-" >> "$ROOT/.eval_results.tsv"; continue
    fi
    stamp="$ROOT/.prepare_stamp"
    if [[ -f "$stamp" ]] && [[ -z "$(find "$dir" -type f -newer "$stamp")" ]]; then
      echo "    SKIP（产物未更新，预置基线未执行）"
      SKIP=$((SKIP+1)); echo -e "$id\tSKIP\t$(basename "$dir")" >> "$ROOT/.eval_results.tsv"; continue
    fi
    ok=1; failed=()
    while IFS= read -r a; do
      if ! "a_$a" "$dir" "$repo_abs"; then
        ok=0; failed+=("$a")
      fi
    done < <(jq -r '.asserts[]' <<<"$line")
    if [[ "$ok" -eq 1 ]]; then
      PASS=$((PASS+1)); echo "    PASS（$(basename "$dir")）"
      echo -e "$id\tPASS\t$(basename "$dir")" >> "$ROOT/.eval_results.tsv"
    else
      FAIL=$((FAIL+1)); echo "    FAIL: ${failed[*]}"
      echo -e "$id\tFAIL\t${failed[*]}" >> "$ROOT/.eval_results.tsv"
    fi
  done < <(jq -c '.evals[]' "$MANIFEST")
  echo; echo "==> PASS=$PASS FAIL=$FAIL SKIP=$SKIP (total=$(jq '.evals|length' "$MANIFEST"))"
fi

if [[ "$cmd" == "report" || "$cmd" == "all" ]]; then
  date_s="$(date +%Y-%m-%d)"
  results_dir="$HERE/evals/results"
  mkdir -p "$results_dir"
  n=1
  while [[ -f "$results_dir/$date_s-$n.md" ]]; do n=$((n+1)); done
  out="$results_dir/$date_s-$n.md"
  {
    echo "# Eval 回归结果（$date_s #$n）"
    echo
    echo "| # | eval | 结果 | 产物 |"
    echo "|---|------|------|------|"
    while IFS=$'\t' read -r id res slug; do
      name="$(jq -r --argjson id "$id" '.evals[] | select(.id==$id) | .name' "$MANIFEST")"
      echo "| $id | $name | $res | $slug |"
    done < "$ROOT/.eval_results.tsv"
  } > "$out"
  echo "报告: $out"
fi
