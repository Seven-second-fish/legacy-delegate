# Notes

```yaml
task_slug: checkout-coupon-500
type: bug
```

## What changed

- Null/missing coupon expiry no longer throws in `PricingService.applyCoupon`
- Unit test for null expiry

## How to regress

1. `npm test -- checkout`
2. Manual: checkout with coupon lacking `expiresAt` → 200

## For next human / agent

- Preview path shares PricingService; covered by same fix

## Handoff for resume

- N/A (task done)

## Unknowns left

- Whether legacy coupons relied on 500 for fraud — ask product if needed

## Follow-ups

- Optional: backfill DB nulls for clarity

## Doc updates (only if requested)

- N/A
