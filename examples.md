# 示例走通（虚构）

> 真实仓验收见 README「真实 Demo：cakeshop」与 [Seven-second-fish/cakeshop](https://github.com/Seven-second-fish/cakeshop)。下文为虚构走通，便于不依赖环境时理解闸门。  
> 第五期动机与**验收追诉**（done 后同控件重开同 slug）见 [PLAN.md §6.7](PLAN.md#67-第五期维护验收闭环与防伪-done)。

仓库：小型 Node 服务。症状：购物车带优惠券时 `POST /checkout` 返回 500。

## Orient

`.delegate/checkout-coupon-500/task.md`

- type: bug，mode: delegate  
- 成功：200 + 折扣后总额；不再 500  
- 测试：`npm test -- checkout`

## Map（complete）

路径：

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` → `CouponRepo.find` → 读取空 `expiresAt` 时抛错

触点：`pricing/coupon.js`、`checkout/controller.js`  
边界：只修 PricingService 对空过期时间的处理；不重做购物车。  
Git 线索（可选）：对 `pricing/coupon.js` 看最近 log — 仅线索，不替代堆栈证实。

## Change（L2）

- 假设：缺失过期时间被当成崩溃 → 已证实  
- 补丁：将空过期视为永不过期；补单元测试  
- `evidence_grade: L2` — 测试通过

## Leave

回归：单元测试 + 手工 checkout（优惠券无 `expiresAt`）。  
未知：历史优惠券是否依赖 500 做风控（问产品）。

## Fast path 对照

用户：「只改 `pricing/coupon.js` 的 null 判断，链路我清楚。」  
→ `fast_path: true`，短 map，证据规则不变。

---

## 续跑：Map 中断 → 新会话

产物快照：[examples/resume-interrupted-map/](examples/resume-interrupted-map/)。

### 会话 1（停在 Map 半程）

- Orient 完成；`map.md` 留在 `status: draft`（路径停在 `applyCoupon`；影响面未知）
- `notes.md` **续跑交接**：`resume_from: map`；**Map complete 前禁止改业务代码**
- `task.md`：`last_stage: orient`，`resume_from: map`，`status: in_progress`

### 会话 2（用户：「继续 checkout-coupon-500」）

1. Orient **续跑**：读同一 `.delegate/checkout-coupon-500/`（不开新 slug）
2. 设 `resume: true`；按交接留在 **Map**（禁止凭聊天记忆跳进 Change）
3. 补完 Map DoD → `status: complete` → Change（L2）→ Leave → 检查脚本 OK → `status: done`

**闸门核对：** 会话 2 在 Map 仍为 draft 时不得打补丁。

---

## 轻量 refactor：抽纯函数（行为保持）

产物快照：[examples/light-refactor-extract-fn/](examples/light-refactor-extract-fn/)。

1. **Orient**：`type: refactor`；成功标准 = 行为不变 + 表征绿  
2. **Map**：边界仅 `pricing/coupon.js` 抽 `isCouponExpired`；禁止改折扣公式 / controller  
3. **Change**：先记 **表征证据**（`npm test -- pricing` 改前绿）与 **回滚点**，再抽函数；改后同套件绿 → `evidence_grade: L2`  
4. **Leave**：回归命令 + 「勿顺手扩到全仓日期工具」

对照：[references/refactor-workflow.md](references/refactor-workflow.md)。检查脚本在 `type: refactor` 时会校验表征/回滚章节。

---

## 验收追诉：成功标准过窄 → 同 slug 重开

产物快照：[examples/acceptance-reopen-outcome-gap/](examples/acceptance-reopen-outcome-gap/)。

1. **首轮 Orient**：成功标准仅「下拉可展开」→ Change 验证通过 → `status: done`
2. **用户追诉**：「能开，但点导出没反应」→ **同 slug** 重开，不新开 change 文件
3. **补成功标准**：追加「点导出 → 下载 JSON」；`change.md` 保留首轮验证，追加 **追诉 #1**（步骤/之前/之后）
4. **Leave**：`notes.md` **成功标准对照** 表逐条勾证据；未完成项不得宣称 done

对照：[PLAN.md §6.7](PLAN.md#67-第五期维护验收闭环与防伪-done)。
