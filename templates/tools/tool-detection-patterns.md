# Tool Detection Patterns

Reference for detecting development tools and their functional equivalents during onboarding reconnaissance (Phase 2b) and health checks (Phase 3g).

---

## General MCP Detection

Detect any MCP server configuration, regardless of which specific tools are in use.

| What | Pattern | Tool |
|------|---------|------|
| MCP config file | Glob: `.mcp.json` at project root | Glob |
| Claude skills | Glob: `.claude/skills/*` | Glob |
| Claude commands | Glob: `.claude/commands/*` | Glob |
| Claude settings with MCP | Grep `.claude/settings.json` for `mcpServers` | Grep |

When `.mcp.json` exists, read it and catalogue all configured servers (name, transport type, command/URL).

---

## OpenSpec Detection

### Direct detection

| What | Pattern | Tool |
|------|---------|------|
| OpenSpec directory | Glob: `openspec/` at project root | Glob |
| OpenSpec specs | Glob: `openspec/specs/*.md` | Glob |
| OpenSpec changes | Glob: `openspec/changes/*.md` | Glob |
| OpenSpec skills | Glob: `.claude/skills/openspec-*` | Glob |
| MCP config entry | Grep `.mcp.json` for `openspec` | Grep |

### Functional equivalents

These indicate spec management exists but may not use OpenSpec:

| What | Pattern | Suggests |
|------|---------|----------|
| ADR directory | Glob: `docs/adr/`, `docs/decisions/`, `adr/` | Architectural Decision Records |
| RFC directory | Glob: `docs/rfc/`, `rfc/` | RFC process |
| Spec files | Glob: `spec.md`, `specs/`, `docs/specs/` | Custom spec management |
| Changeset directory | Glob: `.changeset/` | Changesets (versioning-focused, not specs) |

---

## Context7 Detection

### Direct detection

| What | Pattern | Tool |
|------|---------|------|
| MCP config entry | Grep `.mcp.json` for `context7` | Grep |
| Environment variable | Grep `.env*` for `CONTEXT7_API_KEY` | Grep |

### Functional equivalents

| What | Pattern | Suggests |
|------|---------|----------|
| Other doc MCP servers | Grep `.mcp.json` for `docs`, `documentation`, `devdocs` | Alternative documentation server |
| Local doc cache | Glob: `.docs/`, `docs/vendor/`, `docs/external/` | Manual documentation caching |
| Sourcegraph config | Glob: `.sourcegraph/` | Sourcegraph code intelligence |

---

## Serena Detection

### Direct detection

| What | Pattern | Tool |
|------|---------|------|
| Serena config | Glob: `.serena/project.yml` | Glob |
| Serena cache | Glob: `.serena/cache/` | Glob |
| MCP config entry | Grep `.mcp.json` for `serena` | Grep |

### Functional equivalents

| What | Pattern | Suggests |
|------|---------|----------|
| Other LSP MCP servers | Grep `.mcp.json` for `lsp`, `language-server`, `sourcegraph` | Alternative code intelligence |
| ctags/etags | Glob: `tags`, `TAGS`, `.ctags`, `.ctags.d/` | Traditional code navigation |
| Sourcegraph config | Glob: `.sourcegraph/` | Sourcegraph code intelligence |

---

## Usage

### During onboarding (Phase 2b)

Run all detection patterns. For each tool:
- Record whether the tool itself is detected (direct detection)
- Record whether functional equivalents are detected
- Include results in the reconnaissance summary

### During health checks (Phase 3g)

For tools recorded as configured in `profile.md`:
- Verify configuration still exists and is valid
- Check that CLAUDE.md documents the tool
- Check that config matches project reality (e.g. Serena's `project.yml` references the correct language)

### During `tools` playbook (Phase 2)

Run all detection patterns to present a current-state table before offering setup/removal options.

---

## MCP Health Verification Patterns

Static detection (above) confirms configuration exists. These patterns verify that configured MCP servers are **functional** -- packages resolve, environment variables are set, and no credentials are exposed.

### Hardcoded Credential Detection

Scan `.mcp.json` for values that look like secrets rather than environment variable references.

| What | Pattern | Tool | Severity |
|------|---------|------|----------|
| Common API key prefixes | Grep `.mcp.json` for `sk-\|ctx7sk-\|sbp_\|ghp_\|xoxb-\|eyJ` | Grep | CRITICAL |
| Long alphanumeric strings not in `${...}` | Grep `.mcp.json` for values matching `[A-Za-z0-9_-]{32,}` that are NOT wrapped in `${...}` | Grep | CRITICAL |
| Inline URLs with credentials | Grep `.mcp.json` for `://[^@]+@` (credentials in URL) | Grep | CRITICAL |

**What to flag:** Any match means a credential is hardcoded in a file that is typically version-controlled. The value should be moved to an environment variable and referenced as `${VAR_NAME}`.

### Environment Variable Resolution

Extract all `${VAR}` references from `.mcp.json` and verify they are defined.

| Step | Action | Tool |
|------|--------|------|
| 1. Extract references | Grep `.mcp.json` for `\$\{[A-Z_][A-Z0-9_]*\}` -- collect all variable names | Grep |
| 2. Check `.env` files | For each variable, grep `.env`, `.env.local`, `.env.development` for the variable name | Grep |
| 3. Check documentation | If not in `.env*`, check CLAUDE.md and README for setup instructions mentioning the variable | Grep |

**What to flag:** Any `${VAR}` reference where the variable is not defined in any `.env*` file and not documented as requiring manual setup. Status: `WARN` (missing but documented) or `FAIL` (missing and undocumented).

### Package Existence Check

For MCP servers launched via `npx`, verify the npm package actually exists.

| Step | Action | Tool |
|------|--------|------|
| 1. Identify npx servers | Read `.mcp.json`, find entries where `command` is `npx` or contains `npx` | Read |
| 2. Extract package name | The first argument after `npx` (or after `-y`) that doesn't start with `-` is the package name | -- |
| 3. Verify package | Run `npm view <package> version 2>&1` | Bash |

**What to flag:** If `npm view` returns a 404 or `ERR!`, the package does not exist in the npm registry. This means the MCP server will fail on every invocation. Status: `FAIL`.

**Note:** This check requires network access. If running offline, skip and note as `SKIP (offline)`.

### User-Level Config Conflict Detection

Check whether the user's global Claude config has MCP entries that could conflict with or shadow project-level config.

| Step | Action | Tool |
|------|--------|------|
| 1. Read user config | Read `~/.claude.json` (if it exists) | Read |
| 2. Check for mcpServers | Look for `mcpServers` entries in the user config | Grep |
| 3. Check for project scoping | If MCP entries exist, check whether any are scoped to paths matching or overlapping the target project | Read |

**What to flag:** User-level MCP entries that duplicate or conflict with project-level `.mcp.json` entries. These can cause confusing behaviour where the wrong server version runs, or duplicate servers compete. Status: `WARN`.

### Functional Smoke Tests

Static checks verify configuration. Smoke tests verify the server actually works. These are **operator-executed** — the harness generates the test prompt, the operator runs it in the target project's Claude Code session and reports pass/fail.

Each test is designed to produce an unambiguous result: either meaningful output (pass) or an error (fail).

| Tool | Test prompt (run in target session) | Pass | Fail |
|------|-------------------------------------|------|------|
| Context7 | `Use the Context7 MCP server to look up documentation for React useState. Show the top result.` | Returns documentation content | Auth error, timeout, or empty response |
| Serena | `Use the Serena MCP server to list the symbols in the project's main entry file.` | Returns symbol list | Connection error or "no symbols found" on a file that clearly has them |
| Supabase | `Use the Supabase MCP server to list the tables in the database.` | Returns table list | Auth error or connection refused |

**When to run:** Only when static checks are inconclusive — e.g. a server shows "connected" in `/mcp` but has env var warnings, or when the operator wants to confirm a "degraded" server actually works.

**Reporting:** Record the result in the Tool Health table's Status column. A passing smoke test overrides a static "degraded" status to "healthy". A failing smoke test confirms "broken" regardless of static check results.

### Health Status Values

Combine the results of all checks into a per-server status:

| Status | Meaning |
|--------|---------|
| `healthy` | Config present, package resolves (if applicable), env vars defined, no hardcoded credentials. Or: static checks inconclusive but smoke test passes. |
| `degraded` | Config present but env vars missing or documented-only, or minor warnings. No smoke test run to confirm. |
| `broken` | Package does not exist (404), server cannot possibly start, or smoke test fails |
| `orphaned` | Entry exists in user-level config but not in project `.mcp.json`, or vice versa |
