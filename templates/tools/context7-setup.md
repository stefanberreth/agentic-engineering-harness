# Context7 Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.
> See also: `templates/tools/sandbox-env-provisioning.md` for the `.env` mechanism.

---

## What Context7 Does

Documentation lookup via MCP. Context7 provides up-to-date library documentation directly in Claude's context, eliminating manual doc searching and reducing hallucination of outdated APIs.

- **Usage pattern:** Add "use context7" to prompts when you want Claude to look up current library docs
- **Docs:** https://context7.com/

---

## Setup Steps

The generated prompt should instruct the target-side Claude to:

### 1. Add Context7 to `.mcp.json`

If `.mcp.json` doesn't exist, create it. Add the Context7 server entry:

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "x-context7-api-key": "${CONTEXT7_API_KEY}"
      }
    }
  }
}
```

Note: `${CONTEXT7_API_KEY}` uses environment variable expansion. The value is read from the project's `.env` file (see step 3).

### 2. Add Context7 subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### Context7

Documentation lookup via MCP. Provides up-to-date library docs in context.

Usage: Add "use context7" to prompts when current library documentation is needed.

Docs: https://context7.com/
```

### 3. Provision `CONTEXT7_API_KEY` in `.env`

This step ensures the API key is available to the MCP server, whether running natively or in a Docker sandbox. The sandbox passthrough mechanism reads from the project's `.env` file.

The generated prompt should instruct the target-side Claude to:

1. **Check if `.env` exists** in the project root.
2. **Check if it already contains `CONTEXT7_API_KEY`:**
   ```bash
   grep -q 'CONTEXT7_API_KEY' .env 2>/dev/null && echo "already set" || echo "not found"
   ```
3. **If missing, ask the operator for the value:**
   ```
   Context7 requires an API key. Please provide your CONTEXT7_API_KEY value.
   Get one from: https://context7.com/

   This is a personal key (same across all your projects), not a project secret.
   ```
4. **Append to `.env`:**
   ```bash
   echo "CONTEXT7_API_KEY=<value from operator>" >> .env
   ```
5. **Ensure `.env` is gitignored.** Check `.gitignore` for `.env` or `.env*` patterns. If missing, append:
   ```
   # Environment secrets
   .env
   .env.*
   !.env.example
   ```

**Important:** The actual key value must NEVER appear in the prompt file on disk. The prompt uses a placeholder and instructs the target-side Claude to ask the operator interactively.

### 4. Create `.env.example` (if it doesn't exist)

Create a `.env.example` file documenting required variables without values:

```
# Context7 documentation lookup (get key from https://context7.com/)
CONTEXT7_API_KEY=
```

This file IS committed to git -- it tells other developers (or fresh sessions) what variables are needed without exposing values.

---

## Verification

After setup, verify:
- [ ] `.mcp.json` contains the `context7` entry with HTTP transport
- [ ] CLAUDE.md has a Context7 subsection under Development Tools
- [ ] `.env` contains `CONTEXT7_API_KEY=<actual value>` (not empty)
- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` exists documenting the required variable
- [ ] (If in sandbox) restart the container to pick up the new `.env` value
