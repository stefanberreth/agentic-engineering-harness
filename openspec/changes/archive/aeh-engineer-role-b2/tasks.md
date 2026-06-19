# B2 tasks

Mechanical completion signal in brackets per task.

1. [x] Reframe the scope-clarification section to contrast `harness-reviewer` with
   `target-aeh-reviewer` (not the health-check playbook); add detect/remediate
   placement.
   [signal: `grep -q 'target-aeh-reviewer' templates/personas/harness-reviewer.md`;
   no "harness-reviewer vs AEH health-check" heading remains]
2. [x] Remove the Propagation-Impact Assessment Mode body; leave a pointer to
   `target-aeh-reviewer.md`.
   [signal: only ONE line matches `Propagation-Impact` and it is the pointer]
3. [x] Remove Dimension 4 target-overlay branches + Archaeologist target-baseline
   subsection + the `/path/to/target` validate invocation (Dim 4 + bash block).
   [signal: `grep -c 'reviewing a target' harness-reviewer.md` == 1 (the
   do-NOT-read-target line); no `/path/to/target`]
4. [x] Trim Extended scan sources to harness-side evidence only.
   [signal: no `docs/AE/decisions.md` / target-side `docs/AE/reports/` direct-read
   bullet remains]
5. [x] Fold: add "No harness-only path or script references in base templates"
   check to Dimension 4.
   [signal: `grep -q 'harness-only path' harness-reviewer.md`]
6. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'B2' CHANGELOG.md` under the harness-reviewer purification entry]
7. [x] Publication gate (`--staged` + `--message`); commit; no push.
   [signal: both validator invocations exit 0; commit landed locally]
