---
slug: base-persona-refresh-all-scope
status: archived
archived-at: 2026-06-19T19:18:24Z
since: 2026-05-31
provenance: openspec/changes/base-persona-refresh-all-scope/provenance.md
---

# Base-Persona Refresh: All-Personas Scope

## What

Author a new `templates/prompts/refresh-base-personas.md.template` that copies all six engineering personas (analyst, archaeologist, architect, developer, reviewer, orchestrator) from harness master into a target's `docs/AE/personas/_base/`. Update the harness-reviewer Propagation-Impact Assessment Mode subsection so its example retrofit-action list scopes persona refresh to all personas, not orchestrator-only. Optionally extend health-check Role Activation to detect snapshot currency drift, not just presence.

## Why

Targets carry snapshots of all six engineering personas in `docs/AE/personas/_base/`. When the propagation flow detects a harness advance and an operator approves a "refresh persona snapshots" action, the natural-but-wrong move is to refresh only the persona whose update is most prominent in the diff. Other persona snapshots may have drifted at any point in the target's history -- pre-existing drift the operator never picked up. The first verified end-to-end exercise of the propagation flow caught this: the retrofit plan refreshed only orchestrator; the peer AEH orchestrator session running the Propagation-Impact Assessment Mode pass detected developer + reviewer snapshots had also drifted and authored a corrective commit refreshing all six.

The right shape: persona-refresh actions in the propagation flow are `_base/`-directory-scoped, not persona-scoped. The cost is trivial (six file copies vs one); the value is catching pre-existing drift that single-persona refresh leaves silently in place.

## Scope

In scope:
- New `templates/prompts/refresh-base-personas.md.template`: target-side prompt that copies all six base personas (`templates/personas/{analyst,archaeologist,architect,developer,reviewer,orchestrator}.md`) into the target's `docs/AE/personas/_base/` directory, verifies byte-identical copies via checksum, reports per-persona before/after sizes + checksum.
- Update `templates/personas/harness-reviewer.md` § "Propagation-Impact Assessment Mode": the example retrofit-action list for "Refresh persona snapshots" calls out all six personas explicitly (not orchestrator-only) and references the new refresh-base-personas template.
- Optional: extend `templates/playbooks/health-check.md` § 3l (Role Activation) to verify snapshot currency (checksum vs harness master) in addition to presence. Severity: LOW for stale-but-not-bitten, MEDIUM if recent failures trace to stale snapshots.
- CHANGELOG entry.

Out of scope:
- Auto-refresh of base personas (operator-gated stays the rule).
- Detecting *which* persona has drifted in what way -- the refresh action is `_base/`-wide; granular diffing is a reviewer-pass concern, not a refresh-action concern.

## Acceptance criteria

1. `templates/prompts/refresh-base-personas.md.template` exists and copies all six personas with checksum verification.
2. `templates/personas/harness-reviewer.md` Propagation-Impact Assessment Mode subsection has updated example referencing all-personas refresh + the new template.
3. CHANGELOG entry under [Unreleased] Added.
4. Inbox capture at `openspec/changes/_intake/2026-05-31-1600-base-persona-refresh-all-personas-0c37120ebcd6.md` marked promoted.
5. Optional health-check currency check considered (implement now, defer with a note, or skip with rationale).

## References

- Inbox capture: `openspec/changes/_intake/2026-05-31-1600-base-persona-refresh-all-personas-0c37120ebcd6.md`.
- Related: `openspec/changes/harness-update-propagation-signal/` (the propagation flow this refines).
- Related: `templates/prompts/seed-harness-sync-marker.md.template` (sibling retrofit prompt that may cross-reference).
