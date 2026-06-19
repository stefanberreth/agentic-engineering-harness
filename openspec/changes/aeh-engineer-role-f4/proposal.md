---
slug: aeh-engineer-role-f4
status: in-progress
since: 2026-06-19
parent: aeh-engineer-role
build-step: F4
---

# F4: decide the orchestrator-state.md filename honestly

> Fourth follow-on to the B1-B7 rebuild. B5 renamed the ROLE token
> `orchestrator` -> `target-orchestrator` everywhere but kept the artifact filename
> `orchestrator-state.md`, apologising for it in three proposals. F4 stops the
> half-measure by committing to ONE answer and recording it as a settled exception.

## What

Choose option (b) from the run prompt and commit: KEEP `orchestrator-state.md`
(and `orchestrator-batch-regime.md`) and add ONE settled-exception note in
`CLAUDE.md` next to the marker-value back-compat note, so future harness-reviewer
passes stop re-flagging the filename.

## Why this option (not the rename)

The retrospective floated renaming the file and "leaning on `target-aeh-engineer`
to migrate existing targets." That migration path does not actually exist:
`orchestrator-state.md` lives in the harness-side private workspace
`targets/<slug>/`, NOT in the target tree, and `target-aeh-engineer` is fenced to
the target tree -- it cannot touch `targets/<slug>/`. A rename would instead
require sweeping ~8 live files (CLAUDE.md, both playbooks, the target-orchestrator
persona, two governance files, two prompt templates) PLUS a bespoke harness-side
retrofit over every existing target's private state file, for zero behavioural
gain. The filename is a stable label, not a role assertion. So (b) is the honest,
cheap, correct call; the half-measure (keep it but apologise for it repeatedly) is
what F4 ends.

## Scope

In scope: the one settled-exception note in CLAUDE.md.

Out of scope: any rename (explicitly rejected); touching the ~8 files that
reference the filename.

## Acceptance criteria

1. CLAUDE.md carries a settled-exception note for `orchestrator-state.md` /
   `orchestrator-batch-regime.md` instructing reviewers not to re-flag them.
2. No rename performed.
3. Validator + publication gate pass; F4 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- The rename that kept the filename: B5
  (`openspec/changes/aeh-engineer-role-b5/`).
- Rationale: `retrospective-b1-b7.md` ("the half-measure ... is the worst of
  both") -- F4 resolves it toward keep-and-settle once the rename's true cost
  (and the non-existence of the cited migration path) is visible.
