# Changelog

All notable changes to AEH (Agentic Engineering Harness) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). This project does not yet use semantic versioning -- versions are sequential milestones (v0.1, v0.2, etc.) reflecting capability growth.

Target-project-specific work (prompts, deliverables, assessments, journal entries) is NOT tracked here. That work lives in `targets/<project>/` and is tracked per-project in `tasks.md` and `journal.md`.

---

## [Unreleased]

### Added
- **OpenSpec: no MCP server for CLI agents** -- OpenSpec setup template, teardown template, tools playbook, tools README, and CLAUDE.md.template updated to make clear that CLI agents with filesystem access (Claude Code, Aider, etc.) should NOT use the OpenSpec MCP server. Spec files are markdown readable directly; the MCP server adds a brittle intermediary for zero functional gain. MCP server setup retained only for sandboxed environments without filesystem access.
- **MCP runtime health verification** -- governance tooling now performs functional checks on MCP servers, not just static config detection. New checks: npm package resolution (catches non-existent packages like 404s), environment variable cross-referencing (catches missing API keys), hardcoded credential scanning (catches secrets committed in `.mcp.json`), and user-level config conflict detection (catches `~/.claude.json` shadows). Detection patterns in `templates/tools/tool-detection-patterns.md`, assessment checklist items 9.9-9.12, review criteria Section 5 verification method, and health-check Phase 3h functional verification with expanded tool health reporting table.
- **Orchestrator persona** (`templates/personas/orchestrator.md`) -- pipeline management role that tracks prompt execution, assesses agent output quality, maintains outcome metrics, and generates next actions. Persists state in `targets/<slug>/orchestrator-state.md` for cold-start reconstruction. Supports auto-drive and step-by-step modes with configurable quality gates. Added to valid roles in CLAUDE.md, personas table in README, workspace structure, and project structure trees.
- **Harness Reviewer persona** (`templates/personas/harness-reviewer.md`) -- dedicated self-review role for the harness itself, checking 7 dimensions: target detail leakage, prompt self-containment, documentation currency, template & persona consistency, isolation boundary integrity, governance completeness, and public-facing quality. Added to valid roles in CLAUDE.md, personas table in README, and project structure trees.
- **Target detail leakage enforcement** -- "no target details in harness files" rule added to Working Rules, covers git commit messages, references harness-reviewer as systematic enforcement mechanism
- **Post-onboarding domain deepening** -- new section in CLAUDE.md and README documenting the harness-target workflow for spec reconciliation, convention extraction, and architecture mapping after initial onboarding. Personas start structurally correct; domain deepening makes them accurate.
- **Retrospective prompt** -- onboarding playbook now generates a universal retrospective prompt as the final prompt in every sequence, capturing second-pass insight from the agent that just completed the work
- **Close-out gate** -- onboarding playbook enforces OQ review, retrospective, and review-history baseline before a target can be marked as "maintaining"
- **Explicit execution context rule** -- all prompts, instructions, and next steps must state WHERE they should be executed (AEH harness, target project Claude Code, or external LLM session). Prompt file format template now includes `Execute in:` field. Added to Working Rules in CLAUDE.md.
- **Structural hygiene audit** -- new assessment checklist items 8.9 (directory internal organisation) and 8.10 (agent-generated detritus detection). Reviewer persona gains mandatory "Structural Hygiene" review dimension (step 5) that catches filesystem clutter regardless of baseline. Health-check playbook gains step 3g: independent structural scan that applies fresh engineering judgment, not baseline comparison. Addresses the pattern where LLM agents create files prolifically and walk away.
- **Git history cleaned** -- removed target-identifying details from commit messages and historical file content using git-filter-repo
- **Agent permission governance** -- new `templates/agents/` directory for agent-specific reference knowledge, starting with Claude Code
- `templates/agents/README.md` -- explains agents vs tools vs governance, lists known agents
- `templates/agents/claude-code/permissions.md` -- full schema reference, file precedence, rule syntax, anti-pattern catalogue (CRITICAL→LOW), remediation patterns
- `templates/agents/claude-code/permission-detection-patterns.md` -- glob/grep patterns for auditing permission configs (secrets, bypass mode, filesystem escape, sprawl, stale rules, harness isolation breach)
- `templates/agents/claude-code/permission-baselines.md` -- three recommended configs (solo/team/open-source) as embeddable JSON blocks with rationale
- Assessment checklist **Category 10: Agent Permission Governance** -- 9 items covering settings hygiene, secrets, deny lists, sprawl, filesystem scope, and file separation
- Review criteria **Rubric 6: Agent Permission Quality** -- 6 criteria with signs of good governance and common problems
- **Mandatory permission review in reviewer persona** -- every review pass must include a Permission Health section in `comments.md`, never silently skipped
- **Harness isolation check** -- CRITICAL detection pattern verifying target agent cannot read from the AEH harness directory (AP-04)
- **Review history file** (`targets/<project>/review-history.md`) -- append-only longitudinal findings log for pattern detection across assessments, always includes permission snapshot
- Health-check **Phase 3h: Permission Health Check** -- reads settings files, runs detection patterns, compares against baseline
- Health-check **permission drift** as delta report category with dedicated Permission Health section in report format
- Onboarding Phase 2b step 9: permission file detection in reconnaissance search strategy
- Onboarding Phase 2c: "Permissions" line in summary output format
- `CLAUDE.md.template`: Permission Governance section with settings file documentation, baseline reference, and maintenance rules

### Changed
- Assessment checklist now has 10 categories (was 9)
- Review criteria now has 6 rubrics (was 5), plus "Agent permissions" row in Overall Assessment table
- Health-check remediation option 3 includes permission fixes
- Health-check Phase 5 references permission baselines for drift remediation
- Health-check phase completion appends to `review-history.md` (append-only longitudinal record)
- Onboarding Phase 3e workspace creation includes `review-history.md`
- CLAUDE.md project structure tree includes `templates/agents/` and `review-history.md`
- README project structure tree includes `templates/agents/`

---

## [v0.5] - 2026-02-20

### Added
- **AGPL-3.0 license** with `LICENSE-FAQ.md` clarifying that AEH output (personas, prompts, CLAUDE.md sections) belongs to the user and is unencumbered
- **CONTRIBUTING.md** -- prompt-first contribution model (submit the LLM prompt that produces the change, not just the diff), BDFL maintenance model, clear expectations for response times and scope
- Community infrastructure: Discord + GitLab Issues, sponsor links (GitHub Sponsors, Polar.sh)
- License badge in README
- **Post-transformation regression check** (`templates/prompts/regression-check.md.template`) -- verifies builds, import integrity, config path references, and runtime behaviour after structural transformations. Auto-generated as the final prompt in every onboarding sequence. Also triggered in health-check remediation when fix prompts move or rename files.
- `templates/prompts/` directory for reusable prompt templates
- Onboarding Phase 6d generates a regression check prompt adapted to the target project
- Health-check Phase 5 generates a regression check when remediation moves files
- **Tool integration system** for optional MCP server management (OpenSpec, Context7, Serena)
- `templates/tools/` directory with setup and teardown prompt templates for each tool
- `templates/tools/README.md` -- overview and design principles for the tool integration system
- `templates/tools/tool-detection-patterns.md` -- glob/grep patterns for detecting tools and functional equivalents
- `templates/tools/openspec-setup.md` / `openspec-teardown.md` -- OpenSpec MCP server configuration
- `templates/tools/context7-setup.md` / `context7-teardown.md` -- Context7 MCP server configuration
- `templates/tools/serena-setup.md` / `serena-teardown.md` -- Serena MCP server configuration
- `tools` playbook (`templates/playbooks/tools.md`) -- 5-phase workflow for tool detection, offering, setup/teardown, and recording
- Assessment checklist Category 8: "Project Layout & Naming Hygiene" -- directory structure, file naming, redundant/misplaced/obsolete files, documentation taxonomy
- Assessment checklist Category 9: "Development Tooling (Optional)" -- informational only, never penalises absence (renumbered from 8)
- Review criteria Rubric 5: "Tool Integration Quality (Optional)" -- scored only when tools are actively configured
- Health-check step 3g: Tool Health Check -- verifies configured tools are still present, documented, and consistent
- Health-check tool drift category in delta reports
- Onboarding Phase 2b: MCP and tool detection patterns in reconnaissance search strategy
- Onboarding Phase 6d: informational mention of `tools` after harness setup
- `CLAUDE.md.template`: optional "Development Tools" section with subsection templates for all three tools

### Fixed
- Session init now requires user confirmation before adopting a carried-over persona. Previously, a role persisted from the last session was adopted silently. Updated in harness CLAUDE.md and `CLAUDE.md.template`.

### Changed
- README expanded with Community, Supporting AEH, and License sections
- Onboarding Phase 2b detection targets table expanded with MCP, tool, and spec management rows
- Health-check Phase 4 delta report includes tool drift as a category
- Health-check Phase 5 remediation option 3 now includes tool repair
- CLAUDE.md playbooks table and role commands table include `tools`
- CLAUDE.md project structure tree updated with `templates/tools/` and `tools.md` playbook
- README updated with tool integration in features list, workflow diagram, project structure, and current status
- **Nested private repo for `targets/`** -- recommended setup for keeping private target workspaces versioned independently from the public harness repo
- CLAUDE.md documents dual-repo commit/push rules, detection, and proactive setup offering
- Onboarding Phase 3e offers nested repo setup during first workspace creation
- README documents the pattern under "Managing Target Workspace History"
- `docs/screenshots/` convention for transient human-Claude screenshot exchange (gitignored, timestamp-based)

### Removed
- `.gitlab-ci.yml` -- CI guard for target data leaks was non-functional without runners (GitLab Free tier). The `.gitignore` + nested repo structure provides sufficient protection.

---

## [v0.4] - 2026-02-17

### Added
- Strategist persona template (`templates/personas/strategist.md`) for upstream business/strategic decision support in external LLM sessions
- Maturity model in README (5 levels from assessment-only to strategic layer)
- "Who Is This For", "Quick Start", and "Current Status" sections in README
- CHANGELOG.md
- Harness Maintenance Discipline section in CLAUDE.md
- CLAUDE.md section ordering checks: assessment checklist item 2.8, review criteria "Section ordering" criterion, health-check step 3e, onboarding Phase 3b note
- Specialist prompt collection step in onboarding playbook (Phase 2d): asks users for domain-specific prompts they've been pasting manually, merges them into persona adaptations
- Domain expertise adaptation guidance in generic reviewer template, with worked example reference

### Changed
- README rewritten for public audience (cleaner structure, less internal jargon)
- Project abbreviated as AEH throughout public-facing docs
- Persona count updated from "four" to "four engineering + optional strategist" across CLAUDE.md, README, onboarding playbook
- Onboarding playbook Phase 7: light strategist mention in handoff
- `role info` output now includes strategist as optional external role
- `CLAUDE.md.template`: session init added as second section (after Project Overview), with note that section ordering matters

### Fixed
- `CLAUDE.md.template` had no session init section at all -- added it in the correct position (top of file)
- `targets/*/` now gitignored -- private project data no longer pushed to remote. Only `targets/index.md` (empty registry template) is tracked.
- Strategist template updated to two-document model: stable role definition + frequently-regenerated project knowledge briefing. Includes staleness guidance.

## [v0.3] - 2026-02-17

### Added
- Onboarding playbook (`templates/playbooks/onboarding.md`) -- 7-phase guided workflow with skip gates and re-onboarding detection
- Health-check playbook (`templates/playbooks/health-check.md`) -- recurring compliance checks with delta reports
- Assessment-implementation boundary in CLAUDE.md: onboarding never touches application code
- Merge-and-confirm rule for prompts that modify existing instruction files
- Session init and role selection (persona persistence, 3-line banner, `switch`, `role info`, `ignore role`)
- `onboard` and `health` natural language commands with playbook references

### Changed
- README updated with playbook workflow and new principles

## [v0.2] - 2026-02-15

### Added
- Two-Claude Model: harness reads and plans, target executes
- Target project isolation rule (hard boundary, one narrow exception for prompt delivery)
- `targets/` workspace structure with per-project directories
- `targets/index.md` as orientation entry point
- Prompt file format (self-contained, numbered, ordered)
- Five transformation phases: assessment, planning, implementing, reviewing, maintaining
- Direct prompt delivery policy (per-project opt-in)

### Changed
- Replaced `logs/` with `targets/` as canonical per-project state location

## [v0.1] - 2026-02-15

### Added
- Initial persona templates: Analyst, Architect, Developer, Reviewer
- Project templates: `CLAUDE.md.template`, `agents.md.template`
- Governance criteria: assessment checklist, review criteria
- Structured reference from "How I Tamed Claude" (NDC London 2026)
- CLAUDE.md with mission, working rules, and project structure
- README with problem statement, solution, and core principles
