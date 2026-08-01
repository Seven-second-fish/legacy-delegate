#!/usr/bin/env bash
# legacy-delegate eval fixture 生成器（eval 1-11 各自独立仓）
# 用法：bash prepare_fixtures.sh /tmp/legacy-evals
# 生成后各 eval 仓的 .delegate/ 内是预置状态；跑完 eval 后可重跑本脚本恢复干净基线。
set -euo pipefail
ROOT="${1:-/tmp/legacy-evals}"
rm -rf "$ROOT"
mkdir -p "$ROOT"

write() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

# ============ 基础仓 checkout-service（eval 1/2/3/4/5/7/8/9 复用） ============
base() {
  local d="$1"
  write "$d/package.json" <<'EOF'
{
  "name": "checkout-service",
  "private": true,
  "scripts": {
    "test": "node --test",
    "start": "node src/server.js"
  }
}
EOF
  write "$d/.gitignore" <<'EOF'
node_modules/
.delegate/
EOF
  write "$d/README.md" <<'EOF'
# checkout-service

Node 遗留服务，零依赖（node:http / node:test）。

- 启动：`npm start`（端口 3000）
- 测试：`npm test`
- `POST /checkout` body: `{ "items": [{ "price": 100, "qty": 2 }], "couponId": "SAVE10" }` → `{ subtotal, amount, total }`
- 支付回调：`POST /payment/callback`（内部 service 处理入账）
EOF
  write "$d/src/server.js" <<'EOF'
'use strict';
const http = require('node:http');
const { handleCheckout } = require('./checkout/controller');
const { handleCallback } = require('./payment/callback');

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (c) => (raw += c));
    req.on('end', () => { try { resolve(JSON.parse(raw || '{}')); } catch (e) { reject(e); } });
  });
}

const server = http.createServer(async (req, res) => {
  try {
    const body = await readBody(req);
    let out;
    if (req.method === 'POST' && req.url === '/checkout') out = handleCheckout(body);
    else if (req.method === 'POST' && req.url === '/payment/callback') out = handleCallback(body);
    else { res.writeHead(404); return res.end('not found'); }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(out));
  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: err.message }));
  }
});

if (require.main === module) server.listen(3000);
module.exports = server;
EOF
  write "$d/src/checkout/controller.js" <<'EOF'
'use strict';
const couponRepo = require('../pricing/couponRepo');
const pricing = require('../pricing/coupon');
const { computeOrderTotal } = require('../order/total');

function handleCheckout(body) {
  const { items, couponId } = body;
  const subtotal = items.reduce((s, it) => s + it.price * it.qty, 0);
  const coupon = couponId ? couponRepo.find(couponId) : null;
  const amount = pricing.applyCoupon(subtotal, coupon);
  return { subtotal, amount, total: computeOrderTotal(items, coupon) };
}
module.exports = { handleCheckout };
EOF
  write "$d/src/pricing/couponRepo.js" <<'EOF'
'use strict';
// 优惠券表（模拟 DB）
const coupons = new Map([
  ['SAVE10', { id: 'SAVE10', discountRate: 0.1, expiresAt: null }],
  ['WELCOME', { id: 'WELCOME', discountRate: 0.2, expiresAt: Date.now() + 86400000 }],
]);
function find(id) { return coupons.get(id) || null; }
module.exports = { find };
EOF
  write "$d/src/pricing/coupon.js" <<'EOF'
'use strict';
// 应用优惠券。注意：expiresAt 为 null 时当前实现会崩溃。
function applyCoupon(total, coupon) {
  if (!coupon) return total;
  const now = Date.now();
  if (coupon.expiresAt.getTime() < now) {
    throw new Error('coupon expired');
  }
  return Math.round(total * (1 - coupon.discountRate) * 100) / 100;
}
module.exports = { applyCoupon };
EOF
  write "$d/src/order/total.js" <<'EOF'
'use strict';
// 订单总额：小计 - 折扣。折扣计算内联在本函数里。
function computeOrderTotal(items, coupon) {
  const subtotal = items.reduce((s, it) => s + it.price * it.qty, 0);
  let discount = 0;
  if (coupon && coupon.discountRate) {
    discount = subtotal * coupon.discountRate;
  }
  return Math.round((subtotal - discount) * 100) / 100;
}
module.exports = { computeOrderTotal };
EOF
  write "$d/src/order/repo.js" <<'EOF'
'use strict';
const orders = new Map();
function findById(id) { return orders.get(id) || null; }
function save(order) { orders.set(order.id, order); return order; }
module.exports = { findById, save };
EOF
  write "$d/src/payment/service.js" <<'EOF'
'use strict';
const orderRepo = require('../order/repo');
// 支付入账。注意：目前没有幂等校验，同一事件重复回调会重复累加金额。
function applyPayment(event) {
  const order = orderRepo.findById(event.orderId);
  if (!order) throw new Error('order not found');
  order.paid = (order.paid || 0) + event.amount;
  orderRepo.save(order);
  return order;
}
module.exports = { applyPayment };
EOF
  write "$d/src/payment/callback.js" <<'EOF'
'use strict';
const paymentService = require('./service');
function handleCallback(event) {
  return paymentService.applyPayment(event);
}
module.exports = { handleCallback };
EOF
  write "$d/src/inventory/controller.js" <<'EOF'
'use strict';
const inventoryService = require('./service');
function deductStock(orderId, sku, qty) {
  return inventoryService.deduct(orderId, sku, qty);
}
module.exports = { deductStock };
EOF
  write "$d/src/inventory/service.js" <<'EOF'
'use strict';
const inventoryRepo = require('./repo');
function deduct(orderId, sku, qty) {
  const item = inventoryRepo.find(sku);
  if (!item) throw new Error(`sku not found: ${sku}`);
  if (item.stock < qty) throw new Error('insufficient stock');
  inventoryRepo.decrease(sku, qty);
  return inventoryRepo.find(sku);
}
module.exports = { deduct };
EOF
  write "$d/src/inventory/repo.js" <<'EOF'
'use strict';
// 模拟 DB 表
const table = new Map([
  ['SKU-001', { sku: 'SKU-001', stock: 10 }],
  ['SKU-002', { sku: 'SKU-002', stock: 0 }],
]);
function find(sku) { return table.get(sku) || null; }
function decrease(sku, qty) { const it = table.get(sku); it.stock -= qty; }
module.exports = { find, decrease };
EOF
  write "$d/test/checkout.test.js" <<'EOF'
'use strict';
const assert = require('node:assert');
const { test } = require('node:test');
const { handleCheckout } = require('../src/checkout/controller');

test('checkout with SAVE10 (expiresAt null) should not 500', () => {
  const r = handleCheckout({ items: [{ price: 100, qty: 2 }], couponId: 'SAVE10' });
  assert.strictEqual(r.total, 180);
});
test('checkout without coupon', () => {
  const r = handleCheckout({ items: [{ price: 100, qty: 1 }] });
  assert.strictEqual(r.total, 100);
});
EOF
  write "$d/test/total.test.js" <<'EOF'
'use strict';
const assert = require('node:assert');
const { test } = require('node:test');
const { computeOrderTotal } = require('../src/order/total');

test('no coupon', () => assert.strictEqual(computeOrderTotal([{ price: 100, qty: 2 }], null), 200));
test('10% coupon', () => assert.strictEqual(computeOrderTotal([{ price: 100, qty: 2 }], { discountRate: 0.1 }), 180));
EOF
  write "$d/test/payment.test.js" <<'EOF'
'use strict';
const assert = require('node:assert');
const { test } = require('node:test');
const { handleCallback } = require('../src/payment/callback');
const orderRepo = require('../src/order/repo');

test('duplicate payment callback should apply once', () => {
  orderRepo.save({ id: 'o1', amount: 100 });
  handleCallback({ orderId: 'o1', eventId: 'evt-1', amount: 100 });
  handleCallback({ orderId: 'o1', eventId: 'evt-1', amount: 100 });
  const order = orderRepo.findById('o1');
  assert.strictEqual(order.paid, 100);
});
EOF
}

# ============ eval 4 预置：续跑（停在 Map draft） ============
preset_resume() {
  local d="$1"
  mkdir -p "$d/.delegate/checkout-coupon-500"
  write "$d/.delegate/checkout-coupon-500/task.md" <<'EOF'
# 任务

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: in_progress
fast_path: false
evidence_target: L2
```

## 用户诉求

POST /checkout 带优惠券 SAVE10 时返回 500。先摸清链路再修，证据至少 L1。

## 成功标准

- [ ] POST /checkout 带 SAVE10 返回 200 且金额正确
- [ ] 无优惠券链路不回归

## Fast path（如有）

- 无

## 续跑（如有）

- 无

## 已读仓规

- [x] README
- 构建：`npm start`
- 测试：`npm test`

## 阻塞 / 需用户补充

-

## 备注

- 上轮结束于 Map（draft）
EOF
  write "$d/.delegate/checkout-coupon-500/map.md" <<'EOF'
# 地图

```yaml
status: draft
fast_path: false
```

## 入口

POST /checkout → src/server.js → src/checkout/controller.js#handleCheckout

## 关键路径

1. server.js 解析 body → handleCheckout
2. couponRepo.find('SAVE10') → pricing.applyCoupon(subtotal, coupon)

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| src/pricing/coupon.js | applyCoupon | 疑似崩溃点（读取 expiresAt） |
| src/pricing/couponRepo.js | find | SAVE10 数据来源 |

## 影响面

checkout 流程、订单金额计算

## Git 线索（可选）

N/A

## 历史线索 / 暖启动（可选）

N/A

## 已证实

带 SAVE10 时 handleCheckout 抛 TypeError（测试红）

## 假设

coupon.expiresAt 为 null 导致 getTime() 崩溃

## 未知

其他优惠券是否同样无 expiresAt

## 改动边界

允许：coupon.js 对空 expiresAt 的处理
禁止：改 checkout 流程、改 repo 数据

## 待确认问题

-
EOF
}

# ============ eval 8 预置：暖启动（done 产物在盘上） ============
preset_warmstart() {
  local d="$1"
  mkdir -p "$d/.delegate/checkout-coupon-500"
  write "$d/.delegate/checkout-coupon-500/task.md" <<'EOF'
# 任务

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: done
fast_path: false
evidence_target: L2
```

## 用户诉求

POST /checkout 带优惠券 SAVE10 时返回 500。先摸清链路再修，证据至少 L1。

## 成功标准

- [x] POST /checkout 带 SAVE10 返回 200 且金额正确
- [x] 无优惠券链路不回归

## Fast path（如有）

- 无

## 续跑（如有）

- 无

## 已读仓规

- [x] README
- 构建：`npm start`
- 测试：`npm test`

## 阻塞 / 需用户补充

-

## 备注

- 已完成
EOF
  write "$d/.delegate/checkout-coupon-500/map.md" <<'EOF'
# 地图

```yaml
status: complete
fast_path: false
```

## 入口

POST /checkout → src/server.js → src/checkout/controller.js#handleCheckout

## 关键路径

1. server.js 解析 body → handleCheckout
2. couponRepo.find('SAVE10') → pricing.applyCoupon(subtotal, coupon)

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| src/pricing/coupon.js | applyCoupon | 崩溃点 |
| src/pricing/couponRepo.js | find | SAVE10 数据来源 |

## 影响面

checkout 流程、订单金额计算

## Git 线索（可选）

N/A

## 历史线索 / 暖启动（可选）

N/A

## 已证实

带 SAVE10 时 handleCheckout 抛 TypeError（测试红）；修复后绿

## 假设

coupon.expiresAt 为 null 导致 getTime() 崩溃

## 未知

其他优惠券是否同样无 expiresAt

## 改动边界

允许：coupon.js 对空 expiresAt 的处理
禁止：改 checkout 流程、改 repo 数据

## 待确认问题

-
EOF
  write "$d/.delegate/checkout-coupon-500/change.md" <<'EOF'
# 改动

```yaml
type: bug
evidence_grade: L2
status: verified
```

## 计划（对齐 Map 边界）

- coupon.js applyCoupon 对空 expiresAt 视作永不过期

## 已测假设（bug）/ 触点计划（feature|refactor）

| 项 | 结果 |
|----|------|
| expiresAt 为 null 时崩溃 | 已证实 |

## 表征证据（refactor 必填；其他类型写 N/A）

N/A

## 回滚点（refactor 必填；其他类型写 N/A）

N/A

## 改动摘要

| 文件 | 改动 |
|------|------|
| src/pricing/coupon.js | 空 expiresAt 不再调 getTime() |

## 验证

### 步骤

1. npm test

### 之前

1 个测试红（TypeError）

### 之后

全部测试绿

### 命令 / 测试 / 日志（脱敏）

```
npm test
```

## 证据等级说明

- 自动化测试通过 → L2

## 残留风险

- 无
EOF
  write "$d/.delegate/checkout-coupon-500/notes.md" <<'EOF'
# 笔记

```yaml
task_slug: checkout-coupon-500
type: bug
```

## 改了什么

- coupon.js 对空 expiresAt 视作永不过期

## 如何回归

1. npm test
2. 手工 POST /checkout 带 SAVE10

## 成功标准对照

| 成功标准 | 满足 | 证据 |
|----------|------|------|
| 带 SAVE10 返回 200 | ☑ | change 验证（npm test 绿） |
| 无优惠券链路不回归 | ☑ | 无优惠券测试绿 |

## 给下一位人 / Agent

-

## 续跑交接

N/A

## 仍未知

- 其他优惠券是否同样无 expiresAt

## 后续

-

## 文档更新（仅当用户要求）

-
EOF
}

# ============ eval 10 预置：验收追诉（done 但同控件仍坏） ============
preset_dropdown_done() {
  local d="$1"
  mkdir -p "$d/.delegate/header-city-dropdown"
  write "$d/.delegate/header-city-dropdown/task.md" <<'EOF'
# 任务

```yaml
task_slug: header-city-dropdown
type: bug
mode: delegate
status: done
fast_path: false
evidence_target: L2
```

## 用户诉求

顶栏城市下拉打不开。先摸清再修。

## 成功标准

- [x] 顶栏城市下拉能打开

## Fast path（如有）

- 无

## 续跑（如有）

- 无

## 已读仓规

- [x] README
- 测试：`npm test`

## 阻塞 / 需用户补充

-

## 备注

- 已完成
EOF
  write "$d/.delegate/header-city-dropdown/map.md" <<'EOF'
# 地图

```yaml
status: complete
fast_path: false
```

## 入口

页面加载 → src/dropdown.js#toggle

## 关键路径

1. 点击下拉按钮 → toggle()
2. toggle 切换 open 状态 → 渲染列表

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| src/dropdown.js | toggle | 开关逻辑 |

## 影响面

顶栏导航

## Git 线索（可选）

N/A

## 历史线索 / 暖启动（可选）

N/A

## 已证实

open 状态未正确切换

## 假设

toggle 内状态更新逻辑有误

## 未知

无

## 改动边界

允许：src/dropdown.js 内 toggle 相关逻辑
禁止：其他导航逻辑

## 待确认问题

-
EOF
  write "$d/.delegate/header-city-dropdown/change.md" <<'EOF'
# 改动

```yaml
type: bug
evidence_grade: L2
status: verified
```

## 计划（对齐 Map 边界）

- 修正 toggle 的状态更新

## 已测假设（bug）/ 触点计划（feature|refactor）

| 项 | 结果 |
|----|------|
| open 状态未切换 | 已证实 |

## 表征证据（refactor 必填；其他类型写 N/A）

N/A

## 回滚点（refactor 必填；其他类型写 N/A）

N/A

## 改动摘要

| 文件 | 改动 |
|------|------|
| src/dropdown.js | toggle 修正状态更新 |

## 验证

### 步骤

1. npm test

### 之前

打开测试红

### 之后

打开测试绿

### 命令 / 测试 / 日志（脱敏）

```
npm test
```

## 证据等级说明

- 自动化测试 → L2

## 残留风险

- 无
EOF
  write "$d/.delegate/header-city-dropdown/notes.md" <<'EOF'
# 笔记

```yaml
task_slug: header-city-dropdown
type: bug
```

## 改了什么

- dropdown toggle 可打开

## 如何回归

1. npm test
2. 浏览器点开下拉

## 成功标准对照

| 成功标准 | 满足 | 证据 |
|----------|------|------|
| 下拉能打开 | ☑ | 打开测试绿 |

## 给下一位人 / Agent

-

## 续跑交接

N/A

## 仍未知

- 无

## 后续

-

## 文档更新（仅当用户要求）

-
EOF
}

# ============ 生成 11 个 eval 仓 ============

base "$ROOT/eval01-checkout-500/checkout-service"
base "$ROOT/eval02-payment-idempotency/checkout-service"
base "$ROOT/eval03-fastpath-coupon/checkout-service"
base "$ROOT/eval04-resume/checkout-service"
preset_resume "$ROOT/eval04-resume/checkout-service"
base "$ROOT/eval05-refactor-total/checkout-service"
base "$ROOT/eval07-investigate/checkout-service"
base "$ROOT/eval08-warmstart/checkout-service"
preset_warmstart "$ROOT/eval08-warmstart/checkout-service"
base "$ROOT/eval09-token-economy/checkout-service"

# eval 6：typo 仓（黑名单）
write "$ROOT/eval06-typo/typo-repo/README.md" <<'EOF'
# typo-repo

This repo is a demo. Recieve the latest changes and commit them.
EOF
write "$ROOT/eval06-typo/typo-repo/.gitignore" <<'EOF'
.delegate/
EOF

# eval 10：dropdown-app（能打开、不能选中）
write "$ROOT/eval10-acceptance-reopen/dropdown-app/package.json" <<'EOF'
{
  "name": "dropdown-app",
  "private": true,
  "scripts": { "test": "node --test" }
}
EOF
write "$ROOT/eval10-acceptance-reopen/dropdown-app/README.md" <<'EOF'
# dropdown-app

顶栏城市下拉组件。测试：`npm test`
EOF
write "$ROOT/eval10-acceptance-reopen/dropdown-app/src/dropdown.js" <<'EOF'
'use strict';
// 顶栏城市下拉
const state = { open: false, selected: null };

function toggle() {
  state.open = !state.open;
  return state.open;
}

function select(city) {
  // BUG: 没有更新 state.selected（上轮只修了「能打开」）
  return state.selected;
}

module.exports = { toggle, select, getState: () => state };
EOF
write "$ROOT/eval10-acceptance-reopen/dropdown-app/test/dropdown.test.js" <<'EOF'
'use strict';
const assert = require('node:assert');
const { test } = require('node:test');
const dd = require('../src/dropdown');

test('dropdown opens', () => {
  assert.strictEqual(dd.toggle(), true);
});
test('select city updates selected', () => {
  dd.select('上海');
  assert.strictEqual(dd.getState().selected, '上海');
});
EOF
preset_dropdown_done "$ROOT/eval10-acceptance-reopen/dropdown-app"

# eval 11：filter-app（提交后列表不刷新）
write "$ROOT/eval11-result-chain/filter-app/package.json" <<'EOF'
{
  "name": "filter-app",
  "private": true,
  "scripts": { "test": "node --test" }
}
EOF
write "$ROOT/eval11-result-chain/filter-app/README.md" <<'EOF'
# filter-app

筛选面板 + 结果列表。测试：`npm test`
EOF
write "$ROOT/eval11-result-chain/filter-app/src/filter.js" <<'EOF'
'use strict';
// 筛选面板：提交后应把结果写入 state.results 并重渲染列表
const state = { filters: {}, results: [] };

function submit(filters, fetchResults) {
  state.filters = filters;
  // BUG: 拿到结果后没有写入 state.results，列表不会刷新
  return fetchResults(filters);
}

function render() {
  return state.results;
}

module.exports = { submit, render, getState: () => state };
EOF
write "$ROOT/eval11-result-chain/filter-app/test/filter.test.js" <<'EOF'
'use strict';
const assert = require('node:assert');
const { test } = require('node:test');
const { submit, render, getState } = require('../src/filter');

test('submit refreshes list', () => {
  const data = [{ id: 1, price: 10 }];
  submit({ maxPrice: 20 }, () => data);
  assert.deepStrictEqual(getState().results, data);
  assert.strictEqual(render().length, 1);
});
EOF

echo "scaffold done: $ROOT"
