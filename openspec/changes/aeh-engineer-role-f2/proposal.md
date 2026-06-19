---
slug: aeh-engineer-role-f2
status: in-progress
since: 2026-06-19
parent: aeh-engineer-role
build-step: F2
---

# F2: thin the role-location signature to one-line pointers

> Second follow-on to the B1-B7 rebuild. B7 inlined the full three-part
> role-location signature into ~11 places (the two CLAUDE.md layers, the five
> engineering base personas, the two target-applied AEH roles, and the three
> harness-side personas). The five engineering blocks were near-identical full
> copies that will drift -- the additive ratchet the `aeh-engineer` exists to
> fight. F2 keeps the full signature in exactly the two CLAUDE.md layers and
> reduces every persona to a one-line Step-0 pointer.

## What

1. **Engineering base personas (5)** -- replace each `## §0` full block with a
   one-line pointer to the target `CLAUDE.md` § "Role-location self-check"
   (assert: target tree, NOT the AEH root; loud-halt). Reviewer keeps its
   mirror-image parenthetical.
2. **Target-applied AEH roles (2)** -- `target-aeh-reviewer`,
   `target-aeh-engineer`: replace the inlined signature in their R2 location
   self-check with the same one-line pointer to the target `CLAUDE.md`.
3. **Harness-side personas (3)** -- `harness-reviewer`, `target-orchestrator`,
   `aeh-engineer`: replace the inlined signature in their Step-0 / session-init
   check with a one-line pointer to the harness `CLAUDE.md` § "Role-location
   self-check" (assert: AEH root).
4. **Update the CLAUDE.md sync note** so it describes the new shape: the full
   signature lives in exactly two places (the two CLAUDE.md layers); every persona
   carries a one-line pointer; harness-side personas point here, target-facing
   personas point at their project's CLAUDE.md.

## Why

The signature is one definition restated ~9 times across persona files. Each
restatement is a drift surface: a future edit to the canonical signature must
chase nine copies or they silently disagree. The fence genuinely forbids a
target-facing persona from citing the harness CLAUDE.md, so SOME per-layer source
is unavoidable -- but that is satisfied by the two CLAUDE.md layers, not by nine
inlined persona copies. A one-line pointer per persona preserves the Step-0 gate
(the persona still asserts location at activation) while collapsing the drift
surface to the two canonical files.

## Scope

In scope: the persona-side thinning + the CLAUDE.md sync-note update.

Out of scope: the two CLAUDE.md layers keep the full signature (by design); no
behaviour change to the gate itself (it still loud-halts at Step 0).

## Acceptance criteria

1. The three-part signature enumeration text appears in exactly two files:
   `CLAUDE.md` and `templates/project/CLAUDE.md.template`.
2. All ten personas (five engineering + two target-applied + three harness-side)
   carry a one-line Step-0 pointer to the correct CLAUDE.md layer.
3. The gate still loud-halts on mismatch (the pointer instructs it).
4. Validator + publication gate pass; F2 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- Predecessor that inlined the signature: B7
  (`openspec/changes/aeh-engineer-role-b7/`).
- Rationale: `retrospective-b1-b7.md` ("What I over-built: the B7 signature is
  duplicated ~11 times").
