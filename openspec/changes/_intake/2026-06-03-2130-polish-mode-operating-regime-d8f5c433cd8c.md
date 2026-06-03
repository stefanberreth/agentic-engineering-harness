---
captured-at: 2026-06-03T21:30:00Z
captured-from: d8f5c433cd8c
captured-during: harness orchestrator session, target waitlist-feature boundary push
area: orchestrator-persona / developer-persona / operating-regimes
status: promoted
promoted-to: archive/2026-06/polish-mode-operating-regime
promoted-at: 2026-06-03T22:50:00Z
archived-at: 2026-06-03T23:00:00Z
---

# Third operating regime: Polish Mode (low-friction tactical iteration alongside spec-first default)

**Trigger:** Operator, mid waitlist boundary push, asked for a working mode that suspends the spec-first ceremony (analyst -> architect -> developer -> reviewer) in favour of direct operator-developer dialogue for tactical visual / copy / layout / token-swap adjustments. Quote: "I want to suspend the spec-first ceremony in favor of an interactive dialogue with the developer to make immediate changes to copy and layout as I review (text prompts, console stack pastes and screenshots delivered to the screenshots/ subdir of the project) without looping through a full Analyst-architect-developer-reviewer cycle for each. Once done (or done enough), the changes should be committed with some suitable after-the-fact openspec records committed and pushed with the code changes in one go."

**Insight:** Spec-first ceremony exists for substantive changes (data model, API, business logic, acceptance criteria). It produces drift, missed ACs, and unauditable history when applied to tactical visible-surface adjustments where the operator's intent IS the spec and the operator's eyeball IS the reviewer. The harness currently has no recognised mode for this; operators either bypass the ceremony informally (creating undocumented drift) or burn 4 prompts per text tweak (frustration -> eventually bypass anyway). Neither is good.

The orchestrator persona has two existing regimes (Regime 1 prompt-by-prompt, Regime 2 batch + phase-boundary review). Neither covers live operator-developer dialogue on a bounded surface.

**Proposed regime (full design):**

1. **Name:** Polish Mode (alternative names worth considering during triage: Tactical Iteration Mode, Co-Pilot Mode, Live-Dialogue Mode).

2. **Activation:** explicit phrase from operator naming surface + change-slug. Examples: "polish mode on for waitlist UI", "tactical iteration on questionnaire copy". Orchestrator emits a polish-mode handoff prompt to the target developer.

3. **Scope (BOUNDED):**
   - In scope: copy text, layout micro-adjustments (padding / spacing / typography), token swaps within existing token set, minor UX wording, screenshot-driven visual tuning, tweaks to placeholder content, accessibility wording.
   - Out of scope (developer halts + exits mode if attempted): API shape changes, data-model changes, new tests' substantive assertions, new dependencies, new files outside the touched surface, anything that changes acceptance criteria, schema changes, security boundary changes.
   - The developer holds the boundary. A substantive request causes the mode to exit and fall back to spec-first (analyst -> architect cycle for the new substantive change).

4. **Live-dialogue affordances enabled while mode is on:**
   - Operator types observations + screenshot paths (under `docs/screenshots/` or the AEH-conventional path) + console pastes directly in target chat.
   - Developer applies changes immediately, reports the diff verbatim, does NOT halt for spec confirmation.
   - Vite HMR / dev-server is the operator's verify loop.
   - Conversation + screenshots stay in the target session transcript as the natural audit trail.

5. **Exit conditions:**
   - Operator says "polish complete" / "exit polish mode" / "lock it down".
   - OR a substantive change is attempted -- developer halts, mode exits automatically, falls back to spec-first.
   - OR session ends (Claude exits, host reboot, etc.) -- mode auto-exits; reactivation requires a new polish-mode handoff.

6. **Exit ceremony (the audit-trail capture):**
   a. Developer drafts a single polish-session log at `docs/AE/reports/polish-<surface>-<YYYY-MM-DD>.md` summarising: what changed (file-by-file), what the operator's intent was (paraphrased from the live dialogue), which screenshots drove decisions, the final state of each touched surface.
   b. Orchestrator (or developer at mode-exit) picks the openspec record shape based on scope:
      - **Amend active CP's revision history** when polish touches a single in-flight change-slug (e.g. waitlist `v0.3 -> v0.4` with polish-pass entry in design.md Sec 9).
      - **Open a `<surface>-polish-<YYYY-MM-DD>` change-slug** when polish is broader or touches multiple change-slugs. Minimal proposal/design/tasks reflecting what landed.
   c. Single batch commit (or small natural splits) with all polish diffs + the polish-session log + the openspec record.
   d. Lightweight reviewer pass (NOT a full 10-dimension walk): focused "polish-review" confirming scope-no-creep, no test regression, tokens-only, eslint/tsc clean, commits clean.
   e. Push (if push-in-boundary applies).

**Why this preserves the discipline:**
- Boundary is named, not implicit.
- Developer holds the scope boundary -- substantive requests halt the mode rather than getting smuggled in.
- Audit trail captured retrospectively in one document plus an openspec record.
- Lightweight reviewer pass still gates the commit.

**Suggested changes:**

1. `templates/personas/orchestrator.md` -- new section "Polish Mode" alongside the existing Operating Modes (Regime 1 / Regime 2). Covers activation phrase, scope, exit ceremony, openspec-record decision tree, when polish-mode is and is not appropriate.
2. `templates/personas/developer.md` -- new section "Polish Mode affordances and boundaries". Live-dialogue allowed, screenshot-paste handling, scope-boundary halting, exit-ceremony obligations.
3. `templates/prompts/polish-mode.md.template` -- canonical session-wrapper prompt the orchestrator instantiates per polish session.
4. `templates/governance/review-criteria.md` -- a "polish-pass review" lightweight rubric distinct from the full review-criteria, so reviewer prompts know which mode to apply.

**Open questions for triage:**
- Should polish-mode log + openspec record be authored by the same developer agent at mode-exit, or routed to a fresh agent (analyst-style retrospective) to keep the polish work and the audit work separate? Probable answer: same developer, since they have the context; the lightweight reviewer pass catches misrepresentation.
- Should there be a maximum session-duration or maximum diff size before polish-mode auto-exits? Possible guard against substantive change slipping in over a long polish session. Probable answer: no hard limit; rely on the scope-boundary discipline and reviewer pass.
- Should the polish-mode handoff prompt name the screenshots-dir convention explicitly so operator and agent agree on path? Probable answer: yes; include in the template.

**Memory updates:** None directly -- this is harness-design.

**Related captures:**
- The eyeball-support-session-logistics intake (2026-06-03 17:40) -- adjacent operating-mode capture; same theme of "encode operator-facing mode in persona templates so it's not re-derived per session".
- The placement-discipline (archived) -- adjacent "make implicit discipline explicit" theme.

**Pragmatic implementation note:** The operator wants to exercise polish-mode RIGHT AFTER the current T1-T10 boundary push completes (CI pipeline ~20-30 min). The first exercise of the mode is the immediate next prompt. The persona / template updates land as a separate harness improvement pass after the polish session validates the design.

**Two-bucket feedback triage (refinement 2026-06-03 21:50):** Every operator-feedback item during a polish session falls into one of two buckets, and the developer (or orchestrator if ambiguous) routes it explicitly:

1. **IMMEDIATE-FIX bucket.** Feedback that has an obvious direction or asks a simple answerable question -> developer fixes immediately on the DEV system. Operator confirms via vite HMR / browser reload. The spec record is captured AFTER-THE-FACT as an intake entry (or as part of the polish-session log + the eventual openspec record at mode-exit). No spec-first ceremony required because the operator's intent IS the spec for this fix class.

2. **DEFERRED-TRIAGE bucket.** Feedback that is QA-quality concern -- substantive UX questions, data-model implications, AC reversals, cross-surface implications, anything that smells like "this needs proper analyst-architect-developer cycle to handle". Developer does NOT fix immediately; captures the item into an intake bucket (e.g. `reel-to-spec/`-style session dir, or a polish-session "deferred-items.md", or directly into `openspec/changes/_intake/`) for later triage and pipelining into the standard spec-first regime.

The developer's judgement call -- "immediate or deferred?" -- is the polish-mode boundary. The same scope rule applies: if the developer cannot confidently fix immediately, the item is deferred. The developer surfaces the bucket choice in chat so the operator can override (e.g. "actually, defer that copy change too, I'm not sure yet").

Mode-exit ceremony updated:
- Polish-session log lists IMMEDIATE-FIX items (with diffs) and DEFERRED-TRIAGE items (with captured intake references).
- The openspec record at mode-exit covers the IMMEDIATE-FIX bucket (amendment to active CP or new polish-slug).
- DEFERRED-TRIAGE items live as separate `openspec/changes/_intake/` entries OR a single consolidated intake covering the session's deferred bucket, depending on volume.
