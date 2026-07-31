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

给**不熟项目的 AI**在长链路上用的协议：Orient → Map → Change → Leave。  
闸门是**协议 + 可选脚本**，不是内核强制。

## 硬规则

1. 产物写在**目标仓**的 `.delegate/<task-slug>/`。
2. Map 未 `complete` 前**禁止**改业务代码（Fast path 或 `investigate_only` 除外）。
3. 证据为 **L0** 时**不得**宣称 done。优先 L2；有记录可用 L1。
4. 仓规优先：`AGENTS.md`、`CLAUDE.md`、`.cursor/rules`、README 的构建/测试说明。
5. 产物禁止写入密钥。建议把 `.delegate/` 加入 `.gitignore`。
6. 宣称完成前运行：`bash <本 skill>/scripts/check_delegate_artifacts.sh .delegate/<task-slug>`

从 [templates/](templates/) 拷到任务目录后填满（**禁止空壳占位**）。仅当 Map 各 DoD 段都有实质内容时，才可将 `map.md` 标为 `status: complete`（不能是占位 `-` / 空表）。

## 模式

| 模式 | 默认 | 风格 |
|------|------|------|
| `delegate` | 是 | 短结论 + 证据 + 风险 + 未知 |
| `onboard` | 否 | 同结构，多写「为什么」，方便新人 |

任务类型：`bug` | `feature` | `refactor`（MVP：refactor 仅**轻量**，见 [references/refactor-workflow.md](references/refactor-workflow.md)）。

## 何时不该用

遇到下列情况应停下并说明（或设 `aborted`）：纯 typo/文案且已指定文件；用户只要解释；已有完整补丁只需代粘贴；必须 debugger/线上观测才能定位且当前取不到证 → `blocked`。

## 失败模式（若 X → Y）

| 触发 | 先做什么 | 仍失败 → 兜底 |
|------|----------|----------------|
| 缺环境 / 复现 / 权限 | `task.md` 设 `status: blocked`；列出精确诉求 | **🛑 停止** — 不改业务代码；等用户 |
| Map DoD 不完整（未知挡住修复） | 填待确认问题；`map.md` 保持 `status: draft` | **🔴 检查点** — 问用户；**禁止**进入 Change |
| 用户断言链路清楚且给出精确文件 | `fast_path: true` + 理由 + 文件列表；写短 `map.md` | 文件/意图模糊 → 拒绝 fast path；走完整 Map |
| 无法复现 bug | 要复现步骤或用户确认的复现 | `blocked` 或继续查；**禁止**在 L0 打补丁并宣称完成 |
| 已打补丁仍失败 / 根因不清 | 在 `change.md` 记录尝试；按 Map 假设修订 | 写明未知；问用户；不宣称完成 |
| `check_delegate_artifacts.sh` 失败 | 补齐文件 / 章节标记 / `evidence_grade` | 保持 `in_progress`；宣称完成前重跑脚本 |
| Change 中途范围膨胀 | 停手改码；更新 Map 边界 | **🔴 检查点** — 获用户同意后再继续 |
| 不该用本 skill（见上文） | 说明；设 `aborted` | 保留已有产物；不再改代码 |
| 已有 `.delegate/` 但闸门未完 | 同一 slug 续跑；`resume_from` 指到第一个未完成阶段 | 禁止仅凭聊天记忆跳进 Change |
| 用户说「继续」但未给 slug | 优先最新 `in_progress`/`blocked`；否则询问 | 禁止为同一任务另开平行目录 |
| Refactor 无行为锁 / 无回滚点 | 先补表征证据与回滚点；保持 `in_progress` | 禁止在 L0 或基线未跑通时宣称完成 |
| Refactor 范围膨胀到跨模块 | 停手；更新 Map；问用户 | 超出轻量 → `aborted` 或拆新任务 |

## 流程清单

```
进度：
- [ ] Orient → task.md（或续跑：先读已有 .delegate/<slug>/）
- [ ] Map → map.md（DoD）或已记录 fast_path
- [ ] Change → 代码 + change.md（证据 ≥ L1）
- [ ] Leave → notes.md（中途停手则写续跑交接）
- [ ] check_delegate_artifacts.sh 通过
```

### 0) Orient

**先做：** 若目标仓有 `.delegate/`，查找已有 slug（用户指定，或最新 `in_progress`/`blocked`）。找到则**续跑**该目录（读 `task.md` → map/change/notes）；设 `resume: true`、`last_stage`、`resume_from`。细则：[references/resume-workflow.md](references/resume-workflow.md)。

否则新建 `.delegate/<task-slug>/`（`task-slug`：主题短横线命名，必要时加日期）。

按 [templates/task.md](templates/task.md) 填写/更新 `task.md`：

- 类型、模式、成功标准
- 适用时写 `investigate_only` / `fast_path`
- 续跑时写 resume 字段
- 阅读仓规；记下构建/测试命令

**续跑硬规则：** 不得跳过未完成闸门。Map 未 `complete`（且无合法 `fast_path`）→ 仍**禁止**改业务代码。`done` 任务不再重打补丁；新活开新 slug。

**🔴 检查点 · 🛑 停止**：因环境/复现/权限阻塞 → 设 `status: blocked`，列出诉求，**停止**（不进 Map/Change）。中途停手 → 填 `notes.md` **续跑交接**；不宣称完成。

### 1) Map

按 [templates/map.md](templates/map.md) 填写 `map.md`。

**Map DoD**（全部具备才可 `status: complete`）：

1. 相关入口（API/CLI/回调/消费者/…）
2. 到可疑点或改动点的关键路径
3. 触点列表（文件/符号）
4. 影响面
5. 已证实 / 假设 / 未知
6. 允许的改动边界（+ 明确非目标）
7. 信息不齐则列出待用户确认的问题 — 此时**不得** complete

**可选（非 DoD）：** 对已入触点列表的路径附 **Git 线索**（近况 churn / 热点作者），只作上下文；细则见 [references/map-guidance.md](references/map-guidance.md)#何时看-git轻量线索。禁止写成全仓 git 故事，禁止把提交信息当成已证实根因。

**Fast path**：仅当用户给出精确文件/符号 + 意图，并自认链路清楚。在 `task.md` 写 `fast_path: true` + 理由 + 文件列表。仍须写**简版** `map.md`（至少触点 + 边界）。

**仅调查**：完成 Map（+ 可选 notes）；**禁止**改业务代码。

**🔴 检查点 · 🛑 停止**：Map 未 `complete` 且无合法 `fast_path` 前，**禁止**开始 Change。仍有待确认问题 → 问用户并等待。

细节：[references/map-guidance.md](references/map-guidance.md)。

### 2) Change

要求 Map 已 `complete`（或合法 fast path）。然后：

| 类型 | 遵循 |
|------|------|
| bug | [references/bug-workflow.md](references/bug-workflow.md) |
| feature | [references/feature-workflow.md](references/feature-workflow.md) |
| refactor | [references/refactor-workflow.md](references/refactor-workflow.md) |

按 [templates/change.md](templates/change.md) 填写 `change.md`。

**证据等级**

| 等级 | 含义 | 可宣称完成？ |
|------|------|--------------|
| L0 | 仅推理 | **否** |
| L1 | 可复现步骤（或用户确认）+ 前后对比 | 可，须注明尚无自动化 |
| L2 | 测试或约定日志/探针通过 | 可，优选 |

最小 diff。除非任务类型是 refactor，否则禁止「顺便」重构。

**Refactor：** 遵循 [references/refactor-workflow.md](references/refactor-workflow.md)。改结构前先做**行为锁**（表征测试或手工基线）；`change.md` 必填 **表征证据**、**回滚点**；默认证据 **≥ L1**。

**🔴 检查点**：证据仍为 L0，或脚本检查失败 → **不得**宣称完成；按失败模式表处理。

### 3) Leave

按 [templates/notes.md](templates/notes.md) 填写 `notes.md`：改了什么、如何回归、未知、后续。  
可选：仅当用户要求时，把稳定事实写入仓内正式文档。

## 对人回复形态

**delegate**

```markdown
## 结论
...
## 证据 (L1|L2)
...
## 风险 / 未知
...
## 产物
`.delegate/<task-slug>/`
```

**onboard**：同样标题；在「结论」下短写「为何走这条路径」；`map.md` 关键路径每一跳加**一句角色说明**。

## 完成闸门（宣称完成前）

1. Map `complete`，或合法 `fast_path` + 短 map（触点 + 边界）
2. `change.md` 有 `evidence_grade: L1` 或 `L2`，且步骤 / 前 / 后已填
3. `notes.md` 有回归步骤（非空）
4. `bash <本 skill>/scripts/check_delegate_artifacts.sh .delegate/<task-slug>` → `RESULT: OK`

## 脚本

- [scripts/check_delegate_artifacts.sh](scripts/check_delegate_artifacts.sh) — 必填文件、DoD 标记、L1/L2、**朴素反 stub**（空章节/占位表失败）。仍**不能**完全判断内容质量。

## 更多资源

- 模板：[templates/](templates/)
- 续跑：[references/resume-workflow.md](references/resume-workflow.md)
- 计划 / 完整规格：[PLAN.md](PLAN.md)
- 示例走通：[examples.md](examples.md)
