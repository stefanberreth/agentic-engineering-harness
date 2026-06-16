---
captured-at: 2026-06-15T19:33:00Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, harness-architecture discussion
area: orchestrator-persona
status: promoted
promoted-to: aeh-engineer-role
promoted-at: 2026-06-16
---

# Split harness-engineering out of the orchestrator into a dedicated AEH-engineer role (lean variant)

**Trigger:** During a harness-architecture discussion, the operator proposed separating harness-engineering responsibilities out of the (target-bound) orchestrator into a dedicated harness-level role. The session itself demonstrated the friction: a target-orchestrator session generated several harness `_intake` captures, assessed harness personas, and edited harness state -- repeatedly requiring "which scope am I in" disambiguation -- while ~33 untriaged intake items sit with no dedicated owner.

**Insight:** The orchestrator is currently DUAL-SCOPED: (a) target-SDLC orchestration, and (b) harness maintenance (triage of `_intake`, harness-improvement coordination, harness-repo commits/pushes). That dual scope is the under-documented seam behind the recurring scope confusion. AEH already imposes clean role lanes + commit/push ownership on TARGETS (developer commits and pushes target code under operator authorisation; the orchestrator never touches the target repo) -- but the harness does not yet apply the same discipline to itself. The permission angle has real teeth: a target-orchestrator carrying a specific target's context should not author + commit + push PUBLIC harness artifacts -- that is the paraphrase-leak risk made structural, and it cannot be enforced by documentation or `/clear` discipline alone.

**Suggested change (LEAN variant -- the over-engineered variant is explicitly rejected):**
- Rename `orchestrator` -> `target-orchestrator` (the name encodes the subject).
- Add ONE role: **AEH-engineer** -- the harness's own orchestration/engineering lead. Owns `_intake` triage, planning, implementation-coordination of harness changes, and holds the PUBLIC harness-repo commit/push permission (publication-gated + operator-authorised). It REUSES the existing engineering personas (analyst/architect/developer/reviewer) pointed at harness work, plus the existing harness-reviewer. It does NOT spawn a parallel harness-engineering department.
- Commit/push ownership mirrors the target side, across the TWO harness-side repos: the target-orchestrator continues to own its OWN target-workspace state (the private `targets/` repo: journal, orchestrator-state, prompt source-of-truth); the AEH-engineer owns PUBLIC harness-repo improvement commits/pushes (templates, personas, playbooks, openspec proposals, CLAUDE.md/README/CHANGELOG). Make the two-repo distinction explicit so the split neither over-restricts the target-orchestrator nor leaks harness-commit rights back to it.
- Capture stays UNIVERSAL: any session may WRITE `_intake` files (cheap, sanitised, ASK-before-write). Only triage/plan/build/commit/push moves to the AEH-engineer. Capture file written-by-anyone, committed-by-AEH-engineer.
- Put full persona + layering around both `target-orchestrator` and `AEH-engineer` (the same layered-persona architecture the target roles use) as a follow-on refinement.

**Explicitly OUT OF SCOPE (operator rejected as over-engineering):** a full parallel harness engineering department (harness-analyst / harness-architect / harness-developer / ...); restricting capture to the new role; treating this as premature (volume already justifies it -- ~33 untriaged intake items).

**Memory updates:** none superseded. This FORMALISES `feedback_orchestrator_captures_not_fixes_harness` (the capture-here / build-there discipline) into an actual role + permission boundary. Cross-ref: the `integrity-review-entry-points` capture (2026-06-15-1811) -- the AEH-engineer is the natural OWNER of both integrity entry points (harness-self + target-practice); these two captures are the ORGANISATIONAL half and the WORK half of one likely-merged restructure proposal; triage should consider promoting them together. Subtraction-completeness: renaming `orchestrator` touches CLAUDE.md, the orchestrator persona, the persona-marker resolver/valid-roles list, onboarding, and every cross-reference -- the rename must run the full residual sweep.
