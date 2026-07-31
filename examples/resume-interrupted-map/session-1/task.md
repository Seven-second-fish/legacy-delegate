# Task

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: in_progress
fast_path: false
evidence_target: L2
resume: false
last_stage: orient
resume_from: map
```

## User ask

`POST /checkout` returns 500 when the cart has a coupon. Map first, then fix.

## Success criteria

- [ ] HTTP 200 + discounted total (no 500)
- [ ] Automated test covers null/missing coupon expiry

## Fast path (if any)

- Reason: N/A
- User-specified files/symbols:

## Resume (if any)

- Prior artifacts read: N/A (first session)
- Why this `resume_from`: N/A
- Handoff hint used (from notes.md, if any): N/A

## Repo guides read

- [x] README — `npm test`
- Build: N/A
- Test: `npm test -- checkout`

## Blockers / asks for user

-

## Notes

- Session 1 stopped mid-Map (context limit). Handoff in notes.md.
