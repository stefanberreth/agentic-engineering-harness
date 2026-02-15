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
| 4.1 | Analyst system prompt exists (or N/A if greenfield is done) | | |
| 4.2 | Architect system prompt exists | | |
| 4.3 | Developer system prompt exists | | |
| 4.4 | Reviewer system prompt exists | | |
| 4.5 | Prompts reference project-specific tech stack | | |
| 4.6 | Prompts encode project-specific conventions | | |

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

## Summary

**Overall readiness:** [Not Ready / Partially Ready / Ready with Gaps / Ready]

**Priority actions (top 3):**
1. [Highest-impact item to create or fix]
2. [Second priority]
3. [Third priority]

**Estimated transformation effort:** [Light (1-2 sessions) / Medium (3-5 sessions) / Heavy (5+ sessions)]
