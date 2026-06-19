# Hindsight retrospective: building B1-B7 of the AEH role architecture

Written immediately after building B2-B7 in one autonomous pass (B1 pre-existed).
Framed toward what, with 20/20 hindsight from having now done it once, I would do
**better, simpler, and significantly different**. Self-critical on purpose -- the
value is the simpler shape that only becomes visible after the first pass.

## What landed (so the critique has a referent)

- B2 (9729563): purified `harness-reviewer` to harness-self detection.
- B3 (0315095): `target-aeh-reviewer` + `target-aeh-engineer` personas.
- B4 (e6a91e6): `bin/aeh-practice-check.sh` deterministic check framework.
- B6 (2cea889): enforced `docs/AE/`-only fence.
- B7 (a5f09f1): role-location Step-0 self-check generalised to all roles.
- B5 (bb0a175): `orchestrator` -> `target-orchestrator` repo-wide rename (last).

Architecture is sound; the detect/remediate matrix is now fully populated; the
residual scan is clean; the validator passes. The critique below is about SHAPE,
not correctness.

## The one structural thing I would invert: delivery-wiring is not a follow-on

**The biggest mistake: B3 and B4 ship three target-applied artifacts that cannot
reach a target.** `target-aeh-reviewer`, `target-aeh-engineer`, and
`aeh-practice-check.sh` all RUN IN the target -- but nothing places them there. I
deferred "scaffold delivery into the target" three separate times (B3 Decision 3,
B4 scope, and implicitly B7). The result is correct artifacts that are inert: a
target session has no way to load the two new personas or run the check script,
because the onboarding scaffold and the refresh template do not deliver them.

With hindsight, **delivery-wiring should have been the FIRST thing B3 did, not a
deferred note.** A target-applied role that can't be loaded in a target isn't
half-built -- it's unbuilt, with a persona file as a paper trail. The clean
decomposition:

- B3a: extend the onboarding base-template-placement step + the refresh template +
  the `docs/AE/` scaffold to deliver `target-aeh-reviewer.md`,
  `target-aeh-engineer.md`, and `aeh-practice-check.sh` into the target (alongside
  the five engineering base personas). THEN
- B3b: author the two personas (knowing they will actually load).

I had this backwards: I authored the roles and left "how they get there" as a
standing TODO. The redo's highest-value change is to pull delivery-wiring forward
and make it a build gate ("a target-applied role is not done until a fresh target
session can load it"), not a footnote.

## What I over-built: the B7 signature is duplicated ~11 times

I am the role whose charter is "fight the additive ratchet," and in B7 I inlined
the role-location signature into CLAUDE.md, CLAUDE.md.template, all five
engineering base personas, and the harness personas -- roughly eleven near-
identical statements of the same three-part signature. The fence genuinely forbids
a target-facing persona from citing the harness CLAUDE.md, so SOME per-layer
statement is unavoidable. But I restated the FULL block in each of the five base
personas when a one-line pointer would have done: "run the role-location self-check
in your project's CLAUDE.md § 'Role-location self-check' (assert: target tree, not
AEH root)." One target-side source (the target CLAUDE.md), five one-line pointers
-- instead of five full copies that will now drift.

Simpler still: a single shared snippet delivered into `docs/AE/` that each persona
Step-0 sources by target-side path. That is the same pattern the rest of the
harness uses (base personas are snapshots, not inlined copies). I reached for
inline duplication out of momentum. The redo should thin the five §0 blocks to
one-line pointers.

## What I treated as expensive but isn't anymore: the orchestrator-state.md rename

In B5 I kept `orchestrator-state.md` (and `orchestrator-batch-regime.md`) named
with the old token, on the grounds that renaming the state file would "churn every
existing target and force a back-compat migration." But B3 just built
`target-aeh-engineer` -- whose entire job is applying harness changes (including
renames) to a target's tree. The migration path I cited as the blocker now EXISTS.
So the churn objection is weaker than I let it be: the rename could ship with a
one-line retrofit that `target-aeh-engineer` applies. As built, the role is
`target-orchestrator` but its state artifact is `orchestrator-state.md` -- a small
permanent inconsistency a future harness-reviewer will re-flag every pass. With
hindsight I would either rename it (and lean on the role I just built to migrate
targets) or stop calling it a regret and document it as a settled exception. The
half-measure (keep it, but apologise for it in three proposals) is the worst of
both.

## What I churned needlessly: writing new content in the old token, then renaming it

B6 and B7 authored brand-new content (the fence rules, the Step-0 blocks) using
`orchestrator`, knowing full well B5 would rename it hours later. So B5's diff
includes mass-renaming lines that were written THIS SESSION. Since the final token
was known from the start, B6/B7's new content should have been written directly in
`target-orchestrator`, leaving B5 to rename only genuinely-pre-existing
occurrences. Minor wasted motion, but it also inflated the B5 diff and made its
residual scan noisier. The sequencing rule "rename last" is right for PRE-EXISTING
content; for NET-NEW content authored after the rename is decided, write it in the
final name.

## What I built out of order: the police before the law (B4)

B4's flagship check is `prompt-result-pairing` -- but the prompt->result pairing
CONVENTION (every dispatched prompt gets a committed paired result) is not yet
established in any persona. So on a real target the flagship check SKIPs (no
`docs/AE/results/` or paired reports exist), and the framework verifies almost
nothing until a separate change establishes the convention. I built the enforcement
before the thing it enforces. The redo should pair B4 with a small persona edit
(developer/target-orchestrator guarantee a paired result file per prompt) so the
check has something real to verify on day one.

## What the spec itself over-decomposed (mild)

The parent proposal mandated "each B-step its own reviewed change," which I
followed: seven proposal.md + seven tasks.md + seven CHANGELOG entries. For the
larger steps (B3, B5, B6) that ceremony earned its keep. For B2 (one file) and B7
(mechanical fan-out) it was heavier than the change warranted. Not a mistake given
the spec, but with hindsight the spec could have grouped the small steps. This is a
note on decomposition granularity, not a defect in execution.

## What went RIGHT (worth keeping in the redo)

- **B5-last was correct.** One residual scan covered all new content; the careful
  perl (`(?<!target-)\borchestrator\b(?!-)`) preserved prose, compounds, and the
  kept artifact filenames cleanly.
- **The detect/remediate matrix** is a genuinely good organising idea: every role
  slots into (detect|remediate) x (harness|target) + a coordinator, and the
  taxonomy makes each role's tree legible from its name.
- **Design calls surfaced explicitly** (the "Decisions made (for operator
  ratification)" headings) rather than buried -- this is the right pattern.
- **B4 kept lean** (a script + 3 checks, no heavy mechanism), honouring the
  operator's wariness about non-generic harness surface.
- **The freestyle-label fold** (B5) killed two birds: removed the misleading
  orchestrator label AND the harness-only-resolver-path defect.

## Verdict on whether to redo

**A full re-run of B2-B7 is NOT worth it.** What is built is coherent,
publication-ready in structure, and the architecture is right. The four real gaps
-- (1) delivery-wiring, (2) B7 signature dedup, (3) the prompt->result convention
behind B4's flagship check, (4) optionally the state-file rename -- are INCREMENTAL
additions and small refactors ON TOP of the built version, not rework of it.
Re-running from scratch would re-litigate settled, correct decisions to fix four
bounded follow-ons. The redo prompt (`redo-b2-b7-with-hindsight.md`) is therefore
written as a set of targeted FOLLOW-ON changes, not a rebuild -- and it says so
plainly.
