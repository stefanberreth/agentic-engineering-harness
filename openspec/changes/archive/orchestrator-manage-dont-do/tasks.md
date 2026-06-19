---
slug: orchestrator-manage-dont-do
---

# Tasks

## Task 1: "Manage, do not do" section
- Edit `templates/personas/orchestrator.md` -- insert section after existing "Out-of-Lane Doctrine".
- Content: rule (manage convergence, judge reported outcomes, never inspect/build/test/commit/push on target); two-scales coherence note; hard-tie exception (narrow + explicitly flagged); auditability rationale (ground-truth-finding routes through roles via prompts).
- **Signal:** section present with all four elements.

## Task 2: Role-dispatch guidance reinforcement
- In the role-dispatch / generate-next-action section, add a line: "assess X" / "find ground truth on Y" / "investigate Z" route to a role (typically Archaeologist or Analyst) via a prompt, never to orchestrator's own hands.
- **Signal:** routing rule named in dispatch section.

## Task 3: Live-production operator-only fold-in
- Brief mention in the same section: live-production operations on a target are operator-run; harness provides runbook; sandbox-bound developer never touches live production.
- **Signal:** sentence present.

## Task 4: CHANGELOG + intake status + archive
- CHANGELOG entry under [Unreleased] Added.
- Intake capture frontmatter updated: status promoted.
- Archive proposal post-bookend.
