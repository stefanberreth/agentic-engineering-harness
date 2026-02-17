# Changelog

All notable changes to AEH (Agentic Engineering Harness) are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). This project does not yet use semantic versioning -- versions are sequential milestones (v0.1, v0.2, etc.) reflecting capability growth.

---

## [v0.4] - 2026-02-17

### Added
- Strategist persona template (`templates/personas/strategist.md`) for upstream business/strategic decision support in external LLM sessions
- Adapted strategist briefing for compression-poc-02 (`targets/compression-poc-02/deliverables/strategist.md`)
- Context sync protocol reference document (`targets/compression-poc-02/deliverables/context-sync-protocol.md`)
- Maturity model in README (5 levels from assessment-only to strategic layer)
- "Who Is This For" and "Quick Start" sections in README
- "Current Status" section with honest assessment of what works and what's evolving
- This CHANGELOG

### Changed
- README rewritten for public audience (cleaner structure, less internal jargon)
- Project abbreviated as AEH throughout public-facing docs
- Persona count updated from "four" to "four engineering + optional strategist" across CLAUDE.md, README, onboarding playbook
- Onboarding playbook Phase 7: light strategist mention in handoff
- `/role info` output now includes strategist as optional external role

## [v0.3] - 2026-02-17

### Added
- Onboarding playbook (`templates/playbooks/onboarding.md`) -- 7-phase guided workflow with skip gates and re-onboarding detection
- Health-check playbook (`templates/playbooks/health-check.md`) -- recurring compliance checks with delta reports
- Assessment-implementation boundary: onboarding never touches application code
- Merge-and-confirm rule for prompts that modify existing instruction files
- Session init and role selection (persona persistence via `.claude/persona`, 3-line banner)
- `/onboard`, `/health`, `/switch`, `/role info`, `/ignore` natural language commands
- Orchestration prompt (000-run-all-foundation.md) for compression-poc-02
- Developer persona deliverable for compression-poc-02
- Prompt 009 for fixing pre-existing test failures in compression-poc-02

### Changed
- All 7 existing prompts for compression-poc-02 reviewed and fixed (2 HIGH, 5 MEDIUM issues)
- README updated with playbook workflow, new principles, v0.3 evolution entry
- targets/index.md updated with post-execution status

### Fixed
- Prompt 004: replaced `git add -A _ai/` with explicit file paths
- Prompt 005: inlined audit checklist instead of referencing CLAUDE.md section by name
- Prompt 006: added operator placeholder for issue scoping
- Prompt 007: added concrete reviewer persona delivery instructions

## [v0.2] - 2026-02-15

### Added
- Two-Claude Model: harness reads and plans, target executes
- Target project isolation rule (hard boundary, one narrow exception for prompt delivery)
- `targets/` workspace structure with per-project directories
- `targets/index.md` as orientation entry point
- Prompt file format (self-contained, numbered, ordered)
- Five transformation phases: assessment, planning, implementing, reviewing, maintaining
- Direct prompt delivery policy (per-project opt-in)
- Full assessment of compression-poc-02 (7 categories, 30 items, 18 inconsistencies)
- Transformation plan for compression-poc-02 (16 tasks across 5 phases)
- Reviewer persona deliverable for compression-poc-02
- Prompts 001-008 for compression-poc-02

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
