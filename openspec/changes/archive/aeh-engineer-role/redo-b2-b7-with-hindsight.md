# Redo handoff: B2-B7 with hindsight (targeted follow-ons, NOT a rebuild)

> **Honest bottom line first.** A full re-implementation of B2-B7 is NOT worth it.
> The built version (commits 9729563, 0315095, e6a91e6, 2cea889, a5f09f1, bb0a175)
> is coherent, the architecture is right, and the residual scan + validator pass.
> Re-running from scratch would re-litigate correct, settled decisions. The
> hindsight value is four BOUNDED follow-on changes ON TOP of what is built -- not a
> redo. This prompt specifies exactly those, so the operator can pick them up
> cheaply (or decline) without touching the rest. Full reasoning:
> `retrospective-b1-b7.md`.

You are in the AEH harness root (`/workspace/aeh`), running as `aeh-engineer`.
These are independent; do them in any order, each its own OpenSpec change +
commit, publication-gated, no push until the operator authorises.

## F1 (highest value) -- deliver the target-applied artifacts INTO the target

**Problem:** B3 and B4 authored `target-aeh-reviewer.md`, `target-aeh-engineer.md`,
and `bin/aeh-practice-check.sh` -- all of which RUN in a target -- but nothing
places them there. They are inert until the scaffold delivers them.

**Change:**
- Extend `templates/playbooks/onboarding.md` Phase 2 base-template-placement (and
  the greenfield short-circuit) to ALSO place `target-aeh-reviewer.md`,
  `target-aeh-engineer.md`, and `aeh-practice-check.sh` into the target
  (`docs/AE/personas/_base/` for the two roles -- or a sibling `docs/AE/roles/` if
  you prefer to keep `_base/` as the five engineering personas; `docs/AE/bin/` or
  the target's own `bin/` for the script). Decide the home and wire it.
- Extend `templates/prompts/refresh-base-personas.md.template` to also refresh
  these two roles + the script (or add a sibling refresh prompt for the
  target-applied AEH roles).
- Update the deterministic check / health-check so the script is invoked at its
  delivered target-side path, not a harness path.
- Acceptance: a fresh onboarded target can load `target-aeh-reviewer` and run
  `aeh-practice-check.sh .` with zero harness access.

**Why it matters most:** without this, B3+B4 are paper. This is the difference
between "the roles exist" and "the roles work."

## F2 -- thin the B7 role-location signature to one-line pointers

**Problem:** the role-location signature is fully restated in ~11 places
(CLAUDE.md, CLAUDE.md.template, 5 engineering base personas, the harness personas).
The five base-persona `## §0` blocks are near-identical full copies that will
drift -- the additive ratchet the `aeh-engineer` is supposed to fight.

**Change:**
- Keep the canonical definition in `CLAUDE.md` (harness layer) and
  `templates/project/CLAUDE.md.template` (target layer).
- Replace each engineering base persona's full `## §0` block with a ONE-LINE
  pointer: "Step 0: run the role-location self-check in your project's `CLAUDE.md`
  § 'Role-location self-check' (assert: target tree, NOT the AEH root); loud-halt
  on mismatch." Same for the harness personas pointing at the harness CLAUDE.md.
- Acceptance: the three-part signature text appears in exactly TWO places (the two
  CLAUDE.md layers); everything else is a pointer.

## F3 -- establish the prompt->result pairing convention behind B4's flagship check

**Problem:** B4's `prompt-result-pairing` check SKIPs on every real target because
no persona yet GUARANTEES a paired, committed result file per dispatched prompt.
The police shipped before the law.

**Change:**
- Add to the `developer` (and/or `target-orchestrator`) persona a definition-of-done
  line: every dispatched prompt `docs/AE/prompts/NNN-title.md` gets a paired,
  committed result `docs/AE/reports/NNN-title.md` (short structured handover: what
  was done, what changed, gate pass/fail, wall-clock, commit pointer), written by
  the executing role and routed back by the coordinator.
- Keep it lightweight (a short handover, not a ceremony).
- Acceptance: the convention is stated where the executing role will read it, so
  `aeh-practice-check.sh`'s pairing check has something to verify on a real target.

## F4 (optional) -- decide the orchestrator-state.md filename honestly

**Problem:** the role is `target-orchestrator` but its state artifact is
`orchestrator-state.md` -- a small permanent inconsistency. B5 kept it citing
migration churn, but B3 built `target-aeh-engineer`, whose job IS applying such
renames to a target. So the migration path now exists.

**Change (pick one and commit to it):**
- (a) Rename the artifact to `target-orchestrator-state.md` across the live
  templates + ship a one-line retrofit that `target-aeh-engineer` applies to
  existing targets; OR
- (b) Keep `orchestrator-state.md` and add ONE settled note (in CLAUDE.md near the
  rename back-compat note) that the filename is a deliberate stable exception, so
  future harness-reviewer passes stop re-flagging it.
- Either is fine; the point is to stop the half-measure (kept, but apologised for
  in three proposals).

## What NOT to redo

- The detect/remediate matrix, the taxonomy, the fence, B5-last sequencing, the
  freestyle-label fold, the lean B4 framework, the explicit design-call surfacing
  -- all correct. Leave them.
- Do not re-run the rename. It is clean.

## If the operator declines all four

The built B1-B7 is publication-ready as a coherent whole EXCEPT that F1 leaves the
target-applied roles non-operational. If only ONE follow-on is done, it must be F1
-- otherwise the rebuild ships two roles and a script that no target can use.
