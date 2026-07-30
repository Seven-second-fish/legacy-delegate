# Feature workflow

1. From Map, list all touchpoints needed for the behavior (API, storage, config, callers).
2. Prefer smallest vertical slice that meets success criteria.
3. Match existing patterns in-repo (naming, error handling, tests).
4. Implement inside change boundary; avoid drive-by cleanups.
5. Verify with tests or explicit manual steps (L1/L2).
6. Note compatibility risks (callers, migrations, feature flags) in `change.md` / `notes.md`.
