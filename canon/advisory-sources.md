---
sdd: canon-advisory
---

# Advisory level — curated live sources

> The NORMATIVE canon (the dimension docs in this directory) is pinned by
> version + hash and decides. This file is the ADVISORY level: a curated list
> of official live sources that may be consulted on demand while working.
> **Live consultation never decides.** Anything taken from these pages enters
> the work as `[P]` (PRESUMED — Art. XXI) until verified against the pinned
> canon or promoted into it through a registry release; the `lastro` sensor
> polices the tags. Consuming any of these URLs inside a sensor, hook or CI
> gate is FORBIDDEN (no remote configuration in enforcement — Art. XXV).

## Sources by dimension

| Dimension | Live source | What it informs |
|-----------|------------|-----------------|
| ui-ux | https://www.w3.org/TR/WCAG22/ | Current WCAG success criteria and techniques |
| ui-ux | https://web.dev/vitals/ | Core Web Vitals metric set and thresholds |
| sast | https://cwe.mitre.org/top25/ | Latest CWE Top 25 edition |
| sast, api | https://owasp.org/www-project-top-ten/ | OWASP Top 10 revisions |
| api | https://owasp.org/API-Security/ | OWASP API Security Top 10 |
| ai-llm | https://owasp.org/www-project-top-10-for-large-language-model-applications/ | OWASP LLM Top 10 |
| fitness-functions | https://endoflife.date/ | Runtime/dependency end-of-life dates |
| sca | https://osv.dev/ | Known-vulnerability data, synced per ecosystem (npm, PyPI, Go, crates.io, Maven, Packagist, RubyGems, NuGet) |
| sca | https://www.cisa.gov/known-exploited-vulnerabilities-catalog | Known-exploited flag per CVE (enrichment) |
| sca | https://www.first.org/epss/ | Exploit-probability score per CVE (enrichment) |
| cloud | https://aws.amazon.com/architecture/well-architected/ | AWS Well-Architected pillars and updates |
| cloud | https://learn.microsoft.com/azure/well-architected/ | Azure Well-Architected framework |
| cloud | https://cloud.google.com/architecture/framework | Google Cloud Architecture Framework |
| cloud | https://www.finops.org/framework/ | FinOps Framework practices |
| infrastructure | https://opentelemetry.io/docs/specs/semconv/ | OpenTelemetry semantic conventions |
| infrastructure | https://www.cisecurity.org/cis-benchmarks | CIS Benchmarks catalog |
| infrastructure | https://slsa.dev/ | SLSA supply-chain levels |
| secrets, database, privacy | https://csrc.nist.gov/publications | NIST SP publications (800-53, 800-207, 800-218…) |
| docs-adr | https://adr.github.io/ | ADR formats and tooling |

## Rules of use

1. Cite the source and date when bringing content in; tag the claim `[P]`.
2. A `[P]` claim that must DECIDE something (a gate, a verdict, a story's
   Done-When) first gets verified against the pinned canon — or promoted into
   the canon via a registry release (human-approved), which is what turns it
   normative.
3. When a live source announces a new edition of a pinned standard (a new WCAG,
   a new CWE Top 25), that is input for a canon release — never for editing the
   vendored docs in place (`canon-freshness` will tell you when you are behind).
