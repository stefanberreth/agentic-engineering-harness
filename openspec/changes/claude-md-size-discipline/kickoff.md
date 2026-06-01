# Stream B Kickoff -- claude-md-size-discipline + intake triage

**Target:** harness-self (this repository)
**Directory:** /workspace/aeh
**Role:** orchestrator (harness-side)
**Phase:** OpenSpec change proposal authoring + implementation (Stream B)
**Estimated wall-clock:** 60-120 min for the full pass

## Context for the next session

This file kicks off Stream B after a `/clear` in the harness session. Stream A (<solo-dev-target> retrofit) completed earlier in the day -- harness-side commit `69bdb4a`, target-side commits `c2362c3` (base personas) and `7c68b95` (openspec close-out scaffold), all queued for the operator's next push at a phase boundary.

Stream B is harness-self work: slim CLAUDE.md (currently 42.5k chars, past the 40k runtime-warning threshold) by extracting long-form rationale to dedicated reference docs, AND triage the four untriaged intake captures sitting in `openspec/changes/_intake/`.

## The prompt

### Step 0 -- Activate orchestrator role (harness-side, self-contained)

Resolve the persona marker path via `bin/resolve-persona-marker.sh`, then write `orchestrator` to the resolved path. Suppress any session-init banner; this prompt is the session initialiser. Persona load: `templates/personas/orchestrator.md` (harness-side base; this repo is the harness itself, so no `_base/` overlay layer applies).

### Step 1 -- Read state

Read in this order, brief:
- `CLAUDE.md` (the file under scrutiny -- read end-to-end to ground the slim work).
- `targets/index.md` (latest <solo-dev-target> row reflects Stream A delivery).
- This file's sibling at `openspec/changes/_intake/` -- list the four captures and read their summaries (status frontmatter + Trigger + Insight sections):
  - `2026-05-31-1748-reviewer-prompt-commit-step-77c32eea48bc.md`
  - `2026-05-31-1846-orchestrator-modal-states-chain-fabric-77c32eea48bc.md`
  - `2026-05-31-1910-chain-fabric-impl-comparison-with-hex-77c32eea48bc.md`
  - `2026-06-01-1114-target-side-orchestrator-role-defect-c04003d97c24.md` (added during Stream A dispatch -- retrofit prompt templates use `orchestrator (target-side)` role label that muddies the harness-side coordination role)
- `templates/personas/orchestrator.md` (your own role definition; you'll be modifying scope/execution-context wording as part of the role-defect capture's fix if it is promoted).

### Step 2 -- Triage the four intake captures

For each capture, decide one of:
- **Promote** to `openspec/changes/<slug>/` as a standalone change proposal (author proposal.md + tasks.md; mark intake `status: promoted` and `promoted-to: <slug>`; do NOT delete the intake file -- it's the provenance record).
- **Fold into another proposal** if the capture is naturally a sub-aspect (e.g. the role-defect capture may fold into a sibling proposal alongside this one).
- **Defer / keep as intake** with a note in `status:` (`status: deferred`, with `defer-reason:`).

Recommended dispositions to consider (operator confirms each):
- `target-side-orchestrator-role-defect` -- promote alongside this proposal as `harness-role-execution-context-discipline` (covers both the three retrofit template fixes AND the persona-spec clarifications: every role declares its execution context).
- The other three from 2026-05-31 -- read their content first; some may already have OpenSpec proposals authored. Spot-check `openspec/changes/<slug>/` for existing slugs that match.

### Step 3 -- Author the claude-md-size-discipline proposal

In THIS directory (`openspec/changes/claude-md-size-discipline/`), author:

1. **proposal.md** -- frontmatter (status: proposed, area: harness-meta, authored: 2026-06-01) + sections:
   - Problem: CLAUDE.md is 42.5k chars / 434 lines, past the runtime 40k warning threshold. Growth has been organic (capture inbox, propagation signal, cross-container isolation, OpenSpec self-dogfooding bullets added multi-sentence rationale paragraphs reading like CHANGELOG fragments).
   - Goals: keep CLAUDE.md under 30k chars; preserve all rules as one-liner + pointer to a reference doc; do not lose any load-bearing content; the slim version still answers "what rule applies here?" without the operator needing to follow pointers for the rule itself (only for the rationale / mechanism detail).
   - Non-goals: rewriting CLAUDE.md from scratch; removing rules; changing rule semantics; touching role-or-persona definitions (those are separate proposals).
   - Approach: extract long-form rationale paragraphs from Harness Maintenance Discipline bullets to dedicated reference files under a new `docs/harness-rules/` directory (or `docs/harness-discipline/` -- choose at authoring time). Bullets become `- **Topic.** One-sentence rule. Detail: <pointer>.` shape.
   - Risks: pointer rot (mitigated by harness-reviewer Dimension N adding a "pointers resolve" check); reduced single-file scannability (mitigated by keeping the rule one-liner in CLAUDE.md so scan still finds the rule).

2. **tasks.md** -- numbered task list. Likely shape: T1 inventory CLAUDE.md sections by size; T2 identify extraction candidates (>200-char paragraphs in rule bullets); T3 author each reference doc; T4 rewrite CLAUDE.md bullets to one-liner + pointer; T5 confirm size < 30k; T6 harness-reviewer pass; T7 commit.

3. **design.md** (optional) -- only if a non-obvious mechanism decision is needed (e.g. naming convention for reference docs, how the harness-reviewer enforces pointer-resolution).

Do not implement the slim yet -- the proposal is the artefact this session must land. Implementation is a subsequent session (or the tail of this one if operator authorises).

### Step 4 -- Surface decisions / progress to operator

Per the new 4-state response discipline, every response in this session ends with:
- DONE if a clean stopping point is reached.
- DECISION-NEEDED if an authoring choice surfaces that the operator should adjudicate (e.g. "fold target-side-orchestrator-role-defect into claude-md-size-discipline, or stand it up as sibling proposal?").
- PAUSED-ON-YOUR-WORK if an off-screen operator action is needed (rare in Stream B).
- MONITORING-BACKGROUND -- not expected in Stream B (no autonomous chain).

Be terse. Next action is the (almost-)last line of every response. No buried asks.

### Step 5 -- Report

There is no PROMPT REPORT closing sentinel because this is harness-side orchestrator work, not a target-session role-bound prompt (per the orchestrator persona's Report-Back discipline scope rule -- only target-side prompts carry the sentinel). The artefacts ARE the report: proposal.md + tasks.md committed, intake files updated to triaged states, harness commit landed.

## Expected outcome

- Four intake captures triaged. Each carries an updated `status:` field.
- `openspec/changes/claude-md-size-discipline/` carries proposal.md + tasks.md (+ design.md if needed).
- If operator authorises in-session implementation: CLAUDE.md slimmed to < 30k chars, reference docs landed under `docs/harness-rules/` or chosen path, single harness commit + publication-gate pass.
- Otherwise: proposal awaits an implementation session.

## Fallback

If the persona-marker resolver script is missing or fails, this is the wrong harness checkout state -- halt and surface. If `openspec/changes/_intake/` is empty (somehow cleared between Stream A and now), the four-capture triage step is a no-op; proceed with the CLAUDE.md proposal only.
