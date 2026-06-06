# Design: Orchestrator state consolidation + context-disposability gate

## 1. The model (so operators stop judging by feel)

The orchestrator's context window is a **write-back cache** over the durable state files.

- **Safe to clear = cache is clean = zero dirty pages**: everything in the window is already reflected in the files.
- The "dirty bit" operators currently sense by feel IS the gap between what the live session holds and what a fresh session would reconstruct from the files alone.

Two distinct failure modes the gate must cover:

- **(a) Loss-on-clear.** Orientation lives only in the window; clearing destroys it. Fix: flush the dirty page to its file before clearing.
- **(b) Latent gap.** The window happens to hold it, but the files have no slot for it -- so even after flushing this instance, the next arc will not capture the same class automatically. Fix: add the missing slot (schema gap), not just the instance.

Green requires BOTH: no dirty pages AND the persisted form is structurally complete enough that reinitialisation is faithful.

## 2. Function-based canonical state model

State files are classified by function, not by topic. Four functions:

| Function | File(s) | Mutability | Role |
|---|---|---|---|
| Durable identity | `profile.md` | rarely changes | read-first anchor: path, stack, repo, owner, policy, harness-sync-sha |
| Live dashboard | `orchestrator-state.md` | every session | the single mutable "current truth": pipeline position, execution log, review tracking, scorecard, open questions, handoff notes |
| Append-only history | `journal.md` | append-only | the single chronological ledger: session narrative, decisions, review findings, gate events -- tagged for filtering |
| Phase artifacts | `assessment.md`, `transformation-plan.md` | write-once-ish | reference deliverables produced per phase; not state churn |
| Substructure | `prompts/`, `deliverables/`, `findings/` | as needed | unchanged |

`tasks.md` is retained (see Alternatives) as the granular transformation task list, referenced directly by prompts under the lean-prompt convention.

## 3. Migration mapping (the baby-not-thrown-out proof)

Every retired file's content and lookup function maps to a destination. Nothing is deleted without a home.

| Retired file | Content class | Destination | Lookup preserved by |
|---|---|---|---|
| `decisions.md` | dated decision + rationale | `journal.md` entry tagged `[DECISION]` | `grep '\[DECISION\]' journal.md` |
| `open-questions.md` | current unresolved questions | `orchestrator-state.md` -> new `## Open Questions` section | it is current state, surfaced on the dashboard every session |
| `review-history.md` | longitudinal reviewer findings | `journal.md` entries tagged `[REVIEW]`; rolling counts stay in `orchestrator-state.md` "Review Tracking" | `grep '\[REVIEW\]' journal.md` + the dashboard summary |
| `inconsistencies.md` (added during implementation -- see note) | assessment-phase ranked findings | `assessment.md` -> `## Inconsistency Report` section | it is part of the same assessment-phase findings as the checklist |

**`inconsistencies.md` -- a fourth fold surfaced during the consumer sweep.** The implementation pass that swept every *consumer* of the retired files (onboarding playbook, health-check, tools, governance, docs -- see section 8) found a fourth file the original three-file analysis missed: `inconsistencies.md`, the assessment-phase ranked findings report, which onboarding scaffolds and which was never even listed in CLAUDE.md's canonical tree. It duplicates the "assessment findings" concern with `assessment.md`. Passing it through the same "still earns its place" gate, it fails as a separate file (two files for one phase's findings), so it folds into `assessment.md` as a `## Inconsistency Report` section. This keeps the canonical set at eight and shrinks the consumer surface. Unlike the three churny satellites, this is a write-once phase-artifact merge, not a churn fix; it is in scope because the consumers were explicitly directed through the simplification/de-duplication gate, not just repointed.

Why this preserves function:
- **Decisions** were dated events; they belong in the chronological ledger. The `[DECISION]` tag gives the same "why did we choose X" lookup the separate file gave, without a separate file to keep current.
- **Open questions** are not history -- they are live state the next session must see immediately. Moving them ONTO the dashboard (read first, every session) makes them more visible, not less.
- **Review history** had two parts: the trend (counts -- already in dashboard "Review Tracking") and the findings narrative (dated -- belongs in the journal). Splitting it to its two natural homes removes the third log without losing either part.

Result: the churny-state set the operator must keep current shrinks from `{profile, tasks, decisions, open-questions, review-history, orchestrator-state, journal}` to `{profile (rare), tasks, orchestrator-state, journal}`. Three retired files; zero lost functions.

## 4. Pre-clear reconciliation gate

Added to `orchestrator.md` as a subsection (near "State Initialisation"). Runs before any orchestrator `/clear`, or on demand.

Procedure:

1. Reconstruct -- from `{profile.md, orchestrator-state.md, journal.md, tasks.md}` ALONE -- the current objective, pipeline position, next action, and open decisions/questions.
2. Compare to what the live session is holding. **List the delta.**
3. For each delta item, classify and resolve:
   - **(a) dirty page** -> write it to its destination file, then continue.
   - **(b) missing slot** -> add the field/section to the appropriate file so this class is captured automatically next time, then write the instance.
4. Re-run step 1-2. When the delta is empty -> GREEN. Clear is safe.
5. Log one line in `orchestrator-state.md` Session Handoff Notes: `pre-clear delta: N items, M new slots needed (YYYY-MM-DD)`.

Self-improving property: each (b) resolution shrinks future deltas. Track N and M across sessions; when they are reliably 0, clear-at-will is earned -- the files provably reconstruct the session's head. This is a measurable quality gate built from one log line, not a dashboard or daemon.

The gate is a reconstruct-and-DIFF, deliberately not a brain-dump. A brain-dump cannot prove completeness; a diff against a from-scratch reconstruction can. This is the single upgrade over the existing open-loop "update journal/tasks before exiting" discipline.

## 5. Forgetting fold

The pre-clear reconciliation is also where stale state is pruned (the orchestrator-side forgetting moment). Harness-side, add ONE question to an existing harness-reviewer dimension (recommended: Dimension 3 Documentation Currency):

> Does every always-active rule and every canonical state slot still earn its place -- superseded, mergeable, or demotable to a pointer? Flag dead wood, not just missing or stale content.

No new dimension, no new tool. The reviewer already reads `CLAUDE.md` and the persona files; this adds a lens, not a pass.

## 6. Alternatives considered

- **Fold `tasks.md` into the dashboard too.** Rejected for now. `tasks.md` is referenced directly by prompts (lean-prompt convention: prompts point at the task list rather than paraphrasing it). Folding it into `orchestrator-state.md` would either break that pointer convention or drag the whole dashboard into every prompt's reference surface. The overlap with Pipeline Position is a summary-vs-detail relationship, not true duplication. Revisit only if observed churn justifies it (YAGNI).

- **Keep all files, lean harder on the CONSOLIDATE rule + allowlist.** Rejected. That is the status quo, and it is the additive-ratchet finding: papering over overlap with discipline instead of removing it. The allowlist grows; the overlap remains.

- **Mint a new single mega-state-file.** Rejected. Collapsing the live dashboard and the append-only history into one file destroys the mutable-vs-append-only boundary that makes the journal trustworthy as a record. The function split is the point.

- **Build a tool/daemon for the clear-safety check.** Rejected as the additive reflex. The gate is a procedure in a persona, writing to files that already exist. The whole value is that it adds a habit, not a subsystem.

## 7. Trade-offs

- `journal.md` carries more (decisions + reviews + sessions). Mitigation: tags make it filterable; if size becomes a problem, periodise (`journal.md` + `journal-archive/`) -- not built now (YAGNI).
- Existing targets need a one-time migration of their satellite files. Mitigation: retrofit prompt template (task 6). Targets that never adopt the migration keep working -- the retired filenames are removed from the *canonical* set, not forbidden; a target with a legacy `decisions.md` is a migration candidate, not a breakage.

## 8. Consumer sweep (recording + consumption, end to end)

Folding the files in the *description* (orchestrator persona + CLAUDE.md tree) is not enough: every place that *records into* or *reads from* the retired files must move to the new model, or the harness contradicts itself (e.g. the persona says "eight entries" while the onboarding playbook scaffolds eleven and a new target is "born legacy"). The implementation pass therefore swept all consumers, passing each through the same simplification / de-duplication / "still earns its place" gate rather than mechanically repointing paths:

- **`onboarding.md`** -- workspace scaffold drops the three satellites + `inconsistencies.md`; the assessment flow writes the ranked report as an `assessment.md` section; all "record in decisions.md" opt-out spots become `[DECISION]` journal entries; the re-onboard backup step is removed (the journal is append-only, so `[DECISION]`/`[REVIEW]` history is preserved without a copy); close-out gates rephrased to journal `[REVIEW]` + dashboard `## Open Questions`.
- **`health-check.md`** -- baseline read list updated; standard-tool opt-out checks look for a `[DECISION]` journal entry; phase-completion writes a `[REVIEW]` journal entry (the former `review-history.md` append) and folds the redundant `inconsistencies.md` update into the assessment update.
- **`tools.md`, `tools/README.md`, `permission-baselines.md`, `seed-harness-sync-marker.md.template`, `docs/tool-integration-architecture-analysis.md`** -- all "record in decisions.md" -> `[DECISION]` journal entries.
- **`harness-reviewer.md`** -- the lift-candidate extended-scan sources point at `grep '[DECISION]'/'[REVIEW]'` over the journal instead of the retired files (the target-side `docs/AE/decisions.md` convention is a separate, target-owned file and is left alone).

Out of scope (deliberately not rewritten): historical CHANGELOG entries (a changelog records what was true at each release; rewriting it falsifies history), archived/intake OpenSpec proposals (frozen history), and OpenSpec change-proposal-level `decisions.md` files (an OpenSpec convention, not the target state model).
