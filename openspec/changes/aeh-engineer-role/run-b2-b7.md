# Run prompt: build B2-B7 of the AEH role-architecture rebuild (autonomous, no-pause)

You are running in the AEH harness root (`/workspace/aeh`). This is a fresh,
cleared context. Build steps B2 through B7 of the accepted `aeh-engineer-role`
architecture, autonomously, in one pass, then produce a retrospective and a
redo-prompt. Do NOT pause for operator review between steps. The operator has
authorised this explicitly.

## Step 0 -- become the aeh-engineer

This work IS harness engineering, so run it as the `aeh-engineer` role (the role
B1 created -- you are now dogfooding it).

1. Resolve the persona marker path via `bin/resolve-persona-marker.sh` (fallback
   `.claude/persona`) and write `aeh-engineer` to it.
2. Read `templates/personas/aeh-engineer.md` and operate under it.
3. Do NOT run the CLAUDE.md session-init banner / role-picker. Step 0 is the init.

## Ground yourself first (read in this order)

1. `openspec/changes/aeh-engineer-role/kickoff.md` -- the B1-B7 marching orders.
2. `openspec/changes/aeh-engineer-role/proposal.md` + `design.md` -- the accepted
   architecture (taxonomy, detect/remediate matrix, R2, the enforced fence,
   detect-then-route, propagation split). This is the SPEC; do not re-litigate it.
3. `openspec/changes/aeh-engineer-role-b1/proposal.md` -- what B1 already did
   (the persona, the wiring, the orchestrator subtraction). Read
   `templates/personas/aeh-engineer.md` and the current `CLAUDE.md` role section
   so you build consistently with B1.
4. `targets/_harness-private/intake/TRIAGE-2026-06-17.md` -- the disposition
   manifest (which captures fold into which B-step). The fold-source captures
   live in `targets/_harness-private/intake/` (private; read for understanding,
   but author all public content target-detail-free AND name-free).

## Operating regime (whole run)

- **Commit freely, do NOT push the harness repo.** The publication-readiness gate
  holds until the WHOLE rebuild is coherent and swept; the accumulated local
  commits wait for the operator's push authorisation. (You MAY commit+push the
  private `targets/` repo -- it is personal backup, no downstream consumer.)
- **Publication gate before every harness commit:** `bin/validate-personas.sh
  --staged` over staged content + `bin/validate-personas.sh --message "<msg>"`
  over the message. Both must exit 0. Stage only the files for the current
  B-step; never `git add -A` (the tree has unrelated untracked images +
  other-session target state).
- **No AI attribution** in commits or files. ASCII-only output. Target-detail-free
  and name-free in everything public (`templates/**`, `CLAUDE.md`, `README.md`,
  `openspec/**`).
- **Each B-step is its own committed change** under `openspec/changes/<b-slug>/`
  (proposal.md + tasks.md, same shape as `aeh-engineer-role-b1/`), with a
  CHANGELOG [Unreleased] entry. Don't bundle distinct B-steps into one commit.
- **Subtraction-completeness is load-bearing** (B2 and B5 especially): when you
  remove/rename/fold a construct, sweep every producer AND consumer; the residual
  scan must be clean before you call the step done.
- **Self-review between steps** in lieu of a live operator: after each B-step,
  run a focused harness-reviewer-style pass over the files you touched
  (consistency, currency, no stale refs, no cross-layer leakage) before moving on.

## Build sequence (note the deliberate ordering)

Do B2, B3, B4, B6, B7 first, then **B5 LAST**. Rationale (sanctioned by design.md
"sequence B5 AFTER the persona set stabilises"): B5 is a repo-wide rename
(`orchestrator` -> `target-orchestrator`); doing it last means a SINGLE residual
sweep covers all the new content B2/B3/B4/B6/B7 produced, instead of re-sweeping.
B6 and B7 may freely write `orchestrator`; B5 renames them along with everything
else.

### B2 -- purify harness-reviewer
- Remove harness-reviewer's TARGET-tree review branches (the "if reviewing a
  target project's AEH setup" lines in Dimensions 1/4, the Archaeologist-baseline
  target check, the harness-vs-health-check scope table's target half). Those
  concerns become `target-aeh-reviewer`'s in B3 / stay in the health-check flow.
  harness-reviewer keeps ONLY harness-self review.
- Relocate the "Propagation-Impact Assessment Mode" out of harness-reviewer; it
  becomes `target-aeh-reviewer`'s mode (you build that in B3 -- land the relocated
  content there). Leave a precise pointer, not a dangling reference.
- Fold: base-templates-must-not-cite-harness-only-PATHS/scripts (capture
  `...refresh-template-step0-harness-only-script-ref...`) -- extend Dimension 4's
  existing "no cross-layer construct references" check to also catch a base
  template citing a harness-only path/script (e.g. `bin/resolve-persona-marker.sh`)
  that will not resolve in a target tree.

### B3 -- target-aeh-reviewer + target-aeh-engineer personas  [DESIGN CALL]
- `target-aeh-reviewer` (DETECT, read-only, runs IN the target): evolve the
  health-check playbook (`templates/playbooks/health-check.md`) into a loadable
  role that detects AEH-method violations in an onboarded target from observable
  artefacts; it RUNS the deterministic `bin/` check framework (built in B4);
  receives the relocated Propagation-Impact Mode from B2.
- `target-aeh-engineer` (REMEDIATE, read-write, runs IN the target): applies
  pulled harness changes to a target's overlays and remediates detected
  target-side AEH violations, in the target's own permission model.
- Fold: per-target operational-skill + two-tier currency gate (capture
  `...per-target-operational-skill-and-currency-gate...`).
- **Design calls to MAKE (do not pause -- decide, build, and surface at the end):**
  how much of the health-check playbook becomes the loadable role vs stays a
  playbook the role drives; the exact shape/section-structure of the two new
  personas (they are target-applied, so decide whether they are layered base
  templates with overlays or harness-internal-style single files -- note the
  taxonomy says they run IN the target); whether the currency-gate's Tier-1
  pre-push tripwire ships as a hook template now or is queued. Record each
  decision explicitly in `openspec/changes/<b3-slug>/proposal.md` under a
  "Decisions made (for operator ratification)" heading.

### B4 -- deterministic bin/ AEH-practice check framework
- An extensible registry of deterministic checks the `target-aeh-reviewer` runs
  (single chokepoint, no LLM judgment per check, cannot silently no-op). Fold:
  structural-invariant-gate pattern as the backbone (capture
  `...structural-invariant-gate-pattern...`); the prompt->result one-to-one
  pairing invariant as one concrete check (capture `...prompt-result-pairing...`).
- Honour the operator's wariness (in the structural-invariant capture) about
  lifting non-strictly-generic things into the harness: keep the framework lean
  and SDLC-generic; this is a `bin/` script + a small registry, not a heavy
  mechanism.

### B6 -- enforced docs/AE/-only fence  [DESIGN CALL]
- Retire the soft CLAUDE.md rule "you CAN read target project files for
  assessment purposes." Replace with the enforced fence: AEH-side roles are
  fenced out of the target tree; the ONLY allowlisted exception is
  `orchestrator` (a.k.a. target-orchestrator) reading/writing `<target>/docs/AE/**`.
  Add the permission allowlist/baseline (`templates/agents/claude-code/permission-baselines.md`)
  and the onboarding bootstrap-read exception (narrow, read-only, first-contact
  assessment only, ends when `docs/AE/` exists -- see design.md).
- Fold: no-target-code-spelunking + no-target-tree-rummaging (captures
  `...orchestrator-no-target-code-spelunking...`, `...orch-no-target-tree-rummaging...`)
  -- the orchestrator answers from principle or routes; it never rummages the
  target tree. (Note these may already be partially in orchestrator.md; check and
  consolidate, don't duplicate.)
- **Design calls to MAKE and surface:** exact permission-allowlist syntax/shape;
  how strictly the bootstrap exception is bounded; whether `target-aeh-reviewer`
  polices the orchestrator's actual permission grant here or that is deferred.
  Record under "Decisions made (for operator ratification)".

### B7 -- role-location Step-0 self-check (all roles)
- Generalise the per-role Step-0 tree-location self-check from the orchestrator-only
  form to ALL roles, parameterised by family (AEH-proper + coordinator assert they
  ARE in the AEH root; target-applied-in-target roles assert they are NOT).
  Source the per-family expected signature from ONE shared place (the CLAUDE.md
  taxonomy section and/or a `bin/` resolver), not N hand-rolled copies. Fold the
  location assertion into each base persona's existing role-activation Step 0
  rather than adding a competing block (capture `...role-location-self-check...`).
- ABSORB the standalone `orchestrator-self-location-guard` proposal
  (`openspec/changes/orchestrator-self-location-guard/`): the general form
  replaces it -- mark that proposal superseded-by your B7 slug; do not leave a
  duplicate orchestrator-only guard.

### B5 -- rename orchestrator -> target-orchestrator  [DO LAST]
- Repo-wide rename of the role TOKEN `orchestrator` to `target-orchestrator`:
  `CLAUDE.md`, `README.md`, `bin/*.sh`, every base persona, the playbooks
  (`onboarding`, `health-check`, `tools`), `templates/prompts/orchestrator-batch-regime.md`,
  `templates/governance/*`, and the persona file itself
  (`templates/personas/orchestrator.md` -> `target-orchestrator.md`; `git mv`).
  Update the validator `HARNESS_ROLES` and any persona-marker references.
- DISTINGUISH the role token from prose ("orchestration", "the orchestrating
  session") -- do not rename those. Marker-value back-compat: an existing
  `.claude/persona` holding `orchestrator` must still resolve (accept the legacy
  value for a deprecation window, or have session-init rewrite it -- document
  which).
- Fold: freestyle-prompt label correctness (capture
  `...target-side-orchestrator-label-misuse...`) -- the four retrofit prompt
  templates labelled "orchestrator (target-side)" should be `freestyle`
  (harness-delivered structural placement), not an orchestrator-role label; fix
  them as part of this rename.
- **Acceptance: a clean repo-wide residual scan.** `grep -rn '\borchestrator\b'`
  over the tracked tree returns ONLY `target-orchestrator`, deliberate prose, and
  out-of-scope `openspec/changes/archive/**` + historical proposal text. Any
  surviving bare role-token `orchestrator` in canonical context is a defect.

## When all of B2-B7 are committed

1. **Whole-rebuild coherence sweep** (the publication-readiness gate's
   integrity/consistency/dedup pass over B1-B7 as a whole): run a full
   harness-reviewer-style pass. Fix anything stale/contradictory/duplicated as
   additional commits. Do NOT push -- just confirm the tree would be ready.

2. **Full hindsight retrospective** -- this is a primary deliverable, not a
   footnote. Write it to the operator in chat (and save a copy to
   `openspec/changes/aeh-engineer-role/retrospective-b1-b7.md`). Frame it toward
   what, with 20/20 hindsight from having now done it once, you would do
   **better, simpler, and significantly different** -- e.g. structural choices you
   would invert, sequencing you would change, things you over-built, a simpler
   decomposition you can now see, anything you would delete rather than add.
   Be concrete and self-critical; the value is surfacing the simpler solution
   that only becomes visible after the first pass.

3. **Write the redo handoff prompt** at
   `openspec/changes/aeh-engineer-role/redo-b2-b7-with-hindsight.md`: a
   self-contained prompt a cleared context could execute to RE-IMPLEMENT B2-B7
   (or the specific steps worth redoing) applying the hindsight improvements from
   step 2. It should name exactly what changes vs the just-built version and why,
   so the operator can decide cheaply whether the redo is worth it. (If your
   honest retrospective concludes the current build is already the right shape and
   a redo is NOT worth it, say so plainly and make the redo prompt a no-op note
   explaining why -- do not invent churn.)

4. **Report-back to the operator:** what landed per B-step (commit hashes), the
   B3 + B6 design calls you made (so they can ratify or send you back), the
   retrospective headline, and a clear DECISION-NEEDED on whether to run the redo
   prompt. End in DONE or DECISION-NEEDED.

## Context hygiene

This is a large surface. If your context fills, commit what is done, write a
one-paragraph resume-state note to `openspec/changes/aeh-engineer-role/run-progress.md`
(which B-steps are committed, which is in flight), and tell the operator to
`/clear` and re-paste this run prompt -- a fresh session reads `run-progress.md`
and continues from the next uncommitted B-step. The committed state + the
per-B-step `openspec/changes/<b-slug>/` dirs are the durable resume substrate.
