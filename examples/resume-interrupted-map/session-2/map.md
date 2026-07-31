# Map

```yaml
task_slug: checkout-coupon-500
status: complete
```

## Entries

- `POST /checkout` → `CheckoutController.handle`

## Critical path

`POST /checkout` → `CheckoutController.handle` → `PricingService.applyCoupon` → `CouponRepo.find` → throws on null `expiresAt`

## Touch list

| File / symbol | Why |
|---------------|-----|
| `checkout/controller.js` | Entry |
| `pricing/coupon.js` `PricingService.applyCoupon` | Null expiry crash |
| `pricing/coupon_repo.js` `CouponRepo.find` | Returns coupon without expiry |

## Blast radius

- `applyCoupon` also used by `PreviewController` — same null path; keep fix inside PricingService so preview benefits

## Confirmed / Hypotheses / Unknowns

| Confirmed | Hypotheses | Unknowns |
|-----------|------------|----------|
| Stack: throw when reading `expiresAt` | Missing expiry should mean non-expiring | Whether fraud flow relied on 500 (ask product later) |
| Repro: coupon row with `expiresAt: null` | | |

## Allowed change boundary

- Allow: null/missing expiry handling in `PricingService` + unit test
- Non-goals: cart redesign; CouponRepo schema migration

## Open questions for user

- (none blocking Change; product question deferred to notes)
