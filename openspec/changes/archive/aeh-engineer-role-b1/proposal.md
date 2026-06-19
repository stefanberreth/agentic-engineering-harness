---
slug: aeh-engineer-role-b1
status: archived
archived-at: 2026-06-19T18:47:51Z
since: 2026-06-17
parent: aeh-engineer-role
build-step: B1
---

# B1: aeh-engineer persona + taxonomy wiring + the extract-and-aggregate subtraction

> First build step of the accepted `aeh-engineer-role` architecture (see
> `openspec/changes/aeh-engineer-role/proposal.md` + `design.md`). Establishes the
> harness's read-write engineering role, wires the AEH-vs-Target taxonomy into the
> always-loaded instruction surface, and performs the subtraction that moves
> harness-maintenance duties out of the target-pipeline orchestrator.

## What

1. **Create `templates/personas/aeh-engineer.md`** -- the AEH-proper read-write
   engineering owner. Aggregates the full scope from the parent proposal section
   2a, in three families: drive harness improvement (intake triage,
   improvement-architecting, behaviour-vs-lore divergence detection, the
   declaration/machinery coherence audit, consolidation / anti-bloat /
   CLAUDE.md-size discipline / subtraction-completeness); guard the public
   boundary (per-commit publication gate, publication-readiness gate, the actual
   commit/push + two-repo discipline + CHANGELOG + no-AI-attribution, the full
   OpenSpec lifecycle incl. close-out, promotion-sanitization / name-free spec
   substrate, `bin/` tooling + hook + blocklist maintenance); steward the
   structure (taxonomy + valid-roles + role-location self-checks + the AEH side
   of the `docs/AE/` fence, documentation currency, harness-side propagation/
   release governance, orchestrator-state freshness tooling ownership).

2. **Wire the always-loaded surface:**
   - `CLAUDE.md`: add `aeh-engineer` to the valid-roles set, the session-init
     banner roster, and the project structure tree; add the AEH-vs-Target role
     taxonomy subsection; add the `aeh-engineer` role description; re-own the
     "Owner: orchestrator" publication-gate rule to `aeh-engineer`; re-own the
     harness-capture-triage line to `aeh-engineer`; stamp the Harness Maintenance
     Discipline section "Owner: aeh-engineer".
   - `openspec/project.md`: add the "Role taxonomy (who authors here)" principle
     -- harness-self OpenSpec authoring/close-out is the `aeh-engineer`'s lane;
     the orchestrator only writes captures.
   - `bin/validate-personas.sh`: add `aeh-engineer.md` to `HARNESS_ROLES` so the
     harness-internal persona is not flagged for missing the layered convention.
   - `README.md`: add the AEH Engineer to the coordinating/maintenance roles
     table; mark the Harness Reviewer as detect-only.

3. **The extract-and-aggregate subtraction (`templates/personas/orchestrator.md`):**
   cut harness-maintenance OUT of the orchestrator, leaving only the universal
   capture right. Removed/relocated: the Publication Gate section, the Review
   Intermediaries Are Local-Only section, the Harness-Capture triage-side
   subsection + its session-init surfacing, propagation-signal authoring
   (ownership note added: orchestrator RUNS detection, `aeh-engineer` OWNS the
   mechanism), the "improve the templates / commit to the AEH repo" principle
   (rewritten to capture-and-flag-only), and the harness-CHANGELOG mention in the
   coordination-work list. The orchestrator retains target-pipeline work plus the
   universal capture-write right.

## Why

The orchestrator was dual-scoped (target-SDLC orchestration AND harness
maintenance) -- the seam behind recurring "which scope am I in" confusion and the
unowned additive ratchet. Harness maintenance had no clean owner: ~85 distinct
duties were either nominally "owned by the orchestrator" (wrong lane -- a
target-pipeline role) or homeless (no owner, so they rotted, e.g. the OpenSpec
close-out lifecycle and `bin/` tooling evolution). B1 gives those duties a single
catch-all owner and removes them from the orchestrator, so each role's lane is
legible. The taxonomy is the maturity lever: name-encodes-family makes the
harness/target boundary visible to an adopter from the role list alone.

## Scope

In scope: items 1-3 above; the four B1-folded backlog items folded as named
duties in the persona (continuous coherence-audit duty; harness-side downstream
propagation/release governance; promotion-sanitization / name-free spec
substrate; orchestrator-state freshness + drift-detector tooling ownership).

Out of scope (later build steps, each its own change):
- Purifying `harness-reviewer` of target-tree branches (B2).
- The `target-aeh-reviewer` / `target-aeh-engineer` personas (B3).
- The deterministic `bin/` AEH-practice check framework (B4).
- The `orchestrator` -> `target-orchestrator` rename (B5) -- B1 keeps the role
  named `orchestrator` and notes the pending rename in the taxonomy text.
- The enforced `docs/AE/`-only fence permission allowlist (B6).
- The role-location Step-0 self-check generalised to all roles (B7).
- Concrete builds of the folded mechanisms (the state-freshness `bin/` helper;
  the release-notes/consumption-screening mechanism): the role now OWNS this work
  but the concrete machinery is queued under that ownership, not built here.

## Acceptance criteria

1. `templates/personas/aeh-engineer.md` exists and covers all three duty families
   plus the four folded items.
2. `CLAUDE.md`, `openspec/project.md`, `bin/validate-personas.sh`, and `README.md`
   are wired as in item 2; the AEH-vs-Target taxonomy is recorded in `CLAUDE.md`.
3. The orchestrator persona no longer claims any harness-publication /
   triage / template-editing / harness-commit duty; a residual scan over the
   orchestrator confirms only the universal capture right and the
   propagation-detection-runtime remain harness-touching.
4. The publication gate (`bin/validate-personas.sh --staged` + `--message`) passes
   on the B1 commit.
5. B1 lands as its own commit, reviewable independently; no push (the
   publication-readiness regime holds until the whole rebuild is coherent).

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/` (proposal + design +
  kickoff).
- Supersedes (carried into the parent): `harness-maintainer-role-charter`
  (`status: superseded`).
- Folded backlog items (private captures, dispositioned in the private
  `TRIAGE-2026-06-17` manifest): continuous coherence-audit duty; downstream
  propagation/release governance; name-free spec-substrate discipline;
  orchestrator-state freshness + drift detector.
