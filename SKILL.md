---
name: legacy-delegate
description: >-
  可审计的遗留仓代工：先摸清长调用/数据链路再改代码，按证据等级修 bug / 加功能 / 轻量重构，
  并留下给人与后续 Agent 可读的笔记。支持跨会话续跑已有 `.delegate/<slug>/`，且不得跳过
  Map/证据闸门。在显式调用、陌生模块、长链路排查、代修 bug、跨层加功能、续跑上次代工、
  或不允许跳过理解的安全重构时使用。
disable-model-invocation: true
---

# Legacy Delegate（遗留仓可审计代工）

不熟仓 AI 的长链路协议：**Orient → Map → Change → Leave**。闸门 = 协议 + 可选脚本（非内核强制）。

## 硬规则

1. 产物在**目标仓** `.delegate/<task-slug>/`。
2. Map 未 `complete` 禁改业务代码（Fast path / `investigate_only` 除外）。
3. 证据 **L0** 不得宣称 done（优先 L2，L1 须有记录）。
4. 仓规优先：`AGENTS.md` / `CLAUDE.md` / `.cursor/rules` / README 构建测试。
5. 产物禁密钥；建议 `.gitignore` 忽略 `.delegate/`。
6. 完成前：`bash <本 skill>/scripts/check_delegate_artifacts.sh .delegate/<task-slug>` → `RESULT: OK`

拷贝 [templates/](templates/) 填满（禁空壳）。`map.md` 仅 DoD 齐全时可 `status: complete`。

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
| 缺环境/复现/权限 | `blocked` + 精确诉求 | 停手，不改业务代码 |
| Map DoD 不齐 | 保持 `draft`，列待确认 | 禁 Change，问用户 |
| 用户给精确文件+意图 | `fast_path` + 短 map | 模糊则拒绝，走全 Map |
| 无法复现 / 补丁仍红 | 记录尝试，修订假设 | 勿 L0 宣称完成 |
| 检查脚本 FAIL | 补文件/章节/证据 | 保持 `in_progress` |
| 范围膨胀 | 停手，更新 Map 边界 | 问用户后再改 |
| 续跑闸门未完 | 同 slug，`resume_from` 未完成阶段 | 禁凭聊天记忆进 Change |
| Refactor 无表征/回滚 | 先补行为锁与回滚点 | 禁 done；跨模块则拆任务 |

## 流程

```
Orient(task.md | 续跑已有 slug) → Map(DoD|fast_path) → Change(≥L1) → Leave(notes) → check 脚本
```

### 0) Orient

有 `.delegate/` 则先续跑（用户 slug 或最新 `in_progress`/`blocked`）：读产物，设 `resume: true`、`last_stage`、`resume_from`。[resume-workflow](references/resume-workflow.md)。否则新建 kebab-case slug 目录，按 [task.md](templates/task.md) 填类型/模式/成功标准/`fast_path`/resume/仓规命令。

续跑不跳闸门；`done` 不重打补丁。阻塞 → `blocked` 停。中途停 → notes **续跑交接**。

### 1) Map

按 [map.md](templates/map.md)。**DoD**：入口、关键路径、触点、影响面、已证实/假设/未知、改动边界；缺信息则待确认问题且不得 complete。可选 **Git 线索**（非 DoD）→ [map-guidance](references/map-guidance.md)。Fast path：短 map（触点+边界）+ `task.md` 记录。仅调查：完成 Map，禁改码。未 complete 禁 Change。

### 2) Change

Map complete 或合法 fast path 后，按类型走 [bug](references/bug-workflow.md) / [feature](references/feature-workflow.md) / [refactor](references/refactor-workflow.md)，填 [change.md](templates/change.md)。证据：L0 否；L1 复现前后；L2 测试/探针。最小 diff；非 refactor 禁顺手重构。Refactor：先行为锁；必填表征证据+回滚点；默认 ≥ L1。

### 3) Leave

填 [notes.md](templates/notes.md)。正式文档仅当用户要求。

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

1. Map `complete` 或合法 `fast_path` + 短 map  
2. `evidence_grade: L1|L2` + 步骤/前/后  
3. notes 回归非空  
4. check 脚本 `RESULT: OK`

## 资源

[templates/](templates/) · [resume](references/resume-workflow.md) · [PLAN](PLAN.md) · [examples](examples.md) · [scripts/check_delegate_artifacts.sh](scripts/check_delegate_artifacts.sh)
