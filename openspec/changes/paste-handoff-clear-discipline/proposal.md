---
slug: paste-handoff-clear-discipline
status: proposed
since: 2026-06-01
intake: openspec/changes/_intake/2026-05-31-1820-clear-instructions-explicit-discipline-0c37120ebcd6.md
---

# Paste-handoff explicit /clear-or-not declaration

## What

Hard rule in the orchestrator persona: every paste handoff carries an explicit /clear-or-not statement with one-line reason, positioned above the paste block. Default stays "preserve"; the rule operationalises surfacing the (default-preserve, sometimes-clear) judgment, not clearing more often. Include a small calibration matrix inline in the persona for both the agent and operators reading it.

## Why

The orchestrator persona has the calibration logic internally (clear when continuity hurts, preserve otherwise) but does not mandate that the decision be made visible. Result: the operator is left guessing per-paste, and inconsistent guidance across consecutive handoffs erodes trust. The discipline already exists in operator memory (`feedback_clear_context_on_role_switch`, `feedback_handoff_step_order`); this proposal lifts it from memory to template so it stops being an inferred rule.

Reinforced by this session 2026-06-01: orchestrator suggested /clear without stating the reason, operator pushed back ("Why do you need a /clear? You should be in the orchestrator role and stay in there. If you deem your own context polluted and required clear and re-initialisation, that's fair. But then state it."). Same defect class.

## Scope

In scope:
- `templates/personas/orchestrator.md` § "Paste-Handoff /clear Discipline" -- hard rule: every paste handoff carries an explicit /clear-or-not statement with one-line reason, positioned above the paste block. Applies symmetrically to "recommend clear" AND "recommend preserve" -- silent omission is the failure mode.
- Inline calibration matrix in the same section (situation -> /clear default).
- Cross-reference operator memory entries for traceability.
- Optional memory addition to `feedback_clear_context_on_role_switch`: one-line addition about silent-omission being the failure mode (operator's existing memory; lift discipline-side, leave memory addition to operator).
- CHANGELOG entry under [Unreleased] Changed.

Out of scope:
- Auto-clear mechanism (the rule is about transparency, not behaviour change).
- Changing the default judgment (preserve stays the default).

## Acceptance criteria

1. Hard rule landed in orchestrator persona with explicit-statement-above-paste requirement.
2. Calibration matrix present.
3. Cross-references to operator memory entries.
4. CHANGELOG entry.
5. Intake capture status updated to promoted.

## References

- Intake: `openspec/changes/_intake/2026-05-31-1820-clear-instructions-explicit-discipline-0c37120ebcd6.md`
- Memory: `feedback_clear_context_on_role_switch`, `feedback_handoff_step_order`
