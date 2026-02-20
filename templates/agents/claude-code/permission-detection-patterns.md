# Permission Detection Patterns

Reference for detecting and auditing Claude Code permission configurations during onboarding reconnaissance (Phase 2b), assessment (Phase 3), and health checks (Phase 3h).

Follows the same format as `templates/tools/tool-detection-patterns.md`.

---

## Settings File Detection

Detect all Claude Code configuration files in the target project.

| What | Pattern | Tool | Severity |
|------|---------|------|----------|
| Shared settings | Glob: `.claude/settings.json` | Glob | Informational |
| Local settings | Glob: `.claude/settings.local.json` | Glob | Informational |
| Any settings | Glob: `.claude/settings*.json` | Glob | Informational |
| Claude directory | Glob: `.claude/` | Glob | Informational |

When settings files exist, read them fully and parse the `permissions` object.

---

## CRITICAL Findings

These must be flagged immediately and prominently in any assessment.

| What to detect | Pattern | Tool | Details |
|----------------|---------|------|---------|
| Secrets in rules | Grep settings files for `PASSWORD`, `SECRET`, `TOKEN`, `API_KEY`, `PRIVATE_KEY`, `pgpass`, `Bearer` (case-insensitive) | Grep | Any match = CRITICAL. Credential is exposed in plaintext, likely in git history. |
| Bypass mode | Grep settings files for `bypassPermissions` | Grep | If `defaultMode` is `bypassPermissions`, all safety prompts are disabled. |
| Filesystem escape (broad read) | Grep allow rules for `Read(/*` or `Read` with no argument constraint | Grep | Agent can read any file on the machine. |
| Filesystem escape (broad write) | Grep allow rules for `Write(/*` or `Write` with no argument constraint, or `Edit(/*` or `Edit` with no argument constraint | Grep | Agent can modify any file on the machine. |
| Harness isolation breach | Grep allow rules for harness directory path; also check deny list does NOT contain harness path | Grep | Target agent can read harness files -- breaks two-project isolation model. If harness path is known (from `profile.md`), check for it explicitly. |

---

## HIGH Findings

Significant security or governance gaps.

| What to detect | Pattern | Tool | Details |
|----------------|---------|------|---------|
| Empty deny list | Parse `permissions.deny`, check if absent or empty array | Read + parse | No safety rails. Nothing is explicitly forbidden. |
| No .env blocking | Grep deny rules for `.env` | Grep | If deny list exists but doesn't mention `.env`, secrets files are accessible. |
| No credential file blocking | Grep deny rules for `credentials`, `.pem`, `.key`, `.p12` | Grep | Sensitive auth material not protected. |
| Auto-enable MCP | Grep settings for `enableAllProjectMcpServers.*true` | Grep | Untrusted MCP servers activate without review. |
| acceptEdits on team project | Check `defaultMode` is `acceptEdits` AND project has multiple contributors | Read + context | File edits happen without confirmation in a shared codebase. |

---

## MEDIUM Findings

Maintenance debt and hygiene issues.

| What to detect | Pattern | Tool | Details |
|----------------|---------|------|---------|
| Rule sprawl (50+) | Count entries in `permissions.allow` | Read + count | At 50+ rules, the config is likely accumulated transactionally and unauditable. Escalate to HIGH at 100+. |
| Stale path rules | Extract file paths from allow/deny rules, cross-reference against filesystem | Glob + Read | Rules referencing non-existent paths indicate unmaintained config. |
| Home dir unblocked | Check deny list for `~/`, `/Users/`, `/home/` sensitive paths (`~/.ssh`, `~/.aws`, `~/.config`) | Grep | Agent can access SSH keys, cloud credentials, shell history. |
| Duplicate rules | Check for identical strings in both allow and deny arrays | Read + parse | Confusing intent. Deny wins, but the allow entry is misleading. |
| Local overrides shared | Compare `.claude/settings.json` and `.claude/settings.local.json` for overlapping keys | Read + compare | Unclear which is authoritative for a given permission. |
| Settings not gitignored | Check `.gitignore` for `.claude/settings.local.json` | Grep | Personal overrides would be committed to the shared repo. |

---

## LOW Findings

Cosmetic or minor issues.

| What to detect | Pattern | Tool | Details |
|----------------|---------|------|---------|
| Overly specific allows | Count allow entries that differ only by a trailing path segment (e.g. 20 individual test file rules) | Read + pattern analysis | Symptom of "yes, don't ask again" accumulation. Consolidate with wildcards. |
| No shared settings | `.claude/settings.json` absent but `.claude/settings.local.json` exists | Glob | Team has no shared permission baseline -- every developer has their own config. |
| Unused tool permissions | Allow rules for tools the project doesn't use (e.g. `WebFetch` in an offline project) | Read + context | Minor clutter, but indicates unreviewed config. |

---

## Usage

### During onboarding (Phase 2b)

1. Run settings file detection (all Informational patterns)
2. If settings files exist, read them and run all CRITICAL patterns
3. Record findings in the reconnaissance summary under "Permissions"
4. Full analysis happens in Phase 3 (assessment)

### During assessment (Phase 3)

1. Run ALL detection patterns (CRITICAL through LOW)
2. For each finding, record in `assessment.md` under Category 10
3. Cross-reference rule paths against the filesystem for stale rule detection
4. Count allow/deny entries and note the ratio
5. Check `defaultMode` against project risk profile

### During health checks (Phase 3h)

1. Run ALL detection patterns
2. Compare against the baseline recorded in the previous assessment or review history
3. Flag any new CRITICAL or HIGH findings as regressions
4. Count allow rules and compare against last count (sprawl trend)
5. Report in the Permission Health section of the delta report

### During reviewer pass (mandatory)

The reviewer persona must run permission detection on every review pass:
1. Read `.claude/settings*.json`
2. Run CRITICAL and HIGH detection patterns at minimum
3. Include a "Permission Health" section in `comments.md`
4. Never skip this section, even if the review task is code-focused
