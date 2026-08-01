# 跨工具兼容性验证（第十期）

> 目标：验证 legacy-delegate 在 opencode / Claude Code / Cursor 三端的行为一致性与安装方式。
> 日期：2026-08-01 · 方法：同一 eval（eval 1 全 Map bug + eval 13 粘贴补丁）多端 headless 实测。

## 结论速览

| 工具 | 版本 | 实测 | 结果 |
|------|------|------|------|
| opencode | 1.18.10 | eval 1（subagent 全流程）、eval 13 | ✅ 行为一致（第六/九期 16 条全 PASS） |
| Claude Code | 2.1.220 | eval 1（完整流程）、eval 13（黑名单） | ✅ 行为一致（runner 复核 PASS） |
| Cursor | 3.13.10 | 静态适配检查（Windows GUI 无法 headless） | ⚠️ 需安装指引，格式兼容 |

## 行为一致性（实测）

| 场景 | opencode | Claude Code |
|------|----------|-------------|
| eval 13 粘贴补丁 | 直接应用，不建 `.delegate/`，命中黑名单 | 同上 ✅ |
| eval 1 全 Map bug | Orient→Map(complete)→Change(L1/L2)→Leave→check OK | 同上 ✅（L1：改前 TypeError → 改后 4/5 PASS） |
| 产物格式 | 从 templates/ 拷贝，yaml 字段 | 需显式要求用模板；默认会自创表格格式 |

两端的 runner 断言（`scripts/run_evals.sh check`）均 `PASS`。

## 发现的注意事项（Claude Code）

1. **headless 权限**：`--permission-mode acceptEdits` 只放行文件编辑，**模板读取/check 脚本（Bash cp）会被拦**。完整代工需 `--dangerously-skip-permissions`（沙盒仓安全）或交互式。
2. **产物格式漂移**：未显式要求时，Claude Code 自创 markdown 表格格式（非 templates/ 的 yaml 块），check 脚本对 `^[[:space:]]*status:` 的 grep 无法匹配表格行 → **必须从 templates/ 拷贝填**。SKILL.md 已写明此要求，但跨工具时值得在 prompt 里再强调。
3. **turns 限制**：headless 长任务默认 max-turns 会截断（完整流程需 ≥25-40 turns）。

## 安装方式（三端）

| 工具 | 安装 |
|------|------|
| opencode | 全局技能放 `~/.claude/skills/legacy-delegate/`（本仓即该路径）即被发现 |
| Claude Code | 同上（`~/.claude/skills/` 原生扫描）；或 `npx skills add` |
| Cursor | 项目级 `.cursor/skills/legacy-delegate/` 或全局 `~/.cursor/skills/`；`npx skills add` 亦可 |

## 给维护者的检查清单

改 SKILL.md / templates / scripts 后：

```bash
bash scripts/run_evals.sh all          # opencode 侧（默认执行环境）
# Claude Code 侧（可选冒烟）：
claude -p "用 /legacy-delegate skill：<eval 13 prompt>" --dangerously-skip-permissions --max-turns 10
```

两端口径一致再合入。
