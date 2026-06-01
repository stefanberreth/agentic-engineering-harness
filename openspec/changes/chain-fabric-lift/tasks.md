---
slug: chain-fabric-lift
---

# Tasks

## Task 1: design.md -- converged-design specification
- Author `openspec/changes/chain-fabric-lift/design.md` with the full divergence table (lift from intake 1910) + per-dimension decision (`<target-A>` / `hex` / `merge`).
- Decisions ratified per the 1910 convergence-recommendation section: session-JSONL watchdog (<target-A>); zero-commit HALT (hex); positional-args wrapper (<target-A>); stable-path pulse file (hex); etc.
- **Signal:** design.md present with table + decisions.

## Task 2: aeh-overnight.sh.template (converged wrapper)
- Lift from <target-A> base, fold in hex's zero-commit HALT guard + pluggable multi-gate pre-flight (dirty-tree as its own exit code).
- Granular exit codes (0/2/3/4/5/6/7).
- Env-seeded ETA via `AEH_STEP_ESTIMATES_SEC`.
- Dual-timezone timestamps via `AEH_LOCAL_TZ` / `AEH_LOCAL_TZ_LABEL`.
- Per-step + total wall-clock caps.
- Session-JSONL watchdog (not stdout-capture).
- **Signal:** template script exists; `bash -n` clean; mock-claude smoke passes.

## Task 3: aeh-heartbeat.sh.template
- Separate file per hex's pattern.
- Writes per-run `progress.log` (human, dual-tz, ETA, step counter) AND shared `chain-status.log` (append-only, stable path, START/END banners).
- Auto-started by wrapper.
- **Signal:** template script exists; both log streams emit on test run.

## Task 4: aeh-monitor.sh.template
- <target-A>'s live model-text follower: tails newest `~/.claude/projects/<encoded-cwd>/*.jsonl` through jq for assistant text; auto-follows step rollover via `.current-step` marker.
- **Signal:** template script exists; smoke run follows step rollover.

## Task 5: aeh-alive.sh.template
- hex's portable macOS+Linux one-shot liveness check (uses `date -r`).
- Operator runs from inside or outside container.
- **Signal:** template script exists; works on both macOS and Linux.

## Task 6: Test layer
- `mock-claude.sh.template` + `test-plumbing.sh.template` per <target-A>'s pattern.
- `AEH_TEST_MODE` env-driven; verifies exit-code vocabulary across happy / sentinel-halt / non-zero-step / mtime-idle paths.
- **Signal:** test-plumbing PASS without API calls.

## Task 7: chain-fabric.md -- requirements + procedure + modal-state vocabulary
- Lift from <target-A>'s README.
- Covers: two modal states (interactive / prompt-chaining); interleaving rules; mode-transition handshake; launch + monitor procedure; halt-condition catalogue.
- **Signal:** doc present; covers all five elements.

## Task 8: Orchestrator persona update
- Edit `templates/personas/orchestrator.md`:
  - New "Modal states" subsection (interactive vs prompt-chaining; mapping to four end-states; interleaving rules).
  - Expand "Execute via a chain wrapper" to point to `templates/scripts/chain-fabric.md` + note that targets author per-target wrappers from templates on operator approval.
- **Signal:** subsection present; pointer added.

## Task 9: CHANGELOG + intake statuses + archive
- CHANGELOG entry under [Unreleased] Added + Changed.
- Both intake captures (1846 + 1910) status updated to promoted, both promoted-to: chain-fabric-lift.
- Archive proposal post-bookend.
