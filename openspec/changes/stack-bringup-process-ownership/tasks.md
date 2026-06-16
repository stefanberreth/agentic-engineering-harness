# Tasks: Stack-bringup process-ownership

Ordered. Process/mechanism change -- no formal spec deltas. Each task carries a mechanical signal.

## 1. regression-check template -- prove process ownership

- Rewrite `templates/prompts/regression-check.md.template` section 4 (Runtime Smoke Test): capture the launched PID, assert that PID owns the listening port, scan the launch log for crash markers, detect a silent port-bump, before declaring the launch healthy. Remove reliance on a bare `curl http://localhost:[PORT]` as sufficient proof.
- Replace teardown guidance with by-PID teardown using whatever the container has (do not assume `pkill`/`lsof`/`fuser`); assert ports clear afterward.
- Add the two adjacent-trap notes: do not hardcode a health path (DB-gated `/health` may 503; probe a lighter liveness endpoint), do not assume `.env` is greppable (read key-by-key programmatically).
- **Signal:** `grep -ci 'process ownership\|PID\|port-bump\|owns the\|by-PID' templates/prompts/regression-check.md.template` >= 1 AND `grep -c 'pkill' templates/prompts/regression-check.md.template` reflects only a "do not assume pkill" mention (no bare pkill teardown instruction remains).

## 2. Playbook stack-bringup steps

- In onboarding + health-check playbooks, wherever a stack-bringup / dev-server step exists, add the teardown-by-PID + prove-ownership guidance or a pointer to the regression-check template's hardened sequence.
- **Signal:** `grep -rci 'process ownership\|prove.*ownership\|by-PID' templates/playbooks/` >= 1, OR a verified note that no playbook currently has a stack-bringup step (then this task is a documented no-op).

## 3. Promote-to-script recommendation

- Add a recommendation (in the regression-check template and/or the health-check playbook) that recurring stack-bringup be promoted to a hardened per-target script/skill, naming the ownership checks it must perform (capture-PID, assert-PID-owns-port, log-crash-scan, port-bump-detect, portable teardown).
- **Signal:** `grep -rci 'hardened\|script/skill\|per-target script' templates/prompts/regression-check.md.template templates/playbooks/` >= 1.

## 4. CHANGELOG entry

- Add to `CHANGELOG.md` [Unreleased] Changed.
- **Signal:** `grep -ci 'process ownership\|stack-bringup\|process-ownership' CHANGELOG.md` >= 1.

## 5. Bookend + publication gate + commit

- Run `bin/validate-personas.sh` (full + `--staged` + `--message`). Block on FAIL.
- Harness-reviewer bookend before any push. Single commit; local only; operator authorizes push.
- **Signal:** validator exits 0; `git log --oneline -1` references the slug.
