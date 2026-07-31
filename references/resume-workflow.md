# 跨会话续跑

> **指针**：新任务要复用近邻（含 `done`）产物的触点/边界 → 见 [warm-start.md](warm-start.md)。暖启动开**新** slug；续跑写**同一** slug——二者勿混淆。

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
| `status: done` 且检查通过 | — | **默认**禁止在同 slug 悄悄重打补丁；**新活**开新 slug。例外见下「验收追诉」 |
| `status: blocked` | 先前阶段 | 先解决诉求；清除阻塞后再前进 |
| `status: aborted` | — | 保留产物；新活开新 slug |

## 验收追诉（done 后同控件跟进）

用户在**同一会话**（或明确点名上一 slug）反馈：刚宣称修好的控件仍不可用 / 成功标准有缺口 / notes 里写过的残留风险被戳穿 → **优先重开同一 slug**，不要为「都是下拉框」再开新目录空转 Orient。

| 判定 | 动作 |
|------|------|
| 同入口控件、同用户诉求连续追诉（能开→不能选） | 同 slug：`status: in_progress`，`resume: true`，`resume_from: change`（Map 触点未变可保留 complete；边界膨胀则回 `map`） |
| 追诉只补证据/notes | `resume_from: leave` |
| 真正新问题（另一模块/另一成功标准族） | 新 slug + 暖启动摘旧触点 |

重开时：

1. **禁止**篡改已写的「改前/改后」冒充一次修好；在 `change.md` **追加**「追诉 #N」段（步骤/前/后），`evidence_grade` 仍 ≥ L1。  
2. `notes.md` 记：为何 reopen、相对上一版 done 补了什么。  
3. 再跑 check 脚本；通过后才重新 `status: done`。  
4. **禁止**用「省 token」跳过追加证据。

与暖启动区别：暖启动 = 新活参考近邻；验收追诉 = **同一审计案件未收口**。

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
