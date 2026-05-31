---
captured-at: 2026-05-31T16:00:00Z
captured-from: 0c37120ebcd6
captured-during: harness session, end-of-arc reconciliation after the first verified propagation-signal + close-out cycle on a real target
area: template
status: untriaged
---

# Base-persona refresh during propagation must cover all personas, not just the one most recently updated

**Trigger:** During the first verified end-to-end exercise of the harness-update propagation flow, the operator-paste retrofit plan only refreshed one base-persona snapshot in the target's `docs/AE/personas/_base/` directory (the orchestrator, since that was the persona whose update the propagation pass was about to detect). The peer AEH orchestrator running the Propagation-Impact Assessment Mode pass subsequently caught that other base personas in the target's `_base/` had also drifted behind harness master, and authored a corrective commit refreshing all six to byte-identical-with-harness state. The harness-improvement session's retrofit-paste plan had under-specified the persona refresh step.

**Insight:** Target trees carry snapshots of ALL six engineering personas (analyst, archaeologist, architect, developer, reviewer, orchestrator) in `docs/AE/personas/_base/`, not just orchestrator. When a target is brought up to date with a harness that has advanced multiple commits, more than one persona's source may have been updated in the harness during the unsynced range -- and even if only one obviously-relevant persona has changed in the immediate update, the OTHER persona snapshots may have drifted at any point in the target's history (pre-existing drift from earlier harness changes the target never picked up).

The right shape: any persona-refresh action in the propagation flow refreshes ALL base personas in the target's `_base/` directory, not just the persona whose update prompted the current sync. The cost is trivial (six file copies versus one); the value is catching pre-existing drift that the operator may not have noticed and that single-persona refresh leaves silently in place.

This is consistent with the broader propagation-signal discipline: the mechanism is the signal, the interpretation is operator-driven, and the harness-reviewer pass produces a per-action retrofit list. A "persona refresh" action in that list should not be persona-scoped; it should be `_base/` -directory-scoped.

**Suggested change:**

- Author a new retrofit prompt template at `templates/prompts/refresh-base-personas.md.template` that copies all six base personas (`templates/personas/{analyst,archaeologist,architect,developer,reviewer,orchestrator}.md`) into the target's `docs/AE/personas/_base/` directory, with byte-identical verification, and reports per-persona before/after sizes + a checksum.
- Update `templates/personas/harness-reviewer.md` § "Propagation-Impact Assessment Mode" -- in the example retrofit-action list, the "Refresh persona snapshots" action should explicitly call out ALL personas in `_base/`, not single out one. Reference the new refresh-base-personas template.
- Update the existing `templates/prompts/seed-harness-sync-marker.md.template` to either (a) include an optional "while you are here, refresh base personas if any have drifted" step, or (b) cross-reference the new refresh-base-personas template so an operator running the seed retrofit is reminded that persona refresh is a sibling concern. Decision at implementation time; option (a) is more convenient, option (b) keeps the seed prompt narrow.
- Health-check playbook should already detect base-persona drift (existing Role Activation check verifies `_base/` presence; could be extended to verify currency against harness master via checksum). If not already present, add. Severity: LOW for stale snapshots that haven't bitten yet; MEDIUM if a recent prompt failure traces to a stale snapshot loading the wrong persona behaviour.

**Memory updates:** none specifically. The retrofit-paste discipline observation -- "when drafting a retrofit paste that includes persona refresh, scope it to all personas in `_base/`, not just the one whose update triggered the sync" -- is a useful operator note but lives in the new prompt template's framing, not in feedback memory.
