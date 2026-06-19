---
slug: aeh-engineer-role-b4
status: in-progress
since: 2026-06-17
parent: aeh-engineer-role
build-step: B4
---

# B4: deterministic bin/ AEH-practice check framework

> Fourth build step of the accepted `aeh-engineer-role` architecture. Builds the
> extensible registry of deterministic checks that `target-aeh-reviewer` runs in a
> target -- the separable remainder of the integrity-review work (the role
> structure landed in B3; this is the framework the detect role runs).

## What

1. **Create `bin/aeh-practice-check.sh`** -- a single-chokepoint, registry-driven
   deterministic check runner. Usage: `aeh-practice-check.sh [target-path]`
   (default `.`), `--list`, `-h`. Each check is a `check_<id>` function listed in
   the `CHECKS` registry; it returns PASS / FAIL / SKIP and sets a detail message.
   Every result -- including SKIP -- is printed (the framework cannot silently
   no-op). Exit 0 if no FAIL, 1 on any FAIL, 3 on a framework error (missing check
   function, empty registry). Extending it is mechanical: add a function, register
   its id.

2. **Ship three lean, SDLC-generic checks:**
   - `prompt-result-pairing` (the flagship fold): every dispatched prompt
     `docs/AE/prompts/NNN-*.md` has a paired committed result
     (`docs/AE/reports/NNN-*.md` or `docs/AE/results/NNN-*.md`), and every result
     maps back to a prompt -- one-to-one, orphans either direction are FAIL. This
     is the prompt->result audit-trail invariant made deterministically checkable.
   - `role-activation-base`: `docs/AE/personas/_base/` is present with the five
     engineering base templates (so a dispatched role can load its base in-target).
   - `overlay-header-target-side`: each overlay's `AEH Base:` header points
     target-side (`docs/AE/personas/_base/...`), never a harness path.

3. **Wire `target-aeh-reviewer`** to name and run the framework
   (`aeh-practice-check.sh .` from the target root), with the cross-layer note
   that the script's source of truth is the harness (`bin/aeh-practice-check.sh`)
   and is delivered into the target by the AE scaffold (the same follow-on as the
   base personas) -- never invoked by a bare harness path from a target session.

4. **Structure tree:** add the script to the `CLAUDE.md` `bin/` tree.

## Why

The integrity-review work split into a role structure (the two reviewers, B2+B3)
and a separable deterministic check framework the detect role runs. A reviewer
that eyeballs invariants rots to a rubber-stamp; the durable guarantee is a
deterministic gate -- a single chokepoint with a completeness source-of-truth
that cannot silently no-op and fails the run on any violation. The
prompt->result pairing is the motivating concrete instance: AEH captures the
REQUEST side durably (numbered prompt files) but the RESULT side was ad-hoc, so
the audit trail had a structural asymmetry; a deterministic pairing check makes a
missing result detectable and meaningful.

This is built as the structural-invariant-gate pattern (single chokepoint +
completeness gate + no-bypass + review cadence) applied to AEH practice itself.
Honouring the operator's wariness about lifting non-strictly-generic things into
the harness, the framework is deliberately LEAN: a `bin/` script plus a small
registry of strictly-SDLC-generic checks (audit-trail completeness, role
loadability, cross-layer header hygiene) -- not a heavy mechanism, and not a
home for domain-specific or judgment checks (those stay the reviewer's at the
review cadence).

## Scope

In scope: items 1-4 above.

Out of scope:
- Delivery wiring that copies the script into a target tree (the same
  scaffold-delivery follow-on flagged in B3 Decision 3) -- the script is authored
  in the harness `bin/` here; in-target delivery is deferred.
- Domain-specific or judgment checks -- kept out by design (reviewer's job at
  cadence).
- The Tier-1 operational-skill pre-push hook (a different gate, queued in B3) --
  this framework is the reviewer's every-pass check runner, not the developer's
  per-push tripwire.

## Acceptance criteria

1. `bin/aeh-practice-check.sh` exists, is executable, `--list` shows the three
   checks, runs against a target path, and returns the documented exit codes
   (verified: PASS/FAIL/SKIP paths exercised against a fixture).
2. The three checks behave as specified (orphan prompts/results FAIL; missing base
   templates FAIL; harness-path overlay header FAIL; absent preconditions SKIP and
   are surfaced).
3. `target-aeh-reviewer.md` names and invokes the framework with the cross-layer
   delivery note.
4. The script is in the `CLAUDE.md` `bin/` tree.
5. Publication gate passes; B4 lands as its own commit; no push.

## References

- Parent architecture: `openspec/changes/aeh-engineer-role/`.
- Predecessors: `aeh-engineer-role-b1`/`b2`/`b3`.
- Folded captures (private; dispositioned in `TRIAGE-2026-06-17`):
  `structural-invariant-gate-pattern` (the backbone), `prompt-result-pairing`
  (the flagship check).
