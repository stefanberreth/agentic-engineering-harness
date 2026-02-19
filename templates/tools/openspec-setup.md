# OpenSpec Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.

---

## What OpenSpec Does

Specification-driven development via MCP. OpenSpec manages specs and change proposals as structured documents alongside your code, making them accessible to Claude through MCP tools.

- **Key commands:** `create_spec`, `propose_change`, `list_specs`
- **Docs:** https://openspec.dev/

---

## Setup Steps

The generated prompt should instruct the target-side Claude to:

### 1. Add OpenSpec to `.mcp.json`

If `.mcp.json` doesn't exist, create it. Add the OpenSpec server entry:

```json
{
  "mcpServers": {
    "openspec": {
      "command": "npx",
      "args": ["-y", "openspec-mcp"]
    }
  }
}
```

### 2. Create OpenSpec directory structure

```
openspec/
├── specs/       # Specification documents
└── changes/     # Change proposals
```

### 3. Initialise OpenSpec (if the CLI is available)

```bash
npx openspec init --tools claude
```

If the CLI is not available or the user prefers manual setup, the directory structure from step 2 is sufficient.

### 4. Add OpenSpec subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### OpenSpec

Specification-driven development via MCP. Specs live in `openspec/specs/`, change proposals in `openspec/changes/`.

Key commands (available as MCP tools):
- `create_spec` -- create a new specification document
- `propose_change` -- propose a change to an existing spec
- `list_specs` -- list all specifications

Docs: https://openspec.dev/
```

### 5. Add to `.gitignore` (if needed)

No `.gitignore` changes needed -- OpenSpec files are intended to be version-controlled.

---

## Verification

After setup, verify:
- [ ] `.mcp.json` contains the `openspec` entry
- [ ] `openspec/specs/` directory exists
- [ ] `openspec/changes/` directory exists
- [ ] CLAUDE.md has an OpenSpec subsection under Development Tools
