---
captured-at: 2026-06-15T12:05:45Z
captured-from: e7660dfe2ec1
captured-during: target orchestrator session, eyeball stack bring-up
area: template
status: untriaged
---

# Stack-bringup prompts assume `pkill` and trust port-liveness as green

**Trigger:** A target eyeball-capture prompt's "kill stale servers (pkill, non-fatal)" step silently no-op'd in a sandbox that lacks `pkill`/`lsof`/`fuser` (only `ss` available). The freshly-launched stack then crashed on a port-in-use error while a stale prior-session server kept answering HTTP 200 on the expected port, producing a false-green the agent only caught by reading the launch log -- not from the curl checks.

**Insight:** Two non-portable assumptions are baked into harness eyeball / stack-bringup guidance and prompt templates: (a) `pkill -f` exists for teardown -- some containers only have `ss`, so the kill step silently no-ops (exit 127) and the box is never actually cleaned; (b) an HTTP 200 / open port proves the stack you just launched is the one answering -- it does not. Port-liveness is not process-ownership. Together they let an agent eyeball a STALE build and report it clean -- a correctness failure, not a cosmetic one.

**Suggested change:**
- Eyeball / stack-bringup guidance must teardown BY-PID via whatever the container has (do not assume `pkill`), assert ports clear, then validate PROCESS OWNERSHIP before declaring green: the launched PID matches the listener, scan the launch log for crash markers, and detect silent port-bumps.
- Promote recurring stack-bringup from prose steps to a hardened per-target script/skill. The load-bearing validation is procedural; a markdown instruction cannot prevent the false-green.
- Do not hardcode a health path or assume `.env` is greppable: a DB-gated `/health` can be 503 in a sandbox while a lighter liveness endpoint is the right probe, and a deny-listed `.env` must be read key-by-key programmatically, not via cat/grep.

**Memory updates:** codified orchestrator-side as `feedback_stack_bringup_prove_process_ownership`. This intake propagates the same into the harness prompt templates (e.g. the eyeball / regression-check templates that currently say `pkill -f vite`) and the relevant onboarding/health-check playbook steps.
