---
captured-at: 2026-05-31T19:10:00Z
captured-from: 77c32eea48bc
captured-during: target orchestration -- <target-A> orchestrator built its own chain fabric from the prior intake's requirements (sibling note 2026-05-31-1846-orchestrator-modal-states-chain-fabric)
area: orchestrator-persona, chain-fabric, multi-prompt-monitoring
status: promoted
promoted-to: chain-fabric-lift
promoted-at: 2026-06-01T11:30:00Z
---

# Compare <target-A>-built chain-fabric implementation against the hex sister-project implementation BEFORE raising any lift-to-templates change spec

**Trigger:** Sibling intake `2026-05-31-1846-orchestrator-modal-states-chain-fabric-*` was captured by the hex orchestrator and described the chain fabric in requirements form (PROMPTS array; per-step `claude --print --verbose --output-format=stream-json`; pre-flight gate; commit-baseline check; sentinel scan via jq over assistant text; watchdog loop with wall-clock cap + mtime-idle kill; heartbeat helper writing rolling digest to a tail-able status log; monitor helper following the JSONL through jq assistant-text filter; launch as direct background Bash, NOT nested nohup, to preserve notification path). The <target-A> orchestrator then built its own implementation from those requirements + own memory entries (`feedback_autonomous_run_monitoring_gap`, `feedback_claude_print_streaming_pattern`, `feedback_autonomous_launch_visibility_pattern`), tested it with 4/4 mock plumbing + 1/1 real-claude smoke, and is now live on a 3-prompt chain for the hygiene CP closure.

The <target-A> impl lives at `targets/<target-A>/deliverables/scripts/`:
- `aeh-overnight.sh` -- wrapper (single file; folds heartbeat inline rather than as separate helper)
- `aeh-monitor.sh` -- operator live follower (auto-detects newest session JSONL, auto-follows step rollover)
- `README.md` -- operating procedure with modal-state vocabulary
- `test/mock-claude.sh` + `test/test-plumbing.sh` + `test/smoke-prompt.md` -- test fixtures
- `runs/<TS>-<run-name>/` -- per-run artefacts: `manifest.json`, `step-NN-stdout.jsonl`, `step-NN-summary.txt`, `chain-status.log` (machine-parseable), `progress.log` (human-readable for `tail -F`), `wrapper.log`

A hex impl also exists (per the sibling intake's mention of `aeh-overnight*.sh` and `targets/<slug>/deliverables/*.sh`). Two independent implementations of the same requirements -- a natural diff opportunity before lifting either into `templates/scripts/`.

**Insight:** Lifting either implementation directly into `templates/scripts/` without a structured side-by-side comparison locks in design choices that the other implementation may have arrived at differently for good reasons. The harness benefits from a deliberate convergence pass: surface the divergence points, decide each on its merits, then lift the converged design. This is cheap to do now (both implementations are fresh) and expensive to do later (each implementation will accrete bug-fixes + extensions targeting its specific shape).

**Specific divergence points compared (hex column filled in via hex orchestrator report 2026-05-31; durable findings at `targets/hex/findings/2026-05-31-chain-fabric-impl-comparison-hex-column.md`):**

| Dimension | <target-A> choice | hex choice |
|---|---|---|
| Wrapper structure | One reusable `aeh-overnight.sh` driven by positional args + env (PROMPTS, estimates); one wrapper for all chains | One wrapper per chain, hand-cloned (`aeh-hex-chain-A.sh` through `-M.sh`, 15 to date) -- PROMPTS hard-coded as bash array in each |
| Heartbeat helper | Folded into wrapper as background bash loop; writes to `chain-status.log` (machine) + `progress.log` (human, dual Zulu/local timestamps + step counter + velocity-based ETA) | Separate shared script `.runs/heartbeat.sh` auto-started by wrapper; writes to a single SHARED stable-path file `.runs/chain-status.log` (append-only, across ALL chains) |
| Liveness helper | None (jsonl_age in progress.log heartbeat) | `.runs/alive.sh` -- portable macOS+Linux one-shot using `date -r`; operator runs from inside or outside container |
| Monitor helper | Separate `aeh-monitor.sh`; tails newest `~/.claude/projects/<encoded-cwd>/*.jsonl` through jq for assistant-text; detects step rollover via `.current-step` marker | None (no live model-text follower) |
| Per-step output capture | `claude -p ... --output-format stream-json --verbose --include-partial-messages` piped to `step-NN-stdout.jsonl` | `claude --print --verbose --output-format=stream-json --dangerously-skip-permissions "Read and execute docs/AE/prompts/${prompt}.md" > step_log 2>&1 &` -- no `--include-partial-messages`; same Read-and-execute one-liner pattern |
| mtime-idle watchdog source | Watches `~/.claude/projects/<encoded-cwd>/*.jsonl` (session JSONL; bulletproof per `feedback_claude_print_streaming_pattern` -- pulses even during rate-limit retries) | Watches the wrapper's own stdout capture `chain-<X>-<TS>-step-<N>-<prompt>.jsonl` -- **hex acknowledges this is the weakest point**, can false-halt during long claude internal retries (stdout silent, session jsonl still alive) |
| Sentinel scan | **First-cut: open regex `CHAIN_HALT\|HALT-[A-Z]+`.** Patched 2026-05-31 to require dash separator (`(CHAIN_HALT\|HALT-[A-Z][A-Z_-]*)[[:space:]]+(--\|—)`) after a real false-positive: 087 reviewer narrated "I caught and discarded a bogus `CHAIN_HALT` draft" inside backticks; open regex matched; chain halted spuriously AFTER a clean PASS commit (`e4701c6`) had already landed. Tighter pattern restored. Also matches `PROMPT COMPLETE -- NNN` for success sentinel via grep -oE. | Same jq filter grepped for literal sentinel `<<<CHAIN_HALT>>>` -- deliberately bracket-wrapped so the prompt body's literal echo doesn't false-trip a whole-jsonl grep, AND so reviewer self-narration about sentinels doesn't trip either. **Hex's bracketed-sentinel approach is the structurally cleaner solution; <target-A>'s dash-required tightening is a partial fix that still relies on emission conventions.** Converged template should adopt bracketed sentinel + migrate all existing prompts to emit `<<<CHAIN_HALT>>>`. |
| Pre-flight gate | target-dir exists; claude binary exists; jq exists; all prompt files exist (built into wrapper) | Pluggable multi-gate (also checks dirty tree explicitly with its own exit code 3); RED gate exits 2 |
| Commit-delta accounting | Per step records `commits_added` in summary; no zero-commit halt (review-only steps legitimately produce 1 commit while heavy steps produce many) | Includes a **zero-commit HALT guard** -- `HALT-zero-commits-step-N` fires if a step that should have produced commits produced none. Catches the silent-step failure mode. |
| Exit-code vocabulary | Granular: 0=ok, 2=sentinel-halt, 3=non-zero-step, 4=mtime-idle, 5=wallclock, 6=preflight, 7=usage | Coarse: 0 all PASS, 1 cd-fail, 2 pre-flight RED, 3 dirty tree, 4 ANY mid-run HALT. Specific halt type lives in an `overall_status` string in the launch log: `HALT-sentinel-step-N` / `HALT-mtime-idle-step-N` / `HALT-nonzero-exit-step-N` / `HALT-zero-commits-step-N` / `HALT-wallclock[-mid-step-N]`. |
| ETA computation | Velocity ratio (actual/estimate over completed steps) applied to remaining; initial estimates seeded via `AEH_STEP_ESTIMATES_SEC` env -- ETA is meaningful from t=0 | `avg = done_secs / completed_steps`, then `eta = avg × remaining_steps − time_in_current_step`. No env-seeded initial estimate, so ETA shows `?` during step 1 (no completed step to project from). |
| Locale / timezone handling | `AEH_LOCAL_TZ` + `AEH_LOCAL_TZ_LABEL` env-driven; emits dual Zulu + local timestamps on every progress line | UTC/Zulu only (`date -u` everywhere; no local TZ) |
| Wall-clock caps | Per-step cap (default 3h) + total cap (default 12h) | Total only, no per-step cap (chain-M = 3h, chain-L = 6h). The 15-min mtime-idle effectively bounds single-step silence. |
| claude CLI rate-limit handling | The session-JSONL watchdog mitigates -- session pulses even during retries | Relies on 15-min mtime-idle being generous enough; can false-halt on long retries (because it watches stdout, not session jsonl). The single highest-value <target-A> contribution to take into convergence. |
| Modal-state vocabulary in operator-facing doc | README documents two explicit modes (interactive / prompt-chaining); interleaving rules; mode-transition handshake | Not documented as such (lives implicitly in `orchestrator-state.md` per chain) |
| Launch mechanism (intent) | Direct backgrounded Bash via orchestrator's Bash tool (`run_in_background=true`); NO nested nohup | Same intent (direct bg Bash, no nohup) -- hex notes a recent session slip where nested `nohup bash wrapper &` was used inside the bg call and broke the completion-notification path; corrected since. |
| Prompt list passing | Positional CLI args; orchestrator can launch any prompt sequence without editing the wrapper | Hard-coded bash array in each per-chain wrapper -- requires hand-clone for each new chain |
| Run artefacts layout | Per-run subdir `runs/<TS>-<run-name>/` containing `manifest.json` + `step-NN-stdout.jsonl` + `step-NN-summary.txt` + `chain-status.log` + `progress.log` + `wrapper.log` -- isolated per run | FLAT in `.runs/`: per-step JSONLs named `chain-<X>-<TS>-step-<N>-<prompt>.jsonl`; per-chain launch log `chain-<X>-<TS>.log`; the SHARED `chain-status.log` across all chains; `.summaries/chain-<X>-<TS>.md` for the digest. No per-run subdir. |
| Recovery / re-attach mid-chain | `manifest.json` carries `wrapper_pid` + full launch state for reconstruction | `orchestrator-state.md` records wrapper PID + launch log path + baseline commit (no `manifest.json`); reconstruction via `/proc/<pid>` + launch log + git log. |
| Cheap orchestrator state check (token economy) | Reads small files: `progress.log` tail (~10 lines), `chain-status.log` tail, step-NN-summary.txt for completed steps. Multi-MB JSONLs never read in full on a tick. | Same pattern: `/proc/<pid>` for liveness; `git log --oneline baseline..HEAD` for commit truth; grep `'### Step\|PASS\|HALT\|Final\|Status:'` over the ~1-2 KB launch log; tail of shared `chain-status.log`. JSONLs only read for halt diagnosis via the same jq assistant-text filter. |
| Operator monitor handoff form (THE UX WIN) | **<target-A>: clunky.** Absolute path with embedded run timestamp -- changes per chain, operator must copy-paste each time. Speculated symlink fix was wrong direction. | **hex: stable-path pulse file.** `.runs/chain-status.log` -- ONE shared append-only file across ALL chains, stable path operator memorises and tails forever. Each chain writes a `HEARTBEAT START chain-X` banner + per-60s lines + `CHAIN ENDED chain-X` banner. Operator's command is the same string every time, inside or outside container (`tail -f /workspace/aeh/targets/hex/deliverables/.runs/chain-status.log` inside, equivalent bind-mounted host path outside). **This is the actual operator-UX win.** |
| Test strategy | Two layers: mock-claude with `AEH_TEST_MODE` env (zero API spend; verifies exit-code vocabulary across happy/sentinel/non-zero/mtime-idle); single real-claude smoke prompt for end-to-end | None documented |

## Convergence recommendation (ready-for-triage)

The two implementations have complementary strengths. Hex's own assessment matches the <target-A> read of the table. The converged template at `templates/scripts/` should take:

**From <target-A>:**
- Session-JSONL watchdog (not stdout-capture watchdog) -- the single highest-value robustness contribution; eliminates the rate-limit false-halt class
- Granular numeric exit codes (2/3/4/5/6/7) -- machine-parseable distinction without string grep
- Env-seeded initial ETA via `AEH_STEP_ESTIMATES_SEC` -- meaningful ETA from t=0, not just from step 2 onward
- Dual-timezone timestamps via `AEH_LOCAL_TZ` -- portable to any operator locale
- Mock-claude test layer (`AEH_TEST_MODE` env-driven) + plumbing test script -- regression safety net for wrapper edits without API spend
- README documenting the two explicit modal states (interactive / prompt-chaining) and the mode-transition handshake -- prevents the orchestrator from drifting into "monitoring as background process while still in interactive posture" confusion
- `manifest.json` per run -- recovery state in one file, machine-readable

**From hex:**
- **Stable-path pulse file** (`.runs/chain-status.log`, single shared append-only across all chains) -- the operator-UX win that <target-A> missed. Operator memorises the path once, tails it across every chain, inside and outside container.
- Rich `overall_status` halt-string (`HALT-sentinel-step-N` / `HALT-mtime-idle-step-N` / etc.) kept ALONGSIDE granular exit codes -- belt-and-braces; machines read the code, humans read the string
- **Zero-commit HALT guard** -- catches the silent-step failure mode <target-A>'s accounting only reports; HALT semantics make it actionable
- Pluggable multi-gate pre-flight (dirty-tree gate as its own exit code, not folded into generic pre-flight FAIL)
- `alive.sh` portable one-shot liveness (macOS+Linux via `date -r`) -- complements rolling pulse with a synchronous check

**Resolve differently than either:**
- Wrapper structure: <target-A>'s single reusable wrapper + positional args is the right shape (hex hand-clones; that's drift waiting to happen). Take <target-A>'s shape and bake in hex's stable-path pulse file as a SECOND log alongside the per-run `progress.log` (keep both -- per-run for isolation, shared for stable-path UX).
- Per-step wall-clock cap: keep <target-A>'s (it composes with hex's total cap; the redundancy catches different failure shapes).

**Lift plan:**
1. New OpenSpec change proposal: `openspec/changes/chain-fabric-lift/` with `proposal.md` + `design.md` + `tasks.md`. Reference this intake + the sibling 2026-05-31-1846 intake + the hex findings file.
2. Template artefacts at `templates/scripts/`:
   - `aeh-overnight.sh.template` (converged wrapper)
   - `aeh-heartbeat.sh.template` (split out per hex, but writing BOTH `progress.log` and shared `chain-status.log`)
   - `aeh-monitor.sh.template` (<target-A>'s live model-text follower; optional but small)
   - `aeh-alive.sh.template` (hex's portable one-shot)
   - `mock-claude.sh.template` + `test-plumbing.sh.template` (<target-A>'s test layer)
   - `chain-fabric.md` (requirements + procedure + modal-state vocabulary, lifted from <target-A>'s README)
3. Orchestrator persona update (the sibling intake's scope): point to `templates/scripts/chain-fabric.md`; add the modal-state subsection.
4. Both targets seed their own copies from the templates; deprecate the per-chain hex hand-clones in favor of the reusable wrapper.

**Lift deferred until operator confirms** the convergence plan. This is a harness-template change; it goes through a normal harness-improvement session per `feedback_orchestrator_captures_not_fixes_harness` (orchestrator captures findings; harness-improvement session writes templates).

**Suggested approach:**

1. **Triage step 1:** Operator-mediated read-through of both implementations side-by-side. Each divergence point gets a decision (`<target-A>` / `hex` / `merge` / `revisit`). Decisions captured in a short convergence-notes file.
2. **Triage step 2:** Open an OpenSpec change proposal under `openspec/changes/<slug>/` named e.g. `chain-fabric-lift` with the converged design as the proposed `templates/scripts/aeh-overnight.sh.template` + `aeh-monitor.sh.template` + `chain-fabric.md` (requirements + procedure). Reference the sibling intake `2026-05-31-1846-orchestrator-modal-states-chain-fabric-*` for the requirements baseline.
3. **Triage step 3:** Decide whether the orchestrator persona's chain-execution subsection should be UPDATED (point to the templates) or REPLACED (inline the operating procedure). Sibling intake's "Suggested change" already includes the modal-states subsection -- keep that scope, fold the fabric-pointer in.

**Whether to LIFT remains an explicit decision after comparison.** The two implementations may have legitimately different shapes (different target conventions, different observed failure modes during their respective use). The comparison may conclude (a) one implementation is strictly better -- lift it; (b) implementations differ meaningfully -- lift a converged design; or (c) implementations differ for target-specific reasons -- do NOT lift, document the rationale for keeping target-local. All three outcomes are valid and should be captured in `decisions.md`.

**Why this needs explicit capture (rather than "obviously do a comparison"):** Without a captured intake, the next harness-side session may see only the <target-A> impl + the requirements intake, conclude requirements are met, and lift <target-A>'s impl directly -- missing the parallel hex work. This is a coordination defect that lives between two target orchestrators, not inside either one's scope; the harness inbox is the right place to catch it.

**Memory updates / cross-references:**
- Sibling: `openspec/changes/_intake/2026-05-31-1846-orchestrator-modal-states-chain-fabric-77c32eea48bc.md` (the requirements baseline).
- Sibling: `openspec/changes/_intake/2026-05-31-1748-reviewer-prompt-commit-step-77c32eea48bc.md` (another hex capture from same day; both harden the chain fabric per the sibling's note).
- <target-A> implementation files: `targets/<target-A>/deliverables/scripts/` (build verified 2026-05-31 with 4/4 plumbing + 1/1 smoke PASS).
- Related operator feedback: `feedback_autonomous_run_monitoring_gap`, `feedback_claude_print_streaming_pattern`, `feedback_autonomous_launch_visibility_pattern`.
