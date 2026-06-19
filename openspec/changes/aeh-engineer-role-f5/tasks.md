# F5 tasks

Mechanical completion signal in brackets per task.

1. [x] Add `permission-scope` to the CHECKS registry + a `check_permission_scope`
   function in bin/aeh-practice-check.sh (bypass / filesystem-escape /
   secret-literal / missing-deny; deterministic only).
   [signal: `bin/aeh-practice-check.sh --list` lists permission-scope; FAIL/PASS/SKIP behave per scenario]
2. [x] target-aeh-reviewer: add the permission-config-compliance dimension + the
   report/approve/fix/validate loop; add permission-scope to the framework list;
   note AEH-side-grant symptom-only routing.
   [signal: `grep -q 'permission-scope' templates/personas/target-aeh-reviewer.md`]
3. [x] target-aeh-engineer: add the permission-config remediation (apply on
   approval, re-run permission-scope to validate; target config only).
   [signal: `grep -q 'permission-scope' templates/personas/target-aeh-engineer.md`]
4. [x] harness-reviewer: add the AEH-side-grant-compliance reporting to Dimension 5
   (read the harness config directly; report exact change; aeh-engineer fixes).
   [signal: `grep -q 'AEH-side grant compliance' templates/personas/harness-reviewer.md`]
5. [x] aeh-engineer: add the AEH-side-grant report/approve/fix/validate loop to the
   fence-stewardship duty.
   [signal: `grep -q 'AEH-side grant compliance' templates/personas/aeh-engineer.md`]
6. [x] Update the B6 design-call note in permission-baselines.md (report built in;
   only the airtight lockdown deferred).
   [signal: `grep -q 'updated by F5' templates/agents/claude-code/permission-baselines.md`]
7. [x] CHANGELOG entry; validator + publication gate; commit; no push.
   [signal: validator exit 0; gate exit 0; commit landed]
