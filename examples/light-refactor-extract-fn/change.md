# 改动

```yaml
type: refactor
evidence_grade: L2
status: verified
```

## 计划（对齐 Map 边界）

1. 跑通既有定价表征测试作基线  
2. 抽出 `isCouponExpired(coupon, now)`，`applyCoupon` 改为调用它  
3. 重跑同一测试套件

## 已测假设（bug）/ 触点计划（feature|refactor）

| 项 | 结果 |
|----|------|
| 抽纯函数后折扣用例全绿 | 通过 |
| 不改 `applyCoupon` 签名 | 通过 |

## 表征证据（refactor 必填；其他类型写 N/A）

- 锁住的行为：
  - 有效优惠券：总额 = 折后价
  - 已过期优惠券：不打折
  - `expiresAt: null`：视为未过期（与既有语义一致）
- 改前基线：`npm test -- pricing` → 12 passed（记录于会话日志）

## 回滚点（refactor 必填；其他类型写 N/A）

- `git revert <本提交>` 或还原 `pricing/coupon.js` 内联判断并删除 `isCouponExpired`

## 改动摘要

| 文件 | 改动 |
|------|------|
| `pricing/coupon.js` | 新增 `isCouponExpired`；`applyCoupon` 改用它 |
| `pricing/coupon.test.js` | 可为纯函数补 1 个直测（可选）；表征套件未改期望 |

## 验证

### 步骤

1. 改前：`npm test -- pricing`  
2. 抽函数  
3. 改后：同一命令

### 之前

- 12 passed

### 之后

- 12 passed（+1 可选直测则 13）

### 命令 / 测试 / 日志（脱敏）

```
npm test -- pricing
```

## 证据等级说明

- 自动化表征套件改前/改后均绿 → L2

## 残留风险

- 若别处曾复制粘贴过期判断，未在本边界；见 notes 后续
