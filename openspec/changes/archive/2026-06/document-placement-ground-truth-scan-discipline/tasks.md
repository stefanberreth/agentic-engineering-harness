---
slug: document-placement-ground-truth-scan-discipline
status: in-progress
---

# Tasks: Document placement ground-truth scan discipline

## Done (2026-06-03, same session as proposal)

- [x] T1: `CLAUDE.md` Working Rules -- add the three-branch (RESPECT / CONSOLIDATE / ESTABLISH) bullet. Mechanical signal: `grep -n "Ground-truth scan before writing any new document" CLAUDE.md` returns one match.
- [x] T2: `templates/personas/developer.md` Principles -- add the discipline bullet scoped to developer's content class. Mechanical signal: `grep -n "Ground-truth scan before writing any new document" templates/personas/developer.md` returns one match.
- [x] T3: `templates/personas/analyst.md` Principles -- same. Mechanical signal: equivalent grep returns one match.
- [x] T4: `templates/personas/architect.md` Principles -- same. Mechanical signal: equivalent grep returns one match.
- [x] T5: `templates/personas/reviewer.md` Principles -- same, including the reviewer-as-enforcer clause ("new docs in fresh locations without ground-truth scan evidence are Dimension-1 hygiene findings"). Mechanical signal: equivalent grep returns one match AND grep for "Dimension-1" near the bullet returns a hit.

## Pending

- [x] T6: `templates/personas/archaeologist.md` Principles -- add the discipline bullet. Scan locations: `openspec/specs/baseline-*.md`, `docs/AE/reports/` (for archaeological reports), mkdocs nav. Mechanical signal: equivalent grep returns one match.
- [x] T7: `templates/personas/orchestrator.md` Principles -- add the discipline bullet. Scan locations: `targets/<slug>/` state file tree (`profile.md`, `tasks.md`, `decisions.md`, `journal.md`, `orchestrator-state.md`, `review-history.md`, `open-questions.md`) before authoring a new state file. Mechanical signal: equivalent grep returns one match.
- [x] T8: `templates/personas/harness-reviewer.md` Principles -- add the discipline bullet, INCLUDING the analogous enforcer clause for the public harness repo (`openspec/**`, `docs/`, `templates/**` placement-discipline violations are Dimension-1 hygiene findings in harness review). Mechanical signal: equivalent grep returns one match AND grep for the harness-side enforcer clause returns a hit.
- [x] T9: `templates/governance/review-criteria.md` audit -- added "Document placement discipline" criterion under § 4 Governance & Process Quality (between "Progress tracking" and the section break). No existing hygiene/placement dimension was present; the new row encodes the RESPECT / CONSOLIDATE / ESTABLISH check.
- [x] T10: Confirmed. `templates/prompts/refresh-base-personas.md.template` byte-identically copies all six base personas from `templates/personas/*.md` to target `docs/AE/personas/_base/*.md`; the new Principles bullet in each persona propagates automatically. No new prompt needed. AC-6 satisfied.
- [x] T11: `CHANGELOG.md` `## [Unreleased] > ### Added` entry added as the first bullet, covering CLAUDE.md + all seven personas (no pending placeholder needed -- all seven were completed in this same session) + governance criteria + proposal pointer. Format matches existing Keep-a-Changelog convention.
- [x] T12: Archived. Process/mechanism proposal -- no formal capability spec deltas (Step 1 of `openspec/AGENTS.md` close-out sequence is a no-op); no parent spec metadata to bump (Step 2 no-op). Proposal frontmatter set to `status: archived` + `archived-at: 2026-06-03T10:30:00Z`. Directory moved to `openspec/changes/archive/2026-06/document-placement-ground-truth-scan-discipline/`. CHANGELOG entry remains under `## [Unreleased]` until the next dated release cuts.

## Out-of-scope reminders

- No retrofit prompt for existing targets -- they pick up the discipline at the next base-persona refresh.
- No mass-cleanup of pre-existing scattered docs -- forward discipline only.
