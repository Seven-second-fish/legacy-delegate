# legacy-delegate — 计划文档

> 状态：第一、二、三期已完成；**第四期 M1/M2 已完成**；维护待命  
> 位置：`~/.cursor/skills/legacy-delegate/`  
> GitHub：https://github.com/Seven-second-fish/legacy-delegate · Demo：cakeshop  
> **当前下一刀：无（M1 + M2 已落地；维护待命）**  
> 更新日期：2026-08-01  
> 审查：create-skill / skill-creator · §6.4（功能）· **§3（基础规范）** · 2026-08-01 PLAN 去陈旧/减重 · **M1/M2 执行面已合并**

本文件 = **内部规格 + 路线图 + 待办**。对外入口见 `README.md`（中文）。

**加载边界**：跑代工任务时 Agent **禁止** `Read` 本 `PLAN.md`（省上下文，见 §3.1）。仅规划、贡献、改 skill 规格时读。执行面以 `SKILL.md` + `templates/` + 按需 `references/` 为准。

完成 §6.2 / §6.4 / §6.5 / §6.6 任一项后，必须同步勾选并改文首「当前下一刀」。  
后续改动（含维护刀）须符合 **§3.1**；Token 详表见 §14.14。

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
同时遵守 **§3 基础设计规范**：可审计闸门与 Token 经济同级，不可为省上下文拆闸门。

---

## 3. 基础设计规范 + 产品形态

### 3.1 基础设计规范（两支柱，同级）

本 skill 的一切流程、模板、维护刀、对外叙事，必须同时满足：

| 支柱 | 一句话 | 不可妥协 |
|------|--------|----------|
| **A. 可审计代工** | Map first → Change → Leave evidence | 无合法豁免时，Map 未 complete 禁改业务代码；L0 禁宣称 done |
| **B. Token 经济** | 砍空转与重复考古，不砍闸门 | 禁止用「省 token」作为 fast_path / Map complete / 免证据的理由 |

**Token 经济（规范正文只此节；详表 §14.14）：**

1. **成本对象**：优化全链路成本（返工、复审重挖、误伤），非单次最少 token。  
2. **付费边界**：黑名单/显式调用拦小活；点名文件+意图 → Fast path；陌生/跨层/留痕 → 全 Map。  
3. **落盘即状态机**：`.delegate/<slug>/` 供人审、续跑、脚本验；摊薄后续会话，不否认首跑更贵。  
4. **可瘦 / 禁砍**：瘦仪式与密度；**禁砍** Map 闸门、≥L1、触点+边界、完成前 check（表见 §14.14）。  
5. **SKILL 保持瘦**：渐进披露；细则进 references / §14.14；主文件 ≤8 行摘录或指针（M2）。  
6. **测量**：看误用退出与短 map+L1，**不**要求 token 低于裸改。

```text
误用拦截 → 任务分流 → 会话间复用（续跑/暖启动） → 仪式变瘦
```

### 3.2 产品形态：流程闸门 + 能力全包

| 层次 | 含义 |
|------|------|
| 流程通用 | 任何项目都「先理解再改」——无 Map 不准 Change |
| 能力通用 | 考古 → 修 bug / 加功能 / 重构 → 留档，同一条绳 |

关系：流程通用是底座；能力通用是挂在底座上的作业线。两者的写法与扩容都受 **§3.1** 约束。

---

## 4. 阶段状态机（核心设计）

禁止跳步（Fast path / Investigate-only 除外，见 §14）。遵守 §3.1：豁免只缩小 Map 厚度，**不**取消证据与落盘义务。  
产物落盘到：`<repo>/.delegate/<task-slug>/`（防多任务碰撞；亦为 Token 经济的跨会话资产）。

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
| 默认堆上下文或空转仪式 | **§3.1 Token 经济**：砍空转；禁以省 token 拆闸门 |

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
| 简洁 / ≤500 行 | `SKILL.md` \<500（现约 120+）；细节在 references | ✅ progressive disclosure |
| description WHAT+WHEN | 中文第三人称 + 触发场景 | ✅；英文触发词已由 Q3 补上（真源见 `SKILL.md`） |
| 反馈环 | 完成前跑 check + 反 stub | ✅；质量仍靠人审 Map 实质 |
| 模板 / 脚本 | templates + check 脚本 | ✅ |
| 引用深度 | SKILL → references 一层 | ✅ |
| 短板（当时） | bug/feature 薄；Demo 弱；缺 eval | → Q1–Q5 **已消化**（见下） |

**2026-08-01 PLAN 卫生（skill-creator）**：去 §8 平行草案、补 §11 第四期、实化 §13、瘦 §6.6、文首禁执行加载 PLAN；Token 规范唯一正文 §3.1、详表 §14.14。

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

### 6.5 第四期（维护）— Orient 轻量暖启动

**动机**：新开会话、用户未点名路径、也未提旧产物时，Agent 可能对「上一题附近」的类似改动再次从零摸链路，浪费 token。磁盘上已有 `.delegate/` 可作线索，但协议上 `done` 任务不得自动继承为新任务的 Map。

**原则**：加**轻量暖启动**（线索复用 + 相关时问一句）；**不加**「相似即免 Map / 自动 complete」。落地 §3.1「会话间复用」层，不得削弱支柱 A。

执行顺序：M1（本刀）→ 可选 M1b 文档/eval 对齐 → 可选 M2（§6.6 Token 叙事对齐，不阻塞 M1）。

#### M1 — Orient 轻量暖启动（线索复用）

- [x] `SKILL.md` Orient：若存在 `.delegate/`，除续跑 `in_progress`/`blocked` 外，列出最近若干 slug（含 `done`），读其 map 的**触点列表 / 改动边界**（勿整份灌进上下文）
- [x] 写入新任务 map「假设」或「Git/历史线索」类段落：标明来源 slug，**仅作线索**
- [x] 判定可能相关 → 🔴 CHECKPOINT 问用户：是否参考旧产物 / 是否走 fast path；用户未确认前仍按本题做 Map（可缩短定向读，禁止把旧 map 标成新任务 `complete`）
- [x] 硬约束不变：新 bug → 新 slug；证据 ≥ L1；旧 map 过期风险写进「未知」
- [x] （可选）`references/resume-workflow.md` 或短文 `references/warm-start.md`：暖启动 vs 续跑对照表
- [x] （可选）`test-prompts.json` / `evals` 加 1 条：新会话 + 附近改动 + 仓内已有 done 产物 → 期望先扫 `.delegate/` 再问/短 map

**明确不做（本刀）**：向量检索 / 相似度自动免 Map；把多份旧 map 全文塞进一轮上下文；跨仓共享知识库。

规格细则见 §14.13。

### 6.6 Token 经济 — 对照清单与 M2（正文 §3.1；详表 §14.14）

对照 §3.1 是否已体现在能力上（勿在此重复写规范）：

- [x] 显式调用、黑名单、Fast path、默认 `delegate`、续跑读盘、Git 可选、禁加载 PLAN  
- [x] M1 暖启动写入 Orient（§6.5）  
- [x] M2：`SKILL.md` ≤8 行摘录 §3.1；README FAQ 一句；可选 `references/token-economy.md` + eval  

M2 不阻塞 M1。明确不做见 §14.14 实现约束。

---

## 7. 目标目录结构

> `PLAN.md`：规格/路线图，**非**运行时必读（见文首加载边界）。

```text
~/.cursor/skills/legacy-delegate/
├── PLAN.md                 # 规格与路线图（执行任务勿加载）
├── README.md               # 安装与用法（中文，开源访客入口）
├── LICENSE                 # MIT
├── SKILL.md                # 主技能（执行入口；frontmatter 为 description 真源）
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
│   ├── resume-workflow.md  # 跨会话续跑
│   ├── warm-start.md       # 可选：暖启动 vs 续跑（M1）
│   └── token-economy.md    # 可选：可瘦/禁砍表（M2，自 §14.14 迁出）
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

## 8. SKILL.md 元数据（真源）

**以仓库内现行 `SKILL.md` frontmatter 为准**，本节不维护平行 description 草案，避免漂移。

约定（实现时已满足，改 description 时仍遵守）：

- `name: legacy-delegate`
- description = **WHAT + WHEN**，第三人称；可含少量英文触发词（legacy / map-first / evidence 等）
- **`disable-model-invocation: true`** — 仅显式调用，避免小改被套流程
- §9 触发词供人决定何时调用，**不是**自动挂载依据

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

1. 无 `.delegate/<task-slug>/map.md`（或 Map 未标完成）时，Agent **不得**提交业务代码修改。
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
- 符合 **§3.1**：新增能力不得以省 token 削弱 Map/证据；SKILL 增补 Token 提示时遵守瘦身上限（§14.14）

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
**第三期：§6.4 Q1–Q5 ✅（2026-07-31）。**  
**第四期：M1 + M2 ✅（2026-08-01）；维护待命。**  
**基础规范：§3.1（Token 经济为支柱 B）；已写入 `SKILL.md` 执行面。**

第二期共用验收：无 Map complete 不改业务代码；禁 L0 宣称 done；完成前跑 check 脚本；对外叙事仍是代工 + 可审计；对外 README 为中文；续跑不得跳过未完成闸门。第四期另加：暖启动不免 Map；改动自检 §3.1 两支柱。

---

## 12. 风险与对策

| 风险 | 对策 |
|------|------|
| 做成空壳万能助手 | 协议闸门 + Map DoD + MVP 只做透 bug/feature |
| 产物太重，老人嫌烦 | 默认 `delegate`；Fast path 豁免 |
| 与 CLAUDE.md 混淆 | README：常驻说明 vs 作业 SOP；Orient 先读仓规 |
| 上下文被长 skill 占满 | §3.1 progressive disclosure；执行勿加载整份 PLAN |
| 首跑 token 贵 → 用户要求砍闸门 | §3.1：砍空转不砍 Map/证据；分流 + 落盘摊薄 |
| 「省 token」写成免 Map | §3.1 硬禁；仅合法 Fast path / 黑名单退出 |
| 开源难涨星 | Demo before/after |
| 闸门无法内核强制 | 检查脚本 + 禁止在证据 L0 宣称 done |
| `.delegate/` 泄密 | gitignore；禁止写入密钥/令牌 |

---

## 13. 待确认问题

**无未决项。** 历史默认已拍板并写入正文（场景 B 默认、显式调用、中文 README、轻量 refactor only、`.delegate/` gitignore 等）。若要改名、改自动挂载或扩大 refactor 范围，开新刀并改 §3 / §6.3，勿静默漂移。

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

### 14.13 Orient 轻量暖启动（第四期 M1）

解决：新会话 + 未指路径 + 未提旧产物时，对「上一题附近」任务重复摸链路。

| | 续跑（已有） | 暖启动（本刀） |
|--|-------------|---------------|
| 对象 | 同一 slug，`in_progress`/`blocked` | **新** slug；参考近期其他（含 `done`）产物 |
| 旧 map 角色 | 接着写同一份 | **线索**（触点/边界），非新任务 DoD |
| 能否免 Map | 否（闸门不变） | 否；除非用户确认后走 **fast path** |

**流程要点**：

1. Orient 列 `.delegate/`：优先续跑未完成；否则对新任务做暖启动扫描（最近 N 个，建议 ≤5，按 mtime）。  
2. 只摘触点 + 边界（及 task 成功标准一行），写入本题「假设/线索」，注明 `source: .delegate/<old-slug>/`。  
3. 路径/模块疑似重叠 → 问用户；确认可参考或 fast path 后再缩短考古。  
4. **禁止**：自动 `fast_path: true`；禁止复制旧 `map.md` 改 status 冒充 complete。  

与 Fast path（§14.2）、续跑（§14.9）正交：用户已点名文件仍走 fast path；未完成任务仍走 resume。

### 14.14 Token 经济细则（仅详表；规范正文 §3.1）

本节不重复 §3.1 六条。含：成本账、分流、可瘦/禁砍、实现约束。

#### 成本账（叙事用）

| 贵在哪 | 换来什么 | 更贵的失败 |
|--------|----------|------------|
| 写四件套 + 读链路 | 可审 Map、可复现证据、可续跑状态 | 改错层 / 漏触点后的第二轮 |
| 人等 Map 完成再改 | 范围不膨胀 | 顺手重构整文件 |
| 落盘占用写工具调用 | 跨会话不靠聊天记忆 | 新会话从零考古 |

落盘逻辑：闸门状态外置到 `.delegate/<slug>/` → 人审 + 续跑读盘 + check 脚本验盘；**续跑/暖启动摊薄的是后续会话**，不是否认首跑更贵。

#### 分流（何时付全价）

| 路径 | 条件 | Token 含义 |
|------|------|------------|
| **黑名单 / 退出** | typo、纯解释、粘贴补丁等（§14.4） | 最省：不建或 abort，禁止空转协议 |
| **Fast path** | 用户点名文件/符号 + 意图（§14.2） | 短 map；Change/证据仍付费 |
| **全 Map** | 陌生 / 跨层 / 要留痕 | 付全价；这是产品主场 |
| **investigate_only** | 只摸清不改 | 付 Map，不付改码与假完成 |
| **续跑** | 同 slug 未完成（§14.9） | 读盘接着，禁止凭聊天跳步 |
| **暖启动** | 新 slug + 仓内近邻产物（§14.13） | 只摘触点/边界作线索；不免 Map |

#### 可瘦 vs 禁砍

| 可瘦（仪式 / 密度） | 禁砍（产品定义） |
|--------------------|------------------|
| `onboard` 长篇「为什么」（非用户要求时用 `delegate`） | Map 未 `complete`（无合法 fast path）禁止改业务代码 |
| 可选 Git 线索整段跳过 | 证据 ≥ L1 才可宣称 done；验证含可复现步骤/前/后 |
| 对用户回复里重复粘贴已落盘全文 | 触点列表 + 改动边界（短 map 也要） |
| 一次塞多份旧 `map.md` 全文 | 产物落盘四件套（可中途 `--draft`，不可无盘宣称 done） |
| 小任务硬开全 Map（应走黑名单或 Fast path） | 范围膨胀时回 Map + CHECKPOINT，不闷头扩改 |
| 执行时加载本 `PLAN.md` 全文 | check 脚本 `RESULT: OK` 前的完成闸门 |

#### 实现约束（落实 §3.1，防拆产品）

1. **SKILL 保持瘦**：§3.1 进 SKILL 时 ≤8 行 + 指针；表放 `references/token-economy.md` 或本 §14.14。  
2. **禁止**用「省 token」作为 `fast_path: true` 或 Map `complete` 的理由；Fast path 唯一合法来源仍是用户点名文件+意图（或用户在暖启动对话中**明确确认**走 fast path）。  
3. **测量**：若做 eval，对比的是「误用是否退出 / Fast path 是否仍有短 map+L1」，不是「总 token 必须低于裸改」。  
4. 与 §6.4 审查一致：质量仍靠人审 Map 实质；脚本只反 stub，不替代判断。  
5. 任何新维护刀（含 M1/M2）合并前自检：是否仍满足 §3.1 两支柱同级。
