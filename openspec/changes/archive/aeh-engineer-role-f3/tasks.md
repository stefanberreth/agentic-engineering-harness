# F3 tasks

Mechanical completion signal in brackets per task.

1. [x] Add the prompt-result pairing DoD subsection to target-orchestrator's
   report-back conventions.
   [signal: `grep -q 'Prompt-result pairing' templates/personas/target-orchestrator.md`]
2. [x] Reconcile developer section 6/7: paired report at docs/AE/reports/NNN-title.md,
   retrospective folded in, task-[N]-retrospective.md as fallback.
   [signal: `grep -q 'docs/AE/reports/NNN-title.md' templates/personas/developer.md`]
3. [x] Update reviewer intake to read the paired report path.
   [signal: `grep -q 'docs/AE/reports/NNN-title.md' templates/personas/reviewer.md`]
4. [x] CHANGELOG entry; validator + publication gate; commit; no push.
   [signal: validator exit 0; gate exit 0; commit landed]
