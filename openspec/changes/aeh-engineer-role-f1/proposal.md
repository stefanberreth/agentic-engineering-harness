---
slug: aeh-engineer-role-f1
status: in-progress
since: 2026-06-19
parent: aeh-engineer-role
build-step: F1
---

# F1: deliver the target-applied artifacts INTO the target

> First and highest-value follow-on to the B1-B7 rebuild (rationale:
> `openspec/changes/aeh-engineer-role/retrospective-b1-b7.md`). B3 and B4 authored
> `target-aeh-reviewer.md`, `target-aeh-engineer.md`, and
> `bin/aeh-practice-check.sh` -- all of which RUN in a target -- but nothing places
> them there, so they are inert. F1 wires the delivery: a fresh onboarded target
> can load the two roles and run the check script with zero harness access.

## What

1. **Decide the delivery homes (target-side).**
   - The two single-file target-applied AEH roles -> `docs/AE/roles/`
     (`target-aeh-reviewer.md`, `target-aeh-engineer.md`). A sibling of
     `docs/AE/personas/_base/`, NOT inside it: `_base/` is reserved for the five
     engineering base templates that project overlays extend; the two AEH roles are
     single-file (no overlay) so a separate `docs/AE/roles/` keeps `_base/`
     semantically pure and self-documents the role family.
   - The deterministic check script -> `docs/AE/bin/aeh-practice-check.sh`. Under
     `docs/AE/` (not the target's own `bin/`) so it respects the onboarding Phase 6
     scope boundary and the `docs/AE/`-only fence, and never collides with the
     target's own tooling.

2. **Extend the onboarding playbook** (`templates/playbooks/onboarding.md`):
   - Greenfield plan + greenfield short-circuit execute step: place the two roles
     into `docs/AE/roles/` and the script into `docs/AE/bin/`.
   - Brownfield plan: same placement task.
   - Phase 6a base-template-placement: broaden the placement prompt to also carry
     and place the two roles + the script (self-containment: content inline, script
     made executable).

3. **Extend the refresh prompt**
   (`templates/prompts/refresh-base-personas.md.template`): broaden its scope from
   "five engineering base personas" to "all AEH snapshots" -- the five base
   personas PLUS the two target-applied roles in `docs/AE/roles/` PLUS the check
   script in `docs/AE/bin/`. Filename kept (it is referenced by convention name in
   both target-applied personas); H1 + intro broadened to be honest about scope.

4. **Update `target-aeh-reviewer.md`** so it invokes the script at its delivered
   target-side path `docs/AE/bin/aeh-practice-check.sh .`, not a bare harness path,
   and remove the "until the delivery wiring lands" caveat (the wiring now lands
   here). Note the harness remains the source of truth; the target copy is a
   snapshot refreshed via the refresh prompt.

5. **Wire consumers of the new homes:** `CLAUDE.md` structure tree (note the
   target-side `docs/AE/roles/` + `docs/AE/bin/` delivery destinations; correct the
   stale "6 base personas" refresh comment to five); the target's `CLAUDE.md`
   template (`templates/project/CLAUDE.md.template`) gains a one-line note that the
   two AEH-practice roles load from `docs/AE/roles/` and the check runs from
   `docs/AE/bin/`.

## Why

Without F1, B3 and B4 are paper: a target session has no way to load
`target-aeh-reviewer` / `target-aeh-engineer` or run `aeh-practice-check.sh`,
because the onboarding scaffold and the refresh template do not deliver them. This
is the difference between "the roles exist" and "the roles work." The retrospective
identifies this as the single biggest shape mistake of the B-series (delivery
deferred three times); F1 is the redo's mandatory follow-on -- if only one F-step
is done, it must be this one.

## Decisions made (for operator ratification)

1. **`docs/AE/roles/` for the two roles, not `docs/AE/personas/_base/`.** Keeps
   `_base/` meaning "base templates an overlay extends" (the five engineering
   personas) and gives the single-file AEH roles their own legible home. Alternative
   (drop them in `_base/`) rejected: it muddies the overlay semantics and invites a
   reader to expect non-existent overlays for them.

2. **`docs/AE/bin/` for the script, not the target's own `bin/`.** Honours the
   onboarding Phase 6 scope boundary (prompts touch only `.claude/`, `docs/AE/`,
   `.gitignore`) and the `docs/AE/`-only fence; avoids colliding with target
   tooling. The harness `bin/aeh-practice-check.sh` stays the source of truth.

3. **Refresh prompt broadened in place, filename kept.** Both target-applied
   personas reference `refresh-base-personas` by convention name (the action, not
   the filename), and CLAUDE.md/CHANGELOG cite the path; renaming the file would
   orphan those references for no behavioural gain. The H1 + intro are broadened so
   the name/scope mismatch is documented, not silent.

## Scope

In scope: items 1-5 above.

Out of scope: a new deterministic check verifying the two roles + script are
present target-side (the `permission-scope` check and any infra-presence check are
F5's / a later concern); the orchestrator-state filename decision (F4); the
signature dedup (F2).

## Acceptance criteria

1. A fresh onboarded target (greenfield or brownfield) has, after Phase 6:
   `docs/AE/roles/target-aeh-reviewer.md`, `docs/AE/roles/target-aeh-engineer.md`,
   and an executable `docs/AE/bin/aeh-practice-check.sh`.
2. The onboarding plans (greenfield + brownfield) and the Phase 6a placement
   prompt all place the three artifacts.
3. `refresh-base-personas.md.template` refreshes the two roles + the script in
   addition to the five base personas.
4. `target-aeh-reviewer.md` invokes `docs/AE/bin/aeh-practice-check.sh .` and the
   "until delivery wiring lands" caveat is gone.
5. CLAUDE.md structure tree + the target CLAUDE.md template reflect the new homes;
   the stale "6 base personas" comment is corrected to five.
6. Validator passes; publication gate passes; F1 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- Rationale: `openspec/changes/aeh-engineer-role/retrospective-b1-b7.md`,
  `redo-b2-b7-with-hindsight.md`, `run-f-series.md`.
- Predecessors built but inert without F1: B3 (the two roles), B4 (the script).
