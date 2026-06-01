---
slug: claude-md-size-discipline
status: proposed
since: 2026-06-01
---

# CLAUDE.md size discipline (slim via pointer-to-reference-docs)

## What

Slim `CLAUDE.md` from 42.5k chars / 434 lines to under 30k chars by extracting long-form rationale paragraphs from Harness Maintenance Discipline bullets and similar prose-heavy sections into dedicated reference files (proposed location: `docs/harness-rules/<topic>.md`). CLAUDE.md retains the rule as a one-liner + pointer; rationale, mechanism detail, and historical motivation move to the reference doc.

## Why

CLAUDE.md grew organically as the harness shipped capture-inbox, propagation-signal, cross-container-isolation, OpenSpec self-dogfooding, openspec-authoring-target-detail-free, and other substantial discipline updates. Each landed a multi-sentence rationale paragraph in the always-loaded Harness Maintenance Discipline list. The runtime now warns at 40k chars (CLAUDE.md is 42.5k as of 2026-06-01). Beyond the runtime warning, the per-session token cost compounds across every session and target.

The fix is NOT removing rules. CLAUDE.md must still answer "what rule applies here?" without the operator or agent following pointers for the rule itself. But the WHY / HOW / past-incident-context belongs in a reference doc that the agent reads only when needed (or that the operator reads as auditable rationale).

This proposal codifies the discipline: every CLAUDE.md bullet stays as `- **Topic.** One-sentence rule. Detail: <pointer>.` shape. New rules must conform.

## Scope

In scope:
- Inventory CLAUDE.md sections by size; identify extraction candidates (>200-char paragraphs in rule bullets).
- New `docs/harness-rules/` directory (path TBD at authoring; alternatives considered: `docs/harness-discipline/`, `docs/discipline/`).
- Reference doc per extracted topic. Candidate extractions:
  - Cross-container isolation (mechanism detail + per-host scheduler lock semantics + future-risk note).
  - Harness capture inbox (filesystem-mediated mechanism + atomic write pattern + triage flow).
  - Harness update propagation signal (mechanism + handshake + retrofit-action vocabulary).
  - OpenSpec self-dogfooding (project.md / AGENTS.md / archive convention).
  - OpenSpec authoring target-detail-free discipline (paraphrase-class leakage; harness-reviewer Dimension 1).
  - Publication Gate + review intermediary discipline.
  - gitignore != untrack reminder.
- Rewrite each CLAUDE.md bullet to one-liner + pointer.
- Harness-reviewer dimension: pointer-resolution check (every CLAUDE.md `Detail:` pointer resolves to an existing file).
- CHANGELOG entry under [Unreleased] Changed.

Out of scope:
- Rewriting CLAUDE.md from scratch (preserve structure; surgical slim only).
- Removing rules or changing rule semantics.
- Touching role / persona definitions (separate proposals: `harness-role-execution-context-discipline`, `orchestrator-manage-dont-do`).
- Compressing the Working Rules section (those are already terse; the bloat is in Harness Maintenance Discipline).

## Acceptance criteria

1. CLAUDE.md is < 30k chars (target; firm cap 35k; warning if > 40k re-introduced).
2. `docs/harness-rules/` (or chosen path) holds reference docs per extracted topic.
3. Every extracted bullet in CLAUDE.md follows `- **Topic.** One-sentence rule. Detail: <pointer>.` shape.
4. No rule semantics changed; harness-reviewer can audit by comparing pre/post bullets for rule-content match (the rule sentence in post should be present verbatim or in equivalent meaning in the pre version).
5. Pointer-resolution check landed in harness-reviewer.
6. CHANGELOG entry.

## References

- Intake: this proposal is harness-self-surfaced (no inbox capture); the runtime warning + operator instruction 2026-06-01 are the trigger.
- Related: `openspec/changes/harness-role-execution-context-discipline/` (adds Execution context column to CLAUDE.md roles list -- coordinate edits).
- Related: future harness-reviewer enhancement to enforce the `Detail: <pointer>` shape.
