---
captured-at: 2026-05-31T18:46:00Z
captured-from: 77c32eea48bc
captured-during: target orchestration -- running an autonomous multi-prompt chain while also fielding interactive operator questions
area: orchestrator-persona
status: promoted
promoted-to: chain-fabric-lift
promoted-at: 2026-06-01T11:30:00Z
---

# Orchestrator should have two explicit modal states (interactive / prompt-chaining) + documented chain fabric

**Trigger:** The orchestrator persona describes multi-prompt chains in detail but
treats "running a chain" and "talking to the operator" as the same undifferentiated
mode. In practice the orchestrator is continuously in one of two distinct postures,
and the chain-execution fabric (wrapper script, heartbeat, monitor helper, launch +
watch procedure) is specified only as prose pattern -- no shippable artefact and no
"here is how you operate it" description. A target orchestrator currently re-derives
the whole launch/monitor mechanism from scratch each time, and there is no clean
vocabulary for "I am driving an unattended chain right now" vs "I am in a live
back-and-forth with the operator."

**Insight:** Two improvements, related:

1. **Modal states.** Name two explicit orchestrator modes and make the persona say
   what changes between them:
   - *Interactive* -- live operator dialogue; propose/clarify/hand-off; the operator
     owns the clock between turns.
   - *Prompt-chaining* -- an autonomous multi-prompt chain is executing off-screen;
     the orchestrator owns the clock, monitors via scheduled wakeups, and surfaces
     only on halt/completion. The four end-states already exist
     (DONE/DECISION-NEEDED/MONITORING-BACKGROUND/PAUSED-ON-YOUR-WORK); the modal
     states sit above them (MONITORING-BACKGROUND is the natural end-state while in
     prompt-chaining mode). The two modes interleave: the operator can ask questions
     mid-chain (as happened here) -- the orchestrator answers in interactive mode
     without disturbing the chain it is monitoring.

2. **Document the chain fabric as operable requirements, not just a pattern.** The
   persona's "Execute via a chain wrapper" bullet names the shape (PROMPTS array,
   JSONL stream, watchdog, sentinel) but a target orchestrator needs to know: what
   the helper scripts ARE, what each does, and the concrete launch + monitor
   procedure. Minimum to specify:
   - *Chain wrapper* (`aeh-overnight*.sh` / `targets/<slug>/deliverables/*.sh`):
     PROMPTS array; per-step `claude --print --verbose --output-format=stream-json`;
     pre-flight gate block; per-step commit-baseline + post-step zero-commit /
     non-zero-exit checks; watchdog loop (wall-clock cap, mtime-idle kill, sentinel
     scan via jq over assistant-text only); incremental summary markdown.
   - *Heartbeat helper* (rolling one-line/min digest to a `chain-status.log` the
     operator can `tail -f`; START banner + CHAIN-ENDED-on-wrapper-exit so the log
     never looks falsely live; auto-started by the wrapper).
   - *Monitor helper* (live model-text follower: tails the newest step JSONL through
     a jq assistant-text filter; auto-follows step rollover).
   - *Launch + monitor procedure*: launch detached (background Bash, NOT nested
     nohup, to preserve the notification path); record baseline commit count +
     wrapper PID; schedule periodic wakeups (20-30 min, or shorter cache-warm ticks
     near expected completion); read state from git log + JSONL mtime + launch log,
     never from projection.

**Whether to LIFT the scripts is the intaking session's call (with the operator).**
This capture deliberately does NOT assert the scripts must ship as templates. It
asserts the orchestrator persona should (a) carry the two modal states and (b)
describe the fabric well enough that a target orchestrator can BUILD its own
wrapper/heartbeat/monitor from requirements -- and know it is expected to, with
operator approval, rather than treating ad-hoc authoring as off-piste. If the
intaking session + operator decide a shippable `aeh-overnight.sh.template` +
`heartbeat.sh` + `monitor.sh` are worth lifting, that is a follow-on scope decision,
not a precondition of this change.

**Suggested change:**
- Orchestrator persona: add a "Modal states" subsection (interactive vs
  prompt-chaining; how they interleave; relation to the four end-states).
- Orchestrator persona (Multi-prompt chain section): expand "Execute via a chain
  wrapper" into a requirements-level description of the wrapper + heartbeat +
  monitor helpers and the launch/monitor procedure, with an explicit note that a
  target orchestrator may and should author these per-target on operator approval.
- Optional follow-on (intaking-session decision): lift reference implementations
  into `templates/scripts/` (a multi-prompt `aeh-overnight.sh.template` alongside
  the existing single-prompt `loop-driver.sh.template`, plus heartbeat/monitor).

**Memory updates:** relates to `feedback_autonomous_run_monitoring_gap` (launch via
direct Bash run_in_background + ScheduleWakeup; nested nohup breaks notifications),
`feedback_claude_print_streaming_pattern` (stream-json + JSONL heartbeat + mtime
watchdog), `feedback_autonomous_launch_visibility_pattern`. Sibling to the
2026-05-31 reviewer-prompt-commit-step capture (both harden the chain fabric).
