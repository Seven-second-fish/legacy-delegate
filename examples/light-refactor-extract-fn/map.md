# 地图

```yaml
status: complete
fast_path: false
```

## 入口

- 单测入口：`npm test -- pricing`
- 运行时：`PricingService.applyCoupon`（checkout / preview 共用）

## 关键路径

`applyCoupon(cart, coupon)` → 内联过期判断 → 算折扣 → 返回总额

## 触点列表（文件 / 符号）

| 路径 | 符号 | 原因 |
|------|------|------|
| `pricing/coupon.js` | `PricingService.applyCoupon` | 抽函数来源 |
| `pricing/coupon.js` | `isCouponExpired`（新建） | 纯函数落点 |
| `pricing/coupon.test.js` | 表征用例 | 行为锁 |

## 影响面

- `CheckoutController` / `PreviewController` 经 `applyCoupon`；不改签名则无调用方改动

## Git 线索（可选）

| 路径 | 近况 / churn | 热点作者（线索） |
|------|--------------|------------------|
| `pricing/coupon.js` | 近 10 提交多为定价/券逻辑；非全仓热点 | 仅作「可能知情」；不问责 |

## 已证实

- 过期判断仅在 `applyCoupon` 内联出现一处
- 已有定价单测可作表征基线

## 假设

- 抽成纯函数不改变分支语义

## 未知

- 无（轻量范围内）

## 改动边界

**允许：**

- 在 `pricing/coupon.js` 抽出 `isCouponExpired`；测试只加断言不改业务期望

**禁止动：**

- 折扣公式、仓库 schema、controller 层、顺手改命名全文件

## 待确认问题

-
