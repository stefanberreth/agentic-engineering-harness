---
slug: retrospective-elicitation-convention
status: archived
archived-at: 2026-06-19T18:48:01Z
since: 2026-06-06
---

# Retrospective elicitation: architect writes its own hindsight retrospective; orchestrator owns eliciting them

## What

Two layer-distinct additions that make the existing hindsight-retrospective convention fire reliably instead of only when someone remembers to ask:

- **architect** (target base template, new "Design Retrospective" subsection): after a design is done, the architect writes a short hindsight retrospective focused on **design simplicity** -- "knowing what I know now, could this have been radically simpler: fewer moving parts, fewer files touched, less state passed around?" Mirrors the developer's §7 retrospective, but aimed at the design SHAPE, because over-engineering originates at design.
- **orchestrator** (harness-side role, new Principle + behaviour): the orchestrator explicitly owns ELICITING hindsight retrospectives from the target agents it dispatches -- it builds the retrospective ask (with the simplicity framing) into the report-back of substantive prompts, rather than trusting the target persona's own end-of-task retrospective to fire (on tactical/ops/investigation prompts it often does not).

No new mechanism. The retrospective files and the developer/reviewer retrospective conventions are unchanged.

## Why

Addition-by-default has a sibling failure: the most valuable reflection -- "in hindsight this could have been two deleted rows, not five hundred new lines in fifteen places" -- only surfaces AFTER the work is done, and only if someone runs the retrospective. The convention exists in the developer and reviewer personas, but (a) the architect, who chooses the solution shape and is therefore the origin of most over-engineering, never writes one, and (b) nothing actively elicits retrospectives, so on non-standard prompts they silently do not happen. The motivating instance is immediate: in the orchestrator-state-consolidation session the operator had to explicitly request the closing retrospective; it was not offered.

This wires the elicitation half of the convention. It is deliberately scoped to retrospective elicitation only.

## Scope

In scope:

- architect base template: a "Design Retrospective" subsection (simplicity-focused, mirrors developer §7), routed to `docs/AE/reports/`.
- orchestrator role: an explicit elicitation Principle + the report-back-ask behaviour, carrying the simplicity framing.
- CHANGELOG [Unreleased] entry.
- A partial-triage note on the originating `_intake` capture.

Out of scope (same `_intake` capture, deliberately NOT bundled -- decouple discipline; these are a separate reviewer-quality thread, not retrospective elicitation):

- Sharpening the developer + reviewer retrospective questions toward the explicit simplicity angle (the capture asks for an assessment first, not a blind edit).
- A first-class reviewer over-engineering / LLM-typical-waste scrutiny DIMENSION.
- Re-characterising the reviewer as an elite adversarial (top-0.1%) reviewer.

These three remain in the `_intake` capture for a separate proposal.

## Layer note (kept clean deliberately)

`architect.md` is a target base template; its retrospective is the target architect reflecting on the target's design. `orchestrator.md` is a harness-side role; its elicitation is directed at the target agents it dispatches. The two must not cross-reference each other's constructs -- the target architect does not know the harness orchestrator exists.

## Acceptance criteria

1. architect carries a simplicity-focused Design Retrospective subsection mirroring the developer §7 format.
2. orchestrator carries an explicit retrospective-elicitation responsibility with the simplicity framing, applied via prompt report-backs.
3. No cross-layer reference between the two additions.
4. CHANGELOG [Unreleased] entry present; `_intake` capture annotated as partially triaged.

## References

- Inbox capture: `_intake/2026-06-05-1907-retrospective-convention-architect-and-orchestrator-elicitation-*` (items 1 and 2; items 3-5 deferred).
- Motivating instance: orchestrator-state-consolidation session, 2026-06-06 (operator had to request the closing retrospective).
- Existing convention mirrored: developer §7 Retrospective Report; reviewer Retrospective Evaluation.
- Value framing memory: orchestrator actively elicits retrospectives; core value is surfacing the simpler-in-hindsight solution.
