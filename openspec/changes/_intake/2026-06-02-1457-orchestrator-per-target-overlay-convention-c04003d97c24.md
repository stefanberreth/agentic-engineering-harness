---
captured-at: 2026-06-02T14:57:01Z
captured-from: c04003d97c24
captured-during: harness orchestrator session, operator question about whether the orchestrator has per-target overlays the way the five engineering roles do
area: orchestrator-persona, harness-architecture, target-isolation
status: untriaged
---

# Orchestrator needs a per-target overlay file convention -- aggregate orchestrator-level per-target insights currently scatter into adjacent files

## Trigger

Operator asked whether the AEH orchestrator carries per-target overlays the same way the five engineering roles do (`<target>/docs/AE/personas/<role>.md`). It does not. The operator's framing of the actual concern (precise, captured verbatim):

> "The problem is less the switching between different projects without context clearance or new instantiation. The problem is rather, that aggregate project-specific orchestrator insights, context and knowledge gets spread into unspecified adjacent files instead of into a project-specific overlay file. While this is separate from the overlay instructions in the other agent roles, it is not none."

## Current state

The harness scaffolds per-target overlays for FIVE engineering roles only -- analyst, archaeologist, architect, developer, reviewer -- at `<target>/docs/AE/personas/<role>.md`. The orchestrator persona base template (`templates/personas/orchestrator.md`) excludes itself from this overlay convention explicitly: the onboarding playbook's scaffold step (around line 730 of the persona) lists "five overlay files" and orchestrator is not among them.

Per-target orchestrator context today scatters across:
- `targets/<slug>/profile.md` -- identity, stack, prompt-delivery policy, harness-sync-sha.
- `targets/<slug>/decisions.md` -- target-specific architectural decisions the orchestrator honours.
- `targets/<slug>/orchestrator-state.md` -- runtime pipeline position + execution log + scorecard.
- `targets/<slug>/calibration-log.md` -- per-target wall-clock calibration data.
- `targets/<slug>/review-history.md` -- append-only longitudinal findings.
- Ad-hoc `parked-*.md` and other adjacent files.

The orchestrator persona base template ALSO carries `§CHAIN.PROJECT` and similar "project extension point" placeholders that hint at a target-side overlay surface -- but nowhere does the template anchor those extension points to a concrete file path the orchestrator session reads at initialisation.

## The defect (operator-confirmed framing)

This is NOT a problem about session-switching cleanliness (clearing context between targets is a separate concern, addressed by `feedback_clear_context_on_role_switch` and similar). The actual defect is structural:

**Aggregate orchestrator-level per-target insights, context, knowledge, and policy spread into unspecified adjacent files -- because no canonical per-target orchestrator overlay file exists to hold them.**

Examples of orchestrator-level per-target knowledge that currently has no canonical home:
- Target-specific chain-wrapper scripts and halt sentinels (template's `§CHAIN.PROJECT` extension; today often duplicated across multiple `targets/<slug>/deliverables/*.sh` and `decisions.md` entries).
- Target-specific quality-gate thresholds (block-and-alert vs warn-only; per-target reviewer cadence overrides).
- Target-specific dispatch conventions (which roles to default to for which kind of work; per-target prompt-number conventions).
- Target-specific operator preferences that govern the orchestrator's behaviour for THIS target only.
- Target-specific runbook pointers (e.g. PROD rollback runbook lives at <path>; deployment escalation contact lives at <path>).
- Per-target deploy-pairing posture conventions (lockstep / expand-only / case-by-case).
- Per-target push-gate disposition (operator-manual / in-prompt / never-from-prompt -- before the `boundary-push-policy` proposal lands as a profile-field).

Without a canonical overlay file, these accumulate informally into whichever adjacent file feels closest, with no consistency across targets and no harness-reviewer surface to audit completeness or staleness.

## Why this is separate from the engineering-role overlay mechanism

The engineering-role overlays serve a different purpose: they layer project conventions (BDD-vs-TDD, design-system tokens, schema-naming, etc.) on top of generic methodology, and they load INTO TARGET SESSIONS via two-file layered-persona load at handoff time.

The orchestrator runs HARNESS-SIDE. It does not need (and cannot use) the same two-file layered load mechanism -- the orchestrator's overlay would be read by the harness-side session at initialisation, NOT by a target session. The mechanism is different; the need (per-target customisation surface) is parallel.

## Proposed remedies (intake, not implementation)

The decision points the implementer faces, none decided here:

1. **Overlay file path convention.** Two reasonable shapes:
   - **Harness-side overlay:** `targets/<slug>/orchestrator-overlay.md` (or just `orchestrator.md`, sibling to the existing state/profile/decisions files). Read by the orchestrator session at initialisation alongside `profile.md` and `orchestrator-state.md`. Symmetric with the rest of the harness-side target workspace; the orchestrator session is filesystem-scoped to the harness directory so this works without bind-mount tricks.
   - **Target-side overlay (mirroring engineering pattern):** `<target>/docs/AE/personas/orchestrator.md`. Symmetric with the five engineering roles but operationally awkward because the harness-side orchestrator session must read across the bind-mount into the target tree. Doable; some overhead.

   Recommendation (intake-author's view): harness-side. The orchestrator's context, state, and overlay should all live in the same `targets/<slug>/` workspace; the engineering-role overlays' target-side location reflects THEIR target-session-readability requirement, which doesn't apply to the orchestrator.

2. **Overlay file structure / contents.** What goes in -- candidate categories drawn from the "scatter examples" above:
   - Project-extension-points the base template lists (`§CHAIN.PROJECT`, `§BOUND-PUSH.PROJECT` once the boundary-push-policy proposal lands, others).
   - Target-specific orchestrator behaviour overrides (quality-gate threshold, reviewer cadence, dispatch conventions).
   - Per-target runbook + escalation pointers.
   - Per-target operator preferences governing orchestrator turn-shape.
   - Per-target dispatch-pattern conventions (prompt number prefix, file-naming).

3. **Onboarding scaffold update.** The onboarding playbook (greenfield + brownfield paths) currently scaffolds five overlays; needs to scaffold six. Initial overlay content for the orchestrator overlay: minimal header pointing to the harness master + a clearly-marked empty extension-point list for the operator / future architect to populate.

4. **Harness-reviewer dimension update.** Add a check: orchestrator overlay file present in each `targets/<slug>/`; extension-point sections of the base template that have project-specific content elsewhere (in `decisions.md`, `profile.md`, etc.) flagged as candidates for migration to the overlay.

5. **Retrofit prompt template.** New `templates/prompts/seed-orchestrator-overlay.md.template` for pre-existing targets that predate the convention -- scaffolds the overlay file at the canonical path with the base template's extension-point headers and a "TODO: migrate content from <list of likely adjacent files>" stub.

6. **Base persona references.** Update `templates/personas/orchestrator.md` extension-point sections (`§CHAIN.PROJECT`, etc.) to explicitly name `targets/<slug>/orchestrator-overlay.md` (or the chosen path) as the canonical location. Anchor the hint that today is a dangling pointer.

7. **Migration of existing scattered content.** A separate cleanup activity, not part of the convention-introduction proposal: walk each existing target's `decisions.md` + `orchestrator-state.md` + `parked-*.md` files and migrate orchestrator-level per-target content into the new overlay. Likely a per-target operator-confirmed pass; orchestrator + harness-reviewer pair work.

## Out of scope (explicit)

- Per-target overlays for `harness-reviewer` or `strategist` (those roles' scope is generic-across-targets; no per-target overlay is needed today).
- Changing the engineering-role overlay mechanism (the two-file layered load is fine as-is; this proposal is purely additive for the orchestrator role).
- Auto-migration of all scattered orchestrator-level content from existing targets (manual, operator-confirmed per target; out of scope for the convention-introduction proposal).
- Defining what specific extension points the orchestrator base template should grow (separate concern; the OVERLAY-FILE-existing-as-a-surface is the load-bearing point, what fills it is filled over time as new per-target patterns surface).

## Suggested triage

Promote to `openspec/changes/orchestrator-per-target-overlay-convention/` (or similar slug). Standalone proposal -- the work-surface is small (path convention + base-template anchor edits + onboarding-scaffold update + harness-reviewer-dimension + retrofit prompt template). The retrofit + migration of existing content is the larger downstream concern; that's per-target operator-paced work, not part of the convention-introduction proposal.

Pair with these existing intakes (related-not-blocking):
- `2026-06-01-1043-orchestrator-manage-dont-do-altitude-discipline` -- orchestrator's altitude discipline; this overlay convention gives that discipline a per-target customisation surface.
- `2026-06-01-1114-target-side-orchestrator-role-defect` -- execution-context discipline; orchestrator is harness-side, which informs the harness-side path choice in #1 above.
- `2026-06-01-2030-orchestrator-db-migration-prompts-must-declare-deploy-pairing` -- per-target deploy-pairing posture is one of the candidate contents for the new overlay file.

## References

- `templates/personas/orchestrator.md` -- onboarding scaffold step (around line 730); excludes orchestrator from the five-overlay list. Project extension points (`§CHAIN.PROJECT`, others) listed in the persona body without an overlay-file anchor.
- `templates/playbooks/onboarding.md` -- scaffolds five engineering overlays at the documented path.
- Operator's exact framing 2026-06-02: "aggregate project-specific orchestrator insights, context and knowledge gets spread into unspecified adjacent files instead of into a project-specific overlay file. While this is separate from the overlay instructions in the other agent roles, it is not none."
