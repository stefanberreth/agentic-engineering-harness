---
captured-at: 2026-06-15T18:11:00Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, harness-architecture discussion
area: other
status: promoted
promoted-to: aeh-engineer-role
promoted-at: 2026-06-16
promotion-note: |
  Role-structure half folded into aeh-engineer-role: entry point A = the purified
  harness-reviewer (build change B2); entry point B = target-aeh-reviewer (B3).
  Separable remainder = the deterministic, extensible bin/ AEH-practice check
  framework this reviewer runs (build change B4), to be drafted as its own proposal.
---

# Two AEH integrity entry points: harness-self review + target AEH-practice violation detection

**Trigger:** An operator inspecting `templates/personas/harness-reviewer.md` (alongside `templates/playbooks/health-check.md`) asked whether one persona cleanly handles two concerns: (1) the AEH harness's own internal integrity against its own criteria, and (2) how fully/accurately/with-what-integrity AEH is actually PRACTISED in an onboarded target, judged from observable artefacts. They want two clean, LOADABLE entry points, and intend to use (2) to assess training-program student projects -- on-demand or continuously -- to catch method drift early, before it compounds into a downstream wall.

**Insight:**
- SCOPE BLEED in the harness-reviewer persona (facts): it DECLARES harness-only scope (its scope table routes target audit to the health-check -- "Do NOT use this persona to audit a target project's AEH adoption depth") but its BODY reaches into the target tree -- Dimension-4 "if reviewing a target project's AEH setup" branches, target baseline-spec checks, `validate-personas /path/to/target`, the Propagation-Impact Assessment Mode (target-invoked, writes to `targets/<slug>/`, explicitly disables the 10-dimension structure), and lift-candidate scans. It contradicts its own boundary.
- The target-side concern is ALREADY owned, more thoroughly, by the health-check playbook (Phase 3: persona drift, structural hygiene, OpenSpec health, overlay/role-activation conformance, harness-sync marker), so the persona's straggler branches DUPLICATE it (Dim-4 target branch ~ health-check 3l; Propagation-Impact ~ 3n). The two layers already live in separate artifacts (persona + playbook); the type asymmetry is PRINCIPLED (open-ended judgment role vs repeatable checklist workflow), but the separation is leaky.
- CORRECTED north-star (supersedes an earlier misread that target review should run on un-onboarded projects -- it should NOT; an un-onboarded dir trivially reports "not onboarded"). The valuable target-integrity entry point assesses ONBOARDED targets and DETECTS AEH-METHOD VIOLATIONS from observable artefacts. Concrete violation classes named by the operator:
  - WRONG-DIRECTORY role execution: the orchestrator running (or having run -- ever, or regularly) INSIDE the target tree instead of the AEH harness root (correct). Observable from e.g. an orchestrator persona marker in the target's `.claude/`, orchestrator-authored commits in the target repo, orchestrator state written target-side.
  - LANE CROSSING: the analyst writing (or having written) code, not just requirements/specs. Observable from role-tagged work touching source.
  - PERMISSION-SCOPE VIOLATION of the isolation boundary: the orchestrator's agent permissions allowing direct read/write of the target tree BEYOND the sanctioned `docs/AE/` direct-handover path. Observable from `.claude/settings.json` permission config (the harness already ships permission-detection-patterns + baselines).
  - The general class: inconsistencies, misalignments, and lane-crossings in how the method is practised.
- Two META-requirements the operator stressed: the detection must be THOROUGH and UNCORRUPTABLE (evidence-based, hard to game, not self-attested -- mirrors the persona's existing "self-reporting forbidden without running the scan" + evidence-per-verdict discipline), and EXTENSIBLE (it must lend itself to gradually adding new integrity-test capabilities).

**Suggested change:**
- Provide TWO clean, loadable INTEGRITY entry points:
  - (A) HARNESS SELF-INTEGRITY -- one loadable persona: the purified harness-reviewer, scoped strictly to the harness root. Delete its Dim-4 target branches, target baseline-spec checks, and the `validate-personas /target` leg; relocate Propagation-Impact Mode to the health-check/orchestrator harness-sync flow (where 3n already lives); KEEP lift-candidate scanning but reframe it as "mining target evidence to improve the harness," not "auditing the target."
  - (B) TARGET AEH-PRACTICE INTEGRITY -- a single coherent entry point (decide deliberately: extend the health-check playbook, a new persona, or a shared criteria core feeding both) that, given an ONBOARDED target, detects method VIOLATIONS from observable artefacts. Make UNCORRUPTABILITY structural: prefer DETERMINISTIC checks (a `bin/` integrity-test layer reading markers, git authorship, file locations, permission configs, audit-trail completeness) that a finding cannot be talked out of, with a judgment layer over the subtler misalignments. Make it EXTENSIBLE: a registry/framework of integrity tests so new checks are added incrementally without rewrites.
- The violation classes above SEED the initial test set; each maps to an observable-artefact signal and most can be deterministic (wrong-dir role execution; lane crossings; permission-scope violations; incomplete prompt->result audit trails).
- Cross-refs: `structural-invariant-gate-pattern` intake (the deterministic backbone); the pending prompt->result-completeness drift-detector (one such integrity test); `permission-detection-patterns` + `permission-baselines` (the permission-scope tests); the isolation-boundary rule in CLAUDE.md (the wrong-dir / lane tests); `parked-delivery-telemetry-tool`.
- Subtraction-completeness sweep on any harness-reviewer removal: it is referenced from CLAUDE.md, onboarding, and the orchestrator -- relocations must update consumers in lockstep.

**Memory updates:** none superseded. Triage tensions: keep the artifact-type asymmetry if it stays principled (judgment-persona for harness-self vs a procedural/scriptable integrity-test framework for target-practice) -- the win is clean SCOPE + clean loadable ENTRY POINTS + an uncorruptable, extensible target-integrity test set, NOT symmetric forms for tidiness. The continuous/on-demand drift-detection use case (students' onboarded projects) is a genuine new capability target (repeatable, low-ceremony, evidence-based) that may justify more than a refactor.
