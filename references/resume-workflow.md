# 跨会话续跑

若上一会话留下 `.delegate/<task-slug>/`，下一会话**续写同一目录**——除非用户要求新 slug，否则不要从零重做 Orient。

## Orient（续跑探测）

1. 列出目标仓的 `.delegate/`（若存在）。
2. 用户点了 slug 则打开该目录；否则取最新 `in_progress` / `blocked`，或询问用哪个。
3. 先读 `task.md`，再读已有的 `map.md` / `change.md` / `notes.md`。
4. 在 `task.md` 设置或刷新续跑字段：
   - `resume: true`
   - `last_stage`：上一会话已**完成**的阶段（`orient` | `map` | `change` | `leave`）
   - `resume_from`：本会话要**接着**的阶段
5. 用一行告诉用户：从 `<slug>` 的 `<resume_from>` 续跑（附 Map 状态 / 证据若已知）。

## 从哪接着

| 既有状态 | `resume_from` | 允许动作 |
|----------|---------------|----------|
| 仅有 `task.md`（或 Orient 未完） | `orient` | 补完 Orient；再进 Map |
| `map.md` 缺失或 `status: draft` | `map` | 继续 Map；**禁止改业务代码** |
| Map `complete` 或合法 `fast_path`，Change 未扎实 | `change` | 按类型流程进入 Change |
| Change 已完，notes 过薄 / 未跑检查 | `leave` | 补 notes + 跑检查脚本 |
| `status: done` 且检查通过 | — | **禁止**重打补丁；新活开新 slug |
| `status: blocked` | 先前阶段 | 先解决诉求；清除阻塞后再前进 |
| `status: aborted` | — | 保留产物；新活开新 slug |

## 硬规则（与首跑相同）

- 续跑**不得**跳过未完成闸门。
- Map 未 `complete`（且无合法 `fast_path`）→ **仍禁止**改业务代码。
- 证据 **L0** 时不得宣称 **done**。
- 优先更新**同一** `.delegate/<task-slug>/`；仅当用户开新任务才新开 slug。
- 若 notes 有 **续跑交接**，优先作 `resume_from` 与提示（仍须对照文件复核，勿盲信过期交接）。

## 中途停手时的交接

停在半程前更新：

1. `task.md` — `status`、`last_stage`、`resume_from`，备注里写一句
2. `notes.md` — **续跑交接**（已完成、下一步、待确认）
3. **不要**标 `done`，也不要当已完成去跑完成闸门

## 反模式

- 无视已有 `.delegate/`，不读就重写 Map
- 因「上一聊说过 bug 在某文件」就跳进 Change
- 续跑时 Map DoD 未齐却标 `complete`
- 最终 Leave 后不重跑 `check_delegate_artifacts.sh` 就宣称完成
