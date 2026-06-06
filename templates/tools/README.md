# Tool Integration Templates

Development tool configurations (CLI, skills, and MCP-server based) for target projects under harness management. Two of these tools (**OpenSpec**, **Context7**) are AEH-standard SDLC tools — default in-scope during onboarding because they are load-bearing for successful agentic engineering. The third (**Serena**) is genuinely optional and codebase-dependent.

## Design Principles

- **Two standard, one optional.** OpenSpec and Context7 are AEH-standard SDLC tools — default in-scope during onboarding, opt-out (not opt-in). Their absence on a project is a deliberate operator choice, recorded as a `[DECISION]` journal entry with rationale. Serena remains genuinely optional; its absence is informational.
- **Detect, don't prescribe duplicates.** If a project already has functional equivalents (ADR directories, custom spec management, other MCP servers), report them. For OpenSpec, frame as complementary rather than replacement. For optional tools, treat the equivalent as sufficient unless the operator says otherwise.
- **Per-project.** All tool configuration is recorded in the target's `profile.md`. No cross-project assumptions.
- **Reversible.** Every setup template has a matching teardown template. Nothing is permanent.
- **Brief.** Each template describes what the tool does, lists 2-3 key commands, and links to official docs. No tutorials.

## Available Tools

| Tool | Status | What it does | Setup | Teardown |
|------|--------|-------------|-------|----------|
| **OpenSpec** | AEH-standard (default in-scope) | Specification-driven development. Manages specs and change proposals as markdown files alongside code. **No MCP server needed for CLI agents** -- they read spec files directly. MCP server only for sandboxed environments without filesystem access. | `openspec-setup.md` | `openspec-teardown.md` |
| **Context7** | AEH-standard (default in-scope) | Up-to-date library documentation in the agent's context. **Preferred install is CLI + Skills** (`ctx7 setup --cli --<agent>` -- user-global skill, no `.mcp.json`, no mandatory API key); MCP server is a fallback for environments that can't run the CLI. | `context7-setup.md` | `context7-teardown.md` |
| **Serena** | Optional (codebase-dependent) | Language-aware code navigation via MCP. Provides semantic code understanding (go-to-definition, find-references, symbol search). | `serena-setup.md` | `serena-teardown.md` |

## How Tools Are Managed

Tools are managed through the `tools` playbook (`templates/playbooks/tools.md`), which can be run at any time -- during onboarding or independently. The playbook:

1. Detects which tools (and functional equivalents) are already present
2. Presents each tool with a brief description and offers setup/skip/decline/remove
3. Generates prompts for the target-side Claude to execute
4. Records decisions in the target's `profile.md` and as `[DECISION]` entries in `journal.md`

## Detection Patterns

`tool-detection-patterns.md` documents the glob/grep patterns used during onboarding reconnaissance and health checks to detect these tools and their functional equivalents.

## Files in This Directory

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `tool-detection-patterns.md` | Detection patterns for tools and functional equivalents |
| `openspec-setup.md` | Setup prompt template for OpenSpec |
| `openspec-teardown.md` | Teardown prompt template for OpenSpec |
| `context7-setup.md` | Setup prompt template for Context7 |
| `context7-teardown.md` | Teardown prompt template for Context7 |
| `serena-setup.md` | Setup prompt template for Serena |
| `serena-teardown.md` | Teardown prompt template for Serena |
| `sandbox-env-provisioning.md` | Mechanism for provisioning env vars into target `.env` for Docker sandbox passthrough |
