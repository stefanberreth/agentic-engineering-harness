---
slug: harness-portability-assessment
priority: deferred
---

# Tasks

## Task 1: Per-surface inventory
- Enumerate Claude-Code-specific references across surfaces: `templates/personas/`, `templates/playbooks/`, `templates/tools/`, `templates/project/`, `templates/governance/`, `templates/agents/`, `templates/prompts/`, `bin/`, `CLAUDE.md`, `README.md`, `openspec/`, `docs/`.
- Capture each as: file:line + reference token + current usage shape.
- **Signal:** inventory table committed (file path TBD at authoring; suggestion: `docs/portability-assessment.md` or `design.md` in this proposal dir).

## Task 2: Per-surface classification
- For each inventory row, classify as (a) load-bearing-for-Claude / (b) agent-agnostic-named-claude / (c) genuinely-portable.
- Provide reasoning per (a) and (b) entries (one-line per).
- **Signal:** every inventory row has a classification.

## Task 3: Survey reference standards
- AGENTS.md emerging convention (OpenAI Codex CLI's read pattern; any documented contract).
- Aider's `.aider.conf.yml`.
- Continue's `.continuerc`.
- Cross-CLI tooling (mise/asdf for agent-version pinning).
- One-line summary per standard; relevance to AEH per surface.
- **Signal:** survey section landed.

## Task 4: Phased migration plan (high-level)
- Group classifications by phase: phase 1 = trivial renames (genuinely-portable + clear rename target); phase 2 = AGENTS.md-pattern adoption (agent-agnostic-named-claude); phase 3 = mechanism-bridging (load-bearing requires per-agent bridge).
- Each phase summarised; concrete work deferred to per-phase proposals.
- **Signal:** plan section present with phase definitions.

## Task 5: Harness-reviewer Dimension N: Agent-Harness Portability
- Edit `templates/personas/harness-reviewer.md` to add the new dimension.
- Read-only initially: surfaces Claude-specific references; flags candidates per classification.
- Becomes forward-discipline once a portability convention lands ("base templates should not introduce new Claude-only assumptions without rationale").
- **Signal:** dimension entry committed.

## Task 6: CHANGELOG + intake status + archive (when prioritised)
- CHANGELOG entry under [Unreleased] Added.
- Intake capture frontmatter updated: status promoted (this is done at promotion time, not at completion).
- Archive proposal post-bookend (when work lands; proposal stays `priority: deferred` meanwhile).
