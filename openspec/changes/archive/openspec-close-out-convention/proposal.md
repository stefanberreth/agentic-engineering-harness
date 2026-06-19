---
slug: openspec-close-out-convention
status: archived
archived-at: 2026-06-19T19:18:24Z
since: 2026-05-31
provenance: openspec/changes/openspec-close-out-convention/provenance.md
---

# OpenSpec Close-Out Convention

## What

Add the OpenSpec proposal-closing side to the harness setup template + dogfood the convention in the harness-self `openspec/` tree. Today the harness ships `templates/tools/openspec-setup.md` which covers proposal-authoring (creating `openspec/`, `specs/`, `changes/`, optional `project.md`) but not proposal-closing (no `AGENTS.md` close-out playbook, no `changes/archive/` directory at setup time, no documented flow for applying deltas to parent specs and bumping their updated date). Every target adopting OpenSpec via the harness inherits this gap.

## Why

When a target completes a change proposal, the operator hits a wall: no convention to apply deltas, no archive directory, no documented close-out flow. The choice today is ad-hoc invention (per-target divergence) or indefinite pause at logical-close. Both are unacceptable for a harness whose central organising substrate is OpenSpec.

The harness-self `openspec/` adoption (landed earlier this week) carries the same gap as a meta-issue: `openspec/changes/README.md` mentions archive in the lifecycle section but does not document a close-out playbook, and `openspec/changes/archive/` does not yet exist. The harness should dogfood the convention it ships to targets.

## Scope

In scope:
- Extend `templates/tools/openspec-setup.md` to scaffold (a) `openspec/AGENTS.md` with the close-out playbook content, and (b) `openspec/changes/archive/` directory (with README) at setup time.
- Author the canonical close-out playbook content (the sequence: apply deltas to parent specs -> bump parent `updated:` -> move proposal to `archive/<slug>/` -> set proposal `status: archived`).
- Update `templates/tools/openspec-teardown.md` to preserve archived proposals as history (clarify what teardown removes vs preserves).
- Dogfood the convention in the harness-self tree: add `openspec/AGENTS.md` (the canonical playbook), create `openspec/changes/archive/` with a README.
- Author a retrofit prompt template at `templates/prompts/openspec-close-out-retrofit.md.template`: a target-side prompt that scaffolds `AGENTS.md` + `archive/` for existing targets with already-installed `openspec/` trees, and optionally walks any logically-closed proposals through the mechanical close-out under the new convention.
- CHANGELOG entry.

Out of scope:
- Changing the OpenSpec change-proposal lifecycle itself. Lifecycle stays: proposed -> accepted -> in-progress -> ready-for-archive -> archived. This proposal documents the mechanical close-out, not the lifecycle.
- Automating close-out (e.g. CI that auto-archives ready-for-archive proposals). Manual operator-driven close-out per discipline.
- Tooling to verify deltas applied correctly. Reviewer judgment + spec frontmatter discipline (`since:`, `last-updated-by:`) cover this.

## Acceptance criteria

1. **Setup template extended**: `templates/tools/openspec-setup.md` scaffolds `AGENTS.md` + `changes/archive/` at install time.
2. **AGENTS.md template content authored**: canonical close-out playbook documented (the four-step sequence, plus spec-frontmatter discipline + commit-message convention for archived proposals).
3. **Teardown clarified**: `templates/tools/openspec-teardown.md` preserves `changes/archive/` (history) while removing active `changes/<slug>/` directories on full teardown.
4. **Harness-self dogfooding**: `openspec/AGENTS.md` exists at harness root; `openspec/changes/archive/` exists with README.
5. **Retrofit prompt available**: existing targets with installed `openspec/` can adopt the convention via the retrofit prompt template (no full re-onboarding required).
6. **CHANGELOG entry**: under [Unreleased] Added.
7. **First verified close-out**: after this ships, an existing target with a structurally-closed proposal (e.g. one paused at logical-close awaiting this convention) can run the retrofit prompt and complete the mechanical close-out cleanly under the new convention.

## References

- Provenance: `provenance.md` in this directory.
- Inbox capture that originated the proposal: `openspec/changes/_intake/2026-05-31-1230-openspec-close-out-convention-0c37120ebcd6.md` (status: promoted-to this proposal).
- Sibling proposal: `openspec/changes/harness-update-propagation-signal/` (the propagation mechanism that will surface this convention to existing targets).
