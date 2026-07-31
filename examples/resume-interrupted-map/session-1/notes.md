# 笔记

```yaml
task_slug: checkout-coupon-500
type: bug
```

## 改了什么

- 未改业务代码。Orient 完成；Map 仅为 draft。

## 如何回归

1. Change 完成前 N/A

## 给下一位人 / Agent

- 继续同一 slug `checkout-coupon-500`。打补丁前先补完 Map DoD。

## 续跑交接

- 目前已完成：Orient 完成；Map 有入口 + 部分路径到 `PricingService.applyCoupon`
- 下一阶段（`resume_from`）：`map`
- 待确认问题 / 阻塞：需追 CouponRepo / 过期处理；`applyCoupon` 影响面
- **禁止**改业务代码，直到：`map.md` `status: complete`（或合法 fast_path）

## 仍未知

- 精确抛错点；空过期是否故意

## 后续

-

## 文档更新（仅当用户要求）

- N/A
