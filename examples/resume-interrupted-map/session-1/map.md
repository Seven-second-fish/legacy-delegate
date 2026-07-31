# Map

```yaml
task_slug: checkout-coupon-500
status: draft
```

## Entries

- `POST /checkout` → `CheckoutController.handle`

## Critical path

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` → (stopped here; CouponRepo not traced)

## Touch list

| File / symbol | Why |
|---------------|-----|
| `checkout/controller.js` | Entry |
| `pricing/coupon.js` `PricingService.applyCoupon` | Suspect; stack mentions coupon |

## Blast radius

- Other callers of `applyCoupon`: **unknown** (not listed yet)

## Confirmed / Hypotheses / Unknowns

| Confirmed | Hypotheses | Unknowns |
|-----------|------------|----------|
| 500 only when coupon present | Crash inside `applyCoupon` | Exact throw site; null `expiresAt`? |
| | | Fan-in of `applyCoupon` |

## Allowed change boundary

- Allow: pricing/coupon null-safety only (tentative)
- Non-goals: cart redesign — **DoD incomplete; do not Change yet**

## Open questions for user

- Can we treat missing `expiresAt` as non-expiring?
