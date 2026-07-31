# 笔记

```yaml
task_slug: checkout-coupon-500
type: bug
```

## 改了什么

- `PricingService.applyCoupon` 不再因空/缺失过期抛错
- 空过期单元测试

## 如何回归

1. `npm test -- checkout`
2. 手工：无 `expiresAt` 的优惠券 checkout → 200

## 给下一位人 / Agent

- 预览路径共用 PricingService；同一修复覆盖

## 续跑交接

- N/A（任务已完成）

## 仍未知

- 历史优惠券是否依赖 500 做风控 — 需要时问产品

## 后续

- 可选：回填 DB 空值便于理解

## 文档更新（仅当用户要求）

- N/A
