# 第二真实仓 Case：MartinAgent（Python）

> 对照第一 Demo [cakeshop](https://github.com/Seven-second-fish/cakeshop)（Java / Tomcat / Docker），本 case 换 **Python** 技术栈验证泛化。
> 仓：[Seven-second-fish/MartinAgent](https://github.com/Seven-second-fish/MartinAgent)（ReAct 命令行 AI Agent）
> 日期：2026-08-01 · 模式：bug + fast_path · 证据：L2

## 题目

对话记忆超出 `max_turns` 后历史不裁剪：

- `ConversationMemory` 批量塞入 60 条后再 `add`，长度仍是 60（期望裁回 ≤ `max_turns*2`）
- `PersistentMemory` 从磁盘加载 40 条历史后，长度仍是 40（`_load` 从不裁剪）

## 裸改 vs 启 skill（同一小问题跑两遍）

| | 裸改（不启 skill） | 启 legacy-delegate |
|--|---------------------|---------------------|
| 做法 | 直接加 `_trim_history()`，`add_message` 后调用 | 先复现 → Map（触点 + 边界 + 影响面）→ 最小 diff → 补测试 → check 脚本 |
| 裁剪路径覆盖 | 批量注入 / 磁盘加载两个点都覆盖了 | 同左，另覆盖无 user 消息场景（全 assistant 增量 60 条） |
| 产物 | 无（改完即走，不可审） | `.delegate/memory-max-turns-trim/` 四件套 + `tests/test_memory.py` 12 用例 |
| 证据 | 自写临时脚本跑一遍 | L2：测试 6 FAIL → 12/12 OK，repro 五场景改前/改后对照 |
| 防伪 | 无（改完就报「修复完成」） | 成功标准 6/6 勾选，每条指到证据；check `RESULT: OK` |
| 边界纪律 | 无声明 | map 写清：只动 2 个 memory 文件，禁动 agent.py / 协议 / 文档 |

**裸改的翻车点**（无 skill 组自述「基本可靠」但无证据）：无法证明「没改坏别的路径」——没有基线记录、没有失败集合对照、没有防回归测试；下次重启/重构后无人知道行为被谁改过。

## 链路（Map 摘要）

```
agent.py:50 构造 ConversationMemory(max_turns=20)
  → add_message（唯一裁剪点，每次最多删 1 轮且 break 即止）
  → PersistentMemory._load（json 直赋 _history，完全绕过裁剪）
  → get_messages（供 LLM，超限历史全量上送 → token 膨胀）
```

触点：`conversation.py`（`add_message` / 裁剪逻辑）、`persistentmemory.py`（`_load`）
根因：裁剪不是**强制不变量**——批量/加载路径绕过；且删除依赖「找到 user 消息」，全 assistant 时不删。

## 修复（最小 diff）

1. `conversation.py`：裁剪收敛为强制不变量 `_enforce_max_turns()`——循环删至非 system ≤ `max_turns*2`；优先成对删最旧 user+assistant；无 user 时删最旧非 system；**system 永不删**
2. `persistentmemory.py`：`_load` 加载后调 `_enforce_max_turns()`
3. 新增 `my-agent/tests/test_memory.py`（标准库 unittest，12 用例）
4. `.gitignore` 补 `.delegate/`

## 验证（证据 L2）

| 场景 | 改前 | 改后 |
|------|------|------|
| 批量注入 60 + add | 59（只删 1 轮） | 39 ≤ 40 |
| 全 assistant 增量 60 次 | 60（找不到 user 不删） | 40 |
| 磁盘 100 条 `_load` | 100（加载不裁剪） | 40 |
| 测试套件 | 6 FAIL | 12/12 OK |

复现与回归：`python3 .delegate/memory-max-turns-trim/repro.py`（仓根）→ 全场景 ≤ 40；`cd my-agent && python3 -m unittest tests/test_memory.py -v` → 12/12。

## 产物

- `MartinAgent/.delegate/memory-max-turns-trim/`（task / map / change / notes，fast_path: true + 完整 DoD map）
- `MartinAgent/my-agent/tests/test_memory.py`

## 备注

- fast_path 判定：用户点名文件级 + 意图 → 合法 fast path；但仍填满全 DoD map + 复现证据，未降级（§3.1：fast path 豁免的是 Map 厚度，不是证据）
- 遗留：`_load` 裁剪后不立即写盘（下次 `add_message`/`clear` 才同步，行为已由测试锁定）；库代码 `print` 属既有设计未动
- 本 case 与 cakeshop 的差异：cakeshop 走全 Map（陌生仓），MartinAgent 走 fast_path + 完整 map（点名文件）；两种分流路径各验证一遍
