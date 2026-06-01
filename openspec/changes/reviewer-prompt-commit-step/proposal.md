---
slug: reviewer-prompt-commit-step
status: proposed
since: 2026-06-01
intake: openspec/changes/_intake/2026-05-31-1748-reviewer-prompt-commit-step-77c32eea48bc.md
---

# Reviewer-step explicit commit discipline (chain-safe)

## What

Make "commit the review report on main" an explicit mandatory step of the reviewer persona's review-output section, and update orchestrator chain-composition guidance so any step under a zero-commit halt guard MUST produce a commit. Update the halt-condition catalogue entry for "zero commits" with the reviewer-step caveat.

## Why

A reviewer step in an autonomous chain wrote its verdict report to disk, reported PASS, but did not commit. The chain wrapper's zero-commit halt guard fired -- a false halt on a clean success. The reviewer persona / prompt templates describe writing the review file but do not consistently make the follow-on commit a mandatory, explicit step. The review verdict also belongs in the audit trail as a commit regardless of any chain guard.

## Scope

In scope:
- `templates/personas/reviewer.md` -- review-output section gains an explicit mandatory "Commit the review report on main" step (path-scoped `git add`, single commit, conventional message, no push).
- `templates/personas/orchestrator.md` § "Multi-prompt Multi-role Chain Orchestration" -- note that any step under a zero-commit halt guard must produce a commit; a reviewer / doc step that only writes a file will false-halt the chain.
- Halt-condition catalogue entry for "zero commits": add the reviewer-step caveat.
- CHANGELOG entry under [Unreleased] Changed.

Out of scope:
- Auto-commit mechanism for reviewer prompts (the persona instruction is the mechanism).
- Push behaviour (that is the `boundary-push-policy` proposal's concern).

## Acceptance criteria

1. Reviewer persona has an explicit Commit step in its review-output section.
2. Orchestrator chain section + halt catalogue note the reviewer-step caveat.
3. CHANGELOG entry landed.
4. Intake capture status updated to promoted.

## References

- Intake: `openspec/changes/_intake/2026-05-31-1748-reviewer-prompt-commit-step-77c32eea48bc.md`
- Memory: `feedback_closure_prompts_verify_pipeline`
- Sibling: `openspec/changes/chain-fabric-lift/` (hardens the chain fabric)
