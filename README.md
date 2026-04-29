<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH — Agentic Engineering Governance Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

A governance layer between you and AI coding agents. The harness imposes structure on agent work: separated engineering roles, spec-traceable change proposals, mandatory reviewer gates, and halt-condition-bounded autonomous chains. Code lands only via reviewed change proposals. Reviewers are mechanical gates, not advisory. Boundary reviews iterate until the verdict is PASS.

## Who it's for

You're running serious software work with Claude Code (or similar AI agents) and you've noticed that "let the agent do it" produces unreviewable volume, drifts off-spec, and bypasses any quality bar. AEH is the layer that puts agent work back inside an auditable SDLC: separated engineering roles, OpenSpec change proposals as the unit of work, structural reviewer gates, and execution regimes that range from one-prompt-at-a-time oversight to multi-hour autonomous chains with halt guardrails.

You operate the harness. The harness routes work to agents, tracks state across sessions, and gates progression. Your project's code is modified only by your project's own session — the harness produces the prompts and reads results, never editing target code directly.

## What "governance" means here

Not orchestration alone. Specific disciplines the harness imposes:

- **Multi-role pipeline.** Five engineering roles (Analyst, Architect, Developer, Reviewer, Archaeologist) plus an Orchestrator that routes work between them. Each role has a base methodology template plus a project-specific overlay. Roles cannot bypass each other — the architect cannot write code; the developer cannot author specs; the reviewer is the only PASS authority.
- **No code without a governing spec.** Every change flows through OpenSpec: analyst writes a proposal, architect produces design + tasks, developer implements against `tasks.md`, reviewer validates against the proposal. The reviewer's §0 spec-traceability check is BLOCKING — code without a governing change slug fails review structurally, not by judgement.
- **Mandatory reviewer cadence.** Every 5 developer tasks gets a reviewer pass; phase boundaries get full reviewer scrutiny. Cadence is non-discretionary — the orchestrator's pre-generation gate refuses to dispatch a 6th developer prompt if the 5th has not been reviewed.
- **Boundary-iteration until clean.** When a phase-close reviewer finds CRITICAL issues, correction cycles spawn until the reviewer returns PASS. A recent downstream project's investor-entity-model change took 4 boundary-review iterations to close 4 CRITICAL findings — each iteration added a system-level guardrail (test surface, reviewer Domain Check entry, convention amendment) rather than just patching the symptom.
- **Evolve-the-system principle.** Every fix pairs the targeted symptom-close with a guardrail. The next change proposal doesn't have the boundary reviewer playing whack-a-mole on the same class of issue.
- **Two dispatch modes.** Operator-paced (one prompt at a time, copy-paste handoff, operator inspects each result) for sensitive or first-of-its-kind work. Chain execution (a shell wrapper invokes N prompts back-to-back) for established patterns — wall-clock cap, mtime watchdog, halt-on-`CHAIN_HALT`-sentinel, halt-on-reviewer-non-PASS, halt-on-zero-commits, halt-on-scope-violation. Operator disengages for hours; returns to a morning-readable summary.
- **Restartable state.** Every persistent fact lives in committed files (`targets/<slug>/orchestrator-state.md`, `tasks.md`, `journal.md`, `decisions.md`, `open-questions.md`). Kill any session at any time; the next picks up from file state.
- **Role discipline.** Harness-level engineering (chain wrappers, prompt files, persona overlays) stays with the orchestrator. Project-domain engineering routes to the appropriate engineering role. The orchestrator does not deflect its own work back to the operator; the operator stays in operational awareness without being required to micromanage.

## How it works (basic shape)

```
IN AEH (orchestrator session)         IN YOUR PROJECT (engineering session)
─────────────────────────────         ──────────────────────────────────────
onboard /path/to/project
  → read-only assessment
  → transformation plan
  → scaffold persona overlays + OpenSpec
  → generate first prompts
                                       Paste a prompt; it self-activates
                                       its role and reads its governing spec.

                                       Analyst → Architect → Developer
                                          → Reviewer (every 5 tasks /
                                                       phase boundary).

                                       Reviewer §0 BLOCKING: no governing
                                       spec → automatic FAIL.

                                       PASS → spec deltas merge into
                                       openspec/specs/, change archives.

(periodic) health
  → delta vs last assessment
  → fix prompts if drift
                                       Run fix prompts.
```

The harness produces plans, prompts, and state-tracking artifacts. Every step is human-approved; the operator decides when and whether to run anything. Chain execution mode trades step-by-step approval for halt-condition-bounded autonomy when the operator wants to step away.

## Quick start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project`. The harness reads your project, runs a 10-category assessment, produces a ranked report (CRITICAL / HIGH / MEDIUM / LOW), generates a transformation plan, and scaffolds the agentic structure. No code in your project is modified during onboarding — the harness only reads and reports.

## Maturity levels

Start where you are; deepen as the value compounds:

| Level | What you get | Effort |
|-------|-------------|--------|
| 1 | Assessment report | 15 min |
| 2 | Persona overlays + OpenSpec scaffolding | 1 session |
| 3 | Reviewer-implementer loop fixing assessment findings | 1-2 sessions |
| 4 | Archaeologist baseline specs + domain-deepened personas | 1 session |
| 5 | Full workflow — every change flows through the chain | Ongoing |

Most projects get significant value at level 2. Level 4 is where personas go from generic to domain-accurate. Level 5 is where the harness pays for itself — every feature flows through a reviewable, restartable, spec-driven pipeline with no manual process overhead.

## Standard tools

Two tools are baked into the base persona templates as standard SDLC infrastructure (analogous to "use git"):

- **[OpenSpec](https://openspec.dev/)** — specification substrate. Filesystem-based; CLI agents read and write markdown directly. No MCP server.
- **[context7](https://context7.com/)** — current library documentation lookup. Per-project `.mcp.json`. Agents call it before writing code that uses fast-moving APIs (React 19, Tailwind v4, Playwright, etc.) instead of recalling stale training data.

Project-specific tools (databases, deploy targets, CI providers) belong in project overlays — never in base templates.

## Pointers to deeper docs

- `CLAUDE.md` — the harness's own session instructions (every AEH session reads this first)
- `templates/personas/` — the eight role definitions (5 engineering + Orchestrator + Harness Reviewer + optional Strategist)
- `templates/governance/` — assessment checklist + reviewer quality rubric
- `templates/playbooks/` — `onboard`, `health`, `tools`
- `targets/index.md` — registry of projects under AEH governance
- `docs/` — reference material, the originating talk transcript, deeper specs

## What AEH is not

- Not a framework or library — no install, no dependencies, no build step
- Not language- or stack-specific — base templates are project-agnostic; overlays carry the project specifics
- Not an implementation tool — it produces the configuration, documentation, and prompts that drive implementation; implementation happens in your project's own session
- Not Claude-exclusive — optimised for Claude Code, but the persona templates and governance criteria work with any LLM-based coding agent
- Not a SaaS product — open source, AGPL-3.0, side project

## Inspiration

Inspired by [Emmz Rendle's "How I Tamed Claude" (NDC London 2026)](https://www.youtube.com/watch?v=pey9u_ANXZM).

## Community

- **Discord:** [Join](https://discord.gg/qnKVnJEuQz)
- **GitLab Issues:** [Report bugs / request features](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) — prompts preferred over patches

## Supporting AEH

AEH is free, AGPL-3.0, maintained by one person. If it saves you time:

- **[Support on Ko-fi](https://ko-fi.com/stefanberreth)**
- **Star the repo**

For organisations wanting to embed AEH in proprietary tooling or host it as a service without AGPL obligations, a commercial license is available — contact Stefan Berreth.

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md). Generated outputs (personas, prompts, CLAUDE.md sections) belong to you under any license you choose. AGPL applies only to modifications of AEH itself if you offer them as a public service or distribute them externally.

---

Stefan Berreth — [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
