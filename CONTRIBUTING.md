# 参与贡献

感谢关注 `legacy-delegate`。本仓是 **Agent Skill（作业闸门）**，不是通用框架。

## 怎么提改动

1. Fork / 开分支，改完确保相关检查通过：
   ```bash
   bash scripts/check_delegate_artifacts.sh examples/light-refactor-extract-fn
   bash scripts/check_delegate_artifacts.sh examples/resume-interrupted-map/session-2
   ```
2. 若改了模板章节名，同步更新 `scripts/check_delegate_artifacts.sh` 的中英别名。
3. 对外说明改 `README.md`；路线图与规格改 `PLAN.md`（完成项须勾选并更新文首「当前下一刀」）。
4. PR 说明：动机、改了哪些闸门/模板、如何自测。

## 欢迎的 PR

- 补例子、修文档笔误、加强检查脚本（反 stub / 续跑弱校验）
- 轻量垂直插件（另议；不要把本仓做成车载专用百科）

## 不欢迎 / 需先讨论

- 无 Map 闸门的「全能助手」化
- Darwin / 大规模重写 `SKILL.md` 文风（体积与协议优先）
- 把 `.delegate/` 示例塞进真实密钥

## 行为准则

假设善意；Issue/PR 写清复现与期望。许可见 [LICENSE](LICENSE)（MIT）。
