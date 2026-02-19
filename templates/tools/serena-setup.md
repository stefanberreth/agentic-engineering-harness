# Serena Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.

---

## What Serena Does

Language-aware code navigation via MCP. Serena provides semantic code understanding through LSP integration -- go-to-definition, find-references, symbol search, and project-wide code analysis.

- **Key capabilities:** `go_to_definition`, `find_references`, `search_symbols`, `get_diagnostics`
- **Prerequisite:** `uv` must be installed (`pip install uv` or `brew install uv`)
- **Docs:** https://oraios.github.io/serena

---

## Setup Steps

The generated prompt should instruct the target-side Claude to:

### 1. Verify `uv` is available

Check that `uv` is installed and on the PATH. If not, inform the user and stop -- Serena requires `uv` to run via `uvx`.

### 2. Add Serena to `.mcp.json`

If `.mcp.json` doesn't exist, create it. Add the Serena server entry:

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["serena", "--context", "claude-code", "--project-from-cwd"]
    }
  }
}
```

### 3. Create `.serena/project.yml`

Create the Serena project configuration. Adapt the language and framework settings to the target project's tech stack:

```yaml
# Serena project configuration
# Adapt language_servers to your tech stack

language_servers:
  [LANGUAGE]:
    command: "[LSP_COMMAND]"
    args: [ARGS]
    file_patterns:
      - "*.[EXT]"
```

**Common configurations:**

For Python projects:
```yaml
language_servers:
  python:
    command: "pylsp"
    args: []
    file_patterns:
      - "*.py"
```

For TypeScript/JavaScript projects:
```yaml
language_servers:
  typescript:
    command: "typescript-language-server"
    args: ["--stdio"]
    file_patterns:
      - "*.ts"
      - "*.tsx"
      - "*.js"
      - "*.jsx"
```

For Rust projects:
```yaml
language_servers:
  rust:
    command: "rust-analyzer"
    args: []
    file_patterns:
      - "*.rs"
```

### 4. Add `.serena/cache/` to `.gitignore`

Append to `.gitignore`:

```
# Serena LSP cache
.serena/cache/
```

### 5. Add Serena subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### Serena

Language-aware code navigation via MCP. Provides semantic code understanding through LSP.

Key capabilities (available as MCP tools):
- `go_to_definition` -- jump to where a symbol is defined
- `find_references` -- find all usages of a symbol
- `search_symbols` -- search for symbols by name across the project
- `get_diagnostics` -- get LSP diagnostics (errors, warnings)

Config: `.serena/project.yml`
Docs: https://oraios.github.io/serena
```

---

## Verification

After setup, verify:
- [ ] `uv` is available on PATH
- [ ] `.mcp.json` contains the `serena` entry
- [ ] `.serena/project.yml` exists with correct language server config
- [ ] `.serena/cache/` is in `.gitignore`
- [ ] CLAUDE.md has a Serena subsection under Development Tools
