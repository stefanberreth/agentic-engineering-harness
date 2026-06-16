---
captured-at: 2026-06-16T12:30:00Z
captured-from: e7660dfe2ec1
captured-during: harness intake-triage session, role-architecture conversation
area: governance / orchestrator-persona
status: untriaged
---

# Prompt -> result one-to-one mapping: guarantee a paired, committed result artifact per dispatched prompt

**Trigger:** During role-architecture triage, the operator flagged that AEH captures the REQUEST side of work durably (prompts are numbered files, `NNN-title.md`, versioned in git) but the RESULT side is ad-hoc (report-backs land in chat, or scattered, or only in a target's `docs/AE/reports/` if the role happened to write one). They want the request->result pairing made a first-class, one-to-one integrity invariant so the whole pipeline is revision-controlled and explainable after the fact.

**Insight:** There is a structural asymmetry in the audit trail. Every dispatched prompt `NNN` is a durable artifact; its OUTCOME is not guaranteed a durable, paired counterpart. Without a guaranteed `result/NNN` (a committed handover/report file keyed to the prompt that produced it), you cannot reconstruct, months later, what a given prompt actually produced, whether it succeeded, what it changed, or why -- the explainability the operator wants from a revision-controlled method. This is the proactive CONVENTION that the AEH-practice integrity checks (`aeh-engineer-role` build change B4, "incomplete prompt->result audit trail" violation class) would then POLICE: B4 detects a prompt with no paired result; this capture establishes the pairing that makes the absence detectable and meaningful. Convention first, check second.

**Suggested change:**
- Establish a one-to-one prompt->result pairing convention: every dispatched prompt `NNN-title.md` is guaranteed a paired, committed result artifact (e.g. `results/NNN-title.md` or `docs/AE/reports/NNN-*.md`) capturing the outcome -- what was done, what changed, pass/fail of gates, wall-clock, and a pointer to the commit(s) -- written by the executing role and routed back by the coordinator.
- Decide the home + naming so it composes with both the harness-side prompt source-of-truth (`targets/<slug>/prompts/`) and the target-side delivery/handback surface (`<target>/docs/AE/`), respecting the enforced fence (the orchestrator reads report-backs only under `docs/AE/**`).
- Make the pairing the unit the B4 integrity check verifies (one result per prompt; no orphans either way) and the explainability unit a future `parked-delivery-telemetry-tool` would roll up.
- Keep it lightweight: a result file is a short structured handover, not a ceremony; the win is GUARANTEED existence + revision control, not volume.

**Memory updates:** none superseded. Cross-refs: `aeh-engineer-role` (B4 deterministic check framework polices this; the enforced `docs/AE/**` fence bounds where the orchestrator reads results); `_intake/2026-06-15-1811-integrity-review-entry-points` (named this as a violation class; this capture is the proactive convention behind it); `_intake/2026-06-05-1847-structural-invariant-gate-pattern` (completeness-gate shape: a registry of prompts + a check that fails on an uncovered/unpaired instance); `parked-delivery-telemetry-tool` (the roll-up consumer). Relates to existing report-back disciplines (wall-clock field, report slug bracketing) which already shape result CONTENT but do not guarantee a paired, committed result FILE per prompt.
