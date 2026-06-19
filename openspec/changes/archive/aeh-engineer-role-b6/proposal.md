---
slug: aeh-engineer-role-b6
status: in-progress
since: 2026-06-17
parent: aeh-engineer-role
build-step: B6
---

# B6: the enforced docs/AE/-only fence

> Sixth build step of the accepted `aeh-engineer-role` architecture. Retires the
> soft "harness may read a target for assessment" rule and replaces it with the
> enforced `docs/AE/`-only fence: AEH-side roles are fenced out of the target tree
> except the `target-orchestrator` reading/writing `<target>/docs/AE/**`, backed by
> a permission allowlist and a narrow read-only onboarding bootstrap exception.

## What

1. **CLAUDE.md -- the fence rule.** Add "The enforced `docs/AE/`-only fence (read
   AND write)" subsection to the Target Project Isolation section: AEH-side roles
   fenced out of the target tree; `aeh-engineer`/`harness-reviewer` get NO target
   access; `target-orchestrator` gets the single allowlisted `docs/AE/**`
   exception; enforcement is a permission allowlist (pointer to
   permission-baselines); `target-aeh-reviewer` polices it; the onboarding
   bootstrap exception is the one legitimate first-contact read. Retire the soft
   "you CAN read target project files for assessment purposes" parenthetical in
   the "Assess before prescribing" working principle, repointing it at the fence.

2. **orchestrator.md -- the read-side of the fence + the fold.** Add a "Do not
   read target application source or rummage the target tree" bullet to "What you
   do NOT do" (folds the private captures `orchestrator-no-target-code-spelunking`
   + `orch-no-target-tree-rummaging`): route code-state questions to an
   archaeologist/developer and consume the report, or answer from principle; both
   rationales (role-boundary AND context-altitude protection, the latter primary).
   Add a "`docs/AE/`-only fence (your only target access)" subsection. Reconcile
   the "record what exists structurally" line so post-onboarding structural facts
   come from dispatched-role report-backs, not direct rummaging.

3. **permission-baselines.md -- the enforcement.** Add an "AEH-side fence
   (orchestrator session -> target)" section: the symmetric half of the existing
   harness-isolation rule, with an embeddable `.claude/settings.json` allowlist
   scoping the orchestrator session to `<target>/docs/AE/**` plus sensitive-path
   denies, and the design-call note on the deny-precedence limitation.

4. **onboarding.md -- the bootstrap exception.** Mark Phase 2 (Reconnaissance) AS
   the bootstrap exception: narrow, read-only, one-directional, ending when
   `docs/AE/` exists.

## Why

The current boundary was asymmetric and soft: the WRITE side was a hard rule
("never modify target files") but the READ side was a soft permission ("you CAN
read target project files for assessment purposes"). A soft read rule is
unenforceable and was the seam behind the orchestrator drifting into reading
target source to assert code state (polluting its altitude) and rummaging the
target tree to answer questions. The operator wants the boundary ENFORCED
(uncorruptable), with `docs/AE/` as the only allowlisted channel -- the fence
makes the harness/target boundary structural rather than conventional, which is
the adoptability bar. The chicken-and-egg of first-contact reconnaissance (no
`docs/AE/` exists yet) is resolved by a narrow read-only bootstrap that closes
the moment onboarding creates `docs/AE/`.

## Decisions made (for operator ratification)

1. **Permission-allowlist shape: allow `docs/AE/**` + sensitive-path denies +
   default-`ask` for the remainder.** Claude Code deny takes precedence over
   allow, so "allow `docs/AE/`, deny everything else target-side" CANNOT be one
   allow + one blanket `Deny(Read(<target>/**))` (the blanket deny would also kill
   the `docs/AE/` allow). The shipped baseline grants ONLY `docs/AE/**` (the
   orchestrator's cwd is the harness root, so the rest of the target tree is
   outside it and falls to default-`ask` -- it cannot be written silently) and
   hardens secrets/git with explicit denies. A fully negation-based airtight
   lockdown is DEFERRED with the rest of the concrete permission/propagation
   mechanism (needs the Claude Code permission-schema / repo-owner conversation).

2. **The bootstrap exception is bounded strictly.** Read-only, first-contact only,
   one-directional (never writes the target outside `docs/AE/`), ending the moment
   `docs/AE/` exists. It is pinned to onboarding Phase 2. After that, all target
   reads go through dispatched-role report-backs (orchestrator) or
   `target-aeh-reviewer` running in the target. The bootstrap does not reopen the
   fence (read-only + auto-closing).

3. **`target-aeh-reviewer` polices the grant NOW (detection); a deterministic
   permission-grant check is deferred.** Policing the orchestrator's EFFECTIVE
   target access against `docs/AE/` is `target-aeh-reviewer`'s fence-policing
   dimension, already authored in B3 -- a finding routed by file location
   (AEH-side config -> `aeh-engineer`; target-side residue ->
   `target-aeh-engineer`). A cheap deterministic check in the `bin/` framework is
   NOT added: reading and judging a permission config is config-inspection, not a
   simple in-target path/pairing assertion, so it stays the reviewer's judgment
   for now.

## Scope

In scope: items 1-4 above.

Out of scope:
- The airtight negation-based permission expression (Decision 1) -- deferred.
- A deterministic permission-grant check in the `bin/` framework (Decision 3) --
  deferred to the reviewer's judgment.
- The `orchestrator` -> `target-orchestrator` rename (B5) -- B6 uses both forms
  where natural and B5 reconciles the token.

## Acceptance criteria

1. CLAUDE.md carries the enforced fence subsection; the soft "you CAN read target
   project files for assessment purposes" parenthetical is gone.
2. orchestrator.md has the no-spelunking/no-rummaging bullet + the fence
   subsection; the structural-facts line is reconciled.
3. permission-baselines.md has the "AEH-side fence (orchestrator session ->
   target)" section with an embeddable allowlist + the deferral note.
4. onboarding.md Phase 2 is marked as the bootstrap exception.
5. Publication gate passes; B6 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/` (proposal § 3 + the
  design.md "enforced fence" + "Onboarding bootstrap exception" sections).
- Predecessors: `aeh-engineer-role-b1`..`b4`.
- Folded captures (private; dispositioned in `TRIAGE-2026-06-17`):
  `orchestrator-no-target-code-spelunking`, `orch-no-target-tree-rummaging`.
- Polices: `target-aeh-reviewer` fence-policing dimension (B3).
