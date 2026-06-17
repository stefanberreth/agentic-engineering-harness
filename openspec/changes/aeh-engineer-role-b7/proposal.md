---
slug: aeh-engineer-role-b7
status: in-progress
since: 2026-06-17
parent: aeh-engineer-role
build-step: B7
supersedes: orchestrator-self-location-guard
---

# B7: role-location Step-0 self-check generalised to all roles

> Seventh build step of the accepted `aeh-engineer-role` architecture. Generalises
> the per-role Step-0 tree-location self-check from the orchestrator-only form to
> ALL roles, parameterised by family, sourced from one canonical signature.
> Absorbs the standalone `orchestrator-self-location-guard` proposal.

## What

1. **One canonical signature (the shared source).** Add a "Role-location
   self-check (R2 enforcement -- the canonical signature)" subsection to
   `CLAUDE.md` (taxonomy area): the deterministic AEH-root signature
   (`targets/index.md` + `templates/personas/` + a `CLAUDE.md` declaring the AEH
   mission, walking up from cwd), the target signature, and the per-family
   expected answer (AEH-proper roles + the coordinator assert they ARE in the AEH
   root; target-applied-in-target roles assert they are NOT). Loud-halt on
   mismatch.

2. **CLAUDE.md session-init Step 0.** Add the harness-session location assertion
   as Step 0 of "On first message of every session" (it must live in CLAUDE.md
   because the persona file is not loaded until the role is confirmed -- a
   misplaced session is caught here first).

3. **Target-side shared source.** Add the same definition to
   `templates/project/CLAUDE.md.template` § "Role-location self-check" so every
   onboarded target's `CLAUDE.md` carries it as that layer's canonical signature
   (the fence forbids a target-facing persona citing the harness `CLAUDE.md`, so
   each layer needs its own shared source).

4. **Fold the check into each role's activation Step 0** (not a competing block):
   - Engineering base personas (`analyst`, `archaeologist`, `architect`,
     `developer`, `reviewer`): a uniform `## §0. Role-location self-check` block
     asserting target-tree / NOT-AEH-root, self-contained + referencing the
     target's `CLAUDE.md`.
   - AEH-side personas: `harness-reviewer` + `orchestrator` gain a Step-0
     assertion (assert ARE in AEH root); `aeh-engineer` already had one (aligned
     to the canonical signature); `target-aeh-reviewer` + `target-aeh-engineer`
     already carry the target-side form (aligned to the canonical signature).

5. **Absorb `orchestrator-self-location-guard`.** Mark that proposal
   `status: superseded`, `superseded-by: aeh-engineer-role-b7`. The general form
   replaces it; the orchestrator's assertion is now one instance of the uniform
   check (the standalone guard was never separately implemented, so nothing is
   removed -- only superseded).

## Why

R2 (run where you write) was stated but enforced per-role only ad-hoc: the
`aeh-engineer` and the new `target-aeh-*` roles carried bespoke location checks
with slightly divergent signatures, the engineering base personas had none, and
the orchestrator-only guard sat unimplemented as a separate proposal. Divergent
signature logic across nine-ish roles is the additive ratchet in miniature -- N
hand-rolled copies that drift. B7 collapses "where does each role run?" into one
canonical signature test parameterised by family, baked into each role's existing
activation Step 0 so it propagates to targets, and is the first-person PREVENTION
counterpart to `target-aeh-reviewer`'s after-the-fact DETECTION of wrong-tree
execution. An accidentally-misplaced role (the observed failure: the orchestrator
launched inside a target tree next to the engineering agents) now loud-halts at
Step 0 instead of silently treating the wrong tree as its workspace.

## Decisions made (for operator ratification)

1. **No new `bin/` resolver -- the signature is stated inline + in CLAUDE.md.**
   The `orchestrator-self-location-guard` proposal scoped tooling beyond an inline
   signature check OUT, and a harness `bin/` resolver cannot be called by a
   target-facing base persona anyway (the cross-layer-path hygiene rule + the
   fence). The shared source is therefore the CLAUDE.md definition (harness layer)
   + the CLAUDE.md.template definition (target layer); each persona's Step 0
   references its own-layer definition and restates the check briefly. This is the
   leanest form that respects the fence.
2. **Cross-layer duplication is accepted and owned.** The signature text appears
   in CLAUDE.md, CLAUDE.md.template, and (briefly) each base persona because the
   fence forbids target-facing content from citing the harness CLAUDE.md. This is
   the same discipline stated per-layer in each layer's terms (which the
   harness-reviewer Dimension-4 cross-layer check explicitly permits), and keeping
   the copies in sync is named as part of the `aeh-engineer`'s declaration/
   machinery coherence-audit duty.

## Scope

In scope: items 1-5 above.

Out of scope:
- A `bin/` resolver implementation of the signature (Decision 1) -- not built.
- The `orchestrator` -> `target-orchestrator` rename (B5) -- B7 writes
  `orchestrator` where natural; B5 reconciles the token (including in this new
  Step-0 content).

## Acceptance criteria

1. CLAUDE.md carries the canonical signature subsection + the session-init Step 0.
2. CLAUDE.md.template carries the target-layer definition.
3. All five engineering base personas carry a uniform `## §0. Role-location
   self-check`; `harness-reviewer` + `orchestrator` carry the assert-IS-AEH-root
   Step 0; `aeh-engineer` + `target-aeh-*` checks reference the canonical
   signature.
4. `orchestrator-self-location-guard` is marked superseded by this slug.
5. Publication gate passes; B7 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/` (R2; the per-family
  expected-tree mapping).
- Supersedes: `openspec/changes/orchestrator-self-location-guard/` (the concrete
  first instance, deferred general form).
- Folded capture (private; dispositioned in `TRIAGE-2026-06-17`):
  `role-location-self-check`.
- Deterministic-gate backbone: the structural-invariant-gate pattern (B4).
- Detection counterpart: `target-aeh-reviewer` (B3).
