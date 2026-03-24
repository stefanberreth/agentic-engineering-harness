# AEH Harness Backlog

Items tracked here are improvements to the harness itself — not target project work.

## Documentation

### Document the human-AEH working patterns
**Status:** pending
**Raised:** 2026-03-24

Systematically capture the practical workflow that has emerged from real usage between the human operator and AEH entities. The patterns exist and work — they just aren't written up yet.

Key workflows to document:
- **Feature development loop:** orchestrator generates prompts → developer/reviewer execute in target → operator reviews
- **QA testing loop:** operator tests in QA → developer in testing mode captures triage → operator brings triage back to orchestrator for routing → fixes or specs generated
- **Rapid fix cycle:** operator points at problem → developer fixes → commit → test again (no prompt, no review)
- **Discovery routing:** developer/reviewer logs finding → orchestrator triages to analyst/architect/developer
- **Session handoff:** how state persists between sessions via committed files (orchestrator-state, tasks, journal)

Rules: document what actually happens. Don't invent new mechanisms — everything needed already exists in the current tool set (personas, orchestrator state, triage file, discovery log, open questions, decisions).

## Future Capabilities

### Enterprise process integration — Figma + BA tickets as input
**Status:** roadmap
**Raised:** 2026-03-24

Design a workflow that takes UI/UX designer Figma screens and usage flows as input alongside BA (business analyst) tickets. This links AEH into enterprise processes where design and requirements come from external tools and roles.

The intake should feed into the existing analyst → architect → developer pipeline without new personas or mechanisms. Figma screens are reference input (like screenshots). BA tickets are requirements input (like the business requirements catalogue). The gap is the handoff format and the analyst's instructions for consuming them.
