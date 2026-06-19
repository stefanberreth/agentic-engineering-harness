---
slug: claude-md-size-discipline
---

# Tasks (2026-06-19 consolidation -- controlling)

Supersedes the original task list (which assumed the dropped `docs/harness-rules/` tree).
Ordered; each task carries a mechanical completion signal.

## Task 1: Govern -- "router not manual" principle + authoring test
- Add a "CLAUDE.md is a router, not a manual" governance principle + a soft size budget,
  and the universal-pre-role-vs-role/task-specific authoring test, to the harness governance
  surface; mirror into the target CLAUDE.md template guidance.
- **Signal:** the principle + the authoring test are present harness-side and in the target
  CLAUDE.md template.

## Task 2: Inventory + compress-in-place the named candidates
- Inventory CLAUDE.md sections by size (working artefact, `*.private.md`, gitignored).
- Compress the first candidates (full Harness Maintenance Discipline = aeh-engineer-only;
  the full role-location 3-part signature; duplicated cross-container + propagation
  mechanics) to a one-line rule + a RESOLVABLE pointer to the EXISTING owning home. No new
  docs tree.
- **Signal:** each compressed bullet is `- **Topic.** One-sentence rule. Detail: <pointer>.`;
  word-diff shows rule sentences preserved, rationale moved to (not duplicated in) its home.

## Task 3: Confirm the consumer loads each extracted home
- For every pointer wired in Task 2, confirm the role/playbook that needs the rule actually
  loads the home it now points at (no orphaned rule).
- **Signal:** each extracted home is referenced from at least one consumer that loads it.

## Task 4: Deterministic size-budget WARN check (symmetric)
- Add a CLAUDE.md size/line-budget WARN -- harness-side in the harness-reviewer flow AND
  target-side in `bin/aeh-practice-check.sh` (run by target-aeh-reviewer).
- **Signal:** the check WARNs above budget, PASSes below, on both layers.

## Task 5: Reviewer router-discipline JUDGMENT dimension (symmetric)
- Add a reviewer dimension: "is each section universal-pre-role, or should it be a pointer?"
  harness-reviewer (harness CLAUDE.md) and target-aeh-reviewer (target CLAUDE.md).
- **Signal:** the dimension is present in both reviewer surfaces.

## Task 6: Pointer-resolution check in harness-reviewer
- "Every CLAUDE.md `Detail: <pointer>` line resolves to an existing file."
- **Signal:** dimension entry committed.

## Task 7: Whole-block-diff retrofit-scoping rule
- Bind the rule into the target-orchestrator / propagation-refresh CLAUDE.md alignment path:
  scope a CLAUDE.md retrofit to the whole affected block diffed against the canonical
  template, in one pass.
- **Signal:** the retrofit/refresh path states the whole-block-diff scoping rule.

## Task 8: CHANGELOG + gate + bookend
- CHANGELOG [Unreleased] entry; `bin/validate-personas.sh --staged` + `--message` pass;
  harness-reviewer bookend; coordinate any roles-list edits with
  `harness-role-execution-context-discipline` to avoid a CLAUDE.md merge clash.
- **Signal:** validator exits 0; reviewer PASS/WARN; no push.
