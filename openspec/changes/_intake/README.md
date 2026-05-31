# Harness Capture Inbox

Filesystem-mediated intake for harness-level insights surfaced in any orchestrator session.

## What lands here

Small structured captures of insights about the harness itself — refinements to persona templates, gaps in playbooks, vocabulary changes, patterns worth generalising — written by an orchestrator in any container that has the harness bind-mounted, awaiting triage by a harness orchestrator session.

This is one of two landing points. The other is `BACKLOG.md` (untracked, private). Use this inbox when the capture is **target-detail-free** and fit for the public OpenSpec review pipeline. Use `BACKLOG.md` when the capture needs target context for motivational rationale or the maintainer wants to scrub or shape before public exposure.

## File format

**Filename:** `YYYY-MM-DD-HHMM-<short-tag>-<HOSTNAME>.md`

- Timestamp is when the capture was written.
- Short-tag is a 1-3 word kebab-case descriptor.
- Hostname suffix prevents cross-container filename collision when two captures land at the same minute on the same topic.

**Frontmatter (YAML):**

```yaml
---
captured-at: 2026-05-31T14:23:00Z          # ISO 8601 UTC
captured-from: <container HOSTNAME>
captured-during: <brief context, e.g. "target session on project X" or "harness session triage">
area: orchestrator-persona | playbook | template | governance | bin | docs | other
status: untriaged                          # always 'untriaged' at write time
---
```

**Body (markdown):**

```markdown
# <Short title>

**Trigger:** one or two sentences naming what session-context produced this insight.

**Insight:** one paragraph describing the harness-level observation. Target-detail-free.

**Suggested change:** 1-3 bullets sketching what the harness should do differently. Not a full proposal — that's what triage produces.

**Memory updates:** any `feedback_*.md` memory files this would supersede or extend, with old text vs new text where relevant.
```

## Atomic write protocol

Capture-side orchestrator writes the file in two steps to prevent triage-side from observing a half-written file under the shared bind-mount:

1. Write full content to `openspec/changes/_intake/.tmp.<filename>`.
2. Rename atomically: `mv .tmp.<filename> <filename>`.

`.tmp.*` files are gitignored so a partial write cannot accidentally commit.

## Triage flow

A harness orchestrator session scans this directory on session-init for files where `status: untriaged`. Triage runs on operator request and offers three outcomes per capture:

- **Promote** -- draft a proper `openspec/changes/<new-slug>/proposal.md` (and optionally `design.md` + `tasks.md`). The capture file moves into the new change directory as `provenance.md`, or stays in place with frontmatter updated to `status: promoted` + `promoted-to: <new-slug>`.
- **Defer** -- update frontmatter `status: deferred` with optional rationale. Stays in the inbox; subsequent triage walks skip it unless the operator explicitly asks.
- **Reject** -- delete, or move to `_intake/rejected/` (created on first use).

All triage edits commit through the standard harness publication gate (`bin/validate-personas.sh --staged` + `--message`) and the harness-reviewer bookend before push.

## Relationship to `BACKLOG.md`

Two landings, one shape, different visibility:

| Landing | When | Visibility |
|---|---|---|
| `openspec/changes/_intake/` (this directory) | Target-detail-free; fit for public review | Tracked, public on push |
| `BACKLOG.md` (repo root) | Needs target context to motivate, or maintainer wants to scrub first | Untracked, gitignored, private |

The maintainer cross-references between the two when a public proposal needs private context to make sense. Both carry the same five-field body shape; only frontmatter discipline and file-tracking status differ.

## Authoring discipline

Files here are **public** when pushed. They must never carry target-project identifiers (slugs, project names, real commit SHAs from target work, real RPC / file / column names from target codebases). The publication gate scans `_intake/` files like any other staged content; target leakage fails commit. See `openspec/project.md` § "Authoring discipline" for the full rule.

If a candidate capture has target context that cannot be cleanly scrubbed, write to `BACKLOG.md` instead.

## Cross-references

- Mechanism proposal: `openspec/changes/harness-capture-inbox/`
- Project conventions: `openspec/project.md`
- Active proposals: `openspec/changes/`
