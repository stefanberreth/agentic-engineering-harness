---
slug: orchestrator-self-location-guard
status: superseded
archived-at: 2026-06-19T18:48:01Z
superseded-by: aeh-engineer-role-b7
superseded-at: 2026-06-17
since: 2026-06-16
---

> **SUPERSEDED by `aeh-engineer-role-b7`.** This proposed the orchestrator-only
> first instance and deliberately deferred the general form. B7 built the GENERAL
> form directly -- the role-location Step-0 self-check generalised to ALL roles,
> parameterised by family, sourced from one canonical signature in `CLAUDE.md` §
> "Role-location self-check" -- which ABSORBS this orchestrator-only guard (the
> orchestrator's assertion is now one instance of the uniform check; the
> standalone guard was never implemented separately, so there is nothing to
> remove). Retained for provenance; do not build this separately.

# Orchestrator session-init self-location guard (loud halt outside the harness root)

## What

Add a deterministic **session-init Step 0 self-location assertion** that halts loudly when the orchestrator is launched outside the AEH harness root. Belt-and-suspenders: the check lives in BOTH places that run at session start:

- **CLAUDE.md** "On first message of every session" -- as a Step 0 ahead of the existing banner sequence. CLAUDE.md must carry it because the orchestrator persona file is not loaded until the operator confirms the role, so a misplaced session would otherwise proceed before the persona-level check could fire.
- **The orchestrator persona** session-init -- as a Step 0 ahead of the triage scan / propagation-signal detection, so a confirmed orchestrator re-asserts its location independently of CLAUDE.md.

The signature check is deterministic and relative to cwd (walking up to tolerate a legitimate harness subdirectory): the AEH root is the nearest ancestor that has `targets/index.md` present AND `templates/personas/` present AND a local `CLAUDE.md` declaring the AEH mission. A target directory has none of these (it has `docs/AE/` and its own `CLAUDE.md`), so false positives are effectively impossible.

On failure: STOP, do not proceed, emit a LOUD operator-facing message naming the likely cause (running inside a target tree) and the fix (switch to the AEH directory and reload). Halt-and-warn, never silent-proceed.

## Why

The conceptual boundary is already well-documented -- the orchestrator persona's "Role Boundaries -- Do Not Cross" makes it a team-manager that operates on harness files and routes work to target-side roles -- but there is NO runtime check that the orchestrator is physically in the right directory. Early adopters (and the operator) have accidentally launched the orchestrator INSIDE a target directory, next to the developer/analyst/architect/reviewer agents, instead of in the harness root.

The detection signal already exists but is never weaponised: CLAUDE.md session-init reads `targets/index.md`; launched in a target dir that file is simply absent -- an implicit failure that nothing converts into a loud halt. A misplaced orchestrator quietly reads nothing and may begin treating target files as its own workspace -- the exact wrong-directory violation that an after-the-fact integrity review would later have to detect. Cheap to prevent, currently unprevented, and an observed real-world failure mode rather than a hypothetical one.

This is the PREVENTION / first-person counterpart to artefact-based DETECTION of the same violation class. It is a deterministic structural invariant in the sense of the structural-invariant-gate-pattern capture: a must-always-be-true precondition enforced at a single chokepoint (session-init) that cannot silently no-op.

## Scope

In scope:

- CLAUDE.md "On first message of every session": add a Step 0 self-location assertion ahead of the banner sequence, with the deterministic AEH-root signature, the walk-up-to-tolerate-subdirectory rule, and the loud-halt-on-failure behaviour.
- Orchestrator persona session-init: add the matching Step 0 ahead of the triage scan, cross-referencing the CLAUDE.md check (one rule, stated where each consumer needs it -- not divergent logic).
- CHANGELOG [Unreleased] entry.

Out of scope:

- Generalising the guard to ALL roles ("every role declares which tree it must run in and self-checks"). Noted in the capture as a clean general form but deliberately deferred; implement the orchestrator guard concretely first, generalise only if it stays cheap. A future rename of `orchestrator` -> `target-orchestrator` (see the role-architecture cluster) would update the guard's role name under its own subtraction-completeness sweep -- this proposal does not pre-empt that.
- Any artefact-based after-the-fact detection of wrong-directory execution in a target tree (that is the integrity-review-entry-points work).
- Tooling beyond the signature check expressed inline in the session-init steps.

## Acceptance criteria

1. CLAUDE.md "On first message of every session" carries a Step 0 self-location assertion with the three-part signature, the walk-up rule, and a loud halt on failure.
2. The orchestrator persona session-init carries the matching Step 0 ahead of the triage scan.
3. The two statements describe one check (no divergent signature logic); the persona cross-references CLAUDE.md rather than restating a different rule.
4. The halt message is operator-facing, names the likely cause (target tree) and the fix (switch to AEH root, reload), and never instructs silent-proceed.
5. CHANGELOG [Unreleased] entry present.

## References

- Provenance: `provenance.md` (intake capture 2026-06-15-1946).
- Deterministic-invariant backbone: `_intake/2026-06-05-1847-structural-invariant-gate-pattern-*`.
- Detection counterpart (after-the-fact, target-side): `_intake/2026-06-15-1811-integrity-review-entry-points-*`.
- Role premise both rest on (orchestrator runs harness-side): `_intake/2026-06-15-1933-harness-engineer-role-separation-*` and the existing `harness-maintainer-role-charter` proposal.
