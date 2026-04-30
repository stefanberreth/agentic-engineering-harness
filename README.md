<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH -- Agentic Engineering Governance Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

A working starting point for running serious software work with AI coding agents. AEH ships a complete, end-to-end agentic SDLC -- engineering roles, change-proposal flow, reviewer gates, autonomous chain execution, restartable state -- that runs out of the box, and is designed to be molded toward the specific practices of your team, department, or company. Pick what you need, amend what doesn't fit, drop what doesn't apply.

## What you get out of the box

AEH installs a default agentic pipeline:

- A multi-role engineering team -- Analyst, Architect, Developer, Reviewer, Archaeologist, plus an Orchestrator coordinating them and an optional Strategist for external strategic conversations. Each role has a base methodology template and a project-specific overlay.
- Specifications managed as OpenSpec change proposals -- analyst writes requirements, architect produces design and tasks, developer implements, reviewer validates against the proposal. Code references its governing spec.
- Reviewer gates with a default cadence -- every five developer tasks plus phase boundaries. The orchestrator tracks the cadence and can refuse to dispatch new development work until the review is current.
- Boundary-iteration discipline -- when a phase-close review finds critical issues, correction cycles run until the reviewer returns PASS. Each iteration typically adds a guardrail, not just a fix, so the same class of issue does not recur.
- Two dispatch modes -- operator-paced (paste a prompt, watch the result) for sensitive or first-of-its-kind work, and chain execution (a shell wrapper invokes prompts in sequence with halt conditions: wall-clock cap, mtime watchdog, sentinel detection, reviewer-verdict gating) for established patterns where you want to step away.
- Restartable state -- every persistent fact lives in committed files (`targets/<slug>/orchestrator-state.md`, `tasks.md`, `journal.md`, `decisions.md`, `open-questions.md`). Kill any session at any time; the next picks up from file state.

This works end-to-end on day one. You can drive a real change through the full pipeline -- proposal, design, implementation, review, archive -- with the templates as shipped.

## How you bend it

AEH is a starting point, not a contract. Every default is amendable:

- **Persona overlays.** Each engineering role has a project overlay (`docs/AE/personas/<role>.md`) where you encode your team's hard boundaries, conventions, and domain knowledge. The base templates expose `Section.PROJECT` extension points specifically for this purpose. Add what your team needs; override what doesn't fit.
- **Reviewer cadence.** The default is every five tasks plus phase boundaries. If your team wants every three, or every commit, or only at phase boundaries, change it in the orchestrator overlay. The cadence rule is enforced from the overlay, not hard-coded.
- **Dispatch mode.** Operator-paced and chain execution are not exclusive. Use operator-paced for the sensitive stages of a change and chain-launch the rest, or run everything through one or the other. Per project, per phase, per change proposal -- whatever fits.
- **Tool selection.** AEH ships with OpenSpec and context7 as the two default SDLC tools. Project-specific tools (databases, deploy targets, CI providers, secret stores, ticketing systems) live in project overlays so they don't pollute the base templates. Add yours; the harness has no opinion.
- **Maturity entry point.** Adopt as much or as little as fits. Five maturity levels are documented below; many projects sit at level 2 or 3 and never need 4 or 5. There is value at each level; you do not have to commit to the full workflow on day one or ever.
- **Skip what you don't need.** Greenfield project? Skip the archaeologist. No compliance audit? Trim the reviewer's regulatory checks. Solo developer with no team? Use operator-paced mode and skip the phase-boundary ceremony. The harness is opinionated about defaults, not dogmatic about adoption.

The intent is that you read what AEH ships, see what fits your context, and tune the rest. The harness improves when you push back on its defaults; the templates are versioned and the overlays are yours.

## How it works

```
IN AEH (orchestrator session)         IN YOUR PROJECT (engineering session)
-----------------------------         --------------------------------------
onboard /path/to/project
  -> read-only assessment
  -> transformation plan
  -> scaffold persona overlays + OpenSpec
  -> generate first prompts
                                       Paste a prompt; it self-activates
                                       its role and reads its governing spec.

                                       Analyst -> Architect -> Developer
                                       -> Reviewer (cadence per overlay).

                                       PASS -> spec deltas merge into
                                       openspec/specs/, change archives.

(periodic) health
  -> delta vs last assessment
  -> fix prompts if drift
                                       Run fix prompts.
```

Two sessions, two scopes. The harness session manages the pipeline -- state, prompts, cadence, chain wrappers. Your project's own session executes the prompts and modifies the code. Most teams keep these separate; the separation gives a clean audit trail and predictable permission boundaries. Some teams collapse them and that works too if the audit trail is not a priority. The default keeps them separate; the choice is yours.

## Quick start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project`. The harness reads your project, runs a 10-category assessment, produces a ranked report (CRITICAL / HIGH / MEDIUM / LOW), generates a transformation plan, and scaffolds the agentic structure. The assessment is read-only; nothing in your project changes without your explicit consent.

## Maturity levels

Pick the level that matches your appetite. You can stop at any level.

| Level | What you get | Effort |
|-------|-------------|--------|
| 1 | Assessment report only | 15 min |
| 2 | Persona overlays + OpenSpec scaffolding | 1 session |
| 3 | Reviewer-implementer loop fixing assessment findings | 1-2 sessions |
| 4 | Archaeologist baseline specs + domain-deepened personas | 1 session |
| 5 | Full workflow -- every change flows through the pipeline | Ongoing |

Many projects sit comfortably at level 2 or 3. Level 4 is where personas go from generic to domain-accurate. Level 5 is where the harness pays for itself on a multi-month build.

## Standard tools

Two tools are baked into the base persona templates as default SDLC infrastructure (analogous to "use git"):

- **[OpenSpec](https://openspec.dev/)** -- specification substrate. Filesystem-based; CLI agents read and write markdown directly. No MCP server.
- **[context7](https://context7.com/)** -- current library documentation lookup. Per-project `.mcp.json`. Agents call it before writing code that uses fast-moving APIs, instead of recalling stale training data.

Project-specific tools (databases, deploy targets, CI providers) belong in project overlays, not base templates.

## Pointers to deeper docs

- `CLAUDE.md` -- harness session instructions
- `templates/personas/` -- base role templates and the `Section.PROJECT` extension points
- `templates/governance/` -- assessment checklist + reviewer quality rubric
- `templates/playbooks/` -- `onboard`, `health`, `tools`
- `targets/index.md` -- registry of projects under AEH governance
- `docs/` -- reference material, talk transcript, deeper specs

## What AEH is not

- Not a framework or library -- no install, no dependencies, no build step
- Not language- or stack-specific -- base templates are project-agnostic; overlays carry the specifics
- Not an implementation tool -- it produces the configuration, documentation, and prompts that drive implementation
- Not Claude-exclusive -- optimised for Claude Code; the persona templates work with any LLM-based coding agent
- Not a SaaS product -- open source, AGPL-3.0, side project

## Inspiration

Inspired by [Emmz Rendle's "How I Tamed Claude" (NDC London 2026)](https://www.youtube.com/watch?v=pey9u_ANXZM).

## Community

- **Discord:** [Join](https://discord.gg/qnKVnJEuQz)
- **GitLab Issues:** [Report bugs / request features](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md) -- prompts preferred over patches

## Supporting AEH

AEH is free, AGPL-3.0, maintained by one person. If it saves you time:

- **[Support on Ko-fi](https://ko-fi.com/stefanberreth)**
- **Star the repo**

For organisations wanting to embed AEH in proprietary tooling or host it as a service without AGPL obligations, a commercial license is available -- contact Stefan Berreth.

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md). Generated outputs (personas, prompts, CLAUDE.md sections) belong to you under any license you choose. AGPL applies only to modifications of AEH itself if you offer them as a public service or distribute them externally.

---

Stefan Berreth -- [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
