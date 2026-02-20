# AEH -- Agentic Engineering Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

A meta-engineering toolkit for transforming software projects into structured agentic engineering setups -- where AI coding agents (Claude Code primarily) work within a reviewable, restartable, persona-driven workflow.

## The Problem

AI coding agents are powerful but undisciplined by default. Without structure, they produce unreviewable volumes of code, lose context between sessions, make silent assumptions, and resist being managed. Most people either "vibe code" (no process, no review) or bolt an AI into their existing workflow without rethinking how work is organised.

## The Solution

AEH codifies a **persona-driven workflow** inspired by [Emmz Rendle's "How I Tamed Claude" talk at NDC London 2026](https://www.youtube.com/watch?v=pey9u_ANXZM). The core insight: an AI coding agent given a focused role with clear boundaries (what it IS, what it is NOT, when to stop) produces dramatically better output than one agent asked to do everything. Separating concerns into Analyst, Architect, Developer, and Reviewer -- the same separation that makes human teams effective -- makes AI teams effective too.

AEH provides:

- **Persona templates** -- instruction files ("system prompts") for each role, encoding mature software engineering principles (TDD, small commits, retrospectives, spec-driven development). These are loaded into the AI agent at the start of a session and shape its behaviour. The four engineering personas run inside Claude Code; the optional Strategist runs in any LLM chat for higher-altitude decision-making.
- **Project templates** -- scaffolds for `CLAUDE.md` (Claude Code's project instruction file -- the single most important file for agentic engineering) and `agents.md` (cross-tool agent configuration), adapted per target project
- **Governance criteria** -- checklists and rubrics to assess and improve agentic configuration quality, including agent permission audits
- **Guided playbooks** -- step-by-step workflows for onboarding new projects, running health checks, and configuring development tools
- **Tool integration** -- optional setup/teardown for MCP servers (Model Context Protocol -- a standard for giving AI agents access to external tools and data sources): OpenSpec (specs), Context7 (docs), and Serena (code navigation)
- **Agent permission governance** -- AI coding agents accumulate permissions transactionally ("yes, don't ask again") with no systematic review. AEH audits these configurations: detecting secrets leaked into permission rules, flagging missing safety boundaries, consolidating sprawled allow lists, and enforcing filesystem scope
- **Transformation process** -- a repeatable method for taking an existing project from zero agentic setup to a fully structured one

## Who Is This For

- **Solo practitioners** using Claude Code (or similar) who want structure without bureaucracy
- **Small teams** introducing AI coding agents and needing a shared workflow
- **Technical leads** evaluating how to integrate AI agents into existing processes
- **Anyone** who has experienced the "100 files changed, no idea what happened" problem with AI coding

## What This Is NOT

- It is **not a framework or library**. There is no code to install or import.
- It is **not specific to any language or stack**. The templates are adapted per target project.
- It **does not implement software**. It produces the configuration, documentation, and process artifacts that *drive* implementation.
- It is **not Claude-exclusive**. While optimised for Claude Code, the persona templates and governance criteria work with any LLM-based coding agent.

## Quick Start

```bash
git clone https://gitlab.com/stefanberreth/agentic-engineering-harness.git
cd agentic-engineering-harness
claude
```

Then say `/onboard /path/to/your/project` to start the guided assessment.

AEH will:
1. Read your project's structure, README, and any existing AI agent configuration
2. Run an assessment checklist across 10 categories
3. Produce a ranked inconsistency report (CRITICAL / HIGH / MEDIUM / LOW)
4. Generate a phased transformation plan
5. Create ready-to-execute prompts for setting up the agentic structure in your project
6. Generate a regression check prompt to verify nothing was broken

No code in your project is modified during onboarding. The harness only reads and reports.

## How It Works

### The Two-Project Model

AEH operates on a strict separation: the harness never directly modifies your project's code. Why? Because an AI agent that reads your project's own `CLAUDE.md`, follows your project's conventions, and operates within your project's permission model will make better, safer changes than one operating from an external context. The harness produces the plan; your project's own agent executes it.

1. **Harness-side** (this project) -- reads target projects, analyses them, produces plans, generates adapted templates and prompts. Never modifies target project files directly (with one narrow, optional exception for prompt delivery).
2. **Target-side** (your project) -- a separate Claude Code session receives prompts and executes changes within your project's own context and conventions.

### The Personas

| Persona | Where it runs | What it does |
|---------|---------------|--------------|
| **Analyst** | Claude Code (harness or target) | Gathers requirements, produces specs |
| **Architect** | Claude Code (harness or target) | Designs solutions, defines boundaries |
| **Developer** | Claude Code (target) | TDD implementation, follows conventions |
| **Reviewer** | Claude Code (target) | Compliance checking, produces issue lists |
| **Strategist** | Any LLM chat (optional) | Business strategy, priorities, trade-offs |

The four engineering personas are the core workflow. The Strategist is an optional upstream role for users who want a strategic conversation partner (e.g. in Claude Web) to inform engineering priorities. See `templates/personas/strategist.md` for details.

### The Workflow

```
/onboard your project
    |
    v
Assessment (read-only, produces reports)
    |
    v
Plan (phased, prioritised transformation tasks)
    |
    v
Harness setup (personas, session init, CLAUDE.md sections)
    |
    v
/tools (optional: configure OpenSpec, Context7, Serena)
    |
    v
Reviewer-Implementer loop (Reviewer scans → produces issue list →
  Implementer fixes top issues → Reviewer re-scans → repeat until clean)
    |
    v
Regression check (verify builds, imports, runtime still work)
    |
    v
/health checks (periodic -- detect configuration drift, permission
  sprawl, persona staleness, tool breakage)
```

Each step is human-approved. The harness generates prompts; you decide when and whether to execute them.

**What is "drift"?** Over time, an AI agent's configuration gradually falls out of sync with the project's actual state. New dependencies get added but personas don't mention them. Permission rules accumulate. Documentation references point to files that moved. Drift is silent and cumulative -- the agent still runs, it just gets progressively less effective. Regular health checks catch it.

### Transforming a Project Step by Step

1. Start Claude Code in the AEH directory
2. Say `/onboard /path/to/your/project`
3. The playbook runs 7 phases (you can skip ahead or stop at any point)
4. At the end, you get assessment reports and ready-to-execute prompts
5. Open Claude Code in your project and run the prompts:
   ```
   Read and execute docs/AE/prompts/000-run-all-foundation.md
   ```
6. For code-level fixes, run the reviewer-implementer loop with human oversight
7. Run `/health` periodically to check for drift

### Managing Target Workspace History

When you onboard projects, AEH creates workspaces under `targets/` containing assessments, plans, prompts, and journals. These are valuable artifacts -- but they're also private to you and have no place in a shared or public harness repo.

The recommended setup is a **nested private repo** inside `targets/`. The harness repo (public) ignores target workspace contents via `.gitignore`; the targets repo (private) tracks them independently with its own commit history. Two repos, one working directory, zero risk of leaking private project data into the public harness.

Ask Claude to explain the setup, help you create it, or verify an existing one. Say `set up targets repo` or ask about it -- Claude knows how to configure and maintain it.

## Project Structure

```
.
├── CLAUDE.md                              # Claude's instructions for this project
├── README.md                              # This file
├── CHANGELOG.md                           # Version history (Keep a Changelog format)
├── LICENSE                                # AGPL-3.0
├── LICENSE-FAQ.md                         # License clarifications (output ownership, SaaS, etc.)
├── CONTRIBUTING.md                        # How to contribute (prompt-first, BDFL model)
├── templates/
│   ├── personas/
│   │   ├── analyst.md                     # Requirements gathering persona
│   │   ├── architect.md                   # Solution design persona
│   │   ├── developer.md                   # TDD implementation persona
│   │   ├── reviewer.md                    # Code review persona
│   │   └── strategist.md                  # Strategic advisor (optional, external sessions)
│   ├── prompts/
│   │   └── regression-check.md.template   # Post-transformation regression check
│   ├── project/
│   │   ├── CLAUDE.md.template             # Scaffold for target project CLAUDE.md
│   │   └── agents.md.template             # Cross-tool agent config scaffold
│   ├── governance/
│   │   ├── assessment-checklist.md        # Evaluate agentic readiness
│   │   └── review-criteria.md             # Quality rubric for config files
│   ├── playbooks/
│   │   ├── onboarding.md                  # Guided 7-phase onboarding workflow
│   │   ├── health-check.md               # Recurring compliance check + delta report
│   │   └── tools.md                       # Optional development tool configuration
│   ├── tools/
│   │   ├── openspec-setup.md / teardown   # OpenSpec MCP server setup/removal
│   │   ├── context7-setup.md / teardown   # Context7 MCP server setup/removal
│   │   └── serena-setup.md / teardown     # Serena MCP server setup/removal
│   └── agents/
│       ├── README.md                      # Agent-specific knowledge overview
│       └── claude-code/                   # Claude Code permission schema, patterns, baselines
├── targets/                               # Private nested repo (see "Managing Target Workspace History")
│   └── index.md                           # Registry of target projects + status
└── docs/
    ├── how-i-tamed-claude-ndc-london-2026.md  # Structured reference from source talk
    └── ...
```

When you onboard a project, AEH creates a workspace under `targets/<your-project>/` with assessment, plan, tasks, decisions, prompts, deliverables, and a session journal.

## Core Principles

1. **Structure over speed.** A well-structured agentic setup is slower to start but dramatically more productive and reliable over time.
2. **Restartability.** AI agent sessions are ephemeral -- they lose all context when they end. AEH ensures every piece of state that matters (current task, decisions made, what was tried) lives in committed files, not conversation history. Kill a session at any point, start a fresh one, and it picks up where the last one left off by reading the project files.
3. **Small increments.** One task, one commit, one reviewable change. No 100k-line surprises.
4. **Human in the loop.** The AI proposes; the human decides. Every code-touching change requires explicit approval (or explicit pre-approval for experienced users).
5. **Assessment before implementation.** Onboarding reads and reports. It never modifies your code. Implementation is a separate, conscious step.
6. **Preserve what works.** When your project already has good instructions or conventions, AEH builds on them. Templates fill gaps -- they don't replace what's working.
7. **Governance is continuous.** Agentic configuration degrades over time as the project evolves and permissions accumulate. Regular `/health` checks detect the drift before it causes problems.

## Maturity Model

AEH doesn't require you to adopt everything at once. Start where you are:

| Level | What you get | Effort |
|-------|-------------|--------|
| **1. Assessment only** | Run `/onboard`, get a ranked report of your project's agentic readiness. No changes made. | 15 minutes |
| **2. Harness setup** | Add AE structure (personas, session init, CLAUDE.md sections). Your code untouched. | 1 session |
| **3. Reviewer-implementer loop** | Fix issues found in the assessment with human oversight. | 2-3 sessions |
| **4. Full workflow** | All personas active, regular `/health` checks, continuous governance. | Ongoing |
| **5. Strategic layer** | Add a Strategist in an external LLM chat for business-level decision support. | When needed |

Most projects get significant value at level 2. You don't need to reach level 5 to benefit.

## Community

- **Discord:** [Join the AEH Discord](#) -- chat, help, show-and-tell, feature ideas
- **GitLab Issues:** [Report bugs and request features](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues)
- **Contributing:** See [CONTRIBUTING.md](CONTRIBUTING.md) -- we prefer prompts over patches

## Supporting AEH

AEH is free and open source. If it saves you time, consider supporting continued development:

- **[Sponsor on GitHub](#)** -- recurring or one-time
- **[Polar.sh](#)** -- fund specific features you want built
- **Star the repo** -- visibility helps more than you'd think

For organisations wanting commercial licensing (embed AEH in proprietary tooling without AGPL obligations), contact Stefan Berreth.

## Requirements

- [Claude Code](https://claude.ai/code) (CLI tool from Anthropic)
- A software project you want to structure for agentic development
- That's it. No dependencies, no installation, no build step.

## Current Status

AEH is in active development. It has been used to transform two real projects end-to-end: a Python/PyTorch ML compression toolkit and a React/Express/Supabase fintech platform. The templates and governance criteria are refined through real-world usage.

What's working:
- Onboarding playbook (7-phase guided assessment)
- Four engineering persona templates + optional Strategist
- Assessment checklist (10 categories) and review criteria (6 rubrics)
- Agent permission governance (schema reference, detection patterns, baselines)
- Prompt generation and direct delivery
- Post-transformation regression checks (build, imports, runtime verification)
- Health check playbook (delta reports + tool health + permission health)
- Tool integration playbook (OpenSpec, Context7, Serena -- optional, reversible)

What's evolving:
- Templates are being refined based on real-world usage
- Multi-agent coordination patterns are not yet documented
- CI/CD integration templates are planned but not yet created

## Key Resources

| Resource | Description |
|----------|-------------|
| [How I Tamed Claude (NDC London 2026)](https://www.youtube.com/watch?v=pey9u_ANXZM) | The talk that inspired this project |
| [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) | Official Claude Code documentation |
| [OpenSpec](https://openspec.dev/) | Specification-driven development tool |
| [Context7](https://context7.com/) | Documentation MCP server |

## Mission Evolution

### v0.1 -- Foundation (Feb 2026)

- Transcribed and structured the source talk as reference material
- Created initial persona templates (Analyst, Architect, Developer, Reviewer)
- Created project templates (`CLAUDE.md`, `agents.md`) and governance criteria
- Established the transformation workflow: assess, plan, adapt, validate

### v0.2 -- Target Project Isolation & Multi-Project Tracking (Feb 2026)

- Established the Two-Project Model with strict isolation boundary
- Created `targets/` workspace structure for per-project transformation state
- Defined the prompt file format and five transformation phases
- Open questions: stack adaptability, checklist granularity, MCP recommendations

### v0.3 -- Guided Playbooks, Boundary Enforcement & Session Init (Feb 2026)

- Created onboarding playbook (7-phase guided workflow with skip gates)
- Created health-check playbook (recurring compliance checks with delta reports)
- Established assessment-implementation boundary (onboarding never touches code)
- Added session init, role selection, and merge-and-confirm rule
- First real-world transformation completed (compression-poc-02)

### v0.4 -- Strategist Persona (Feb 2026)

- Added optional Strategist persona for upstream business/strategic decision support
- Designed for use in external LLM sessions (Claude Web, etc.) without filesystem access
- Adapted per-project into context briefings that can be pasted into any chat
- Kept deliberately lightweight -- discoverable but not required

### v0.5 -- Tool Integration, Open Source, Regression Checks (Feb 2026)

- Added optional tool integration system for OpenSpec, Context7, and Serena MCP servers
- `/tools` playbook for setup, teardown, and repair -- runnable independently or during onboarding
- Detection patterns for tools and functional equivalents (ADR directories, other MCP servers, etc.)
- Tool health checking integrated into `/health` playbook
- Every setup has a matching teardown -- fully reversible, per-project, never prescribed
- Post-transformation regression checks verify builds, imports, and runtime after structural changes
- AGPL-3.0 license with FAQ clarifying output ownership
- Prompt-first contribution model -- submit the LLM prompt, not just the diff
- Community: Discord + GitLab Issues + sponsor support
- Second real-world transformation completed (React/Express/Supabase fintech platform, 36/36 governance pass)

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md).

**TL;DR:** Use AEH freely on any project (including proprietary). The output belongs to you. If you modify AEH itself and distribute it or host it as a service, the AGPL applies to your modifications.

## Contact

Stefan Berreth -- [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
