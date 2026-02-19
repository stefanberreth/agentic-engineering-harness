# Context7 Teardown -- Prompt Template

> Adapt this template when generating a removal prompt for a target project.

---

## What Gets Removed

- Context7 entry from `.mcp.json`
- Context7 subsection from CLAUDE.md

## Residual State

None. Context7 is a remote service with no local state beyond the MCP configuration entry.

---

## Teardown Steps

The generated prompt should instruct the target-side Claude to:

### 1. Remove Context7 from `.mcp.json`

Remove the `context7` entry from the `mcpServers` object. If `.mcp.json` becomes empty (`"mcpServers": {}`), delete the file.

### 2. Remove Context7 subsection from CLAUDE.md

Remove the `### Context7` subsection from the `## Development Tools` section. If the Development Tools section has no remaining subsections, remove the section.

---

## Verification

After teardown, verify:
- [ ] `.mcp.json` no longer references `context7` (or file is deleted)
- [ ] CLAUDE.md no longer mentions Context7 in Development Tools
