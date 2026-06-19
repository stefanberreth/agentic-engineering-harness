# F4 tasks

Mechanical completion signal in brackets per task.

1. [x] Add the settled-exception note for the orchestrator-state.md /
   orchestrator-batch-regime.md filenames in CLAUDE.md near the back-compat note.
   [signal: `grep -q 'Settled exception: the .orchestrator-state.md' CLAUDE.md`]
2. [x] No rename performed (the ~8 referencing files still use the filename).
   [signal: `grep -rq 'orchestrator-state.md' templates/personas/target-orchestrator.md`]
3. [x] CHANGELOG entry; validator + publication gate; commit; no push.
   [signal: validator exit 0; gate exit 0; commit landed]
