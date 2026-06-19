---
slug: openspec-close-out-convention
---

# Tasks: OpenSpec Close-Out Convention

## Task 1: Author canonical AGENTS.md content
- Create `templates/tools/openspec-AGENTS.md.template`: the canonical close-out playbook embedded as the AGENTS.md content the setup template installs.
- Content: four-step close-out sequence (apply deltas to parent specs, bump parent `updated:`, move proposal to `archive/<slug>/`, set proposal `status: archived`), commit-message convention, spec-frontmatter discipline (`since:`, `last-updated-by:`), how to handle ready-for-archive vs blocked proposals.
- **Signal:** file exists; contains all four sequence steps.

## Task 2: Extend openspec-setup.md
- Update `templates/tools/openspec-setup.md` to also write `openspec/AGENTS.md` (from the template above) and create `openspec/changes/archive/` (with a small README) at install time.
- **Signal:** `grep -c "AGENTS.md\|changes/archive" templates/tools/openspec-setup.md` returns >= 2.

## Task 3: Update openspec-teardown.md
- `templates/tools/openspec-teardown.md`: explicitly preserve `openspec/changes/archive/` on teardown (history). Active `openspec/changes/<slug>/` directories may be removed.
- **Signal:** `grep -c "archive" templates/tools/openspec-teardown.md` returns >= 1.

## Task 4: Dogfood harness-self
- Write `openspec/AGENTS.md` at harness root (same content as the template, target-detail-free).
- Create `openspec/changes/archive/` with a README.
- **Signal:** both files exist.

## Task 5: Retrofit prompt template
- `templates/prompts/openspec-close-out-retrofit.md.template`: target-side prompt that (a) creates `openspec/AGENTS.md` and `openspec/changes/archive/` if missing, (b) optionally walks any logically-closed proposals through mechanical close-out under the new convention.
- **Signal:** file exists.

## Task 6: CHANGELOG entry
- Under [Unreleased] Added: convention summary + dogfooding note + retrofit-prompt availability.
- **Signal:** `grep -c "close-out convention\|openspec-close-out" CHANGELOG.md` returns >= 1 in an Unreleased entry.

## Task 7: Archive after implementation
- Move `openspec/changes/openspec-close-out-convention/` to `openspec/changes/archive/openspec-close-out-convention/` once Tasks 1-6 and harness-reviewer bookend complete. This is the first close-out under the new convention.
- **Signal:** `test -d openspec/changes/archive/openspec-close-out-convention` returns zero.
