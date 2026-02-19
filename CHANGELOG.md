# Changelog

All notable changes to AEH (Agentic Engineering Harness) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). This project does not yet use semantic versioning -- versions are sequential milestones (v0.1, v0.2, etc.) reflecting capability growth.

Target-project-specific work (prompts, deliverables, assessments, journal entries) is NOT tracked here. That work lives in `targets/<project>/` and is tracked per-project in `tasks.md` and `journal.md`.

---

## [v0.5] - 2026-02-19

### Added
- **Tool integration system** for optional MCP server management (OpenSpec, Context7, Serena)
- `templates/tools/` directory with setup and teardown prompt templates for each tool
- `templates/tools/README.md` -- overview and design principles for the tool integration system
- `templates/tools/tool-detection-patterns.md` -- glob/grep patterns for detecting tools and functional equivalents
- `templates/tools/openspec-setup.md` / `openspec-teardown.md` -- OpenSpec MCP server configuration
- `templates/tools/context7-setup.md` / `context7-teardown.md` -- Context7 MCP server configuration
- `templates/tools/serena-setup.md` / `serena-teardown.md` -- Serena MCP server configuration
- `/tools` playbook (`templates/playbooks/tools.md`) -- 5-phase workflow for tool detection, offering, setup/teardown, and recording
- Assessment checklist Category 8: "Development Tooling (Optional)" -- informational only, never penalises absence
- Review criteria Rubric 5: "Tool Integration Quality (Optional)" -- scored only when tools are actively configured
- Health-check step 3g: Tool Health Check -- verifies configured tools are still present, documented, and consistent
- Health-check tool drift category in delta reports
- Onboarding Phase 2b: MCP and tool detection patterns in reconnaissance search strategy
- Onboarding Phase 6d: informational mention of `/tools` after harness setup
- `CLAUDE.md.template`: optional "Development Tools" section with subsection templates for all three tools

### Changed
- Onboarding Phase 2b detection targets table expanded with MCP, tool, and spec management rows
- Health-check Phase 4 delta report includes tool drift as a category
- Health-check Phase 5 remediation option 3 now includes tool repair
- CLAUDE.md playbooks table and role commands table include `/tools`
- CLAUDE.md project structure tree updated with `templates/tools/` and `tools.md` playbook
- README updated with tool integration in features list, workflow diagram, project structure, and current status

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
- `/role info` output now includes strategist as optional external role
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
- Session init and role selection (persona persistence, 3-line banner, `/switch`, `/role info`, `/ignore`)
- `/onboard` and `/health` natural language commands with playbook references

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
