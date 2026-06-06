# Kickoff -- orchestrator-state-consolidation (implementation + bookend)

**Target:** harness-self (this repository)
**Directory:** /workspace/aeh
**Role:** harness-reviewer (harness-side)
**Phase:** implement an accepted OpenSpec proposal, then run the harness-reviewer bookend
**Estimated wall-clock:** 45-90 min

## Context for this session

This file kicks off implementation of the `orchestrator-state-consolidation` proposal after a fresh start in the harness session. The proposal, design, and tasks are already authored and on disk in this directory. Your job is to implement them and gate your own work.

Scope boundary (do NOT exceed): implement `orchestrator-state-consolidation` ONLY. The sibling `harness-maintainer-role-charter` proposal is a recorded charter awaiting its own design round -- do NOT build the maintainer role in this session. `claude-md-size-discipline` is parked -- do NOT touch it.

Known limitation, stated honestly: in this session the harness-reviewer is both implementer and bookend reviewer. That is acceptable at current harness scale because you implement against an external written spec (the proposal/design/tasks), not freehand. The future harness-maintainer/harness-reviewer split (see `harness-maintainer-role-charter`) is what will separate these; until it exists, run the bookend as adversarially as you can against your own edits.

## The prompt

### Step 0 -- Activate harness-reviewer role (harness-side, self-contained, silent)

Resolve the persona marker path via `bin/resolve-persona-marker.sh`, then write `harness-reviewer` to the resolved path. Suppress the session-init banner and role-picker; THIS prompt is the session initialiser. Load your role definition: `templates/personas/harness-reviewer.md` (this repo is the harness itself; no `_base/` overlay applies).

### Step 1 -- Read the plan and the edit targets

Read, in order:
- `openspec/changes/orchestrator-state-consolidation/proposal.md`
- `openspec/changes/orchestrator-state-consolidation/design.md` (the migration mapping in section 3 is the contract: every retired file maps to a destination + preserved lookup -- this is the no-baby-thrown-out proof you must uphold)
- `openspec/changes/orchestrator-state-consolidation/tasks.md` (your ordered task list with mechanical signals)
- `templates/personas/orchestrator.md` "State Initialisation" + Principles (the eleven-canonical-filenames allowlist) -- the main edit target
- `CLAUDE.md` "Target Project Workspace Structure"
- `templates/personas/harness-reviewer.md` Dimension 3 (Documentation Currency) -- where the forgetting question lands

### Step 2 -- Sanity-review the proposal before implementing

Spend a few minutes confirming the plan is sound before you edit: does the migration mapping cover every retired file? Is the conservative call (keep `tasks.md`, fold only the three redundant satellites) still right? If you find a genuine flaw, STOP and surface it as DECISION-NEEDED rather than implementing a flawed plan. If sound, proceed.

### Step 3 -- Implement tasks 1-7 and 9

Work the tasks in `tasks.md` in order, honouring each mechanical completion signal:
1. orchestrator.md: reduce the canonical-filename allowlist (remove `decisions.md`, `open-questions.md`, `review-history.md`; update the count in prose); add an `## Open Questions` section to the state-file format template; document the journal tagging convention (`[DECISION]` / `[REVIEW]` / `[SESSION]` / `[GATE]`).
2. orchestrator.md: add the "Pre-clear reconciliation" subsection (reconstruct-and-diff procedure from design.md section 4, the `pre-clear delta:` log-line format, and the "fix the slot, not just the instance" rule).
3. CLAUDE.md: update the `targets/<slug>/` listing to the reduced set + a one-line note on where the folded content now lives. Re-check `wc -c CLAUDE.md` does NOT cross 40k (it should DROP -- three filenames removed from the tree).
4. harness-reviewer.md Dimension 3: add the "does every always-active rule and canonical state slot still earn its place -- superseded, mergeable, demotable to a pointer? flag dead wood" question. No new dimension.
6. Create `templates/prompts/migrate-state-satellites.md.template` (retrofit prompt to fold an existing target's three satellite files into journal tags + dashboard section, then remove them). Generic placeholders only (`<slug>`), ASCII-only.
7. CHANGELOG.md [Unreleased] Changed: orchestrator state consolidation + pre-clear reconciliation gate + harness-reviewer forgetting question. Include the short before/after function-preservation table (task 5).

Keep all new content ASCII-only. Do not rephrase rule semantics -- consolidation moves content, it must not change what a rule means.

### Step 4 -- Bookend (task 8): run the harness-reviewer 10-dimension pass

Run your standard review over the changed files. Dimension 1 (Target Detail Leakage) is mandatory -- run `bin/validate-personas.sh` (full mode) and inspect output; never self-certify clean without the scan. Pay special attention to:
- Dimension 3 (Currency): CLAUDE.md and orchestrator.md now describe the SAME canonical file set -- diff them, no divergence.
- Dimension 4 (Template/Persona Consistency): no retired filename survives in the canonical-set context anywhere.
- The migration-mapping contract: no folded content lost.

If the bookend returns REQUEST-CHANGES, fix and re-bookend before committing.

### Step 5 -- Commit LOCAL ONLY (do NOT push)

Run the publication gate: `bin/validate-personas.sh --staged` over staged content and `--message "<text>"` over the commit message. Block on FAIL.

Commit to the harness repo only (this change touches no `targets/` files -- confirm `git -C targets/ status` is clean of changes you caused). Single commit, ASCII-only message, NO AI attribution (no Co-Authored-By / Generated-by). Suggested message:

```
openspec(impl): orchestrator-state-consolidation -- fold decisions/open-questions/review-history into journal tags + dashboard; add pre-clear reconciliation gate; harness-reviewer forgetting question
```

DO NOT `git push`. Pushing publishes to downstream consumers, and how changes reach consumers without tearing apart their setups is exactly the unbuilt charter of the harness-maintainer role (`harness-maintainer-role-charter`). The push is a later, deliberate, maintainer-governed act the operator authorises -- not part of this session.

Then flip the proposal `status:` toward `ready-for-archive` (do NOT archive -- close-out is a separate maintainer-governed step, and it may want to spec the state model under `openspec/specs/` first).

### Step 6 -- Report

This is harness-side work; no PROMPT-COMPLETE sentinel (that's target-session only). The artefacts ARE the report: edited orchestrator.md / CLAUDE.md / harness-reviewer.md / CHANGELOG.md, the new retrofit template, the bookend verdict, and a local commit (unpushed). Close with the 4-state discipline (DONE / DECISION-NEEDED / PAUSED-ON-YOUR-WORK / MONITORING-BACKGROUND). Be terse; next action is the near-last line.

## Expected outcome

- orchestrator.md, CLAUDE.md, harness-reviewer.md, CHANGELOG.md edited per tasks 1-4, 7.
- `templates/prompts/migrate-state-satellites.md.template` created.
- Harness-reviewer bookend APPROVE / APPROVE-WITH-MINOR.
- Single LOCAL harness commit; nothing pushed.
- Proposal status `ready-for-archive`.

## Fallback

If `bin/resolve-persona-marker.sh` is missing or the `bin/.leakage-patterns` blocklist is absent, this is the wrong checkout state for a leak-gated commit -- halt and surface. If the migration mapping in design.md does not in fact cover a content class you find in the field, STOP and surface as DECISION-NEEDED; do not improvise a destination.
