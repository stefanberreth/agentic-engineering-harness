---
slug: harness-portability-assessment
status: proposed
since: 2026-06-01
priority: deferred
intake: openspec/changes/_intake/2026-05-31-1800-agent-harness-portability-assessment-0c37120ebcd6.md
---

# AEH coding-agent harness portability: systematic assessment

## What

Author a systematic per-surface assessment classifying every Claude-Code-specific reference in the harness as (a) load-bearing for Claude Code, (b) agent-agnostic-but-named-claude, or (c) genuinely portable already. Produce the table + a phased migration plan (separate proposals per phase, not part of this one). Extend the harness-reviewer with a new dimension covering agent-harness portability. NO renames or mechanism changes in this proposal -- this is assessment scope only.

## Why

AEH today is de-facto Claude-Code-centric across templates, persona files, playbooks, governance, scripts, and operator-facing docs. The market for coding-agent CLI environments is broader (Gemini CLI, OpenAI Codex CLI, Mistral offerings, Aider, Continue, etc.). Many conventions AEH locks to Claude Code (`CLAUDE.md` filename, `.claude/` directory, in-session persona-marker mechanics, slash-commands) are not inherently Claude-specific -- they exist because Claude Code was the bootstrapping environment. The core methodology (OpenSpec discipline, layered personas, capture inbox, propagation signal, close-out convention, harness-reviewer governance) is agent-agnostic in substance.

`AGENTS.md` is emerging as a cross-CLI convention (OpenAI Codex CLI reads it; others following). Real-world targets already carry both a repo-root `AGENTS.md` and a `.claude/CLAUDE.md`. AEH templates encode only the Claude-Code-specific half today.

Renaming-without-mechanism-understanding is the failure mode. Mechanism understanding must precede convention change. This proposal authorises the assessment that produces the table; concrete migration is downstream.

This is NOT a priority for the next quarter; the operator's standing focus is harness substrate maturity and target-project work. The proposal is deliberately marked `priority: deferred`. The capture exists so when the next harness major release window opens or first cross-CLI adoption signal arrives, the work is scoped and ready to pick up.

## Scope

In scope:
- Per-surface assessment producing a classification table covering: `templates/personas/`, `templates/playbooks/`, `templates/tools/`, `templates/project/`, `templates/governance/`, `templates/agents/`, `templates/prompts/`, `bin/`, `CLAUDE.md`, `README.md`, `openspec/`, operator-facing docs in `docs/`.
- Per-surface classification: load-bearing-for-Claude / agent-agnostic-named-claude / genuinely-portable.
- Phased migration plan (high-level; each phase becomes its own proposal when prioritised).
- Survey of reference standards / candidates as input: AGENTS.md emerging convention, Aider's `.aider.conf.yml`, Continue's `.continuerc`, cross-CLI tooling like `mise`/`asdf` for agent-version pinning.
- Extend `templates/personas/harness-reviewer.md` with a new dimension (e.g. Dimension 11: Agent-Harness Portability) covering the per-surface classification check. Read-only at first (surfaces Claude-specific references); becomes forward-discipline once a portability convention lands.
- CHANGELOG entry under [Unreleased] Added.

Out of scope (explicit):
- Renaming `CLAUDE.md` to `AGENTS.md` in this proposal or its assessment. Mechanism understanding must precede convention change.
- Building cross-agent compatibility shims, polyfills, or runtime detection.
- Multi-agent orchestration (running multiple different CLI agents on the same project simultaneously) -- different problem.
- Concrete migration. Each phase of the migration plan becomes its own proposal when prioritised.

## Acceptance criteria

1. Per-surface assessment table produced and committed (likely under `docs/portability-assessment.md` or as a section of this proposal's design.md).
2. Phased migration plan (high-level) produced.
3. Harness-reviewer Dimension 11 (or whichever number) authored.
4. Survey of reference standards documented.
5. CHANGELOG entry.
6. Intake capture status updated to promoted.
7. Status flag honoured: this proposal stays `priority: deferred` until operator prioritises.

## References

- Intake: `openspec/changes/_intake/2026-05-31-1800-agent-harness-portability-assessment-0c37120ebcd6.md`
- Related: harness-reviewer dimensions baseline at `templates/personas/harness-reviewer.md`
- Future-related: any concrete migration proposal spawned from this assessment
