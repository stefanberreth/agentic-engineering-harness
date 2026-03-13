# Playbook: Onboarding a Target Project

This playbook drives the guided assessment and transformation of a new target project. Claude reads this file and follows it step-by-step when the user says `onboard` or when no targets exist.

**Trigger:** `onboard` or `onboard <path>`
**Produces:** A fully populated `targets/<slug>/` workspace with assessment, plan, and ready-to-execute prompts.

---

## Tone Rules

- Max 3 lines per step explanation.
- No emoji, no exclamation marks.
- Show progress: `[2/7] Reconnaissance`
- Offer detail on demand: `(say "explain" for more)`
- Never repeat information the user already acknowledged.

## Skip Gates

The user can say any of these at any time:

| Command | Effect |
|---------|--------|
| `skip to <phase>` | Jump to the named phase (e.g. `skip to report`) |
| `fast mode` | Suppress explanations, show only results and prompts |
| `stop` | End the playbook, save progress to `targets/<slug>/journal.md` |

Experienced users can bypass Phase 1 entirely: `onboard /path/to/project`

---

## Phase 1: Target Selection

```
[1/7] Target Selection
```

**If path was provided with `onboard <path>`:** Skip to validation below.

**Otherwise, ask:**

> Which project do you want to assess? Provide the absolute path to its root directory.

**Validation:**
1. Verify the path exists and is a directory.
2. Verify read access (attempt to list top-level contents).
3. Check whether a target workspace already exists for this path (search `targets/index.md`).

### Existing target detected

If a workspace already exists for this path, read the target's `tasks.md`, `decisions.md`, and `transformation-plan.md` to assess how much progress has been made. Then present the user with a clear summary and choice:

```
This project is already being tracked: <slug> (<phase>)

Progress:
  Tasks:     <N> completed / <N> total
  Decisions: <N> recorded
  Prompts:   <N> generated, <N> applied

Re-onboarding will regenerate the assessment, inconsistency report, and
transformation plan from scratch. This means:
  - Existing task statuses will be reset
  - Recorded decisions (e.g. "no branching", "remove Fresh.dev") will
    need to be re-confirmed or may be lost
  - Prompts already generated but not yet applied will be replaced

Options:
  [1] Continue where you left off (recommended)
      Resume the existing plan. Say `health` to check for new issues.
  [2] Run a health check instead
      Compares current state vs last assessment. Preserves all progress.
      Adds new tasks for new issues only.
  [3] Re-onboard from scratch
      Full re-assessment. Existing workspace files will be overwritten.
      Use this if the project has changed significantly or the existing
      plan is no longer relevant.
```

Wait for the user to choose. Do not proceed with re-onboarding unless the user explicitly picks option 3.

If the user picks option 1: read the target's `tasks.md` and `open-questions.md`, summarise current state, and propose next steps. The playbook ends here.

If the user picks option 2: switch to the health-check playbook (`templates/playbooks/health-check.md`). The onboarding playbook ends here.

If the user picks option 3: proceed with Phase 2, but first back up the existing workspace:
- Copy `targets/<slug>/decisions.md` to `targets/<slug>/decisions-pre-reonboard-<date>.md`
- Note in the journal that a re-onboard was initiated and why

### New target

If no existing workspace is found:

**Derive the slug:** Use the directory name, lowercased, hyphens for spaces. If it collides with an existing slug, append a number.

**Output:**

```
Target: <project-name>
Path:   <absolute-path>
Slug:   <slug>
```

Proceed to Phase 2.

---

## Phase 2: Reconnaissance

```
[2/7] Reconnaissance
```

### 2a. Structural Snapshot

Read the following (where they exist) and note which are present/absent:

| File/Directory | Purpose |
|----------------|---------|
| `README.md` or `README` | Project description |
| `.claude/CLAUDE.md` or `CLAUDE.md` | Agent instructions (`.claude/` location preferred) |
| `.claude/` directory | Claude configuration |
| `agents.md` or `agents.yaml` | Cross-tool agent config |
| `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` / `*.csproj` / `Makefile` | Package/build config |
| `docs/` | Documentation directory |
| `.github/` / `.gitlab-ci.yml` / `Jenkinsfile` | CI/CD config |
| `tests/` / `test/` / `__tests__/` / `spec/` | Test directories |
| `.eslintrc*` / `.prettierrc*` / `ruff.toml` / `setup.cfg` / `rustfmt.toml` | Linter/formatter config |
| `CONTRIBUTING.md` | Contribution guidelines |

Record file counts:
- Total files (non-hidden, non-vendor)
- Source files by language (top 3 languages)
- Test files
- Documentation files (`.md`)

### 2b. Existing Setup Detection

Many projects already have role-based instructions in non-standard locations. Detect, catalogue, and evaluate them.

**Detection targets:**

| Pattern | Where to look | Examples |
|---------|--------------|----------|
| Persona/role files | `.claude/`, `docs/prompts/`, `prompts/`, `docs/AE/`, project root | `developer-prompt.md`, `reviewer-instructions.md`, `SYSTEM_PROMPT.md` |
| Role sections in CLAUDE.md | Embedded in CLAUDE.md or `.claude/Claude.md` | `## Developer Rules`, `## When reviewing code`, `## Coding Standards` |
| agents.md / agents.yaml | Project root, `.claude/` | Cursor rules, Windsurf configs, other tool agent files |
| Workflow instructions | README, CONTRIBUTING.md, `docs/` | `## Development Workflow`, `## Code Review Process` |
| Custom conventions | Various | Commit hooks with role logic, CI configs with review steps |
| MCP configuration | Project root, `.claude/` | `.mcp.json`, `.claude/settings.json` with `mcpServers` |
| Development tools | Project root | `openspec/`, `.serena/`, `.claude/skills/openspec-*` |
| Spec/ADR management | `docs/`, project root | `docs/adr/`, `docs/rfc/`, `specs/`, `.changeset/` |
| Code intelligence | Project root | `.sourcegraph/`, `tags`, `.ctags` |
| Agent permission config | `.claude/` | `.claude/settings.json`, `.claude/settings.local.json` |

**Search strategy:**
1. Glob for files with names containing: `prompt`, `persona`, `role`, `agent`, `instruction`, `system`, `rules`, `convention`, `workflow`, `CONTRIBUTING`
2. Grep CLAUDE.md (if it exists) for section headings suggesting role-specific content: `developer`, `reviewer`, `review`, `coding standard`, `architect`, `analyst`, `workflow`
3. Check `.claude/` directory contents for any instruction-like files beyond the standard `settings.json`
4. Scan README for sections about development workflow, code review, or contribution guidelines
5. Check for `.mcp.json` at project root; if found, read and catalogue all configured MCP servers
6. Check for `.claude/settings.json` and grep for `mcpServers`
7. Check for tool-specific directories: `openspec/`, `.serena/`, `.claude/skills/openspec-*`
8. Check for functional equivalents: `docs/adr/`, `docs/rfc/`, `specs/`, `.changeset/`, `.sourcegraph/`
9. Read `.claude/settings*.json` if they exist: count allow/deny rules, check for secrets (grep for PASSWORD, SECRET, TOKEN, API_KEY), note `defaultMode`, check for `bypassPermissions`

**When development tools are detected**, add a "Development Tools" section to the catalogue:

For each detected tool or MCP server:
- **Tool name**: identified tool or "unknown MCP server"
- **Config location**: where detected (`.mcp.json` entry, directory, etc.)
- **Documented**: whether it's mentioned in CLAUDE.md
- **Status**: working / incomplete / stale
- **Functional equivalents**: any related non-MCP tools detected (ADR dirs, etc.)

**When existing setup is found, build a catalogue:**

For each detected file/section:
- **Source**: file path and section (if within a larger file)
- **Summary**: one-line description of what it covers
- **Quality**: clear / inconsistent / stale / contradictory
- **AE role mapping**: which persona (analyst/architect/developer/reviewer) it maps to, or "cross-cutting" if it spans multiple
- **Coverage**: what topics it addresses vs what the AE template covers
- **Recommendation**: keep as-is / merge and refactor / archive / no existing equivalent (generate new)

### 2c. Present Summary

Present a concise summary to the user:

```
[2/7] Reconnaissance -- <project-name>

Stack:      <primary language> · <framework> · <build tool>
Size:       <N> source files · <N> test files · <N> docs
CI/CD:      <present/absent> (<tool if present>)
Agent config: <what exists>
Permissions: <N> allow / <N> deny rules · mode: <defaultMode> · <issues if any>

Existing role setup:
  <N> files/sections with role-like instructions detected
  (say "show details" for the full catalogue)
```

If existing setup was found, add:

```
Existing instructions found -- these will be evaluated in the assessment
and preserved where they work well.
```

Ask: `Continue to assessment, or adjust scope?`

### 2d. Collect Specialist Prompts

Before moving to assessment, ask:

```
Do you have any specialist prompts, audit checklists, or domain-specific
instructions you've been pasting into Claude sessions for this project?

These might be: a code auditor prompt, a domain expert persona, a review
checklist specific to your tech stack, or any instructions you manually
inject at the start of sessions.

If so, paste them now -- they'll be merged into the appropriate persona
adaptation. If not, say "none" and we'll continue.
```

If the user provides specialist prompts:
1. Identify which AE persona(s) they map to (usually reviewer or developer)
2. Note them in `targets/<slug>/profile.md` under a `## Specialist Inputs` section (source, summary, target persona)
3. During Phase 6 (Execute), merge them into the relevant persona deliverable rather than using the generic template alone

This step captures institutional knowledge that would otherwise live only in the user's clipboard. It's optional but high-value -- domain expertise baked into personas produces dramatically better reviews.

---

## Phase 3: Assessment

```
[3/7] Assessment
```

### 3a. Run Assessment Checklist

Apply every item from `templates/governance/assessment-checklist.md` against the reconnaissance findings. For each of the 7 categories:
- Mark each item: Present / Partial / Missing / N/A
- Add a brief note explaining the rating

Write the completed checklist to `targets/<slug>/assessment.md`.

### 3b. Run Review Criteria (if applicable)

If any agentic config files exist (CLAUDE.md, persona prompts, agents.md), evaluate them against `templates/governance/review-criteria.md`.

Score each applicable criterion: Good / Adequate / Poor / Missing.

**Pay particular attention to section ordering in CLAUDE.md:** If the file has session init, persona selection, or safety-critical instructions, verify they appear in the first 50 lines. Instructions buried deep in a long CLAUDE.md (200+ lines) are unreliably followed by LLMs. Flag any session-critical content found late in the file as a HIGH issue.

Append findings to `targets/<slug>/assessment.md` under a `## Existing Config Quality` section.

### 3c. Evaluate Existing Role Setup

If existing role-like instructions were detected in Phase 2:

For each detected source, produce a migration analysis:

| Source | AE Role | Recommendation | Rationale |
|--------|---------|----------------|-----------|
| `CLAUDE.md` > Developer Rules | developer | Merge and refactor | Good conventions but mixed with architecture concerns |
| `docs/review-process.md` | reviewer | Keep as-is | Clear, specific, well-maintained |
| `README.md` > Workflow section | cross-cutting | Archive | Stale, contradicts CLAUDE.md |

**Key principle:** Never discard working instructions. If the project has good developer guidelines, those become the foundation of the developer persona -- the AE template fills gaps, it does not replace what works.

Write migration analysis to `targets/<slug>/assessment.md` under a `## Existing Setup Migration` section.

### 3d. Generate Inconsistency Report

Cross-reference all findings and produce a ranked inconsistency report:

| Severity | ID | Description | Recommendation |
|----------|----|-------------|----------------|
| CRITICAL | I-01 | ... | ... |
| HIGH | I-02 | ... | ... |
| MEDIUM | I-03 | ... | ... |
| LOW | I-04 | ... | ... |

**Severity definitions:**
- **CRITICAL**: Causes Claude session confusion (contradictory instructions, broken references, ambiguous authority)
- **HIGH**: Creates significant ambiguity (duplicate instruction sources, missing key config, undocumented conventions)
- **MEDIUM**: Structural debt (naming inconsistencies, stale references, incomplete coverage)
- **LOW**: Cosmetic or minor (formatting, optional improvements, nice-to-haves)

Write to `targets/<slug>/inconsistencies.md`.

### 3e. Create Target Workspace

If not already created, set up the full workspace:

```
targets/<slug>/
├── profile.md
├── assessment.md          (written above)
├── inconsistencies.md     (written above)
├── review-history.md      (first entry written from assessment findings)
├── transformation-plan.md (placeholder -- filled in Phase 5)
├── tasks.md               (placeholder)
├── decisions.md
├── open-questions.md
├── prompts/
├── deliverables/
└── journal.md
```

**profile.md** must include:
- Project name and path
- Tech stack summary
- Prompt delivery policy (ask the user now -- see CLAUDE.md for the standard question)
- Key structural features noted during reconnaissance
- Existing setup summary (if applicable)

Update `targets/index.md` with the new target (phase: assessment).

**If `targets/.git/` does not exist** (no private targets repo yet), mention it:

```
Your target workspaces are not yet version-controlled separately.
A nested private repo in targets/ keeps your transformation history
safe without leaking into the public harness. Say "set up targets repo"
to create it, or continue without it.
```

Do not block on this -- it's an offer, not a gate. Proceed regardless of the user's answer.

Proceed to Phase 4.

---

## Phase 4: Report

```
[4/7] Report
```

Present findings in a compact, terminal-friendly format:

```
Assessment complete: <project-name>

CRITICAL (<N>) · HIGH (<N>) · MEDIUM (<N>) · LOW (<N>)

Top issues:
  [C] I-01: <one-line description>
  [C] I-02: <one-line description>
  [H] I-03: <one-line description>

Full report: targets/<slug>/inconsistencies.md
Assessment:  targets/<slug>/assessment.md
```

If existing role setup was detected:

```
Existing setup: <N> instruction sources detected
  <N> keep as-is · <N> merge/refactor · <N> archive · <N> new needed
  (say "show migration" for details)
```

**Ask the user:**

> Which severity levels do you want to address? (e.g. "critical and high", "all", "critical only")

Record their choice in `targets/<slug>/decisions.md`.

---

## Phase 5: Plan

```
[5/7] Plan
```

Generate `targets/<slug>/transformation-plan.md` based on:
- Assessment findings and user's chosen severity scope
- Existing setup migration recommendations
- Standard AE harness transformation phases

Present the plan as a numbered task list:

```
Transformation plan: <project-name>

Phase 1: Foundation
  1. [CRITICAL] Create consolidated CLAUDE.md           ~1 prompt
  2. [CRITICAL] Resolve contradictory instructions       ~1 prompt

Phase 2: Personas
  3. [HIGH] Create developer persona (merge existing)    ~1 prompt
  4. [HIGH] Create reviewer persona                      ~1 prompt

Phase 3: Governance
  5. [MEDIUM] Add assessment checklist                   ~1 prompt
  6. [MEDIUM] Document branch strategy                   ~1 prompt

Total: <N> prompts
```

Tasks based on existing setup migration should note the approach:

```
  3. [HIGH] Create developer persona (merge from CLAUDE.md > Dev Rules + AE template)
```

**Ask the user:**

> Approve this plan, modify it, or skip tasks? (say task numbers to skip, or describe changes)

Record approvals and modifications in `targets/<slug>/decisions.md`.
Write the final task list to `targets/<slug>/tasks.md`.

---

## Phase 6: Execute (AE Harness Setup Only)

```
[6/7] Execute -- harness setup
```

**Scope boundary**: This phase generates prompts that set up the AE harness infrastructure in the target project. These prompts may ONLY touch:
- `.claude/CLAUDE.md` (adding AE sections: session init, role selection, context management)
- `docs/AE/` (personas, prompts, harness artifacts)
- `.gitignore` (adding AE-related ignores like `.claude/persona`)
- `docs/AE/reports/` (writing assessment/review reports)

These prompts must NEVER touch:
- Application code (`scripts/`, `src/`, `lib/`, etc.)
- Non-AE documentation (`README.md`, `CONTRIBUTING.md`, `docs/` outside `docs/AE/`)
- Non-AE configuration (`.gitignore` entries unrelated to AE, build configs, CI configs)
- Test files, build scripts, or infrastructure

For each approved task, in order:

### 6a. Generate Deliverable

Adapt the relevant template from `templates/` to the target project's specifics. When migrating existing instructions, use the project's own content as the foundation and fill gaps from the AE template.

Write to `targets/<slug>/deliverables/`.

### 6b. Generate Prompt -- Self-Contained, Merge, Don't Replace

**Self-containment rule:** Every prompt must be executable by a target-side Claude that has NO access to the harness filesystem. This means:

- **NEVER reference harness-side paths** in the prompt text (`targets/<slug>/deliverables/`, `templates/`, or any path outside the target project directory).
- **EMBED deliverable content directly** in the prompt as a fenced code block or inline text. The deliverable file in `targets/<slug>/deliverables/` is a working copy for the harness; the prompt is the delivery vehicle and must carry the full payload itself.
- **Only reference target-local paths** -- files that exist or will exist inside the target project's own directory tree.

**Merge-and-confirm rule:** Prompts that modify existing instruction files (CLAUDE.md, persona files, agents.md, etc.) must use a **merge-and-confirm** approach, not wholesale replacement. The generated prompt should instruct the target-side Claude to:

1. **Read the current version** of the file being modified.
2. **Compare against the embedded deliverable content** in the prompt.
3. **Diff the two** and present a summary of what will change: sections added, sections modified, sections removed.
4. **Ask the user to confirm** before applying. If the current file has been modified since the deliverable was prepared, the target-side Claude should flag the discrepancy and ask how to proceed rather than silently overwriting.

This prevents loss of changes made between deliverable preparation and prompt execution, and makes the transformation auditable.

**Exception**: For brand-new files that don't exist yet in the target project (e.g. creating a new persona file), the prompt can write directly without a merge step.

Write the prompt following the standard format (see CLAUDE.md > Prompt File Format) to `targets/<slug>/prompts/`.

If the target's prompt delivery policy is `direct`, also write to `<target-path>/docs/AE/prompts/`.

### 6c. Present to User

```
[<current>/<total>] <task title>
  What this does: <one-line description>
  Deliverable:    targets/<slug>/deliverables/<filename>
  Prompt:         targets/<slug>/prompts/<NNN>-<title>.md
  Ready to generate? [y/skip/stop]
```

Wait for user confirmation before generating each prompt. If the user says `skip`, move to the next task. If `stop`, save progress and end.

### 6d. Generate Regression Check Prompt

**Always generate a regression check prompt as the second-to-last prompt in the sequence.** Adapt `templates/prompts/regression-check.md.template` to the target project:

- Replace `[BUILD_COMMAND]` with the project's actual build command (from `package.json`, `Makefile`, etc.)
- Replace `[DEV_SERVER_COMMAND]` with the project's dev server start command
- Replace `[PORT]` and `[API_PORT]` with the project's actual ports
- Add project-specific moved/archived paths to the import integrity checks based on the transformation plan

This prompt verifies that the transformation didn't break builds, imports, config references, or runtime behaviour. The governance review checks structural correctness; the regression check verifies functional correctness.

### 6e. Generate Retrospective Prompt

**Always generate a retrospective prompt as the final prompt in the sequence.** This prompt must be run by the same target-side agent session that executed the other prompts -- that agent has the full mental model from having worked through the entire scope.

The retrospective prompt is universal (not project-specific). Generate it with this content:

```markdown
# Prompt [NNN]: Post-Transformation Retrospective

**Target project:** [name]
**Target directory:** [absolute path]
**Prerequisite prompts:** all previous prompts in this sequence
**Phase:** reviewing

## Context for the operator

This must be run in the SAME session that executed the transformation
prompts. The value comes from the agent's accumulated context -- a fresh
session would just be re-reading files, not reflecting on experience.

If the session that ran the prompts has already ended, skip this prompt.
The insight is lost. (This is a lesson, not a failure -- note it in the
journal and run a `health` check instead.)

## Prompt

You have just completed the full onboarding transformation for this
project. Before this session ends, reflect on what you learned by
working through the entire scope.

Answer these questions:

1. What would you change about the CLAUDE.md you just created or modified?
   Be specific -- which sections, what's missing, what's misleading.

2. What conventions did you discover in the code that are not yet codified
   in any instruction file? List each with a file path example.

3. Where did you have to make assumptions because the instructions or
   specs were ambiguous? List each assumption and what you assumed.

4. What information would have saved you time if you had known it at the
   start of this session?

5. What is fragile? What will break first as this project evolves?

6. If you started a fresh session right now with the current instruction
   files, what would confuse you or lead you astray?

Write your answers to docs/AE/retrospective.md. Be specific -- file paths,
line numbers, concrete examples from this session. Do not fix anything.
Report only.

## Expected outcome

A file `docs/AE/retrospective.md` with honest, specific observations.
This file feeds back into the harness for persona and CLAUDE.md refinement.

## If something goes wrong

If the session has already lost context (restarted, compressed), the
retrospective has limited value. Note this in the journal and move on.
A health check will catch structural issues; the retrospective catches
experiential insight that only exists in-session.
```

The retrospective prompt captures second-pass insight: things the agent only knows because it worked through the full scope. This is not a review of the files (the governance prompt does that). It is a reflection on the experience of using them.

### 6f. After Harness Setup Prompts

```
Harness setup complete.

  Prompts:      targets/<slug>/prompts/
  Deliverables: targets/<slug>/deliverables/
  <delivery note based on policy>

These prompts set up the AE harness structure only.
No application code, configs, or non-AE docs will be touched.

The second-to-last prompt is a regression check -- verifies nothing broke.
The final prompt is a retrospective -- captures what the agent learned.
Run the retrospective in the SAME session as the other prompts.
```

If existing setup was migrated, add:

```
  Note: Prompts will migrate your existing instructions into the AE
  structure. Original files are preserved until you choose to remove them.
```

### 6g. OpenSpec Setup (Recommended)

Before proceeding to handoff, offer OpenSpec setup:

```
OpenSpec is recommended for structured spec management. It integrates
with the AEH role flow: analyst writes specs, architect writes designs
and task breakdowns, developer reads tasks, reviewer checks spec currency.

Set up OpenSpec now? [yes / not now / never for this project]
```

**If "yes":** Read `templates/tools/openspec-setup.md`, generate the setup prompt adapted to this target, and add it to the prompt sequence (insert before the regression check prompt). Record the decision in `profile.md` under a `## Specification Management` section: `policy: openspec`.

**If "not now":** Record in `profile.md` under `## Specification Management`: `policy: deferred`. OpenSpec will be offered again when the user runs `tools`.

**If "never":** Record in `profile.md` under `## Specification Management`: `policy: manual (spec.md)`. Personas fall back to `requirements.md` / `spec.md` conventions. The decision is reversible if the user explicitly asks to reconsider.

After OpenSpec decision, add:

```
  Optional: Additional tools (Context7, Serena) can enhance your workflow.
  Say `tools` to explore options.
```

### 6h. Sandbox Environment Variable Provisioning

> **Reference:** `templates/tools/sandbox-env-provisioning.md` for full mechanism details.

If any accepted tool requires environment variables (currently: Context7 requires `CONTEXT7_API_KEY`), provision them now. This step ensures the variables reach the agent inside Docker sandbox containers.

**Step 1: Check harness-level `.env`**

Read `<harness-root>/.env` (gitignored). For each required variable:
- If present: note the value for interactive use (do NOT write it to prompt files on disk).
- If absent: ask the operator for the value. Store it in the harness `.env` for reuse across future onboardings.

```
Tools you selected require environment variables for sandbox passthrough.

Checking harness config for known keys...
  CONTEXT7_API_KEY: <found / not found>
```

If not found:

```
I need your CONTEXT7_API_KEY to provision it in the target project's .env.
This is a personal key (same across all projects). Get one from https://context7.com/
Paste it here:
```

Store the provided value in `<harness-root>/.env`:

```
# Personal API keys for sandbox passthrough (shared across all targets)
CONTEXT7_API_KEY=<value>
```

**Step 2: Ensure the generated tool setup prompt handles `.env`**

The Context7 setup prompt (generated from `templates/tools/context7-setup.md`) already includes `.env` provisioning steps. Verify the prompt instructs the target-side Claude to:

1. Check if `.env` exists and contains the variable
2. If missing, ask the operator for the value (interactive, not hardcoded)
3. Append to `.env`
4. Ensure `.env` is in `.gitignore`
5. Create `.env.example` documenting required variables (without values)

**Step 3: Pre-provision for the operator (optional, interactive only)**

If the harness has the key value and the delivery policy is `direct`, offer to tell the operator the value so they can have it ready when the target-side Claude asks:

```
When the target-side Claude runs the Context7 setup prompt, it will ask
for CONTEXT7_API_KEY. Your key is available in the harness config.
Want me to show it now so you can paste it? [yes / I know it]
```

This is a convenience -- the key never appears in any file that's version-controlled. It passes through the interactive session only.

**Generality:** This mechanism supports any passthrough variable. When new variables are added to the sandbox's `PASSTHROUGH_VARS` array, add them to `templates/tools/sandbox-env-provisioning.md` and they'll be picked up here automatically.

Proceed to Phase 7.

---

## Phase 7: Implementation Handoff

```
[7/7] Implementation handoff
```

This phase does NOT execute implementation. It presents the assessment findings and gives the user clear options for what to do next.

### 7a. Present Findings Summary

```
Assessment complete: <project-name>

Reports written:
  Assessment:       targets/<slug>/assessment.md
  Inconsistencies:  targets/<slug>/inconsistencies.md
  Plan:             targets/<slug>/transformation-plan.md

Findings: CRITICAL (<N>) · HIGH (<N>) · MEDIUM (<N>) · LOW (<N>)

Top issues:
  [C] I-01: <one-line description>
  [C] I-02: <one-line description>
  [H] I-03: <one-line description>
```

### 7b. Explain What Happens Next

```
The harness setup prompts (Phase 6) are safe to execute --
they only create AE structure files (personas, session init, docs/AE/).

To fix the issues found in the assessment, you need to run the
reviewer-implementer loop. This WILL modify application code,
configs, and documentation based on the findings above.
```

### 7c. Present Options

```
What would you like to do?

  [1] Execute harness setup only (recommended for first run)
      Run the generated prompts to set up AE structure.
      Review the assessment reports yourself.
      Decide what to fix and when.

  [2] Execute harness setup, then run reviewer-implementer loop
      Sets up AE structure, then runs a reviewer pass and
      implementer fix round for CRITICAL and HIGH issues.
      You review each fix before it's committed.
      (Human-in-the-loop: you approve each change)

  [3] Full auto: setup + reviewer-implementer loop, no stops
      For experienced users who trust the process.
      All CRITICAL and HIGH fixes applied automatically.
      Individual commits for each fix -- revertable via git.
      WARNING: This modifies application code without per-change approval.

  [4] Stop here -- I'll review the reports and come back
```

### 7d. Handle Each Choice

**Option 1 (default):**
Generate only the harness setup prompts. End the playbook. The user runs them manually in the target project and decides independently what to fix.

**Option 2 (supervised implementation):**
Generate a reviewer-implementer prompt pair. The reviewer prompt runs autonomously (read-only). The implementer prompt is structured to present each proposed fix and wait for user confirmation before applying.

Record this choice in `targets/<slug>/decisions.md`.

**Option 3 (pre-approved auto):**
Generate a single orchestration prompt that chains reviewer + implementer with no stops. Before generating, confirm:

```
You are pre-approving autonomous code changes. This means:
  - The reviewer will scan the codebase and produce an issue list
  - The implementer will fix all CRITICAL and HIGH issues
  - Each fix gets its own commit (revertable individually)
  - Tests are run after each code change
  - If a fix breaks tests, it's reverted and skipped

To undo everything after the fact:
  git log --oneline    (find the commit before the fixes started)
  git reset --hard <commit>

Type "I understand, proceed" to confirm.
```

Only generate the auto-prompt if the user confirms with that exact phrase or equivalent explicit acknowledgement. Record this in `targets/<slug>/decisions.md` with timestamp.

**Option 4:**
Save progress, update journal, end the playbook. The user can return at any time to continue.

### 7e. Mention the Orchestrator (informational only)

After presenting the options, add one line:

```
Tip: Switch to the orchestrator role to manage prompt execution with
continuous state tracking. It picks up where you left off across sessions.
```

Do not elaborate unless the user asks. This is a pointer, not a pitch.

### 7f. Mention the Strategist (informational only)

After presenting the options, add one line:

```
Tip: If you want a strategic conversation partner (priorities, trade-offs,
research context) outside Claude Code, see templates/personas/strategist.md.
```

Do not elaborate unless the user asks. This is a pointer, not a pitch.

### 7g. Support mention (informational only)

After ALL other output for Phase 7 is complete, add one line:

```
AEH is free and maintained by one person. If it saved you time: https://ko-fi.com/stefanberreth
```

One line, end of output, no elaboration. Never repeat this in subsequent phases or sessions.

---

## Phase Completion

After any phase completes (or the user says `stop`):

1. Update `targets/<slug>/journal.md` with what was done this session.
2. Update `targets/<slug>/tasks.md` with current progress.
3. Update `targets/index.md` with current phase and status.

### Close-out gate (before marking "maintaining")

Do NOT mark a target as "maintaining" in `targets/index.md` until:

1. **Open questions reviewed.** Every item in `targets/<slug>/open-questions.md` is either resolved (with date and outcome) or explicitly deferred (with rationale). No item may sit unmarked.
2. **Retrospective received.** The target-side retrospective prompt has been executed and `docs/AE/retrospective.md` exists in the target project -- OR the user confirms the retrospective session was lost and a `health` check will substitute.
3. **Review history baseline created.** `targets/<slug>/review-history.md` exists with at least one entry from the initial assessment findings.

If any of these are missing, the target stays in "reviewing" phase. This gate prevents the drift that comes from marking a project as done while loose ends remain untracked.

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Path does not exist | Ask user to verify and re-enter |
| Path is not readable | Inform user, suggest checking permissions |
| Target already exists | Offer to re-assess, continue, or create a new slug |
| Assessment finds no issues | Congratulate briefly, suggest running `health` periodically |
| User wants to change scope mid-playbook | Allow it -- re-enter at the relevant phase |
| Context getting large | Suggest saving progress and continuing in a new session |
