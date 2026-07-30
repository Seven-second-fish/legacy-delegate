# Example walkthrough (fictional)

> 真实仓验收见 README「Demo：cakeshop」与 [Seven-second-fish/cakeshop](https://github.com/Seven-second-fish/cakeshop)。下文为虚构走通，便于不依赖环境时理解闸门。

Repo: tiny Node service. Symptom: `POST /checkout` returns 500 when cart has a coupon.

## Orient

`.delegate/checkout-coupon-500/task.md`

- type: bug, mode: delegate  
- success: 200 + discounted total; no 500  
- test: `npm test -- checkout`

## Map (complete)

Path:

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` → `CouponRepo.find` → throws on null `expiresAt`

Touch: `pricing/coupon.js`, `checkout/controller.js`  
Boundary: fix null expiry handling in PricingService only; do not redesign cart.

## Change (L2)

- Hypothesis: missing expiry treated as crash → confirmed  
- Patch: treat null expiry as non-expiring; add unit test  
- `evidence_grade: L2` — test green

## Leave

Regress: unit test + manual checkout with coupon lacking `expiresAt`.  
Unknown: whether legacy coupons rely on crash for fraud (ask product).

## Fast path contrast

User: “Only change `pricing/coupon.js` null check, I know the path.”  
→ `fast_path: true`, short map, same evidence rules.
