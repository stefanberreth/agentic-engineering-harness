---
slug: orchestrator-manage-dont-do
status: proposed
since: 2026-06-01
intake: openspec/changes/_intake/2026-06-01-1043-orchestrator-manage-dont-do-altitude-discipline-77c32eea48bc.md
---

# Orchestrator manage-don't-do altitude discipline

## What

Add a "Manage, do not do" section to the orchestrator persona codifying the altitude discipline: the orchestrator MANAGES convergence of the arc toward a stable objective and JUDGES the roles' REPORTED OUTCOMES; it does NOT inspect, assess, find ground truth, build, test, commit, or push on the target itself. All groundwork -- including read-only inspection and ground-truth-finding -- flows through the engineering roles via prompts; the orchestrator consumes their reports. Includes the "two scales" coherence note (transactional-technical scale belongs to the roles; stable-objective-management scale belongs to the orchestrator) and a narrow exception (hands-on only to break a hard tie that cannot be resolved from reports, explicitly flagged).

## Why

An orchestrator session repeatedly drifted into hands-on target work -- read-only system inspection, ad-hoc operational commands, direct ground-truth gathering -- instead of driving that work through the AEH roles and judging their reported outcomes. Two problems resulted:

1. **Spirit of target-isolation violated.** Isolation's auditability/reproducibility rationale applies to inspection + assessment, not only to mutation. A narrow read of CLAUDE.md's "harness never modifies target files" misses that the orchestrator-side reading and ad-hoc inspection bypass the role-based audit trail too.
2. **Coherence loss correlated with descent.** Drift into transactional-technical work correlated with fabricated facts, mis-framings, and over-complicated invented arcs. The orchestrator's reliability degrades specifically when descending from stable-objective altitude into transactional technical work.

The current orchestrator persona has "Role Boundaries -- Do Not Cross" and "Mission Ownership -- Do Not Deflect", but neither names the altitude-mixing failure mode explicitly. This proposal lifts the rule from operator-correction-in-the-moment to template-level discipline.

## Scope

In scope:
- `templates/personas/orchestrator.md` -- new "Manage, do not do" section with: the rule (manage / judge / never inspect-or-build); the two-scales coherence note; the hard-tie exception; the auditability rationale (ground-truth-finding routes to Archaeologist / Analyst / Reviewer via prompts, NEVER to the orchestrator's hands).
- Reinforce role-dispatch guidance so that "assess X" or "find ground truth on Y" routes to a role, never to the orchestrator's own Bash calls.
- Brief mention of live-production operations being operator-run (related capture, lifted into this proposal: harness provides runbook; sandbox-bound developer never touches live production).
- CHANGELOG entry under [Unreleased] Added.

Out of scope:
- Mechanism enforcement (tool-restriction at runtime). The discipline is persona-level; runtime enforcement is a different concern.
- Revising the engineering role personas (they already own ground-truth work; this is about clarifying the orchestrator boundary).

## Acceptance criteria

1. "Manage, do not do" section landed in orchestrator persona with rule + two-scales note + hard-tie exception + auditability rationale.
2. Role-dispatch guidance reinforces routing ground-truth-finding through roles.
3. Live-production operator-only mention folded in.
4. CHANGELOG entry.
5. Intake capture status updated to promoted.

## References

- Intake: `openspec/changes/_intake/2026-06-01-1043-orchestrator-manage-dont-do-altitude-discipline-77c32eea48bc.md`
- Related: `openspec/changes/harness-role-execution-context-discipline/` (where each role runs; this proposal is about what the orchestrator does at its altitude)
- Existing orchestrator sections this builds on: "Role Boundaries -- Do Not Cross", "Mission Ownership -- Do Not Deflect", "Out-of-Lane Doctrine + Expected Pushback"
