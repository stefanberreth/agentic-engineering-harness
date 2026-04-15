<p align="center">
  <img src="docs/Images/AEH-Round.png" alt="AEH" width="120">
</p>

# AEH -- Agentic Engineering Harness

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2)](https://discord.gg/qnKVnJEuQz)
[![Support on Ko-fi](https://img.shields.io/badge/Ko--fi-Support-FF5E5B)](https://ko-fi.com/stefanberreth)

A meta-engineering toolkit for running structured, spec-driven software development with AI coding agents. Instead of letting an agent generate unreviewable volumes of code with no process, AEH gives each agent a focused engineering role, enforces specification traceability on every change, and gates all work through evidence-based review.

## The Problem AEH Solves

AI coding agents are powerful but undisciplined. Without structure, they produce code that:
- Has no specification traceability (nobody can verify what was supposed to be built vs what was built)
- Bypasses review (the agent generates and commits in one shot with no quality gate)
- Uses stale library APIs (the agent recalls training data instead of checking current documentation)
- Loses coherence across sessions (context dies when the session ends)
- Drifts from the plan (the agent improvises instead of following the architect's design)

AEH fixes this by separating concerns into engineering personas, routing all work through versioned specifications (OpenSpec), enforcing review at structural level (the reviewer cannot be bypassed), and persisting all state in committed files so any session can pick up where the last left off.

## The Core Insight

An AI coding agent given a focused role with clear boundaries produces dramatically better output than one agent asked to do everything. Separating concerns into distinct engineering personas -- the same separation that makes human teams effective -- makes AI teams effective too. Inspired by [Emmz Rendle's "How I Tamed Claude" talk at NDC London 2026](https://www.youtube.com/watch?v=pey9u_ANXZM).

## How It Works

AEH operates on a strict separation: the harness never directly modifies your project's code. The harness produces plans, specifications, and prompts; your project's own Claude Code session executes them within your project's context, conventions, and permission model.

```
IN AEH (orchestrator session)          IN YOUR PROJECT (engineering session)
─────────────────────────────           ──────────────────────────────────────
onboard /path/to/project
  → assessment (read-only)
  → transformation plan
  → scaffold persona overlays
  → generate prompts
                                        Paste prompts one at a time:
                                          "Read and execute
                                           docs/AE/prompts/001-..."

                                        Each prompt self-activates its role,
                                        loads base + overlay persona,
                                        reads the governing OpenSpec proposal,
                                        implements against tasks.md,
                                        commits with spec references.

                                        Reviewer pass every 5 tasks:
                                          §0 BLOCKING spec traceability check
                                          15+ review dimensions
                                          evidence-based verdict (no rubber stamps)
                                          corrections before next phase

health (periodic)
  → delta report vs last assessment
  → fix prompts if drift detected
                                        Run fix prompts
```

Each step is human-approved. The harness generates prompts; you decide when and whether to execute them. Between sessions, all state lives in committed files -- kill a session at any point, start fresh, and the next agent picks up where the last left off.

## The Engineering Personas

AEH defines five engineering roles that run in your project's Claude Code session. These are not abstract concepts -- they are instruction files loaded into a session to shape the agent's behaviour for a specific type of work.

Each persona has a **base template** (generic methodology, ships with AEH) and a **project overlay** (project-specific configuration, lives in your project). The agent loads both; the overlay extends the base with domain knowledge, hard boundaries, and project conventions.

| Persona | What it does | Key discipline enforced |
|---------|-------------|------------------------|
| **Archaeologist** | Investigates existing codebases, produces verified baseline specs in `openspec/specs/baseline-*.md`. Runs upstream before the main loop. | Documents what EXISTS, not what should exist. Tags claims `[verified]` / `[unverified]`. |
| **Analyst** | Gathers requirements, produces change proposals at `openspec/changes/<slug>/proposal.md`. QA finding capture mode for high-throughput intake. | Primary output is ALWAYS an OpenSpec artefact. No routing recommendations (that's the orchestrator's job). |
| **Architect** | Designs solutions, writes `design.md` + `tasks.md` inside the change proposal directory. Verifies library APIs via context7 before writing examples. | Design lives in the change proposal, not a separate location. Tasks.md is the developer's authoritative source. |
| **Developer** | TDD implementation. BLOCKING Step 0: identify governing spec before writing any code. Reads tasks from `openspec/changes/<slug>/tasks.md` directly. | No code without a governing spec. Spec reference comments in test files. Change slug in commit messages. context7 lookup before using fast-moving library APIs. |
| **Reviewer** | Quality gate with 15+ review dimensions. §0 SPEC TRACEABILITY is BLOCKING -- runs first, gates everything. No governing spec = automatic FAIL. Evidence required for every verdict. | Code without spec traceability does not pass review, period. Library API currency spot-checks via context7. |

The standard workflow: Archaeologist (once, for existing codebases) then Analyst → Architect → Developer → Reviewer in a loop. The reviewer's BLOCKING §0 check is the structural enforcement -- it catches any attempt to bypass the specification workflow, intentional or accidental.

### Three Harness Roles

These run in the AEH harness session (a separate Claude Code instance in the AEH directory), not in your project:

| Role | What it does |
|------|-------------|
| **Orchestrator** | Manages the prompt execution pipeline. Enforces reviewer cadence (every 5 tasks or phase boundary -- non-discretionary). Pre-generation self-check refuses to create developer prompts without a governing spec. Tracks state across sessions. Two execution regimes: prompt-by-prompt (close oversight) and batch (self-chaining with phase-boundary review). |
| **Strategist** | Business strategy and priorities -- runs in any LLM chat (optional, external to Claude Code) |
| **Harness Reviewer** | Self-review of AEH's own quality across 10 dimensions: target detail leakage, prompt protocol, documentation currency, template consistency, isolation boundary, governance completeness, public-facing quality, OpenSpec discipline integrity, quality gate chain integrity, SDLC tool compliance |

## OpenSpec -- The Specification Substrate

[OpenSpec](https://openspec.dev/) is the organising unit for ALL engineering work in AEH-governed projects. It manages specifications as structured markdown files alongside your code. No MCP server, no dependencies -- just a directory convention that CLI agents read and write directly.

```
openspec/
├── project.md                    # Project conventions (slug naming, status vocabulary)
├── specs/
│   ├── baseline-*.md             # Archaeologist output: verified ground truth
│   └── <domain-id>.md           # Stable specs (archived from completed changes)
└── changes/
    ├── <active-slug>/            # In-flight change proposals
    │   ├── proposal.md           # Analyst: requirements + acceptance criteria
    │   ├── design.md             # Architect: solution design + decisions
    │   ├── tasks.md              # Architect: ordered task breakdown (developer reads this)
    │   └── specs/<id>.md         # Spec deltas (merged into specs/ on completion)
    └── archive/<YYYY-MM>/<slug>/ # Completed proposals (historical record)
```

Every feature flows through this structure:

1. **Analyst** creates `openspec/changes/<slug>/proposal.md` with requirements and acceptance criteria
2. **Architect** fills in `design.md` (solution) and `tasks.md` (developer's work order)
3. **Developer** reads `tasks.md` directly (the orchestrator does not paraphrase), implements, marks tasks complete, adds spec reference comments to tests and source
4. **Reviewer** validates the implementation against the proposal via the BLOCKING §0 spec traceability check
5. **On reviewer PASS**: spec deltas merge into `openspec/specs/`, the change archives to `openspec/changes/archive/`

The reviewer's §0 check enforces this end-to-end. Code that bypasses OpenSpec -- intentionally or by drift -- does not pass review.

## Two Standard SDLC Tools

AEH prescribes two tools as standard infrastructure for every project (analogous to "use git"):

| Tool | Purpose | How it's used |
|------|---------|---------------|
| **[OpenSpec](https://openspec.dev/)** | Specification management | Filesystem-based. CLI agents read/write markdown files directly. No MCP server needed. Every persona knows where to read and write. |
| **[context7](https://context7.com/)** | Current library documentation lookup | MCP server configured per-project in `.mcp.json`. Agents call it before writing code that uses fast-moving library APIs (React 19, TanStack Query, Tailwind v4, Playwright, Supabase CLI, etc.). Prevents training-data recall for libraries that changed after the agent's training cutoff. |

Both are named in the base persona templates. They are development methodology tools, not project-technology-specific choices. Project-technology-specific tools (GitLab, Supabase, Snyk, specific CI providers, databases, deployment platforms) belong in project overlays, never in base templates.

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
6. Set up OpenSpec (`openspec/specs/`, `openspec/changes/`, `openspec/project.md`, `AGENTS.md`)
7. Create ready-to-execute prompts for setting up the agentic structure in your project

No code in your project is modified during onboarding. The harness only reads and reports.

## The Quality Chain

AEH's quality enforcement is structural, not advisory. Each link in the chain is enforced by a different persona:

```
Analyst produces → OpenSpec change proposal (proposal.md)
                   ↓
Architect fills  → design.md + tasks.md in the same proposal
                   ↓
Developer reads  → tasks.md directly (not a paraphrase)
  ├─ BLOCKING Step 0: no code without governing spec
  ├─ context7 lookup before fast-moving library APIs
  ├─ spec reference comments in tests: // Validates: openspec/...
  ├─ change slug in commits: feat(scope): desc [change:<slug>]
  └─ TDD: test first, implement, refactor, commit
                   ↓
Reviewer gates   → §0 SPEC TRACEABILITY (BLOCKING, runs first)
  ├─ Governing spec exists? (FAIL if not)
  ├─ Implementation matches spec? (FAIL on unjustified deviation)
  ├─ Test-to-spec linkage? (FAIL if no spec references in tests)
  ├─ Spec currency? (FAIL if spec is stale after code changes)
  ├─ Commit traceability? (WARN if no change slug)
  └─ 15+ additional dimensions: absence check, security,
     cross-module impact, library API currency, dependency health,
     performance anti-patterns, structural hygiene, permissions...
                   ↓
On PASS          → deltas merge into openspec/specs/, change archives
                   ↓
Orchestrator     → enforces reviewer cadence (every 5 tasks / phase boundary)
                   pre-generation self-check (no prompt without governing spec)
                   tracks active change proposals in state file
```

The chain is unbroken: the orchestrator can't generate a developer prompt without a governing spec, the developer can't start without finding that spec, the reviewer rejects work without spec traceability. Drift is caught structurally, not by vigilance.

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
│   │   ├── reviewer.md                   # Code review + §0 BLOCKING spec traceability (base template)
│   │   ├── orchestrator.md               # Pipeline management + reviewer cadence enforcement
│   │   ├── harness-reviewer.md           # Harness self-review (10 dimensions)
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
│   │   └── tools.md                      # Development tool configuration (OpenSpec, context7, Serena)
│   ├── tools/
│   │   ├── README.md                     # Tool integration overview
│   │   ├── tool-detection-patterns.md    # Detection patterns for tools + equivalents
│   │   ├── openspec-setup.md             # OpenSpec setup prompt template
│   │   ├── openspec-teardown.md          # OpenSpec teardown prompt template
│   │   ├── context7-setup.md             # context7 setup prompt template
│   │   ├── context7-teardown.md          # context7 teardown prompt template
│   │   ├── serena-setup.md               # Serena setup prompt template
│   │   ├── serena-teardown.md            # Serena teardown prompt template
│   │   └── sandbox-env-provisioning.md   # Env var provisioning for Docker/sandbox
│   ├── prompts/
│   │   ├── regression-check.md.template  # Post-transformation regression check
│   │   └── orchestrator-batch-regime.md  # Regime 2 switchover prompt template
│   ├── scripts/
│   │   └── loop-driver.sh.template       # Autonomous dev→gates→reviewer loop
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

- **Persona templates** -- base templates for five engineering roles and three harness roles, with `§.PROJECT` extension points for project-specific adaptation. Each engineering persona integrates OpenSpec as the specification substrate and context7 as the documentation lookup tool.
- **Project templates** -- scaffolds for `CLAUDE.md` and `agents.md`, adapted per target project with two-file persona loading and Step 0 self-activation
- **Governance criteria** -- assessment checklists (10 categories) and quality rubrics for evaluating agentic configuration
- **Guided playbooks** -- `onboard` (7-phase assessment + transformation), `health` (recurring compliance check), `tools` (OpenSpec + context7 + optional Serena configuration)
- **Agent permission governance** -- schema reference, detection patterns, recommended baselines. Catches secrets in permission rules, missing deny lists, filesystem scope violations
- **Validation tooling** -- `bin/validate-personas.sh` checks base template structure, extension points, and project-specific content leakage
- **Reviewer enforcement** -- §0 BLOCKING spec traceability check, mandatory reviewer cadence, evidence-based verdicts, domain-critical adversarial review extension points
- **Execution regimes** -- prompt-by-prompt (Regime 1, close oversight) and batch execution with phase-boundary review (Regime 2, higher velocity). Both enforce reviewer gates.

## Maturity Model

Start where you are:

| Level | What you get | Effort |
|-------|-------------|--------|
| **1. Assessment only** | Run `onboard`, get a ranked report. No changes made. | 15 minutes |
| **2. Harness setup** | Persona overlays, session init, CLAUDE.md sections, OpenSpec scaffolding. Code untouched. | 1 session |
| **3. Reviewer-implementer loop** | Fix assessment issues with human oversight. Reviewer cadence active. | 1-2 sessions |
| **4. Domain deepening** | Archaeologist baseline specs, verified domain knowledge in personas, context7 trigger lists populated. | 1 session |
| **5. Full workflow** | All personas active, OpenSpec change proposals for every feature, health checks, continuous governance, batch execution regime. | Ongoing |

Most projects get significant value at level 2. Domain deepening (level 4) is where personas go from generic to accurate. Level 5 is where the harness pays for itself -- every new feature flows through a reviewable, restartable, spec-driven pipeline with no manual process overhead.

## Core Principles

1. **Spec-driven, not vibe-driven.** Every feature has a governing specification. The reviewer enforces this structurally -- code without spec traceability does not pass review.
2. **Structure over speed.** A well-structured agentic setup is slower to start but dramatically more productive over time.
3. **Restartability.** Kill a session at any point, start fresh, and it picks up where the last one left off by reading committed files.
4. **Small increments.** One task, one commit, one reviewable change. Commit messages reference the governing change slug.
5. **Human in the loop.** The AI proposes; the human decides. The orchestrator generates prompts; you decide when and whether to execute them.
6. **Assessment before implementation.** Onboarding reads and reports. It never modifies your code.
7. **Preserve what works.** Templates fill gaps -- they don't replace working instructions.
8. **Verify, don't recall.** Agents call context7 for current library documentation instead of relying on training-data recall. This is methodology, not optional tooling.

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
| [OpenSpec](https://openspec.dev/) | Specification-driven development -- the spec substrate AEH uses |
| [context7](https://context7.com/) | Current library documentation lookup -- standard SDLC tool in AEH |

## License

AGPL-3.0. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md).

**TL;DR:** Use AEH freely -- personal projects, teams, entire organisations. All generated output (personas, prompts, CLAUDE.md sections) belongs to you under any license you choose. The AGPL only applies if you modify AEH itself and offer it as a public service or distribute it externally.

## Contact

Stefan Berreth -- [gitlab.com/stefanberreth/agentic-engineering-harness](https://gitlab.com/stefanberreth/agentic-engineering-harness)
