---
slug: base-template-layer-hygiene
status: ready-for-archive
since: 2026-06-06
---

# Base-template layer hygiene: target base templates must not reference harness-only constructs

## What

Add one check to `harness-reviewer` Dimension 4 (Template & Persona Consistency), under "Layered Persona Architecture": a TARGET-facing base template (`architect`, `analyst`, `archaeologist`, `developer`, `reviewer`) must not reference a construct that exists only in the harness layer -- the `orchestrator`, the `harness-reviewer`, a harness-reviewer Dimension number, the harness `CLAUDE.md` tree, the `_intake` inbox, the additive-ratchet/forgetting framing. When a cross-cutting discipline lands in both layers, each layer states it in its own terms; the two do not cite each other.

## Why

The harness has two persona layers that are easy to conflate because they share a directory (`templates/personas/`): TARGET-facing base templates (propagate into `docs/AE/personas/_base/`, run inside a target) and HARNESS-side roles (`orchestrator`, `harness-reviewer`, which operate on the harness). A base-template edit this session leaked a harness-reviewer-only construct ("the reviewer's still-earns-its-place lens") into the target `architect` -- a target architect would have followed a dead reference to something that exists only in the harness layer. The leak was caught by the operator, not by any standing check. This makes the check standing, in the dimension that already owns persona-layer consistency, so the next cross-layer leak is caught at review.

## Scope

In scope: one bullet in `harness-reviewer` Dimension 4 "Layered Persona Architecture"; CHANGELOG entry.

Out of scope: a deterministic grep in `bin/validate-personas.sh` (the leak is paraphrase-class -- "the orchestrator" can appear legitimately in a base template that describes how the orchestrator dispatches it; this is a judgment check, not a pattern match). Revisit if a reliable pattern emerges.

## Acceptance criteria

1. `harness-reviewer` Dimension 4 carries the no-cross-layer-construct-references check under Layered Persona Architecture.
2. CHANGELOG [Unreleased] entry present.

## References

- Motivating instance: the `subtraction-completeness-discipline` edit leaked a harness-reviewer Dimension-3 reference into target `architect.md`, fixed in the same session.
- Sibling: the subtraction-completeness check (same Dimension 4) and the Dimension-3 forgetting question.
