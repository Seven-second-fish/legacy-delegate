# Orient 轻量暖启动

新会话、用户未点名路径也未提旧产物时，用仓内近邻 `.delegate/` 作**线索**，缩短定向读。**不免 Map**；不得自动继承为新任务 DoD。

## 续跑 vs 暖启动 vs 验收追诉

| | 续跑 | 暖启动 | 验收追诉 |
|--|------|--------|----------|
| 对象 | **同一** slug，`in_progress` / `blocked` | **新** slug；参考近邻 `done` | **同一** slug，刚 `done` 但用户追诉未收口 |
| 旧 map 角色 | 接着写同一份 | **线索**（触点/边界），非新 DoD | 通常保留；边界膨胀再改 |
| 能否免 Map | 否 | 否（除非用户确认 fast path） | 触点未变可保留 complete，直接 `resume_from: change` |

细则：续跑/验收追诉见 [resume-workflow.md](resume-workflow.md)；本文件只管暖启动。

## Orient 步骤

1. 若存在 `.delegate/`：**优先**探测续跑（`in_progress` / `blocked`）→ 走续跑流程，**不要**当暖启动开新 slug。  
   若最新相关 slug 为 `done`，但用户话术是「还是不行 / 能开不能选 / 同一控件」→ 走**验收追诉**（同 slug 重开），**不要**新开 slug。
2. 否则（真正新任务）：按 mtime 扫描最近 **≤5** 个 slug（**含** `done`）；用户话术像「还是不行 / 同控件缺口」→ 优先验收追诉而非新 slug。
3. 对每个候选只摘：
   - map 的 **触点列表** + **改动边界**
   - task 的 **成功标准** 一行  
   **勿**把整份旧 map 灌进上下文。
4. 写入**本题** map 的「假设」或「历史线索 / 暖启动」段，每条注明 `source: .delegate/<old-slug>/`，标明**仅作线索**。
5. 路径/模块**疑似相关** → 🔴 CHECKPOINT 问用户：是否参考旧产物 / 是否走 fast path。  
   - 未确认前：仍按本题做 Map（可缩短定向读）。  
   - **禁止**自动 `fast_path: true`。  
   - **禁止**复制旧 map 改 `status` 冒充本题 `complete`。
6. **旧产物自证失效（假 done）**：旧 `change.md` 声称已修（`status: done` + L1/L2），但当前代码未见该修复、或复现仍红 → 以**代码为准**，旧 claim 只当线索，按完整 Map 走本题；把「旧 map 疑过期」写进本题「未知」，并在 CHECKPOINT 提示用户旧 done 不可信。

## 硬约束

- **真正新活** → 新 slug。`done` / `aborted` 不得悄悄改码冒充旧案一次修完。  
- **验收追诉**（同控件、用户追诉未收口）→ **同 slug 重开**，见 [resume-workflow.md](resume-workflow.md#验收追诉done-后同控件跟进)；不是暖启动。  
- 完成宣称仍须证据 **≥ L1**（追诉段也要）。  
- 旧 map 可能过期 → 把过期风险写进「未知」。

## 明确不做

- 向量检索 / 相似度评分
- 「相似」即免 Map 或自动 complete
- 多份旧 map **全文**塞进一轮上下文
- 跨仓共享知识库
