---
slug: subtraction-completeness-discipline
status: archived
archived-at: 2026-06-19T18:48:01Z
since: 2026-06-06
---

# Subtraction-completeness discipline (sweep producers + consumers before a removal is "done")

## What

Add one tight cross-cutting discipline to the three roles that author and review changes which REMOVE, RENAME, or FOLD a convention (a filename, rule, state slot, path, flag, tag):

- **architect** (§8 Principles): a design that subtracts a convention must enumerate its producers + consumers and carry the reference sweep as explicit `tasks.md` tasks with a mechanical residual-scan completion signal.
- **reviewer** (Principles + a note on the Absence Check): a change that retires a token is not complete until a repo-wide residual scan over that token returns only labelled migration notes and deliberately-out-of-scope history; a surviving reference in canonical-set context is a finding.
- **harness-reviewer** (Dimension 4): the same check, explicit, paired with the Dimension-3 "still earns its place" forgetting question.

No new mechanism, no new file class, no tooling -- three Principles-level additions, mirroring how the document-placement ground-truth discipline was propagated.

**Two layers, deliberately.** `architect.md` and `reviewer.md` are AEH **base templates** -- they propagate into target projects and govern subtractions in the *target's own* code (renaming a column, removing an endpoint, deleting a flag: leaving consumers behind is a runtime bug). `harness-reviewer.md` is a **harness-side role** -- it governs subtractions in the *harness itself* (a persona allowlist, a CLAUDE.md tree). The discipline is identical in shape; the worked example and the partner-lens reference differ by layer. The two layers must not cross-reference each other's constructs (e.g. the target architect must not point at the harness-reviewer's Dimension-3 forgetting question, which exists only in the harness layer).

## Why

Addition has always been safe-by-default in this harness; **subtraction has had no discipline.** The additive ratchet that motivated `orchestrator-state-consolidation` is, at root, the absence of a safe removal operation: pipelines acquire rules and slots and nobody can confidently take one away, because taking one away means finding every place that produces or consumes it -- and there is no standing rule that says you must.

The motivating instance is concrete and recent: a consolidation proposal retired three state files and was declared sound against an abstract migration mapping, without scanning the harness for the files that actually produced and consumed those names. The result was an under-scoped first pass (declaration updated, machinery -- onboarding scaffold, health-check reads, tools recording -- left behind), caught only when a review happened to grep broadly. The fix that session was manual and ad hoc; this proposal makes it a standing discipline so the next subtraction does not repeat it.

This is the symmetric partner of the forgetting question added in `orchestrator-state-consolidation`: that lens decides *whether* something should be removed; this discipline ensures that *once removed, it is removed completely* -- declaration and machinery together -- rather than forked into a self-contradiction.

## Scope

In scope:

- architect §8 Principles bullet (plan-time enumeration + tasks.md sweep + residual-scan signal).
- reviewer Principles bullet + a one-line tie-in on the Absence Check (the inverse blind spot: references that should be gone but aren't).
- harness-reviewer Dimension 4 bullet (explicit residual-scan-clean check on any subtraction).
- CHANGELOG [Unreleased] entry.

Out of scope:

- CLAUDE.md Working Rules pointer. CLAUDE.md is at its size ceiling; adding a bullet there is deferred to `claude-md-size-discipline`, which owns the relocate-detail-to-canonical-home-and-leave-a-pointer mechanism. The operative rule lives in the personas now; the CLAUDE.md pointer rides the size-discipline work.
- A continuous declaration/machinery coherence AUDIT (a standing duty to detect drift that accumulates when no single change is responsible). That is role-ownership, deferred to `harness-maintainer-role-charter` (see `_intake` capture, 2026-06-06).
- Any tooling/automation. The discipline is a habit + a grep, not a subsystem.

## Acceptance criteria

1. architect §8 Principles carries the subtraction-enumeration + tasks.md-sweep bullet.
2. reviewer carries the residual-scan-clean completion rule and ties it to the Absence Check.
3. harness-reviewer Dimension 4 carries the explicit subtraction residual-scan check, paired with the Dimension-3 forgetting question.
4. The three additions use consistent wording (one discipline, three role-appropriate framings) -- no divergence.
5. CHANGELOG [Unreleased] entry present.

## References

- Motivating instance + hindsight: `orchestrator-state-consolidation` implementation session, 2026-06-06.
- Inbox captures: `_intake/2026-06-06-1255-subtraction-completeness-scan-before-plan-sound-*`, `_intake/2026-06-06-1256-declaration-vs-machinery-divergence-maintainer-charter-*`.
- Symmetric partner: the "still earns its place" forgetting question (harness-reviewer Dimension 3, added by `orchestrator-state-consolidation`).
- Deferred companions: `claude-md-size-discipline` (CLAUDE.md pointer), `harness-maintainer-role-charter` (continuous coherence audit).
