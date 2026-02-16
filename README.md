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

## How It Works

### The Two-Claude Model

This harness operates on a strict separation principle:

1. **Harness-side Claude** (running in this project) -- reads target projects, analyses them, produces plans, generates adapted templates and ready-to-paste prompts. **Never modifies target project files** except for one optional, narrow exception (see below).
2. **Target-side Claude** (running in the target project) -- receives prompts from the human operator, executes changes within the target project's own context and permissions.

This separation ensures auditability, reproducibility, and clean context boundaries. Every change to a target project is made by a Claude instance that reads *that project's* `CLAUDE.md` and follows *that project's* conventions.

**Optional: Direct Prompt Delivery.** Per-project, the user can choose to let the harness write prompt files directly into the target project's `docs/AE/prompts/` directory. This means the target-side Claude can simply be told "Read and execute `docs/AE/prompts/003-create-developer-prompt.md`" instead of requiring manual copy-paste. This is a policy choice asked during onboarding and recorded in the target's `profile.md`. The harness never writes anything else into the target project -- only prompt `.md` files into that single directory.

### Transforming an Existing Project

1. Start Claude Code in this project's directory:
   ```bash
   cd /path/to/agentic-engineering-harness
   claude
   ```
2. Claude reads `CLAUDE.md` → `targets/index.md`, shows a session banner with active targets and roles.
3. Say `/onboard` (or `/onboard /path/to/project`) to start the guided onboarding playbook.
4. The playbook runs 7 phases:
   - **Target selection** -- verify the path, check for existing workspace
   - **Reconnaissance** -- structural snapshot, detect existing role-like instructions
   - **Assessment** -- checklist evaluation, inconsistency report, existing setup migration analysis
   - **Report** -- ranked findings presented in terminal-friendly format
   - **Plan** -- transformation plan with numbered tasks and effort estimates
   - **Execute (harness setup only)** -- generate deliverables and prompts that set up AE structure. These prompts only touch `docs/AE/`, `CLAUDE.md` (AE sections), and `_ai/reports/`. They never modify application code.
   - **Implementation handoff** -- present findings and offer options: harness setup only, supervised reviewer-implementer loop, pre-approved auto mode, or stop and review
5. You point a Claude Code session **inside the target project** at the generated prompts:
   ```
   Read and execute docs/AE/prompts/000-run-all-foundation.md
   ```
6. For code-touching implementation (fixing issues from the assessment), you run the reviewer-implementer loop separately with human oversight.
7. Run `/health` periodically to check for drift, new issues, or persona staleness.

### Returning to an Existing Target

Say `/health` (or `/health <slug>`) to run a compliance check against the last assessment. The health check produces a delta report: new issues, resolved issues, regressions, persona drift, and instruction leaks (new guidelines that appeared outside the AE structure).

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
│   ├── governance/
│   │   ├── assessment-checklist.md        # Evaluate agentic readiness
│   │   └── review-criteria.md             # Quality rubric for config files
│   └── playbooks/
│       ├── onboarding.md                  # Guided 7-phase assessment + transformation
│       └── health-check.md               # Recurring compliance check + delta report
├── targets/
│   ├── index.md                           # Registry of all target projects + status
│   └── <project-slug>/                    # Per-project transformation workspace
│       ├── profile.md                     #   Identity, path, stack, context
│       ├── assessment.md                  #   Assessment checklist results
│       ├── transformation-plan.md         #   Phased transformation plan
│       ├── tasks.md                       #   Task tracking for transformation
│       ├── decisions.md                   #   Key decisions with rationale
│       ├── open-questions.md              #   Unresolved questions
│       ├── prompts/                       #   Ready-to-paste prompts for target
│       │   ├── 001-create-claude-md.md
│       │   └── ...
│       ├── deliverables/                  #   Adapted files for the target project
│       │   ├── CLAUDE.md
│       │   └── ...
│       └── journal.md                     #   Chronological session log
├── docs/
│   ├── how-i-tamed-claude-ndc-london-2026.md  # Structured reference from source talk
│   ├── raw transcript.txt                     # Raw talk transcript
│   └── Screenshot 2026-02-15 at 15.17.33.png  # Resources slide
└── logs/                                  # (legacy, migrated to targets/)
```

## Core Principles

1. **Structure over speed.** A well-structured agentic setup is slower to start but dramatically more productive and reliable over time.
2. **Restartability.** Every piece of state that matters must live in committed files, not in conversation history. Any Claude session can be killed and work resumed from disk.
3. **Small increments.** One task, one branch, one reviewable PR. No 100k-line commits.
4. **Feedback loops.** Developer retrospectives feed back to the Reviewer and Architect. The spec is a living document.
5. **Human in the loop.** The human approves requirements, designs, and review verdicts. The AI proposes; the human decides.
6. **Assessment produces reports; implementation acts on them.** Onboarding and assessment workflows never modify application code. They read, analyse, and generate reports. Code changes require a separate step with human oversight (or explicit pre-approval).
7. **Preserve existing conventions.** When a target project has working instructions, they become the foundation -- AE templates fill gaps, they don't replace what works. Merge, don't overwrite.
8. **Templates are starting points.** Every template in this project must be adapted to the target project's language, framework, team, and culture.
9. **Governance is continuous.** Agentic configuration files degrade over time. Regular `/health` checks keep them effective.

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

### v0.2 -- Target Project Isolation & Multi-Project Tracking (Feb 2026)

- Established the **Two-Claude Model**: harness-side Claude reads and plans, target-side Claude executes. Hard boundary: harness never modifies target files directly.
- Created `targets/` workspace structure with per-project directories for profile, assessment, plans, tasks, decisions, open questions, prompts, deliverables and journal.
- Created `targets/index.md` as the orientation entry point for fresh sessions.
- Defined the **prompt file format** -- self-contained, numbered, ordered prompts that a human pastes into a target-project Claude session.
- Defined five transformation phases: assessment → planning → implementing → reviewing → maintaining.
- Replaced `logs/` with `targets/` as the canonical location for all per-project state.
- **Open questions:**
  - How well do the generic persona templates adapt to radically different stacks (embedded C vs. web SPA vs. data pipeline)?
  - What is the right granularity for the assessment checklist?
  - How should OpenSpec integration be templated now that it has changed its structure?
  - What MCP server configurations should be recommended vs. left to project discretion?
  - How should the prompt numbering scheme handle re-ordering or inserting new prompts?
  - What's the right feedback loop when a target-side prompt execution reveals issues?

### v0.3 -- Guided Playbooks, Boundary Enforcement & Session Init (Feb 2026)

- Created **onboarding playbook** (`templates/playbooks/onboarding.md`) -- a guided 7-phase workflow for assessing and transforming new target projects. Triggered via `/onboard`. Includes existing setup detection, migration analysis, skip gates, and re-onboarding protection.
- Created **health-check playbook** (`templates/playbooks/health-check.md`) -- recurring compliance checks for existing targets. Produces delta reports (new issues, resolved, regressions, persona drift, instruction leaks). Triggered via `/health`.
- Established the **assessment-implementation boundary**: onboarding and assessment workflows operate in read-and-report mode only. They set up AE harness structure but never touch application code. Implementation requires a separate step with human oversight, or explicit pre-approval for experienced users.
- Added **merge-and-confirm rule**: prompts that modify existing instruction files must diff current vs deliverable and confirm with the user before applying. No silent overwrites.
- Added **session init and role selection**: persona persistence via `.claude/persona`, 3-line terminal banner, `/switch`, `/role info`, `/ignore` commands. Encoded in both harness CLAUDE.md and as a deliverable for target projects.
- Produced **compression-poc-02 Phase 3 deliverable**: project-specific developer persona tailored to Python/PyTorch/HuggingFace patterns, frozen dataclass configs, Black/MyPy style, and config-driven architecture.
- Reviewed and fixed all 7 existing prompts for compression-poc-02 (2 HIGH, 5 MEDIUM issues).
- Created **orchestration prompt** (000-run-all-foundation.md) that chains harness setup steps in one pass, ending at the review report without touching code.
- **Open questions:**
  - How well does the 7-phase playbook flow for projects with radically different structures (monorepo, polyglot, no existing CLAUDE.md at all)?
  - What's the right threshold for the health check's "30+ days" stale target suggestion?
  - Should the pre-approval mechanism for auto-implementation have a scope limiter (e.g. "auto-fix CRITICAL only")?

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
