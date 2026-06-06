---
captured-at: 2026-06-06T12:56:30Z
captured-from: a8733b7927f2
captured-during: implementing the state-consolidation proposal; root-causing why the proposal under-scoped revealed a recurring class of divergence that no current role owns
area: governance / roles (feeds harness-maintainer-role-charter)
status: untriaged
---

# Note for harness-maintainer-role-charter: the "declaration vs machinery" divergence this session is concrete motivation for the role

**Origin.** The state-consolidation proposal under-scoped for a specific, repeatable reason worth recording against the parked `harness-maintainer-role-charter` proposal as motivating evidence.

**The divergence.** The proposal described the state model in terms of the two files that DECLARE it (the orchestrator persona's allowlist + CLAUDE.md's workspace tree) and forgot the files that USE it: onboarding scaffolds the state files, health-check reads them, the tools playbook records into them. So the declared canonical set and the de-facto behaviour had drifted -- onboarding was minting eleven files while the persona "declared" a smaller set -- and nobody owned noticing that. The implementation pass discovered it only because the bookend happened to grep broadly.

**Why this is the charter's territory.** The charter's stated concern is exactly "who owns de-facto behaviour vs file-lore divergence and harness re-engineering." This session is a clean instance: a declaration changed, the machinery did not, and the gap sat undetected until a review stumbled on it. No current role's standing duties include "when a convention's declaration changes, audit its producers and consumers for drift." The orchestrator routes; the harness-reviewer reviews specific changes; neither continuously owns declaration/machinery coherence across the whole harness.

**The actionable, role-independent half is being injected now** as a subtraction-completeness discipline in architect/reviewer/harness-reviewer (see the sibling capture). What remains for the charter is the CONTINUOUS-OWNERSHIP half: a role whose job includes periodically auditing that declarations (canonical sets, allowlists, structure trees) still match what the playbooks/personas actually do. The per-change discipline catches subtractions made deliberately; the role catches drift that accumulates when no single change is responsible.

**Recommendation for the charter round.** When the maintainer role is designed, give it an explicit "declaration/machinery coherence audit" duty: pick a declared convention (a canonical file set, a rule allowlist, a documented tree) and verify every producer and consumer still agrees. This session is the worked example to design against.
