---
slug: aeh-engineer-role-b5
status: archived
archived-at: 2026-06-19T18:47:51Z
since: 2026-06-17
parent: aeh-engineer-role
build-step: B5
---

# B5: rename orchestrator -> target-orchestrator (done last)

> Fifth build step (sequenced LAST per design.md: a repo-wide rename re-sweeps many
> files, so doing it after the persona set stabilises means a single residual scan
> covers all the new content B2/B3/B4/B6/B7 produced). Renames the role TOKEN
> `orchestrator` to `target-orchestrator` across the live harness surface so the
> name encodes its target-applied family.

## What

1. **Persona file rename:** `git mv templates/personas/orchestrator.md
   templates/personas/target-orchestrator.md`; title -> "Target Orchestrator"
   (the AEH-side pipeline coordinator).

2. **Role-token rename across the LIVE surface** (lowercase token + capitalized
   role-name prose -> `target-orchestrator` / "Target Orchestrator"): `CLAUDE.md`
   (valid-roles, banner roster, taxonomy, role description, structure tree, fence,
   propagation line), `README.md` (roles table), `openspec/project.md`,
   `docs/backlog.md`, all base + harness personas that reference the role, the
   playbooks, `templates/governance/*`, `templates/project/CLAUDE.md.template`,
   `templates/agents/claude-code/permission-baselines.md`, the prompt templates,
   `templates/hooks/*`, and `bin/*.sh` (incl. the validator's `HARNESS_ROLES`).
   Role compounds in prose (`orchestrator-authored`, `-session`, `-generated`,
   `-side`, `-persona`, `-managed`) renamed too.

3. **Marker-value back-compat:** `CLAUDE.md` gains a deprecation-window note -- an
   existing persona marker holding the legacy value `orchestrator` resolves to
   `target-orchestrator` and is rewritten on next write.

4. **Fold: freestyle-prompt label correctness** (private capture
   `target-side-orchestrator-label-misuse`). The four retrofit templates
   (`refresh-base-personas`, `seed-harness-sync-marker`, `seed-target-owner`,
   `openspec-close-out-retrofit`) were labelled "orchestrator (target-side)" /
   "(harness-side)" and wrote `orchestrator` to the persona marker. They are
   mechanical pre-authored file-placement, which is `freestyle` per CLAUDE.md, not
   an orchestrator-role job. Each is relabelled `freestyle (harness-delivered
   structural placement)` and its Step 0 now does NO marker write (which also
   resolves the harness-only-resolver-path defect the B2 capture flagged in the
   refresh template).

## Why

The role's name now carries its family (target-applied). `orchestrator` was the
sole target-applied role whose name did not say so; renaming it to
`target-orchestrator` completes the name-encodes-family taxonomy so an adopter
reads the role roster and knows which roles touch their tree without further
explanation. Sequenced last so one residual scan covers the whole rebuild's new
content rather than re-sweeping after each prior B-step.

## Decisions made (for operator ratification)

1. **Artifact FILENAMES keep the `orchestrator-` prefix; only the ROLE TOKEN is
   renamed.** `orchestrator-state.md` (a per-target state file with an instance in
   every existing target's private workspace) and `orchestrator-batch-regime.md`
   (a prompt template) are deliberately NOT renamed -- renaming them would churn
   every existing target's tree and force a back-compat migration for zero
   behavioural gain, and both read fine as "the orchestration state / batch
   regime". The residual scan therefore intentionally still shows
   `orchestrator-state` / `orchestrator-batch-regime` (artifact filenames) and the
   `orchestrator-*` historical proposal-dir slugs + CHANGELOG history; the ROLE
   TOKEN is fully renamed.
2. **`refresh-base-personas` aligned to FIVE engineering personas (not six).** The
   rename surfaced a pre-existing onboarding-vs-refresh divergence: onboarding
   places five engineering base personas (no coordinator), but the refresh
   template refreshed "six" including `orchestrator`. The coordinator runs
   harness-side and does not belong in a target's `_base/`, so the refresh set is
   corrected to the five engineering personas -- aligning the two and removing the
   need to place a `target-orchestrator.md` snapshot in the target tree.
3. **Historical openspec/changes proposals + CHANGELOG history are NOT rewritten.**
   They are the historical record; per the acceptance, references to the old token
   there are "historical proposal text", exempt from the rename.

## Scope

In scope: items 1-4 above, over the live harness surface.

Out of scope:
- Renaming the `orchestrator-state.md` / `orchestrator-batch-regime.md` artifact
  filenames (Decision 1).
- Rewriting historical openspec/changes proposals + CHANGELOG history (Decision 3).
- The `_base/`-set-composition question beyond the refresh alignment (the deferred
  scaffold-delivery wiring from B3 covers placing `target-aeh-*` into targets).

## Acceptance criteria

1. `templates/personas/orchestrator.md` is renamed to `target-orchestrator.md`
   (git mv) with an updated title; `HARNESS_ROLES` lists `target-orchestrator.md`.
2. A residual scan (`git grep -nwE 'orchestrator'` over the live tree, excluding
   `openspec/changes`, `targets`, `CHANGELOG.md`) returns ONLY `target-orchestrator`
   and the two deliberately-kept artifact filenames (`orchestrator-state`,
   `orchestrator-batch-regime`) -- no bare role-token survivors.
3. The marker-value back-compat note is present.
4. The four retrofit templates are relabelled `freestyle` with no marker write.
5. The validator passes; B5 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/` (design.md "The
  `orchestrator` -> `target-orchestrator` rename" section).
- Predecessors: `aeh-engineer-role-b1`..`b4`, `b6`, `b7`.
- Folded capture (private; dispositioned in `TRIAGE-2026-06-17`):
  `target-side-orchestrator-label-misuse`.
