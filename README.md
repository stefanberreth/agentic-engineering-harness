<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH -- Agentic Engineering Governance Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

A working starting point for running serious software work with AI coding agents. AEH brings the shape of a real engineering team to the work AI agents do: separated roles, spec-driven changes, regular review, and predictable handoffs. It runs out of the box and is designed to be molded toward the practices of your team, department, or company. Pick what you need, amend what does not fit, drop what does not apply.

## Why a governance harness

AI coding agents produce code at a rate human review does not naturally keep up with. Without structure, that work is hard to audit, hard to course-correct, and hard to hand off between people or sessions. AEH addresses that by giving the work an engineering shape -- the same separation of concerns that makes human teams effective. An analyst clarifies requirements, an architect chooses a design, a developer implements, a reviewer gates the result. Each role has its own focus and its own constraints, and the work moves through them in a way that leaves a clean trail behind it.

The outcome is that AI work becomes governable. You can stop it, resume it, audit it, hand it off, and trust that the parts you have not personally watched were nonetheless reviewed.

## What you get out of the box

A complete agentic SDLC, ready to drive a real change from idea to merged code on day one:

- A multi-role engineering team -- Analyst, Architect, Developer, Reviewer, Archaeologist, plus an Orchestrator that coordinates them and an optional Strategist for external strategic conversations.
- Specifications managed as change proposals, with code traceable to the spec it implements.
- Reviewer gates at a regular cadence, with the orchestrator tracking that the cadence is held.
- Correction-cycle discipline -- when a review finds something critical, the work iterates until the review passes.
- Two ways to run -- closely supervised one step at a time, or batched into longer autonomous runs you can step away from.
- Persistent state in committed files, so any session can stop and resume cleanly. Switch machines, change models, take a break, and pick up where you left off.

The templates as shipped are a known-good default. They work without further tuning. Deeper docs explain each piece.

## How you bend it

AEH is a starting point, not a contract. Every default is amendable:

- **Role definitions.** Each role has a generic methodology template plus a project-specific overlay where you encode your team's conventions, hard boundaries, and domain knowledge. Add what your team needs; override what does not fit.
- **Review cadence.** The default cadence is sensible for most projects; if your team wants more or fewer review touchpoints, change it in the orchestrator overlay.
- **Run mode.** Supervised and autonomous runs are not exclusive. Use one for sensitive stages of a change and the other for established patterns -- per project, per phase, per change, whatever fits.
- **Tool choice.** AEH ships with two default development tools (one for specifications, one for current library documentation). Project-specific tools (databases, deploy targets, CI providers, secret stores, ticketing) live in project overlays so they do not pollute the base templates.
- **Maturity entry point.** Adopt as much or as little as fits your appetite. Five maturity levels are documented below; many projects sit at level two or three and never need four or five.
- **Skip what you do not need.** Greenfield project? Skip the archaeologist. No compliance audit? Trim the reviewer's regulatory checks. Solo developer? Skip the phase-boundary ceremony. The harness is opinionated about defaults, not dogmatic about adoption.

The intent is that you read what AEH ships, see what fits your context, and tune the rest. The harness improves when you push back on its defaults; the templates are versioned and the overlays are yours.

## How it works

```
HARNESS SESSION                        PROJECT SESSION
(manages the pipeline)                 (does the engineering work)

assess and plan
generate prompts
                                        execute prompts as the role
                                        they activate

                                        analyst -> architect ->
                                        developer -> reviewer
                                        (cadence per overlay)

                                        on PASS, archive and continue
```

Two sessions, two scopes. The harness session manages the pipeline; your project's own session executes the work. Most teams keep these separate, because the separation gives a clean audit trail and predictable permission boundaries. Some teams collapse them, and that works too if the audit trail is not a priority. The default keeps them separate; the choice is yours.

## Quick start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project`. The harness reads your project, runs an assessment, produces a ranked report (CRITICAL / HIGH / MEDIUM / LOW), generates a transformation plan, and scaffolds the agentic structure. The assessment is read-only; nothing in your project changes without your explicit consent.

## Maturity levels

Pick the level that matches your appetite. You can stop at any level.

| Level | What you get | Effort |
|-------|-------------|--------|
| 1 | Assessment report only | 15 min |
| 2 | Persona overlays + spec scaffolding | 1 session |
| 3 | Reviewer-implementer loop fixing assessment findings | 1-2 sessions |
| 4 | Baseline specs from existing code + domain-deepened personas | 1 session |
| 5 | Full workflow -- every change flows through the pipeline | Ongoing |

Many projects sit comfortably at level two or three. Level four is where personas go from generic to domain-accurate. Level five is where the harness pays for itself on a multi-month build.

## Standard tools

Two tools are baked into the base persona templates as default development infrastructure:

- **[OpenSpec](https://openspec.dev/)** -- specification substrate.
- **[context7](https://context7.com/)** -- current library documentation lookup, so agents check current API shape instead of recalling stale training data.

Project-specific tools (databases, deploy targets, CI providers) belong in project overlays, not base templates.

## Pointers to deeper docs

- `CLAUDE.md` -- harness session instructions
- `templates/personas/` -- base role templates
- `templates/governance/` -- assessment checklist + reviewer quality rubric
- `templates/playbooks/` -- onboarding, health, tool configuration
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
