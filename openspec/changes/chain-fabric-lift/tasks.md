---
slug: chain-fabric-lift
---

# Tasks

Implementation A and implementation B below are the two independent target
implementations being converged; the divergence table lives in the private
implementation-comparison capture (consult it in `targets/_harness-private/intake/`).

## Task 1: design.md -- converged-design specification
- Author `openspec/changes/chain-fabric-lift/design.md` with the full divergence table (lift from the implementation-comparison capture) + per-dimension decision (implementation A / implementation B / merge). Author target-detail-free.
- Decisions ratified per the convergence-recommendation section: session-JSONL watchdog (A); zero-commit HALT (B); positional-args wrapper (A); stable-path pulse file (B); etc.
- **Signal:** design.md present with table + decisions.

## Task 2: aeh-overnight.sh.template (converged wrapper)
- Lift from implementation A base, fold in implementation B's zero-commit HALT guard + pluggable multi-gate pre-flight (dirty-tree as its own exit code).
- Granular exit codes (0/2/3/4/5/6/7).
- Env-seeded ETA via `AEH_STEP_ESTIMATES_SEC`.
- Dual-timezone timestamps via `AEH_LOCAL_TZ` / `AEH_LOCAL_TZ_LABEL`.
- Per-step + total wall-clock caps.
- Session-JSONL watchdog (not stdout-capture).
- **Signal:** template script exists; `bash -n` clean; mock-claude smoke passes.

## Task 3: aeh-heartbeat.sh.template
- Separate file per implementation B's pattern.
- Writes per-run `progress.log` (human, dual-tz, ETA, step counter) AND shared `chain-status.log` (append-only, stable path, START/END banners).
- Auto-started by wrapper.
- **Signal:** template script exists; both log streams emit on test run.

## Task 4: aeh-monitor.sh.template
- Implementation A's live model-text follower: tails newest `~/.claude/projects/<encoded-cwd>/*.jsonl` through jq for assistant text; auto-follows step rollover via `.current-step` marker.
- **Signal:** template script exists; smoke run follows step rollover.

## Task 5: aeh-alive.sh.template
- Implementation B's portable macOS+Linux one-shot liveness check (uses `date -r`).
- Operator runs from inside or outside container.
- **Signal:** template script exists; works on both macOS and Linux.

## Task 6: Test layer
- `mock-claude.sh.template` + `test-plumbing.sh.template` per implementation A's pattern.
- `AEH_TEST_MODE` env-driven; verifies exit-code vocabulary across happy / sentinel-halt / non-zero-step / mtime-idle paths.
- **Signal:** test-plumbing PASS without API calls.

## Task 7: chain-fabric.md -- requirements + procedure + modal-state vocabulary
- Lift from implementation A's operating-procedure README.
- Covers: two modal states (interactive / prompt-chaining); interleaving rules; mode-transition handshake; launch + monitor procedure; halt-condition catalogue.
- **Signal:** doc present; covers all five elements.

## Task 8: target-orchestrator persona update
- Edit `templates/personas/target-orchestrator.md`:
  - New "Modal states" subsection (interactive vs prompt-chaining; mapping to four end-states; interleaving rules).
  - Expand the chain-wrapper guidance to point to `templates/scripts/chain-fabric.md` + note that targets author per-target wrappers from templates on operator approval.
- **Signal:** subsection present; pointer added.

## Task 9: CHANGELOG + archive
- CHANGELOG entry under [Unreleased] Added + Changed.
- Archive proposal post-bookend.
