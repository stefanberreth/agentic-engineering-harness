# Design -- vocal upgrade gate + turnkey upgrade runbook

## The two failures being fixed

The shipped mechanism couples a weak detector to an open-ended response:

1. **Detector is quiet.** Session-init surfaces one post-banner line ("Harness
   has advanced N commits since last sync. Say 'review changes'..."). One line
   among the banner output is easy to skip. The most consequential maintenance
   event gets the least prominent surfacing.
2. **Response is open-ended.** `review changes` dispatches a Propagation-Impact
   assessment that produces a retrofit-action LIST the operator adjudicates
   per-action. There is no canonical end-to-end procedure that drives a stale
   target to current and proves it arrived. The assessment is a good DIAGNOSIS
   step but it is not a runbook.

The fix keeps the cheap read-only detector but (A) makes its output a loud gate
and (B) gives the operator one ordered procedure with the assessment folded in as
one step.

## (A) The gate -- shape and placement

The detection stays exactly as cheap (two git commands already in session-init
step 5: `rev-parse HEAD`, `rev-list --count $sync..HEAD`). Only the OUTPUT
changes. When behind (or marker absent), the orchestrator emits, as the FIRST
post-banner output, a block of this shape:

```
=== UPGRADE REQUIRED -- <slug> is N commits behind the harness (<sync>..<HEAD>) ===
Do NOT start code work on this target until it is upgraded.
To upgrade now: say "upgrade" (drives templates/playbooks/upgrade.md end-to-end).
You may defer explicitly, but the default posture is upgrade-first.
```

Missing-marker variant: `=== UPGRADE REQUIRED -- <slug> has never recorded a
harness sync ===` with the same do-not-start-code-work line and the same runbook
pointer, plus "seed the marker as part of the upgrade run."

Design choices:

- **First, not buried.** The block is the first thing after the banner so it
  cannot be skipped under the banner output.
- **Default posture stated.** "Upgrade first" is the default; deferral is
  explicit and operator-chosen, never the silent path.
- **Single pointer.** The gate names exactly one response (`upgrade`), removing
  the "which of several things do I do?" ambiguity of the old `review changes`
  loop.
- **Detection unchanged.** No diff-classification or heavy work enters
  session-init; the gate is a formatting/prominence change over the same cheap
  compare.

## (B) The runbook -- ordered, gated, self-verifying

A new `upgrade` playbook drives the full sequence. The orchestrator runs it the
same way it runs onboarding/health: it dispatches target-side prompts and
consumes report-backs; it does not reach into the target tree. Five steps, each
with a hard verification gate:

1. **Refresh AEH snapshots target-side.** Dispatch
   `templates/prompts/refresh-base-personas.md.template` (5 base personas + 2
   target-applied roles + `docs/AE/bin/aeh-practice-check.sh`). **Gate:**
   every artifact byte-identical to harness master (the template already does
   `cmp` per file and reports match/no-match).
2. **Uplift the target's `CLAUDE.md`.** WHOLE-BLOCK diff per region against the
   current `templates/project/CLAUDE.md.template`, applied in ONE pass (per the
   claude-md-size-discipline whole-block rule -- session-init siblings are
   interdependent). **Gate:** no stale or self-contradicting session-init block
   remains; `aeh-practice-check.sh`'s `claude-md-size` check does not regress.
3. **Behavioural-retrofit pass (operator-gated).** This is where the existing
   `review changes` Propagation-Impact assessment folds IN as ONE step: dispatch
   `target-aeh-reviewer` in Propagation-Impact Assessment Mode with the
   `$sync..HEAD` range + CHANGELOG diff; operator adjudicates the retrofit-action
   list; `target-aeh-engineer` applies approved actions. **Gate:** every action
   is apply/defer/skip-resolved (no action left unadjudicated).
4. **Seed `.prompt-pairing-since` if pre-convention + drive the check clean.**
   If the target predates the one-prompt-one-report (F3) pairing convention,
   seed `docs/AE/.prompt-pairing-since`; then run
   `docs/AE/bin/aeh-practice-check.sh .` and resolve findings. **Completion
   gate: PASS/WARN only, zero FAIL.**
5. **Confirm role activation + bump the marker.** Confirm a role-bound prompt
   activates correctly target-side (the refreshed roles load from
   `docs/AE/roles/`). **Final gate:** bump `harness-sync-sha` in
   `targets/<slug>/profile.md` to the HEAD just synced to; the terminal state is
   an explicit `UPGRADE COMPLETE -- synced to <HEAD>, aeh-practice-check clean,
   ready for code work`, after which the gate in (A) stops firing.

### Why a playbook (ESTABLISH, not RESPECT/CONSOLIDATE)

Ground-truth scan: `templates/playbooks/` holds the three guided workflows
(`onboarding`, `health-check`, `tools`), each a `<command>` the operator says in
natural language and wired into the CLAUDE.md Playbooks + Commands tables. A
full-upgrade procedure is the same content class -- an operator-triggered,
multi-step, gated workflow the orchestrator drives. No existing file holds it
("review changes" is a persona section that starts a loop, not a runbook). So
ESTABLISH a new `upgrade` playbook following the existing convention exactly, and
wire it into both CLAUDE.md tables + the orchestrator persona gate pointer. This
keeps the single-source-of-truth invariant: the runbook lives in one place and
everything points at it.

### Folding `review changes` in, not deleting it

The Propagation-Impact Assessment (the `review changes` loop) is NOT removed --
it is the right tool for the judgment-heavy behavioural-retrofit step. The change
demotes it from "the whole mechanism" to "step 3 of the runbook." The
`target-aeh-reviewer`'s Propagation-Impact Assessment Mode is retained verbatim
in capability; only the framing that presents it as the entire response to a
harness advance is rewritten to present it as one folded-in step.

## Subtraction-completeness sweep (retiring "signal only")

The "signal only" doctrine and the soft one-line wording appear in several
places. All must move to the new doctrine in one change or the harness
self-contradicts:

- `templates/personas/target-orchestrator.md`: section intro ("The mechanism is
  a *signal only*"), the session-init detection code block comment, the
  session-init step 5 wording, and the "symmetric counterpart" line.
- `CLAUDE.md`: the "Harness update propagation signal" bullet.
- `templates/playbooks/health-check.md`: the `harness-sync-sha` presence check
  wording (missing/stale = upgrade trigger, not merely a LOW finding).
- `templates/personas/target-aeh-reviewer.md`: the Propagation-Impact Assessment
  Mode intro (folded-in step, not whole mechanism).
- `templates/prompts/refresh-base-personas.md.template`: the line describing the
  "broader propagation-signal philosophy" -- align to gate-plus-runbook (and note
  it is the runbook's Step 1).
- `templates/prompts/seed-harness-sync-marker.md.template`: the "surface the
  signal" / "say 'review changes'" expected-outcome wording -- align to the
  UPGRADE REQUIRED gate + `upgrade` runbook.

The `harness-sync-sha` convention, the seed prompt, and the marker-bump semantics
are UNCHANGED -- only the surfacing (loud gate) and the response (one runbook)
change.
