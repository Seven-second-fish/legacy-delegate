---
name: legacy-delegate
description: >-
  可审计的遗留仓（legacy codebase）代工：map-first，Orient → Map → Change → Leave；
  先摸清长调用/数据链路再改代码，按 evidence grade（L0/L1/L2）做 bugfix / feature / light refactor，
  产物落盘 `.delegate/<task-slug>/` 供人与后续 Agent 审阅，支持跨会话 resume 同一 task-slug，不得跳过
  Map/证据闸门。适用于显式调用、陌生模块、长链路排查、代修 bug、跨层加功能、续跑上次代工、
  或不允许跳过理解的安全重构；小改 typo 或纯解释勿用。
disable-model-invocation: true
---

# Legacy Delegate（遗留仓可审计代工）

不熟仓 AI 的长链路协议：**Orient → Map → Change → Leave**。闸门 = 协议 + 可选脚本（非内核强制）。

## 硬规则

1. 产物在**目标仓** `.delegate/<task-slug>/`（kebab-case slug）。
2. Map 未 `complete` 禁改业务代码（Fast path / `investigate_only` 除外）。
3. 证据 **L0** 不得宣称 done（优先 L2，L1 须有记录）。
4. 仓规优先：`AGENTS.md` / `CLAUDE.md` / `.cursor/rules` / README 构建测试命令。
5. 产物禁密钥；目标仓 `.gitignore` 写入一行 `.delegate/`（仓库可写时）。
6. 完成前：`bash <本 skill>/scripts/check_delegate_artifacts.sh .delegate/<task-slug>` → stdout 含 `RESULT: OK`（中途态用 `--draft`）。

从 [templates/](templates/) 拷贝 `task.md` `map.md` `change.md` `notes.md` 填满（禁空壳）。`map.md` 仅 DoD 齐全时可写 `status: complete`。

## 模式与类型

| 模式 | 默认 | 风格 |
|------|------|------|
| `delegate` | 是 | 短结论 + 证据 + 风险 + 未知 |
| `onboard` | 否 | 同上，多写「为什么」 |

类型：`bug` | `feature` | `refactor`（仅**轻量** → [refactor-workflow](references/refactor-workflow.md)）。

**不该用**则说明并 `aborted`/`blocked`：指定文件的 typo/文案；只要解释；完整补丁代粘贴；缺 debugger/线上证据。

## 失败模式（若 X → 先做 / 兜底）

| 触发 | 先做 | 兜底 |
|------|------|------|
| 缺环境/复现/权限 | `blocked` + 精确诉求 | 🛑 停手，不改业务代码 |
| Map DoD 不齐 | 保持 `draft`，列待确认 | 🔴 CHECKPOINT 禁 Change，等用户 |
| 用户给精确文件+意图 | `fast_path` + 短 map | 模糊则拒绝，走全 Map |
| 无法复现 / 补丁仍红 | 记录尝试，修订假设 | 🛑 勿 L0 宣称完成 |
| 检查脚本 FAIL | 补文件/章节/证据 | 🛑 保持 `in_progress` |
| 范围膨胀 | 停手，更新 Map 边界 | 🔴 CHECKPOINT 等用户后再改 |
| 续跑闸门未完 | 同 slug，`resume_from` 未完成阶段 | 🛑 禁凭聊天记忆进 Change |
| Refactor 无表征/回滚 | 先补行为锁与回滚点 | 🛑 禁 done；跨模块则拆任务 |

## 流程

```
Orient(task.md | 续跑已有 slug) → Map(DoD|fast_path) → Change(≥L1) → Leave(notes) → check 脚本
```

### 0) Orient

有 `.delegate/` 则先续跑（用户给出的 slug，或 mtime 最新且 `status` 为 `in_progress`/`blocked` 的目录）：读四件套，设 `resume: true`、`last_stage`、`resume_from`（取值仅 `orient|map|change|leave`）。[resume-workflow](references/resume-workflow.md)。否则 `mkdir -p .delegate/<task-slug>/`，拷模板填：`task_slug` `type` `mode` `status` `fast_path` `evidence_target`；成功标准写成可勾选条目；记下仓规构建/测试命令。

续跑不跳闸门；`done` 不重打补丁。阻塞 → `blocked` 停。中途停 → notes 写满 **续跑交接**。  
🔴 CHECKPOINT：type / 成功标准不清 → 先问用户，勿猜着进 Map。

### 1) Map

按 [map.md](templates/map.md)。**DoD（缺一不可 complete）**：入口、关键路径、触点列表、影响面、已证实、假设、未知、改动边界。可选 **Git 线索**（非 DoD）→ [map-guidance](references/map-guidance.md)。Fast path 仅当用户点名文件+意图：`task.md` 写 `fast_path: true`，短 map 至少填触点列表+改动边界。`investigate_only`：Map 可 complete，禁改业务代码。未 complete 且非合法 fast path → 禁 Change。  
🔴 CHECKPOINT：DoD 缺项或边界将膨胀 → 列问题等用户；🛑 STOP 禁 Change。

### 2) Change

Map complete 或合法 fast path 后，按类型走 [bug](references/bug-workflow.md) / [feature](references/feature-workflow.md) / [refactor](references/refactor-workflow.md)，填 [change.md](templates/change.md)。`evidence_grade` 只能是 `L1` 或 `L2`。**验证**段固定写三块：`步骤:` / `前:` / `后:`（各至少一行实质内容）。最小 diff；非 refactor 禁顺手重构。Refactor：先行为锁；**表征证据**与**回滚点**非空壳；默认 ≥ L1。  
🛑 STOP：无行为锁开 refactor、或证据仍 L0 → 禁宣称 done。

### 3) Leave

填 [notes.md](templates/notes.md)：至少 **改了什么**、**如何回归** 两章有实质行。正式文档仅当用户要求时另写。

## 对人回复

```markdown
## 结论
## 证据 (L1|L2)
## 风险 / 未知
## 产物
`.delegate/<task-slug>/`
```

`onboard`：结论下加「为何走这条路径」；关键路径每跳一句角色。

## 完成闸门

1. Map `status: complete`，或 `fast_path: true` + 短 map（触点+边界）  
2. `evidence_grade: L1|L2` 且验证含 `步骤/前/后`  
3. notes「改了什么」「如何回归」非空壳  
4. check 脚本 stdout：`RESULT: OK`

## 资源

[templates/](templates/) · [resume](references/resume-workflow.md) · [examples](examples.md) · [scripts/check_delegate_artifacts.sh](scripts/check_delegate_artifacts.sh) · [PLAN](PLAN.md)（仅规划/贡献时读，执行流程勿整篇加载）
