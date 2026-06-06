---
slug: reviewer-over-engineering-and-adversarial-stance
status: ready-for-archive
since: 2026-06-06
---

# Reviewer quality: an over-engineering scrutiny dimension, an elite-adversarial stance, and the simplicity angle in the retrospectives

## What

The reviewer-quality half of the retrospective-convention capture (items 3-5; items 1-2 shipped as `retrospective-elicitation-convention`). Three additions plus one registration:

- **Reviewer over-engineering dimension (item 4).** `reviewer.md` §2 gains an "Over-Engineering & LLM-Typical Waste" dimension -- the inverse of the Absence Check -- tuned to the waste patterns characteristic of LLM-generated code (speculative abstraction, defensive-check sprawl, duplicated logic, reinvented helpers, prolific small files, state passed back and forth, premature generality). Findings are non-blocking simplification suggestions by default, blocking only when the over-build creates real maintenance/bug/security surface. A new `over_engineering` verdict category and a mirror Principles bullet ("check for what's over-built, not just what's missing") make it reportable and durable.
- **Elite-adversarial reviewer characterisation (item 5).** `reviewer.md` "What You Are" reframes the reviewer as a top-calibre, adversarial reviewer whose default stance is to assume there IS a flaw and hunt it -- adversarial toward the artifact, never the author, applied with taste (rigour and a feel for simplicity, never arrogance or nitpicking). This carries the authority to insist on the simpler solution at the gate.
- **Simplicity angle in the retrospectives (item 3, assessed then applied).** Assessment: the developer §7 and reviewer Retrospective Evaluation guidance was already sound, so it was sharpened, not rewritten -- the developer retrospective now asks the explicit "could this have been substantially simpler?" question; the reviewer's Retrospective Evaluation now surfaces and routes any developer simplicity insight and cross-checks it against the new Over-Engineering dimension.
- **Registration (addition-completeness hygiene).** `harness-reviewer.md` Dimension 6 reviewer-structural-dimensions list registers the over-engineering dimension + adversarial stance, so a future harness-review verifies they persist.

## Why

The simplicity value the harness cares about -- "delete two rows, not five hundred lines in fifteen places" -- was only caught inside-out, by the doer in hindsight. The reviewer sits at the gate with fresh, adversarial distance the implementer structurally lacks: exactly the vantage to catch over-engineering the doer is too close to see, and the place where simplification gains traction instead of evaporating. The reviewer had a dependency-necessity check, an absence check, and a detritus check, but no first-class "is this over-built / could it be substantially simpler" dimension, and its character framing did not carry the standard-bearer authority needed to hold the line on the simpler solution. This adds the outside-in complement to the doers' inside-out hindsight: same simplicity goal, an independent adversarial angle. Architect captures it at the origin (design), the doer in hindsight, the reviewer at the gate.

## Scope

In scope: `reviewer.md` (over-engineering dimension + verdict category + adversarial "What You Are" + Retrospective-Evaluation sharpening + Principles bullet); `developer.md` §7 simplicity sharpening; `harness-reviewer.md` Dimension 6 registration; CHANGELOG; close the `_intake` capture (items 3-5 done; 1-2 already done).

Out of scope: a deterministic over-engineering linter (it is a judgment dimension); changing the existing dependency-necessity or detritus checks (they stand; the new dimension complements them).

## Acceptance criteria

1. `reviewer.md` §2 carries the Over-Engineering & LLM-Typical-Waste dimension with the LLM-waste pattern list and the non-blocking-by-default / blocking-on-real-surface severity rule.
2. The reviewer is characterised as elite and adversarial-toward-the-artifact (not the author).
3. The developer §7 and reviewer Retrospective-Evaluation carry the explicit simplicity question (sharpened, existing guidance preserved).
4. A reportable `over_engineering` verdict category exists; a mirror Principles bullet exists; `harness-reviewer.md` registers the dimension.
5. CHANGELOG entry present; the `_intake` capture is fully closed (all 5 items dispositioned).

## References

- Inbox capture: `_intake/2026-06-05-1907-retrospective-convention-architect-and-orchestrator-elicitation-*` (items 3-5; items 1-2 shipped under `retrospective-elicitation-convention`).
- Sibling this session: `retrospective-elicitation-convention` (architect retrospective + orchestrator elicitation).
- Existing reviewer dimensions complemented: Absence Check, dependency-necessity, detritus/leftover-file check.
