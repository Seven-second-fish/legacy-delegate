# Changelog

本仓遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)；版本号遵循 [SemVer](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-08-01

首个正式版本。流程闸门 + 可审计代工全能力落地，并完成真实仓验收与多工具验证。

### Added（能力）

- **Orient → Map → Change → Leave** 阶段状态机，Map 未 `complete` 禁改业务代码
- 三种任务类型：`bug` / `feature` / `light refactor`（refactor 强制行为锁 + 回滚点）
- 两种模式：`delegate`（短结论可拍板）/ `onboard`（多写为什么）
- Fast path 豁免（用户点名**文件/符号级** + 意图）+ 黑名单退出（typo / 纯解释 / 粘贴补丁 / 无法复现）
- 证据等级 L0/L1/L2：**L0 禁宣称 done**；验证固定「步骤/前/后」三块
- 产物落盘 `.delegate/<task-slug>/` 四件套，check 脚本反 stub + `--draft` 中途态
- 跨会话续跑（`resume` 字段）+ 验收追诉（同控件 done 后重开同 slug）
- Orient 暖启动：近邻 `.delegate/` 只摘触点/边界作线索，不免 Map
- 成功标准**结果链**（可操作态 → 意图动作 → 可观察后果），残留风险禁伪 done
- Token 经济支柱：砍空转不砍闸门；分流（黑名单 / fast path / 全 Map / investigate_only / 续跑 / 暖启动 / 验收追诉）

### Added（工程 / 开源）

- `scripts/check_delegate_artifacts.sh`：完成态校验（含 blocked/aborted 合法退出、investigate_only 放行 `N/A`）
- `scripts/run_evals.sh` + `evals/manifest.json` + `evals/prepare_fixtures.sh`：**16 条 eval 一键回归**（fixture git 化，git diff 精确断言改动范围）
- `docs/`：demo-walkthrough 权威轮播、裸改 vs 启 skill 对比、`tooling-matrix.md` 三端兼容、`case-martinagent.md` 第二真实仓对照
- `test-prompts.json`：11 条轻量 prompt；`.github/ISSUE_TEMPLATE/second-repo-case.md` 第二真实仓贡献入口

### Verified（验证）

- **黄金路径**：cakeshop（Java/Tomcat/Docker）真实仓验收（2026-07-30）
- **第二真实仓**：MartinAgent（Python）裸改 vs 启 skill 对照（2026-08-01）
- **Eval 回归**：16/16 断言全过（2026-08-01），覆盖 bug / feature / refactor / fast path / 续跑 / 黑名单 / investigate_only / 暖启动 / token 经济 / 验收追诉 / 结果链 / blocked / 粘贴补丁 / 范围膨胀 / 跨模块拒绝 / L0 禁 done
- **跨工具**：opencode 1.18.10 + Claude Code 2.1.220 实测行为一致；Cursor 3.13.10 静态适配（2026-08-01）

### Changed

- 迭代期文档骨架 → `PLAN.md`（内部规格/路线图）、`README.md`（对外中文入口）、`CONTRIBUTING.md`

### 版本历程

- 第一～五期：MVP → 能力 → 审查打磨 → 暖启动 → 验收闭环（未发版，均为预发布迭代）
- 第六～十期：eval 实测 → 回归自动化 → 第二真实仓 → 跨工具验证（未发版，均为预发布迭代）
