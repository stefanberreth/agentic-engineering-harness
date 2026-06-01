---
captured-at: 2026-05-31T18:00:00Z
captured-from: 0c37120ebcd6
captured-during: harness session, operator-direction surfaced while re-engaging an existing target with the new propagation flow
area: governance
status: promoted
promoted-to: harness-portability-assessment
promoted-at: 2026-06-01T11:30:00Z
---

# AEH coding-agent-harness portability: systematic assessment + nudge toward agent-agnostic conventions

**Trigger:** Operator-direction surfaced during a target re-engagement arc that exposed how target-tree files split between Claude-Code-specific conventions and broader cross-CLI conventions (a `.claude/CLAUDE.md` for Claude Code alongside a repo-root `AGENTS.md` as a broader workflow contract). AEH today is de-facto Claude-Code-centric across templates, persona files, playbooks, governance, scripts, and operator-facing docs. The market for coding-agent CLI environments is broader (Gemini CLI, OpenAI Codex CLI, Mistral's offerings, Aider, Continue, etc.) and likely to grow. A meaningful share of conventions AEH locks to Claude Code (`CLAUDE.md` filename, `.claude/` directory, in-session persona-marker mechanics, slash-commands, etc.) are not inherently Claude-specific -- they exist because Claude Code was the bootstrapping environment. Adoption beyond Claude Code is currently friction-heavy or impossible without forking, even though the core methodology (OpenSpec discipline, layered personas, capture inbox, propagation signal, close-out convention, harness-reviewer governance) is agent-agnostic in substance.

**Insight:** The right first step is a **systematic portability assessment**, not a sweeping rename pass. Before changing any filename or directory convention, the harness needs to understand per surface:

- **Mechanism vs convention.** Is this file/directory/marker load-bearing for Claude Code specifically, or is the location an arbitrary choice that any agent could be told to follow? Example: `.claude/persona.<HOSTNAME>` is Claude-Code-specific (Claude Code reads `.claude/CLAUDE.md` at session init); `docs/AE/personas/_base/<role>.md` is agent-agnostic (just markdown files in the project tree).
- **Convention is shifting industry-wide.** `AGENTS.md` is emerging as a cross-CLI convention (OpenAI Codex CLI reads it; others are following). A real-world example surfaced in this session: a target carries both a repo-root `AGENTS.md` (broader workflow contract; cross-CLI-friendly) AND a `.claude/CLAUDE.md` (Claude-Code-specific session-init instructions). The two coexist because they serve different audiences. AEH templates currently encode only the Claude-Code-specific half.
- **Renaming-without-mechanism-understanding is the failure mode.** Renaming `CLAUDE.md` to `AGENTS.md` without understanding what Claude Code reads at session-init would break Claude Code users while not necessarily helping other-agent users (each CLI has its own discovery mechanism).

The assessment should produce: a per-surface table classifying each Claude-specific reference as (a) load-bearing for Claude Code, (b) agent-agnostic-but-named-claude, (c) genuinely portable already; and a phased migration plan (if any) that doesn't break existing Claude Code users while widening the funnel for other-agent users.

The harness-reviewer is the natural home for the assessment dimension; the templates/personas/, templates/playbooks/, templates/tools/, and CLAUDE.md surfaces are where Claude-specific assumptions live and where the per-surface classification needs to happen.

This is NOT a priority for the next quarter; the operator's standing focus is harness substrate maturity and target-project work. The capture is a deliberate plant -- when the next harness major release window opens, or when first cross-CLI adoption signal arrives, this is the work to pick up.

**Suggested change (assessment scope, not migration scope):**

- Author `openspec/changes/<future-slug>-agent-harness-portability-assessment/` (when prioritised): a structured assessment proposal that produces the per-surface classification table. Deliverable is the table + recommended phased migration (separate proposals for each phase).
- Extend `templates/personas/harness-reviewer.md` with a new dimension (e.g. Dimension 11: Agent-Harness Portability) covering the per-surface classification check. The dimension is read-only at first (just surfaces Claude-specific references); becomes a forward-discipline check once a portability convention lands ("base templates should not introduce new Claude-only assumptions without explicit rationale").
- Consider authoring a `templates/portability/` directory once concrete patterns emerge from the assessment (e.g. an AGENTS.md template that complements per-agent CLAUDE.md-equivalents, agent-agnostic persona-marker mechanisms, cross-agent session-init conventions).
- Reference standards / candidates worth surveying as input to the assessment: the AGENTS.md emerging convention (OpenAI / Anthropic / others), Aider's `.aider.conf.yml` patterns, Continue's `.continuerc` patterns, any cross-CLI tooling like `mise`/`asdf` for agent-version pinning.

**Memory updates:** none specifically; portability is a forward concern that lives in the assessment proposal when prioritised. After the assessment ships, operator memory about "which agent-harness am I targeting on this project" may want a one-line addition; not now.

**Out of scope (explicit):**
- Renaming `CLAUDE.md` to `AGENTS.md` in this capture or its eventual proposal. Mechanism understanding must precede convention change.
- Building cross-agent compatibility shims, polyfills, or runtime detection. Out of scope for AEH's substrate-focused mission.
- Multi-agent orchestration (running multiple different CLI agents on the same project simultaneously). Different problem.
