---
slug: aeh-engineer-role-f3
status: archived
archived-at: 2026-06-19T18:47:51Z
since: 2026-06-19
parent: aeh-engineer-role
build-step: F3
---

# F3: establish the prompt->result pairing convention behind B4's flagship check

> Third follow-on to the B1-B7 rebuild. B4 shipped `aeh-practice-check.sh` whose
> flagship check is `prompt-result-pairing` -- but no persona GUARANTEED a paired,
> committed result file per dispatched prompt, so the check SKIPs on every real
> target ("the police shipped before the law"). F3 establishes the convention where
> the executing role reads it, so the check verifies something real.

## What

1. **`target-orchestrator`** -- add a "Prompt-result pairing (committed paired
   report -- definition of done)" subsection to the report-back conventions: every
   dispatched `docs/AE/prompts/NNN-title.md` gets a paired committed
   `docs/AE/reports/NNN-title.md` (same stem), written by the executing role; the
   coordinator does NOT record a prompt complete until the paired report is
   committed. One-to-one; orphan either way is a defect -- exactly what the check
   verifies. The report is a lightweight structured handover (what was done, what
   changed, gates, wall-clock, commit pointer).
2. **`developer`** -- reconcile section 6 / section 7 so the per-task report is the
   PAIRED `docs/AE/reports/NNN-title.md` (carrying the structured handover header
   plus the existing retrospective sections), with `task-[N]-retrospective.md` kept
   only as the fallback for ad-hoc (non-dispatched) work. No second report artifact
   per prompt -- the retrospective lives in the paired file.
3. **`reviewer`** -- update its intake step to read the paired report
   `docs/AE/reports/NNN-title.md` (with the fallback name), so the consumer points
   at the new convention.

## Why

B4's `prompt-result-pairing` is the flagship deterministic check, but it could only
SKIP or trivially pass because nothing in the personas produced a paired result
file named to match the prompt (the developer wrote `task-[N]-retrospective.md`,
which does not pair with `docs/AE/prompts/NNN-title.md`). Establishing the
convention at the coordinator (universal across dispatched roles) plus the
developer (the most frequent executor) and pointing the reviewer at it gives the
check a real invariant to confirm on day one -- and gives every target a durable,
auditable prompt->result trail instead of an ephemeral chat report-back.

## Decisions made (for operator ratification)

1. **The paired report subsumes the retrospective for dispatched prompts.** Rather
   than two files per prompt (`NNN-title.md` + `task-[N]-retrospective.md`), the
   reflective retrospective sections live IN the paired `NNN-title.md`. This honours
   anti-bloat and makes the pairing check verify the actual report. The legacy
   `task-[N]-retrospective.md` name is retained ONLY as the fallback for ad-hoc work
   with no dispatched numbered prompt.
2. **The universal anchor is the coordinator's DoD.** Putting "no prompt is
   complete without its paired committed report" in `target-orchestrator` makes the
   convention apply to ALL dispatched roles (analyst/architect/developer/reviewer/
   archaeologist), not just the developer. The developer carries the concrete
   writing instruction; the reviewer carries the consuming instruction.

## Scope

In scope: the three persona edits above. The check itself (B4) is unchanged -- F3
gives it something to verify.

Out of scope: renaming `task-[N]-retrospective.md` everywhere (kept as the ad-hoc
fallback); the architect's `design-<slug>-retrospective.md` (a distinct
architect-output artifact, left as is).

## Acceptance criteria

1. `target-orchestrator` states the prompt->result pairing definition of done
   (paired `docs/AE/reports/NNN-title.md`, coordinator gates completion on it).
2. `developer` writes the paired report at `docs/AE/reports/NNN-title.md` for a
   dispatched prompt, with the retrospective folded in.
3. `reviewer` reads the paired report path.
4. The convention is stated where the executing role reads it, so
   `aeh-practice-check.sh`'s `prompt-result-pairing` verifies a real invariant.
5. Validator + publication gate pass; F3 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- The check it backs: B4 (`openspec/changes/aeh-engineer-role-b4/`).
- Rationale: `retrospective-b1-b7.md` ("the police before the law").
