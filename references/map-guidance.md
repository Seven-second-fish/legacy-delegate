# Map guidance

Keep maps **task-scoped**. Do not boil the ocean.

## Prefer order

1. Locate runtime/config entry for the symptom or feature area
2. Trace one critical path with file:symbol breadcrumbs
3. List fan-in callers of the hottest symbol (blast radius)
4. Separate confirmed facts from guesses
5. Freeze a small change boundary before editing

## Good path line

`HTTP /login` → `AuthController.login` → `SessionService.create` → `RedisStore.set` → failure at TTL config

## Bad map

- Only directory tree dump
- “Seems like auth is wrong” with no files
- Marking `complete` while Unknowns block the fix and no questions asked

## Depth vs mode

- `delegate`: shortest path that supports a reviewable change
- `onboard`: same path + one-sentence role of each hop
