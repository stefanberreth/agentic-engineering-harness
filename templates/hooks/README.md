# Git Hook Templates

Local git hooks that run the AEH leak scan before commit/push. Both the harness repo and AEH-onboarded target projects can install these.

## Install (per repo)

```
cp templates/hooks/pre-commit  .git/hooks/pre-commit
cp templates/hooks/pre-push    .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

Both hooks resolve `bin/validate-personas.sh` relative to the repo root. If the validator is missing the hook is a no-op (warns and exits 0) so it does not block contributors on a fresh clone before they populate the local blocklist.

## What they do

- **pre-commit:** runs `bin/validate-personas.sh --staged` and `--message` against the in-progress commit message file. Blocks the commit on FAIL.
- **pre-push:** runs the full broad scan against tracked files. Blocks the push on FAIL.

## Bypass

These are defence-in-depth, not authoritative gates. The orchestrator's Publication Gate (see `templates/personas/orchestrator.md`) is the primary control. If a hook misfires, it is acceptable to bypass with `git commit --no-verify` -- but only after confirming the orchestrator's gate has cleared the same content, and only for the specific commit at hand. A persistent reliance on `--no-verify` is a finding.
