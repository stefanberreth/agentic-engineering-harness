---
slug: boundary-push-policy
---

# Tasks

## Task 1: profile.md schema field
- Document `boundary-push-policy:` in the `profile.md` schema reference (wherever schema lives -- likely in `templates/playbooks/onboarding.md` Phase 3e + brownfield).
- Values: `in-prompt`, `operator-manual` (default), `never-from-prompt`, `other`.
- **Signal:** schema reference lists all four values with one-line semantics each.

## Task 2: Onboarding elicitation (greenfield + brownfield)
- Greenfield Phase 3e: add operator-facing question with the four-option block.
- Brownfield: add to profile checklist.
- Default `operator-manual` if operator skips.
- **Signal:** elicitation block present on both paths.

## Task 3: Orchestrator persona honours field
- Edit `templates/personas/orchestrator.md` boundary-prompt-authoring section.
- Per-value behaviour spelled out: `in-prompt` includes `git push`; `operator-manual` says "push when ready"; `never-from-prompt` notes push is operator-only; `other` defaults to operator-manual with rationale surfaced.
- Add a one-line self-check the persona runs before authoring any boundary-closing prompt.
- **Signal:** all four values handled; self-check present.

## Task 4: Health-check verifies presence
- Edit `templates/playbooks/health-check.md`: verify field present + non-empty. Missing = LOW.
- **Signal:** check listed in playbook.

## Task 5: CHANGELOG + intake status + archive
- CHANGELOG entry under [Unreleased] Added.
- Intake capture frontmatter updated: status promoted.
- Archive proposal post-bookend.
