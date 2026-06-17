# AEH OpenSpec -- Project Identity

This `openspec/` tree governs **the Agentic Engineering Harness itself**, not any target project. The harness dogfoods the OpenSpec discipline it prescribes for targets: substantive changes to harness templates, personas, playbooks, governance, or process documentation are proposed and tracked here as change proposals; archived proposals seed and update the canonical spec corpus under `openspec/specs/`.

This is a deliberate, late-stage adoption -- the harness has matured to the point where its change surface is structured enough that an OpenSpec layer adds clarity rather than ceremony. The spec corpus is intentionally empty at adoption time and grows organically as proposals archive. No retrofit of existing harness capability into specs is planned; that would create heavy definitional overhead with no clear payoff.

## What belongs here

- **Substantive changes** to harness templates, personas, playbooks, governance, scripts, or process rules. Anything that changes contracts between roles, mechanism, methodology, or public-facing convention.
- **Cross-cutting changes** that touch multiple files or that introduce a new pattern other parts of the harness will reference.

## What does NOT belong here (trivial-change bypass)

- Typo fixes, ASCII-conformance fixes, broken-link fixes, wording clarifications.
- Single-file cosmetic updates to README / CHANGELOG / CLAUDE.md that do not change rules or behaviour.
- Tracked-file metadata fixes (gitignore tweaks, file renames without content change).

Trivial changes commit directly with a `[trivial]` or `[hygiene]` prefix in the commit message. The OpenSpec layer is a tool, not ceremony -- if a change is genuinely a one-line cleanup, do not wrap it in a proposal.

## Authoring discipline (target-detail-free)

Proposals and specs in this tree are **public** -- they ship in the public harness repo. They must never contain target-project identifiers (real slugs, project names, real commit SHAs from target work, real incident details with serial numbers filed off, real RPC / file / column names from target codebases). Private triage scratchpads -- the private capture inbox (`targets/_harness-private/intake/`), the maintainer backlog (`targets/_harness-private/BACKLOG.md`), and any `*.private.md` / `*.local.md` -- are **inspiration, not source-of-text** for proposals. Author each proposal from scratch in generic terms; if a real-world incident motivates the proposal, describe the class of failure abstractly, not the specific incident. The capture inbox is itself private (tracked in the `targets` repo, never published); the public boundary is enforced at promotion, when a capture becomes a target-detail-free proposal.

The publication gate (`bin/validate-personas.sh --staged` over staged content + `--message` over the commit message) scans staged content uniformly and catches pattern-matched leakage in `openspec/**` automatically. Authoring discipline catches the residual class -- paraphrases close enough to a real incident to identify the target.

The harness-reviewer persona's Dimension 1 (target detail leakage) covers `openspec/**` explicitly.

## Status vocabulary

Inherits the AEH canonical OpenSpec status vocabulary (when established harness-wide; see BACKLOG entry "AEH canonical OpenSpec status vocabulary"). Until then, this tree uses the standard OpenSpec change lifecycle:

- `proposed` -- proposal authored, not yet reviewed
- `accepted` -- maintainer accepted; ready for implementation
- `in-progress` -- implementation underway
- `ready-for-archive` -- implementation complete, awaiting archive sweep
- `archived` -- moved to `openspec/changes/archive/<slug>/`; specs updated

Spec status follows: `draft`, `current`, `superseded`, `archived`.

## Directory layout

```
openspec/
  project.md                       # this file
  specs/                           # canonical capability specs (grows from archived proposals)
    README.md                      # corpus growth note
  changes/                         # active change proposals
    README.md                      # active proposal index
    <change-slug>/                 # one directory per proposal
      proposal.md                  # what + why + scope
      design.md                    # how (optional for trivial-shape proposals)
      tasks.md                     # ordered task list with mechanical completion signals
      specs/                       # spec deltas to apply on archive (when applicable)
    archive/                       # archived proposals (created on first archive)
```

## How OpenSpec interacts with other harness discipline

- **Publication gate** runs before every commit/push regardless of whether the change is OpenSpec-shaped or trivial. No bypass for OpenSpec-tree commits.
- **Harness-reviewer** is the bookend for substantive changes. Run it after authoring a proposal and again after implementation lands, before push.
- **CHANGELOG.md** [Unreleased] section captures the user-visible summary of every substantive change (whether it went through OpenSpec or not). The OpenSpec change is the engineering record; the CHANGELOG is the readable history.
- **The private capture inbox** (`targets/_harness-private/intake/`) and **`targets/_harness-private/BACKLOG.md`** (both tracked in the private `targets` repo, never published) are the maintainer's capture + triage scratchpads; promoting an entry into a real (public, target-detail-free) OpenSpec change is a deliberate decision made when the change is ready to design.
