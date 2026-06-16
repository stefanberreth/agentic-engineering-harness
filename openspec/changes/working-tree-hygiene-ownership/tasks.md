# Tasks: Working-tree hygiene ownership

Ordered. Process/mechanism change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. health-check playbook -- working-tree hygiene dimension

- Add a dimension that detects untracked orphans, unreferenced modules, and stale backup files (`*.bak` / `*.session-bak` / dead env copies) and reports them as a delta against the last check.
- **Signal:** `grep -ci 'working-tree hygiene\|orphan\|unreferenced module\|stale backup' templates/playbooks/health-check.md` >= 1.

## 2. developer persona -- verify-then-dispose pattern

- Add a disposal pattern: confirm a file is genuinely unreferenced, then remove or quarantine reversibly; never blind-delete. Include the parked-WIP cautionary case (apparent debris may be stash-preserved work).
- **Signal:** `grep -ci 'verify.*dispose\|blind-delete\|quarantine\|unreferenced' templates/personas/developer.md` >= 1.

## 3. orchestrator persona -- standing-signal note

- Add a note: untracked-file accumulation in a report-back is a finding to route (to a verify-then-dispose developer task), not noise; name the mislabel-as-external-strand failure mode.
- **Signal:** `grep -ci 'untracked.*accumulat\|route.*not noise\|working-tree debris\|external strand' templates/personas/orchestrator.md` >= 1.

## 4. Reconcile with the chain-wrapper tolerate-untracked rule

- Add a one-paragraph reconciliation so "tolerate untracked during a run" (chain wrapper `??` filter) and "sweep periodically" (health check) read as two distinct mechanisms, placed where a reader of either rule finds it.
- **Signal:** `grep -rci 'tolerate.*during a run\|distinct mechanism\|sweep periodically' templates/playbooks/health-check.md templates/personas/orchestrator.md` >= 1.

## 5. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Added.
- **Signal:** `grep -ci 'working-tree hygiene\|orphan' CHANGELOG.md` >= 1.

## 6. Bookend + publication gate + commit

- Run `bin/validate-personas.sh` (full + `--staged` + `--message`). Block on FAIL.
- Harness-reviewer bookend before any push. Single commit; local only; operator authorizes push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
