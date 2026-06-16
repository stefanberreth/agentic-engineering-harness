---
captured-at: 2026-06-15T11:47:31Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, pre-launch edit pass
area: playbook
status: untriaged
---

# No role owns working-tree debris / orphaned-file cleanup

**Trigger:** A developer report-back flagged an untracked, orphaned source+test file pair sitting in the target tree -- not part of the current task, almost certainly a leftover from an abandoned push or a hard-rebooted dev sandbox. It was silently reddening local quality gates (a test-collection failure plus two style ratchets), and the orchestrator initially waved it off as "another strand's work" rather than routing it. The operator pointed out that in an agent-driven project there is no parallel human editor: all such debris is agent-authored, so the harness itself must own cleanup -- yet no role does.

**Insight:** AEH's role model has a gap around filesystem hygiene of the target working tree. The reviewer is diff-scoped by design, so an orphan outside the current diff is invisible to it. The archaeologist can detect debris (it reads the whole tree, read-only) but does not own disposal. The developer is how orphans get created in the first place (a crashed or abandoned session leaves uncommitted files behind). The orchestrator tracks pipeline state, not FS hygiene, and currently treats untracked-file accumulation in report-backs as background noise instead of a routable signal. Net effect: dead-wood files (orphaned modules, stale config/env backups, abandoned scaffolding) accumulate over a long-running transformation with no owner, and only surface accidentally when they break a gate.

**Suggested change:**
- Give the **health-check playbook** a "working-tree hygiene" dimension: detect untracked orphans, unreferenced modules, and stale backup files (e.g. `*.bak` / `*.session-bak` / dead env copies), and report them as a delta. The health check is already the recurring per-target maintenance pass, so it is the natural periodic net.
- Make **disposal** an explicit developer-task pattern (verify-unreferenced, then remove or quarantine reversibly -- never blind-delete), orchestrator-directed.
- Add an **orchestrator standing-signal** note: untracked-file accumulation surfaced in a report-back is a finding to route, not noise to wave off. Capture the failure mode (mislabelling agent-authored debris as an external "strand").

**Memory updates:** none directly superseded. Relates to the existing chain-wrapper rule that pre-flight filters `??` untracked entries from `git status --porcelain` (that rule TOLERATES untracked debris so chains can run; this capture is about who eventually CLEANS it). Triage should reconcile the two so "tolerate during a run" and "sweep periodically" are clearly distinct mechanisms, not contradictory.
