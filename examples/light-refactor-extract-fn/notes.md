# 笔记

```yaml
task_slug: extract-apply-coupon-helpers
type: refactor
```

## 改了什么

- 将优惠券过期判断抽为 `isCouponExpired`，`applyCoupon` 行为保持

## 如何回归

1. `npm test -- pricing`
2. 手工：checkout / preview 各一单有效券与过期券，总额与改前一致

## 给下一位人 / Agent

- 勿在本任务扩大到「统一全仓日期工具」；那是新 slug

## 续跑交接

- N/A（已完成）

## 仍未知

- 其他文件是否有重复过期判断（未扫全仓）

## 后续

- 可选：全仓搜索重复逻辑，另开轻量 refactor

## 文档更新（仅当用户要求）

- N/A
