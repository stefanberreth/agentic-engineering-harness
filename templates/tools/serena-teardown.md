# Serena Teardown -- Prompt Template

> Adapt this template when generating a removal prompt for a target project.

---

## What Gets Removed

- Serena entry from `.mcp.json`
- Serena subsection from CLAUDE.md
- `.serena/cache/` entry from `.gitignore`

## What Requires Confirmation

- `.serena/` directory -- contains `project.yml` (config) and `cache/` (transient). Ask the user before deleting.

---

## Teardown Steps

The generated prompt should instruct the target-side Claude to:

### 1. Remove Serena from `.mcp.json`

Remove the `serena` entry from the `mcpServers` object. If `.mcp.json` becomes empty (`"mcpServers": {}`), delete the file.

### 2. Ask about `.serena/` directory

Ask the user:

> Remove `.serena/` directory? This contains `project.yml` (your language server configuration) and `cache/` (transient data). [y/n]

If yes, delete the entire `.serena/` directory. If no, leave it in place.

### 3. Remove Serena subsection from CLAUDE.md

Remove the `### Serena` subsection from the `## Development Tools` section. If the Development Tools section has no remaining subsections, remove the section.

### 4. Revert `.gitignore` change

Remove the `.serena/cache/` entry from `.gitignore`. If a comment line `# Serena LSP cache` precedes it, remove that too.

---

## Verification

After teardown, verify:
- [ ] `.mcp.json` no longer references `serena` (or file is deleted)
- [ ] `.serena/` is deleted (if user approved) or still present (if user declined)
- [ ] CLAUDE.md no longer mentions Serena in Development Tools
- [ ] `.gitignore` no longer references `.serena/cache/`
