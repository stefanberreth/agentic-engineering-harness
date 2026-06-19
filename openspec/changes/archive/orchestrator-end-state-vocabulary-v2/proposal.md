---
slug: orchestrator-end-state-vocabulary-v2
status: archived
archived-at: 2026-06-19T19:18:24Z
since: 2026-05-31
provenance: openspec/changes/orchestrator-end-state-vocabulary-v2/provenance.md
---

# Orchestrator Response End-State Vocabulary v2 (4-state)

## What

Expand the orchestrator persona's response end-state convention from the current 3-state vocabulary (`DONE | DECISION-NEEDED | NEXT-STEP-CLEAR`) to a 4-state vocabulary that cleanly separates two distinct ticking-clock cases:

```
DONE | DECISION-NEEDED | MONITORING-BACKGROUND | PAUSED-ON-YOUR-WORK
```

## Why

The 3-state vocabulary collapses two operator-relevant states into the catch-all `NEXT-STEP-CLEAR`. In practice, every operator response needs to communicate two facts simultaneously: (1) is the clock ticking somewhere, and (2) on whose side. The current vocabulary handles the no-clock-ticking cases (`DONE`, `DECISION-NEEDED`) but conflates the clock-ticking cases:

- A chain wrapper or scheduled wakeup running off-screen (operator can walk away; orchestrator owns the clock).
- An off-screen operator action whose result the orchestrator is idle waiting for (operator owns the clock; orchestrator is parked).

Both today get reported as `NEXT-STEP-CLEAR` (or sometimes `DONE` with a note), losing useful signal about who owns the next move. The v2 vocabulary makes the two cases distinct and self-explanatory.

The semantic distinction between `DECISION-NEEDED` and `PAUSED-ON-YOUR-WORK` is also worth noting: the first needs a *choice* from the operator, the second needs a *result* the operator produces off-screen. Different operator actions, different "what happens next" expectations -- the labels make the difference visible.

## Scope

In scope:
- Update `templates/personas/orchestrator.md` Report-Back / response end-state discipline section: replace the 3-state list with the 4-state list, include one-line definitions, include a short rule-of-thumb for `DECISION-NEEDED` vs `PAUSED-ON-YOUR-WORK`.
- Update operator memory `feedback_orchestrator_response_end_state.md` from 3-state to 4-state, preserving the "no other states" closing-discipline rule.
- CHANGELOG entry under [Unreleased] Changed.

Out of scope:
- Backfilling past responses to the new vocabulary. The change applies going forward.
- Tooling that detects/enforces end-state labels in responses. Convention-only, enforced by the orchestrator persona, not by automation.

## Acceptance criteria

1. **Template updated**: `templates/personas/orchestrator.md` Report-Back section names all four states with one-line definitions and the choice-vs-result rule-of-thumb.
2. **Memory updated**: `feedback_orchestrator_response_end_state.md` carries the 4-state list and the rule-of-thumb; the "no other states" discipline is preserved.
3. **CHANGELOG entry**: under [Unreleased] Changed, summarising the vocabulary shift and the operator-experience rationale.
4. **First worked use**: this proposal's own response (and subsequent orchestrator responses in the same session) close with one of the four new states, exercising the convention.

## Definitions (the four states)

- **DONE** -- nothing pending anywhere. No clock ticking, no operator action queued, no orchestrator action queued.
- **DECISION-NEEDED** -- orchestrator is blocked on a choice from the operator. The operator's next action is a decision.
- **MONITORING-BACKGROUND** -- a chain wrapper, scheduled wakeup, autonomous loop, or other off-screen process owned by the orchestrator side is running. The operator can walk away; the clock is ticking on the orchestrator's side.
- **PAUSED-ON-YOUR-WORK** -- the operator has an off-screen action to perform (manual auth, side work, anything where the orchestrator is idle until the operator returns with a result). The clock is ticking on the operator's side; the orchestrator is parked.

Rule of thumb for the two operator-action states: `DECISION-NEEDED` needs a *choice*; `PAUSED-ON-YOUR-WORK` needs a *result*.

## References

- Provenance: `openspec/changes/orchestrator-end-state-vocabulary-v2/provenance.md` (the original inbox capture).
- Inbox mechanism that surfaced this proposal: `openspec/changes/harness-capture-inbox/`.
- Existing 3-state memory being superseded: `feedback_orchestrator_response_end_state.md`.
