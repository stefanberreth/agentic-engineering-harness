# Context7 Setup -- Prompt Template

> Adapt this template when generating a setup prompt for a target project.
> Replace all `[PLACEHOLDER]` values with project-specific details.

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

Note: `${CONTEXT7_API_KEY}` uses environment variable expansion. The user needs a Context7 API key set in their environment.

### 2. Add Context7 subsection to CLAUDE.md

Under the `## Development Tools` section (create the section if it doesn't exist), add:

```markdown
### Context7

Documentation lookup via MCP. Provides up-to-date library docs in context.

Usage: Add "use context7" to prompts when current library documentation is needed.

Docs: https://context7.com/
```

### 3. Verify API key availability

Remind the user to ensure `CONTEXT7_API_KEY` is set in their environment. This is not something the prompt should configure -- it's a user-managed secret.

---

## Verification

After setup, verify:
- [ ] `.mcp.json` contains the `context7` entry with HTTP transport
- [ ] CLAUDE.md has a Context7 subsection under Development Tools
- [ ] `CONTEXT7_API_KEY` is set in the environment (user responsibility)
