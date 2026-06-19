---
slug: dogfooding-harness-feedback-channel
status: ready-for-archive
since: 2026-06-19
---

# Standing harness-feedback (dogfooding) channel in dispatched prompts

## What

Add a lightweight, standing upstream channel so that an agent executing a dispatched
prompt inside a target can reliably surface harness-improvement signals -- and so the
coordinating session reliably harvests them -- instead of relying on the executing
agent to volunteer them in free-text asides.

Three small, coordinated additions:

1. **Prompt-file format (`CLAUDE.md` "Prompt File Format" + the prompt templates):**
   a standard, lightweight "Harness feedback (dogfooding)" framing block + a dedicated
   `HARNESS FEEDBACK` report-back field. Framing: the AEH artifacts you are loading and
   running are UNDER TEST; report the classes of "did not land flawlessly" (a dangling
   harness-path reference, a misfiring check, a role file that assumes something untrue
   in-target, an ambiguous step); keep these SEPARATE from target findings; STOP rather
   than silently work around a blocking harness defect; "none -- landed as written" is a
   valid answer. Apply to AEH-practice / retrofit / propagation prompts at minimum;
   consider for all role-bound prompts.

2. **`target-orchestrator` persona:** a standing discipline -- scan every report-back's
   `HARNESS FEEDBACK` field and proactively capture (operator-gated, via the existing
   Harness Capture protocol) any item that is a harness-level signal. Make "applying AEH
   to a target is also dogfooding the harness" an explicit lens.

3. **`target-aeh-reviewer` persona:** name a "dogfooding feedback" detection dimension --
   harvesting AEH improvement signals from the target's lived experience of the harness
   is squarely a detect role's job.

## Why

The harness has a strong capture-and-flag philosophy, and the universal capture right
lets any session write a capture. But the SOURCE of many of the best signals is the
agent running a dispatched prompt inside a target -- the first to hit a harness artifact
that does not land flawlessly. Nothing in the prompt-file format or the target-applied
personas currently tells that agent to treat the artifacts it loads as under test, to
separate harness-improvement signals from target defects, to STOP rather than work
around a blocking harness defect, or to report them in a dedicated field. Today those
signals survive only when the executing agent is generous enough to volunteer them; the
coordinating side has no standing "harvest the harness-feedback field" step. The result
is reliance on agent initiative -- fragile, and it loses exactly the field-test data that
makes the harness better.

This is the upstream (target -> harness) symmetric partner to the propagation signal
(harness -> target): the harness already pushes updates down to targets; this is how the
target's lived experience flows back up.

## Scope

In scope:
- The "Harness feedback (dogfooding)" block + `HARNESS FEEDBACK` report-back field in the
  prompt-file format and the dispatched-prompt templates.
- The `target-orchestrator` harvest-and-capture discipline.
- The `target-aeh-reviewer` dogfooding-feedback detection dimension.
- CHANGELOG entry.

Out of scope:
- A heavy mechanism. Keep it to a small block + one report-back field + one coordinator
  habit + one reviewer dimension.
- Who FIXES a surfaced signal (that is unchanged: capture -> aeh-engineer triage ->
  proposal). This change is about WHERE the signal originates and HOW it is reliably
  surfaced and harvested, not remediation ownership.
- Changing the capture protocol itself (it is reused as-is).

## Acceptance criteria

1. The prompt-file format documents the dogfooding framing block and the
   `HARNESS FEEDBACK` report-back field; the dispatched-prompt templates carry both.
2. `target-orchestrator` carries the harvest-from-every-report-back + operator-gated
   capture discipline.
3. `target-aeh-reviewer` names the dogfooding-feedback detection dimension.
4. "none -- landed as written" is documented as a valid `HARNESS FEEDBACK` value, and
   "STOP if blocked by a harness defect" is explicit.
5. CHANGELOG entry; validator + publication gate pass; harness-reviewer bookend.

## References

- The symmetric downstream mechanism: `openspec/changes/harness-update-propagation-signal/`.
- The capture protocol reused here: the harness capture inbox
  (`openspec/changes/harness-capture-inbox/`, amended by `intake-private-relocation`).
- Provenance: private intake capture (2026-06-19), surfaced while driving a real
  harness-update propagation/retrofit through several dispatched role-bound prompts;
  sanitized at promotion.
