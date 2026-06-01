---
slug: reviewer-prompt-commit-step
---

# Tasks

## Task 1: Reviewer persona explicit commit step
- Edit `templates/personas/reviewer.md` review-output section.
- Add a mandatory step block: read-review-file path -> `git add <path>` (path-scoped) -> `git commit -m "<conventional review message>"`. Single commit. No push.
- **Signal:** `grep -c "git commit" templates/personas/reviewer.md` returns >= 1 in the review-output section.

## Task 2: Orchestrator chain-section caveat
- Edit `templates/personas/orchestrator.md` § "Multi-prompt Multi-role Chain Orchestration".
- Note that any step under a zero-commit halt guard must produce a commit. Reviewer + doc-only steps trip the guard if they only write files.
- **Signal:** explicit caveat sentence present.

## Task 3: Halt-condition catalogue entry update
- Update the "zero commits from a step" halt-condition catalogue entry in the same persona section.
- Add the reviewer-step caveat by example.
- **Signal:** catalogue entry references reviewer steps.

## Task 4: CHANGELOG + intake status + archive
- CHANGELOG entry under [Unreleased] Changed.
- Intake capture frontmatter updated: `status: promoted`, `promoted-to: reviewer-prompt-commit-step`, `promoted-at: <ISO>`.
- Archive proposal post-bookend per `openspec/AGENTS.md`.
