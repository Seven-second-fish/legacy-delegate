# 地图

```yaml
task_slug: checkout-coupon-500
status: draft
```

## 入口

- `POST /checkout` → `CheckoutController.handle`

## 关键路径

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` →（停于此；尚未追到 CouponRepo）

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| `checkout/controller.js` | | 入口 |
| `pricing/coupon.js` | `PricingService.applyCoupon` | 可疑；堆栈提到 coupon |

## 影响面

- `applyCoupon` 的其他调用方：**未知**（尚未列出）

## 已证实

- 仅在有优惠券时 500

## 假设

- 崩溃发生在 `applyCoupon` 内

## 未知

- 精确抛错点；是否空 `expiresAt`？
- `applyCoupon` 的 fan-in

## 改动边界

**允许：**

- 暂定：仅 pricing/coupon 空安全

**禁止动：**

- 购物车重设计 — **DoD 未完成；禁止进入 Change**

## 待确认问题

- 能否将缺失的 `expiresAt` 视为永不过期？
