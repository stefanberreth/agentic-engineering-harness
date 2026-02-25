# OpenSpec Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.

---

## What OpenSpec Does

Specification-driven development. OpenSpec manages specs and change proposals as structured markdown documents alongside your code.

- **Docs:** https://openspec.dev/

---

## MCP Server: When to Use It and When Not To

OpenSpec offers an MCP server (`openspec-mcp`) that exposes commands like `create_spec`, `propose_change`, and `list_specs` as MCP tools.

**Do NOT set up the MCP server for CLI agents with filesystem access (Claude Code, Aider, etc.).** These agents can already read, write, and list files in `openspec/specs/` and `openspec/changes/` directly. The MCP server adds a brittle intermediary (npx startup, package resolution, process management) for zero functional gain. Spec files are markdown -- there is nothing the MCP server provides that `Read`, `Write`, and `Glob` don't already do better and more reliably.

**The MCP server is only appropriate when:**
- The agent runs in a sandboxed environment without direct filesystem access (web UIs, hosted playgrounds)
- The agent framework has no native file tools and relies entirely on MCP for all I/O

If neither of these applies -- and for Claude Code they never do -- skip the MCP server entirely and set up OpenSpec as a directory convention only.

---

## Setup Steps

The generated prompt should instruct the target-side Claude to:

### 1. Create OpenSpec directory structure

```
openspec/
├── specs/       # Specification documents
└── changes/     # Change proposals
```

### 2. Initialise OpenSpec (if the CLI is available)

```bash
npx openspec init --tools claude
```

If the CLI is not available or the user prefers manual setup, the directory structure from step 1 is sufficient.

### 3. Add OpenSpec subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### OpenSpec

Specification-driven development. Specs live in `openspec/specs/`, change proposals in `openspec/changes/`.

Read spec files directly -- no MCP server needed. Create new specs by writing markdown files to the appropriate directory.

Docs: https://openspec.dev/
```

### 4. Add to `.gitignore` (if needed)

No `.gitignore` changes needed -- OpenSpec files are intended to be version-controlled.

---

## MCP Server Setup (sandboxed environments only)

> Only use this section if the target agent lacks direct filesystem access.
> For Claude Code and other CLI agents, skip this entirely.

Add the OpenSpec server entry to `.mcp.json`:

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

Add MCP tool references to the CLAUDE.md subsection:

```markdown
Key commands (available as MCP tools):
- `create_spec` -- create a new specification document
- `propose_change` -- propose a change to an existing spec
- `list_specs` -- list all specifications
```

---

## Verification

After setup, verify:
- [ ] `openspec/specs/` directory exists
- [ ] `openspec/changes/` directory exists
- [ ] CLAUDE.md has an OpenSpec subsection under Development Tools
- [ ] (Sandboxed environments only) `.mcp.json` contains the `openspec` entry and server connects
