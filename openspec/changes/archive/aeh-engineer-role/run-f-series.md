# Run prompt: F-series follow-ons (F1-F5) + publication-readiness sweep (autonomous)

You are in the AEH harness root (`/workspace/aeh`), running as `aeh-engineer`.
This executes the operator-ratified follow-ons to the B1-B7 rebuild. Build F1
through F5 autonomously (each its own OpenSpec change + commit, publication-gated),
then run the final publication-readiness doc/README sweep. Do NOT push; the
accumulated local commits wait for operator push authorisation.

## Step 0 -- become the aeh-engineer

Write `aeh-engineer` to the resolved persona marker (`bin/resolve-persona-marker.sh`,
fallback `.claude/persona`); read `templates/personas/aeh-engineer.md`; operate
under it. Do not run the CLAUDE.md banner.

## Ground yourself

Read, in order: `openspec/changes/aeh-engineer-role/retrospective-b1-b7.md` (the
rationale for F1-F4), `openspec/changes/aeh-engineer-role/redo-b2-b7-with-hindsight.md`
(F1-F4 detail), and this file (adds F5 + the sweep). Then the B-step proposals
under `openspec/changes/aeh-engineer-role-b{1..7}/` and the personas they touched,
so you build consistently with the rebuild.

## Operating regime (whole run)

Same as the B-series run: commit freely, do NOT push the public harness repo;
publication gate (`bin/validate-personas.sh --staged` + `--message`) before every
harness commit; stage only the current change's files (never `git add -A`); no AI
attribution; ASCII-only; target-detail-free and name-free in everything public.
Each F-step is its own `openspec/changes/<f-slug>/` change (proposal + tasks) with
a CHANGELOG entry. Self-review between steps. Subtraction-completeness is
load-bearing.

## Build order

Do F1 FIRST (it changes the scaffold/onboarding story that F2 and the final sweep
depend on). Then F2, F3, F5, F4 in any order. The README/doc sweep is LAST (it
must describe the post-F1 scaffold).

### F1 -- deliver the target-applied artifacts INTO the target  [highest value]

Make `target-aeh-reviewer`, `target-aeh-engineer`, and `aeh-practice-check.sh`
actually reachable from a target session (today they are authored but inert).
- Decide and wire the delivery home (recommended: the two roles into
  `docs/AE/personas/_base/` alongside the five engineering personas, OR a sibling
  `docs/AE/roles/`; the script into the target's own `bin/` or `docs/AE/bin/`).
- Extend `templates/playbooks/onboarding.md` Phase 2 base-template-placement (and
  the greenfield short-circuit) to place all three; extend
  `templates/prompts/refresh-base-personas.md.template` (or add a sibling refresh
  prompt) to refresh them.
- Update `target-aeh-reviewer.md` so it invokes the script at its delivered
  target-side path, not a harness path.
- **Acceptance:** a fresh onboarded target can load `target-aeh-reviewer` and run
  `aeh-practice-check.sh .` with zero harness access.

### F2 -- thin the B7 role-location signature to one-line pointers

Replace each of the five engineering base personas' full `## §0` role-location
block with a one-line pointer to the target `CLAUDE.md` § "Role-location
self-check"; same for the harness personas pointing at the harness CLAUDE.md.
Keep the full signature in exactly the two CLAUDE.md layers.
- **Acceptance:** the three-part signature text appears in exactly two places; all
  personas carry a one-line pointer Step 0.

### F3 -- establish the prompt->result pairing convention behind B4's flagship check

Add to `developer` (and/or `target-orchestrator`) a definition-of-done: every
dispatched `docs/AE/prompts/NNN-title.md` gets a paired committed
`docs/AE/reports/NNN-title.md` (short structured handover: what was done, what
changed, gate pass/fail, wall-clock, commit pointer). Keep it lightweight.
- **Acceptance:** the convention is stated where the executing role reads it, so
  `aeh-practice-check.sh`'s `prompt-result-pairing` check verifies something real.

### F5 -- permission-config compliance reporting + approved-fix + ground-truth validation  [NEW, operator-ratified]

Two checks, split by which tree the config lives in. BOTH are report-by-default,
offer-fix-after-operator-approval, then validate-against-measured-ground-truth.

- **Target's own config** (`<target>/.claude/settings.json` + `.local`): add a
  `permission-scope` check to `bin/aeh-practice-check.sh` (deterministic cases:
  secrets in rules, `Read(/**)`/filesystem escape, bypass mode, missing
  harness-isolation deny). `target-aeh-reviewer` REPORTS the finding + the exact
  rule changes needed to be compliant (read-only; cites the
  `permission-baselines.md` baseline). The judgment cases (sprawl) stay the
  reviewer's narrative. On operator approval, `target-aeh-engineer` APPLIES the
  rule change in the target. Then RE-RUN the deterministic check to validate the
  config now passes (the check that detected is the check that confirms).
- **AEH-side grant** (the harness `/workspace/aeh/.claude/settings.json` scoping
  the orchestrator to `docs/AE/**`): add a `harness-reviewer` dimension that reads
  the harness config directly (it is a harness file, in its tree) and reports
  whether the grant is `docs/AE/`-scoped + any change needed. `target-aeh-reviewer`
  contributes only target-side SYMPTOM evidence (AEH-side-authored commits/markers
  outside `docs/AE/`). On approval, `aeh-engineer` fixes the harness config; then
  re-run to validate.
- Wire the report/approve/fix/validate loop explicitly in both reviewer + both
  engineer personas (detect-then-route-by-file-location already governs WHO fixes
  WHICH tree). Update the B6 design-call note in `permission-baselines.md`: the
  compliance REPORT is now built in (not deferred); only the airtight
  negation-based lockdown stays deferred.
- **Acceptance:** `aeh-practice-check.sh --list` shows `permission-scope`; the
  report->approve->fix->revalidate loop is documented in the four roles; the B6
  deferral note is corrected.

### F4 -- decide the orchestrator-state.md filename honestly

Pick ONE and commit: (a) rename the artifact to `target-orchestrator-state.md`
across live templates + a one-line retrofit `target-aeh-engineer` applies to
existing targets; OR (b) keep `orchestrator-state.md` and add ONE settled
exception note near the CLAUDE.md rename back-compat note so future reviews stop
re-flagging it. Default to (b) unless the rename is cheap once F1's delivery
wiring exists.

## Final phase -- publication-readiness doc/README sweep (the push gate)

After F1-F5 land, run the full harness-reviewer-style publication-readiness sweep
over the WHOLE B1-B7 + F1-F5 surface:
- **README narrative:** update the "how it works" / boundary prose to describe the
  ENFORCED `docs/AE/` fence (B6) and the detect/remediate matrix as the model
  (currently only the roles table reflects the new roles; the narrative predates
  B6). Reflect the post-F1 scaffold (the target-applied roles + check script now
  ship into the target).
- **Currency:** CLAUDE.md, CHANGELOG, structure trees, playbook cross-refs all
  current; no stale references to removed/renamed constructs anywhere.
- **Leak hygiene:** confirm the untracked planning docs under `docs/` (e.g.
  `aeh-layered-implementation-plan.md`, which carries a real target slug + the old
  model) stay UNTRACKED; never `git add` them. Broad validator scan clean.
- **Integrity/consistency/dedup:** a full pass; fix anything stale/contradictory/
  duplicated as additional commits.
- Confirm the tree WOULD be ready to publish; do NOT push.

## Report-back

What landed per F-step (commit hashes), the F1/F4/F5 decisions you made, the
README/doc-sweep outcome, and a clear statement that the publication-readiness gate
is (or is not) clear pending operator push authorisation. End in DONE or
DECISION-NEEDED.
