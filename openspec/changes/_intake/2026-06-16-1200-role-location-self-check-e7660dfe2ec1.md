---
captured-at: 2026-06-16T12:00:00Z
captured-from: e7660dfe2ec1
captured-during: harness intake-triage session, AEH-vs-Target role-taxonomy design conversation
area: governance / personas
status: untriaged
---

# Every role self-checks at Step 0 that it was invoked in its correct tree TYPE (R2 enforcement)

**Trigger:** While untangling the AEH-vs-Target role taxonomy, rule R2 was stated: "a role runs where it WRITES -- modifying files in tree X means being a session launched in tree X (the isolation boundary, generalized); run-location is determined by what the role writes." The operator asked that this be enforced per-role, not just for the orchestrator: every role must self-check at invocation that it was launched in the right tree type.

**Insight:** The `orchestrator-self-location-guard` proposal adds a Step 0 loud-halt for ONE role (the orchestrator, which must run in the AEH root) and explicitly DEFERRED the general form ("generalise to all roles only if it stays cheap"). The taxonomy makes the general form both cheap and principled: R2 says each role's correct tree TYPE is determined by what it writes, so each role can carry the same deterministic Step 0 self-location assertion, parameterised by its family:

- **AEH-proper roles** (`aeh-engineer`, `harness-reviewer`) assert they ARE in the AEH harness root (signature: `targets/index.md` + `templates/personas/` + local `CLAUDE.md` declares the AEH mission). Halt if launched in a target tree.
- **Target-applied roles that run IN the target** (`target-aeh-reviewer`, `target-aeh-engineer`, and the engineering personas dispatched into the target) assert they are NOT in the AEH root -- they are in a target tree (signature: a target's `docs/AE/` + its own `CLAUDE.md`, and the ABSENCE of the AEH-root signature). Halt if launched in the harness root.
- **AEH-side coordinators** (`target-orchestrator`) assert they ARE in the AEH root (same as AEH-proper) -- they run harness-side and dispatch target work via prompts.

The check is the same deterministic signature test in every role; only the expected answer flips by family. It is a structural-invariant gate (single chokepoint = Step 0; deterministic; cannot silently no-op), the first-person PREVENTION counterpart to the target-aeh-reviewer's after-the-fact DETECTION of wrong-tree role execution.

**Suggested change:**
- Generalise the self-location guard from the orchestrator to ALL roles as a uniform Step 0 "role-location precondition": each role declares its required tree type (per the taxonomy family) and self-asserts it at invocation, loud-halting on mismatch.
- Source the per-family expected signature from one shared place (CLAUDE.md taxonomy section and/or a `bin/` resolver) so the nine-ish roles do not each hand-roll divergent signature logic -- one rule, parameterised, not N copies.
- Bake the precondition into each base persona's Step 0 (so it propagates to targets) and into the harness-side personas; the `orchestrator-self-location-guard` proposal is the concrete first instance and can ship ahead of the general form.
- Cross-check against the existing role-bound-prompt Step 0 (orchestrator "Layered Persona Loading"): the role-ACTIVATION Step 0 and the tree-LOCATION Step 0 are complementary -- activation says "be this role"; location says "and you must be in this tree type to be it." Fold the location assertion into the existing Step 0 block rather than adding a competing one.

**Memory updates:** none superseded. Cross-refs: `orchestrator-self-location-guard` (the concrete first instance this generalises); `aeh-engineer-role` (R2 + the taxonomy this enforces; the per-family expected-tree mapping lives there); `_intake/2026-06-05-1847-structural-invariant-gate-pattern-*` (the deterministic-gate backbone); `integrity-review-entry-points` / `target-aeh-reviewer` (the after-the-fact DETECTION counterpart to this PREVENTION). Subtraction note: if this generalises and the orchestrator-only guard lands first, the general form must absorb (not duplicate) the orchestrator instance.
