---
slug: harness-maintainer-role-charter
status: superseded
superseded-by: aeh-engineer-role
superseded-at: 2026-06-16
since: 2026-06-06
decision: resolution-2 (dedicated harness-maintainer role) -- operator-confirmed 2026-06-06
needs: design.md + tasks.md (this proposal records the charter; the build is a follow-up design round)
---

> SUPERSEDED 2026-06-16 by `aeh-engineer-role`. At triage the operator folded this
> charter's dedicated-role decision into a single `aeh-engineer` role reframed by the
> AEH-vs-Target role taxonomy. This charter's three concerns are carried forward there;
> its "downstream propagation" scope is split harness-side (AEH-engineer) vs target-side
> (target-applied roles). Retained here as history; archive once the supersession is
> accepted. Do not build from this file.

# Harness-maintainer role charter

## What

Establish a dedicated **harness-maintainer** persona, distinct from the harness-reviewer. The maintainer owns the harness as an evolving, *published, downstream-consumed* product. Its charter spans three concerns:

1. **Behaviour-vs-lore divergence.** Read how roles (especially the orchestrator) actually behave day-to-day vs what the instruction files prescribe; spot drift; architect corrections.
2. **Improvement architecting.** Turn field-notes and divergence findings into OpenSpec change proposals; sequence and consolidate them; prevent the additive ratchet (redundant/overlapping rules and state) by owning a periodic consolidation round.
3. **Downstream-consumer propagation governance (the load-bearing new scope).** Own how changes to the public harness repo are *propagated, documented, and consumed* by downstream adopters without tearing their setups apart.

The harness-reviewer is the maintainer's **quality gate** -- the verdict-producer that bookends maintainer-authored changes. Both roles are built out together: the maintainer architects and sequences; the reviewer gates.

## Why

Two pressures converged.

**Altitude smell.** Harness re-engineering conversations currently happen with whatever session is in the chair -- frequently the orchestrator, whose charter is to *drive a target pipeline* ("stay in manager lane"; "improve the templates ... present the edit as a candidate" -- surface, not architect). The harness-reviewer reviews the harness *as written* (file-vs-file consistency, currency, leakage) and produces verdicts; it does not consume orchestrator field-notes or detect behaviour-vs-lore divergence. So nobody owns divergence detection or improvement architecting; the work falls to ad-hoc chat -- which is exactly how the additive ratchet and state overlap accumulated unchecked (see `orchestrator-state-consolidation`).

**Downstream propagation is unowned and already biting.** The harness is published to a public Git repo and consumed by real downstream adopters (friends-and-family scale, started ~weeks ago, updating via `git pull`). From a downstream orchestrator's perspective -- often in a very different working context from where a change was authored -- the updates arrive as *scattered* commits. There is no discipline for how a refactor like `orchestrator-state-consolidation` reaches a consumer: how it's versioned, documented, sequenced, and applied so it does NOT (a) tear apart a consumer's working setup, or (b) land half-consumed, leaving the consumer in an inconsistent state when the change requires atomic adoption to be coherent. The existing `harness-update-propagation-signal` (the `harness-sync-sha` marker) was built for one-operator-many-targets; the larger, real prize is many-consumers-downstream, and it belongs under this role. Finding C from the 2026-06-06 retrospective is thereby partially rehabilitated: the propagation mechanism is more justified at consumer scale than at solo-operator scale, and the maintainer owns making it robust.

The maintainer is also the natural counterpart for the operator's standing conversation with the **public-repo human owner** about propagation policy: what constitutes a release, what must be adopted atomically vs incrementally, how breaking/consistency-requiring changes are flagged, and how a consumer verifies they are in a consistent state after pulling.

## Scope

In scope (this proposal -- charter + decision record):

- Record resolution 2 (dedicated role) as operator-confirmed.
- Define the three-concern charter (above).
- Define the maintainer/reviewer relationship: maintainer architects + consolidates; reviewer gates.
- Enumerate the downstream-propagation sub-concerns the follow-up design must address (below).

Out of scope (deferred to the follow-up design round + repo-owner discussion):

- The persona file itself (`templates/personas/harness-maintainer.md`), session-init wiring, CLAUDE.md role-list entry.
- The concrete propagation/release mechanism (versioning scheme, release notes format, atomic-vs-incremental change classification, consumer-side consistency verification). This needs the repo-owner conversation first.
- Building out the harness-reviewer as the maintainer's gate (new dimensions for divergence and propagation-readiness).
- Reconciling `harness-update-propagation-signal` and `harness-cross-container-isolation` under the maintainer's propagation charter.

### Downstream-propagation sub-concerns for the follow-up design

- **Change classification.** Which changes are safe to pull piecemeal vs which require atomic adoption to stay coherent (e.g. `orchestrator-state-consolidation` changes both CLAUDE.md and the orchestrator persona and a retrofit step -- a consumer who pulls one without the others is inconsistent).
- **Consumer-facing release record.** A downstream-readable changelog/release note distinct from the internal OpenSpec engineering record -- "what changed, do you need to act, is it breaking, how to verify you're consistent after."
- **Consistency verification.** How a downstream consumer confirms, after a pull, that their setup is in a coherent state (not half-consumed). Candidate: a maintainer-owned check the consumer's orchestrator runs at session-init, building on the `harness-sync-sha` signal.
- **Sequencing across heterogeneous consumers.** Consumers are in different working contexts; the propagation discipline must not assume they adopt in lockstep.

## Acceptance criteria

1. This proposal records resolution 2 and the three-concern charter (done by authoring).
2. The follow-up design round produces `design.md` + `tasks.md` covering: the persona file, the maintainer/reviewer split, and the downstream-propagation mechanism.
3. The repo-owner propagation-policy conversation is held and its outcomes feed the design.
4. Build is sequenced AFTER `orchestrator-state-consolidation` lands (the consolidation is the maintainer's first real consolidation subject; the role need not exist to implement the well-spec'd consolidation, but the consolidation is a worked example the role's design should reference).

## References

- Retrospective: harness self-review, 2026-06-06 session.
- Companion / first subject: `orchestrator-state-consolidation`.
- Rehabilitated under this charter: `harness-update-propagation-signal`, `harness-cross-container-isolation`.
- Parked for the maintainer's first consolidation round: `claude-md-size-discipline`.
- Anchors: `orchestrator.md` Principles ("stay in manager lane", "improve the templates"); `harness-reviewer.md` "Scope clarification"; memory rule "orchestrator captures, does not fix the harness".

## Decision (operator-confirmed 2026-06-06)

Resolution 2: build a dedicated harness-maintainer role, because the charter must include downstream-consumer propagation governance -- a concern that is neither review (harness-reviewer) nor target-pipeline management (orchestrator), and that is already biting real downstream adopters. The harness-reviewer is built out as the maintainer's quality gate rather than absorbing the maintainer's architecting role.
