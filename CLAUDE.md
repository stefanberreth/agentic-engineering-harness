# Agentic Engineering Harness -- Project Instructions

## Mission

This project is a **meta-engineering harness**. It does not implement software. It develops, tests, maintains and refines the plans, templates, persona definitions, governance criteria and process documentation needed to transform any existing software development project into a mature agentic engineering setup -- one where Claude Code (or similar agents) can be started, stopped and restarted at any point in the lifecycle without losing coherence or going off-piste.

## What This Project Contains

- **Persona templates** (`templates/personas/`) -- system prompt files for the four core engineering roles (Analyst, Architect, Developer, Reviewer), the Harness Reviewer (self-review), and the optional Strategist role. These are generic but principled starting points.
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

There is **one narrow, optional exception** to the isolation rule: the harness may write prompt files directly into a target project's designated prompt inbox directory (conventionally `docs/AE/prompts/` within the target project). This allows the target-side Claude Code instance to simply reference and execute prompts by file path instead of requiring the human to copy-paste prompt text.

**This is a per-target-project policy decision.** It must be:

1. **Asked explicitly** when a new target project is onboarded. The question is:

   > "Would you like the harness to deliver prompt files directly into this target project's `docs/AE/prompts/` directory? This means the harness will create/update/delete files ONLY in that specific directory -- nowhere else in the target project. The alternative is that all prompts stay in the harness and you copy-paste them manually."

2. **Recorded in the target's `profile.md`** under a `## Prompt Delivery Policy` section, with one of:
   - `direct` -- harness writes prompts to `<target-path>/docs/AE/prompts/`
   - `manual` -- all prompts stay in `targets/<project>/prompts/`, human copy-pastes

3. **Respected strictly.** If the policy is `direct`:
   - The harness may ONLY write to `<target-path>/docs/AE/prompts/` -- no other target directory.
   - Files written there are prompt files only (numbered `.md` files following the standard prompt format).
   - The harness still writes its own copy to `targets/<project>/prompts/` as well (single source of truth stays in the harness).
   - Deliverables (adapted `CLAUDE.md`, persona files, etc.) are NEVER written directly -- they always go to `targets/<project>/deliverables/` and a prompt instructs the target-side Claude to apply them.

4. **Changeable at any time.** The human can switch the policy by telling Claude to update the target's `profile.md`. No other files need to change -- prompts are always maintained in both locations when `direct` is active.

#### Why this exception exists

Copy-pasting multi-page prompts is error-prone and tedious. When the harness can drop a prompt file directly into the target project, the human's instruction to the target-side Claude becomes simply:

> "Read and execute `docs/AE/prompts/003-create-developer-prompt.md`"

This is faster, less error-prone, and the prompt file is version-controlled in the target project's repo as a record of what was done.

#### Directory convention

The target-side directory is always `docs/AE/prompts/` (AE = Agentic Engineering). This convention:
- Keeps harness artifacts namespaced and visible in the target project
- Is unlikely to collide with existing directory structures
- Is easy to `.gitignore` if the team doesn't want prompts in their repo
- Can be overridden per-project by recording a different path in `profile.md`

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

### File purposes

| File | Purpose | Updated by |
|---|---|---|
| `profile.md` | Stable identity and context for the target project. Includes prompt delivery policy. Read first on any session. | Created once, updated when policy or context changes. |
| `assessment.md` | Snapshot of the project's agentic readiness. Based on `templates/governance/assessment-checklist.md`. | Created during assessment phase. Re-run when the target evolves. |
| `transformation-plan.md` | The phased plan: what to create, in what order, with what priority. | Created after assessment. Revised as work progresses. |
| `tasks.md` | Granular task tracking for the transformation itself (not the target project's development tasks). | Updated every session. |
| `decisions.md` | Records choices made and why (e.g. "use pytest not unittest because the project already has pytest fixtures"). | Append-only during sessions. |
| `open-questions.md` | Questions that need human input, further investigation, or a decision before proceeding. | Updated every session. Cleared as questions are resolved. |
| `review-history.md` | Append-only longitudinal log of all assessment/health-check/reviewer findings. Each dated entry includes full findings snapshot and comparison against previous. Serves as memory across sessions for pattern detection and drift tracking. | Appended every assessment, health-check, and reviewer pass. |
| `orchestrator-state.md` | Pipeline position, prompt execution log, outcome scorecard, and session handoff notes. Created by the orchestrator persona on first engagement. Execution log and quality gate history are append-only. | Read and updated every orchestrator session. |
| `prompts/` | Numbered, ordered, ready-to-paste prompt files. Each prompt is self-contained: it tells a Claude Code instance inside the target project exactly what to do. | Created as transformation plan is executed. |
| `deliverables/` | Fully adapted files (persona prompts, `CLAUDE.md`, etc.) ready to be placed into the target project. | Created alongside prompts. |
| `journal.md` | Chronological session log: what was done, what was learned, what's next. | Appended at end of each session. |

### The targets/index.md registry

This file is the **entry point for orientation**. It lists every target project with:
- Project slug and display name
- Filesystem path
- Current transformation phase (assessment / planning / implementing / reviewing / maintaining)
- One-line status summary
- Date of last activity

A fresh Claude session should read `CLAUDE.md` (this file) and then `targets/index.md` to understand the full landscape.

---

## Transformation Phases

Each target project moves through these phases:

### 1. Assessment
- Read the target project's structure, README, existing config
- Complete the assessment checklist (`templates/governance/assessment-checklist.md`)
- Write findings to `targets/<project>/assessment.md`
- Identify the priority actions

### 2. Planning
- Produce `targets/<project>/transformation-plan.md` with phased, ordered tasks
- Identify project-specific adaptations needed for templates
- Document decisions and open questions
- Get human approval on the plan

### 3. Implementing
- For each task in the transformation plan:
  - Adapt the relevant template to the target project
  - Write the adapted file to `targets/<project>/deliverables/`
  - Write a corresponding prompt to `targets/<project>/prompts/`
  - **Self-containment check:** Before finalising the prompt, verify it contains NO references to harness-side paths (`targets/`, `deliverables/`, `templates/`). All deliverable content must be embedded directly in the prompt text.
  - If prompt delivery policy is `direct`: also write the prompt to `<target-path>/docs/AE/prompts/`
  - Update `targets/<project>/tasks.md`
- The human takes each prompt to a Claude Code session in the target project:
  - If `direct` delivery: "Read and execute `docs/AE/prompts/NNN-title.md`"
  - If `manual` delivery: human copy-pastes the prompt text from `targets/<project>/prompts/`

### 4. Reviewing
- After the target project has its agentic config in place, review it using `templates/governance/review-criteria.md`
- Document findings, suggest improvements
- Feed lessons back into the harness templates

### 5. Maintaining
- Periodic re-assessment as the target project evolves
- Update persona prompts and config as the target's stack or workflow changes
- The target project's own retrospectives may trigger harness-side updates

### Post-Onboarding: Domain Deepening

Onboarding produces clean structure but domain-thin personas. The personas know the tech stack and conventions but don't deeply understand what the code actually does, what the specs get right or wrong, or what architectural decisions were made and why. Domain accuracy comes from post-onboarding investigation.

**Three phases:**

| Phase | What happens | Who does it |
|-------|-------------|-------------|
| 1. Housekeeping | Close open questions from assessment, resolve deferred items, fix known config issues | Harness generates a cleanup prompt; target executes |
| 2. Ground truth | Code archaeology (map what exists) + spec reconciliation (compare specs against code) | Harness reads target for code archaeology; target executes spec reconciliation prompt |
| 3. Refine | Archive/delete stale specs, inject verified domain knowledge into personas, fix documentation debt | Target executes prompts generated by harness |

Phase 2 is the highest-value step. The spec reconciliation classifies every spec as MATCHES (accurate), PARTIAL (partly built), ASPIRATIONAL (correctly unbuilt), or STALE (contradicts the code). Stale specs that claim false implementation are the most dangerous finding -- they actively mislead agents.

**The harness-target division of labour:**

1. **Harness designs the question.** The harness-side agent generates a read-and-report prompt based on what needs investigation.
2. **Target executes the investigation.** The target-side agent -- running inside the project with full CLAUDE.md context -- reads the code, compares against specs/docs, and writes findings to `docs/AE/`.
3. **Harness interprets the results.** The operator brings findings back to the harness. The harness-side agent reads the report and generates refinement prompts.
4. **Target applies refinements.** Archive stale specs, update personas, fix documentation.

**Why the target-side agent, not the harness?** The target-side agent has the project's CLAUDE.md loaded, knows the conventions, and operates within the project's permission model. It will produce more accurate findings than an external agent reading the same files without that context. The harness can read target files for assessment, but domain-deep investigation belongs to the agent that lives in the codebase.

---

## Prompt File Format

Every file in `targets/<project>/prompts/` should follow this structure:

```markdown
# Prompt [NNN]: [Short Title]

**Target project:** [name]
**Target directory:** [absolute path]
**Execute in:** [target project Claude Code session / AEH harness session / external LLM session]
**Prerequisite prompts:** [list of prompt numbers that must be executed first, or "none"]
**Phase:** [assessment / planning / implementing / reviewing]

## Context for the operator

[Brief explanation of what this prompt does and why, WHO should
execute it and WHERE. Never assume this is obvious -- the human
operates multiple agent contexts simultaneously.]

## Prompt

[The actual text to paste into Claude Code. This should be self-contained:
it should not assume the target-side Claude has any context from this
harness project. It should reference only files that exist or will exist
in the target project.

CRITICAL: Prompts must NEVER reference harness-side file paths (anything
under targets/<project>/deliverables/, targets/<project>/, or the harness
directory). The target-side Claude cannot access the harness filesystem.
When a prompt needs to deliver content (persona files, adapted CLAUDE.md
sections, configuration), the full content must be EMBEDDED directly in
the prompt as a fenced code block or inline text. The deliverable file
in the harness is a working copy for the harness; the prompt is the
delivery vehicle and must carry the payload itself.

IMPORTANT: When the prompt modifies an existing instruction file (CLAUDE.md,
persona files, agents.md, etc.), it must use a merge-and-confirm approach:
read the current file, read/receive the deliverable, diff the two, present
the changes to the user, and confirm before applying. Never silently
overwrite instruction files -- changes made between deliverable preparation
and prompt execution would be lost. New files that don't yet exist in the
target can be written directly.]

## Expected outcome

[What files should be created/modified, what the human should verify.]

## If something goes wrong

[Fallback instructions: what to check, how to retry, when to come
back to the harness for a revised approach.]
```

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

When assessing a new target project, the harness operates as a **reviewer by nature**. The assessment is not just a checklist exercise -- it's a deep audit. These principles apply to every assessment:

### Thoroughness

- **Read everything.** Don't skim. Read all instruction files (`CLAUDE.md`, `.claude/`, `agents.md`, README), all configuration files, and all documentation indexes. For source code, read the directory structure completely and sample key files.
- **Cross-reference.** Check whether what instruction files SAY matches what the filesystem SHOWS. Document every contradiction.
- **Count things.** How many spec files? How many test files? How many fix instructions? Volume matters -- it signals documentation sprawl or audit debt.

### Inconsistency Detection

- **Produce a ranked inconsistency report** for every assessment. Use severity levels: CRITICAL (causes Claude session confusion), HIGH (creates ambiguity), MEDIUM (structural debt), LOW (cosmetic).
- **Check for duplicates.** Multiple instruction files covering the same topic is a top-priority finding.
- **Check naming conventions.** Are file names, directory names, and in-file references internally consistent? Mixed casing, mixed separators (hyphens vs underscores), stale path references -- all go in the report.
- **Check for staleness.** Look for date references, version numbers, and references to files/directories that no longer exist. Stale documentation is worse than missing documentation.

### Deriving Policies

- When assessment reveals existing conventions that are well-established in the target project, **encode them as explicit policies** in the transformation deliverables rather than replacing them with generic templates.
- When assessment reveals inconsistencies, **document the inconsistency AND propose a resolution**, but always defer the final decision to the human.
- When assessment reveals mature practices (e.g. a working audit methodology, a config-driven architecture), **preserve and build on them** rather than imposing the harness's generic patterns.

### Assessment Outputs

Every assessment produces these files in `targets/<project>/`:

| File | Content |
|---|---|
| `profile.md` | Project identity, tech stack, prompt delivery policy, key structural features |
| `assessment.md` | Completed checklist (10 categories) with status and notes per item |
| `inconsistencies.md` | Ranked report of all findings with severity, description, and recommendation |
| `review-history.md` | First entry: full findings snapshot from initial assessment (append-only from here on) |
| `transformation-plan.md` | Phased, ordered plan with task descriptions, priorities, and effort estimate |
| `tasks.md` | Checklist view of all transformation tasks |
| `decisions.md` | Decisions made during assessment + pending decisions needing human input |
| `open-questions.md` | Unresolved questions that need human input before work can proceed |
| `journal.md` | Session log of what was read, found, and produced |

---

## The Reviewer-Implementer Loop

The core operational workflow for transforming a target project:

1. **Harness** writes policy/rule files as deliverables (adapted CLAUDE.md, persona prompts, policies)
2. **Reviewer** Claude instance (in target project) evaluates rules against project ground truth, produces a ranked issue list as technical instruction tickets
3. **Implementer** Claude instance (in target project) works through tickets top-down (CRITICAL first, then HIGH, etc.)
4. **Repeat** until the reviewer finds no further CRITICAL or HIGH violations

The human's role is to:
- Review the harness's deliverables before applying them
- Review the reviewer's findings and approve/prioritise
- Decide when to stop iterating (e.g. MEDIUM/LOW issues can be deferred)

This pattern is encoded in the prompt templates: `005-run-reviewer.md` runs the review, `006-implementer-fix-round.md` runs the fixes. These are reusable -- run them as many times as needed.

---

## Assessment-Implementation Boundary

Onboarding and assessment workflows operate in **read-and-report mode**. They may:
- Read any file in the target project
- Create/modify files in the AE harness namespace (`docs/AE/`, `_ai/reports/`)
- Set up AE harness structure (personas, session init, CLAUDE.md sections for AE)
- Generate reports, assessments, inconsistency lists, and transformation plans

They must **never**:
- Modify application code, scripts, or non-AE configuration files
- Modify non-AE documentation (README, CONTRIBUTING, docs/ content outside `docs/AE/`)
- Run build, test, or lint commands that modify state
- Make fixes, refactors, or "improvements" to the codebase

The boundary is: **assessment produces reports; implementation acts on them.** Implementation (code changes, doc fixes, config corrections) requires a separate step with human oversight.

### Pre-approval for experienced users

Users familiar with the process may pre-approve the implementation phase by explicitly saying so. This must be:
1. **Asked, not assumed.** The onboarding playbook asks at the end of the assessment phase.
2. **Informed.** The user is told what will happen: which issues will be fixed, which files will be touched, and that the reviewer-implementer loop will run autonomously.
3. **Recoverable.** The prompt must include clear revert instructions (commit hashes, `git reset` commands) so the user can undo everything if it goes wrong.
4. **Recorded.** The choice is logged in `targets/<slug>/decisions.md`.

This is an opt-in escalation, not the default. The default is: assessment stops at the report, and the user decides what happens next.

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

This harness is a project like any other. It needs the same discipline it prescribes for target projects.

### CHANGELOG.md

`CHANGELOG.md` at project root tracks all notable changes. It follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

**Update the CHANGELOG for every commit that:**
- Adds, changes, or removes a template, persona, playbook, or governance document
- Changes CLAUDE.md rules or working patterns
- Adds or modifies harness-level features (commands, session init, playbooks)
- Changes README or public-facing documentation

**Do not update the CHANGELOG for:**
- Target-specific work (prompts, deliverables, assessments, journal entries, persona adaptations) -- these are tracked per-project in `targets/<project>/tasks.md` and `targets/<project>/journal.md`
- Typo fixes or minor formatting

**When to bump the version:** When a coherent set of changes forms a meaningful capability increment. Not every commit is a version bump -- group related changes under the current unreleased version until they form a logical unit, then tag it.

### README.md

The README is the public face of this project. Update it when:
- A new capability is added (persona, playbook, command)
- The project structure changes
- Core principles are added or revised
- The "Current Status" section becomes stale

### Documentation currency

After every session that modifies the harness itself (not target work), verify:
1. Does CLAUDE.md reflect the current rules and structure?
2. Does README.md reflect the current capabilities and status?
3. Is CHANGELOG.md up to date?
4. Does the project structure tree in CLAUDE.md and README.md match reality?

If any of these are stale, fix them before committing other work.

### Nested Repository Structure (targets/)

This project uses two git repositories:

1. **Harness repo** (root) -- public, tracks templates, governance, playbooks, docs, CLAUDE.md, README. Pushed to the public remote.
2. **Targets repo** (`targets/`) -- private, tracks all target project workspaces (assessments, plans, prompts, deliverables, journals). Nested inside the harness directory but is an independent git repo.

The harness `.gitignore` contains `targets/` so nothing under `targets/` is tracked by the public repo. The targets repo owns everything in that directory, including `index.md`.

**Commit and push rules:**

**Command style for the targets repo:** Always use `git -C targets/` with a relative path -- never use an absolute path with `-C`. This ensures the command pattern matches across permission approvals (the user approves once, all subsequent `git -C targets/ ...` commands match). Example: `git -C targets/ status`, not `git -C "/full/path/targets" status`.

When the user says "commit" or "commit and push":
1. **Determine what changed.** Run `git status` and `git -C targets/ status` to check both repos.
2. **If only harness files changed:** Commit and push the harness repo only.
3. **If only target files changed:** Commit and push the targets repo only (`git -C targets/ ...`).
4. **If both changed:** Commit and push BOTH repos, in separate commits with appropriate messages. Commit the targets repo first (it's the inner dependency), then the harness repo.

When committing target-specific work (assessments, prompts, deliverables, journal entries):
- Commit to the **targets repo**, not the harness repo.
- Use descriptive messages: `<slug>: <what changed>` (e.g. `my-project: complete Phase 3 assessment`).
- Do NOT update CHANGELOG.md for target-specific work.

When committing harness work (templates, governance, playbooks, CLAUDE.md):
- Commit to the **harness repo** only.
- Follow the existing CHANGELOG/README currency rules.

**Never assume only one repo is affected.** Always check both on commit.

**Detecting and offering the nested repo setup:**

On session start, check whether `targets/.git/` exists. If it does not, and target workspaces exist under `targets/`, mention it briefly:

```
Note: targets/ has no private repo set up. Your target workspaces are
unversioned. Say "set up targets repo" for the recommended setup.
```

If the user says "set up targets repo" (or equivalent), explain briefly:
- What it is: a nested private git repo inside `targets/` that tracks all transformation workspaces independently from the public harness repo
- Why: keeps private project data versioned without risk of leaking into a shared/public harness
- How: `git init` in `targets/`, add all existing files, optionally add a private remote for backup

Then offer to create it. After creation, verify it works:
- `git -C targets/ status` shows a clean working tree
- `git status` in the root shows no target workspace files

If the user already has it set up, verify on first commit of the session that both repos are healthy (`git status` in both).

If the targets repo has no remote configured, do not nag -- but if the user asks about backup or syncing target data across machines, suggest adding a private remote.

---

## Working Rules

- **Never write application code.** This project produces markdown, configuration, process documentation, and prompt engineering artifacts only.
- **NEVER modify target project files directly.** Produce prompts and deliverables here; the human executes them in the target project. (See "Target Project Isolation" above.)
- **Always ask which target project** the user wants to work on before generating any artifacts.
- **Assess before prescribing.** Read the target project's existing structure (you CAN read target project files for assessment purposes) before proposing changes.
- **Favour incremental transformation.** Don't propose a 50-file overhaul. Identify the highest-value first step and iterate.
- **Respect existing conventions.** Encode the target project's existing patterns into generated artifacts rather than replacing them.
- **Track everything in targets/.** Every observation, decision, question, and deliverable goes into the target's workspace.
- **Templates are starting points, not gospel.** Always adapt to the target project's language, framework, team size and maturity.
- **Update targets/index.md** whenever a target project's phase or status changes.
- **Capture rules into files.** When a conversation produces a new rule or policy, write it into the correct instruction file immediately. (See "Rule Capture Principle" above.)
- **Always state execution context explicitly.** When presenting prompts, instructions, or next steps to the user, always state WHERE each action should be executed: "in the AEH harness session", "in the target project's Claude Code session (e.g. a target project)", or "in an external LLM session (e.g. Claude Web for the strategist)". Never assume the human knows which agent instance should run a given prompt. This applies to all communication: prompt handoff instructions, health check remediation, next-step summaries, and conversational suggestions. The human operates multiple concurrent agent contexts -- ambiguity about which context to act in causes errors.
- **Orchestrator state is append-friendly.** The Prompt Execution Log and quality gate history in `orchestrator-state.md` are append-only -- never rewrite or reorder past entries. Configuration, Pipeline Position, and Session Handoff Notes are mutable and updated each session.
- **No target project details in harness files.** Templates, personas, playbooks, governance criteria, CLAUDE.md, README, and CHANGELOG must never contain identifying details about specific target projects -- no project names, tech stacks, team details, scores, or any information that could identify a real project. Examples in these files must use generic placeholders (`my-project`, `<slug>`, `<project-name>`). Target-specific information belongs exclusively in `targets/<project>/` (the private repo). This protects client confidentiality and keeps the public harness generic. The `harness-reviewer` persona enforces this systematically -- run it before publishing or after significant harness changes. Git commit messages in the harness repo are also in scope: they must not reference real target project names, stacks, or scores.

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

The active persona is stored in `.claude/persona` as a single line (e.g. `reviewer`). This file is NOT tracked in git (add to `.gitignore`).

Valid roles: `analyst`, `architect`, `developer`, `reviewer`, `harness-reviewer`, `orchestrator`

Note: A `strategist` persona template also exists (`templates/personas/strategist.md`) but is not an active harness-side role. It is designed for use in external LLM sessions (Claude Web, etc.) where the human pastes an adapted briefing document. When users ask about roles or say "role info", mention the strategist as an available option for users who want a strategic conversation partner outside Claude Code. Don't push it -- just make it discoverable.

The `harness-reviewer` role is special: it reviews the harness itself, not target projects. It checks for target detail leakage, documentation currency, template consistency, and public-facing quality. Use it before publishing or after significant harness changes. See `templates/personas/harness-reviewer.md`.

The `orchestrator` role manages the agentic pipeline for a single target project. It tracks prompt execution, assesses agent output quality, maintains outcome metrics, and generates the next action. Unlike other roles that do work, the orchestrator manages the flow of work across roles. It persists state in `targets/<slug>/orchestrator-state.md` so any session can reconstruct the full pipeline position. See `templates/personas/orchestrator.md`.

An absent or empty file means no role is active.

### On first message of every session

1. Read `.claude/persona` (if it exists).
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
  Roles: analyst · architect · developer · reviewer · harness-reviewer · orchestrator
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
| "switch" or "switch role" | Show role picker. Update `.claude/persona`. |
| "role info" | Show one-line summary of each role + path to its definition file (`templates/personas/<role>.md`). Include the strategist as an optional external role. |
| "ignore role" or "no role" | Clear `.claude/persona`. Work without persona constraints. |
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
├── templates/
│   ├── personas/
│   │   ├── analyst.md                     # Requirements gathering persona
│   │   ├── architect.md                   # Solution design persona
│   │   ├── developer.md                   # TDD implementation persona
│   │   ├── harness-reviewer.md            # Harness self-review persona
│   │   ├── orchestrator.md               # Pipeline management persona
│   │   ├── reviewer.md                    # Code review persona
│   │   └── strategist.md                  # Strategic advisor (optional, for external LLM sessions)
│   ├── prompts/
│   │   └── regression-check.md.template   # Post-transformation functional regression check
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
│   │   └── serena-teardown.md             # Serena teardown prompt template
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
└── logs/                                  # (legacy, migrated to targets/)
```
