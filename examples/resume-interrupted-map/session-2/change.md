# 改动

```yaml
task_slug: checkout-coupon-500
evidence_grade: L2
```

## 计划（对齐 Map 边界）

- 在 PricingService 将空/缺失 `expiresAt` 视为永不过期，并补测试

## 已测假设（bug）/ 触点计划（feature|refactor）

| 项 | 结果 |
|----|------|
| 空 `expiresAt` 被当成崩溃 | **已证实** |

## 改动摘要

| 文件 | 改动 |
|------|------|
| `pricing/coupon.js` | 空/缺失过期视为永不过期 |
| 测试 | 新增 `coupon-null-expiry` |

## 验证

### 步骤

1. 种入 `expiresAt: null` 的优惠券 → checkout → 断言 200

### 之前

- `POST /checkout` + 空过期优惠券 → 500

### 之后

- 同请求 → 200 + 折扣总额
- `npm test -- checkout` 通过

### 命令 / 测试 / 日志（脱敏）

```
npm test -- checkout
```

## 证据等级说明

- 自动化测试通过 → `evidence_grade: L2`

## 残留风险

- 产品是否依赖旧 500 行为：见 notes
