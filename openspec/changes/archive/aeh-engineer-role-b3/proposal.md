---
slug: aeh-engineer-role-b3
status: in-progress
since: 2026-06-17
parent: aeh-engineer-role
build-step: B3
---

# B3: target-aeh-reviewer + target-aeh-engineer personas

> Third build step of the accepted `aeh-engineer-role` architecture. Creates the
> two target-applied AEH-practice roles -- the DETECT/REMEDIATE pair that runs IN
> a target tree -- completing the detect/remediate matrix, and lands the
> Propagation-Impact Assessment Mode relocated out of `harness-reviewer` in B2.

## What

1. **Create `templates/personas/target-aeh-reviewer.md`** (target-applied DETECT,
   read-only, runs in the target). It is the loadable role that DRIVES the
   health-check playbook: it detects AEH-method violations in an onboarded target
   from observable artefacts (role activation, convention conformance, the
   prompt->result audit trail, tool/spec health, harness-sync + ownership markers,
   archaeologist baseline specs, operational-skill currency, fence policing). It
   routes findings by file location and never remediates. It carries the relocated
   **Propagation-Impact Assessment Mode** (adapted to run IN the target against the
   target's local state, with the harness delta handed in by the orchestrator).

2. **Create `templates/personas/target-aeh-engineer.md`** (target-applied
   REMEDIATE, read-write, runs in the target's own permission model). It applies
   pulled harness changes to the target's overlays/scaffolding (propagation,
   consumer side), remediates the target-side findings `target-aeh-reviewer`
   routes to it, and installs/repairs the per-target operational-skill currency
   gate (Tier 1). It is fenced out of the harness tree; AEH-side root causes
   escalate to `aeh-engineer`.

3. **Fold the per-target operational-skill + two-tier currency gate** (private
   capture `per-target-operational-skill-and-currency-gate`): the convention (a
   `/<slug>` operational skill that POINTS, never duplicates) + the two-tier model
   (Tier 1 cheap deterministic per-push tripwire; Tier 2 expensive coherence
   judgment at the review cadence) + the developer/reviewer/orchestrator ownership
   split are documented across the two roles. (Tier-1 hook template: QUEUED -- see
   Decisions.)

4. **Wire consumers of the relocation:**
   - `bin/validate-personas.sh`: add both files to the single-file (not-layered)
     exemption list; update the comment to cover target-applied single-file roles.
   - `templates/personas/orchestrator.md`: the "review changes" interpretation gate
     now DISPATCHES `target-aeh-reviewer` into the target (handing it the harness
     delta as prompt input) instead of adopting `harness-reviewer` in-session;
     applied retrofits run via `target-aeh-engineer`.
   - `templates/prompts/seed-harness-sync-marker.md.template` + `CLAUDE.md`
     propagation lines: point at the `target-aeh-reviewer` Propagation-Impact pass,
     not a harness-reviewer pass.
   - `CLAUDE.md` taxonomy: the `target-aeh-*` pair now exists (with file pointers);
     note they are NOT in the harness-side valid-roles set (they run in the target).
   - `README.md` coordinating-roles table + `CLAUDE.md` structure tree: add the two
     roles.

## Why

The detect/remediate matrix had only its AEH-proper row built (`harness-reviewer`
+ `aeh-engineer`, both from B1/B2). The target's-AEH-practice row was empty, so
detection of a target's adoption health lived as a bare playbook with no role to
own its judgment/boundaries, and remediation of target-side AEH violations had no
owner at all -- the detect-then-route-by-file-location model could not resolve
because the target-side remediator did not exist. B3 builds both, completing the
matrix and giving the relocated Propagation-Impact Mode a correct home (it is
about what THIS target must retrofit, so it runs IN the target).

## Decisions made (for operator ratification)

1. **Playbook stays a playbook; the persona is the loadable role.** The
   health-check playbook (`templates/playbooks/health-check.md`, ~548 lines of
   mechanical phase-by-phase procedure) is NOT folded into the persona. The
   persona is the judgment + boundaries + routing + location discipline that
   govern running it; it POINTS at the playbook as its procedure. This mirrors the
   orchestrator (persona) / onboarding (playbook) split and avoids duplicating the
   procedure. Alternative considered: dissolve the playbook into the persona --
   rejected (it would bloat the persona and lose the operator-facing `health`
   playbook entry point).

2. **The two roles are SINGLE-FILE personas (no `_base`/overlay split).** Their
   subject is the GENERIC AEH method (conformance + propagation), not the target's
   domain, so they need no project-domain overlay (unlike analyst/developer). They
   run IN the target. They are added to the validator's single-file exemption
   list. They are NOT added to the harness-side valid-roles set in `CLAUDE.md`
   (that set is for harness-session personas); a target session loads them from a
   dispatched prompt.

3. **Delivery-into-target wiring is a FOLLOW-ON, not built in B3.** The personas
   are authored in `templates/personas/` (source of truth). Placing them into a
   target tree (whether they propagate into `docs/AE/personas/_base/` during
   onboarding + the `refresh-base-personas` set) touches the onboarding playbook,
   the refresh template's persona enumeration, and intersects the B5 rename + the
   B6 fence. To keep B3 bounded and avoid re-sweeping, the scaffold-delivery wiring
   is deferred; until it lands, the orchestrator delivers the role into a target
   session by dispatching its content (as with any harness-delivered structural
   placement). FLAGGED so it is not mistaken for complete.

4. **Tier-1 operational-skill hook template: QUEUED.** B3 establishes the
   convention + the two-tier model + the developer/reviewer/orchestrator/engineer
   ownership split (documented in the two roles). The concrete pre-push hook
   template + the developer/reviewer/orchestrator base-persona currency-DoD deltas
   are a follow-on change -- they would collide with the B5 rename and the B6/B7
   base-persona edits if done now. Until the template ships,
   `target-aeh-engineer` installs Tier 1 by adapting the existing pre-push hook
   pattern under `templates/hooks/`.

5. **Propagation-Impact runs IN the target.** The orchestrator (harness-side)
   detects the gap and hands the harness delta (commit range + CHANGELOG diff +
   change summary) into the dispatched `target-aeh-reviewer` prompt, so the
   target-side reviewer does not reach into the harness tree (the fence cuts both
   ways). Output is a retrofit-action list at
   `docs/AE/reports/propagation-impact-YYYY-MM-DD.md`; `target-aeh-engineer`
   applies the approved actions.

## Scope

In scope: items 1-4 above.

Out of scope (later / follow-on):
- The deterministic `bin/` AEH-practice check framework the reviewer RUNS (B4) --
  B3 references it as a forward dependency.
- The enforced `docs/AE/`-only fence permission allowlist + baselines the reviewer
  POLICES (B6) -- B3 references it forward.
- The `orchestrator` -> `target-orchestrator` rename (B5) -- B3 writes
  `orchestrator`/`target-orchestrator` where natural and B5 reconciles the token.
- The role-location Step-0 self-check generalised to all roles (B7) -- B3's two
  roles already carry the target-side form of the check; B7 makes it uniform.
- Scaffold-delivery wiring + the Tier-1 hook template (Decisions 3 + 4).

## Acceptance criteria

1. `target-aeh-reviewer.md` and `target-aeh-engineer.md` exist, each with the
   taxonomy placement, the R2 location self-check (assert NOT in the harness root),
   detect-then-route-by-file-location, and the fence.
2. `target-aeh-reviewer.md` carries a Propagation-Impact Assessment Mode (the B2
   pointer now resolves).
3. The operational-skill + two-tier currency gate convention is documented across
   the two roles; the Tier-1 hook is explicitly queued.
4. The orchestrator + seed template + CLAUDE.md propagation references dispatch
   `target-aeh-reviewer`, not `harness-reviewer`.
5. Both files are in the validator's single-file exemption list; the validator
   passes.
6. Publication gate passes; B3 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- Predecessors: `aeh-engineer-role-b1`, `aeh-engineer-role-b2`.
- Folded capture (private; dispositioned in `TRIAGE-2026-06-17`):
  `per-target-operational-skill-and-currency-gate`.
- Forward dependencies: B4 (check framework), B6 (fence + permission baselines),
  B7 (uniform location self-check).
