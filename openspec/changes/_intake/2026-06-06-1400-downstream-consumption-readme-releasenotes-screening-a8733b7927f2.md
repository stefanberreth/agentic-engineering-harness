---
captured-at: 2026-06-06T14:00:03Z
captured-from: a8733b7927f2
captured-during: after a multi-change harness session (state consolidation + subtraction-completeness + retrospective convention + reviewer quality), the operator noted that none of these changes had been examined for how downstream consumers receive them, and parked a requirement to be picked up later while returning to active target work
area: governance / publication / downstream consumption (relates to harness-maintainer-role-charter + harness-update-propagation-signal)
status: untriaged
---

# Requirement (PARKED -- do not execute yet): downstream-consumption practice -- README currency, a release-notes log per push, and a consumption-screening step before publishing

**Status: parked by operator.** This is a captured requirement, not a directive to act now. The operator is returning to active target work; this is picked up in a dedicated later session. Recorded here so it is not lost.

**Why this surfaced.** A session landed several substantive harness changes (orchestrator state consolidation + full consumer sweep, subtraction-completeness discipline, base-template layer hygiene, retrospective-elicitation convention, reviewer over-engineering + adversarial stance). All were committed LOCAL ONLY, deliberately unpushed. The operator observed that the harness has been improving its INTERNAL quality but has not examined how those changes are CONSUMED downstream: what a consumer sees when they pull, and how they apply the updates to their own target setups without things tearing apart. Publication has been treated as "commit + maybe push" with no consumer-facing layer.

**The requirement has three parts.**

1. **README currency before push.** The public `README.md` is the consumer's front door. Before any push that changes harness behaviour, the README must be reviewed and updated so it still describes what the harness actually is and does. Today README updates are ad hoc. Make "README reviewed/updated" a gate on a behaviour-changing push. (The operator specifically wants to REVIEW the updated README before it goes out.)

2. **A release-notes log, updated every push.** Distinct from the CHANGELOG (which is a complete internal change ledger). Release notes are CONSUMER-FACING: for each published release/push, a short "what you are getting and what it means for you" -- the headline changes, anything that affects how a consumer works with the harness downstream, and any action a consumer must take to adopt the update. The goal is consumer VISIBILITY: when someone pulls, they should immediately understand what changed and how to work with it. Establish the log file, its location, its format, and the practice of updating it on every push.

3. **A consumption-screening step before publishing.** Before pushing, screen the batched changes through the lens of "how will a downstream consumer receive and apply this?" -- which changes require a consumer-side action (re-run a retrofit prompt, refresh base personas, migrate state files, bump a marker), which are transparent, and which could "tear apart" an existing target setup if applied naively. The output is the consumer-facing release-notes entry plus any required retrofit guidance. This is the missing screen between "internally committed" and "safely published."

**Strong relationship to two existing/parked pieces -- triage should reconcile, not duplicate:**
- `harness-maintainer-role-charter` (parked): the unbuilt role is explicitly about how changes reach consumers without tearing apart their setups. The push -> consumer-adoption flow is that role's territory; the consumption-screening step is plausibly one of its standing duties. Decide whether this requirement is implemented standalone or folded into the maintainer role's charter.
- `harness-update-propagation-signal` (active): already provides the target-side mechanism for detecting that the harness advanced (`harness-sync-sha` + the harness-reviewer Propagation-Impact Assessment Mode that produces a per-change retrofit-action list). The release-notes + consumption-screening practice is the PUBLISHER-SIDE complement to that CONSUMER-SIDE detector: the publisher writes the human-readable "what changed + how to adopt" that the propagation-impact pass then operationalises per target. Reconcile so they are two ends of one pipe, not two parallel inventions.

**Scope note for triage.** Likely a lightweight governance/playbook + a release-notes file convention + a pre-push checklist, NOT a heavy mechanism. Honour the anti-over-engineering bias: the simplest thing that gives consumers real visibility and a safe adoption path. Possibly a "publish" playbook (sibling of `onboard` / `health` / `tools`) that runs README-currency + release-notes-entry + consumption-screening + the push, gated.

**Concrete trigger for picking this up:** the five local commits from the 2026-06-06 session are unpushed precisely so this consumer-facing layer can be designed first. When this is picked up, those commits are the first batch to screen and write release notes for.
