---
slug: harness-role-execution-context-discipline
---

# Tasks

## Task 1: CLAUDE.md roles list -- Execution context column
- Edit `CLAUDE.md` § "Session Init and Role Selection" -- valid roles list gains an Execution context column.
- Values: harness-side / target-side / external-LLM.
- **Signal:** column present; one entry per role.

## Task 2: Persona files declare execution context
- Add a one-line execution-context declaration at the top of each persona file (immediately after the H1):
  - `templates/personas/orchestrator.md` -- harness-side
  - `templates/personas/harness-reviewer.md` -- harness-side
  - `templates/personas/analyst.md` -- target-side
  - `templates/personas/archaeologist.md` -- target-side
  - `templates/personas/architect.md` -- target-side
  - `templates/personas/developer.md` -- target-side
  - `templates/personas/reviewer.md` -- target-side
  - `templates/personas/strategist.md` -- external-LLM
- **Signal:** `grep -l "Execution context:" templates/personas/*.md` lists all eight.

## Task 3: Retrofit prompt templates -- drop orchestrator role label
- Edit:
  - `templates/prompts/seed-harness-sync-marker.md.template`
  - `templates/prompts/refresh-base-personas.md.template`
  - `templates/prompts/openspec-close-out-retrofit.md.template`
- Replace `Role: orchestrator (target-side)` with `Role: none (freestyle mechanical retrofit)`.
- Step 0 rewritten: explicitly clear persona marker (write empty file, or delete), suppress banner, no role load.
- **Signal:** none of the three templates declare an active role.

## Task 4: Harness-reviewer dimension entry
- Add a check to `templates/personas/harness-reviewer.md` Dimension covering template hygiene: "retrofit prompt templates declare an execution-context-appropriate role label."
- **Signal:** check present.

## Task 5: CHANGELOG + intake status + archive
- CHANGELOG entry under [Unreleased] Changed + Fixed.
- Intake capture frontmatter updated: status promoted.
- Archive proposal post-bookend.
