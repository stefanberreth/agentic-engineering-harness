# Playbook: Health Check

A lighter-weight assessment for projects already under harness management. Compares current state against the last assessment, detects drift, and produces a delta report with actionable fix prompts.

**Trigger:** `health` or `health <slug>`, or suggested automatically when a target hasn't been reviewed in 30+ days.
**Produces:** A delta report in `targets/<slug>`health`-check-<date>.md` and optional fix prompts.

---

## Tone Rules

Same as onboarding playbook: concise, no emoji, progress indicators, detail on demand.

---

## Prerequisites

- The target must already exist in `targets/index.md`.
- `targets/<slug>/assessment.md` must exist (baseline to compare against).

If these are missing, redirect the user to `onboard` instead.

---

## Phase 1: Target Selection

```
[health] Target Selection
```

**If slug provided with `health <slug>`:** Validate it exists in `targets/index.md`, skip to Phase 2.

**If only one active target exists:** Use it automatically, confirm with user.

**If multiple targets exist:** List them with last-active dates, ask user to pick.

**If no targets exist:** Inform user and suggest `onboard`.

---

## Phase 2: Baseline Load

```
[health] Loading baseline for <project-name>
```

Read:
1. `targets/<slug>/profile.md` -- project identity and context
2. `targets/<slug>/assessment.md` -- last assessment results, incl. its `## Inconsistency Report` section (last known issues)
3. `targets/<slug>/tasks.md` -- transformation task status
4. `targets/<slug>/journal.md` -- `[DECISION]` / `[REVIEW]` history and last-session context

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

### 3f. Review Cadence Health

Check whether reviewer cadence has been maintained since the last assessment:

1. Read the target's `orchestrator-state.md` (if it exists). Look for the Review Tracking section:
   - `last_reviewed_task` — what was the last task that received a formal reviewer pass?
   - `current_gap` — how many developer tasks since the last review?
   - `reviews_completed` / `reviews_with_corrections` — ratio of reviews to correction rounds
2. If `current_gap >= 5` (Regime 1) or a phase was signed off without a reviewer pass: flag as **HIGH** — review debt has accumulated.
3. If no Review Tracking section exists in `orchestrator-state.md`: flag as **MEDIUM** — the target-orchestrator state predates the cadence enforcement upgrade. Add the section.
4. If no `orchestrator-state.md` exists: this target has not been managed by the target-orchestrator. Not a finding — just note it.

**Review cadence health checks:**

| Check | Status | Finding |
|-------|--------|---------|
| Review Tracking section present | pass/WARN | |
| Review gap within cadence (< 5) | pass/HIGH | gap = N |
| All phases have reviewer PASS/WARN | pass/HIGH | phase N unsigned |
| Review-to-correction ratio | info | N reviews, M corrections |

### 3g. Check Persona Drift

For each persona file in the target project (if they exist):
- Does it still reference the correct tech stack? (Check against package config)
- Does it reference files/directories that still exist?
- Are there new patterns in the codebase that the persona should know about? (New frameworks added, new test patterns, new directories)
- Are there conventions encoded in the persona that the codebase no longer follows?

### 3h. Structural Hygiene Scan (Independent)

**This scan does NOT compare against the baseline.** It applies fresh engineering judgment to the current filesystem, regardless of what previous assessments found or missed. The baseline is irrelevant here -- if the project looks cluttered to a staff engineer, it's cluttered.

1. **List root directory contents.** Flag anything that isn't standard project infrastructure (package.json, tsconfig, vite/webpack config, CI config, README, CLAUDE.md, .gitignore, .env.example, lockfiles). One-off scripts, data files, SQL, stale configs, and orphaned docs in root are all findings.

2. **Audit key directories internally.** For each of `scripts/`, `tools/`, `utils/`, `docs/`, `config/`, and any other multi-file utility directory:
   - Count the files. More than 20 files in a utility directory warrants closer inspection.
   - Check for agent-generated detritus: `debug-*`, `check-*`, `fix-*`, `trace-*`, `test-*` (not in a test suite), `*-analysis.*`, `*-dump.*`, session management scripts, duplicate configs copied from root.
   - Check for files that are clearly one-off (SQL queries, data dumps, ad-hoc scripts) mixed with production utilities.

3. **Check for orphaned directories.** Directories with no files, only a README, or containing only outdated content that should have been archived.

4. **Apply the smell test:** Would a senior engineer joining this project look at the filesystem and feel confident about its organisation? If not, flag what's wrong -- even if it was "resolved" in a previous assessment by being moved rather than cleaned.

Report findings as structural hygiene items in the delta report (Phase 4). These are always "New issues" regardless of baseline, because they represent current state, not drift from a previous state.

### 3i. Tool Health Check

**Standard-tool presence check (run first, independent of configured-tool status):**

OpenSpec and Context7 are AEH-standard SDLC tools (default in-scope per onboarding Phase 6g). Read `targets/<slug>/profile.md`:

1. **OpenSpec:** check `## Specification Management`. Expected: `policy: openspec`. Flag if:
   - `policy: TBD` → onboarding incomplete; recommend running `tools` to set it up
   - `policy: deferred` → operator postponed; check `journal.md` `[DECISION]` entries for context, recommend re-offer via `tools` if no explicit decline
   - `policy: manual (spec.md)` with no `[DECISION]` journal entry → looks like default-was-bypassed; recommend operator confirm the opt-out is deliberate
   - Section absent → onboarding gap; recommend `onboard` re-run or manual `tools` invocation
2. **Context7:** check `## Development Tools`. Expected: `context7: configured (cli-skills)` or `configured (mcp)`. Flag if:
   - `context7: TBD` → onboarding incomplete
   - `context7: in-scope (default)` → setup prompt was never run; onboarding did not complete its Phase 6j verification gate. Recommend running `tools` to finish the install, then verify.
   - `context7: deferred` → recommend re-offer
   - `context7: declined` with no `[DECISION]` journal entry → recommend operator confirm
   - Status absent → onboarding gap
   - `configured` but no `verified <date>` recorded → unverified claim; require the functional smoke test (below) before treating it as healthy

Standard-tool absence is a HIGH-severity finding when no `[DECISION]` journal entry records a deliberate opt-out, because the project is missing load-bearing engineering infrastructure (spec traceability + current library docs). When a `[DECISION]` entry records the opt-out, downgrade to informational.

**Context7 functional verification (mandatory part of the e2e gate -- not skippable when context7 is `configured`):** static presence is insufficient because the preferred CLI + Skills install is user-global and leaves nothing in the project tree. Confirm Context7 actually returns docs:
   - CLI + Skills mode: hand the operator `npx ctx7@latest library react "state hooks"` then `npx ctx7@latest docs /facebook/react "useState cleanup"` to run in the target session. Pass = the second command returns documentation content.
   - MCP mode: run the static checks below AND the MCP smoke test from `templates/tools/tool-detection-patterns.md`.
   A `configured` status with a failing or never-run smoke test is a HIGH finding: the tool is declared but not load-bearing. Record the verification result and date in the health report.

**Configured-tool health check (existing logic):**

If `targets/<slug>/profile.md` records any configured development tools (under `## Development Tools`), verify each one:

**Static checks:**

1. **Config present:** Is the tool's entry still in `.mcp.json`?
2. **Documented:** Is the tool still documented in the target's CLAUDE.md under a Development Tools section?
3. **Config matches reality:** For Serena, does `.serena/project.yml` reference languages the project still uses? For Context7 in MCP mode, is the transport config valid? For Context7 in CLI + Skills mode there is no `.mcp.json` entry -- it is verified by the functional smoke test above, not by config inspection (do not flag a missing `.mcp.json` entry as broken for a CLI + Skills install).
4. **No orphaned config:** Are there tools in `.mcp.json` that are NOT documented in CLAUDE.md? (These are invisible to new sessions.)
5. **No removed tools:** Are there tools documented in CLAUDE.md that are NOT in `.mcp.json`? (These are documented but non-functional.)

**Functional verification** (for each server in `.mcp.json`):

6. **Package resolution** (npx-based servers): Run `npm view <package> version 2>&1`. A 404 means the package does not exist and the server will fail on every invocation. Skip for non-npx servers (http, stdio with local binaries).
7. **Environment variable check:** Extract all `${VAR}` references from the server's config. Verify each is defined in `.env`, `.env.local`, or `.env.development`. Flag missing variables with severity based on whether they're documented elsewhere.
8. **Credential scan:** Grep the server's config block in `.mcp.json` for hardcoded secret patterns: common prefixes (`sk-`, `ctx7sk-`, `sbp_`, `ghp_`, `xoxb-`, `eyJ`), 32+ character alphanumeric strings not wrapped in `${...}`, and credentials embedded in URLs (`://user:pass@`).
9. **User-level config conflict:** Check `~/.claude.json` for `mcpServers` entries that duplicate or shadow servers configured in the project's `.mcp.json`. Flag any overlap.
10. **Connection status (operator verification):** If any of checks 6-9 raise concerns, flag the server for operator verification via the `/mcp` diagnostic screen. Note: the harness cannot run `/mcp` directly -- this is a manual check item for the operator.

Use detection patterns from `templates/tools/tool-detection-patterns.md` (both static detection and MCP Health Verification Patterns sections).

**Report format for Phase 4 Tool Health section:**

| Tool | Config | Documented | Package | Env Vars | Credentials | Status |
|------|--------|------------|---------|----------|-------------|--------|
| _name_ | present/missing | yes/no | ok / FAIL (404) / N/A | ok / WARN (missing) / N/A | clean / FAIL (hardcoded) | healthy / degraded / broken / orphaned |

Status values:
- `healthy` -- all checks pass
- `degraded` -- config present but env vars missing or minor warnings
- `broken` -- package does not exist (404) or server cannot start
- `orphaned` -- entry in user-level config but not in project `.mcp.json`, or vice versa

Report findings as tool drift items in the delta report (Phase 4).

### 3j. Permission Health Check

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

### 3k. OpenSpec Specification Health

**Only run when `openspec/specs/` exists in the target project.** If OpenSpec is not configured, skip this step entirely.

1. **Spec inventory:** Count spec files in `openspec/specs/` and proposals in `openspec/changes/`. Compare to baseline if a previous health check recorded counts. Flag significant growth or shrinkage.
2. **Frontmatter audit:** Read each spec file's frontmatter. Check for required fields: `id`, `title`, `status`, `created`, `updated`. Flag specs missing any of these.
3. **Staleness detection:** Flag active specs (status not `deprecated` or `superseded`) with an `updated` date more than 90 days old. These may be accurate but warrant verification.
4. **Abandoned proposals:** Check `openspec/changes/` for proposals that have `proposal.md` but are missing `design.md` or `tasks.md`. These are incomplete change proposals that were started but not finished.
5. **Spec-code drift (light):** For a sample of active specs, check whether the features they describe exist in the codebase (directory names, module names, API endpoints). Flag specs that describe things that clearly don't exist. This is a light check -- deep reconciliation belongs to the domain-deepening phase.

Report findings for inclusion in the delta report (Phase 4) under the Spec Health section.

### 3l. Role Activation Check

Verify that the layered-persona loading mechanism is intact -- a target-side role must be able to load both its base template and its overlay from within the target tree.

1. **Base templates present:** Check that `docs/AE/personas/_base/` exists and contains the role base templates (archaeologist, analyst, architect, developer, reviewer). Flag any missing base template.
2. **Overlay headers point target-side:** For each overlay in `docs/AE/personas/`, read the `AEH Base:` header line. It must point at the target-side path `docs/AE/personas/_base/<role>.md`. Flag any overlay whose header points at a harness path (`templates/personas/...`) or any other path outside the target tree.
3. **Loadability:** If the base directory exists with all role templates present and every overlay header points target-side, role activation is loadable. Otherwise flag the drift.

| Check | Status | Finding |
|-------|--------|---------|
| `docs/AE/personas/_base/` present with role templates | pass/FAIL | [N] base templates missing |
| Overlay headers point at `docs/AE/personas/_base/<role>.md` | pass/FAIL | [N] overlays point at a harness path |

Report findings as role-activation items in the delta report (Phase 4).

### 3m. Prompt Delivery Health

Verify that the target-orchestrator's prompt-handoff path actually works for this target — the target Claude session must be able to read every prompt the target-orchestrator hands off.

1. **Policy is `direct` (default):** Read `targets/<slug>/profile.md`. Expected: `Prompt delivery policy: direct`. Flag if:
   - Policy is `manual` AND `journal.md` has no `[DECISION]` entry justifying the opt-out → looks like a residual from when manual was an unguided option; recommend operator confirm the choice is deliberate (and accept the `cp`-before-handoff overhead) or switch to `direct`.
   - Policy is absent → onboarding gap; default-direct should be set.
2. **Mirror integrity:** For each prompt file in `targets/<slug>/prompts/`, check whether a corresponding file exists at `<target-path>/docs/AE/prompts/` with matching content. Flag any prompt that exists harness-side but is missing or stale target-side. This is the silent-mirror-failure check that catches the failure mode the operator hit during a 2026-05-30 brownfield onboarding: the target-orchestrator wrote source-of-truth but did not mirror, then handed off a path the target could not read.
   - Use a basic checksum / size comparison to flag stale mirrors (file exists target-side but content differs from the harness-side source of truth).
3. **No broken-on-arrival handoffs in recent journal entries:** grep `targets/<slug>/journal.md` and `targets/<slug>/orchestrator-state.md` for the anti-pattern `Read and execute targets/<slug>/prompts/` (or any absolute path beginning with `/workspace/aeh/` or `targets/`). Such entries are evidence of broken handoffs the operator likely had to correct manually. Flag with the journal-line cites so the operator can decide whether to back-fill mirrors or just note the friction.

**Report format:**

| Check | Status | Finding |
|-------|--------|---------|
| `Prompt delivery policy` is `direct` (or `manual` with a `[DECISION]` journal justification) | pass/FAIL | |
| Every harness-side prompt has a matching target-side mirror | pass/FAIL | [N] missing / [N] stale |
| No `Read and execute targets/...` or `/workspace/aeh/...` lines in recent journal/state | pass/FAIL | [N] anti-pattern occurrences |

Report findings as delivery-health items in the delta report (Phase 4). Missing-mirror findings are HIGH severity (broken handoffs the next time the target-orchestrator dispatches against this slug); broken-on-arrival anti-pattern occurrences are HIGH (target-orchestrator drift, will recur without intervention); manual-policy-without-justification is MEDIUM (working as configured but likely accidental).

### 3n. Harness Sync Marker

Verify the target's `profile.md` carries a `harness-sync-sha:` field so the target-orchestrator's session-init harness-update detection step has something to compare against.

1. **Field presence:** `grep -c "^harness-sync-sha:" targets/<slug>/profile.md`. Must be >= 1. Missing field = LOW finding ("seed via the retrofit prompt at templates/prompts/seed-harness-sync-marker.md.template").
2. **Field non-empty:** the SHA value must be a valid 40-char hex string. Empty or malformed = LOW finding.
3. **Field references a real harness commit:** `git -C /workspace/aeh cat-file -t $sync_sha 2>/dev/null` must return `commit`. Stale SHA (after harness history rewrite) = MEDIUM finding ("re-seed marker").
4. **Range size:** if the marker is more than 100 commits behind harness HEAD, surface as informational ("target has been out of sync for a long time; consider a propagation-impact review pass").

**Report format:**

| Check | Status | Finding |
|-------|--------|---------|
| `harness-sync-sha:` field present in profile.md | pass/FAIL | |
| Field value is a valid 40-char SHA | pass/FAIL | |
| SHA references a real harness commit | pass/FAIL | |
| Range is reasonable (< 100 commits) | pass/INFO | [N] commits behind |

Findings feed Phase 4 delta report. Missing marker is LOW (mechanism degrades gracefully without it; operator can seed retroactively). Stale-SHA-after-rewrite is MEDIUM (detection will misbehave until re-seeded).

### 3o. Cross-Container Ownership Marker

Verify the target's `.owner-container` marker is present and matches the current container (or surface for operator review if it doesn't).

1. **Marker presence:** `test -f targets/<slug>/.owner-container`. Missing = INFO ("marker not yet seeded; will seed on next target-orchestrator session-init via the new step-6 check").
2. **Owner hostname matches current container:** `bin/resolve-target-owner.sh --check <slug>` (exit 0 = match, exit 1 = peer container, exit 2 = absent).
   - Match: pass.
   - Peer container: MEDIUM ("last write was from peer container; verify intended ownership before continuing work in this container").
   - Absent: see check 1.
3. **Recency:** if `last-touched=` field is older than 30 days, surface as informational ("ownership marker is stale; consider running target-orchestrator session-init to refresh").

**Report format:**

| Check | Status | Finding |
|-------|--------|---------|
| `.owner-container` marker present | pass/INFO | |
| Owner hostname matches current container | pass/FAIL | [hostname mismatch details if fail] |
| Marker recency reasonable (< 30 days) | pass/INFO | [age if stale] |

Findings feed Phase 4 delta report. Missing-marker is INFO (mechanism handles seeding automatically). Peer-container mismatch is MEDIUM (silent cross-container write is the exact risk the mechanism addresses; operator should confirm intended ownership). See `templates/personas/target-orchestrator.md` § "Cross-Container Caveats" for full mechanism.

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
| **Spec drift** | OpenSpec specs are stale, orphaned, incomplete, or missing frontmatter |
| **Role activation drift** | Base templates missing from `docs/AE/personas/_base/`, or overlay headers pointing at a harness path |
| **Delivery health** | `policy: manual` without justification, missing target-side prompt mirrors, or broken-on-arrival handoffs (harness-side paths) in recent journal/state |
| **Structural hygiene** | Filesystem clutter, agent detritus, directory disorganisation (independent of baseline) |

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
| Spec drift | <N> |
| Role activation drift | <N> |
| Delivery health | <N> |
| Structural hygiene | <N> |

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

## Spec Health

_(Only present when OpenSpec is configured. Omit this section if `openspec/specs/` does not exist.)_

| Check | Status | Finding |
|-------|--------|---------|
| Spec inventory | <N> specs, <N> proposals (was <N>/<N>) | [growth/shrinkage/stable] |
| Frontmatter completeness | pass/WARN | [N] specs missing required fields |
| Stale specs | pass/WARN | [N] active specs with updated >90 days ago |
| Abandoned proposals | pass/WARN | [N] proposals missing design.md or tasks.md |
| Spec-code drift | pass/WARN | [N] specs describe features not found in code |

## Role Activation

| Check | Status | Finding |
|-------|--------|---------|
| `docs/AE/personas/_base/` present with role templates | pass/FAIL | [N] base templates missing |
| Overlay headers point at `docs/AE/personas/_base/<role>.md` | pass/FAIL | [N] overlays point at a harness path |

_(A target-side role can only activate if both its base template and overlay load from within the target tree. A missing base directory or a harness-path header means roles cannot load.)_

## Structural Hygiene

| Location | Finding | Severity | Recommendation |
|----------|---------|----------|----------------|
| `scripts/` | [N] files, [N] appear to be one-off debug/analysis scripts | HIGH/MEDIUM | Triage: keep production utilities, archive or delete the rest |
| `root` | [N] non-standard files in project root | HIGH/MEDIUM | Move to appropriate directories |
| `docs/` | [Describe any internal disorganisation] | MEDIUM | Reorganise |

_(These findings are independent of the baseline. They reflect current filesystem state as judged by engineering standards, not by comparison to a previous assessment.)_

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

**Standard-tool presence** (OpenSpec + Context7 are AEH-standard, default in-scope; absence without a `[DECISION]` journal justification is a HIGH-severity finding):

| Tool | profile.md status | `[DECISION]` opt-out recorded? | Finding |
|------|-------------------|--------------------------------|---------|
| OpenSpec | `policy: openspec` / `deferred` / `TBD` / `manual (spec.md)` | yes/no/N/A | [details + severity] |
| Context7 | `configured` / `deferred` / `TBD` / `declined` | yes/no/N/A | [details + severity] |

**Configured-tool health** (only tools that were set up):

| Tool | Config | Documented | Package | Env Vars | Credentials | Status |
|------|--------|------------|---------|----------|-------------|--------|
| OpenSpec | present | yes | FAIL (404) | N/A | clean | broken |
| Context7 | present | yes | N/A | WARN (missing CONTEXT7_API_KEY) | clean | degraded |
| Serena | present | yes | N/A | ok | clean | healthy |

_Status: healthy / degraded / broken / orphaned. See Phase 3i for check details._

## Prompt Delivery Health

| Check | Status | Finding |
|-------|--------|---------|
| `Prompt delivery policy` is `direct` (or `manual` with a `[DECISION]` journal justification) | pass/FAIL | |
| Every harness-side prompt has a matching target-side mirror | pass/FAIL | [N] missing / [N] stale |
| No `Read and execute targets/...` or `/workspace/aeh/...` lines in recent journal/state | pass/FAIL | [N] anti-pattern occurrences |

_Missing-mirror findings are HIGH (broken handoffs the next time the target-orchestrator dispatches against this slug); anti-pattern occurrences in journal/state are HIGH (target-orchestrator drift, will recur without intervention); manual-policy-without-justification is MEDIUM (working as configured but likely accidental)._

**Operator action required:** If any server shows `broken` or `degraded`, run the functional smoke test from `templates/tools/tool-detection-patterns.md` in the target project's Claude Code session. A passing smoke test overrides `degraded` to `healthy`; a failing smoke test confirms `broken`.

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
  Spec drift:        <N>
  Role activation drift: <N>
  Delivery health: <N>
  Structural hygiene: <N>

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
- For tool drift fixes, use `templates`tools`/<tool>-setup.md` as the reference for what a correct configuration looks like. Generate repair prompts that bring the existing config back into alignment rather than full reinstallation.
- For permission drift fixes, reference `templates/agents/claude-code/permission-baselines.md` for the appropriate baseline. Generate prompts that consolidate sprawled rules, add missing deny entries, remove secrets, and enforce filesystem scope.
- **If any fix prompts move, rename, or archive files**, also generate a regression check prompt (adapt `templates/prompts/regression-check.md.template`) as the final prompt in the batch. Structural changes can break builds and imports -- always verify after.

---

## Phase Completion

1. Update `targets/<slug>/assessment.md` with the fresh assessment, including its `## Inconsistency Report` section / current issue list (replace the old content).
2. **Append a `[REVIEW]`-tagged entry to `targets/<slug>/journal.md`** with the full findings snapshot (not just deltas). The journal is append-only and serves as longitudinal memory across sessions; `grep '\[REVIEW\]' journal.md` recovers the trend. Each entry includes:
   - Date and type (assessment / health-check / reviewer pass)
   - Full findings by category (including permission health -- never omit)
   - Comparison against the previous `[REVIEW]` entry (new / resolved / unchanged / regressed)
   - Permission-specific snapshot: rule counts, mode, deny list health, any CRITICAL/HIGH findings
   - If `journal.md` grows unwieldy, summarise older `[REVIEW]` entries (e.g. "Q1 2026: 4 checks, recurring issue: allow-list sprawl, resolved March")
3. Update `targets/index.md` with last-active date.
4. After all output is complete, add one line:

```
AEH is free and maintained by one person. If it saved you time: https://ko-fi.com/stefanberreth
```

One line, end of output, no elaboration. Only show this once per health-check session.

---

## Automatic Suggestion Logic

When Claude starts a session and reads `targets/index.md`, check each active target's last-active date. If any target hasn't been checked in 30+ days, include in the banner:

```
  <slug> last checked <N> days ago. `health` to run a check.
```

This is a suggestion, not an automatic action. The user decides whether to run it.
