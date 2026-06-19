---
slug: target-upgrade-gate-and-runbook
status: archived
since: 2026-06-19
archived-at: 2026-06-19
---

# Vocal upgrade-required gate + turnkey full-upgrade runbook

## What

Replace the harness-update propagation mechanism's "signal only" posture with a
two-part mechanism that makes a stale target's upgrade (a) impossible to miss at
session-init and (b) reliable to complete end-to-end:

- **(A) Vocal upgrade-required gate.** When a target's `harness-sync-sha` is
  behind the harness HEAD (or absent), the `target-orchestrator` surfaces a
  prominent multi-line `UPGRADE REQUIRED` block as the FIRST thing after the
  banner -- not a soft one-line "say 'review changes'" nudge. The block states
  the target is N commits behind, that code work should not start until the
  target is upgraded, and points at the single turnkey runbook. The "signal
  only" framing is retired everywhere it is stated (the orchestrator persona's
  propagation section, its session-init step, the CLAUDE.md propagation bullet,
  and the mirrors in the health-check playbook and the `target-aeh-reviewer`
  persona) so the new doctrine is coherent across the harness.

- **(B) Turnkey full-upgrade runbook.** A new `upgrade` playbook
  (`templates/playbooks/upgrade.md`) gives the operator one ordered,
  self-verifying sequence that takes a stale target all the way to current. Each
  step is driven by the orchestrator via a dispatched target-side prompt and
  carries a hard verification gate; the terminal state is an explicit "UPGRADE
  COMPLETE" with the marker bumped to the synced HEAD and the AEH-practice check
  clean. The existing `review changes` assess-and-decide loop folds IN as one
  step (the operator-gated behavioural-retrofit step), rather than being the
  whole mechanism.

The gate (A) points at the runbook (B); together: launch -> loud gate -> one
runbook -> reliable, self-verified completion.

## Why

The shipped propagation mechanism is deliberately "a signal only" -- a one-line
post-banner nudge that kicks off a judgment-heavy assess-and-decide loop. That
fails on two counts. First, it is not vocal: a single quiet line is easy to skip
past, so a target can keep taking code work while running stale harness
artifacts. Second, it is not a reliable all-the-way-through procedure: "review
changes" starts an open-ended Propagation-Impact assessment, but there is no
single canonical runbook that drives a stale target to current and verifies it
got there. The two failures compound -- a quiet signal pointing at an open-ended
loop is the weakest possible nudge for the most consequential maintenance event
(adopting upstream harness changes).

The propagation event is exactly when a target's AEH practice can silently
diverge from the harness: snapshots drift, the target's `CLAUDE.md` falls behind
the template, new conventions go unobserved. A loud gate plus a self-verifying
runbook turns "the operator might notice and might assemble the right steps" into
"the operator cannot miss it and runs one procedure that proves completion."

## Scope

In scope:

- **target-orchestrator persona** (`templates/personas/target-orchestrator.md`):
  rewrite "Harness Update Propagation Signal" -> a vocal UPGRADE-REQUIRED gate;
  retire the "signal only" framing and the soft one-line wording in the section
  intro, the session-init detection block, and the session-init step 5; point the
  gate at the new `upgrade` playbook; keep the detection itself read-only and
  cheap. Add the `upgrade` mode to the persona's mode list where modes are
  enumerated.
- **upgrade playbook** (NEW `templates/playbooks/upgrade.md`): the ordered,
  self-verifying full-upgrade runbook (5 steps, each with a hard gate; terminal
  UPGRADE COMPLETE state; marker bump).
- **CLAUDE.md** (harness): update the propagation bullet to the gate-plus-runbook
  doctrine; add `upgrade` to the Playbooks table and the natural-language
  Commands table.
- **health-check playbook** (`templates/playbooks/health-check.md`): align the
  `harness-sync-sha` presence wording with the new gate doctrine (a missing or
  stale marker is an upgrade trigger, not just a LOW finding).
- **target-aeh-reviewer persona**
  (`templates/personas/target-aeh-reviewer.md`): align the Propagation-Impact
  Assessment Mode framing so it reads as one folded-in step of the upgrade
  runbook, not the whole mechanism.
- **prompt-template mirrors**: `templates/prompts/refresh-base-personas.md.template`
  (the "propagation-signal philosophy" line -> gate-plus-runbook, noting it is the
  runbook's Step 1) and `templates/prompts/seed-harness-sync-marker.md.template`
  (the "surface the signal" / "say 'review changes'" expected-outcome wording ->
  UPGRADE REQUIRED gate + `upgrade` runbook).
- **onboarding playbook** (`templates/playbooks/onboarding.md`): repoint the two
  `§ "Harness Update Propagation Signal"` references to the renamed section
  `§ "Harness Update Propagation Gate"` (subtraction-completeness of the rename).
- **CHANGELOG** [Unreleased] entry.

Out of scope:

- The per-target private `targets/<slug>/` state (sync markers, UPGRADE-DUE
  records, index updates). That is target-specific (private repo) and is applied
  directly as part of the same sweep, NOT through this public proposal.
- Executing the in-target upgrades themselves. The runbook is the procedure; each
  target runs it later in its own orchestrator/target session.
- The concrete release/versioning mechanism design (release-notes log format,
  breaking-change flagging) -- still deferred to the public-repo-owner
  conversation; this proposal does not depend on it.
- Auto-application of retrofits. Every behavioural retrofit stays operator-gated;
  the runbook drives the sequence but the operator approves the judgment step.

## Acceptance criteria

- Launching the `target-orchestrator` against a target whose `harness-sync-sha`
  is behind HEAD surfaces a prominent multi-line `UPGRADE REQUIRED` block as the
  first post-banner output, naming the commit delta and pointing at the `upgrade`
  runbook. The missing-marker case is equally vocal.
- No surviving reference to the propagation mechanism as a "signal only" or to
  the soft one-line "say 'review changes'" wording in the orchestrator persona,
  CLAUDE.md, the health-check playbook, or the target-aeh-reviewer persona.
- `templates/playbooks/upgrade.md` exists, is wired into the CLAUDE.md Playbooks
  table and Commands table, and is pointed at by the gate in the orchestrator
  persona. It is an ordered sequence with a hard verification gate per step and
  an explicit terminal UPGRADE COMPLETE state (marker bumped + aeh-practice-check
  clean).
- The runbook is target-detail-free and name-free (it ships public).
- Publication gate passes (`--staged` + `--message`); harness-reviewer bookend
  APPROVE / APPROVE-WITH-MINOR before close-out.
