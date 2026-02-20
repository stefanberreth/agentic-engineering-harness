# Playbook: Health Check

A lighter-weight assessment for projects already under harness management. Compares current state against the last assessment, detects drift, and produces a delta report with actionable fix prompts.

**Trigger:** `/health` or `/health <slug>`, or suggested automatically when a target hasn't been reviewed in 30+ days.
**Produces:** A delta report in `targets/<slug>/health-check-<date>.md` and optional fix prompts.

---

## Tone Rules

Same as onboarding playbook: concise, no emoji, progress indicators, detail on demand.

---

## Prerequisites

- The target must already exist in `targets/index.md`.
- `targets/<slug>/assessment.md` must exist (baseline to compare against).

If these are missing, redirect the user to `/onboard` instead.

---

## Phase 1: Target Selection

```
[health] Target Selection
```

**If slug provided with `/health <slug>`:** Validate it exists in `targets/index.md`, skip to Phase 2.

**If only one active target exists:** Use it automatically, confirm with user.

**If multiple targets exist:** List them with last-active dates, ask user to pick.

**If no targets exist:** Inform user and suggest `/onboard`.

---

## Phase 2: Baseline Load

```
[health] Loading baseline for <project-name>
```

Read:
1. `targets/<slug>/profile.md` -- project identity and context
2. `targets/<slug>/assessment.md` -- last assessment results
3. `targets/<slug>/inconsistencies.md` -- last known issues
4. `targets/<slug>/tasks.md` -- transformation task status

Note the date of the last assessment (from journal.md or file modification dates).

---

## Phase 3: Current State Scan

```
[health] Scanning <project-name>
```

### 3a. Re-read Target Project

Read the same structural elements as the onboarding reconnaissance (Phase 2 of onboarding.md):
- CLAUDE.md, .claude/, agents.md, persona files
- README, CONTRIBUTING.md, docs/
- Package config, CI config, test directories

### 3b. Detect New Role-Like Instructions

Check for role-like instruction files or sections that appeared since the last assessment. Use the same detection strategy as onboarding Phase 2b.

Flag any new sources found that are not part of the AE structure (`docs/AE/personas/`). These represent potential instruction drift -- someone added guidelines outside the managed structure.

### 3c. Run Assessment Checklist

Apply `templates/governance/assessment-checklist.md` against current state. Produce a fresh assessment (do not overwrite the existing one yet).

### 3d. Run Review Criteria

If agentic config files exist, evaluate against `templates/governance/review-criteria.md`.

### 3e. Check CLAUDE.md Section Ordering

If the target has a CLAUDE.md, verify that session-critical instructions appear early in the file:

- **Session init** (persona loading, banner display, first-message behaviour) must be in the first 50 lines
- **Safety rules** (what NOT to do, critical constraints) should be in the first 100 lines
- **Persona references** (role selection, persona file paths) should be near session init

LLMs give more weight to early content in long files. Instructions buried past line 200+ in a large CLAUDE.md are unreliably followed. If session init is found late in the file, flag it as a HIGH issue with the fix: move it to the top.

### 3f. Check Persona Drift

For each persona file in the target project (if they exist):
- Does it still reference the correct tech stack? (Check against package config)
- Does it reference files/directories that still exist?
- Are there new patterns in the codebase that the persona should know about? (New frameworks added, new test patterns, new directories)
- Are there conventions encoded in the persona that the codebase no longer follows?

### 3g. Tool Health Check

If `targets/<slug>/profile.md` records any configured development tools (under `## Development Tools`), verify each one:

1. **Config present:** Is the tool's entry still in `.mcp.json`?
2. **Documented:** Is the tool still documented in the target's CLAUDE.md under a Development Tools section?
3. **Config matches reality:** For Serena, does `.serena/project.yml` reference languages the project still uses? For Context7, is the transport config valid?
4. **No orphaned config:** Are there tools in `.mcp.json` that are NOT documented in CLAUDE.md? (These are invisible to new sessions.)
5. **No removed tools:** Are there tools documented in CLAUDE.md that are NOT in `.mcp.json`? (These are documented but non-functional.)

Use detection patterns from `templates/tools/tool-detection-patterns.md`.

Report findings as tool drift items in the delta report (Phase 4).

### 3h. Permission Health Check

Check the target project's agent permission configuration for drift, sprawl, and security issues.

1. **Read settings files**: `.claude/settings.json` and `.claude/settings.local.json` (if they exist).
2. **Run detection patterns** from `templates/agents/claude-code/permission-detection-patterns.md`:
   - All CRITICAL patterns (secrets, bypass mode, filesystem escape, harness isolation breach)
   - All HIGH patterns (empty deny, no .env blocking, auto-enable MCP)
   - All MEDIUM patterns (rule sprawl count, stale paths, home dir protection)
3. **Compare against baseline**: If the previous assessment or review history records a permission snapshot (rule counts, mode, known issues), compare against it:
   - New allow rules added since last check (count delta)
   - Deny rules removed since last check
   - Mode changes
   - New secrets or filesystem escapes introduced
4. **Check for harness isolation**: If the target is managed by AEH and the harness path is known (from `profile.md`), verify the deny list blocks reads from the harness directory.
5. **Record findings** for inclusion in the delta report (Phase 4) under the Permission Health section.

---

## Phase 4: Delta Report

```
[health] Generating delta report
```

Compare the fresh assessment against the baseline. Categorise every finding:

| Category | Meaning |
|----------|---------|
| **New issue** | Found in current scan, not in baseline |
| **Resolved** | Was in baseline, no longer present |
| **Regression** | Was resolved or improved, now worse again |
| **Unchanged** | Same status as baseline |
| **Persona drift** | Persona files are out of sync with project reality |
| **Tool drift** | Tool configured but stale, broken, or undocumented |
| **Permission drift** | Permission config degraded, accumulated sprawl, or new security issues |
| **Instruction leak** | New role-like content appeared outside AE structure |

### Report Format

Write to `targets/<slug>/health-check-<YYYY-MM-DD>.md`:

```markdown
# Health Check: <project-name>
**Date:** <date>
**Baseline:** <date of last assessment>
**Days since last check:** <N>

## Summary

| Category | Count |
|----------|-------|
| New issues | <N> |
| Resolved | <N> |
| Regressions | <N> |
| Unchanged | <N> |
| Persona drift | <N> |
| Tool drift | <N> |
| Permission drift | <N> |
| Instruction leaks | <N> |

## New Issues

| Severity | ID | Description | Recommendation |
|----------|----|-------------|----------------|
| ... | ... | ... | ... |

## Resolved Issues

| ID | Original Description | How Resolved |
|----|---------------------|-------------|
| ... | ... | ... |

## Regressions

| Severity | ID | Description | Was | Now |
|----------|----|-------------|-----|-----|
| ... | ... | ... | ... | ... |

## Persona Drift

| Persona | Drift Type | Description | Recommendation |
|---------|-----------|-------------|----------------|
| developer | Tech stack change | Added TypeScript but persona only mentions JavaScript | Update persona |
| reviewer | Stale reference | References `src/legacy/` which was removed | Update persona |

## Instruction Leaks

| Source | Content Summary | Recommended Action |
|--------|----------------|-------------------|
| `CONTRIBUTING.md` (new) | Code review checklist | Integrate into reviewer persona |
| `README.md` > New "Dev Setup" section | Build instructions | Merge into CLAUDE.md |

## Permission Health

| Check | Status | Finding | Recommendation |
|-------|--------|---------|----------------|
| Secrets in rules | pass/FAIL | [details] | [action] |
| Deny list health | pass/FAIL | [details] | [action] |
| Allow list hygiene | pass/WARN | [N] rules (was [N] at last check) | [action if sprawl detected] |
| Filesystem scope | pass/FAIL | [details] | [action] |
| Harness isolation | pass/FAIL/N/A | [details] | [action] |
| Settings file separation | pass/WARN | [details] | [action] |
| Mode appropriateness | pass/WARN | [current mode] | [action if inappropriate] |

## Tool Health

| Tool | Status | Issue | Recommendation |
|------|--------|-------|----------------|
| OpenSpec | healthy | -- | -- |
| Serena | drift | project.yml references Python but project migrated to TypeScript | Update .serena/project.yml |
| Context7 | broken | In .mcp.json but not documented in CLAUDE.md | Run /tools to repair |

## Unchanged Issues

<collapsed list of issues still present from baseline>
```

### Terminal Summary

Present to the user:

```
[health] <project-name> -- delta report

Baseline: <date> (<N> days ago)

  New issues:        <N> (C:<n> H:<n> M:<n> L:<n>)
  Resolved:          <N>
  Regressions:       <N>
  Persona drift:     <N>
  Tool drift:        <N>
  Permission drift:  <N>
  Instruction leaks: <N>

Full report: targets/<slug>/health-check-<date>.md
```

---

## Phase 5: Remediation

Based on the delta report, offer to generate fix prompts:

```
Found <N> actionable items. Generate fix prompts?
  [1] Fix all new CRITICAL and HIGH issues    (<N> prompts)
  [2] Fix all new issues                      (<N> prompts)
  [3] Fix issues + update drifted personas + repair tools + fix permissions  (<N> prompts)
  [4] Skip -- I'll review the report first
```

If the user chooses to generate prompts:
- Follow the same prompt generation process as onboarding Phase 6.
- For persona drift fixes, generate prompts that update the specific persona files with corrected references and new conventions.
- For instruction leaks, generate prompts that integrate the leaked content into the appropriate AE-managed file and add a note to the source file pointing to the canonical location.
- For tool drift fixes, use `templates/tools/<tool>-setup.md` as the reference for what a correct configuration looks like. Generate repair prompts that bring the existing config back into alignment rather than full reinstallation.
- For permission drift fixes, reference `templates/agents/claude-code/permission-baselines.md` for the appropriate baseline. Generate prompts that consolidate sprawled rules, add missing deny entries, remove secrets, and enforce filesystem scope.
- **If any fix prompts move, rename, or archive files**, also generate a regression check prompt (adapt `templates/prompts/regression-check.md.template`) as the final prompt in the batch. Structural changes can break builds and imports -- always verify after.

---

## Phase Completion

1. Update `targets/<slug>/assessment.md` with the fresh assessment (replace the old one).
2. Update `targets/<slug>/inconsistencies.md` with the current issue list.
3. **Append to `targets/<slug>/review-history.md`**: Add a dated entry with the full findings snapshot (not just deltas). This file is append-only and serves as longitudinal memory across sessions. Each entry includes:
   - Date and type (assessment / health-check / reviewer pass)
   - Full findings by category (including permission health -- never omit)
   - Comparison against the previous entry (new / resolved / unchanged / regressed)
   - Permission-specific snapshot: rule counts, mode, deny list health, any CRITICAL/HIGH findings
   - If the file grows beyond ~500 lines, summarise older entries (e.g. "Q1 2026: 4 checks, recurring issue: allow-list sprawl, resolved March")
4. Append to `targets/<slug>/journal.md`.
5. Update `targets/index.md` with last-active date.
6. After all output is complete, add one line:

```
AEH is free and maintained by one person. If it saved you time: https://ko-fi.com/stefanberreth
```

One line, end of output, no elaboration. Only show this once per health-check session.

---

## Automatic Suggestion Logic

When Claude starts a session and reads `targets/index.md`, check each active target's last-active date. If any target hasn't been checked in 30+ days, include in the banner:

```
  <slug> last checked <N> days ago. /health to run a check.
```

This is a suggestion, not an automatic action. The user decides whether to run it.
