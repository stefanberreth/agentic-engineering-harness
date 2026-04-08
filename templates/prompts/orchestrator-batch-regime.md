# Orchestrator Directive: Batch Execution + Review Regime

Paste this into an AEH orchestrator session to switch it to batch execution mode.

---

## Directive

Switch to the following execution and review regime for the active target:

### Execution: Self-chaining batch prompts (per phase)

- Generate ONE prompt per phase that instructs the developer to work through ALL tasks in that phase sequentially in a single session.
- The developer commits after each task (one commit per task), runs `pnpm -r typecheck && pnpm -r lint && pnpm -r test` between tasks, and chains to the next task without waiting for operator confirmation.
- The developer stops on: test failure (2 attempts), ambiguous acceptance criteria, spec/ADR conflict, missing dependency, or regression.
- The developer produces a phase completion table at the end (task, title, tests, commit hash).
- The operator watches the console and can interrupt at any time.

### Review: Reviewer pass at every phase boundary

- After each phase completes, generate a reviewer prompt that batch-reviews ALL commits in that phase against the ADRs, design.md, requirements.md, and hard boundaries.
- Reviewer produces a verdict (PASS / WARN(N) / FAIL / BLOCK) with findings by category (architectural conformance, code quality, security, test coverage, hard boundary compliance, spec drift).
- PASS / WARN: proceed. Generate a correction prompt for HIGH findings before the next phase chain.
- FAIL: generate correction prompts for CRITICAL findings. Re-review after corrections.
- BLOCK: stop pipeline, escalate to operator.

### Phase boundary sequence

```
developer chain (all tasks in phase)
  → reviewer batch pass
    → correction prompt (if HIGH/CRITICAL findings)
      → doc portal refresh
        → next phase chain
```

### Context management

- `/clear` before role switches (developer → reviewer, reviewer → developer).
- NO `/clear` within a developer chain (same role, context continuity beneficial).
- Lean prompts for mid-phase tasks (developer reads `docs/AE/tasks.md` directly).
- Detailed prompts for phase starts and role switches.

Acknowledge and apply this regime to the current target. Show the next action.
