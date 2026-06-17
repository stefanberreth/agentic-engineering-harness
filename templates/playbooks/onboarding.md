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

If a workspace already exists for this path, read the target's `tasks.md`, `journal.md` (its `[DECISION]` entries), and `transformation-plan.md` to assess how much progress has been made. Then present the user with a clear summary and choice:

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

If the user picks option 1: read the target's `tasks.md` and the `## Open Questions` section of `orchestrator-state.md` (if the target-orchestrator has initialised it), summarise current state, and propose next steps. The playbook ends here.

If the user picks option 2: switch to the health-check playbook (`templates/playbooks/health-check.md`). The onboarding playbook ends here.

If the user picks option 3: proceed with Phase 2, but first preserve continuity:
- Add a `[DECISION]` entry to `targets/<slug>/journal.md` recording that a re-onboard was initiated and why (the journal is append-only, so prior `[DECISION]` / `[REVIEW]` history is preserved automatically -- no separate backup file needed)

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

> **This phase IS the onboarding bootstrap exception to the enforced `docs/AE/`-only fence** (CLAUDE.md § "The enforced `docs/AE/`-only fence"). First-contact reconnaissance of an un-onboarded target is the one time an AEH-side session reads the target tree directly, because the target has no `docs/AE/` and no AE roles to dispatch into yet. It is NARROW, READ-ONLY, and one-directional: read to assess, never write the target outside `docs/AE/`. The exception ends the moment `docs/AE/` exists -- after onboarding, ongoing assessment is `target-aeh-reviewer`'s (run in the target) and the target-orchestrator operates through the `docs/AE/` channel only.

### 2.0 Greenfield Detection (run first)

Before any deep reconnaissance, run a fast greenfield check. The target is **greenfield** if ALL of the following hold:

- Zero source files (no files in `src/`, `lib/`, `app/`, language-specific roots, etc.; ignore `.git/`, `.gitignore`, `LICENSE`).
- No package/build manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.csproj`, `Makefile`, etc.), or a manifest that exists but declares no dependencies and no scripts.
- No agent config (`CLAUDE.md`, `.claude/`, `agents.md`, `.mcp.json`).
- No CI/CD config (`.github/`, `.gitlab-ci.yml`, `Jenkinsfile`).
- Documentation is at most a default-template README from GitHub/GitLab/etc.

If greenfield: declare it in one line and switch to the **Greenfield Short-Circuit** below. Do NOT proceed to 2a-2d, do NOT interview the operator about domain, stack, or team. The skeleton is generic; project content is filled in by the analyst persona on the first feature, not by this playbook.

If brownfield (anything substantive exists): proceed to 2a normally.

### Greenfield Short-Circuit

Present a one-line declaration:

```
[2/7] Reconnaissance -- <project-name>

Greenfield repository detected (empty or default-template-only).
Skipping reconnaissance and assessment depth. Proceeding to skeleton generation.
```

Then jump straight to a condensed flow:

1. **Skip 2a-2d entirely.** No structural snapshot, no existing-setup detection, no specialist-prompt collection. Re-offer specialist prompts after the skeleton is in place if the operator asks.
2. **Skip Phase 3a (assessment checklist).** Every item is N/A on a greenfield. Write `targets/<slug>/assessment.md` with a single line: `Greenfield project. Assessment N/A until first feature.`
3. **Skip Phase 3b (review criteria).** Nothing to review.
4. **Skip Phase 3c (existing setup migration).** Nothing to migrate.
5. **Skip Phase 3d (inconsistency report).** Nothing to be inconsistent with. The single-line `assessment.md` from step 2 already covers this; do NOT create a separate inconsistency file.
6. **Run Phase 3e (create workspace).** Write `profile.md` with placeholder fields:

   ```markdown
   # Profile: <slug>

   Path:   <absolute-path>
   Slug:   <slug>
   Status: greenfield -- AE skeleton onboarding

   Stack:  TBD (populated by analyst on first feature)
   Domain: TBD (populated by analyst on first feature)
   Team:   TBD (operator confirms when relevant)

   Prompt delivery policy: direct (default -- operator may opt out to manual)

   harness-sync-sha: <run `git -C /workspace/aeh rev-parse HEAD` at onboarding time and paste the SHA here>

   ## Specification Management
   policy: openspec (default in-scope -- operator may opt out in Phase 6g)

   ## Development Tools
   context7: in-scope (default -- operator may opt out in Phase 6g)
   serena: TBD (codebase-dependent assessment in Phase 6g)
   ```

   The `harness-sync-sha:` field records the harness commit SHA at the moment this target was onboarded; the target-orchestrator's session-init step compares it against current harness HEAD to detect upstream updates. See `templates/personas/target-orchestrator.md` § "Harness Update Propagation Signal".

   Do NOT ask domain/stack/team questions -- those are explicitly out of scope for onboarding.

   **Delivery policy: do NOT ask -- default to `direct`.** Direct delivery (harness writes prompts to both `targets/<slug>/prompts/` and `<target-path>/docs/AE/prompts/`) is the only mode under which the target-orchestrator's standard handoff one-liner (`Read and execute docs/AE/prompts/NNN-title.md`) actually works -- target-side Claude sessions are filesystem-scoped to the target project tree and cannot read harness-side paths. Set `policy: direct` in `profile.md` without asking. If the operator explicitly volunteers a preference for manual delivery, honour it AND surface the trade-off ("under manual you'll need to copy each prompt to the target tree before pasting the handoff -- direct is the default for that reason"); record the decision as a `[DECISION]` entry in `journal.md` with the reason.

7. **Skip Phase 4 (report).** There is nothing to report. Note in the journal that the target was onboarded as greenfield.
8. **Phase 5 (plan): use the standard greenfield plan.** Identical for every greenfield target -- no per-project tailoring needed:

   ```
   Transformation plan: <project-name> (greenfield skeleton)

   Phase 1: Foundation
     1. Create target CLAUDE.md (session init + role selection + working rules)
     2. Create docs/AE/ directory structure

   Phase 2: Persona overlays (scaffolded with placeholders)
     3. Place AEH base persona templates -> docs/AE/personas/_base/ (5 files, inline-carried prompt)
     4. Create docs/AE/personas/archaeologist.md (header + Project Identity placeholder)
     5. Create docs/AE/personas/analyst.md       (header + Project Identity placeholder)
     6. Create docs/AE/personas/architect.md     (header + Project Identity placeholder)
     7. Create docs/AE/personas/developer.md     (header + Project Identity placeholder)
     8. Create docs/AE/personas/reviewer.md      (header + Project Identity placeholder)

   Phase 3: Standard tooling (default in-scope; operator may opt out per Phase 6g)
     9. OpenSpec setup     (default -- opt out per Phase 6g)
    10. context7 setup     (default -- opt out per Phase 6g)
        Serena             (auto-skip on greenfield: no codebase to navigate;
                            re-assess via `tools` after first feature lands)

   Phase 4: Verification
    11. Regression check (skeleton-level: verify CLAUDE.md loads, persona switching works)
    12. Role-activation smoke test (HARD GATE -- see below)
    13. Retrospective
   ```

   Confirm with the operator, then write to `tasks.md`.

9. **Phase 6 (execute): run the full Phase 6 sequence -- do NOT stop after skeleton prompts.** The short-circuit collapses reconnaissance and assessment, not execution. Tool setup is what makes the skeleton operational, so it must run on greenfield exactly as on brownfield.

   a. **Skeleton prompts.** Generate the CLAUDE.md prompt and the five persona overlay prompts. Each overlay creates a file with the Persona Header Block and a single `## Project Identity` line: `TBD -- populated by analyst on first feature`. No `§.PROJECT` content beyond placeholders.

   b. **Phase 6g (Standard SDLC Tools Setup) -- MANDATORY, do not skip.** Run the offer block verbatim from Phase 6g below. OpenSpec and context7 are default in-scope; the operator may opt out, but the offer presents installation as the default path:
      - **OpenSpec:** default scope. Present the opt-out confirmation block from Phase 6g; if operator does NOT opt out (silence / yes / continue), read `templates/tools/openspec-setup.md` and generate the setup prompt; insert it into the sequence before the regression check. Record the decision in `profile.md` under `## Specification Management`.
      - **context7:** default scope. Present the opt-out confirmation block from Phase 6g; if operator does NOT opt out, read `templates/tools/context7-setup.md` and generate the **CLI + Skills** setup prompt (MCP fallback only if the CLI can't run). Record the decision in `profile.md` under `## Development Tools`.
      - **Serena:** auto-skip on greenfield (0 lines of source -- assessment criteria in 6g resolve to "do not recommend"). Record in `profile.md` under `## Development Tools`: `serena: not recommended (greenfield -- re-assess via tools after first feature)`. Do NOT present the offer block; the assessment has already resolved.

   c. **Phase 6h (Sandbox env provisioning).** Only if context7 was accepted **in the MCP fallback mode** (which needs `CONTEXT7_API_KEY`). The preferred CLI + Skills mode needs no env var -- skip 6h for it. Skip 6h entirely if context7 was opt-out/deferred. Do not skip merely because the path is greenfield.

10. **Phase 7 (handoff): present options as usual.** Note in the handoff that the analyst persona, once invoked on the first feature, will populate the overlays with real domain/stack/architecture content. Onboarding itself is done -- but onboarding cannot be declared complete until the Role-Activation Completion Gate (section 6i) and the Standard-Tool Verification Completion Gate (section 6j) have passed.

After completing the greenfield short-circuit, do NOT return to the brownfield phases. The playbook is complete for this target. Onboarding cannot be declared complete until the Role-Activation Completion Gate (section 6i) has passed.

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
- **AE role mapping**: which persona (archaeologist/analyst/architect/developer/reviewer) it maps to, or "cross-cutting" if it spans multiple
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

Write the ranked report as a `## Inconsistency Report` section in `targets/<slug>/assessment.md` (the assessment checklist and the ranked findings are one assessment-phase artifact -- do NOT create a separate `inconsistencies.md`).

### 3e. Create Target Workspace

If not already created, set up the full workspace:

```
targets/<slug>/
├── profile.md
├── assessment.md          (checklist + ## Inconsistency Report section, written above)
├── transformation-plan.md (placeholder -- filled in Phase 5)
├── tasks.md               (placeholder)
├── prompts/
├── deliverables/
└── journal.md             (first [REVIEW] entry written from assessment findings)
```

The live dashboard (`orchestrator-state.md`, carrying the `## Open Questions` section) is created by the target-orchestrator on first engagement, not here. Decisions and review findings are recorded as `[DECISION]` / `[REVIEW]` tagged entries in `journal.md`; open questions, once the target-orchestrator initialises, live on the dashboard. There are no separate `decisions.md` / `open-questions.md` / `review-history.md` / `inconsistencies.md` files.

**profile.md** must include:
- Project name and path
- Tech stack summary
- Prompt delivery policy (default `direct`; do NOT ask -- see CLAUDE.md § "Selective exception: Direct Prompt Delivery (default)" for the rationale and the rare opt-out conditions)
- `harness-sync-sha:` -- the harness commit SHA at onboarding time (`git -C /workspace/aeh rev-parse HEAD`). Enables the target-orchestrator's session-init harness-update detection. See `templates/personas/target-orchestrator.md` § "Harness Update Propagation Signal".
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

Full report: targets/<slug>/assessment.md (## Inconsistency Report)
```

If existing role setup was detected:

```
Existing setup: <N> instruction sources detected
  <N> keep as-is · <N> merge/refactor · <N> archive · <N> new needed
  (say "show migration" for details)
```

### 4a. Scope boundary -- read before asking anything

The inconsistency report is a set of *findings*, not an onboarding work list.
**Onboarding (Phases 5-6) only ever stands up the AEH skeleton. It never fixes
inconsistencies.** Fixing them touches application code, configuration, and
non-AE docs -- that is downstream archaeologist and reviewer-implementer work,
explicitly out of onboarding scope (see the Phase 6 scope boundary).

Do NOT ask "which severity levels do you want to address" as a plan-scoping
question. It implies the onboarding plan will address them; it will not. Asking
it that way is a known derailment.

Instead, state where the findings go:

> The findings above are recorded in assessment.md (the ## Inconsistency
> Report section) and summarised as a [REVIEW] journal entry.
> Onboarding does not fix them -- it stands up the AEH structure around the
> project. The findings become a handoff artifact the archaeologist and the
> reviewer-implementer loop consume later. Phase 7 is where you choose whether
> to queue that remediation now or onboard only.

No severity-scoped decision is recorded here. The Phase 7 option choice is the
only scope decision, and it is recorded as a `[DECISION]` entry in
`targets/<slug>/journal.md` at that point.

---

## Phase 5: Plan

```
[5/7] Plan
```

**The onboarding plan is always the AEH harness skeleton -- nothing else.** It
never contains inconsistency-remediation tasks and never carries severity tags
(`[CRITICAL]`, `[HIGH]`): those issues touch application code, config, and
non-AE docs, which is downstream archaeologist and reviewer-implementer work,
not onboarding. The plan content is governed only by:
- Whether the target is greenfield or brownfield
- Existing setup migration recommendations (which existing role files merge
  into which persona overlays)
- The standard AEH harness setup phases

A brownfield plan differs from the greenfield plan only in that persona
overlays merge existing instruction content instead of scaffolding bare
placeholders. Present the plan as a numbered task list:

```
Transformation plan: <project-name> (brownfield -- AEH skeleton only)

Phase 1: Foundation
  1. Merge AE sections into CLAUDE.md (session init, role selection,
     context mgmt) -- merge-and-confirm against existing file   ~1 prompt
  2. Create docs/AE/ directory structure (personas/, prompts/)  ~1 prompt
  3. Add AE entries to .gitignore                               (folded in)

Phase 2: Persona overlays (docs/AE/personas/)
  4. Place AEH base persona templates -> docs/AE/personas/_base/
     (5 files, inline-carried prompt)                           ~1 prompt
  5-9. archaeologist / analyst / architect / developer / reviewer
       -- new where no equivalent exists; merge-and-refactor
       where existing role files exist                          ~1-5 prompts

Phase 3: Standard tooling (offered during execute -- operator chooses)
  10-12. OpenSpec / context7 / Serena (per Phase 6g)            ~0-3 prompts

Phase 4: Verification
  13. Regression check (skeleton-level)                         ~1 prompt
  14. Role-activation smoke test (HARD GATE -- see below)        ~1 prompt
  15. Retrospective                                             ~1 prompt

Total: <N> prompts
```

A persona task that merges an existing role file should note the source:

```
  7. architect overlay (merge-and-refactor from roles/ARCHITECT_ROLE.md)
```

**Ask the user:**

> Approve this plan, modify it, or skip tasks? (say task numbers to skip, or describe changes)

Record approvals and modifications as `[DECISION]` entries in `targets/<slug>/journal.md`.
Write the final task list to `targets/<slug>/tasks.md`.

**Note to operator:** The target-orchestrator enforces mandatory reviewer cadence (every 5 developer tasks or at phase boundaries — non-discretionary). This is built into the target-orchestrator template and does not need to be configured per-project. The plan should anticipate reviewer passes at regular intervals; they are not optional extras.

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

### 6a. Generate Deliverable — Layered Persona Convention

Personas use a two-file layered architecture. **Both files live inside the target project tree** so a target-side Claude -- which is filesystem-scoped to its own project and cannot read the harness -- can load them:
- **Base template** -- the generic AEH role methodology. Copied into the target at `docs/AE/personas/_base/<role>.md`: a per-target snapshot of the harness `templates/personas/<role>.md`, re-synced if the harness base template materially changes.
- **Project overlay** (`docs/AE/personas/<role>.md` in the target project) -- project-specific configuration extending the base.

The five engineering personas are: **archaeologist**, **analyst**, **architect**, **developer**, **reviewer**. The archaeologist runs upstream (before the Analyst → Architect → Developer → Reviewer loop) to produce baseline specs of existing codebases. For greenfield projects with no existing code, the archaeologist overlay is scaffolded but not immediately invoked.

**When generating persona deliverables:**

1. **Place the base templates.** Onboarding generates a base-template-placement prompt that creates `docs/AE/personas/_base/` in the target and writes the five AEH base persona templates (archaeologist, analyst, architect, developer, reviewer) into it. The prompt carries the base-template content inline -- the self-containment rule applies; the target session has no harness access. This is the foundation the overlays' headers point at; it runs in Phase 2, before the role-activation smoke test (Phase 4).

2. **Scaffold overlay files**, not monolithic personas. Each overlay must start with the Persona Header Block:

```markdown
# [Role] Persona: [Project Name]

> **AEH Base:** `docs/AE/personas/_base/<role>.md`
> Load the base template first. This file provides project-specific
> configuration that extends, overrides, or parameterises the base.
> **Precedence rules:**
> - Sections here with the same heading as a base section → this file wins
> - Sections here not in the base → extensions, applied after the base
> - Base sections not mentioned here → apply unchanged
> - `[SKIP]` marker → explicitly suppresses a base section

## Project Identity

[1-2 lines: project name, domain, tech stack summary]
```

3. **Populate `§.PROJECT` extension points** from the base template with project-specific content. Read the base template to identify which extension points exist (e.g. `§1.PROJECT`, `§HR.PROJECT`, `§ENV.PROJECT`) and fill in those that apply to this project.

4. **Merge existing instructions** from the reconnaissance catalogue into the appropriate overlay extension points. Do not duplicate base methodology — only add project-specific rules, conventions, constraints, and domain knowledge.

5. **For projects with existing codebases**, include the archaeologist overlay with investigation tools, priority areas, and known documentation gaps populated from the reconnaissance.

Write overlay deliverables to `targets/<slug>/deliverables/`. These are the working copies — the prompt embeds their content for delivery.

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

**Exception**: For brand-new files that don't exist yet in the target project (e.g. creating a new persona overlay file), the prompt can write directly without a merge step.

**Persona prompt convention:** Prompts that create persona overlay files must instruct the target-side Claude to create files at `docs/AE/personas/<role>.md`. Each prompt must note that the overlay works in conjunction with the AEH base template — the CLAUDE.md in the target project describes the two-file loading convention. The prompt itself must NOT reference harness-side paths (self-containment rule still applies); the overlay's header block points at the target-side base template `docs/AE/personas/_base/<role>.md`, which the base-template-placement prompt has put in place. That path is operative, not merely documentation -- the role's Step 0 loads the base from it.

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

### 6g. Standard SDLC Tools Setup

AEH prescribes two standard SDLC tools — **OpenSpec** and **context7** — as default in-scope for every project. They are load-bearing for successful agentic engineering (spec traceability + current library documentation) and almost every software project benefits from them. The default during onboarding is to set both up; the operator may opt out, but doing so should be a deliberate choice, not the default outcome.

A third tool — **Serena** — remains conditional on codebase characteristics (see below).

#### OpenSpec (standard — default in-scope)

```
OpenSpec is AEH's specification substrate. Every feature flows through
change proposals (analyst → architect → developer → reviewer) with the
reviewer's §0 BLOCKING spec traceability check enforcing discipline.

Default: set up OpenSpec as part of onboarding scope.

  [Y -- proceed with setup (default)]
  [opt-out -- skip OpenSpec for this project (rare; you know better)]
  [defer -- offer again via `tools` later]
```

**Default behavior (Y / silence / "continue" / "yes"):** Read `templates/tools/openspec-setup.md`, generate the setup prompt adapted to this target, and add it to the prompt sequence (insert before the regression check prompt). Record the decision in `profile.md` under a `## Specification Management` section: `policy: openspec`.

**If operator explicitly opts out ("opt-out" / "skip" / "never"):** Record in `profile.md` under `## Specification Management`: `policy: manual (spec.md)`. Personas fall back to `requirements.md` / `spec.md` conventions. The decision is reversible via `tools`. Note the operator-stated reason as a `[DECISION]` entry in `journal.md` so future sessions don't second-guess.

**If operator defers ("not now" / "defer" / "later"):** Record in `profile.md` under `## Specification Management`: `policy: deferred`. OpenSpec will be offered again when the user runs `tools`. The default-in-scope status is preserved -- defer is "not yet", not "no".

#### context7 (standard — default in-scope)

```
context7 provides current library documentation lookup. Agents check
current API shape before writing code that uses fast-moving library APIs —
prevents training-data recall for libraries that changed after the agent's
cutoff.

Preferred install: CLI + Skills (ctx7 setup --cli --<agent>) — a user-global
skill, no .mcp.json, no mandatory API key. MCP server is a fallback only for
environments that can't run the ctx7 CLI.

Default: set up context7 (CLI + Skills) as part of onboarding scope.

  [Y -- proceed with setup (default)]
  [opt-out -- skip context7 for this project (rare; you know better)]
  [defer -- offer again via `tools` later]
```

**Default behavior (Y / silence / "continue" / "yes"):** Read `templates/tools/context7-setup.md`, generate the **CLI + Skills** setup prompt adapted to this target (use the flag matching the target's coding agent), and add it to the prompt sequence. Generate the MCP-fallback variant only if the target environment cannot run the `ctx7` CLI (no Node 18+ / no npx) or the operator asks for it. Record in `profile.md` under `## Development Tools`: `context7: configured (cli-skills)` (or `configured (mcp)` for the fallback). The developer and architect overlays will need a §1a.PROJECT / §3a.PROJECT trigger list populated with the project's fast-moving libraries — generate that as part of the setup prompt.

**If operator explicitly opts out:** Record in `profile.md` under `## Development Tools`: `context7: declined (operator opt-out)`. Note the reason as a `[DECISION]` entry in `journal.md`. Reversible via `tools`.

**If operator defers:** Record in `profile.md` under `## Development Tools`: `context7: deferred`. Will be offered again via `tools`.

#### Serena (assessed — recommended when codebase warrants it)

Unlike OpenSpec and context7 (which benefit every project), Serena's value depends on codebase characteristics. Assess based on the Phase 2 reconnaissance findings:

**Recommend Serena when ALL of:**
- Codebase is >10k lines of source code (semantic navigation adds value over grep at scale)
- Multiple languages or dual-layer architecture (e.g. backend JS + frontend TSX, Python + JS, Go + TS) where cross-layer find-references matters
- The project will undergo significant refactoring or cross-module changes (state machine migrations, financial rewrites, architecture changes)
- LSP support is available for the primary language(s) (TypeScript: excellent. Python: good. JavaScript-without-TS: weaker but usable. Go/Rust: excellent. Ruby: limited.)

**Do NOT recommend Serena when ANY of:**
- Codebase is <5k lines (grep is sufficient, semantic navigation is overhead)
- Single-language, well-typed codebase where grep + Read covers navigation needs
- The project is in maintenance mode with no planned refactoring
- The container/runtime environment cannot support LSP servers (restricted containers, no package installation)

**Present the assessment with rationale:**

```
Serena (semantic code navigation via LSP):
  Codebase size:    <N>k lines — <above/below threshold>
  Languages:        <list> — <multi-layer: yes/no>
  Refactoring ahead: <assessment from transformation plan>
  LSP quality:      <assessment for primary language>

  Recommendation: <install / defer / skip>
  Rationale: <1-2 sentences explaining why>
```

**If recommending:** Read `templates/tools/serena-setup.md`, generate the setup prompt with the correct language server config for this project's stack. Add to the prompt sequence.

**If deferring:** Record in `profile.md` under `## Development Tools`: `serena: deferred (<rationale>)`. The target-orchestrator can re-assess when the project enters a heavy refactoring phase.

**If skipping:** Record in `profile.md` under `## Development Tools`: `serena: not recommended (<rationale>)`. The assessment and rationale are preserved so future sessions don't re-evaluate unnecessarily.

### 6h. Sandbox Environment Variable Provisioning

> **Reference:** `templates/tools/sandbox-env-provisioning.md` for full mechanism details.

If any accepted tool requires environment variables, provision them now. This step ensures the variables reach the agent inside Docker sandbox containers.

**Applies to Context7 only in the MCP fallback mode.** The preferred CLI + Skills install needs no env var (doc queries work without a key; a key only raises rate limits and is set interactively if wanted). If Context7 was installed via CLI + Skills, skip this section. The steps below apply when the MCP fallback was chosen.

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

### 6i. Role-Activation Completion Gate

Onboarding MUST NOT be declared complete until role activation is proven end to end. The skeleton-level regression check verifies files are present; it does NOT prove a role can load. Onboarding prompts are freestyle (no role), so onboarding otherwise never exercises a role -- the gap stays invisible until the first role-bound prompt, post-onboarding. That is the defect this gate closes.

Before Phase 7 handoff, dispatch ONE trivial role-bound prompt (any one engineering role -- archaeologist is the natural choice). The prompt self-activates the role via Step 0 and must confirm that BOTH files loaded from within the target tree: the base template at `docs/AE/personas/_base/<role>.md` and the overlay at `docs/AE/personas/<role>.md`. The role then emits a one-line confirmation and stops -- no investigation work is required; this is a loading smoke test.

If either file fails to load, onboarding is NOT complete. Fix the placement and re-run the gate. This is gate-first applied to onboarding itself: no 'onboarding complete' without a gate that proves the outcome 'roles can activate.'

### 6j. Standard-Tool Verification Completion Gate

Onboarding MUST NOT be declared complete until each standard SDLC tool is either **proven working** or **explicitly opted out via a `[DECISION]` journal entry**. A `profile.md` line that says `configured` is a claim, not proof -- the gate requires functional evidence (or a recorded deliberate opt-out). This closes the failure mode where a tool is "set up" in the plan but never actually functions, and nobody notices until a developer prompt needs it.

For **context7** (one of three outcomes must hold):

1. **Verified working:** the operator has run the functional smoke test in the target session and reported a pass:
   - CLI + Skills mode: `npx ctx7@latest library react "state hooks"` then `npx ctx7@latest docs /facebook/react "useState cleanup"` returns documentation content.
   - MCP mode: the Context7 MCP smoke test from `templates/tools/tool-detection-patterns.md` returns docs.
   Record `context7: configured (cli-skills)` / `configured (mcp)` plus `verified <date>` in `profile.md`.
2. **Explicit opt-out:** `profile.md` records `context7: declined (operator opt-out)` AND `journal.md` has a dated `[DECISION]` entry with the operator's reason. No verification required.
3. **Deferred:** `profile.md` records `context7: deferred`. Allowed, but onboarding is reported as **complete-with-deferral**, not clean-complete, and the deferral is surfaced in the Phase 7 handoff so it is not silently lost.

If context7 was accepted but the smoke test has not been run or did not pass, onboarding is NOT complete: hand the operator the smoke-test commands, wait for the pass, then proceed. (Apply the same proven-or-opted-out logic to OpenSpec via its own verification.)

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
  Assessment:       targets/<slug>/assessment.md (incl. ## Inconsistency Report)
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

Record this choice as a `[DECISION]` entry in `targets/<slug>/journal.md`.

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

Only generate the auto-prompt if the user confirms with that exact phrase or equivalent explicit acknowledgement. Record this as a `[DECISION]` entry in `targets/<slug>/journal.md` with timestamp.

**Option 4:**
Save progress, update journal, end the playbook. The user can return at any time to continue.

### 7e. Mention the Target Orchestrator (informational only)

After presenting the options, add one line:

```
Tip: Switch to the target-orchestrator role to manage prompt execution with
continuous state tracking. It uses the five-role model (Archaeologist,
Analyst, Architect, Developer, Reviewer) and includes two-file persona
loading in all handover prompts. It picks up where you left off across
sessions.
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

1. **Open questions reviewed.** Every harness/orchestration-layer open question raised during onboarding is either resolved (with date and outcome, recorded in `journal.md`) or carried into the `## Open Questions` section of `orchestrator-state.md` for the target-orchestrator to track. No item may sit unmarked.
2. **Retrospective received.** The target-side retrospective prompt has been executed and `docs/AE/retrospective.md` exists in the target project -- OR the user confirms the retrospective session was lost and a `health` check will substitute.
3. **Review baseline recorded.** `targets/<slug>/journal.md` has at least one `[REVIEW]`-tagged entry summarising the initial assessment findings.
4. **Role-Activation Completion Gate passed.** The Phase 4 role-activation smoke test (see section 6i) has been run and confirmed that a role loaded both its base template (`docs/AE/personas/_base/<role>.md`) and its overlay from within the target tree. Onboarding cannot be declared complete until this gate passes.

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
