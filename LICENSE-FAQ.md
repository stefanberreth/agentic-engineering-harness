# License FAQ

AEH is licensed under the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) (AGPL-3.0). This FAQ clarifies what that means in practice.

**The short version:** Use AEH freely -- on personal projects, in teams, across your entire organisation. No license to buy, no obligations triggered. The AGPL only applies if you host a modified AEH as a public service for others.

## Using AEH to transform your project

**Q: Does running AEH on my project make my project AGPL?**

No. AEH's output -- adapted personas, CLAUDE.md sections, prompts, agents.md, governance reports -- belongs to you. These are generated artifacts tailored to your project, not derivative works of AEH. You can use them under any license you choose, including proprietary.

Think of it like a compiler: using GCC to compile your code doesn't make your code GPL.

**Q: Can I use AEH on a proprietary/commercial project?**

Yes. AEH reads your project and produces configuration artifacts. Your project's code, architecture, and intellectual property are yours. The AGPL applies to AEH itself, not to the projects it transforms.

**Q: Do I need to credit AEH in my project?**

No. Credit is appreciated but not required. The generated prompts and personas are yours to use without attribution.

## Enterprise and team use

**Q: Can my company use AEH internally without buying a license?**

Yes. An organisation can clone AEH, run it on any number of internal projects, adapt the templates, train teams on the workflow, and use all generated artifacts -- all without any license obligation. Internal use is simply use. The AGPL does not trigger for software running on your own machines for your own teams.

**Q: Can a consultant or contractor use AEH for client work?**

Yes. A consultant running AEH locally to assess or transform a client's project is normal use. The generated artifacts (personas, prompts, assessments) belong to whoever commissioned the work. No AGPL obligation is triggered.

**Q: Can we deploy AEH on an internal server for our engineering teams?**

Yes. Hosting AEH internally (on your CI server, internal tooling platform, or shared development machine) for your own employees and contractors is not "offering it as a network service" under the AGPL. The AGPL's network clause applies when you make the software available to the public or to external users -- not to your own organisation.

**Q: What if we modify AEH for our internal needs?**

Entirely fine. You can fork, modify, and adapt AEH for internal use without sharing your modifications. The AGPL obligation to share source code only triggers when you **distribute** the modified version to others outside your organisation or **host** it as a service for external users.

## Modifying AEH

**Q: Can I fork AEH and modify it?**

Yes. If you distribute your modified version or offer it as a network service (e.g. a hosted version), you must make your modifications available under the AGPL.

**Q: Can I use AEH templates as a starting point for my own harness?**

If you're building a substantially new tool that happens to be inspired by AEH's approach, that's not a derivative work -- go ahead. If you're copying and modifying AEH's templates, playbooks, and governance criteria wholesale, that's a fork and the AGPL applies to your modifications.

## Offering AEH as a service

**Q: Can I host AEH as a SaaS product?**

The AGPL requires that if you offer AEH (or a modified version) as a network service, you must make the source code available to users of that service. If you want to offer a hosted AEH without this obligation, contact the author about a commercial license.

**Q: What counts as "offering as a service"?**

Running AEH on a server where other people interact with it over a network (web UI, API, hosted Claude Code wrapper, etc.). Running it locally on your own machine for your own projects is just normal use -- no obligations beyond the license grant.

## Commercial licensing

**Q: Is a commercial license available?**

For organisations that need to embed AEH in proprietary tooling or offer it as a hosted service without AGPL obligations, a commercial license is available. Contact Stefan Berreth to discuss terms.

## Summary

| Use case | License obligation |
|----------|-------------------|
| Use AEH on your project (personal or commercial) | None. Output is yours. |
| Use AEH across your organisation (any number of projects) | None. Internal use is just use. |
| Modify AEH for internal use | None. Your modifications stay private. |
| Consultant uses AEH for client work | None. Artifacts belong to the client. |
| Host AEH internally for your team | None. Internal hosting is not a network service. |
| Fork and distribute AEH publicly | AGPL: your modifications must be open-sourced. |
| Host AEH as a public service | AGPL: make source available. Or: commercial license. |
| Use AEH-generated artifacts | None. They're yours under any license. |
| Contribute to AEH | Your contributions are licensed under AGPL (see CONTRIBUTING.md). |
