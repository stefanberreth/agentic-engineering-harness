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

### During `/tools` playbook (Phase 2)

Run all detection patterns to present a current-state table before offering setup/removal options.
