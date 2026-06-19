---
slug: harness-role-execution-context-discipline
status: archived
archived-at: 2026-06-19T19:27:06Z
outcome: overtaken-by-events
since: 2026-06-01
intake: openspec/changes/_intake/2026-06-01-1114-target-side-orchestrator-role-defect-c04003d97c24.md
---

# Harness role execution-context discipline

## Disposition (2026-06-19): archived -- overtaken-by-events (not built)

Closed without building: the intent was delivered by later, larger work.
- The mislabeled retrofit templates (the motivating defect) were corrected by the
  B5 role rename (`aeh-engineer-role-b5`): they now read `freestyle (harness-delivered
  structural placement)`.
- "Where each role runs" is now documented more robustly than the proposed CLAUDE.md
  "Execution context" column would have been: `README.md` carries an explicit
  detect/remediate x harness/target matrix with a "Runs in" column plus a per-role
  "Where it runs" table; the role NAMES encode the family (`target-orchestrator` vs
  `harness-reviewer`); each engineering persona's Step-0 declares it runs in the target,
  not the harness; and the role-location self-check makes every role assert its tree at
  activation. A CLAUDE.md column would now duplicate the README.
The only literally-unbuilt remnant (a CLAUDE.md column + per-persona one-liners) is
redundant with the above, so it is not pursued. Operator-ratified 2026-06-19.

## What

Make each persona's intended execution context explicit and unambiguous: harness-side / target-side / external-LLM. Update CLAUDE.md and every persona file to declare execution context up front. Fix the three retrofit prompt templates that incorrectly label themselves `orchestrator (target-side)` -- they should be freestyle (no role) since they are mechanical operator-authored maintenance scripts that need no persona constraints.

## Why

Three harness retrofit prompt templates declare `Role: orchestrator (target-side)` in their headers:
- `templates/prompts/seed-harness-sync-marker.md.template`
- `templates/prompts/refresh-base-personas.md.template`
- `templates/prompts/openspec-close-out-retrofit.md.template`

This contradicts the architectural model of the orchestrator role: it is a harness-side coordination role -- pipeline management, prompt authorship, gate enforcement -- with state files at `targets/<slug>/orchestrator-state.md` (harness-side path). Target sessions have no orchestrator-state to manage. The retrofits do mechanical file operations + a commit; no coordination authority involved.

The persona / role specifications loaded at session-init do NOT explicitly state "orchestrator is harness-side only." This was caught at first real exercise of the retrofit prompts (2026-06-01 <solo-dev-target> dispatch, prompts 326/327/328). The operator's reasonable expectation: execution context should be defined and unambiguous in the persona docs, not left as an open question to the agent at run-time.

Without an explicit fix at the documentation layer, the next retrofit-template author repeats the same mistake. Without a fix at the template layer, the muddied label keeps propagating into generated prompts.

## Scope

In scope:
- `CLAUDE.md` § "Session Init and Role Selection" -- add an "Execution context" column to the roles list (harness-side / target-side / external-LLM).
- `templates/personas/orchestrator.md` -- one explicit sentence at the top: orchestrator runs harness-side, manages a target via prompts; orchestrator never runs target-side.
- `templates/personas/analyst.md`, `archaeologist.md`, `architect.md`, `developer.md`, `reviewer.md` -- one-line execution context (target-side; harness orchestrator never enters their context).
- `templates/personas/harness-reviewer.md` -- one-line: harness-side.
- `templates/personas/strategist.md` -- one-line: external-LLM session (existing prose lifts to a standard pattern).
- Fix the three retrofit prompt templates: drop `Role: orchestrator (target-side)`, replace with `Role: none (freestyle mechanical retrofit)`; Step 0 explicitly clears persona marker and suppresses banner. Update the templates ONLY; existing already-dispatched prompts (326/327/328) are dispatched-and-done.
- Add a harness-reviewer dimension entry: "retrofit prompt templates declare an execution-context-appropriate role label."
- CHANGELOG entry under [Unreleased] Changed + Fixed.

Out of scope:
- A new `aeh-maintenance` role (considered and rejected: freestyle is cleaner for one-shot mechanical retrofits; reserve `aeh-maintenance` if a recurring class emerges).
- Restructuring the orchestrator persona's authority sections (those are correct; the gap was the missing execution-context declaration at the top).
- Migrating dispatched prompts 326/327/328 retroactively.

## Acceptance criteria

1. CLAUDE.md roles list has Execution context column.
2. All seven persona files declare execution context up front (orchestrator, harness-reviewer, five engineering roles, strategist).
3. Three retrofit prompt templates updated to `Role: none` with freestyle Step 0.
4. Harness-reviewer dimension entry added.
5. CHANGELOG entry.
6. Intake capture status updated to promoted.

## References

- Intake: `openspec/changes/_intake/2026-06-01-1114-target-side-orchestrator-role-defect-c04003d97c24.md`
- Sibling: `openspec/changes/orchestrator-manage-dont-do/` (altitude discipline; this proposal is the sibling concerned with execution location)
- Pairs with: `openspec/changes/claude-md-size-discipline/` (CLAUDE.md slim work; the Execution context column is part of the slim revision)
