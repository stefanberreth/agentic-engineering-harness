# Rebuild kickoff -- aeh-engineer-role (B1-B7)

Marching orders for the post-`/clear` build session. The architecture is ACCEPTED (see `proposal.md` + `design.md`); this is the build. Read `proposal.md` and `design.md` first.

## Operating regime (applies to the whole rebuild)

- **Commit freely, do NOT push.** Per CLAUDE.md "Publication-readiness gate before push": nothing goes to the public remote until the WHOLE reworked setup is coherent, complete, documentation-current, stale-reference-free, and passes a comprehensive integrity/consistency/dedup sweep (full harness-reviewer pass). The rebuild accumulates as local commits until then.
- **Publication gate before every commit** (`bin/validate-personas.sh --staged` + `--message`).
- **Subtraction-completeness discipline** is load-bearing here (B1 + B5 remove/rename a lot): sweep every producer + consumer; leave nothing stranded; residual scan must be clean.
- The capture inbox is now PRIVATE at `targets/_harness-private/intake/` (not public). Folded-item detail lives in the private `targets/_harness-private/intake/TRIAGE-2026-06-17.md`.

## Build sequence

Each B-step is its own reviewed change (don't bundle). Suggested order: B1 first (establishes the role + taxonomy + the big subtraction); B2/B3/B4 next; B5 (rename) AFTER the persona set stabilises (it re-sweeps many files); B6 + B7 fold in their items. `orchestrator-self-location-guard` (already a separate proposal) is B7's concrete first instance -- B7 generalises and absorbs it.

### B1 -- aeh-engineer persona + taxonomy + the extract-and-aggregate subtraction  [START HERE]
- Create `templates/personas/aeh-engineer.md` aggregating the full scope (proposal.md section 2a): intake triage, improvement-architecting, consolidation/anti-bloat, the public-repo commit/push permission, behaviour-vs-lore divergence detection, harness-side propagation governance, OpenSpec close-out lifecycle, bin/ tooling + hook maintenance.
- Wire CLAUDE.md: role-list, session-init, Commands, valid-roles set; add the AEH-vs-Target taxonomy statement; `openspec/project.md` taxonomy principle.
- **The subtraction:** cut harness-maintenance OUT of `orchestrator.md` (leave only the universal capture right); re-own the "Owner: orchestrator" CLAUDE.md rules to `aeh-engineer`. Full producer/consumer residual sweep.
- Folded backlog items (private detail in TRIAGE manifest): maintainer continuous coherence-audit duty; harness-side downstream propagation/release governance; promotion-sanitization (name-free spec substrate) discipline; orchestrator-state freshness + drift detector.

### B2 -- purify harness-reviewer
- Remove its target-tree branches (relocate to target-aeh-reviewer / health-check flow). Folded: base-templates-must-not-cite-harness-only-paths cross-layer hygiene.

### B3 -- target-aeh-reviewer + target-aeh-engineer personas
- target-aeh-reviewer evolves from the health-check playbook (detect, runs in target, read-only). target-aeh-engineer remediates target-side AEH (runs in target, read-write). Folded: per-target operational-skill + two-tier currency gate.

### B4 -- deterministic bin/ AEH-practice integrity-check framework
- Extensible registry the target-aeh-reviewer runs. Folded: structural-invariant-gate pattern (the backbone); prompt->result one-to-one pairing invariant (a check).

### B5 -- rename orchestrator -> target-orchestrator
- Own change; acceptance = clean repo-wide residual scan (`grep -rn '\borchestrator\b'` returns only `target-orchestrator` + labelled history). Marker-value back-compat note. Folded: freestyle-prompt label correctness.

### B6 -- enforced docs/AE/-only fence
- AEH-side roles fenced from the target except the orchestrator's allowlisted `docs/AE/**`; retire the soft "harness may read target" rule; onboarding bootstrap exception. Folded: no-target-code-spelunking, no-tree-rummaging.

### B7 -- role-location Step-0 self-check (all roles)
- Generalise from the orchestrator-only guard; absorb `orchestrator-self-location-guard`. Folded: role-location-self-check capture.

## Done = ready-to-publish

The rebuild is "done" only when B1-B7 land coherently AND the whole-setup integrity/consistency/dedup sweep passes (docs, onboarding verbiage, READMEs, CLAUDE.md, no stale refs). THEN the publication-readiness gate clears and the accumulated commits can be pushed (operator-authorised).
