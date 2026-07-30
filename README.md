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

脚本会检查：必填文件、Map DoD 标记、证据等级 L1/L2，以及**空 stub**（空章节 / 占位表格）。仍不能代替人工审内容质量。

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

## S4 实仓验收（cakeshop · 2026-07-30）

Demo 仓：本地 `cakeshop`（Java/Tomcat Docker，`localhost:8080`）。

### 不启 skill（对照）

| 现象 | 风险 |
|------|------|
| 看到 `CartServlet`/`OrderSubServlet` 就直接加 `if` | 易漏同文件同模式（如只修 `delItem` 不修 `changeIn`） |
| 无 Map / 无证据档 | 事后难审「改了啥、怎么回归」 |
| 可能只改 `build/classes` 或忘 rebuild 镜像 | 源码改了容器仍 500 |

### 启 skill（本轮）

| 类型 | slug | 结果 |
|------|------|------|
| bug | `fix-cart-delitem-null-npe` | 修复前 delItem **500 NPE** → 修复后 **302** 到购物车；`check_delegate_artifacts.sh` OK |
| feature | `guard-empty-cart-on-submit` | 修复前 subOrder **500 NPE** → 修复后 **200** + `请先登录再提交订单`；脚本 OK |

产物在目标仓：`.delegate/<slug>/{task,map,change,notes}.md`（建议 gitignore）。

### 价值一句话

同一类空 session NPE：skill 强制先画链路与边界，再改码并留下 L1 证据，避免「眼熟就过、容器未重建」。
