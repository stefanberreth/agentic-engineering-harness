---
captured-at: 2026-06-01T10:43:46Z
captured-from: 77c32eea48bc
captured-during: target orchestration -- orchestrator repeatedly drifted into hands-on target inspection/ops; operator corrected
area: orchestrator-persona, role-discipline, target-isolation
status: promoted
promoted-to: orchestrator-manage-dont-do
promoted-at: 2026-06-01T11:30:00Z
---

# Orchestrator operating discipline: manage via roles, do not do target work hands-on; judge reports; altitude prevents drift

**Insight.** An orchestrator session repeatedly drifted into hands-on target work --
read-only system inspection, ad-hoc operational commands, direct ground-truth gathering --
instead of driving that work through the AEH roles and judging their reported outcomes.
Two problems resulted: (1) it violated target-isolation in spirit (isolation's
auditability/reproducibility rationale applies to inspection + assessment, not only to
mutation); (2) it correlated with incoherence -- fabricated facts, mis-framings,
over-complicated invented arcs -- and the drift occurred specifically when the orchestrator
descended from the stable-objective altitude into transactional technical work.

**Proposed rule (orchestrator persona).**
- The orchestrator MANAGES convergence of the arc toward a stable objective and JUDGES the
  roles' REPORTED OUTCOMES. It does NOT inspect, assess, find ground truth, build, test,
  commit, or push on the target itself.
- ALL groundwork -- including read-only inspection and ground-truth-finding -- flows through
  Archaeologist / Analyst / Architect / Developer / Reviewer via prompts; the orchestrator
  consumes their reports.
- The orchestrator puts hands on something ONLY to break a hard tie that cannot be resolved
  from reports -- rare, and explicitly flagged as such.
- Coherence anchor (the "two scales" note): keep the transactional-technical scale (the
  roles' job, judged on reports) separate from the stable-objective-management scale (the
  orchestrator's job). Mixing them is where orchestrator reliability degrades.

**Why it matters.** Target-isolation has been read narrowly as "do not mutate target files."
This widens it to "do not do target groundwork at all, including inspection" for the
orchestrator role -- because the orchestrator's value is altitude + judgment, and hands-on
descent both breaks auditability and empirically destabilises the session.

**How to apply.** Add a "manage, do not do" section to templates/personas/orchestrator.md
with the two-scales coherence note; reinforce in the role/dispatch guidance that assessment
and ground-truth-finding route to a role, never to the orchestrator's own hands.

**Related (same screen).** Live-production operations on a target are operator-run; the
harness provides the runbook; the sandbox-bound developer never touches live production.
Worth folding into the same orchestrator-persona discipline pass.
