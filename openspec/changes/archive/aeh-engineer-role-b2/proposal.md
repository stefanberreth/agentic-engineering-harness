---
slug: aeh-engineer-role-b2
status: archived
archived-at: 2026-06-19T18:47:51Z
since: 2026-06-17
parent: aeh-engineer-role
build-step: B2
---

# B2: purify harness-reviewer (harness-self detection only)

> Second build step of the accepted `aeh-engineer-role` architecture (see
> `openspec/changes/aeh-engineer-role/proposal.md` + `design.md`). Removes the
> target-tree review branches from `harness-reviewer` so it is purely the
> AEH-proper DETECT role, and relocates the Propagation-Impact Assessment Mode to
> the target-applied detection role (`target-aeh-reviewer`, built in B3).

## What

1. **Reframe the scope-clarification section** of `templates/personas/harness-reviewer.md`.
   The old table contrasted harness-reviewer with the `health-check` playbook; it
   now contrasts the two DETECT roles split by tree -- `harness-reviewer`
   (AEH-proper, runs in the AEH root, reviews the harness) vs `target-aeh-reviewer`
   (target-applied, runs in the target, reviews a target's AEH adoption, with the
   `health-check` playbook as its procedure). Adds a one-line detect/remediate
   matrix placement (harness-reviewer = DETECT, `aeh-engineer` = REMEDIATE).

2. **Relocate Propagation-Impact Assessment Mode** out of `harness-reviewer`.
   The whole section is removed and replaced with a precise pointer to
   `templates/personas/target-aeh-reviewer.md` § "Propagation-Impact Assessment
   Mode" -- the consumer-side detection mode runs IN the target against the
   target's local state, so it belongs to the target-applied detector. (B3 lands
   the relocated content in that file; this is a forward pointer that resolves
   once B3 commits, within the same un-pushed rebuild batch.)

3. **Remove the target-tree review branches** from the review dimensions:
   - Dimension 4: the two "If reviewing a target project's AEH setup" overlay
     checks and the `bin/validate-personas.sh /path/to/target` target invocation.
   - Dimension 4: the "Archaeologist Baseline Specs" subsection (a target
     `openspec/specs/baseline-*.md` check) -- relocates to `target-aeh-reviewer`.
   - Review Process bash: the commented `./bin/validate-personas.sh /path/to/target`
     line.
   - Extended scan sources: trim the direct target-tree reads (`docs/AE/decisions.md`,
     target-side `docs/AE/reports/`) -- the harness-reviewer reads HARNESS-SIDE
     evidence only (the per-target `targets/<slug>/` workspace is harness-side; the
     target's own tree is not). Target-side patterns reach the harness via the
     private capture inbox or a `target-aeh-reviewer` escalation.

4. **Fold: base-templates-must-not-cite-harness-only-PATHS** (private capture
   `refresh-template-step0-harness-only-script-ref`). Extend Dimension 4's
   "No cross-layer construct references" check with a sibling "No harness-only path
   or script references in base templates" check: a base/target-facing template
   must not invoke a harness-only path (`bin/...`, `templates/...`) by a bare
   relative path that will not resolve in a target tree. The fix is to name the
   CONTRACT, or use an absolute harness path for a deliberate sync-from-harness
   exception.

## Why

`harness-reviewer` was dual-purpose: it reviewed the harness AND carried branches
for reviewing a target's AEH setup (overlay checks, target baseline-spec checks,
the target validate invocation, the propagation-impact mode). Under the AEH-vs-Target
taxonomy those target-tree concerns belong to `target-aeh-reviewer` (the
target-applied DETECT role, runs in the target). Leaving them in `harness-reviewer`
keeps the role dual-scoped -- the same seam the rebuild removes elsewhere -- and
contradicts the enforced fence (an AEH-proper role has no target-tree access).
Purifying `harness-reviewer` to harness-self detection makes the detect/remediate
matrix legible: `harness-reviewer` detects the harness, `target-aeh-reviewer`
detects a target, neither does the other's job.

## Scope

In scope: items 1-4 above, all within `templates/personas/harness-reviewer.md`.

Out of scope (later steps):
- Creating `target-aeh-reviewer.md` and landing the relocated Propagation-Impact
  Mode + the overlay/baseline checks there (B3).
- The deterministic `bin/` AEH-practice check framework the target-aeh-reviewer
  runs (B4).
- The enforced `docs/AE/`-only fence permission allowlist (B6).
- The `orchestrator` -> `target-orchestrator` rename (B5) -- B2 keeps the token
  `orchestrator` where it appears (harness-reviewer reviews the orchestrator
  TEMPLATE, which is a harness file -- correct and retained).

## Acceptance criteria

1. `harness-reviewer.md` contains no "if reviewing a target project" branch, no
   `/path/to/target` validate invocation, no Archaeologist target-baseline check,
   and no Propagation-Impact Assessment Mode body.
2. The scope-clarification section contrasts `harness-reviewer` with
   `target-aeh-reviewer` (not the health-check playbook directly) and places
   harness-reviewer as the AEH-proper DETECT role.
3. Dimension 4 carries the new "No harness-only path or script references in base
   templates" check.
4. A precise (non-dangling-after-B3) pointer to `target-aeh-reviewer.md` replaces
   the relocated content.
5. Publication gate passes; B2 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- Predecessor: `openspec/changes/aeh-engineer-role-b1/`.
- Folded capture (private; dispositioned in `TRIAGE-2026-06-17`):
  `refresh-template-step0-harness-only-script-ref`.
- Forward dependency: B3 lands the relocated Propagation-Impact Mode + the overlay
  and baseline checks in `target-aeh-reviewer.md`.
