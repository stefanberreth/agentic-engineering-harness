---
slug: chain-fabric-lift
status: proposed
since: 2026-06-01
intake-primary: openspec/changes/_intake/2026-05-31-1846-orchestrator-modal-states-chain-fabric-77c32eea48bc.md
intake-secondary: openspec/changes/_intake/2026-05-31-1910-chain-fabric-impl-comparison-with-hex-77c32eea48bc.md
---

# Chain-fabric lift: converged template + modal-states + operating procedure

## What

Lift a converged multi-prompt chain-execution fabric into `templates/scripts/` based on a structured side-by-side comparison of two independent target implementations (<target-A> at `targets/<target-A>/deliverables/scripts/` and hex at `targets/hex/deliverables/`). Add a "Modal states" subsection (interactive / prompt-chaining) and a requirements-level chain-fabric description to the orchestrator persona. Lift artefacts: converged wrapper, heartbeat helper writing both per-run and shared-path logs, monitor helper, alive helper, mock-claude test layer, operating-procedure document.

## Why

The orchestrator persona describes multi-prompt chains in detail but treats "running a chain" and "talking to the operator" as the same undifferentiated mode. In practice the orchestrator is continuously in one of two distinct postures (interactive vs prompt-chaining). The chain fabric (wrapper, heartbeat, monitor, alive, launch + watch procedure) is specified only as prose pattern -- no shippable artefact and no operating procedure. A target orchestrator re-derives the launch/monitor mechanism from scratch each time.

Two independent implementations now exist: <target-A>'s and hex's. Lifting either directly into `templates/scripts/` locks in design choices the other arrived at differently for good reasons. The harness benefits from a deliberate convergence pass while both implementations are fresh -- cheap now, expensive later when each accretes bug-fixes targeting its specific shape. The intake captures contain a full divergence-point comparison table and a convergence recommendation; this proposal authorises lifting the converged design.

## Scope

In scope:
- New OpenSpec design.md in this proposal directory carrying the converged-design specification (divergence table + per-dimension decision: `<target-A>` / `hex` / `merge`).
- Template artefacts at `templates/scripts/`:
  - `aeh-overnight.sh.template` -- converged wrapper (<target-A>'s positional-args reusable shape; hex's zero-commit HALT guard; <target-A>'s session-JSONL watchdog; granular numeric exit codes; env-seeded ETA; dual-timezone timestamps).
  - `aeh-heartbeat.sh.template` -- separate per hex's pattern, writes BOTH `progress.log` (per-run, human) AND shared-path append-only `chain-status.log` (operator memorises path once, tails forever).
  - `aeh-monitor.sh.template` -- <target-A>'s live model-text follower (auto-detects newest session JSONL, auto-follows step rollover).
  - `aeh-alive.sh.template` -- hex's portable macOS+Linux one-shot liveness check.
  - `mock-claude.sh.template` + `test-plumbing.sh.template` -- <target-A>'s test layer (`AEH_TEST_MODE` env-driven).
  - `chain-fabric.md` -- requirements + procedure + modal-state vocabulary (lifted from <target-A>'s README).
- `templates/personas/orchestrator.md` updates:
  - New "Modal states" subsection: interactive vs prompt-chaining; how they interleave; relation to the four end-states (MONITORING-BACKGROUND maps to prompt-chaining mode).
  - Expand "Execute via a chain wrapper" into a requirements-level pointer to `templates/scripts/chain-fabric.md` + note that a target orchestrator may and should author per-target wrappers from these templates on operator approval.
- Deprecate the per-chain hex hand-clone pattern in favor of the reusable wrapper.
- CHANGELOG entry under [Unreleased] Added + Changed.

Out of scope:
- Auto-migrating existing target wrappers (hex's 15 hand-cloned `aeh-hex-chain-A.sh` through `-M.sh` stay as-is until next-touch).
- Auto-detection of optimal halt thresholds, ETA tuning, etc.
- Cross-CLI portability of the chain fabric (the templates are Claude-CLI-specific; portability is the `harness-portability-assessment` proposal's concern).
- Reviewer-step commit discipline (separate proposal: `reviewer-prompt-commit-step`).

## Acceptance criteria

1. design.md committed with full divergence table + per-dimension decision.
2. Six template artefacts at `templates/scripts/` exist and are tested (<target-A>'s mock-claude + test-plumbing layer applied).
3. Orchestrator persona has Modal states subsection + chain-fabric pointer.
4. CHANGELOG entry.
5. Both intake captures status updated to promoted (point both to this proposal).
6. The intake's "structured side-by-side comparison" already happened in the 1910 capture -- this proposal lifts the conclusion, does not re-do the comparison.

## References

- Intake (primary, requirements baseline): `openspec/changes/_intake/2026-05-31-1846-orchestrator-modal-states-chain-fabric-77c32eea48bc.md`
- Intake (secondary, comparison + convergence): `openspec/changes/_intake/2026-05-31-1910-chain-fabric-impl-comparison-with-hex-77c32eea48bc.md`
- <target-A> implementation: `targets/<target-A>/deliverables/scripts/`
- hex implementation: `targets/hex/deliverables/` (per-chain wrappers + `.runs/` shared pulse file + `alive.sh`)
- Memory: `feedback_autonomous_run_monitoring_gap`, `feedback_claude_print_streaming_pattern`, `feedback_autonomous_launch_visibility_pattern`
- Pairs with: `openspec/changes/reviewer-prompt-commit-step/` (chain-safety on the reviewer step); both harden the chain fabric per the 1846 intake's note
