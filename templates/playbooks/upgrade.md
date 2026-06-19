# Playbook: Upgrade (full harness-sync upgrade of a target)

The single turnkey procedure that takes a target whose AEH practice has fallen
behind the harness all the way back to current, and PROVES it got there. Driven
by the `target-orchestrator` from the harness root via dispatched target-side
prompts; the orchestrator never reaches into the target tree itself.

**Trigger:** `upgrade` or `upgrade <slug>`, or the `UPGRADE REQUIRED` gate the
orchestrator surfaces at session-init when a target's `harness-sync-sha` is
behind the harness HEAD (or absent).
**Produces:** an upgraded target (snapshots refreshed, `CLAUDE.md` uplifted,
behavioural retrofits applied, AEH-practice check clean) and a bumped
`harness-sync-sha` marker; the terminal `UPGRADE COMPLETE` state.

This playbook is the response the propagation gate points at. It REPLACES the old
"signal only -> say 'review changes'" posture: the gate is now loud (see the
`target-orchestrator` persona's "Harness Update Propagation Gate"), and this is
the one reliable end-to-end procedure it names. The former `review changes`
Propagation-Impact assessment is NOT gone -- it folds in here as Step 3 (the
operator-gated behavioural-retrofit step), one part of the runbook rather than the
whole mechanism.

---

## Tone Rules

Same as the onboarding and health-check playbooks: concise, ASCII-only, no emoji,
progress indicators, detail on demand. Each step ends with its gate result stated
plainly (PASS / blocked-and-why).

---

## Prerequisites

- The target exists in `targets/index.md` and has been onboarded (it has a
  `docs/AE/` tree). A not-yet-onboarded planning workspace has no AEH practice to
  upgrade -- run `onboard` first; this playbook does not apply.
- You are the `target-orchestrator` running in the AEH harness root (the
  role-location self-check has passed). Steps dispatch target-side prompts; you
  do not edit the target tree.
- The target's `targets/<slug>/profile.md` carries (or will be seeded with) a
  `harness-sync-sha:` field. If absent, the gate already flagged it; Step 5 seeds
  it at completion.

If the target is not onboarded, redirect to `onboard` and stop.

---

## Phase 0: Scope the delta

```
[upgrade] Scoping <slug> against harness HEAD
```

1. Read `targets/<slug>/profile.md` for `harness-sync-sha` (`$sync`). Read the
   harness HEAD: `git -C /workspace/aeh rev-parse --short HEAD` (`$head`).
2. Count and list the range:
   - `git -C /workspace/aeh rev-list --count $sync..HEAD` (commit count).
   - The CHANGELOG diff for the range (you hand this to the reviewer in Step 3 so
     the target-side role does not reach into the harness tree).
3. Confirm scope with the operator in plain English: "<slug> is N commits behind
   (`$sync..$head`). Running the upgrade runbook: refresh snapshots, uplift
   CLAUDE.md, apply behavioural retrofits, drive the AEH-practice check clean,
   bump the marker. Proceed?" Default posture is upgrade-first; the operator may
   defer explicitly.

If `$sync` equals `$head`, the target is already current -- say so and stop (the
gate would not have fired).

---

## Step 1: Refresh AEH snapshots target-side

```
[upgrade 1/5] Refreshing AEH snapshots
```

Dispatch `templates/prompts/refresh-base-personas.md.template` adapted for the
target (5 engineering base personas + 2 target-applied roles + the
`docs/AE/bin/aeh-practice-check.sh` check script). More than one artifact may have
moved in the range, and pre-existing drift on untouched artifacts is silently
corrected -- so refresh is directory-scoped, not minimally-scoped.

**Gate (hard):** every refreshed artifact is byte-identical to harness master.
The refresh prompt reports a `cmp` match/no-match per file; the report-back must
show match for all 5 base personas, both target-applied roles, and the check
script. Any no-match blocks -- resolve before Step 2.

---

## Step 2: Uplift the target's CLAUDE.md

```
[upgrade 2/5] Uplifting CLAUDE.md
```

Dispatch a target-side prompt that diffs the target's `CLAUDE.md` against the
current `templates/project/CLAUDE.md.template` and uplifts it. Scope the prompt
to a WHOLE-BLOCK diff per region applied in ONE pass -- not section-by-section.
The session-init siblings (banner flow, dispatch handling, role-location
self-check, role-loading, role-activation announcement) are interdependent;
aligning one region while leaving a sibling stale can produce a live
self-contradiction (worse than doing nothing). The correct scoping unit is the
coherent block, not the single section a symptom pointed at.

**Gate (hard):** no stale or self-contradicting session-init block remains, and
the AEH-practice check's `claude-md-size` check does not regress. The
report-back states each uplifted region and confirms the session-init block is
internally coherent.

---

## Step 3: Behavioural-retrofit pass (operator-gated)

```
[upgrade 3/5] Behavioural retrofits (Propagation-Impact assessment)
```

This is where the former `review changes` assessment folds in as ONE step.

1. Dispatch `target-aeh-reviewer` in Propagation-Impact Assessment Mode (see
   `templates/personas/target-aeh-reviewer.md`). Hand it, in the prompt, the
   commit range (`$sync..HEAD`), the CHANGELOG diff for that range, and a summary
   of relevant harness changes -- so the target-side reviewer does not reach into
   the harness tree (the fence cuts both ways).
2. The reviewer writes a structured retrofit-action list to
   `docs/AE/reports/propagation-impact-YYYY-MM-DD.md`. Read it via the `docs/AE/`
   channel and present it to the operator in plain English.
3. Operator adjudicates per-action: apply / defer / skip. Applied actions execute
   via target-side prompts you dispatch to `target-aeh-engineer`. CLAUDE.md
   retrofits use the whole-block scoping from Step 2.

**Gate (hard):** every action on the list is resolved (apply / defer / skip) --
none left unadjudicated. "No action needed" is a valid resolution for
purely-harness-internal commits; mark the marker can advance past those.

---

## Step 4: Seed pairing baseline (if needed) + drive the check clean

```
[upgrade 4/5] AEH-practice check to clean
```

1. If the target predates the one-prompt-one-report pairing convention (its
   `docs/AE/prompts/` history starts before the convention), dispatch a prompt to
   seed `docs/AE/.prompt-pairing-since` with the first NNN prompt number to
   evaluate (zero-padded). This excludes legacy history from the
   prompt-result-pairing check without fabricating reports; the excluded span is
   reported explicitly, never silently truncated.
2. Dispatch a prompt that runs `docs/AE/bin/aeh-practice-check.sh .` and reports
   the full PASS/FAIL/WARN/SKIP breakdown. Route any FAIL to remediation
   (`target-aeh-engineer` for target-side root-cause; capture to the private
   intake for a confirmed harness-side check false-positive, and have the
   operator confirm before treating any FAIL as a false-positive).

**Completion gate (hard): PASS/WARN only, zero FAIL.** A genuine FAIL blocks the
upgrade; a confirmed harness-side false-positive is captured and explicitly
acknowledged by the operator before proceeding.

---

## Step 5: Confirm role activation + bump the marker

```
[upgrade 5/5] Confirm activation + bump marker
```

1. Confirm a role-bound prompt activates correctly target-side -- the refreshed
   target-applied roles load from `docs/AE/roles/` and the engineering base
   personas from `docs/AE/personas/_base/`. A dispatched role prompt's Step-0
   role-activation announcement firing correctly is the signal.
2. Bump `harness-sync-sha` in `targets/<slug>/profile.md` to the HEAD just synced
   to (`$head`). If the marker was absent, add it cleanly to the frontmatter
   (match the canonical schema -- a single `harness-sync-sha: <sha>` line the
   `^harness-sync-sha:` anchor matches). Record the bump in
   `targets/<slug>/journal.md` as a `[DECISION]`-tagged entry.
3. Update `targets/index.md` Status cell: "AEH-CURRENT (synced to `<head>`,
   <date>)".

**Final gate (hard):** the target is ready for code work. Emit the explicit
terminal state:

```
UPGRADE COMPLETE -- <slug> synced to <head>, aeh-practice-check clean, ready for code work
```

Once the marker is bumped to `$head`, the session-init UPGRADE REQUIRED gate
stops firing for this target.

---

## Deferral

The operator may defer explicitly at Phase 0 (the gate stated this is allowed).
On deferral, do NOT bump the marker; the gate re-surfaces on the next
session-init. Record the deferral as a `[DECISION]` journal entry so the choice
is auditable. Partial completion (some steps done, marker not yet bumped) is
fine: the marker only advances at Step 5, so an interrupted run simply re-surfaces
the gate and resumes from where the snapshots/CLAUDE.md left off.

---

## Fallback

- **A gate blocks.** Stop at the blocked step, surface the specific failure to
  the operator, do NOT advance the marker. The runbook is idempotent from any
  step (Steps 1-2 are byte-compares; Step 4 re-runs the check), so resume after
  the block clears.
- **Target not onboarded.** Redirect to `onboard`; this playbook needs a
  `docs/AE/` tree.
- **AEH-practice check FAIL the operator believes is a harness false-positive.**
  Capture it to `targets/_harness-private/intake/` and have the operator confirm
  before treating it as non-blocking. A real target-side FAIL is never waved off.
