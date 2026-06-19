# Design: AEH role architecture

> Records the model settled with the operator across the 2026-06-16 triage conversation.

## The taxonomy, stated for propagation

On archive this propagates verbatim into `CLAUDE.md` (role section) and `openspec/project.md`:

> **AEH-vs-Target role taxonomy.** Every AEH role is either AEH-proper or target-applied, and the role's name says which.
> - **AEH-proper** (no "target" in the name): owns the harness as a published product. Operates only on harness files. E.g. `aeh-engineer`, `harness-reviewer`.
> - **Target-applied** ("target" in the name): owns applying AEH to one specific target. E.g. `target-orchestrator`, `target-aeh-reviewer`, `target-aeh-engineer`.
> - The engineering personas (`analyst`/`archaeologist`/`architect`/`developer`/`reviewer`) are layer-neutral instruments reused by both families.

## The two derived rules

- **R1 (name encodes subject):** taxonomy above.
- **R2 (run where you write):** a role that modifies tree X is a session launched in tree X. Run-location is not a choice; it is determined by what the role writes. Reading may cross trees only through the enforced fence (below). Enforced per-role by the Step 0 location self-check.

These two rules collapse "where does each role run?" from a per-role puzzle into a derivation.

## The detect/remediate matrix

|                          | DETECT (read-only)   | REMEDIATE (read-write) | Runs in   |
|--------------------------|----------------------|------------------------|-----------|
| AEH-proper (harness)     | `harness-reviewer`   | `aeh-engineer`         | AEH root  |
| target's AEH practice    | `target-aeh-reviewer`| `target-aeh-engineer`  | the target|

`target-orchestrator` is the AEH-side coordinator: it dispatches the target-side roles via prompts (as it dispatches developer/analyst today) and routes their report-backs. It does not itself review or remediate the target's AEH practice.

The matrix also absorbs the #2 integrity work: `harness-reviewer` = integrity entry point A (harness self); `target-aeh-reviewer` = integrity entry point B (target practice). #2's only separable remainder is the deterministic check framework B reviewer runs (build change B4).

## The enforced fence

AEH-side roles are fenced out of the target tree, with one narrow allowlisted exception.

| Role | Target-tree access |
|---|---|
| `aeh-engineer` | none |
| `harness-reviewer` | none |
| `target-orchestrator` | read/write `<target>/docs/AE/**` ONLY (deliver prompts; read report-backs) |
| `target-aeh-reviewer` | runs IN the target; reads the whole target (its own session) |
| `target-aeh-engineer` | runs IN the target; writes the target (its own permission model) |

- The exception is a **clearly scoped, enforced allowlist** (`docs/AE/**`), not a soft convention. The orchestrator's permission config must grant target access scoped to `docs/AE/` and nothing wider.
- `target-aeh-reviewer` polices it: an orchestrator permission grant exceeding `docs/AE/`, or evidence of AEH-side writes outside `docs/AE/` (orchestrator-authored commits to the target app tree, stray markers), is a finding. Root-cause in the AEH project's `.claude/settings.json` escalates to `aeh-engineer` (AEH-side fix); target-side debris is cleaned by `target-aeh-engineer`.
- This REPLACES the current CLAUDE.md rule "you CAN read target project files for assessment purposes." That softer rule is retired by build change B6; its one legitimate use (initial reconnaissance) is handled by the bootstrap exception below.

### Onboarding bootstrap exception (default resolution)

Chicken-and-egg: before onboarding, a target has no `docs/AE/` and no AE roles to dispatch into, so the very first reconnaissance cannot go through the channel or a target-side AE role. Default resolution (finalised in B6): initial onboarding reconnaissance is a distinct, **narrow, read-only bootstrap** -- explicitly scoped to first-contact assessment of an un-onboarded target, ending the moment `docs/AE/` exists. Once onboarded, the orchestrator operates through the `docs/AE/` channel only; ongoing assessment is `target-aeh-reviewer`'s job, running in the target. The bootstrap is read-only and one-directional (never writes the target outside `docs/AE/`), so it does not reopen the fence.

## Detect-then-route-by-file-location

Detection crosses trees (by reading); remediation is owned by whoever owns the offending file's tree. Worked: `target-aeh-reviewer` (in the target) finds the orchestrator over-reached. If the cause is the AEH project's permission config -> `aeh-engineer` fixes it in the AEH root. If the residue is target-side -> `target-aeh-engineer` fixes it in the target. Neither engineer touches the other's tree.

## The `orchestrator` -> `target-orchestrator` rename (build change B5)

Large subtraction-completeness operation. The `orchestrator` token spans `CLAUDE.md` (~17), `README.md`, `bin/resolve-persona-marker.sh` + `resolve-target-owner.sh` + `validate-personas.sh`, every base persona, `templates/playbooks/{onboarding,health-check}.md`, `templates/prompts/orchestrator-batch-regime.md`, `templates/governance/*`, and the persona file (`orchestrator.md` -> `target-orchestrator.md`).

- Its own change: acceptance = a clean repo-wide residual scan (`grep -rn '\borchestrator\b'` returns only `target-orchestrator`, labelled history, and out-of-scope archive). Bundling a large rename with new-role authoring is the "don't bundle distinct changes" anti-pattern.
- Marker-value back-compat: an existing `.claude/persona` containing `orchestrator` -- the resolver accepts the legacy value for a deprecation window, or session-init rewrites it.
- Distinguish the role TOKEN `orchestrator` from prose ("orchestration", "the orchestrating session"); the residual scan must not false-positive on those.

## Build sequence (each its own reviewed change)

1. **B1** `aeh-engineer` persona + CLAUDE.md wiring + `openspec/project.md` taxonomy principle + valid-roles.
2. **B2** purify `harness-reviewer` (drop target-tree branches; relocate Propagation-Impact Mode).
3. **B3** `target-aeh-reviewer` (health-check playbook -> loadable role) + `target-aeh-engineer` persona.
4. **B4** deterministic `bin/` AEH-practice check framework (extensible registry) the reviewer runs.
5. **B5** the rename (above).
6. **B6** the enforced `docs/AE/`-only fence (permission allowlist/baseline + retire the soft read rule + bootstrap exception).
7. **B7** role-location Step 0 self-check generalised to all roles (absorbs `orchestrator-self-location-guard`).

Sequencing notes: B1 first (establishes the owner + taxonomy). B5 (rename) and B7 (self-check) touch many of the same files as B1/B2/B3 -- sequence B5 AFTER the persona set stabilises to avoid re-sweeping. `orchestrator-self-location-guard` may ship standalone NOW as B7's concrete first instance; B7 then generalises and absorbs it.

## Alternatives considered

- **Distinct harness-maintainer AND AEH-engineer:** rejected by the operator -- two harness-side engineering roles is the additive ratchet; one role, layered.
- **Full harness-side department:** rejected as over-engineering; engineering personas are reused, not duplicated.
- **No taxonomy, just document the split:** insufficient for the adoptability bar; name-encodes-family is what makes it legible to outsiders.
- **Soft "harness may read target" boundary (current):** rejected -- the operator wants the fence enforced (uncorruptable), with the `docs/AE/` exception as the only allowlisted channel.
- **Rename bundled into this proposal's build:** rejected on subtraction-completeness grounds (B5 is its own change).
- **One combined target-AEH role (detect+remediate):** rejected -- it would have to both run-in-target-and-read-AEH-config; splitting detect (reads, routes) from remediate (writes, fenced to one tree) is what dissolves the contradiction.
