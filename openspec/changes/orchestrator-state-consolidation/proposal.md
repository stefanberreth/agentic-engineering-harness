---
slug: orchestrator-state-consolidation
status: proposed
since: 2026-06-06
---

# Orchestrator state consolidation + context-disposability gate

## What

Two coupled changes to how an orchestrator's per-target state is stored and how an orchestrator session is safely cleared:

1. **Consolidate the overlapping state files** in `targets/<slug>/` by function. Fold the three clearly-redundant satellite files -- `decisions.md`, `open-questions.md`, `review-history.md` -- into the existing live dashboard (`orchestrator-state.md`) and the existing append-only narrative (`journal.md`), preserving their lookup function via tags. The canonical churny-state set drops from "eleven canonical filenames" to a smaller set organised around four functions: durable identity, live dashboard, append-only history, phase artifacts.

2. **Add a pre-clear reconciliation gate** to the orchestrator persona: an explicit, cheap procedure that decides whether it is safe to `/clear` and reinitialise an orchestrator session without losing orientation. The gate is a reconstruct-and-diff (rebuild the session's orientation from the state files alone; compare to what the live context holds; the delta is the un-persisted state that must be flushed before clearing). The same procedure is the natural moment to prune state that no longer earns its place (the forgetting discipline below).

3. **Add a "still earns its place" forgetting question** to an existing harness-reviewer dimension, so the harness gains a pruning pass symmetric to its many capture pipelines.

## Why

This proposal is the implementation record of a retrospective on orchestrator state and control. The findings:

- **Additive ratchet, no forgetting.** Every harness pipeline (`_intake` inbox, BACKLOG, OpenSpec proposals, archive) *acquires* rules and state slots. There is no symmetric process for shedding, merging, or retiring one. The evidence is structural: `CLAUDE.md` hit its own 40k-char limit, and the orchestrator state tree grew to "eleven canonical filenames" with a CONSOLIDATE rule (`orchestrator.md` Principles) and an 11-name allowlist papering over the overlap rather than removing it.

- **State overlap.** `orchestrator-state.md` already consolidates a live dashboard (Pipeline Position, Prompt Execution Log, Review Tracking, Outcome Scorecard, Session Handoff Notes). Alongside it, `decisions.md`, `open-questions.md`, and `review-history.md` duplicate concerns the dashboard or `journal.md` already hold: decisions are dated events (journal), open questions are current state (dashboard), review history is dated findings (journal/dashboard). Three of the files exist mainly because no one folded them.

- **Context disposability is unmodelled.** The orchestrator runs a different context regime from a target session. A target session is tabula-rasa-from-specs: clearing is safe by construction. An orchestrator session accumulates orientation (the objective, the why-behind-the-current-move, open threads) that lives partly in the context window and is not guaranteed to be reflected in the state files. Operators currently judge "is it safe to clear the orchestrator" by feel. That is unsafe: clearing can silently lose orientation. A reconstruct-and-diff gate makes the safety condition explicit and, over time, drives the state files toward completeness so clearing becomes reliably safe.

- **Resource link.** A fat orchestrator context window is a fat process heap. On memory-constrained hosts a bloated session is an OOM risk. Making clear-and-reinitialise safe is therefore also an operational-resilience win, not only a clarity win.

The fix is deliberately minimal and folds into existing mechanisms rather than adding subsystems -- consistent with the additive-ratchet finding that motivates it.

## Scope

In scope:

- Define the function-based canonical state model (durable identity / live dashboard / append-only history / phase artifacts) in `design.md`.
- Fold `decisions.md` -> `journal.md` entries tagged `[DECISION]`; `review-history.md` -> `journal.md` entries tagged `[REVIEW]`; `open-questions.md` -> a new `## Open Questions` section in `orchestrator-state.md`. Preserve lookup via tags (greppable).
- Update the canonical-filename allowlist in `orchestrator.md` Principles ("eleven canonical filenames") and the `targets/<slug>/` listing in `CLAUDE.md` "Target Project Workspace Structure" so both describe the SAME reduced set.
- Add a "Pre-clear reconciliation" subsection to `orchestrator.md` (procedure + one-line delta-log format + "fix the slot, not just the instance" rule).
- Add the "still earns its place" forgetting question to an existing harness-reviewer dimension (Documentation Currency or Template Consistency -- decided in design).
- Add a retrofit prompt template for existing targets to migrate their satellite files.
- CHANGELOG [Unreleased] entry.

Out of scope (recorded here for the historical record; deferred to separate proposals):

- **Cross-container machinery rationalisation** (Finding B: ownership markers vs the host RAM ceiling that prevents the multi-session scale they arbitrate). Touches `harness-cross-container-isolation` (active). Deferred.
- **`harness-sync-sha` simplification** (Finding C: a version-vector pattern for a solo operator; a `git log` one-liner may suffice). Touches `harness-update-propagation-signal` (active). Deferred.
- **Leak-enforcement layer de-duplication** (Finding E: four-to-six overlapping layers for one concern). Deferred.
- **Operating-regime taxonomy review** (Finding F: a third named regime is a signal to ask whether "regimes" is still the right abstraction). Deferred.
- **Harness-maintainer role charter** (Finding G: who owns "de-facto behaviour vs file-lore divergence" and harness re-engineering). Separate companion proposal `harness-maintainer-role-charter`.
- **CLAUDE.md global slimming.** Owned by existing proposal `claude-md-size-discipline`. This proposal does not touch it beyond the workspace-structure listing; the in-place-compression vs extract-to-reference-docs mechanism choice is reconciled there, not here.
- **Aggressive fold of `tasks.md` into the dashboard.** Considered and NOT recommended (see design.md "Alternatives"): `tasks.md` is referenced directly by prompts (lean-prompt convention) and folding it risks the pointer convention for marginal gain. Left as a future decision only if churn pain is observed.

## Acceptance criteria

1. `CLAUDE.md` "Target Project Workspace Structure" and `orchestrator.md` "State Initialisation" + Principles describe the SAME canonical file set (verifiable by comparing both; no divergence).
2. `decisions.md`, `open-questions.md`, and `review-history.md` no longer appear as separate canonical filenames in either file.
3. `design.md` contains a migration mapping table: every retired filename maps to a destination (file + section + tag). No content class unmapped -- this table is the baby-not-thrown-out proof.
4. `orchestrator.md` contains a "Pre-clear reconciliation" subsection with the reconstruct-and-diff procedure and the delta-log line format.
5. The harness-reviewer carries the "still earns its place" question inside an existing dimension (no new dimension unless explicitly decided).
6. A retrofit prompt template exists under `templates/prompts/` for migrating an existing target's satellite files.
7. CHANGELOG [Unreleased] entry present.
8. A before/after function table demonstrates each retired file's function is preserved in its destination (no rule or lookup capability lost).

## References

- Retrospective: harness self-review, 2026-06-06 session (orchestrator field-notes + close read of `orchestrator.md`, `harness-reviewer.md`, `openspec/`).
- Related active proposals: `claude-md-size-discipline`, `harness-cross-container-isolation`, `harness-update-propagation-signal`, `orchestrator-manage-dont-do`.
- Companion proposal: `harness-maintainer-role-charter` (the role-governance finding).
- Anchors: `orchestrator.md` "State Initialisation" + Principles; `CLAUDE.md` "Target Project Workspace Structure".
