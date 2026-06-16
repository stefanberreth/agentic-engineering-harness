---
captured-at: 2026-06-15T19:46:00Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, harness-architecture discussion
area: orchestrator-persona
status: untriaged
---

# Orchestrator session-init self-location guard (loud halt if not run in the AEH root)

**Trigger:** The operator reports early adopters (and themselves) accidentally launching the orchestrator INSIDE a target directory -- next to the developer/analyst/architect/reviewer agents -- instead of in the AEH harness root. The orchestrator persona + CLAUDE.md document the conceptual lane but have NO runtime check that the orchestrator is physically in the right directory, so a misplaced orchestrator just proceeds silently.

**Insight:** The CONCEPTUAL boundary is well-documented (orchestrator persona "Role Boundaries -- Do Not Cross": team-manager not team-member; operates on harness files; routes to target-side roles) but there is NO runtime SELF-LOCATION guard. Neither the orchestrator persona's session-init nor CLAUDE.md's "On first message of every session" sequence checks the working directory. The detection signal already EXISTS but is never weaponised: CLAUDE.md session-init step 2 reads `targets/index.md`; launched in a target dir that file is simply absent -- an implicit failure nothing converts into a loud halt. A misplaced orchestrator quietly reads nothing and may start treating target files as its own workspace -- the exact wrong-directory violation the `integrity-review-entry-points` capture detects after the fact. Cheap to prevent, currently unprevented.

**Suggested change:**
- Add a session-init **Step 0 self-location assertion** to BOTH the orchestrator persona AND CLAUDE.md's "On first message of every session" sequence. Belt-and-suspenders is needed because the persona may not be loaded until the operator confirms the role, so CLAUDE.md must carry the check too.
- Deterministic AEH-root signature check relative to cwd: `targets/index.md` present AND `templates/personas/` present AND the local `CLAUDE.md` declares the AEH mission (not a target's `CLAUDE.md`). A target directory has none of these (it has `docs/AE/` and its own `CLAUDE.md`), so there are effectively no false positives.
- On failure: STOP, do NOT proceed, emit a LOUD operator-facing message, e.g. "You appear to be running the orchestrator inside a target directory, not the AEH harness root. The orchestrator must run in the AEH directory -- switch there and reload." Halt-and-warn, never silent-proceed.
- Edge case: tolerate launch from a harness SUBDIRECTORY (walk up to the signature, or resolve against the known harness root) so the guard flags only the real error (sitting in a target tree) without false-flagging a legitimate harness subdir.

**General role-location pattern (NOTED for triage, NOT mandated now):** the clean general form is a "role-location precondition" -- every role declares which tree it must run in and self-checks at Step 0 (target-side roles assert they are NOT in the harness root; harness-side roles assert they ARE). This is the PREVENTION / first-person counterpart to the integrity-entry-points capture's after-the-fact artefact DETECTION of the same violation. Implement the orchestrator guard concretely; generalise to all roles only if it stays cheap.

**Memory updates:** none superseded. Cross-ref: `integrity-review-entry-points` (2026-06-15-1811) -- the detection counterpart to this prevention guard; `harness-engineer-role-separation` (2026-06-15-1933) -- both rest on the "orchestrator runs harness-side" premise; `structural-invariant-gate-pattern` -- this is a deterministic invariant. Note for triage: this is a few lines in the persona + CLAUDE.md for a real, observed early-adopter failure mode -- high-value and explicitly NOT over-engineering; it can ship ahead of the larger role-separation / integrity work.
