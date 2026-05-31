---
slug: harness-capture-inbox
---

# Design: Harness Capture Inbox

## Context

Multiple orchestrator sessions run in parallel from separate Docker containers, all bind-mounting the same host harness directory. Insights about the harness itself surface organically during target work; until now there has been no robust capture path that doesn't rely on the operator shuttling text between sessions. The shared bind-mount is a clean transport channel for filesystem-mediated handoff — a capture file written in one container appears instantly in every other container's view of the harness tree.

This proposal stands alongside `harness-cross-container-isolation`. That sibling addresses contamination avoidance under the shared mount; this proposal embraces the shared mount as a feature for one specific use — capture transport — where the cross-visibility is desired.

## Mechanism

### Directory and filename

- Directory: `openspec/changes/_intake/` (the leading underscore sorts it visually distinct from real change-proposal directories like `harness-cross-container-isolation/`).
- Filename: `YYYY-MM-DD-HHMM-<short-tag>-<HOSTNAME>.md`.
- Hostname suffix: prevents collision when two containers capture at the same minute on the same topic. Filename is the only collision-avoidance layer; full attribution lives in frontmatter.

### File shape

```markdown
---
captured-at: 2026-05-31T14:23:00Z          # ISO 8601 UTC
captured-from: <container HOSTNAME>
captured-during: <brief context — e.g. "target session on project X" or "harness session triage">
area: orchestrator-persona | playbook | template | governance | bin | docs | other
status: untriaged                          # always 'untriaged' at write time
---

# <Short title>

**Trigger:** one or two sentences naming what session-context produced this insight.

**Insight:** one paragraph describing the harness-level observation. Target-detail-free.

**Suggested change:** 1-3 bullets sketching what the harness should do differently. Not a full proposal — that's what triage produces.

**Memory updates:** any `feedback_*.md` memory files this would supersede or extend, with old text vs new text where relevant.
```

### Atomic write protocol

To prevent a triage-side reader from observing a half-written file:

1. Capture-side orchestrator writes the full file content to `openspec/changes/_intake/.tmp.<filename>` first.
2. After write completes, `mv .tmp.<filename> <filename>` (atomic rename on the same filesystem).
3. Filenames starting with `.tmp.` are gitignored so they cannot accidentally commit.

### Capture-side behaviour (orchestrator persona, any session)

**Proactive identification, operator-gated capture.**

The orchestrator monitors conversation for harness-level insights — refinements to persona templates, gaps in playbooks, new patterns worth generalising, vocabulary changes affecting future sessions, mechanism improvements. When a candidate emerges:

1. **Proactively surface**: "This looks like a harness-level capture candidate. Want me to draft an inbox file?"
2. **Wait for operator confirmation** before writing. **Never capture silently.** Operator may say yes / no / "yes but to BACKLOG instead" (target context present) / "let me reword first".
3. On `yes` and target-detail-free: draft the capture file in the conversation for operator review, then write atomically to `openspec/changes/_intake/`.
4. On `yes but BACKLOG`: append to `BACKLOG.md` instead (operator's private triage scratchpad, target context permitted).
5. On `no` / silence / pushback: drop it; do not re-prompt for the same insight in the same conversation.

Explicit operator instruction ("capture this for the harness") follows the same flow from step 3.

The asymmetry — proactive identification but operator-gated capture — is deliberate. Proactive identification reduces operator cognitive load (orchestrator notices candidates the operator might miss mid-flow). The confirmation gate prevents inbox pollution and keeps editorial control with the operator. The cost is one prompt per candidate; the value is that the operator never has to remember to capture.

### Two landing points, distinguished at capture time

| Landing | When to use | Visibility |
|---|---|---|
| `openspec/changes/_intake/` | Insight is target-detail-free, fit for public review | Tracked, public on push |
| `BACKLOG.md` | Insight needs target context for motivational rationale; maintainer wants to scrub or shape before public exposure | Untracked, gitignored, private |

The maintainer can later cross-reference BACKLOG entries against inbox/proposal items when public reasoning needs private context to make sense. Both landings carry the same five-field body shape; only the frontmatter discipline (and the gitignore status of the file's home) differs.

### Triage-side behaviour (harness orchestrator session)

**Session-init scan.**

After the standard banner, the harness orchestrator runs:

```
ls openspec/changes/_intake/*.md 2>/dev/null | wc -l
```

Filtering files where frontmatter contains `status: untriaged`. If count > 0, append to the banner area:

```
N untriaged harness capture(s) in openspec/changes/_intake/. Say 'triage' to walk them.
```

The scan is read-only and adds negligible startup latency.

**Triage walk.**

On operator request (`triage`, `review intake`, or natural prompt), orchestrator reads each untriaged capture in chronological order and offers three outcomes per capture:

| Outcome | Action |
|---|---|
| **Promote** | Draft `openspec/changes/<new-slug>/proposal.md` (and optionally `design.md` + `tasks.md`). Move capture file to `openspec/changes/<new-slug>/provenance-<original-filename>` (or set its status to `promoted` in-place and add a `promoted-to: <new-slug>` field). |
| **Defer** | Update capture frontmatter `status: deferred` with optional rationale field. Stays visible in the inbox; subsequent triage walks skip `deferred` unless operator asks for them explicitly. |
| **Reject** | Move to `openspec/changes/_intake/rejected/` (created on first use) or delete outright. Operator's call. |

Triage commits land like any other harness commit: publication-gate validator before commit, harness-reviewer bookend before push.

### Cross-container collision and concurrency

- Filename hostname suffix prevents same-minute, same-topic collision across containers.
- Within a single container, same-minute, same-tag collision is prevented by the orchestrator either picking a different `<short-tag>` or appending a per-second component if needed (rare in practice; operator-driven capture is naturally serialised).
- Atomic rename means triage-side cannot observe a partial file.
- No file locking is needed. Each capture file is independent; multiple captures can land concurrently from different containers without coordination.

### Trust model

- Any container with the harness bind-mounted can write to `_intake/`. There is no authentication — the bind-mount itself is the trust boundary.
- Triage is the editorial control point. A capture file in `_intake/` is a *candidate* for the public review pipeline, not an automatic proposal. The maintainer decides what gets promoted.
- The publication gate scans `_intake/` files like any other staged content; target-detail leakage in a capture file fails commit.

## Alternatives considered

**A. Single landing point (just `_intake/`, drop BACKLOG).** Rejected. BACKLOG already exists, already works for the maintainer's private triage; the inbox is *additive* not *replacement*. Captures that need target context to make sense have nowhere clean to go if `_intake/` is the only landing and must be public.

**B. Single landing point (just BACKLOG, drop `_intake/`).** Rejected. BACKLOG is private and the wrong shape for cross-session handoff that should ultimately surface as public proposals. The whole point is to give captures a public-ready home from the start when content allows.

**C. Capture without operator confirmation (fully silent).** Rejected per operator direction. Removes the operator's editorial control over what enters the public review queue. The confirmation prompt is cheap; inbox pollution is expensive.

**D. Operator-typed-only capture (no proactive identification).** Rejected. Pushes the cognitive load of "is this harness-level?" entirely onto the operator. Proactive identification by the orchestrator is the main value-add; the confirmation gate is just the safety on top.

**E. GitHub Issues / GitLab Issues as the universal inbox (no filesystem mechanism).** Rejected for cross-session capture. Issues are right for external contributors; for the maintainer's own captures from parallel sessions on the same machine, filesystem handoff via the existing bind-mount is dramatically simpler than round-tripping through the platform UI.

**F. One file per capture vs. append to single inbox file.** Chose one-file-per-capture. Multiple writers from multiple containers can write concurrently without coordination; per-file frontmatter status enables clean triage. A single append-only `INTAKE.md` would race on concurrent writes and complicate triage status tracking.

## Trade-offs

- **Adds one new tracked directory.** Acceptable; small structural addition, mirrors the existing `openspec/changes/` shape.
- **Capture-side orchestrator gains a behaviour.** Acceptable; the behaviour is small (recognise candidate, ask, write atomically) and the persona template already carries similar pattern-recognition disciplines (Spec-Aware Routing, ASCII-only, Report-Back).
- **Triage-side adds a tiny startup latency.** Negligible; a single `ls` on a small directory.
- **Two landing points means operator decides at capture time.** Acceptable; the decision is binary and quick (target context present? -> BACKLOG; not? -> `_intake/`). The orchestrator surfaces the decision in the confirmation prompt.

## Migration risk

None. Additive change: new directory, new orchestrator behaviour. Existing sessions and existing BACKLOG flow continue to work. First orchestrator session on a container that has loaded the updated persona template starts identifying candidates and asking; older sessions remain unchanged until restarted.
