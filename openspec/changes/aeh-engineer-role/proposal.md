---
slug: aeh-engineer-role
status: proposed
since: 2026-06-16
supersedes: harness-maintainer-role-charter
merges: harness-maintainer-role-charter + _intake/2026-06-15-1933-harness-engineer-role-separation + _intake/2026-06-15-1811-integrity-review-entry-points (role-structure half) + _intake/2026-06-16-1200-role-location-self-check
review: DRAFT-records-operator-decisions -- the architecture below was settled with the operator across the 2026-06-16 triage conversation; build is sequenced follow-on changes
note: slug retained for stability though scope broadened from one role to the full role architecture (per the slug-stability convention, the rename was weighed and declined to avoid churning committed cross-references)
---

# AEH role architecture: the AEH-vs-Target taxonomy, the five-role roster, the enforced fence

> Architecture decision record. Anchored by the new `aeh-engineer` role but broader: it
> establishes the role taxonomy, the full roster, the enforced harness/target fence, and
> the per-role location self-check. The BUILD is sequenced follow-on changes (enumerated
> in Scope). Supersedes `harness-maintainer-role-charter`.

## What

### 1. The AEH-vs-Target role taxonomy (governing principle)

Every AEH role is either AEH-proper or target-applied, and the role's NAME says which:

- **AEH-proper** (no "target" in the name) -- owns the harness as a published, generic product: completeness, consistency, redundancy-avoidance, clarity, effectiveness. Members: `aeh-engineer`, `harness-reviewer`.
- **Target-applied** ("target" in the name) -- owns applying AEH to one specific target. Members: `target-orchestrator`, `target-aeh-reviewer`, `target-aeh-engineer`.
- The engineering personas (`analyst`/`archaeologist`/`architect`/`developer`/`reviewer`) are layer-neutral instruments reused by both families; they carry no "target" in their name for that reason.

Name-encodes-family is the deliverable, not decoration: an adopter tells from the role list alone which roles touch their tree. That legibility is the maturity bar -- adoptable without confusion.

### 2. The roster as a detect/remediate matrix + a coordinator

|                          | DETECT (read-only)   | REMEDIATE (read-write) | Runs in   |
|--------------------------|----------------------|------------------------|-----------|
| **AEH-proper** (harness) | `harness-reviewer`   | `aeh-engineer`         | AEH root  |
| **target's AEH practice**| `target-aeh-reviewer`| `target-aeh-engineer`  | the target|

Plus `target-orchestrator` (renamed from `orchestrator`): the AEH-side coordinator of a target's pipeline; dispatches the target-side roles via prompts; runs in the AEH root.

- `aeh-engineer` (NEW): the harness's engineering lead -- `_intake` triage, improvement-architecting, consolidation rounds, the PUBLIC harness-repo commit/push permission (publication-gated, operator-authorised), behaviour-vs-lore divergence detection, harness-side propagation governance. Reuses the engineering personas pointed at harness work; harness-reviewer is its gate. Folds in the whole superseded `harness-maintainer-role-charter`.
- `harness-reviewer` (EXISTS; to be purified): harness self-integrity detection. Loses its target-tree branches (those move to `target-aeh-reviewer`).
- `target-orchestrator` (RENAME of `orchestrator`): unchanged charter, renamed to encode its target-application subject.
- `target-aeh-reviewer` (EVOLVES from the health-check playbook): detects AEH-method violations in an onboarded target from observable artefacts; runs IN the target (read-only); the health-check playbook becomes its procedure; the deterministic `bin/` check framework (from #2) is what it runs.
- `target-aeh-engineer` (NEW): applies pulled harness changes to a target's overlays and remediates detected target-side AEH violations; runs IN the target (read-write, the target's own permission model).

### 3. R2 + run-where-you-write + the enforced fence

- **R1:** the name encodes the subject (taxonomy).
- **R2:** a role runs where it WRITES. Run-location is determined by what a role writes, not chosen. Enforced per-role by a Step 0 location self-check (captured separately: `_intake/2026-06-16-1200-role-location-self-check`): AEH-proper roles + the coordinator assert they are in the AEH root; target-applied roles that run in the target assert they are NOT in the AEH root. One deterministic signature test, parameterised by family.
- **The fence (enforced, not documented):** AEH-side roles are fenced out of the target tree, with ONE narrow allowlisted exception: `target-orchestrator` may read/write ONLY `<target>/docs/AE/**` (deliver prompts; read report-backs). Every other path in the target tree, and every other AEH-side role (`aeh-engineer`, `harness-reviewer`), has NO target access. Enforcement is a permission allowlist scoped to `docs/AE/`, and `target-aeh-reviewer` polices that the orchestrator's actual permissions do not exceed it. This replaces the softer current CLAUDE.md rule ("harness may read a target for assessment").

### 4. Detect-then-route-by-file-location (dissolves the cross-boundary fix problem)

Detection may cross trees (by reading evidence); remediation never does. A finding is routed to the engineer who owns the tree where the offending file lives:

- offending file is target-side -> `target-aeh-engineer` fixes it, in the target.
- offending file is AEH-side (e.g. the AEH project's `.claude/settings.json` granting over-broad perms) -> escalated to `aeh-engineer`, who fixes it in the AEH root.

`target-aeh-engineer` cannot edit AEH files (fenced to the target); `aeh-engineer` cannot edit the target. No role both detects-everywhere and fixes-everywhere -- that was the phantom contradiction.

### 5. Propagation split + universal capture

- Propagation harness-side (what is a release, atomic vs piecemeal, release-notes, breaking-change flagging) = `aeh-engineer`. Target-side (a target detecting it is behind via `harness-sync-sha`, then applying the gap) = `target-aeh-reviewer` detects, `target-aeh-engineer` applies. AEH-engineer authors the mechanism; the target runs it.
- Capture stays UNIVERSAL: any session may WRITE `_intake`. Only triage / plan / build / commit / push moves to `aeh-engineer`.

## Why

The orchestrator is currently dual-scoped (target-SDLC orchestration AND harness maintenance) -- the seam behind recurring "which scope am I in" confusion and the unowned additive ratchet. AEH imposes clean role lanes + commit/push ownership on targets but never on itself. Intake volume already justifies a dedicated owner; the harness is published and consumed downstream, so the permission boundary (a target-context session must not push public harness artifacts) has teeth; and the project must mature -- legible roles, an enforced fence -- to be adoptable without maintenance headaches. The taxonomy is the maturity lever: the methodical untangling of AEH-proper concerns from target-application concerns, expressed where every reader meets it (the role names), with the fence making the harness/target boundary structural rather than conventional.

## Scope

In scope (this proposal -- the architecture decision record):

- Record the taxonomy, the five-role roster + the detect/remediate matrix, R2, the enforced `docs/AE/`-only fence, detect-then-route-by-file-location, the propagation split, and universal capture.
- Mark `harness-maintainer-role-charter` superseded-by this proposal.
- Enumerate the sequenced BUILD changes (each its own proposal, so none is a monolith):
  - B1. `aeh-engineer` persona + CLAUDE.md role-list/session-init/Commands wiring + `openspec/project.md` taxonomy principle + valid-roles set.
  - B2. Purify `harness-reviewer` (remove target-tree branches; relocate Propagation-Impact Mode) -- the #2 entry-point-A work.
  - B3. `target-aeh-reviewer` (evolve the health-check playbook into a loadable role) + `target-aeh-engineer` persona -- the #2 entry-point-B role structure.
  - B4. The deterministic `bin/` AEH-practice check framework `target-aeh-reviewer` runs (the separable remainder of #2; extensible registry).
  - B5. `orchestrator` -> `target-orchestrator` rename (its own change; acceptance = clean repo-wide residual scan; includes the marker-value back-compat note).
  - B6. The enforced `docs/AE/`-only fence: permission allowlist/baseline + the CLAUDE.md rule change replacing "harness may read a target for assessment".
  - B7. The role-location Step 0 self-check generalised to all roles (from `_intake/2026-06-16-1200-role-location-self-check`; absorbs `orchestrator-self-location-guard`).

Out of scope:

- All persona/wiring/mechanism implementation (the B-list above; each is its own reviewed change).
- The concrete release/propagation mechanism (versioning, release-notes format, consumer consistency verification) -- needs the repo-owner conversation; deferred.
- A future `target-project engineer` beyond `target-aeh-engineer` (named in the taxonomy as having room; not designed).
- The onboarding bootstrap-read exception detail (see design.md) -- resolved there as a default, finalised in B6.

## Acceptance criteria

1. Taxonomy, roster + detect/remediate matrix, coordinator, R2, the enforced `docs/AE/`-only fence, detect-then-route-by-file-location, propagation split, and universal capture are all recorded.
2. `harness-maintainer-role-charter` is marked `status: superseded` with `superseded-by: aeh-engineer-role`.
3. The build is enumerated as sequenced B1-B7 changes, each able to land and be reviewed independently.
4. #2's role-structure is folded in (the two reviewers = integrity entry points A/B), leaving only its deterministic check framework (B4) as separable.
5. The operator confirms the architecture before any B-change build task runs.

## References

- Provenance: `provenance-role-separation.md` (intake 2026-06-15-1933).
- Superseded: `harness-maintainer-role-charter` (operator-confirmed 2026-06-06; carried forward + reframed).
- Folds in: `_intake/2026-06-15-1811-integrity-review-entry-points` (role-structure half -> the two reviewers; B4 = its check framework), `_intake/2026-06-16-1200-role-location-self-check` (-> B7).
- Concrete first instance of B7, already proposed: `orchestrator-self-location-guard`.
- Formalises memory rule `feedback_orchestrator_captures_not_fixes_harness` into a role + permission boundary.
- Rehabilitated under the harness-side propagation scope: `harness-update-propagation-signal`, `harness-cross-container-isolation`.
- Deterministic-gate backbone: `_intake/2026-06-05-1847-structural-invariant-gate-pattern`.
