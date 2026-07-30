# legacy-delegate

可审计的遗留仓代工 Skill：让**不熟项目的 AI**先 Map 再改，覆盖 bug / feature /（轻量）refactor，并留下证据与笔记。

## 安装

本目录已在：

`~/.cursor/skills/legacy-delegate/`

Cursor 会发现个人 skills。使用时**显式调用**（本 skill 关闭自动调用）：

- 聊天中说明：使用 `legacy-delegate` skill
- 或 `/legacy-delegate`（若客户端支持按 name 触发）

## 和 CLAUDE.md / AGENTS.md 的区别

| | 仓内说明书 | 本 skill |
|--|------------|----------|
| 角色 | 常驻背景与仓规 | 单次任务作业 SOP |
| 何时 | 几乎总在 | 显式调用长链路任务 |

Orient 阶段会**先读**仓规，再跑流程。

## 快速用法

1. 描述任务（bug / 加功能 / 轻量重构）
2. 调用本 skill
3. Agent 在仓库写入 `.delegate/<task-slug>/`
4. 宣称完成前应通过：

```bash
bash ~/.cursor/skills/legacy-delegate/scripts/check_delegate_artifacts.sh .delegate/<task-slug>
```

建议将 `.delegate/` 加入项目 `.gitignore`。

## 阶段

Orient → Map → Change → Leave  

详见 [SKILL.md](SKILL.md)。规格与缺口修订见 [PLAN.md](PLAN.md)。

## Fast path

你已指定精确文件且自认链路清楚时，可要求 fast path；仍须短 map + 证据 ≥ L1。

## Demo 建议

同一小问题对比：

1. 不启 skill，直接让 AI 改  
2. 启 skill，展示 map → change → notes  

示例叙事见 [examples.md](examples.md)。
