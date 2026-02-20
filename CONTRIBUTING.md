# Contributing to AEH

AEH is maintained by a single person. Contributions are welcome -- but the project operates under a benevolent dictator model. I review everything personally and make all design decisions. This isn't bureaucracy; it's how a solo-maintained project stays coherent.

## Before you contribute

**Open an issue first.** Describe what you want to change and why. I may say no -- that's not personal, it's scope management. A quick conversation before you invest time prevents wasted effort on both sides.

## How to contribute

### The preferred way: submit a prompt, not a patch

This is a project about AI-assisted engineering. Contributions should reflect that.

Instead of (or in addition to) a code diff, **submit the LLM prompt that would produce the change.** This means:

1. Write a clear, self-contained prompt that describes what to change, where, and why
2. Include enough context that I can paste it into a Claude Code session in this repo and review the result
3. If the change is complex, break it into numbered steps

**Why prompts over patches?**

- I can read a prompt in 30 seconds and understand what it *intends*. A diff of 200 lines of markdown takes longer to interpret.
- I can adjust the prompt before running it, adapting it to context you may not have.
- It keeps the contribution process aligned with how this project actually works -- prompt-driven, reviewable, auditable.
- It's faster for you too. Describe what should change; let the LLM handle the mechanical work.

**You can submit both** -- a prompt and its output as a diff -- if you want to show the exact result you're proposing. But the prompt is the primary artifact I'll review.

### What I'm looking for

**High-value contributions:**
- New persona adaptations for specific tech stacks or domains (e.g. "reviewer persona adapted for Rust/embedded", "developer persona for Django projects")
- Assessment checklist items that catch real problems I haven't encountered
- Playbook improvements based on your onboarding experience
- Bug reports with reproduction steps
- Documentation improvements (clarity, accuracy, missing context)

**Also welcome:**
- Governance criteria refinements
- Tool integration additions (new MCP servers following the existing pattern)
- Regression check improvements from real-world post-transformation issues

**Probably won't accept:**
- Changes that add runtime dependencies (this project is markdown and process artifacts -- no code to install)
- Features that increase maintenance burden without clear value
- Opinionated style changes (formatting, naming conventions) unless they fix a real problem
- Contributions that require me to learn and maintain a new tool or service

### Contribution format

For **prompt-based contributions** (preferred), open an issue or MR with:

```markdown
## What this changes
[One sentence]

## Why
[Brief rationale]

## Prompt
[The prompt to paste into Claude Code in the AEH repo]

## Expected result
[What files change and how]
```

For **traditional contributions** (if you prefer), open a merge request. Keep changes small and focused -- one logical change per MR.

## Technical guidelines

- **No application code.** AEH produces markdown, prompt templates, and process documentation. If your contribution includes code that runs, it probably doesn't belong here.
- **Match existing tone.** Read the existing templates before writing new ones. The project has a consistent voice: direct, professional, no emoji, no marketing language.
- **Templates are starting points.** They should be adaptable to any tech stack. Avoid hardcoding language-specific or framework-specific assumptions into generic templates.
- **Test with a real project.** If you're improving a playbook or template, run it against an actual project (even a toy one) before submitting.

## Response times

I maintain this in my own time. Responses may take days or weeks. If something is urgent, say so in the issue -- but understand that "urgent" in an open-source side project has a different threshold than at work.

## Licensing

By contributing, you agree that your contributions are licensed under the same AGPL-3.0 license as the project. See [LICENSE](LICENSE) and [LICENSE-FAQ.md](LICENSE-FAQ.md).

## Code of conduct

Be professional. Be constructive. Assume good intent. If someone's contribution doesn't fit, explain why clearly and kindly. There's no formal CoC document because the community is small and the expectations are simple: treat people the way you'd want to be treated in a code review.

## Community

- **Issues:** [GitLab Issues](https://gitlab.com/stefanberreth/agentic-engineering-harness/-/issues) for bugs, feature requests, and structured discussion
- **Discord:** [AEH Discord](#) for real-time chat, show-and-tell, and help (link in README)

Thank you for considering a contribution. Even a well-written bug report or a "this didn't work because..." story helps make AEH better.
