# legacy-delegate — 计划文档

> 状态：第一、二、三期已完成；**维护模式**  
> 位置：`~/.cursor/skills/legacy-delegate/`  
> GitHub：https://github.com/Seven-second-fish/legacy-delegate · Demo：cakeshop  
> **当前下一刀：无（第三期 Q1–Q5 已完成）**  
> 更新日期：2026-07-31  
> 审查：create-skill 清单 · 功能结论见 §6.4

本文件 = **内部规格 + 路线图 + 待办**。对外入口见 `README.md`（中文）。

完成 §6.2 / §6.4 任一项后，必须同步勾选并改文首「当前下一刀」。

---

## 1. 一句话定位

让**不熟悉项目的 AI**在长链路场景下**先摸清再改**，覆盖查 bug、加功能、重构，并把证据与文档留下；人可以是新人，也可以是甩手的老人。

**产品名**：`legacy-delegate`（遗留仓可审计代工）  
**不是**：普通 code review、纯报告式考古、车载垂直专用工具。

---

## 2. 问题与场景

### 2.1 共同卡点

真正动手的是「刚装上、不熟仓」的 AI；任务常常链路很长（跨模块 / 跨配置 / 跨进程）。

### 2.2 场景 A：刚入职新人

- 人也不熟，要靠 AI 上手并交付（修 bug / 加功能 / 重构）
- 需要：地图可读、过程可学、结果可审、知识可留

### 2.3 场景 B：老人熟但不想亲自挖

- 人不想查长链路，想把活交给 AI
- 需要：短结论 + 证据链，30 秒可拍板；防「眼熟就过、AI 实际没查清」

### 2.4 设计默认

**默认按场景 B（可审计代工）做硬**；场景 A 共用产物，多一层解释即可。

---

## 3. 产品形态：流程闸门 + 能力全包

| 层次 | 含义 |
|------|------|
| 流程通用 | 任何项目都「先理解再改」——无 Map 不准 Change |
| 能力通用 | 考古 → 修 bug / 加功能 / 重构 → 留档，同一条绳 |

关系：流程通用是底座；能力通用是挂在底座上的作业线。

---

## 4. 阶段状态机（核心设计）

禁止跳步（Fast path / Investigate-only 除外，见 §14）。  
产物落盘到：`<repo>/.delegate/<task-slug>/`（防多任务碰撞）。

| 阶段 | ID | 职责 | 必产 |
|------|-----|------|------|
| 0 | Orient | 确认任务类型、模式、成功标准、是否豁免 | `task.md` |
| 1 | Map | 链路、影响面、已证实/假设/未知；满足 Map DoD | `map.md` |
| 2 | Change | 按任务类型最小改动 + 证据等级 | `change.md` + 代码 |
| 3 | Leave | 回归点、排障笔记、可选正式文档 | `notes.md` |

闸门性质：**协议约束 + 可选脚本检查**，skill 无法内核级强制；Agent 宣称 done 前应跑检查脚本。

### 4.1 Change 子策略

| 任务类型 | 策略要点 |
|----------|----------|
| bug | 复现 → 假设树 → 定点补丁 → 证据（测试/日志/行为对比） |
| feature | 触点清单 → 最小切入 → 不破坏旧链路 |
| refactor | 先锁行为/补表征 → 小步可回滚 → 禁止顺手大优化 |

### 4.2 人模（口吻）

| 模式 | 何时 | 输出风格 |
|------|------|----------|
| `delegate`（默认） | 老人甩给 AI | 短结论 + 证据 + 风险 + 未验证项 |
| `onboard` | 新人上手 | 同结构，多写「为什么这样判断」 |

---

## 5. 与市面差异

| 市面常见「考古」skill | 本 skill |
|----------------------|----------|
| 读懂 / git 故事 / 技术债报告 | 读懂是为了**代工交付** |
| 往往停在报告 | **必须改完并留下可审计证据** |
| 偏 onboarding | **默认服务 delegate，兼带 onboard** |
| 闸门弱或没有 | **Map 未完成，禁止改代码** |

---

## 6. 范围：做 / 不做

### 6.1 MVP（第一期）

- [x] `SKILL.md`：阶段闸门、模板、触发描述
- [x] 产物模板：`task.md` / `map.md` / `change.md` / `notes.md`
- [x] bug + feature 两条 Change 流程写死
- [x] `delegate` / `onboard` 两种输出密度
- [x] 使用说明（README）：如何安装、如何触发、Demo 建议
- [x] 可选：`examples.md` 用一个虚构小仓走通一遍

### 6.2 第二期（能力）

执行顺序：P1 → P2 → P3（可与 P2 并行）→ P4（随时可插队）→ P5。

#### P1 — 跨会话续跑

- [x] Orient：若目标仓已有 `.delegate/<slug>/`，先读再决定从哪一阶段接着
- [x] `task.md` / `notes.md` 约定续跑字段（如 `resume_from`、`last_stage`）
- [x] `SKILL.md`：续跑不得跳过未完成闸门；Map 未 complete 仍禁改码
- [x] 走通「中断于 Map → 新会话续跑」1 次；README 补 Resume 一小段

#### P2 — refactor 完整闸门

- [x] 扩充 `references/refactor-workflow.md`：表征测试、行为锁、回归清单
- [x] Change 模板 refactor 必填段（表征证据、回滚点）；默认证据 ≥ L1
- [x] 实仓或小仓跑 1 例轻量 refactor（禁止顺手大优化）

#### P3 — git 历史轻量结合

- [x] Map 可选附关键触点 churn / 热点作者（只作线索）
- [x] 边界：不作纯 git 故事 skill；`map-guidance.md` 加「何时看 git」

#### P4 — 开源曝光与 Demo 资产

- [x] README Demo GIF / 短录屏（裸改 vs 启 skill）
- [x] 分享 skills.sh / Cursor 社区；可选第二真实仓 case

#### P5 — 可选打磨

- [x] 压缩 `SKILL.md`（Darwin dim9 **跳过**，按用户要求不跑）
- [x] 检查脚本续跑弱校验；可选 `CONTRIBUTING.md`

#### 已落地（原第二期 scripts）

- [x] 简单 `scripts/`（必填文件 + DoD 标记 + 反 stub）

### 6.3 明确不做（保持边界）

- 车载协议 / ARXML / DBC / FIBEX 专项（可另开垂直插件仓）
- 大型静态分析平台、自动全仓重构
- 替代团队规范的通用 code review
- 与 `CLAUDE.md` / `AGENTS.md` 抢「常驻项目说明书」定位（本 skill 是作业流程，非常驻百科）

### 6.4 第三期（create-skill 审查后）

**审查结论（2026-07-31）**：功能定位**合理**，值得保留并小步打磨，不必大改架构。

| create-skill 维度 | 现状 | 判断 |
|-------------------|------|------|
| 定位 / 自由度 | 作业闸门 + 代工交付；显式调用 | ✅ 对症；非百科、非 CR 替代 |
| 简洁 / ≤500 行 | `SKILL.md` ~95 行；细节在 references | ✅ progressive disclosure |
| description WHAT+WHEN | 中文第三人称 + 触发场景 | ✅；Q3 可补英文触发词利于目录发现 |
| 反馈环 | 完成前跑 check + 反 stub | ✅；质量仍靠人审 Map 实质 |
| 模板 / 脚本 | templates + check 脚本 | ✅ |
| 引用深度 | SKILL → references 一层 | ✅ |
| 短板 | bug/feature 指引过薄；Demo GIF 信息弱；缺轻量 eval | → 下列 Q1–Q5 |

**保持不做**：车载垂直百科、全仓自动重构、抢 `AGENTS.md` 常驻位、默认跑 Darwin。

执行顺序：Q1 → Q2 → Q3（可与 Q2 并行）→ Q4 → Q5（随时可插队）。

#### Q1 — 补齐 bug/feature 流程厚度

- [x] 扩充 `references/bug-workflow.md`：假设树、最小补丁、证据落点（仍短于 refactor 全文）
- [x] 扩充 `references/feature-workflow.md`：触点竖切、兼容风险、回归要点
- [x] `SKILL.md` Change 表保持链到上述文件；不把细则塞回主文件

#### Q2 — Demo 资产可读性

- [x] 替换/增强 `docs/demo-bare-vs-skill.gif`（可读中文幕或静态 PNG + 保留 walkthrough）
- [x] README 标明「轮播页为权威对照；GIF 为示意」

#### Q3 — 发现力（description）

- [x] `SKILL.md` description 增加少量英文触发词（legacy, map-first, evidence grade 等），保持中文主述
- [x] 核对 skills.sh / 安装说明与 description 一致

#### Q4 — 轻量自测 / eval

- [x] 扩充 `test-prompts.json`（含续跑、refactor、fast path、不该用各 ≥1）
- [x] 可选：`scripts/smoke_examples.sh` 批量跑 examples 目录 check

#### Q5 — 仓卫生与可选增强

- [x] 确认 darwin 产物已 gitignore；README/PLAN 勿链到本地卡片
- [x] （可选）check 脚本 `--draft`：中途续跑目录允许缺 change 不 FAIL
- [x] （可选）第二真实仓 case Issue 模板

---

## 7. 目标目录结构（实现时）

```text
~/.cursor/skills/legacy-delegate/
├── PLAN.md                 # 本计划（已有）
├── README.md               # 安装与用法（中文，开源访客入口）
├── LICENSE                 # MIT
├── SKILL.md                # 主技能
├── templates/
│   ├── task.md             # 含 resume / last_stage / resume_from
│   ├── map.md
│   ├── change.md
│   └── notes.md            # 含续跑交接
├── references/
│   ├── bug-workflow.md
│   ├── feature-workflow.md
│   ├── refactor-workflow.md
│   ├── map-guidance.md
│   └── resume-workflow.md  # 跨会话续跑
├── scripts/
│   └── check_delegate_artifacts.sh
├── examples.md
└── examples/
    ├── resume-interrupted-map/   # session-1 draft Map → session-2 续跑
    └── light-refactor-extract-fn/  # 轻量抽函数 + 表征锁
```

项目内运行时产物（由 Agent 写入被操作的仓库）：

```text
<repo>/.delegate/
├── <task-slug>/
│   ├── task.md
│   ├── map.md
│   ├── change.md
│   └── notes.md
└── (建议根目录 .gitignore 忽略 .delegate/ 或仅提交脱敏 notes)
```

---

## 8. SKILL.md 元数据草案

```yaml
name: legacy-delegate
description: >
  可审计的遗留仓代工：先摸清长调用/数据链路再改代码，按证据等级修 bug / 加功能 /
  轻量重构，并留下给人与后续 Agent 可读的笔记。支持跨会话续跑。在显式调用、陌生
  模块、长链路排查、代修 bug、跨层加功能或不允许跳过理解的安全重构时使用。
```

- **MVP：`disable-model-invocation: true`** —— 仅用户显式调用（`/legacy-delegate` 或点名 skill），避免小改被强行套流程。
- 第 9 节触发词供 README / 用户决定何时调用，**不是**自动挂载依据。
- 描述需含 WHAT + WHEN，第三人称。

---

## 9. 触发词（供用户显式调用时参考）

适合调用本 skill 的意图：

- 接手老项目 / 陌生模块 / 没人懂
- 长链路 bug、查起来麻烦、不想自己跟
- 跨多层加功能、影响面不清
- 重构但怕改炸
- 「让 AI 改，我只审」「先别改代码，先摸清」

**不适合**（应退出 / 不用本 skill）：见 §14.4。

---

## 10. 验收标准

### 10.1 行为验收

1. 无 `.delegate/map.md`（或 Map 未标完成）时，Agent **不得**提交业务代码修改。
2. 声称 bug 已修复时，`change.md` 必须含：假设、验证步骤、证据；否则不得宣称 done。
3. feature / refactor 必须列出触点或影响面，并与 `map.md` 一致。
4. `notes.md` 至少包含：改了什么、怎么回归、已知未知项。

### 10.2 Demo 验收（开源/面试）

选一个公开小仓或自备 demo 仓：

1. 直接让 AI 改 → 记录翻车或漏层  
2. 启用本 skill → 展示 Map → Change → Notes  
3. README 用前后对比说明价值  

### 10.3 质量约束

- `SKILL.md` < 500 行；细节进 `references/` / `templates/`
- 术语统一：Orient / Map / Change / Leave；bug / feature / refactor；delegate / onboard

---

## 11. 实施计划

| 步骤 | 内容 | 产出 |
|------|------|------|
| S0 | 本计划评审、定名与范围确认 | `PLAN.md` ✅ |
| S1 | 写 `SKILL.md` 主流程 + frontmatter | ✅ |
| S2 | 补齐 `templates/` 与 `references/` | ✅ |
| S3 | 写 `README.md` + `examples.md` + check script | ✅ |
| S4 | 用真实或 demo 仓跑通 bug + feature 各 1 例 | ✅ cakeshop 2026-07-30 |
| S5 | （可选）加强 scripts | ✅ 反 stub / 实质段落检查 2026-07-30 |
| S6 | （可选）整理为 GitHub 仓库对外开源 | ✅ README 徽章/安装/Demo + MIT LICENSE 2026-07-30 |

**第一期：S0–S6 完成；黄金路径已验收（cakeshop）。**  
**第二期：P1–P5 ✅（2026-07-31）。**  
**第三期：§6.4 Q1–Q5 已完成（2026-07-31）；维护模式。**

第二期共用验收：无 Map complete 不改业务代码；禁 L0 宣称 done；完成前跑 check 脚本；对外叙事仍是代工 + 可审计；对外 README 为中文；续跑不得跳过未完成闸门。

---

## 12. 风险与对策

| 风险 | 对策 |
|------|------|
| 做成空壳万能助手 | 协议闸门 + Map DoD + MVP 只做透 bug/feature |
| 产物太重，老人嫌烦 | 默认 `delegate`；Fast path 豁免 |
| 与 CLAUDE.md 混淆 | README：常驻说明 vs 作业 SOP；Orient 先读仓规 |
| 上下文被长 skill 占满 | progressive disclosure |
| 开源难涨星 | Demo before/after |
| 闸门无法内核强制 | 检查脚本 + 禁止在证据 L0 宣称 done |
| `.delegate/` 泄密 | gitignore；禁止写入密钥/令牌 |

---

## 13. 待确认问题（已默认拍板）

见上文「默认拍板」。若要改名或开源，实现后可再调。

---

## 14. 规格缺口与修订

### 14.1 Map Definition of Done

`map.md` 标记 `status: complete` 前必须具备：

1. 任务相关**入口**（进程/API/回调/CLI/消息消费等）  
2. **关键路径**（从入口到可疑点或改动点，逐步列出）  
3. **触点文件/符号**列表（准备改或强相关）  
4. **影响面**（可能波及的模块/调用方）  
5. 三栏：**已证实 / 假设 / 未知**  
6. **建议改动边界**（允许改哪些；明确禁止顺手改哪些）  
7. 若信息不足：列出**待用户补充的问题**，不得假装 complete  

空文件或只有标题 ≠ complete。

### 14.2 Fast path（轻量豁免）

仅当用户**明确**给出：精确文件/符号 + 改动意图，且自认链路已清，可跳过完整 Map。

必须在 `task.md` 记录：

- `fast_path: true`  
- 豁免理由  
- 用户给出的文件列表  

Fast path 仍须写简版 `map.md`（至少触点 + 改动边界），且 Change 证据等级规则不变。

### 14.3 Abort / Investigate-only

| 状态 | 含义 | 允许的动作 |
|------|------|------------|
| `investigate_only` | 只摸清，不改代码 | Orient + Map + notes；禁止业务代码改动 |
| `blocked` | 缺复现/权限/环境 | 停止 Change；在 task/notes 写阻塞项与所需输入 |
| `aborted` | 用户取消或判定不该用本 skill | 保留已有产物；不再改代码 |

### 14.4 何时不该用

- 纯文案/注释/明显单行 typo，且用户已指定文件  
- 用户只要解释概念、不要动仓  
- 已有完整补丁只需代为粘贴应用  
- 需要真实 debugger/线上观测才能定位，且当前环境无法取证（应 `blocked`，勿瞎改）

### 14.5 与仓规关系

Orient 阶段优先阅读（若存在）：`AGENTS.md`、`CLAUDE.md`、`.cursor/rules`、README 中的 build/test 说明。  
**仓规优先于本 skill 的默认习惯**（测试命令、禁止目录、提交规范）。

### 14.6 证据等级

| 等级 | 含义 | 可否宣称 done |
|------|------|----------------|
| L0 | 仅静态推理，无复现/无测试/无日志对照 | **否** |
| L1 | 有可复现步骤（或用户确认的复现）+ 预期/实际对比 | 可（须写明尚无自动化） |
| L2 | 自动化测试通过，或约定日志/行为探针验证通过 | 可（优选） |

### 14.7 安全与 git

- `.delegate/` 默认建议加入项目 `.gitignore`  
- 产物中禁止粘贴密钥、token、密码、完整隐私数据；日志需脱敏  
- 不替代安全审计工具

### 14.8 产品成功假设（Demo 可验证）

相对「裸 AI 直接改」，本 skill 应降低：漏层改动、无证据宣称修复、老人复审时间。  
S4 用前后对比各跑 1 个 bug + 1 个 feature 验证。

### 14.9 跨会话续跑（P1）

Orient 若发现目标仓已有 `.delegate/<slug>/`，先读再续，不默认另开 slug。

`task.md` 字段：

- `resume: true|false`  
- `last_stage`: 上一会话已完成的阶段（`orient` | `map` | `change` | `leave`）  
- `resume_from`: 本会话应从哪一阶段接着  

`notes.md` 中途停手时填写 **续跑交接**。

硬约束与首跑相同：Map 未 `complete` 且无合法 `fast_path` → 禁止改业务代码；不得凭上一聊的记忆跳闸门。细则见 [references/resume-workflow.md](references/resume-workflow.md)；虚构走通见 `examples/resume-interrupted-map/`。

### 14.10 Refactor 轻量闸门（P2）

`type: refactor` 时：

1. 改结构前须有**行为锁**（表征测试或可复跑手工基线）  
2. `change.md` 必填 **表征证据**、**回滚点**（检查脚本校验非空壳）  
3. 默认证据 **≥ L1**；有自动化表征则 L2  
4. 禁止跨模块大改、修 bug 时顺手重构；范围膨胀须回 Map 并问用户  

细则：[references/refactor-workflow.md](references/refactor-workflow.md)；示例：`examples/light-refactor-extract-fn/`。

### 14.11 Git 线索（P3，可选）

Map 可在触点列表之外增加 **Git 线索（可选）** 段：对已定位文件记录近况/churn、热点作者。

- **非 DoD**：无 git 或未填不影响 `status: complete`  
- **只作线索**：不得把 commit message 当已证实根因；不得写成全仓编年史  
- **边界**：本 skill 不作纯 git 故事 / 技术债报告工具  

命令与「何时看」见 [references/map-guidance.md](references/map-guidance.md)。

### 14.12 开源 Demo 与打磨（P4–P5）+ 第三期

- Demo：`docs/demo-walkthrough.html` 为权威对照；`demo-bare-vs-skill.gif` / `.png` 为示意；`docs/SHARE.md`  
- Darwin 卡片已 gitignore，勿链入 README/PLAN；**不跑** Darwin（除非用户另说）  
- `check_delegate_artifacts.sh`：续跑弱校验 + `--draft`；`scripts/smoke_examples.sh` 批量测 examples  
- `test-prompts.json` 含续跑 / refactor / fast path / 不该用 / investigate_only  
- 第二仓 case：`.github/ISSUE_TEMPLATE/second-repo-case.md`  
- 贡献说明：`CONTRIBUTING.md`
