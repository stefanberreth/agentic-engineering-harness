# Agentic Engineering Harness

A meta-engineering project that provides the templates, governance criteria, persona definitions and process documentation needed to transform any software development project into a mature agentic engineering setup -- where AI coding agents (Claude Code primarily) work within a structured, reviewable, restartable workflow.

## The Problem

AI coding agents are powerful but undisciplined by default. Without structure, they produce unreviewable volumes of code, lose context between sessions, make silent assumptions, and resist being managed. Most developers either "vibe code" (no process, no review) or bolt an AI into their existing workflow without rethinking how work is organised.

## The Solution

This project codifies a **four-persona workflow** (Analyst → Architect → Developer → Reviewer) inspired by [Emmz Rendle's "How I Tamed Claude" talk at NDC London 2026](https://www.youtube.com/watch?v=pey9u_ANXZM). It provides:

- **Persona templates** -- system prompts for each role, encoding mature software engineering principles (TDD, small commits, retrospectives, spec-driven development)
- **Project templates** -- `CLAUDE.md` and `agents.md` scaffolds to configure any target project
- **Governance criteria** -- checklists and rubrics to assess and improve agentic configuration quality
- **Transformation process** -- a repeatable method for taking an existing project from zero agentic setup to a fully structured one

## What This Project Is NOT

- It is **not a framework or library**. There is no code to install or import.
- It is **not specific to any language or stack**. The templates are adapted per target project.
- It **does not implement software**. It produces the configuration, documentation and process artifacts that *drive* implementation.

## How To Use It

### Transforming an Existing Project

1. Clone this repo alongside your target project.
2. Start Claude Code in this project's directory:
   ```bash
   cd /path/to/agentic-engineering-harness
   claude
   ```
3. Claude will orient itself via `CLAUDE.md` and ask which project you want to transform.
4. Provide the path to your target project.
5. Claude will assess the project's current state using the assessment checklist and propose an incremental transformation plan.
6. Work through the plan together -- creating `CLAUDE.md`, persona prompts, spec docs, and governance files in the target project.

### Working on the Harness Itself

Start Claude Code here and say you want to improve the harness. Areas for ongoing refinement:
- Persona prompt effectiveness
- Governance criteria completeness
- New patterns discovered from transformation experience
- Documentation of lessons learned

## Project Structure

```
.
├── CLAUDE.md                              # Claude's instructions for this project
├── README.md                              # This file
├── templates/
│   ├── personas/
│   │   ├── analyst.md                     # Requirements gathering persona
│   │   ├── architect.md                   # Solution design persona
│   │   ├── developer.md                   # TDD implementation persona
│   │   └── reviewer.md                    # Code review persona
│   ├── project/
│   │   ├── CLAUDE.md.template             # Scaffold for target project CLAUDE.md
│   │   └── agents.md.template             # Cross-tool agent config scaffold
│   └── governance/
│       ├── assessment-checklist.md        # Evaluate agentic readiness
│       └── review-criteria.md             # Quality rubric for config files
├── docs/
│   ├── how-i-tamed-claude-ndc-london-2026.md  # Structured reference from source talk
│   ├── raw transcript.txt                     # Raw talk transcript
│   └── Screenshot 2026-02-15 at 15.17.33.png  # Resources slide
└── logs/                                  # Per-project transformation journals
    └── <project-name>/
        └── transformation-log.md
```

## Core Principles

1. **Structure over speed.** A well-structured agentic setup is slower to start but dramatically more productive and reliable over time.
2. **Restartability.** Every piece of state that matters must live in committed files, not in conversation history. Any Claude session can be killed and work resumed from disk.
3. **Small increments.** One task, one branch, one reviewable PR. No 100k-line commits.
4. **Feedback loops.** Developer retrospectives feed back to the Reviewer and Architect. The spec is a living document.
5. **Human in the loop.** The human approves requirements, designs, and review verdicts. The AI proposes; the human decides.
6. **Templates are starting points.** Every template in this project must be adapted to the target project's language, framework, team, and culture.
7. **Governance is continuous.** Agentic configuration files degrade over time. Regular assessment keeps them effective.

## Key Resources

| Resource | URL |
|---|---|
| Claude Code Docs | https://code.claude.com/docs |
| OpenSpec | https://openspec.dev/ |
| Context7 (docs MCP) | https://context7.com/ |
| Serena (LSP MCP) | https://oraios.github.io/serena |
| Anthropic Skills | https://github.com/anthropic/skills |
| Awesome Claude Code | https://github.com/hesreallyhim/awesome-claude-code |
| Awesome Claude Skills | https://github.com/travisvn/awesome-claude-skills |

## Mission Evolution

This section tracks how the project's scope and understanding evolve over time.

### v0.1 -- Foundation (Feb 2026)

- Transcribed and structured the source talk as reference material.
- Created initial persona templates (Analyst, Architect, Developer, Reviewer).
- Created project templates (`CLAUDE.md`, `agents.md`) and governance criteria.
- Established the transformation workflow: assess → plan → adapt → validate.
- **Open questions:**
  - How well do the generic persona templates adapt to radically different stacks (embedded C vs. web SPA vs. data pipeline)?
  - What is the right granularity for the assessment checklist?
  - How should OpenSpec integration be templated now that it has changed its structure?
  - What MCP server configurations should be recommended vs. left to project discretion?

### Future directions

- **Battle-tested refinement:** Apply the harness to real projects, capture what works and what doesn't in transformation logs, and feed improvements back into templates.
- **Skills and commands library:** Develop reusable Claude skills/commands that support the transformation workflow itself.
- **Multi-agent coordination patterns:** Document how to run multiple Claude sessions (e.g. developer + reviewer) effectively.
- **CI/CD integration patterns:** Templates for GitHub Actions / GitLab CI that enforce agentic workflow discipline (branch naming, test gates, coverage rules).
- **Metrics and feedback:** Define how to measure whether an agentic setup is actually improving development velocity and quality.

## License

Private project. Not currently licensed for external use.

## Contact

Stefan Berreth -- maintained in personal GitLab at `gitlab.com/stefanberreth/agentic-engineering-harness`.
