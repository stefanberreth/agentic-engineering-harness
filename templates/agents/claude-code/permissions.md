# Claude Code Permission Reference

Reference knowledge for the AEH harness when auditing and advising on Claude Code permission configurations in target projects.

---

## 1. File Locations and Precedence

Claude Code reads permission settings from multiple sources. Higher-precedence sources override lower ones.

| Priority | Source | Path | Scope | Version-controlled? |
|----------|--------|------|-------|---------------------|
| 1 (highest) | Enterprise/managed | Set by organisation admin | Organisation-wide | N/A (admin-managed) |
| 2 | CLI flags | `--allowedTools`, `--disallowedTools` | Session-only | No |
| 3 | Project local | `.claude/settings.local.json` | This machine only | No (should be gitignored) |
| 4 | Project shared | `.claude/settings.json` | All contributors | Yes |
| 5 (lowest) | User baseline | `~/.claude/settings.json` | All projects for this user | No |

**Key implications for governance:**
- `.claude/settings.json` is the shared, reviewable config -- this is where team agreements live
- `.claude/settings.local.json` is per-developer overrides -- this is where personal tool paths and local exceptions live
- If both exist, local settings merge with (and override) shared settings at the key level
- Enterprise/managed settings cannot be overridden -- they are outside project-level governance scope

---

## 2. Schema Reference

### permissions object

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Read",
      "Edit",
      "Write"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(/etc/passwd)",
      "Bash(curl*)"
    ],
    "defaultMode": "default"
  }
}
```

### permissions.allow

Array of tool permission strings that are pre-approved (no confirmation prompt). Each entry is a tool invocation pattern.

### permissions.deny

Array of tool permission strings that are always blocked. Deny rules take precedence over allow rules. This is the primary safety mechanism.

### permissions.defaultMode

Controls what happens for tool calls not covered by allow or deny lists.

| Mode | Behaviour | Use case |
|------|-----------|----------|
| `"default"` | Prompt user for approval | Team projects, production code |
| `"acceptEdits"` | Auto-approve file edits, prompt for Bash | Solo R&D, trusted environments |
| `"bypassPermissions"` | Auto-approve everything | **Never recommended** -- CRITICAL finding if detected |

### Other settings keys

| Key | Purpose | Governance relevance |
|-----|---------|---------------------|
| `mcpServers` | MCP server configuration | Covered by tool integration governance |
| `enableAllProjectMcpServers` | Auto-enable project MCP servers | HIGH if true without review |
| `hooks` | Pre/post action hooks | Can enforce or bypass permissions |

---

## 3. Rule Syntax

### Tool permission string format

```
ToolName(argument_pattern)
```

- `ToolName` alone (no parens) matches all invocations of that tool
- `ToolName(exact text)` matches only that exact argument
- `ToolName(prefix*)` matches any argument starting with `prefix`
- Wildcards (`*`) only work at the end of the argument pattern

### Common tool names

| Tool | What it does | Risk level |
|------|-------------|------------|
| `Bash` | Execute shell commands | Highest -- can do anything |
| `Read` | Read file contents | Medium -- information disclosure |
| `Edit` | Modify existing files | High -- can alter any file |
| `Write` | Create/overwrite files | High -- can create any file |
| `WebFetch` | Fetch URLs | Medium -- data exfiltration risk |
| `WebSearch` | Search the web | Low |

### Shell operator awareness

Bash rules match the **full command string**, including operators:

```json
"Bash(npm test)"
```

This matches exactly `npm test` but does NOT match:
- `npm test && echo "done"` -- different string
- `npm test; rm -rf /` -- different string
- `npm test | tee log.txt` -- different string

**Anti-pattern:** Assuming a rule like `Bash(npm test)` prevents `Bash(npm test && malicious_command)`. It does not -- the chained command is a different string that won't match the allow rule but also won't match a deny rule unless explicitly denied.

---

## 4. Anti-Pattern Catalogue

### CRITICAL

| ID | Anti-pattern | Example | Impact |
|----|-------------|---------|--------|
| AP-01 | **Secrets in rules** | `Bash(PGPASSWORD=secret123 psql*)` | Credentials stored in plaintext in a committed file |
| AP-02 | **Bypass mode** | `"defaultMode": "bypassPermissions"` | All safety prompts disabled -- agent can do anything without approval |
| AP-03 | **Filesystem escape** | `Read(/**)` or no deny for paths outside project | Agent can read any file on the machine, including other projects, SSH keys, credentials |
| AP-04 | **Harness isolation breach** | No deny rule for the AEH harness directory | Target agent can read transformation plans, other project assessments, harness internals |

### HIGH

| ID | Anti-pattern | Example | Impact |
|----|-------------|---------|--------|
| AP-05 | **Empty deny list** | `"deny": []` or deny key absent | No safety rails -- nothing is explicitly forbidden |
| AP-06 | **No .env blocking** | Deny list doesn't include `.env` patterns | Agent can read secrets from environment files |
| AP-07 | **Broad write permissions** | `Write` with no path constraints | Agent can write anywhere in the filesystem |
| AP-08 | **Auto-enable MCP** | `"enableAllProjectMcpServers": true` | Untrusted MCP servers auto-activated |

### MEDIUM

| ID | Anti-pattern | Example | Impact |
|----|-------------|---------|--------|
| AP-09 | **Rule sprawl** | 50+ individual allow entries | Unauditable, likely accumulated transactionally |
| AP-10 | **Stale path rules** | Allow rules reference `src/legacy/` which no longer exists | Indicates unmaintained config |
| AP-11 | **No home dir protection** | Deny list doesn't block `~/` sensitive paths | Agent can access SSH keys, shell history, credentials |
| AP-12 | **Duplicate rules** | Same permission string in both allow and deny | Confusing intent (deny wins, but the allow is misleading) |

### LOW

| ID | Anti-pattern | Example | Impact |
|----|-------------|---------|--------|
| AP-13 | **Overly specific allows** | One rule per test file instead of `Bash(npm test*)` | Maintenance burden, symptom of "yes don't ask again" accumulation |
| AP-14 | **Commented-out rules** | JSON doesn't support comments, but string entries like `"// disabled"` | No effect but clutters config |
| AP-15 | **Mixed concern files** | Both shared and local settings contain the same rules | Unclear which is authoritative |

---

## 5. Remediation Patterns

### Secret rotation

When secrets are found in permission rules:
1. **Immediately rotate the credential** -- the settings file is likely committed in git history
2. Replace the Bash rule with a secret-free alternative (e.g. use `.pgpass` file or env var set outside Claude)
3. Add the credential pattern to the deny list to prevent re-introduction
4. Check git history: `git log -p --all -S 'PASSWORD'` to find all commits containing the secret

### Deny list construction

A healthy deny list blocks at minimum:
- **Secrets files**: `.env`, `.env.*`, `credentials*`, `*.pem`, `*.key`
- **SSH/auth**: `~/.ssh/*`, `~/.aws/*`, `~/.config/gh/*`
- **Outside project**: paths above the project root (filesystem escape prevention)
- **Destructive commands**: `rm -rf`, `git push --force`, `git reset --hard`
- **Data exfiltration**: `curl*` to unknown hosts, `Bash(scp*)`

### Allow list consolidation

When rule sprawl is detected (>50 allow entries):
1. Group rules by tool and pattern prefix
2. Replace groups with wildcards: `Bash(npm test:*)` instead of 20 individual test file rules
3. Move truly one-off rules to ask-mode (remove from allow, let the prompt appear)
4. Document the consolidation rationale in the project's CLAUDE.md

### Stale rule cleanup

1. Extract all file paths referenced in allow/deny rules
2. Cross-reference against the current filesystem
3. Remove rules referencing paths that no longer exist
4. Review rules referencing paths that changed (e.g. directory renames)

### Filesystem scope enforcement

Ensure the agent cannot read or write outside the project directory:
1. Add deny rules for broad filesystem patterns: `Read(/etc/*)`, `Read(/Users/*)` (excluding project path)
2. Or use the project root as a scope boundary in allow rules
3. Specifically deny the harness directory path if known
