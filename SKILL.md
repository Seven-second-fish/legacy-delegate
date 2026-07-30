---
name: legacy-delegate
description: >-
  Auditable legacy-codebase delegation: map long call/data chains before editing,
  then fix bugs or add features with evidence grades, optionally light-refactor,
  and leave notes for humans and future agent sessions. Use when explicitly
  invoked for unfamiliar modules, long investigation chains, delegated bugfixes,
  cross-layer features, or safe refactors that must not skip understanding.
disable-model-invocation: true
---

# Legacy Delegate

Protocol for **unfamiliar-AI** work on long chains: Orient → Map → Change → Leave.  
Gates are **protocol + optional script**, not kernel enforcement.

## Hard rules

1. Write artifacts under `.delegate/<task-slug>/` in the **target repo**.
2. Do **not** edit business code until Map is `complete`, unless Fast path (§) or `investigate_only`.
3. Never claim **done** at evidence **L0**. Prefer L2; L1 allowed if documented.
4. Obey repo rules first: `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, README build/test.
5. No secrets in artifacts. Suggest `.delegate/` in `.gitignore`.
6. Before claiming done, run: `bash <this-skill>/scripts/check_delegate_artifacts.sh .delegate/<task-slug>`

Copy templates from [templates/](templates/) into the task dir; fill them (do not leave stubs).

## Modes

| Mode | Default | Style |
|------|---------|-------|
| `delegate` | yes | Short verdict + evidence + risks + unknowns |
| `onboard` | no | Same structure, more “why” for newcomers |

Task types: `bug` | `feature` | `refactor` (MVP: refactor = **light only**, see [references/refactor-workflow.md](references/refactor-workflow.md)).

## When not to use

Stop and say so (or set `aborted`) if: typo/copy-only with exact file given; user wants explanation only; user already has a full patch to apply; issue needs debugger/prod signals unavailable → `blocked`.

## Workflow checklist

```
Progress:
- [ ] Orient → task.md
- [ ] Map → map.md (DoD) OR fast_path recorded
- [ ] Change → code + change.md (evidence ≥ L1)
- [ ] Leave → notes.md
- [ ] check_delegate_artifacts.sh passes
```

### 0) Orient

Create `.delegate/<task-slug>/` (`task-slug`: short kebab-case from topic + date if needed).

Fill `task.md` from [templates/task.md](templates/task.md):

- type, mode, success criteria
- `investigate_only` / `fast_path` if applicable
- Read repo guide files; note build/test commands

If blocked on env/repro/access: set status `blocked`, list asks, **stop**.

### 1) Map

Fill `map.md` from [templates/map.md](templates/map.md).

**Map DoD** (`status: complete` only if all present):

1. Relevant entries (API/CLI/callback/consumer/…)
2. Critical path to suspect or change points
3. Touch list (files/symbols)
4. Blast radius
5. Confirmed / Hypotheses / Unknowns
6. Allowed change boundary (+ explicit non-goals)
7. Open questions for user if incomplete — then **not** complete

**Fast path**: only if user gave exact files/symbols + intent and asserts chain is clear. Set `fast_path: true` + reason + file list in `task.md`. Still write a **short** `map.md` (touch list + boundary).

**Investigate-only**: complete Map (+ optional notes); **no** business code edits.

Detail tips: [references/map-guidance.md](references/map-guidance.md).

### 2) Change

Require Map `complete` (or valid fast path). Then:

| Type | Follow |
|------|--------|
| bug | [references/bug-workflow.md](references/bug-workflow.md) |
| feature | [references/feature-workflow.md](references/feature-workflow.md) |
| refactor | [references/refactor-workflow.md](references/refactor-workflow.md) |

Fill `change.md` from [templates/change.md](templates/change.md).

**Evidence grades**

| Grade | Meaning | Claim done? |
|-------|---------|-------------|
| L0 | Reasoning only | **No** |
| L1 | Repro steps (or user-confirmed) + before/after | Yes, note no automation |
| L2 | Tests or agreed log/probe checks pass | Yes, preferred |

Minimal diffs. Do not “while we’re here” refactor unless type is refactor.

### 3) Leave

Fill `notes.md` from [templates/notes.md](templates/notes.md): what changed, how to regress, unknowns, follow-ups.  
Optional: promote stable facts into repo docs **only if user asked**.

## Human reply shape

**delegate**

```markdown
## Verdict
...
## Evidence (L1|L2)
...
## Risks / Unknowns
...
## Artifacts
`.delegate/<task-slug>/`
```

**onboard**: same headings + short “Why this path” under Verdict.

## Scripts

- [scripts/check_delegate_artifacts.sh](scripts/check_delegate_artifacts.sh) — verify required files and naive DoD markers exist.

## Additional resources

- Templates: [templates/](templates/)
- Plan / full spec: [PLAN.md](PLAN.md)
- Example walkthrough: [examples.md](examples.md)
