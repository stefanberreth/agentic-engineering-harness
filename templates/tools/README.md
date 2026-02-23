# Tool Integration Templates

Optional MCP server and development tool configurations for target projects under harness management.

## Design Principles

- **Optional.** Tool absence is informational, never a deficiency. No assessment or health check penalises a project for not using these tools.
- **Detect, don't prescribe.** If a project already has functional equivalents (ADR directories, custom spec management, other MCP servers), report them -- don't suggest replacement.
- **Per-project.** All tool configuration is recorded in the target's `profile.md`. No cross-project assumptions.
- **Reversible.** Every setup template has a matching teardown template. Nothing is permanent.
- **Brief.** Each template describes what the tool does, lists 2-3 key commands, and links to official docs. No tutorials.

## Available Tools

| Tool | What it does | Setup | Teardown |
|------|-------------|-------|----------|
| **OpenSpec** | Specification-driven development via MCP. Manages specs and change proposals alongside code. | `openspec-setup.md` | `openspec-teardown.md` |
| **Context7** | Documentation lookup via MCP. Provides up-to-date library docs in Claude's context without manual searching. | `context7-setup.md` | `context7-teardown.md` |
| **Serena** | Language-aware code navigation via MCP. Provides semantic code understanding (go-to-definition, find-references, symbol search). | `serena-setup.md` | `serena-teardown.md` |

## How Tools Are Managed

Tools are managed through the `tools` playbook (`templates/playbooks/tools.md`), which can be run at any time -- during onboarding or independently. The playbook:

1. Detects which tools (and functional equivalents) are already present
2. Presents each tool with a brief description and offers setup/skip/decline/remove
3. Generates prompts for the target-side Claude to execute
4. Records decisions in the target's `profile.md` and `decisions.md`

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
