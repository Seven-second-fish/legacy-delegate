# Bug workflow

1. Reproduce or get user-confirmed repro; if impossible → `blocked` (do not patch blindly).
2. From Map, pick ranked hypotheses (falsifiable).
3. Test cheapest hypothesis first (log read, bisect, focused test).
4. Apply **minimal** patch inside change boundary.
5. Re-run repro; record before/after in `change.md`.
6. Evidence: L1 minimum; add/adjust test when feasible → L2.
7. If root cause unclear after reasonable tries: document unknowns, ask user, do not claim done.
