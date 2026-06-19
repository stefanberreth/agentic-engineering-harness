---
slug: chain-fabric-lift
status: proposed
since: 2026-06-01
provenance: private intake captures (2026-05-31) -- the modal-states/chain-fabric requirements capture and the chain-fabric implementation-comparison capture; in targets/_harness-private/intake/, sanitized at promotion
---

# Chain-fabric lift: converged template + modal-states + operating procedure

## What

Lift a converged multi-prompt chain-execution fabric into `templates/scripts/`, based on a structured side-by-side comparison of two independent target implementations of the same fabric (call them implementation A and implementation B). Add a "Modal states" subsection (interactive / prompt-chaining) and a requirements-level chain-fabric description to the `target-orchestrator` persona. Lift artefacts: converged wrapper, heartbeat helper writing both per-run and shared-path logs, monitor helper, alive helper, mock-claude test layer, operating-procedure document.

## Why

The `target-orchestrator` persona describes multi-prompt chains in detail but treats "running a chain" and "talking to the operator" as the same undifferentiated mode. In practice the orchestrator is continuously in one of two distinct postures (interactive vs prompt-chaining). The chain fabric (wrapper, heartbeat, monitor, alive, launch + watch procedure) is specified only as prose pattern -- no shippable artefact and no operating procedure. A target orchestrator re-derives the launch/monitor mechanism from scratch each time.

Two independent implementations of this fabric now exist across the target portfolio. Lifting either directly into `templates/scripts/` locks in design choices the other arrived at differently for good reasons. The harness benefits from a deliberate convergence pass while both implementations are fresh -- cheap now, expensive later when each accretes bug-fixes targeting its specific shape. The implementation-comparison capture contains a full divergence-point comparison table and a convergence recommendation; this proposal authorises lifting the converged design.

## Scope

In scope:
- New OpenSpec design.md in this proposal directory carrying the converged-design specification (divergence table + per-dimension decision: implementation A / implementation B / merge), authored target-detail-free.
- Template artefacts at `templates/scripts/`:
  - `aeh-overnight.sh.template` -- converged wrapper (a reusable positional-args shape; a zero-commit HALT guard; a session-JSONL watchdog; granular numeric exit codes; env-seeded ETA; dual-timezone timestamps).
  - `aeh-heartbeat.sh.template` -- a separate heartbeat that writes BOTH a per-run human `progress.log` AND a shared-path append-only `chain-status.log` (operator memorises the path once, tails forever).
  - `aeh-monitor.sh.template` -- a live model-text follower (auto-detects newest session JSONL, auto-follows step rollover).
  - `aeh-alive.sh.template` -- a portable macOS+Linux one-shot liveness check.
  - `mock-claude.sh.template` + `test-plumbing.sh.template` -- an `AEH_TEST_MODE` env-driven test layer.
  - `chain-fabric.md` -- requirements + procedure + modal-state vocabulary.
- `templates/personas/target-orchestrator.md` updates:
  - New "Modal states" subsection: interactive vs prompt-chaining; how they interleave; relation to the four end-states (MONITORING-BACKGROUND maps to prompt-chaining mode).
  - Expand the chain-wrapper guidance into a requirements-level pointer to `templates/scripts/chain-fabric.md` + note that a target orchestrator may and should author per-target wrappers from these templates on operator approval.
- Deprecate the per-chain hand-clone pattern in favor of the reusable wrapper.
- CHANGELOG entry under [Unreleased] Added + Changed.

Out of scope:
- Auto-migrating existing target wrappers (per-target hand-cloned chain wrappers stay as-is until next-touch).
- Auto-detection of optimal halt thresholds, ETA tuning, etc.
- Cross-CLI portability of the chain fabric (the templates are Claude-CLI-specific; portability is the `harness-portability-assessment` proposal's concern).
- Reviewer-step commit discipline (separate proposal: `reviewer-prompt-commit-step`).

## Acceptance criteria

1. design.md committed with full divergence table + per-dimension decision (target-detail-free).
2. Six template artefacts at `templates/scripts/` exist and are tested (the mock-claude + test-plumbing layer applied).
3. `target-orchestrator` persona has the Modal states subsection + chain-fabric pointer.
4. CHANGELOG entry.
5. The structured side-by-side comparison already happened in the implementation-comparison capture -- this proposal lifts the conclusion, it does not re-do the comparison.

## References

- Provenance: two private intake captures (2026-05-31) -- the modal-states/chain-fabric requirements capture (requirements baseline) and the chain-fabric implementation-comparison capture (comparison + convergence). Both in `targets/_harness-private/intake/`; consult them there for the divergence table.
- Memory: `feedback_autonomous_run_monitoring_gap`, `feedback_claude_print_streaming_pattern`, `feedback_autonomous_launch_visibility_pattern`.
- Pairs with: `openspec/changes/reviewer-prompt-commit-step/` (chain-safety on the reviewer step); both harden the chain fabric.
