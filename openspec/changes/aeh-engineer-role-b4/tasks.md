# B4 tasks

Mechanical completion signal in brackets per task.

1. [x] Create `bin/aeh-practice-check.sh` (registry runner; PASS/FAIL/SKIP;
   exit 0/1/3; `--list`/`-h`).
   [signal: `bash bin/aeh-practice-check.sh --list` lists 3 checks; exit 0]
2. [x] Ship the three checks (prompt-result-pairing, role-activation-base,
   overlay-header-target-side); verify FAIL/PASS/SKIP against a fixture.
   [signal: fixture with orphans + missing base + harness-path header yields 3 FAIL, exit 1]
3. [x] Wire `target-aeh-reviewer.md` to name + invoke the framework with the
   cross-layer delivery note.
   [signal: `grep -q 'aeh-practice-check.sh' templates/personas/target-aeh-reviewer.md`]
4. [x] Add the script to the CLAUDE.md bin/ structure tree.
   [signal: `grep -q 'aeh-practice-check.sh' CLAUDE.md`]
5. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'aeh-practice-check' CHANGELOG.md`]
6. [x] Publication gate (`--staged` + `--message`); commit; no push.
   [signal: both gate invocations exit 0; commit landed locally]
