---
slug: working-tree-hygiene-ownership
status: proposed
since: 2026-06-16
---

# Working-tree hygiene: give orphaned-file cleanup an owner

## What

Close the gap in AEH's role model around filesystem hygiene of the target working tree. In an agent-driven project there is no parallel human editor, so all working-tree debris (orphaned modules, stale config/env backups, abandoned scaffolding) is agent-authored -- yet no role owns its cleanup. Three small, role-appropriate additions, plus an explicit reconciliation with the chain-wrapper "tolerate untracked during a run" rule so the two mechanisms are distinct rather than contradictory:

- **health-check playbook** gains a "working-tree hygiene" dimension: detect untracked orphans, unreferenced modules, and stale backup files (`*.bak` / `*.session-bak` / dead env copies), reported as a delta. The health check is already the recurring per-target maintenance pass, so it is the natural periodic net.
- **developer** gains an explicit disposal pattern: when directed to clear debris, VERIFY-then-dispose -- confirm the file is genuinely unreferenced, then remove or quarantine reversibly (never blind-delete). This is a hard safety rule: a real case showed apparent "debris" was stash-preserved parked WIP, so disposal that does not verify-first destroys work.
- **orchestrator** gains a standing-signal note: untracked-file accumulation surfaced in a report-back is a finding to ROUTE (to a verify-then-dispose developer task), not noise to wave off as "another strand's work."

## Why

AEH's role model has a hole around target working-tree hygiene. The reviewer is diff-scoped by design, so an orphan outside the current diff is invisible to it. The archaeologist can detect debris (it reads the whole tree, read-only) but does not own disposal. The developer is how orphans get created (a crashed or abandoned session leaves uncommitted files behind). The orchestrator tracks pipeline state, not FS hygiene, and currently treats untracked-file accumulation in report-backs as background noise rather than a routable signal. Net effect: dead-wood files accumulate over a long-running transformation with no owner and surface only accidentally -- e.g. when an orphaned source+test pair silently reddens local quality gates (a test-collection failure plus style ratchets) and the orchestrator initially waves it off rather than routing it.

The reconciliation matters: an existing chain-wrapper rule pre-flight FILTERS `??` untracked entries from `git status --porcelain` so chains can run over a tree that legitimately keeps operator-side state files untracked. That rule TOLERATES untracked debris *during a run*; this proposal assigns who eventually CLEANS it *between runs*. Stated together they are two distinct mechanisms (tolerate-during-a-run vs sweep-periodically), not a contradiction -- and the proposal must say so explicitly so a future reader does not read them as conflicting.

## Scope

In scope:

- health-check playbook: a "working-tree hygiene" dimension (detect untracked orphans / unreferenced modules / stale backups; report as delta).
- developer persona: a verify-then-dispose pattern (confirm unreferenced -> remove or quarantine reversibly; never blind-delete; the parked-WIP cautionary case).
- orchestrator persona: a standing-signal note (untracked accumulation in a report-back is a finding to route, not noise; name the mislabel-as-external-strand failure mode).
- An explicit one-paragraph reconciliation with the chain-wrapper "tolerate untracked during a run" rule, placed where a reader of either rule will find it (health-check dimension and/or the chain-wrapper guidance).
- CHANGELOG [Unreleased] entry.

Out of scope:

- Any automated sweeper/cron that deletes files. Disposal is verify-then-dispose, human/agent-judged, orchestrator-routed -- never automatic deletion (the parked-WIP case is exactly why).
- Harness-side working-tree debris ownership. This proposal is about the TARGET tree; harness-side debris ownership (if needed) belongs with the harness role-architecture work, not here.
- Changing the chain-wrapper filter itself; this proposal only reconciles its wording with the new sweep dimension.

## Acceptance criteria

1. health-check playbook carries a working-tree hygiene dimension producing a delta of untracked orphans / unreferenced modules / stale backups.
2. developer persona carries the verify-then-dispose pattern with the never-blind-delete rule and the parked-WIP cautionary note.
3. orchestrator persona carries the standing-signal note (route, do not wave off) and names the mislabel-as-external-strand failure mode.
4. A reconciliation statement makes "tolerate untracked during a run" (chain wrapper) and "sweep periodically" (health check) read as two distinct mechanisms, not a contradiction.
5. CHANGELOG [Unreleased] entry present.

## References

- Provenance: `provenance.md` (intake capture 2026-06-15-1147).
- Reconciled rule: chain-wrapper porcelain `??` filter (`feedback_porcelain_filter_untracked`).
- Safety refinement (verify-not-blind-delete; parked-WIP case): noted in the triage handoff for this capture.
