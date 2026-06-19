# F1 tasks

Mechanical completion signal in brackets per task.

1. [x] Onboarding greenfield plan + short-circuit execute: place the two roles
   into `docs/AE/roles/` and the script into `docs/AE/bin/`.
   [signal: `grep -q 'docs/AE/roles/' templates/playbooks/onboarding.md` and `grep -q 'docs/AE/bin/' templates/playbooks/onboarding.md`]
2. [x] Onboarding brownfield plan: same placement task.
   [signal: brownfield plan block references `docs/AE/roles/` placement]
3. [x] Phase 6a base-template-placement: broaden the placement prompt to carry +
   place the two roles + the executable script.
   [signal: Phase 6a text names target-aeh-reviewer/engineer + aeh-practice-check.sh]
4. [x] Broaden `refresh-base-personas.md.template` to refresh the two roles +
   script; broaden H1 + intro.
   [signal: `grep -q 'docs/AE/roles' templates/prompts/refresh-base-personas.md.template` and `grep -q 'aeh-practice-check' templates/prompts/refresh-base-personas.md.template`]
5. [x] Update `target-aeh-reviewer.md`: invoke `docs/AE/bin/aeh-practice-check.sh .`;
   remove the "until delivery wiring lands" caveat.
   [signal: `grep -q 'docs/AE/bin/aeh-practice-check.sh' templates/personas/target-aeh-reviewer.md`; no "Until that delivery wiring lands" string]
6. [x] CLAUDE.md structure tree: note target-side delivery homes; fix stale "6 base
   personas" -> five.
   [signal: no "6 base personas" in CLAUDE.md]
7. [x] `templates/project/CLAUDE.md.template`: one-line note the AEH-practice roles
   load from `docs/AE/roles/` and the check runs from `docs/AE/bin/`.
   [signal: `grep -q 'docs/AE/roles' templates/project/CLAUDE.md.template`]
8. [x] CHANGELOG [Unreleased] entry.
   [signal: `grep -q 'F1' CHANGELOG.md` or delivery-wiring entry present]
9. [ ] Validator passes; publication gate (`--staged` + `--message`); commit; no push.
   [signal: validator exit 0; both gate invocations exit 0; commit landed locally]
