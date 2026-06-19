# B6 tasks

Mechanical completion signal in brackets per task.

1. [x] CLAUDE.md: add the enforced `docs/AE/`-only fence subsection; retire the
   soft "you CAN read target project files for assessment purposes" parenthetical.
   [signal: `grep -q 'enforced .docs/AE/.-only fence' CLAUDE.md`; `grep -c 'CAN read target project files' CLAUDE.md` == 0]
2. [x] orchestrator.md: add no-spelunking/no-rummaging bullet + fence subsection;
   reconcile the structural-facts line.
   [signal: `grep -q 'rummage the target tree' templates/personas/orchestrator.md`]
3. [x] permission-baselines.md: add the "AEH-side fence (orchestrator session ->
   target)" section + the deny-precedence design-call note.
   [signal: `grep -q 'AEH-side fence' templates/agents/claude-code/permission-baselines.md`]
4. [x] onboarding.md: mark Phase 2 as the bootstrap exception.
   [signal: `grep -q 'bootstrap exception' templates/playbooks/onboarding.md`]
5. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'docs/AE/-only fence' CHANGELOG.md`]
6. [x] Publication gate (`--staged` + `--message`); commit; no push.
   [signal: both gate invocations exit 0; commit landed locally]
