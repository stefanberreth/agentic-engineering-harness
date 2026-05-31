---
slug: base-persona-refresh-all-scope
---

# Tasks

## Task 1: Author refresh-base-personas template
- `templates/prompts/refresh-base-personas.md.template` -- target-side prompt copies all six base personas + verifies checksums.
- **Signal:** file exists; lists all six personas.

## Task 2: Update harness-reviewer Propagation-Impact Assessment Mode
- The example retrofit-action list updates "Refresh persona snapshots" to all-personas-scoped.
- References the new template.
- **Signal:** `grep -c "refresh-base-personas\|all six personas\|all base personas" templates/personas/harness-reviewer.md` returns >= 1.

## Task 3: Health-check Role Activation currency extension (decision)
- Either implement now, defer with a note, or skip with rationale.
- If implementing: extend § 3l to verify checksum match between target snapshot and harness master per-persona.
- Decided this proposal: defer to a future health-check enhancement proposal; current proposal lands the refresh mechanism, the detection enhancement is a sibling concern.

## Task 4: CHANGELOG + archive after bookend
- Under [Unreleased] Added.
- Archive proposal post-bookend.
