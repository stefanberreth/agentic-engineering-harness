# Playbook: Onboarding a Target Project

This playbook drives the guided assessment and transformation of a new target project. Claude reads this file and follows it step-by-step when the user says `/onboard` or when no targets exist.

**Trigger:** `/onboard` or `/onboard <path>`
**Produces:** A fully populated `targets/<slug>/` workspace with assessment, plan, and ready-to-execute prompts.

---

## Tone Rules

- Max 3 lines per step explanation.
- No emoji, no exclamation marks.
- Show progress: `[2/6] Reconnaissance`
- Offer detail on demand: `(say "explain" for more)`
- Never repeat information the user already acknowledged.

## Skip Gates

The user can say any of these at any time:

| Command | Effect |
|---------|--------|
| `skip to <phase>` | Jump to the named phase (e.g. `skip to report`) |
| `fast mode` | Suppress explanations, show only results and prompts |
| `stop` | End the playbook, save progress to `targets/<slug>/journal.md` |

Experienced users can bypass Phase 1 entirely: `/onboard /path/to/project`

---

## Phase 1: Target Selection

```
[1/6] Target Selection
```

**If path was provided with `/onboard <path>`:** Skip to validation below.

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
      Resume the existing plan. Say /health to check for new issues.
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
[2/6] Reconnaissance
```

### 2a. Structural Snapshot

Read the following (where they exist) and note which are present/absent:

| File/Directory | Purpose |
|----------------|---------|
| `README.md` or `README` | Project description |
| `CLAUDE.md` | Agent instructions |
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
| Persona/role files | `.claude/`, `docs/prompts/`, `prompts/`, `_ai/`, project root | `developer-prompt.md`, `reviewer-instructions.md`, `SYSTEM_PROMPT.md` |
| Role sections in CLAUDE.md | Embedded in CLAUDE.md or `.claude/Claude.md` | `## Developer Rules`, `## When reviewing code`, `## Coding Standards` |
| agents.md / agents.yaml | Project root, `.claude/` | Cursor rules, Windsurf configs, other tool agent files |
| Workflow instructions | README, CONTRIBUTING.md, `docs/` | `## Development Workflow`, `## Code Review Process` |
| Custom conventions | Various | Commit hooks with role logic, CI configs with review steps |

**Search strategy:**
1. Glob for files with names containing: `prompt`, `persona`, `role`, `agent`, `instruction`, `system`, `rules`, `convention`, `workflow`, `CONTRIBUTING`
2. Grep CLAUDE.md (if it exists) for section headings suggesting role-specific content: `developer`, `reviewer`, `review`, `coding standard`, `architect`, `analyst`, `workflow`
3. Check `.claude/` directory contents for any instruction-like files beyond the standard `settings.json`
4. Scan README for sections about development workflow, code review, or contribution guidelines

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
[2/6] Reconnaissance -- <project-name>

Stack:      <primary language> · <framework> · <build tool>
Size:       <N> source files · <N> test files · <N> docs
CI/CD:      <present/absent> (<tool if present>)
Agent config: <what exists>

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

---

## Phase 3: Assessment

```
[3/6] Assessment
```

### 3a. Run Assessment Checklist

Apply every item from `templates/governance/assessment-checklist.md` against the reconnaissance findings. For each of the 7 categories:
- Mark each item: Present / Partial / Missing / N/A
- Add a brief note explaining the rating

Write the completed checklist to `targets/<slug>/assessment.md`.

### 3b. Run Review Criteria (if applicable)

If any agentic config files exist (CLAUDE.md, persona prompts, agents.md), evaluate them against `templates/governance/review-criteria.md`.

Score each applicable criterion: Good / Adequate / Poor / Missing.

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

Proceed to Phase 4.

---

## Phase 4: Report

```
[4/6] Report
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
[5/6] Plan
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

## Phase 6: Execute

```
[6/6] Execute
```

For each approved task, in order:

### 6a. Generate Deliverable

Adapt the relevant template from `templates/` to the target project's specifics. When migrating existing instructions, use the project's own content as the foundation and fill gaps from the AE template.

Write to `targets/<slug>/deliverables/`.

### 6b. Generate Prompt -- Merge, Don't Replace

Prompts that modify instruction files (CLAUDE.md, persona files, agents.md, etc.) must use a **merge-and-confirm** approach, not wholesale replacement. The generated prompt should instruct the target-side Claude to:

1. **Read the current version** of the file being modified.
2. **Read the deliverable** (the harness-prepared version).
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

### 6d. After All Prompts

```
All prompts generated.

  Prompts:      targets/<slug>/prompts/
  Deliverables: targets/<slug>/deliverables/
  <delivery note based on policy>

Next steps:
  1. Open Claude Code in the target project
  2. Execute prompts in order (001 first, then 002, etc.)
  3. After applying all prompts, run /health here to verify
```

If existing setup was migrated, add:

```
  Note: Prompts will migrate your existing instructions into the AE
  structure. Original files are preserved until you choose to remove them.
```

Offer to run a reviewer pass: `Want to generate a reviewer prompt (005-run-reviewer.md) now?`

---

## Phase Completion

After any phase completes (or the user says `stop`):

1. Update `targets/<slug>/journal.md` with what was done this session.
2. Update `targets/<slug>/tasks.md` with current progress.
3. Update `targets/index.md` with current phase and status.

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Path does not exist | Ask user to verify and re-enter |
| Path is not readable | Inform user, suggest checking permissions |
| Target already exists | Offer to re-assess, continue, or create a new slug |
| Assessment finds no issues | Congratulate briefly, suggest running /health periodically |
| User wants to change scope mid-playbook | Allow it -- re-enter at the relevant phase |
| Context getting large | Suggest saving progress and continuing in a new session |
