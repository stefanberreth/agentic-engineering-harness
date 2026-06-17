# Permission Baselines

Recommended Claude Code permission configurations by project archetype. These are starting points for target projects, embedded directly into prompts (never referenced by harness path).

Each baseline is a complete `.claude/settings.json` that can be adapted to the target project's specifics.

---

## 1. Solo Developer / R&D

For single-developer projects, prototypes, and research work. Prioritises flow over friction while maintaining essential safety rails.

**When to use:** Solo projects, personal experiments, early-stage prototypes, learning projects.

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Write",
      "Bash(npm test*)",
      "Bash(npm run *)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "WebSearch"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(curl*)",
      "Bash(wget*)",
      "Bash(scp *)",
      "Read(/etc/*)",
      "Read(~/.ssh/*)",
      "Read(~/.aws/*)",
      "Read(~/.config/gh/*)",
      "Read(*/.env)",
      "Read(*/.env.*)",
      "Read(*/credentials*)",
      "Read(*.pem)",
      "Read(*.key)"
    ],
    "defaultMode": "acceptEdits"
  }
}
```

**Rationale:**
- `acceptEdits` mode: file edits are auto-approved (solo developer trusts the agent's edits), Bash commands still prompt
- Broad Read/Edit/Write: no path constraints within the project (solo developer has full trust)
- Deny list covers: destructive git ops, network exfiltration, secrets files, SSH/cloud credentials
- Adapt: replace `npm` with your package manager (`yarn`, `pnpm`, `bun`, `pip`, `cargo`, etc.)

---

## 2. Team Project / Production

For shared codebases with multiple contributors. Balances productivity with safety and auditability.

**When to use:** Team projects, production codebases, projects with CI/CD, anything that gets deployed.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(npm run build*)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "WebSearch"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(git push*)",
      "Bash(git checkout main)",
      "Bash(git checkout master)",
      "Bash(curl*)",
      "Bash(wget*)",
      "Bash(scp *)",
      "Bash(ssh *)",
      "Read(/etc/*)",
      "Read(~/.ssh/*)",
      "Read(~/.aws/*)",
      "Read(~/.config/gh/*)",
      "Read(*/.env)",
      "Read(*/.env.*)",
      "Read(*/credentials*)",
      "Read(*.pem)",
      "Read(*.key)",
      "Read(*.p12)",
      "Bash(docker rm *)",
      "Bash(docker rmi *)",
      "Bash(DROP TABLE*)",
      "Bash(DROP DATABASE*)"
    ],
    "defaultMode": "default"
  }
}
```

**Rationale:**
- `default` mode: every non-allowed action requires explicit approval
- Read/Edit/Write NOT in allow list: file operations require confirmation (team safety)
- Git push denied: prevents accidental pushes to shared branches
- Network commands denied: no data exfiltration risk
- Docker/DB destructive ops denied: prevents infrastructure damage
- Adapt: add project-specific test/build commands to allow list, add production DB connection strings to deny list

---

## 3. Open Source / Public

For projects where the codebase is public and contributions may come from various sources. Strictest configuration.

**When to use:** Open source projects, public repositories, projects where trust boundaries are widest.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm test*)",
      "Bash(npm run lint*)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "WebSearch"
    ],
    "deny": [
      "Bash(rm *)",
      "Bash(git push*)",
      "Bash(git reset*)",
      "Bash(git checkout main)",
      "Bash(git checkout master)",
      "Bash(git merge*)",
      "Bash(git rebase*)",
      "Bash(curl*)",
      "Bash(wget*)",
      "Bash(scp *)",
      "Bash(ssh *)",
      "Bash(npm publish*)",
      "Bash(npx*)",
      "Read(/etc/*)",
      "Read(~/.ssh/*)",
      "Read(~/.aws/*)",
      "Read(~/.config/*)",
      "Read(~/.npmrc)",
      "Read(*/.env)",
      "Read(*/.env.*)",
      "Read(*/credentials*)",
      "Read(*.pem)",
      "Read(*.key)",
      "Read(*.p12)",
      "Write(*.sh)",
      "Bash(chmod *)",
      "Bash(chown *)"
    ],
    "defaultMode": "default"
  }
}
```

**Rationale:**
- `default` mode: everything not explicitly allowed requires approval
- Minimal allow list: only read-only commands and tests
- No `npx` -- prevents arbitrary package execution
- No `npm publish` -- prevents accidental/malicious package publishing
- Script writes denied: prevents creating executable scripts
- Permission changes denied: no `chmod`/`chown`
- Broadest network deny: all outbound commands blocked
- Adapt: add project-specific test commands, consider denying `Write` for `*.yml` / `*.yaml` (CI config)

---

## Common Deny Rules (all profiles)

These should be present in every profile. Copy into the deny list and adapt paths.

```json
[
  "Read(*/.env)",
  "Read(*/.env.*)",
  "Read(*/credentials*)",
  "Read(*.pem)",
  "Read(*.key)",
  "Read(~/.ssh/*)",
  "Read(~/.aws/*)",
  "Bash(rm -rf *)",
  "Bash(git push --force*)",
  "Bash(git reset --hard*)",
  "Bash(curl*)",
  "Bash(wget*)"
]
```

### Adding harness isolation (when AEH is in use)

If the project is managed by AEH, add a deny rule for the harness directory to prevent the target agent from reading harness files:

```json
"Read(/path/to/agentic-engineering-harness/*)"
```

Replace with the actual harness path. This prevents:
- Reading other target project assessments
- Reading transformation plans and prompt strategies
- Accessing harness-internal templates and governance criteria
- Breaking the two-project isolation model

### AEH-side fence (target-orchestrator session -> target)

This is the SYMMETRIC half of the rule above. The rule above keeps the TARGET
agent out of the harness; this keeps the AEH-side session (the
`target-orchestrator`, running in the harness root) out of the target tree
EXCEPT the one allowlisted delivery channel, `<target>/docs/AE/**`. It is the
enforced form of the `docs/AE/`-only fence (CLAUDE.md § "The enforced
`docs/AE/`-only fence"). `aeh-engineer` and `harness-reviewer` get NO target
access; only the target-orchestrator session gets the `docs/AE/` carve-out.

Embed in the AEH harness project's own `.claude/settings.json` (substitute the
real absolute target path):

```json
{
  "permissions": {
    "allow": [
      "Read(/abs/path/to/target/docs/AE/**)",
      "Write(/abs/path/to/target/docs/AE/**)",
      "Edit(/abs/path/to/target/docs/AE/**)"
    ],
    "deny": [
      "Read(/abs/path/to/target/.env*)",
      "Read(/abs/path/to/target/.git/**)",
      "Write(/abs/path/to/target/.git/**)"
    ]
  }
}
```

The target-orchestrator session's working directory is the harness root, so the target
tree is outside it and reachable only through explicit rules: the `docs/AE/**`
allow is the only grant, and anything else target-side falls to the default
`ask` posture (it cannot be written silently). The explicit deny rules harden the
sensitive areas (secrets, git internals) against an accidental allow.

> **Design call (B6, for operator ratification) -- the airtight "deny everything
> else target-side" shape is DEFERRED.** Deny takes precedence over allow (see
> `permissions.md`), so a blanket `Deny(Read(/abs/path/to/target/**))` would also
> kill the `docs/AE/**` allow -- you cannot express "allow docs/AE, deny the rest"
> as one allow + one blanket deny. The enforceable shape shipped here is
> **allow `docs/AE/**` + specific sensitive-path denies + default-`ask` for the
> remainder** -- which prevents silent out-of-channel writes and is what
> `target-aeh-reviewer` polices (it flags an EFFECTIVE grant exceeding `docs/AE/`,
> regardless of how it is expressed). A fully-locked-down, negation-based
> expression needs the Claude Code permission-schema / repo-owner conversation and
> is deferred with the rest of the concrete propagation/permission mechanism.
> Until then: the allowlist above + the reviewer's fence-policing dimension are
> the enforcement.

---

## Adapting Baselines to Target Projects

When generating a permission governance prompt for a target project:

1. **Start with the appropriate profile** based on project context (solo/team/open-source)
2. **Replace package manager commands** (`npm` -> `yarn`, `pip`, `cargo`, `bun`, etc.)
3. **Add project-specific test commands** (e.g. `Bash(pytest*)`, `Bash(cargo test*)`)
4. **Add project-specific deny rules** (production DB hosts, deployment commands, etc.)
5. **Add harness isolation deny rule** if project is managed by AEH
6. **Record the chosen baseline** in the target's `profile.md` under `## Permission Baseline`
7. **Document any deviations** from the baseline with rationale as a `[DECISION]` entry in the target's `journal.md`
