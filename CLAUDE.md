# Agentic Engineering Harness -- Project Instructions

## Mission

This project is a **meta-engineering harness**. It does not implement software. It develops, tests, maintains and refines the plans, templates, persona definitions, governance criteria and process documentation needed to transform any existing software development project into a mature agentic engineering setup -- one where Claude Code (or similar agents) can be started, stopped and restarted at any point in the lifecycle without losing coherence or going off-piste.

## What This Project Contains

- **Persona templates** (`templates/personas/`) -- base template files for the five engineering roles (Archaeologist, Analyst, Architect, Developer, Reviewer), plus the Orchestrator, Harness Reviewer, and optional Strategist. Engineering base templates use numbered sections with `§.PROJECT` extension points for project-specific overlays.
- **Project templates** (`templates/project/`) -- scaffold files (`CLAUDE.md`, `agents.md`, governance checklists) to be adapted for target projects.
- **Governance criteria** (`templates/governance/`) -- assessment checklists and quality rubrics for evaluating and evolving the agentic configuration of a target project.
- **Agent knowledge** (`templates/agents/`) -- agent-specific reference knowledge (permission schemas, detection patterns, baselines) for coding agent runtimes like Claude Code.
- **Reference documentation** (`docs/`) -- source material, transcripts and curated resources.
- **Target project workspaces** (`targets/`) -- per-project directories holding all planning, assessment, transformation artifacts and generated prompts. See below.

---

## CRITICAL RULE: Target Project Isolation

**Claude Code running in this harness project must NEVER directly modify application code, configuration, or general files in any target project directory.**

This is not a suggestion. It is a hard boundary. The reasons are:

1. **Context separation.** This harness and a target project are different scopes with different permissions, conventions and objectives. Mixing them creates confusion and risk.
2. **Auditability.** Every change to a target project should be made by a Claude Code instance running *inside* that project, where it reads that project's `CLAUDE.md`, follows that project's conventions, and operates within that project's permission model.
3. **Reproducibility.** The prompts generated here are artifacts that can be reviewed, edited, versioned and re-run. Direct file writes are fire-and-forget.

### What this harness DOES produce

- **Assessment documents** -- analysis of a target project's current state
- **Transformation plans** -- phased, prioritised plans for what to create/change
- **Generated prompts** -- complete, ready-to-paste prompts that a human takes to a Claude Code session running *inside the target project* to execute changes there
- **Adapted templates** -- project-specific versions of persona prompts, `CLAUDE.md`, etc., written as files *in this harness* under `targets/<project>/deliverables/`, for the human to copy or for a prompt to instruct the target-side Claude to create

### What this harness NEVER does

- Write, edit, or delete application code, configuration, or general files under a target project's directory tree
- Run build, test, or git commands inside a target project
- Make commits or push changes in a target project's repository

When producing deliverables, always write them to `targets/<project>/deliverables/` and generate an accompanying prompt in `targets/<project>/prompts/` that tells the target-side Claude Code instance how to apply them.

### Selective exception: Direct Prompt Delivery

The harness may optionally write prompt files directly into a target project's `docs/AE/prompts/` directory (prompt files only — never deliverables or other files). This is a **per-target policy** recorded in `profile.md` as `direct` or `manual`. Ask during onboarding. When `direct`: the harness writes to both `targets/<project>/prompts/` (source of truth) and `<target-path>/docs/AE/prompts/` (delivery). The target-side Claude then runs: "Read and execute `docs/AE/prompts/NNN-title.md`". The directory path can be overridden per-project in `profile.md`.

---

## Artifact Output Rule

**All artifacts, reports, reference documents, and deliverables must be written to the workspace tree — never to Claude Code's memory directory (`~/.claude/`).**

Claude Code's built-in memory (`~/.claude/projects/*/memory/`) is for session-to-session recall notes only (e.g., user preferences, conversation context). It must not be used for:
- Reports, diagnostics, or review outputs
- Reference documents or expanded guides
- Deliverables or generated content
- Any artifact that a human or another agent session might need to read

**Why:** The harness often runs inside a Docker container where `~/.claude/` is a named volume invisible from the host. The workspace directories (`/workspace/aeh/`, `/workspace/<project>/`) are bind-mounted and visible. Anything written to Claude's memory is effectively lost between environments.

**Where artifacts go:**

| Artifact type | Write to |
|---|---|
| Harness planning/state | `targets/<slug>/` |
| Harness reference docs | `docs/` or inline in templates |
| Target-side reports | `docs/AE/reports/` or `docs/AE/reviews/` (in target project) |
| Target-side deliverables | `targets/<slug>/deliverables/` → delivered via prompts |

---

## Target Project Workspace Structure

Each target project gets a workspace under `targets/`:

```
targets/
├── index.md                          # Registry of all target projects and their status
└── <project-slug>/
    ├── profile.md                    # Project identity: path, stack, repo, owner, key context
    ├── assessment.md                 # Completed assessment checklist with findings
    ├── transformation-plan.md        # Phased plan for the transformation
    ├── tasks.md                      # Task tracking for THIS transformation (not the target's dev tasks)
    ├── decisions.md                  # Key decisions made during transformation, with rationale
    ├── open-questions.md             # Unresolved questions requiring human input or investigation
    ├── review-history.md                # Append-only longitudinal findings log
    ├── orchestrator-state.md             # Pipeline position, execution log, outcome scorecard
    ├── prompts/                      # Ready-to-paste prompts for execution in the TARGET project
    │   ├── 001-create-claude-md.md
    │   ├── 002-create-analyst-prompt.md
    │   └── ...
    ├── deliverables/                 # Generated files intended for the target project
    │   ├── CLAUDE.md                 # Adapted CLAUDE.md for this specific target
    │   ├── analyst.md                # Adapted analyst persona for this target
    │   └── ...
    └── journal.md                    # Chronological log of transformation sessions
```

Key files: `profile.md` (read first every session), `tasks.md` + `open-questions.md` (updated every session), `orchestrator-state.md` (pipeline position, append-only execution log), `review-history.md` (append-only findings log), `journal.md` (session log). `targets/index.md` is the entry point — lists all projects with phase and status. A fresh session reads `CLAUDE.md` → `targets/index.md` → active target's `profile.md` + `tasks.md`.

---

## Transformation Phases

> **Full reference:** `templates/playbooks/onboarding.md` — read when working on a transformation, domain deepening, or running the reviewer-implementer loop.

| Phase | Summary |
|-------|---------|
| 1. Assessment | Read target, complete checklist, write findings to `targets/<project>/assessment.md` |
| 2. Planning | Produce transformation plan, get human approval |
| 3. Implementing | Adapt templates → deliverables → prompts. Self-containment check: no harness paths in prompts. |
| 4. Reviewing | Review agentic config using `templates/governance/review-criteria.md`, feed lessons back |
| 5. Maintaining | Periodic re-assessment, persona updates, retrospective-driven changes |

**Post-onboarding domain deepening** follows three phases: housekeeping → ground truth (spec reconciliation) → refine. The target-side agent runs investigations; the harness designs questions and interprets results. The **reviewer-implementer loop** (harness writes deliverables → reviewer evaluates → implementer fixes → repeat) is the core operational workflow.

---

## Prompt File Format

> **Full template:** See any existing prompt in `targets/<project>/prompts/` for the canonical format.

Every prompt must include: header (target, directory, execute-in, role, prerequisites, phase), context for operator, the prompt text, expected outcome, and fallback instructions. **Critical rules:** prompts must be self-contained (no harness-side paths), deliverable content must be embedded inline, and modifications to existing instruction files must use merge-and-confirm (never silently overwrite).

---

## How This Project Is Used

1. Start Claude Code **in this project directory**.
2. Claude reads this file and `targets/index.md` to orient.
3. The user either:
   a. **Picks an existing target** to continue working on, or
   b. **Nominates a new target** to begin assessment.
4. All planning, analysis and deliverable generation happens HERE.
5. The user takes generated prompts to Claude Code sessions IN the target project.
6. Results and lessons feed back into this harness.

---

## Assessment Working Principles

> **Full reference:** `templates/playbooks/onboarding.md` and `templates/governance/assessment-checklist.md` — read before running any assessment or onboarding.

**Key principles:** Read everything, cross-reference instructions against filesystem, count things, produce a ranked inconsistency report (CRITICAL/HIGH/MEDIUM/LOW). Encode existing conventions as policies rather than replacing them. Assessment is read-and-report only — never modify application code, scripts, or non-AE files during assessment.

---

## Rule Capture Principle

**Every rule, policy, or convention that emerges from a conversation must be captured into the correct instruction file.**

Rules don't live in chat transcripts. They live in files:
- **Target project rules** -> deliverables (adapted CLAUDE.md, persona prompts)
- **Harness process rules** -> this file (CLAUDE.md)
- **Per-target decisions** -> `targets/<project>/decisions.md`
- **Governance criteria** -> `templates/governance/`

When a conversation produces a new insight about how the harness should work, or how a target project should be configured, always ask: "Where does this rule belong?" and write it there. Don't rely on the human remembering it from a previous session.

---

## Harness Maintenance Discipline

> **Full reference:** See "Nested Repository Structure" below and the harness-reviewer persona at `templates/personas/harness-reviewer.md`.

**Key rules (always active):**
- Two git repos: harness (root, public) and targets (`targets/`, private, nested). Always use `git -C targets/` (relative path) for the targets repo.
- On commit: check BOTH repos (`git status` + `git -C targets/ status`). Commit targets repo first if both changed.
- Target-specific commits go to targets repo only. No CHANGELOG update for target work.
- After harness changes: verify CLAUDE.md, README.md, CHANGELOG.md, and project structure tree are current before committing.
- CHANGELOG follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Update for template/persona/playbook/governance/CLAUDE.md changes. Skip for target work and typo fixes.

---

## Working Rules

- **Never write application code.** This project produces markdown, configuration, process documentation, and prompt engineering artifacts only.
- **NEVER modify target project files directly.** Produce prompts and deliverables here; the human executes them in the target project. (See "Target Project Isolation" above.)
- **Always ask which target project** the user wants to work on before generating any artifacts.
- **Onboarding is structural, not domain-discovery.** Skeleton generation (harness workspace under `targets/<slug>/` + AE infrastructure prompts for the target's `docs/AE/`) is decoupled from project content. Onboarding does NOT require knowing the project's domain, tech stack, team size, or business purpose. Persona overlays scaffold with placeholder `## Project Identity` lines and `TBD` profile fields; analyst and architect overlays are populated by the analyst persona on the first feature, not by the onboarding playbook. Do NOT interview the operator about domain/stack/team during onboarding. Empty repos and brand-new GitLab/GitHub default-README repos are the easiest onboarding case, not a blocker -- proceed straight to the greenfield branch of `templates/playbooks/onboarding.md`.
- **Assess before prescribing.** Read the target project's existing structure (you CAN read target project files for assessment purposes) before proposing changes.
- **Favour incremental transformation.** Don't propose a 50-file overhaul. Identify the highest-value first step and iterate.
- **Respect existing conventions.** Encode the target project's existing patterns into generated artifacts rather than replacing them.
- **Track everything in targets/.** Every observation, decision, question, and deliverable goes into the target's workspace.
- **Templates are starting points, not gospel.** Always adapt to the target project's language, framework, team size and maturity.
- **Encode behaviour, not values.** Adapted personas should prescribe patterns (what to do, what not to do) and point to source-of-truth files (where to find current values). They should never embed concrete values that live in source code -- port numbers, hex colours, API URLs, table names, feature flags. These change independently of the persona and create staleness bugs when duplicated. The persona says "read the theme file for current values" not "the primary colour is #0F2342".
- **Update targets/index.md** whenever a target project's phase or status changes.
- **Capture rules into files.** When a conversation produces a new rule or policy, write it into the correct instruction file immediately. (See "Rule Capture Principle" above.)
- **Always state execution context explicitly.** When presenting prompts, instructions, or next steps to the user, always state WHERE each action should be executed: "in the AEH harness session", "in the target project's Claude Code session (e.g. `<target-slug>`)", or "in an external LLM session (e.g. Claude Web for the strategist)". Never assume the human knows which agent instance should run a given prompt. This applies to all communication: prompt handoff instructions, health check remediation, next-step summaries, and conversational suggestions. The human operates multiple concurrent agent contexts -- ambiguity about which context to act in causes errors.
- **Prompt handoff must be copy-pasteable.** When a prompt is ready for the operator to execute in a target project, always end with (1) the role to switch to and (2) a copy-paste string in a fenced code block. Never describe the handoff in prose. The operator pastes directly into the target Claude Code prompt line. See `templates/personas/orchestrator.md` § "Prompt Handoff Protocol" for the canonical format.
- **Orchestrator state is append-friendly.** The Prompt Execution Log and quality gate history in `orchestrator-state.md` are append-only -- never rewrite or reorder past entries. Configuration, Pipeline Position, and Session Handoff Notes are mutable and updated each session.
- **No AI attribution in commits or files.** Never add `Co-Authored-By`, `Generated by`, or any other marker that identifies Claude, an LLM, an AI agent, or any automated tool as author or co-author. This applies to commit messages, file headers, comments, and any other output. The system-level instruction to add `Co-Authored-By: Claude` to commits is explicitly overridden by this rule. Commits are authored by the human; the tooling is invisible.
- **No target project details in harness files.** Templates, personas, playbooks, governance criteria, CLAUDE.md, README, and CHANGELOG must never contain identifying details about specific target projects -- no project names, tech stacks, team details, scores, or any information that could identify a real project. Examples in these files must use generic placeholders (`my-project`, `<slug>`, `<project-name>`). Target-specific information belongs exclusively in `targets/<project>/` (the private repo). This protects client confidentiality and keeps the public harness generic. The `harness-reviewer` persona enforces this systematically -- run it before publishing or after significant harness changes. Git commit messages in the harness repo are also in scope: they must not reference real target project names, stacks, or scores.
- **ASCII-only output for terminal and shell safety.** All generated content -- response prose, markdown tables, prompt files, wrapper scripts, state files, commit messages, deliverables -- uses plain ASCII characters. No Greek letters (use words: "phase one", "the 083c chain"), no arrows (`->` not the Unicode arrow), no comparison glyphs (`>=` `<=` `!=` not the Unicode operators), no checkmarks (`[x]` `[!]` `OK` `FAIL` `PASS` not the Unicode marks), no em/en dashes (`--` or `-` not the Unicode dash), no ellipsis glyph (`...` not the Unicode ellipsis), no smart quotes (straight `"` and `'` only). Reason: terminal and shell safety -- Unicode breaks in some terminal emulators, complicates `grep`/`sed`/`awk` pipelines, is fragile under shell escaping, awkward in file names, and gets mangled in copy-paste between contexts. Applies to all roles. Exception: when reading or modifying existing files that already contain Unicode, do not ASCII-fy unprompted; the rule governs new content the harness generates.

## Screenshots

The user shares screenshots via `docs/screenshots/`. This directory is gitignored (transient communication, not project content).

Files are named with macOS default timestamps: `Screenshot YYYY-MM-DD at HH.MM.SS.png`. When the user refers to "the screenshot", "the last screenshot", or "the latest one", glob `docs/screenshots/*.png` and use the timestamp in the filename to determine recency. Read the most recent file to view it.

## Context Management

- This is a documentation-heavy project. Context fills up fast when reading target projects.
- Prefer short, focused sessions: one assessment, one persona adaptation, one prompt batch per session.
- Before exiting, update `targets/<project>/journal.md` and `targets/<project>/tasks.md` with progress.
- On fresh start, read this file, then `targets/index.md`, then the active target's `profile.md` and `tasks.md`.

## Playbooks

Playbooks are guided workflows stored in `templates/playbooks/`. When triggered, Claude reads the playbook file and follows it step-by-step. Each playbook has skip gates so experienced users can jump ahead or stop at any point.

| Command | Playbook | When to use |
|---------|----------|-------------|
| `onboard` | `templates/playbooks/onboarding.md` | Assess and transform a new target project. Runs 7 phases: target selection, reconnaissance, assessment, report, planning, harness setup, implementation handoff. |
| `health` | `templates/playbooks/health-check.md` | Run a recurring compliance check on an existing target. Produces a delta report comparing current state vs last assessment, detects persona drift and instruction leaks. |
| `tools` | `templates/playbooks/tools.md` | Configure optional development tools (OpenSpec, Context7, Serena) for a target project. Detects existing tools, offers setup/removal, generates prompts. |

When a playbook is triggered, Claude must read the playbook file and follow its instructions exactly. The playbook governs tone, pacing, output format, and user interaction for the duration of the workflow.

---

## Session Init and Role Selection

### Persona persistence

The active persona is stored as a single line (e.g. `reviewer`) in a marker file whose path resolves via `bin/resolve-persona-marker.sh`:

- **Single-directory-no-Docker setups** (default): marker is `.claude/persona` — unchanged legacy behaviour.
- **Docker / container setups** with a non-trivial `$HOSTNAME`: marker is `.claude/persona.$HOSTNAME` — gives each container its own marker, avoiding collision when multiple AEH orchestrator sessions bind-mount the same harness directory from separate containers.

Call `bin/resolve-persona-marker.sh` to get the resolved path for the current environment; both session-init reads and Step 0 writes use this resolver so the behaviour is consistent.

The marker file (in either form) is NOT tracked in git — `.claude/persona` and `.claude/persona.*` are both gitignored. The resolver also performs opportunistic stale-marker cleanup on session init: per-hostname markers untouched for >30 days are removed, so container-rebuild churn doesn't accumulate cruft.

Valid roles: `analyst`, `archaeologist`, `architect`, `developer`, `reviewer`, `harness-reviewer`, `orchestrator`

Note: A `strategist` persona template also exists (`templates/personas/strategist.md`) but is not an active harness-side role. It is designed for use in external LLM sessions (Claude Web, etc.) where the human pastes an adapted briefing document. When users ask about roles or say "role info", mention the strategist as an available option for users who want a strategic conversation partner outside Claude Code. Don't push it -- just make it discoverable.

The `harness-reviewer` role is special: it reviews the harness itself, not target projects. It checks for target detail leakage, documentation currency, template consistency, and public-facing quality. Use it before publishing or after significant harness changes. See `templates/personas/harness-reviewer.md`.

The `orchestrator` role manages the agentic pipeline for a single target project. It tracks prompt execution, assesses agent output quality, maintains outcome metrics, and generates the next action. Unlike other roles that do work, the orchestrator manages the flow of work across roles. It persists state in `targets/<slug>/orchestrator-state.md` so any session can reconstruct the full pipeline position. The orchestrator enforces **mandatory reviewer cadence** (every 5 developer tasks or at phase boundaries — non-discretionary) and tracks review state (`last_reviewed_task`, `current_gap`) to prevent reviews from being skipped. No phase can be signed off without a reviewer PASS/WARN covering its full scope. See `templates/personas/orchestrator.md`.

An absent or empty file means no role is active.

### On first message of every session

1. Resolve the persona marker path via `bin/resolve-persona-marker.sh`, then read it if it exists (path is `.claude/persona` for non-Docker setups, `.claude/persona.$HOSTNAME` inside Docker containers).
2. Read `targets/index.md` for landscape context.
3. Output the session banner. **Keep it to 3 lines max.** Style: clean, minimal, terminal-native.

**If a persona is set:**

```
agentic-engineering-harness · reviewer (from last session)
  Targets: my-project (implementing)
  Continue as reviewer, or: switch · role info · ignore role
```

**If no persona is set:**

```
agentic-engineering-harness · no active role
  Roles: analyst · archaeologist · architect · developer · reviewer · harness-reviewer · orchestrator
  Pick a role, or "no role" to work freestyle. Say "role info" for details.
```

**If no active targets exist** (regardless of persona), append to the banner:

```
  No target projects yet. Say "onboard" to assess your first project.
  AEH is free and maintained by one person. Support: https://ko-fi.com/stefanberreth
```

The support line only appears when there are no targets (fresh install / first session). Once the user has onboarded a project, it is never shown in the banner again -- subsequent mentions happen only at the end of onboarding and health-check outputs.

**If targets exist but any haven't been checked in 30+ days**, append:

```
  <slug> last checked <N> days ago. Say "health" to run a check.
```

4. **Wait for the user before proceeding.** When a persona is carried over from a previous session, do NOT adopt it automatically. Show the banner and wait for the user to either confirm the role (by saying "continue", giving a task, or acknowledging) or switch/clear it. Do not read the persona definition file or apply persona constraints until confirmed. Do not launch into work unprompted.

### Commands (natural language, not slash commands)

These are natural language triggers the user can say at any time. They are NOT Claude Code slash commands or skills -- they are keywords that Claude recognises from this file and matches to playbooks or actions. No leading slash.

| User says | Action |
|-----------|--------|
| "switch" or "switch role" | Show role picker. Update the resolved persona marker (path via `bin/resolve-persona-marker.sh`). |
| "role info" | Show one-line summary of each role + path to its definition file (`templates/personas/<role>.md`). Include the strategist as an optional external role. |
| "ignore role" or "no role" | Clear the resolved persona marker (path via `bin/resolve-persona-marker.sh`). Work without persona constraints. |
| "onboard" or "onboard <path>" | Start the guided onboarding playbook for a new target project. Reads `templates/playbooks/onboarding.md` and follows it step-by-step. |
| "health" or "health <slug>" | Run a health check on an existing target. Reads `templates/playbooks/health-check.md` and follows it step-by-step. |
| "tools" or "tools <slug>" | Configure optional development tools for a target project. Reads `templates/playbooks/tools.md` and follows it step-by-step. |

### Role behaviour

When a persona is active, Claude should:
- Read the persona definition file (`templates/personas/<role>.md`) at session start
- Follow its instructions and constraints
- Note the active role in any deliverables produced

When no persona is active, Claude operates as a general assistant within the harness rules.

### After the banner

If continuing an existing target:
  a. Read that target's `profile.md`, `tasks.md`, and `open-questions.md`.
  b. Summarise current state and propose next steps.

If adding a new target:
  a. Ask for the project path.
  b. Read its top-level structure, README, and any existing agentic config.
  c. Ask the prompt delivery policy question (direct to `docs/AE/prompts/` or manual copy-paste).
  d. Create the target workspace (including `profile.md` with the chosen policy) and run the assessment.

If working on the harness itself:
  a. Ask what aspect to improve (templates, governance, docs, process).
  b. Work on it, commit when the user is satisfied.

## Project Structure

```
.
├── CLAUDE.md                              # This file
├── README.md                              # Public-facing project description
├── CHANGELOG.md                           # Version history (Keep a Changelog format)
├── LICENSE                                # AGPL-3.0
├── LICENSE-FAQ.md                         # License clarifications (output ownership, SaaS, etc.)
├── CONTRIBUTING.md                        # How to contribute (prompt-first, BDFL model)
├── bin/
│   ├── resolve-persona-marker.sh         # Resolves .claude/persona marker path (Docker-aware; legacy fallback)
│   └── validate-personas.sh              # Structural validation for base templates + overlays
├── templates/
│   ├── personas/
│   │   ├── analyst.md                     # Requirements gathering (base template)
│   │   ├── archaeologist.md               # Codebase investigation (base template)
│   │   ├── architect.md                   # Solution design (base template)
│   │   ├── developer.md                   # TDD implementation (base template)
│   │   ├── reviewer.md                    # Code review (base template)
│   │   ├── harness-reviewer.md            # Harness self-review persona
│   │   ├── orchestrator.md               # Pipeline management persona
│   │   └── strategist.md                  # Strategic advisor (optional, for external LLM sessions)
│   ├── prompts/
│   │   ├── regression-check.md.template   # Post-transformation functional regression check
│   │   └── orchestrator-batch-regime.md   # Regime 2 switchover prompt template
│   ├── scripts/
│   │   └── loop-driver.sh.template        # Autonomous dev→gates→reviewer loop template
│   ├── project/
│   │   ├── CLAUDE.md.template             # Scaffold for target project CLAUDE.md
│   │   └── agents.md.template             # Cross-tool agent config scaffold
│   ├── governance/
│   │   ├── assessment-checklist.md        # Evaluate agentic readiness
│   │   └── review-criteria.md             # Quality rubric for config files
│   ├── playbooks/
│   │   ├── onboarding.md                  # Guided assessment + transformation workflow
│   │   ├── health-check.md               # Recurring compliance check workflow
│   │   └── tools.md                       # Optional development tool configuration
│   ├── tools/
│   │   ├── README.md                      # Tool integration overview
│   │   ├── tool-detection-patterns.md     # Detection patterns for tools + equivalents
│   │   ├── openspec-setup.md              # OpenSpec setup prompt template
│   │   ├── openspec-teardown.md           # OpenSpec teardown prompt template
│   │   ├── context7-setup.md              # Context7 setup prompt template
│   │   ├── context7-teardown.md           # Context7 teardown prompt template
│   │   ├── serena-setup.md                # Serena setup prompt template
│   │   ├── serena-teardown.md             # Serena teardown prompt template
│   │   └── sandbox-env-provisioning.md    # Sandbox passthrough var provisioning mechanism
│   └── agents/
│       ├── README.md                      # Agent-specific knowledge overview
│       └── claude-code/
│           ├── permissions.md             # Permission schema reference + anti-patterns
│           ├── permission-detection-patterns.md  # Glob/grep patterns for auditing
│           └── permission-baselines.md    # Recommended configs by project archetype
├── targets/                               # Private nested repo (not tracked by public harness)
│   ├── index.md                           # Registry of all target projects
│   └── <project-slug>/                    # Per-project transformation workspace
│       ├── profile.md                     #   Identity, path, stack, context
│       ├── assessment.md                  #   Assessment checklist results
│       ├── transformation-plan.md         #   Phased transformation plan
│       ├── tasks.md                       #   Task tracking for transformation
│       ├── decisions.md                   #   Decisions and rationale
│       ├── open-questions.md              #   Unresolved questions
│       ├── review-history.md              #   Append-only longitudinal findings log
│       ├── orchestrator-state.md         #   Pipeline position, execution log, scorecard
│       ├── prompts/                       #   Ready-to-paste prompts for target
│       ├── deliverables/                  #   Adapted files for target project
│       └── journal.md                     #   Chronological session log
├── docs/
│   ├── Images/
│   │   ├── AEH-Round.png                 # Project logo (circular, for avatars)
│   │   └── AEH-square.jpg                # Project logo (square, for badges)
│   ├── how-i-tamed-claude-ndc-london-2026.md
│   ├── raw transcript.txt
│   └── Screenshot 2026-02-15 at 15.17.33.png
└── docs/screenshots/                      # (gitignored, transient human-Claude communication)
```
