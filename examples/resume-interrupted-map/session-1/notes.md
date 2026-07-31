# Notes

```yaml
task_slug: checkout-coupon-500
type: bug
```

## What changed

- No business code. Orient done; Map draft only.

## How to regress

1. N/A until Change

## For next human / agent

- Continue same slug `checkout-coupon-500`. Finish Map DoD before any patch.

## Handoff for resume

- Done so far: Orient complete; Map has entry + partial path into `PricingService.applyCoupon`
- Next stage (`resume_from`): `map`
- Open questions / blockers: need CouponRepo / expiry handling; blast radius of `applyCoupon`
- Do **not** edit business code until: `map.md` `status: complete` (or valid fast_path)

## Unknowns left

- Exact throw site; whether null expiry is intentional

## Follow-ups

-

## Doc updates (only if requested)

- N/A
