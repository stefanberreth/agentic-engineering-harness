---
slug: polish-mode-operating-regime
status: archived
proposed: 2026-06-03
archived-at: 2026-06-03T23:00:00Z
authored-by: harness orchestrator session d8f5c433cd8c
intake: 2026-06-03-2130-polish-mode-operating-regime-d8f5c433cd8c.md
---

# Polish Mode: third operating regime for tactical iteration alongside spec-first default

## What

A third recognised operating regime in the AEH harness -- Polish Mode -- for low-friction tactical iteration on visible surfaces (copy, layout, tokens, micro-UX) alongside the existing spec-first default. Activated explicitly by operator request, scoped to a named surface, runs as live dialogue between operator and target developer, exits with batch commit + lightweight reviewer pass + push.

The regime is encoded in the orchestrator and developer base personas, in a canonical prompt template, and in the governance review-criteria. README documents the regime as a first-class capability alongside the existing operation modes.

## Why

The spec-first ceremony (analyst -> architect -> developer -> reviewer) exists for substantive changes where drift, missed ACs, and unauditable history are real risks. It is overkill for tactical visible-surface adjustments where:

- The operator's intent IS the spec for the change.
- The visual outcome IS the acceptance criterion.
- The operator's eyeball IS the reviewer.

Without an explicit polish-mode regime, operators either bypass ceremony informally (creating undocumented drift) or burn four prompts per text tweak (friction -> eventual bypass anyway). Both outcomes are worse than codifying the regime.

The discipline that makes polish mode safe (not a slippery slope into substantive-change-via-polish): explicit activation, bounded scope, developer holds the scope boundary, two-bucket feedback triage (IMMEDIATE-FIX vs DEFERRED-TRIAGE), exit ceremony with after-the-fact audit trail (polish-session log + openspec record), lightweight reviewer pass before push.

## Scope

In scope:

- New "Polish Mode" section in `templates/personas/orchestrator.md` alongside existing Operating Modes (Regime 1 prompt-by-prompt, Regime 2 batch + phase-boundary review).
- New "Polish Mode affordances and boundaries" section in `templates/personas/developer.md`.
- New canonical prompt template at `templates/prompts/polish-mode.md.template` that the orchestrator instantiates per polish session.
- New criterion in `templates/governance/review-criteria.md` covering the polish-pass review treatment.
- New section in `README.md` documenting Polish Mode as a first-class harness capability.
- `CHANGELOG.md` entry under `## [Unreleased]` Added section.

Out of scope:

- Per-target overlay updates for existing targets -- they pick up Polish Mode at the next base-persona refresh (existing `refresh-base-personas` mechanism).
- Retroactive promotion of past spec-first cycles that could have been polish.
- Hard time-box or diff-size limits on polish sessions (rely on scope-boundary discipline and reviewer pass; revisit if abuse surfaces).
- Polish-mode application to non-UI artefacts (config tweaks, dev infra polish, etc.). The regime targets visible surfaces specifically; non-UI tactical work has its own existing affordances.

## Acceptance criteria

- [ ] AC-1: `templates/personas/orchestrator.md` carries a Polish Mode section under or alongside Operating Modes, covering activation phrase, scope IN / OUT, two-bucket triage, exit ceremony, openspec-record decision tree, when polish-mode is and is not appropriate.
- [ ] AC-2: `templates/personas/developer.md` carries a Polish Mode posture section covering live-dialogue affordances, screenshot-paste handling, scope-boundary halting, exit-ceremony obligations (session log + openspec record + lightweight self-check).
- [ ] AC-3: `templates/prompts/polish-mode.md.template` exists as a canonical session-wrapper the orchestrator instantiates per polish session. Placeholders for surface name, change-slug, in-scope route list.
- [ ] AC-4: `templates/governance/review-criteria.md` carries a "Polish-pass review" criterion distinct from the full reviewer rubric -- lighter scope, focused on scope-no-creep + no regression + tokens-only + commits clean.
- [ ] AC-5: `README.md` documents Polish Mode as a first-class harness capability, mentioning the two-bucket triage and the spec-first complement relationship.
- [ ] AC-6: `CHANGELOG.md` `## [Unreleased] > ### Added` carries the polish-mode entry.
- [ ] AC-7: Target propagation: existing targets pick up Polish Mode at the next base-persona refresh. No new retrofit prompt required.

## Status

In progress. Proposal + design + tasks authored in same session as intake promotion (2026-06-03). Implementation tracked in `tasks.md`.
