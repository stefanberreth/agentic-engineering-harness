---
slug: openspec-closeout-verification-status-preservation
---

# Tasks

## Task 1: Add subsection to harness-self openspec/AGENTS.md
- Insert "Verification-Status Preservation" subsection after "Mechanical close-out sequence".
- Covers the two guards + archaeologist persona cross-reference.
- **Signal:** `grep -c "Verification-Status Preservation\|verification-status" openspec/AGENTS.md` returns >= 2.

## Task 2: Mirror into setup template
- `templates/tools/openspec-setup.md` Step 1 embedded AGENTS.md content gets the same subsection.
- **Signal:** `grep -c "Verification-Status Preservation\|verification-status" templates/tools/openspec-setup.md` returns >= 2.

## Task 3: Add to retrofit prompt template
- `templates/prompts/openspec-close-out-retrofit.md.template` carries the guards in the close-out walking step.
- **Signal:** `grep -c "verification-status\|archaeologist_verified" templates/prompts/openspec-close-out-retrofit.md.template` returns >= 1.

## Task 4: CHANGELOG entry + archive proposal
- Under [Unreleased] Changed: refinement summary.
- Archive after bookend.
