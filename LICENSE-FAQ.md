# License FAQ

AEH is licensed under the [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) (AGPL-3.0). This FAQ clarifies what that means in practice.

## Using AEH to transform your project

**Q: Does running AEH on my project make my project AGPL?**

No. AEH's output -- adapted personas, CLAUDE.md sections, prompts, agents.md, governance reports -- belongs to you. These are generated artifacts tailored to your project, not derivative works of AEH. You can use them under any license you choose, including proprietary.

Think of it like a compiler: using GCC to compile your code doesn't make your code GPL.

**Q: Can I use AEH on a proprietary/commercial project?**

Yes. AEH reads your project and produces configuration artifacts. Your project's code, architecture, and intellectual property are yours. The AGPL applies to AEH itself, not to the projects it transforms.

**Q: Do I need to credit AEH in my project?**

No. Credit is appreciated but not required. The generated prompts and personas are yours to use without attribution.

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
| Run AEH on your project | None. Output is yours. |
| Fork and modify AEH | AGPL applies to your modifications if distributed or hosted. |
| Host AEH as a service | AGPL: make source available. Or: commercial license. |
| Use AEH-generated artifacts | None. They're yours. |
| Contribute to AEH | Your contributions are licensed under AGPL (see CONTRIBUTING.md). |
