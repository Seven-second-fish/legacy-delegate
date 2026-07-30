# Refactor workflow (MVP: light only)

## Allowed in MVP

- Extract function, rename local, dedupe within mapped boundary
- Move code only with clear callers updated in the same change
- Add characterization tests **before** behavior-preserving edits when tests missing

## Not in MVP (defer / ask user)

- Cross-module redesign, layer swaps, dependency inversion campaigns
- “Improve everything” while fixing a bug
- Refactors without regression plan

## Steps

1. Map boundary + regression plan (even if manual)
2. Lock behavior (test or checklist)
3. Small commits/steps mentally: one intention per diff hunk group
4. Re-run regression; evidence ≥ L1
5. If scope grows → stop, update Map, get confirmation
