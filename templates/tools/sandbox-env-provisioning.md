# Sandbox Environment Variable Provisioning

> Reference doc for ensuring required environment variables reach the agent
> inside a Docker sandbox (e.g. sandbox-dev). Read this when generating
> Context7 setup prompts or onboarding projects that run in sandboxed containers.

---

## How the Sandbox Passthrough Works

The sandbox container (sandbox-dev or similar) has a passthrough mechanism:

1. `run-sandbox.sh` defines a `PASSTHROUGH_VARS` array listing variable names to forward.
2. On container start, it reads each variable's value from the **target project's `.env` file**.
3. Values are passed via `docker compose run -e VAR=value` into the container.
4. Inside the container, `init-firewall.sh` forwards all non-system env vars through the `sudo -u agent` handoff, making them available in the agent's shell and to Claude Code.

**Key implication:** The variable must be in the target project's `.env` file, not in `~/.bashrc` or `~/.zshrc`. The container runs with `--rm`, so anything set inside it is lost on restart.

---

## Currently Required Passthrough Variables

| Variable | Used by | Purpose | Firewall rule needed |
|----------|---------|---------|----------------------|
| `CONTEXT7_API_KEY` | Context7 **MCP fallback only** | Authenticates with context7.com for doc lookup | `mcp.context7.com:443` (already whitelisted) |

This table is the source of truth for what the onboarding playbook provisions. When a new passthrough var is added to `run-sandbox.sh`, add it here too.

Note: Context7's **preferred CLI + Skills mode needs no env var** -- doc queries work without a key, and an optional key (higher rate limits only) is set interactively rather than provisioned through the sandbox. `CONTEXT7_API_KEY` is provisioned only when the MCP-server fallback was installed.

---

## Provisioning Flow (During Onboarding)

### 1. Check harness-level `.env`

The harness root has a gitignored `.env` file for personal API keys shared across all targets. When a tool requiring a passthrough var is accepted during onboarding:

1. Read `<harness-root>/.env` for the variable.
2. If present: use the value when generating the target's setup prompt.
3. If absent: ask the operator for the value. Store it in both the harness `.env` (for reuse) and embed it in the interactive session (not in the prompt file on disk).

### 2. Generate the setup prompt

The generated prompt (e.g. 007-setup-context7.md) instructs the target-side Claude to:

1. Check if `.env` exists in the target project root.
2. Check if it already contains the required variable.
3. If missing, ask the operator for the value and append it.
4. Ensure `.env` is in `.gitignore`.

**The actual key value must NEVER appear in prompt files on disk.** Prompt files are version-controlled and may be delivered to `docs/AE/prompts/`. The prompt uses a placeholder like `[ASK_OPERATOR]` and instructs the target-side Claude to request the value interactively.

### 3. Verify

The setup prompt includes a verification step that checks the variable is set in the running environment. For sandboxed execution, this means the value must be in `.env` before the container starts.

---

## Adding a New Passthrough Variable

1. Add the variable to the `PASSTHROUGH_VARS` array in `run-sandbox.sh`.
2. Add it to the table in this document.
3. Add a firewall rule in `init-firewall.sh` if the variable enables a service that needs network access.
4. Update the relevant tool's setup template to include `.env` provisioning.
5. The onboarding playbook automatically picks up new entries from this document.

---

## Dev Server Binding in Containers

When a target project runs inside a Docker container, dev servers must bind to `0.0.0.0` (not `localhost`/`127.0.0.1`) for the host browser to reach them. This is a common gotcha: ports are mapped correctly in Docker but the server only listens on the loopback interface inside the container.

**Common frameworks and their fixes:**

| Framework | Default bind | Fix |
|-----------|-------------|-----|
| Vite | `localhost` | Add `server: { host: true }` to `vite.config.ts` |
| Next.js | `localhost` | `next dev -H 0.0.0.0` |
| Express | `localhost` (implicit) | `app.listen(port, '0.0.0.0', callback)` |
| Django | `localhost` | `python manage.py runserver 0.0.0.0:8000` |

**When to check:** During onboarding, if the target project runs in a container (detected via `/.dockerenv` or `$SANDBOX_PORTS`), verify dev server binding and fix if needed. This should be part of the developer persona's environment verification step (prompt 078 pattern).

**Port mapping:** The `$SANDBOX_PORTS` env var (if set) shows the container→host port mapping. When telling the operator the test URL, use the host port from this mapping, not the container port.

## Non-Sandbox Environments

When the target project runs outside a sandbox (native Claude Code, no Docker), the `.env` provisioning still works as a reliable convention:

- Many frameworks auto-load `.env` (dotenv, Vite, Next.js, etc.)
- MCP configs using `${VAR}` syntax read from the shell environment
- The operator can `source .env` or add `export` lines to their shell profile

The `.env` approach is universal. The sandbox just makes it mandatory rather than convenient.
