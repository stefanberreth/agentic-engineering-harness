---
slug: orchestrator-end-state-vocabulary-v2
---

# Tasks: Orchestrator Response End-State Vocabulary v2

## Task 1: Update orchestrator persona template Report-Back / end-state section
- `templates/personas/orchestrator.md`: locate the response end-state convention section. Replace the 3-state list (`DONE | DECISION-NEEDED | NEXT-STEP-CLEAR`) with the 4-state list (`DONE | DECISION-NEEDED | MONITORING-BACKGROUND | PAUSED-ON-YOUR-WORK`). Add one-line definitions for each state and the choice-vs-result rule-of-thumb for the two operator-action states.
- **Mechanical signal:** `grep -c "MONITORING-BACKGROUND\|PAUSED-ON-YOUR-WORK" templates/personas/orchestrator.md` returns >= 2.

## Task 2: Update operator memory file
- Path: `~/.claude/projects/-workspace-aeh/memory/feedback_orchestrator_response_end_state.md` (resolved relative to the operating environment).
- Replace the 3-state list with the 4-state list. Preserve the "no other states" closing-discipline rule. Add the choice-vs-result rule-of-thumb.
- **Mechanical signal:** `grep -c "MONITORING-BACKGROUND" feedback_orchestrator_response_end_state.md` returns >= 1.

## Task 3: CHANGELOG entry
- Add an entry under [Unreleased] Changed summarising the vocabulary shift and the operator-experience rationale.
- **Mechanical signal:** `grep -c "MONITORING-BACKGROUND" CHANGELOG.md` returns >= 1 in an Unreleased entry.

## Task 4: Archive after implementation
- Move `openspec/changes/orchestrator-end-state-vocabulary-v2/` to `openspec/changes/archive/orchestrator-end-state-vocabulary-v2/` once Tasks 1-3 are complete and harness-reviewer bookend has passed.
- **Mechanical signal:** `test -d openspec/changes/archive/orchestrator-end-state-vocabulary-v2` returns zero.
