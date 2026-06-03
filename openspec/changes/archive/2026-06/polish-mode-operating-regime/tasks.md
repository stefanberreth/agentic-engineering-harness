---
slug: polish-mode-operating-regime
status: in-progress
---

# Tasks: Polish Mode operating regime

## Done (2026-06-03, same session as proposal)

- [x] T1: Polish Mode section added to `templates/personas/orchestrator.md` alongside existing Operating Modes. Mechanical signal: `grep -n "Polish Mode" templates/personas/orchestrator.md` returns the new section header.
- [x] T2: Polish Mode posture section added to `templates/personas/developer.md` before § 11 OpenSpec Integration. Mechanical signal: equivalent grep returns the new section header.
- [x] T3: `templates/prompts/polish-mode.md.template` created with all phases (activation, live dialogue, exit ceremony), two-bucket triage, placeholders for surface / change-slug / routes / environment / NNN / YYYY-MM-DD.
- [x] T4: `templates/governance/review-criteria.md` § 4a Polish-pass review added with the five-criterion rubric (scope-no-creep, no-regression, tokens-only, audit-trail coverage, commit hygiene).
- [x] T5: `README.md` Polish Mode section added between Operation modes and Onboarding modes.
- [x] T6: `CHANGELOG.md` `## [Unreleased] > ### Added` entry covering all of the above.
- [x] T7: Confirmed -- existing `templates/prompts/refresh-base-personas.md.template` byte-identically copies all six base personas into target `docs/AE/personas/_base/`; the new orchestrator + developer sections propagate automatically at the next refresh cycle. No new retrofit prompt needed. AC-7 satisfied.
- [x] T8: Intake capture status flipped from `untriaged` -> `promoted` with the proposal-slug pointer (`promoted-to: archive/2026-06/polish-mode-operating-regime`).
- [x] T9: Proposal archived. Process/mechanism (no formal capability spec deltas; Step 1 of openspec close-out is no-op). Frontmatter set to `status: archived` + `archived-at: 2026-06-03T23:00:00Z`. Directory moved to `openspec/changes/archive/2026-06/polish-mode-operating-regime/`.
- [x] T10: Publication gate clean; commit with conventional format and `[change:polish-mode-operating-regime]`. No AI attribution. ASCII.
