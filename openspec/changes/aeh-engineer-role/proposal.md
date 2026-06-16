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

### 2a. AEH-engineer scope: extract-and-aggregate (catch-all for now)

**Decision (operator-confirmed 2026-06-16):** the AEH-engineer is the single CATCH-ALL owner of all AEH-project engineering ("tinkering") for now -- until a proven need to differentiate it further. It is not new machinery; it is the AGGREGATION of harness-maintenance duties that are today scattered or homeless.

A scoping sweep found ~85 distinct harness-maintenance duties, almost all currently in one of two bad places: nominally "owned by the orchestrator" (wrong lane -- a target-pipeline role), or undefined/ad-hoc (no owner). The role is built by three mechanical moves:

1. **Cut harness-maintenance OUT of the orchestrator persona.** The orchestrator (renamed `target-orchestrator`) shrinks to pure target-pipeline work plus the ONE universal right to write a capture note + flag an insight. It loses: `_intake` triage/promotion, OpenSpec proposal authoring, harness-repo commits, propagation-signal authoring, template editing, consolidation -- all currently in its persona.
2. **Re-own every CLAUDE.md rule stamped "Owner: orchestrator"** (publication gate, two-repo commit discipline, CHANGELOG, etc.) to the AEH-engineer.
3. **Give a home to the currently-ownerless duties** -- they land in the AEH-engineer for the first time.

The aggregated scope, by family:

- **Drive harness improvement:** inbox triage; turn field-notes into OpenSpec proposals + sequence them; behaviour-vs-lore divergence detection; consolidation rounds / additive-ratchet combat / CLAUDE.md size discipline / subtraction-completeness decisions.
- **Guard the public boundary:** the publication gate (leak scan) + the actual commit/push of harness changes + two-repo discipline + CHANGELOG + no-AI-attribution; the full OpenSpec lifecycle (target-detail-free authoring, the trivial-vs-substantive gate, AND the close-out/archive sequence); maintenance of the harness's own tooling (`bin/` scripts, the leak-pattern blocklist schema/example, the git-hook templates).
- **Steward the structure:** the role taxonomy + valid-roles list + role-location self-checks + the AEH-side of the `docs/AE/` fence (and being the AEH-side fixer when `target-aeh-reviewer` escalates an AEH-rooted violation); harness documentation currency (CLAUDE.md/README/structure-tree/playbook cross-refs -- harness-reviewer flags, AEH-engineer fixes); harness-side downstream-consumer propagation governance.

**Two previously-ownerless rot-gaps explicitly in scope** (operator-confirmed): the OpenSpec close-out/archive lifecycle (today no owner -> proposals risk never being archived/spec'd), and `bin/` tooling + git-hook template maintenance (today everyone RUNS them, nobody owns EVOLVING them -> they rot).

**Boundary -- what must LEAVE other lanes:** `target-orchestrator` retains only the universal capture right (write + flag), nothing else harness. `harness-reviewer` stays detection-only; the AEH-engineer is who acts on its findings. The engineering personas are instruments the AEH-engineer points at harness work, not owners.

This aggregation is a large subtraction-completeness operation on `orchestrator.md` and `CLAUDE.md` -- sweep every producer + consumer of each moved duty so nothing is left stranded (carried in build change B1).

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
  - B1. `aeh-engineer` persona aggregating the full scope (section 2a) + CLAUDE.md role-list/session-init/Commands wiring + `openspec/project.md` taxonomy principle + valid-roles set. INCLUDES the extract-and-aggregate subtraction: cut harness-maintenance out of `orchestrator.md` (leaving only the universal capture right) and re-own the "Owner: orchestrator" CLAUDE.md rules to `aeh-engineer`, with a full producer/consumer residual sweep so no duty is left stranded.
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
1a. AEH-engineer scope is recorded as the extract-and-aggregate catch-all (section 2a): the three mechanical moves, the duty families, the two previously-ownerless rot-gaps, and the orchestrator-side subtraction.
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
