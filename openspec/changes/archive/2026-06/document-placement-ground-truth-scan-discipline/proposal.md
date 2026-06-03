---
slug: document-placement-ground-truth-scan-discipline
status: archived
proposed: 2026-06-03
archived-at: 2026-06-03T10:30:00Z
authored-by: harness orchestrator session d8f5c433cd8c
intake: 2026-06-03-0930-document-placement-ground-truth-scan-discipline-d8f5c433cd8c.md
---

# Document placement ground-truth scan discipline (RESPECT / CONSOLIDATE / ESTABLISH)

## What

A cross-persona discipline: before any role authors a new markdown artefact (runbook, spec, report, deliverable, persona overlay, how-to, design doc, review file, anything that lives in a docs tree), the role must first run a comprehensive ground-truth scan of existing convention and pre-existing material on the same topic, then pick exactly one of three actions:

- **RESPECT** -- existing convention exists for this content class; write at the location it dictates and follow its format.
- **CONSOLIDATE** -- pre-existing material on the same topic exists; update IT in place; convert any duplicates into one-line pointers.
- **ESTABLISH** -- no convention exists; pick a defensible location, wire it into the docs / mkdocs nav, and add pointers from CLAUDE.md / relevant persona overlays / related runbooks so future role-holders discover it.

The discipline is encoded in CLAUDE.md Working Rules (harness-side discoverability) and in each content-producing base persona's Principles section (target-side propagation via the existing base-persona refresh mechanism).

## Why

The harness has multiple roles that produce documents (analyst, architect, developer, reviewer, archaeologist, orchestrator, harness-reviewer). Each persona currently carries narrow rules for its own canonical output location, but no general principle prevents creating a NEW doc in a NEW location when an existing convention already exists for that content class. The observable anti-pattern: scattered duplicates across `docs/`, `docs/AE/`, `openspec/`, `targets/`, project root -- each written once, found never. This both inflates docs-tree noise and silently strands knowledge: future role-holders cannot find prior art and re-derive it elsewhere.

Stating the discipline as three explicit branches (RESPECT / CONSOLIDATE / ESTABLISH) gives role-holders an action set, not just a prohibition. The reviewer's role in this discipline is enforcement: a new doc created in a fresh location without ground-truth scan evidence is itself a Dimension-1 hygiene finding.

## Scope

In scope:
- A new bullet in `CLAUDE.md` Working Rules codifying the three-branch discipline.
- A one-bullet Principles addition in each content-producing base persona template:
  - `templates/personas/developer.md`
  - `templates/personas/analyst.md`
  - `templates/personas/architect.md`
  - `templates/personas/reviewer.md` (includes the reviewer-as-enforcer clause -- new docs without scan evidence are Dimension-1 hygiene findings)
  - `templates/personas/archaeologist.md`
  - `templates/personas/orchestrator.md` (also authors state files and journal entries; same discipline applies)
  - `templates/personas/harness-reviewer.md` (mirror of reviewer-as-enforcer for the public harness repo)
- A check in `templates/governance/review-criteria.md` if a hygiene dimension exists there (audit during implementation).
- Target propagation via the existing `templates/prompts/refresh-base-personas.md.template` mechanism; no new retrofit prompt required.

Out of scope:
- Non-markdown artefacts (scripts, configs, fixtures, schema files). Same scatter risk in principle, but code-organisation conventions are stronger and this proposal does not extend there. Revisit if reviewer-flagged.
- Per-persona shell command snippets for "how to run the scan". Scan locations are persona-specific (developer scans `docs/`, architect scans `openspec/specs/` + `docs/AE/designs/`, etc.); a generic command would mislead. Each persona's bullet names the locations relevant to its content class.
- Mass-retrofit of pre-existing scattered docs. Discipline applies forward; reconciliation of legacy duplicates happens organically through CONSOLIDATE actions as future authoring touches each cluster.

## Acceptance criteria

- [ ] AC-1: `CLAUDE.md` Working Rules contains a bullet stating the three-branch discipline (RESPECT / CONSOLIDATE / ESTABLISH) with one-line explanations of each branch and the role-applicability list.
- [ ] AC-2: All seven content-producing base persona templates carry a one-bullet Principles entry encoding the discipline, scoped to the persona's content class (developer scans `docs/` + mkdocs nav; analyst scans requirements / openspec; architect scans `openspec/specs/` + `docs/AE/designs/`; reviewer scans `docs/AE/reviews/`; archaeologist scans `openspec/specs/baseline-*.md`; orchestrator scans `targets/<slug>/` state files; harness-reviewer scans the public harness repo).
- [ ] AC-3: The reviewer base persona's bullet explicitly includes the enforcer clause -- a new doc in a fresh location with no ground-truth scan evidence is a Dimension-1 hygiene finding.
- [ ] AC-4: The harness-reviewer base persona's bullet includes the analogous enforcer clause for `openspec/**` and `docs/` in the public harness repo.
- [ ] AC-5: `templates/governance/review-criteria.md` either references the discipline or has been audited and confirmed not to need a change (record the finding either way).
- [ ] AC-6: No new propagation prompt is added; existing `refresh-base-personas` mechanism is the propagation path (documented in the proposal-archive notes).

## Out of scope decisions recorded

- No new persona role is added.
- No change to the existing per-persona canonical-output rules (archaeologist's `openspec/specs/baseline-*.md`, developer's `docs/AE/reports/`, etc.) -- those are narrower and remain authoritative for their content class.
- No change to how `_intake/` triage produces full proposals; this proposal IS the example of that flow.

## Status

In progress. AC-1, AC-2 (four of seven personas: developer, analyst, architect, reviewer), AC-3 implemented in the same harness session that authored this proposal (2026-06-03). Remaining: AC-2 for archaeologist + orchestrator + harness-reviewer, AC-4, AC-5, AC-6. Implementation tracked in `tasks.md`.
