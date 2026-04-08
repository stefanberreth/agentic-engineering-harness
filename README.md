<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH -- Agentic Engineering Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

A meta-engineering toolkit for transforming software projects into structured agentic engineering setups. AI coding agents (Claude Code primarily) work within a reviewable, restartable, persona-driven workflow instead of generating unreviewable volumes of code with no process.

## The Core Insight

An AI coding agent given a focused role with clear boundaries produces dramatically better output than one agent asked to do everything. Separating concerns into distinct engineering personas -- the same separation that makes human teams effective -- makes AI teams effective too. Inspired by [Emmz Rendle's "How I Tamed Claude" talk at NDC London 2026](https://www.youtube.com/watch?v=pey9u_ANXZM).

## The Five Engineering Personas

AEH defines five engineering roles. These are not abstract concepts -- they are instruction files ("system prompts") loaded into a Claude Code session to shape the agent's behaviour for a specific type of work. You start a Claude Code session in your project, load a persona, and the agent operates within that role's boundaries until you switch.

Each persona has a base template (generic methodology, ships with AEH) and a project overlay (project-specific configuration, lives in your project). More on this in [Layered Persona Architecture](#layered-persona-architecture) below.

| Persona | What it does |
|---------|-------------|
| **Archaeologist** | Investigates existing codebases, produces verified baseline specs. Runs upstream before the main loop. |
| **Analyst** | Gathers requirements, produces specs. Consumes baseline specs as context. |
| **Architect** | Designs solutions, defines task breakdowns. Works within verified constraints. |
| **Developer** | TDD implementation, follows conventions. Logs discoveries for other roles. |
| **Reviewer** | Quality gate: 15 review dimensions including absence checks, dependency health, security audit, spec traceability, performance anti-patterns. Evidence-based verdicts (no rubber-stamping). |

The standard workflow is Archaeologist (once, for existing codebases) then Analyst → Architect → Developer → Reviewer in a loop. You run one role at a time in a Claude Code session pointed at your project. Between sessions, state lives in committed files -- kill a session at any point, start fresh, and the next agent picks up where the last left off.

Three additional roles run in the AEH harness itself (a separate Claude Code session in the AEH directory) to manage the process:

| Role | What it does |
|------|-------------|
| **Orchestrator** | Manages the prompt execution pipeline, enforces reviewer cadence (every 5 tasks or phase boundary -- non-discretionary), tracks state across sessions, generates handover prompts with two-file persona loading |
| **Strategist** | Business strategy and priorities -- runs in any LLM chat (optional, external to Claude Code) |
| **Harness Reviewer** | Self-review of AEH's own quality, documentation currency, and target detail leakage |

## Layered Persona Architecture

Personas are split into two files:

- **Base template** (`templates/personas/<role>.md`) -- generic methodology with numbered sections and `§.PROJECT` extension points. These ship with AEH and evolve with the project.
- **Project overlay** (`docs/AE/personas/<role>.md` in the target project) -- project-specific configuration: hard boundaries, domain checks, conventions, credential patterns. Populated during onboarding.

The agent loads the base first, then the overlay. The overlay takes precedence where sections overlap. This means methodology improvements in AEH base templates flow to all projects without rewriting overlays, and project-specific knowledge stays in the project.

Run `bin/validate-personas.sh` to verify structural integrity of base templates. Run `bin/validate-personas.sh /path/to/project` to also validate that project's overlays.

## OpenSpec and Baseline Specs

[OpenSpec](https://openspec.dev/) manages specifications as structured markdown files alongside your code (`openspec/specs/` for specifications, `openspec/changes/` for change proposals with designs and task breakdowns). No MCP server, no dependencies -- just a directory convention that CLI agents read and write directly. Each persona knows where to read and write: Analyst creates specs, Architect fills in designs and tasks, Developer reads tasks and applies spec updates, Reviewer checks that specs match what was built.

The Archaeologist produces **baseline specs** (`status: baseline` in frontmatter) that document what the codebase currently does -- not what it should do. These are the verified ground truth that all downstream roles consume. Baseline specs include `[verified]` and `[unverified]` tags on factual claims so downstream roles know what they can build on safely.

## Quick Start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `onboard /path/to/your/project` to start the guided assessment.

AEH will:
1. Read your project's structure, README, and any existing AI agent configuration
2. Run a 10-category assessment checklist
3. Produce a ranked inconsistency report (CRITICAL / HIGH / MEDIUM / LOW)
4. Generate a transformation plan
5. Scaffold persona overlay files with the layered base+overlay convention
6. Create ready-to-execute prompts for setting up the agentic structure in your project
7. Offer OpenSpec setup for structured spec management

No code in your project is modified during onboarding. The harness only reads and reports.

## How It Works

AEH operates on a strict separation: the harness never directly modifies your project's code. The harness produces plans and prompts; your project's own Claude Code session executes them within your project's context, conventions, and permission model.

```
IN AEH                              IN YOUR PROJECT
------                               ---------------
onboard /path/to/project
  -> assessment (read-only)
  -> plan
  -> generates prompts
                                     Run the prompts:
                                       "Read and execute
                                        docs/AE/prompts/001-..."
                                       (one at a time, you review each)

                                     Reviewer-Implementer loop:
                                       reviewer scans -> issue list ->
                                       implementer fixes -> repeat

health (periodic)
  -> delta report
  -> fix prompts if needed
                                     Run fix prompts
```

Each step is human-approved. The harness generates prompts; you decide when and whether to execute them.

## What AEH Is NOT

- **Not a framework or library.** No code to install, no dependencies, no build step.
- **Not specific to any language or stack.** Templates are adapted per target project.
- **Does not implement software.** It produces configuration, documentation, and process artifacts that *drive* implementation.
- **Not Claude-exclusive.** Optimised for Claude Code, but the persona templates and governance criteria work with any LLM-based coding agent.
- **Not a SaaS product.** It's an open-source side project that works well enough to share.

## Project Structure

```
.
├── CLAUDE.md                              # Claude's instructions for this project
├── README.md                              # This file
├── CHANGELOG.md                           # Version history
├── LICENSE                                # AGPL-3.0
├── LICENSE-FAQ.md                         # License clarifications
├── CONTRIBUTING.md                        # How to contribute
├── bin/
│   └── validate-personas.sh              # Structural validation for base templates + overlays
├── templates/
│   ├── personas/
│   │   ├── archaeologist.md              # Codebase investigation (base template)
│   │   ├── analyst.md                    # Requirements gathering (base template)
│   │   ├── architect.md                  # Solution design (base template)
│   │   ├── developer.md                  # TDD implementation (base template)
│   │   ├── reviewer.md                   # Code review (base template)
│   │   ├── orchestrator.md               # Pipeline management
│   │   ├── harness-reviewer.md           # Harness self-review
│   │   └── strategist.md                 # Strategic advisor (optional, external)
│   ├── project/
│   │   ├── CLAUDE.md.template            # Scaffold for target project CLAUDE.md
│   │   └── agents.md.template            # Cross-tool agent config scaffold
│   ├── governance/
│   │   ├── assessment-checklist.md       # 10-category agentic readiness evaluation
│   │   └── review-criteria.md            # Quality rubric for config files
│   ├── playbooks/
│   │   ├── onboarding.md                 # 7-phase guided onboarding workflow
│   │   ├── health-check.md              # Recurring compliance check + delta report
│   │   └── tools.md                      # Optional development tool configuration
│   ├── tools/
│   │   ├── README.md                     # Tool integration overview
│   │   ├── tool-detection-patterns.md    # Detection patterns for tools + equivalents
│   │   ├── openspec-setup.md             # OpenSpec setup prompt template
│   │   ├── openspec-teardown.md          # OpenSpec teardown prompt template
│   │   ├── context7-setup.md             # Context7 setup prompt template
│   │   ├── context7-teardown.md          # Context7 teardown prompt template
│   │   ├── serena-setup.md               # Serena setup prompt template
│   │   ├── serena-teardown.md            # Serena teardown prompt template
│   │   └── sandbox-env-provisioning.md   # Env var provisioning for Docker/sandbox
│   ├── prompts/
│   │   └── regression-check.md.template  # Post-transformation regression check
│   ├── scripts/
│   │   └── loop-driver.sh.template       # Autonomous dev->gates->reviewer loop
│   └── agents/
│       ├── README.md                     # Agent-specific knowledge overview
│       └── claude-code/
│           ├── permissions.md            # Permission schema reference + anti-patterns
│           ├── permission-detection-patterns.md
│           └── permission-baselines.md   # Recommended configs by project archetype
├── targets/                              # Private nested repo (your project workspaces)
│   └── index.md                          # Registry of target projects + status
└── docs/
    ├── how-i-tamed-claude-ndc-london-2026.md
    └── Images/                           # Project logos
```

## What AEH Provides

- **Persona templates** -- base templates for five engineering roles and three harness roles, with `§.PROJECT` extension points for project-specific adaptation
- **Project templates** -- scaffolds for `CLAUDE.md` and `agents.md`, adapted per target project with two-file persona loading
- **Governance criteria** -- assessment checklists (10 categories) and quality rubrics (6 rubrics) for evaluating agentic configuration
- **Guided playbooks** -- `onboard` (7-phase assessment + transformation), `health` (recurring compliance check), `tools` (optional MCP server configuration)
- **Agent permission governance** -- schema reference, detection patterns, recommended baselines. Catches secrets in permission rules, missing deny lists, filesystem scope violations
- **Validation tooling** -- `bin/validate-personas.sh` checks base template structure, extension points, and project-specific content leakage
- **Tool integration** -- optional setup/teardown for OpenSpec, Context7 (docs), and Serena (code navigation) MCP servers

## Maturity Model

Start where you are:

| Level | What you get | Effort |
|-------|-------------|--------|
| **1. Assessment only** | Run `onboard`, get a ranked report. No changes made. | 15 minutes |
| **2. Harness setup** | Persona overlays, session init, CLAUDE.md sections. Code untouched. | 1 session |
| **3. Reviewer-implementer loop** | Fix assessment issues with human oversight. | 1-2 sessions |
| **4. Domain deepening** | Archaeologist baseline specs, verified domain knowledge in personas. | 1 session |
| **5. Full workflow** | All personas active, health checks, continuous governance. | Ongoing |

Most projects get significant value at level 2. Domain deepening (level 4) is where personas go from generic to accurate.

## Core Principles

1. **Structure over speed.** A well-structured agentic setup is slower to start but dramatically more productive over time.
2. **Restartability.** Kill a session at any point, start fresh, and it picks up where the last one left off by reading committed files.
3. **Small increments.** One task, one commit, one reviewable change.
4. **Human in the loop.** The AI proposes; the human decides.
5. **Assessment before implementation.** Onboarding reads and reports. It never modifies your code.
6. **Preserve what works.** Templates fill gaps -- they don't replace working instructions.

## Requirements

- [Claude Code](https://claude.ai/code) (CLI tool from Anthropic)
- A software project you want to structure for agentic development
- That's it. No dependencies, no installation, no build step.

## Community

- **Discord:** [Join the AEH Discord](https://discord.gg/qnKVnJEuQz)
- **GitLab Issues:** [Report bugs and request features](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues)
- **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md) -- we prefer prompts over patches

## Supporting AEH

AEH is free, open source, and maintained by one person. If it saves you time:

- **[Support on Ko-fi](https://ko-fi.com/stefanberreth)**
- **Star the repo**
- **[Join the Discord](https://discord.gg/qnKVnJEuQz)**

For organisations wanting to embed AEH in proprietary tooling or host it as a service without AGPL obligations, a commercial license is available -- contact Stefan Berreth.

## Key Resources

| Resource | Description |
|----------|-------------|
| [How I Tamed Claude (NDC London 2026)](https://www.youtube.com/watch?v=pey9u_ANXZM) | The talk that inspired this project |
| [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) | Official Claude Code documentation |
| [OpenSpec](https://openspec.dev/) | Specification-driven development tool |

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md).

**TL;DR:** Use AEH freely -- personal projects, teams, entire organisations. All generated output (personas, prompts, CLAUDE.md sections) belongs to you under any license you choose. The AGPL only applies if you modify AEH itself and offer it as a public service or distribute it externally.

## Contact

Stefan Berreth -- [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
