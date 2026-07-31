# Cross-session resume

When a prior session left `.delegate/<task-slug>/`, the next session **continues that folder** — it does not restart Orient from zero unless the user asks for a new slug.

## Orient (resume detection)

1. List `.delegate/` in the **target repo** (if present).
2. If the user named a slug, open that dir; else pick the newest `in_progress` / `blocked` task, or ask which slug.
3. Read `task.md` first, then existing `map.md` / `change.md` / `notes.md` (whatever exists).
4. Set or refresh resume fields in `task.md`:
   - `resume: true`
   - `last_stage`: last **finished** stage (`orient` | `map` | `change` | `leave`)
   - `resume_from`: stage to run **next**
5. Tell the user in one line: resuming `<slug>` from `<resume_from>` (Map status / evidence if known).

## Where to resume

| Existing state | `resume_from` | Allowed actions |
|----------------|---------------|-----------------|
| Only `task.md` (or incomplete Orient) | `orient` | Finish Orient; then Map |
| `map.md` missing or `status: draft` | `map` | Continue Map; **no business code edits** |
| Map `complete` or valid `fast_path`, no solid Change | `change` | Enter Change per type workflow |
| Change done, notes thin / checker not run | `leave` | Finish notes + run check script |
| `status: done` + checker OK | — | Do **not** re-patch; new work → new slug |
| `status: blocked` | prior stage | Resolve asks; clear blockers before advancing |
| `status: aborted` | — | Keep artifacts; new work → new slug |

## Hard rules (same as fresh run)

- Resume **must not** skip unfinished gates.
- Map not `complete` (and no valid `fast_path`) → **still no** business code edits.
- Never claim **done** at evidence **L0**.
- Prefer updating the **same** `.delegate/<task-slug>/`; only create a new slug if the user starts a different task.
- If prior notes have **Handoff for resume**, treat that as the preferred `resume_from` + hint (re-verify against files; do not trust stale handoff blindly).

## Leaving a handoff (end of session mid-task)

Before stopping mid-flow, update:

1. `task.md` — `status`, `last_stage`, `resume_from`, short note under Notes
2. `notes.md` — **Handoff for resume** (what is done, what is next, open questions)
3. Do **not** mark `done` or run the done-gate as if finished

## Anti-patterns

- Ignoring existing `.delegate/` and rewriting Map from scratch without reading it
- Jumping to Change because “the previous chat said the bug is in file X”
- Marking Map `complete` on resume without filling DoD gaps
- Claiming done without re-running `check_delegate_artifacts.sh` after the final Leave
