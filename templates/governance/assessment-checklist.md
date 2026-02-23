# Agentic Readiness Assessment Checklist

Use this checklist to evaluate an existing software project's readiness for agentic engineering and to identify what needs to be created or adapted.

## Instructions

For each item, mark one of:
- **Present** -- exists and is adequate
- **Partial** -- exists but needs improvement
- **Missing** -- does not exist, needs to be created
- **N/A** -- not applicable to this project

---

## 1. Project Foundation

| # | Item | Status | Notes |
|---|---|---|---|
| 1.1 | `README.md` exists and describes the project | | |
| 1.2 | Build/run/test instructions are documented and work | | |
| 1.3 | `.gitignore` is present and sensible | | |
| 1.4 | Project can be built from a clean clone | | |
| 1.5 | Dependencies are managed via a lockfile | | |

## 2. Agent Configuration

| # | Item | Status | Notes |
|---|---|---|---|
| 2.1 | `CLAUDE.md` exists at project root | | |
| 2.2 | `.claude/` directory exists and is in source control | | |
| 2.3 | `agents.md` exists (cross-tool compatibility) | | |
| 2.4 | Build commands are documented in `CLAUDE.md` | | |
| 2.5 | Code style rules are documented or referenced | | |
| 2.6 | Architecture is described or referenced | | |
| 2.7 | Context management guidance is included | | |
| 2.8 | Session init instructions (if any) are in the first 50 lines of CLAUDE.md | | |

## 3. Specification & Planning

| # | Item | Status | Notes |
|---|---|---|---|
| 3.1 | `requirements.md` exists | | |
| 3.2 | `spec.md` exists with architecture + implementation plan | | |
| 3.3 | Tasks are broken into branch-sized units | | |
| 3.4 | Each task has acceptance criteria | | |
| 3.5 | Task dependencies are documented | | |
| 3.6 | `tasks.md` or equivalent tracking exists | | |

## 4. Persona Readiness

| # | Item | Status | Notes |
|---|---|---|---|
| 4.1 | Analyst system prompt exists | | |
| 4.2 | Architect system prompt exists | | |
| 4.3 | Developer system prompt exists | | |
| 4.4 | Reviewer system prompt exists | | |
| 4.5 | Prompts reference project-specific tech stack | | |
| 4.6 | Prompts encode project-specific conventions | | |
| 4.7 | Every role advertised in session banner has a matching persona file | | |

## 5. Development Practice

| # | Item | Status | Notes |
|---|---|---|---|
| 5.1 | Test suite exists and passes | | |
| 5.2 | Test coverage is measured | | |
| 5.3 | Linter/formatter is configured and enforced | | |
| 5.4 | CI pipeline exists | | |
| 5.5 | Branch strategy is defined | | |
| 5.6 | Commit message conventions are documented | | |

## 6. Restartability

| # | Item | Status | Notes |
|---|---|---|---|
| 6.1 | A fresh Claude session can orient itself by reading `CLAUDE.md` → `spec.md` → `tasks.md` | | |
| 6.2 | Current task state is tracked in a file (not just in conversation history) | | |
| 6.3 | No critical information exists only in previous Claude sessions | | |
| 6.4 | Feature branches are committed and pushed regularly | | |
| 6.5 | Retrospective reports capture lessons from completed tasks | | |

## 7. Governance

| # | Item | Status | Notes |
|---|---|---|---|
| 7.1 | Review process is defined (who reviews, what criteria) | | |
| 7.2 | Spec revision process exists (how to handle feedback from retrospectives) | | |
| 7.3 | Quality criteria for agentic config files are defined | | |
| 7.4 | Permissions and safety boundaries are documented | | |

---

## 8. Project Layout & Naming Hygiene

| # | Item | Status | Notes |
|---|---|---|---|
| 8.1 | Directory structure follows a consistent organisational principle | | |
| 8.2 | File naming conventions are consistent (casing, separators, prefixes) | | |
| 8.3 | No redundant files with different names covering the same content | | |
| 8.4 | No files placed in wrong directories (e.g. root clutter, misplaced docs) | | |
| 8.5 | Obsolete/superseded files are archived or removed, not left in-place | | |
| 8.6 | Documentation directory structure matches a clear taxonomy (not ad-hoc) | | |
| 8.7 | No orphaned redirect/stub files pointing to moved or deleted content | | |
| 8.8 | Config files are consolidated (not scattered across root and subdirectories) | | |
| 8.9 | Key directories are internally well-organised (not used as dump bins) | | Check `scripts/`, `docs/`, `config/`, `tests/` etc. -- not just whether files are in the right directory, but whether each directory is coherent. Flag: one-off debugging scripts mixed with production utilities, duplicate configs copied into wrong dirs, SQL dumps alongside shell scripts. |
| 8.10 | No agent-generated detritus left behind | | LLM agents generate files prolifically and forget them: ad-hoc test scripts, debug helpers, analysis outputs, session notes, temporary SQL, unused config variants. Check for files that smell like single-use agent output: `debug-*.js`, `check-*.js`, `fix-*.js`, `test-*.js` (not in a test suite), `*-analysis.*`, `*-check.*`, dump files, and any file not imported/referenced by the build or documentation. |

---

## 9. Development Tooling (Optional)

> This category is **informational only**. Tool absence is not a deficiency -- it simply
> records what is present. No items here affect the overall readiness rating.

| # | Item | Status | Notes |
|---|---|---|---|
| 9.1 | `.mcp.json` exists and is well-formed | | |
| 9.2 | MCP servers documented in CLAUDE.md (if any configured) | | |
| 9.3 | OpenSpec: directory structure and MCP config present | | |
| 9.4 | Context7: MCP config present with valid transport | | |
| 9.5 | Serena: `.serena/project.yml` present and matches tech stack | | |
| 9.6 | Functional equivalents: ADR/RFC/spec management exists | | |
| 9.7 | Functional equivalents: alternative doc/code intelligence servers | | |
| 9.8 | Tool configuration consistent (`.mcp.json` entries match CLAUDE.md documentation) | | |

---

## 10. Agent Permission Governance

| # | Item | Status | Notes |
|---|---|---|---|
| 10.1 | Settings files exist and are intentionally configured (not just accumulated defaults) | | |
| 10.2 | No secrets, passwords, or API keys embedded in permission rules | | |
| 10.3 | Deny list blocks sensitive files (`.env`, credentials, SSH keys, `*.pem`, `*.key`) | | |
| 10.4 | Allow list uses consolidated wildcard patterns (not sprawled one-off rules from "yes, don't ask again") | | |
| 10.5 | Permission rules reference only paths and files that currently exist in the project | | |
| 10.6 | `defaultMode` is appropriate for the project's risk profile (solo vs team vs public) | | |
| 10.7 | Shared settings (`.claude/settings.json`) are version-controlled if present | | |
| 10.8 | Local settings (`.claude/settings.local.json`) are gitignored | | |
| 10.9 | Agent cannot read or write outside the project directory tree (filesystem scope enforcement) | | |

---

## Summary

**Overall readiness:** [Not Ready / Partially Ready / Ready with Gaps / Ready]

**Priority actions (top 3):**
1. [Highest-impact item to create or fix]
2. [Second priority]
3. [Third priority]

**Estimated transformation effort:** [Light (1-2 sessions) / Medium (3-5 sessions) / Heavy (5+ sessions)]
