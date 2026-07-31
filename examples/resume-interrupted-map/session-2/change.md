# Change

```yaml
task_slug: checkout-coupon-500
evidence_grade: L2
```

## Hypotheses tried

1. Null `expiresAt` treated as crash → **confirmed**

## Diff summary

- `PricingService.applyCoupon`: treat null/missing `expiresAt` as non-expiring
- Added unit test `coupon-null-expiry`

## Before

- `POST /checkout` with coupon `expiresAt: null` → 500

## After

- Same request → 200 + discounted total
- `npm test -- checkout` green

## Evidence

- Steps: seed coupon with null expiry → checkout → assert 200
- Automation: unit test passes (`evidence_grade: L2`)
