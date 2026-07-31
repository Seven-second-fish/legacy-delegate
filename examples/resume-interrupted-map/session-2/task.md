# Task

```yaml
task_slug: checkout-coupon-500
type: bug
mode: delegate
status: done
fast_path: false
evidence_target: L2
resume: true
last_stage: leave
resume_from: ""
```

## User ask

`POST /checkout` returns 500 when the cart has a coupon. Map first, then fix.

## Success criteria

- [x] HTTP 200 + discounted total (no 500)
- [x] Automated test covers null/missing coupon expiry

## Fast path (if any)

- Reason: N/A
- User-specified files/symbols:

## Resume (if any)

- Prior artifacts read: session-1 `task.md` / `map.md` (draft) / `notes.md` handoff
- Why this `resume_from`: handoff said `map`; Map was not complete
- Handoff hint used (from notes.md, if any): finish Map DoD; no code until complete

## Repo guides read

- [x] README — `npm test`
- Build: N/A
- Test: `npm test -- checkout`

## Blockers / asks for user

-

## Notes

- Session 2 resumed from Map; completed Map → Change (L2) → Leave.
