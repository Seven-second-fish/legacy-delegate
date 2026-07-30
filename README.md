# legacy-delegate

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-Seven--second--fish%2Flegacy--delegate-181717?logo=github)](https://github.com/Seven-second-fish/legacy-delegate)
[![Cursor Skill](https://img.shields.io/badge/Cursor-Skill-000000)](https://cursor.com/docs/context/skills)

可审计的**遗留仓代工** Skill：让不熟项目的 AI **先 Map 再改**，覆盖 bug / feature /（轻量）refactor，并留下证据与笔记。

> 流程通用（无 Map 不准改）+ 能力通用（考古 → 改 → 留档）。默认服务「老人甩活可审」，兼带新人 onboard。

## 安装

### 方式 A：`npx skills`（推荐）

```bash
npx skills add Seven-second-fish/legacy-delegate -g
```

装到用户级 Cursor skills 目录后，在聊天里**显式调用**（本 skill 关闭自动挂载）：

- 说明：使用 `legacy-delegate` skill
- 或输入 `/legacy-delegate`（若客户端支持按 name 触发）

### 方式 B：手动克隆

```bash
git clone https://github.com/Seven-second-fish/legacy-delegate.git \
  ~/.cursor/skills/legacy-delegate
```

已在个人 skills 目录则无需再装。

### 检查脚本（可选）

宣称完成前建议在目标仓跑：

```bash
bash ~/.cursor/skills/legacy-delegate/scripts/check_delegate_artifacts.sh \
  .delegate/<task-slug>
```

检查：必填文件、Map DoD 标记、证据等级 L1/L2、空 stub。不代替人工审内容质量。

建议将目标仓的 `.delegate/` 加入 `.gitignore`。

## 和 CLAUDE.md / AGENTS.md 的区别

| | 仓内说明书 | 本 skill |
|--|------------|----------|
| 角色 | 常驻背景与仓规 | 单次任务作业 SOP |
| 何时 | 几乎总在 | 显式调用长链路任务 |

Orient 阶段会**先读**仓规，再跑流程。

## 快速用法

1. 描述任务（bug / 加功能 / 轻量重构）
2. 调用本 skill
3. Agent 在目标仓写入 `.delegate/<task-slug>/`
4. 宣称完成前跑检查脚本（见上）

阶段：`Orient → Map → Change → Leave`  

详情：[SKILL.md](SKILL.md) · 规格与路线图：[PLAN.md](PLAN.md) · 虚构走通：[examples.md](examples.md)

## Fast path

你已指定精确文件且自认链路清楚时，可要求 fast path；仍须短 map + 证据 ≥ L1。

## Demo：前后对比（cakeshop）

Demo 仓：[Seven-second-fish/cakeshop](https://github.com/Seven-second-fish/cakeshop)（Java/Tomcat + Docker，`localhost:8080`）。

### 不启 skill（对照）

| 现象 | 风险 |
|------|------|
| 看到 `CartServlet`/`OrderSubServlet` 就直接加 `if` | 易漏同文件同模式（如只修 `delItem` 不修 `changeIn`） |
| 无 Map / 无证据档 | 事后难审「改了啥、怎么回归」 |
| 可能只改 `build/classes` 或忘 rebuild 镜像 | 源码改了容器仍 500 |

### 启 skill（2026-07-30）

| 类型 | slug | 结果 |
|------|------|------|
| bug | `fix-cart-delitem-null-npe` | 修复前 delItem **500 NPE** → 修复后 **302** 到购物车；检查脚本 OK |
| feature | `guard-empty-cart-on-submit` | 修复前 subOrder **500 NPE** → 修复后 **200** + 登录提示；脚本 OK |

**黄金路径**（curl）：登录 → 加购 → 提交 → **订单提交成功**；守卫未误伤。产物在目标仓 `.delegate/<slug>/`（建议 gitignore，本地留档即可）。

**价值一句话**：同一类空 session NPE——强制先画链路与边界，再改码并留下 L1 证据，避免「眼熟就过、容器未重建」。

自备对比时也可：同一小问题先不启 skill 直接改，再启 skill 走 Map → Change → Notes。

## 仓库结构

```text
legacy-delegate/
├── SKILL.md                 # 主流程（显式调用）
├── PLAN.md                  # 规格与实施计划
├── README.md                # 本文件
├── LICENSE                  # MIT
├── examples.md              # 虚构小仓走通
├── templates/               # task / map / change / notes
├── references/              # bug / feature / refactor / map 指引
└── scripts/
    └── check_delegate_artifacts.sh
```

## 何时适合用

- 接手老项目 / 陌生模块 / 长链路 bug
- 跨多层加功能、影响面不清
- 重构但怕改炸；「让 AI 改，我只审」

不适合：纯 typo、只要概念解释、已有完整补丁代粘贴、环境无法取证却硬改。见 `SKILL.md`。

## License

[MIT](LICENSE)
