# 地图

```yaml
task_slug: checkout-coupon-500
status: complete
```

## 入口

- `POST /checkout` → `CheckoutController.handle`

## 关键路径

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` → `CouponRepo.find` → 读取空 `expiresAt` 时抛错

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| `checkout/controller.js` | | 入口 |
| `pricing/coupon.js` | `PricingService.applyCoupon` | 空过期崩溃 |
| `pricing/coupon_repo.js` | `CouponRepo.find` | 返回无过期时间的优惠券 |

## 影响面

- `PreviewController` 也调用 `applyCoupon` — 同一空路径；修复放在 PricingService，预览一并受益

## 已证实

- 堆栈：读 `expiresAt` 时抛错
- 复现：优惠券行 `expiresAt: null`

## 假设

- 缺失过期应视为永不过期

## 未知

- 风控是否曾依赖 500（产品后续确认）

## 改动边界

**允许：**

- `PricingService` 对空/缺失过期的处理 + 单元测试

**禁止动：**

- 购物车重设计；CouponRepo schema 迁移

## 待确认问题

- （无阻塞 Change 的问题；产品疑问留到 notes）
