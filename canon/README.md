# Quality Canon — Index

> **Doctrine with a mechanism (Art. XXV).** Each file in this directory is one
> engineering dimension of the canon: what good looks like, which versioned
> public standards say so, and which executable sensor — or standard-derived
> checklist — verifies it. Format: `templates/canon-template.md`. Structure
> validated mechanically by the `canon-check` sensor
> (`tools/sensors/canon_check.py`, part of the `harness-check` suite).

---

## Dimensions

> Dimensions arrive one story at a time, each through the gate below. Add a
> row when a dimension doc lands.

| Dimension | Doc | Standards | Mechanism | Measurability |
|-----------|-----|-----------|-----------|---------------|
| code-architecture | [code-architecture.md](code-architecture.md) | ISO/IEC 25010:2011; ISO/IEC/IEEE 42010:2022 | sensors: `arch-layers`, `no-cycles` | source code + declared layer map |
| code-health | [code-health.md](code-health.md) | ISO/IEC 5055:2021; ISO/IEC 25010:2011 | sensor: `code-health` | source code + FULL VCS history (shallow clone = not assessable) |
| fitness-functions | [fitness-functions.md](fitness-functions.md) | ISO/IEC 25010:2011; ISO/IEC 5055:2021; endoflife.date (pinned snapshot) | sensors: `complexity-ceiling`, `file-size-ceiling`, `no-duplication`, `no-eol-runtime` (`no-cycles`: see code-architecture) | source code; EOL check needs declared runtime versions + pinned snapshot |
| test-seams | [test-seams.md](test-seams.md) | ISO/IEC/IEEE 29119-1:2022; 29119-4:2021 | sensor: `test-seams` (mutation-score gate) | an executable test suite |
| sast | [sast.md](sast.md) | CWE Top 25 (2024); OWASP Top 10:2021 | sensor: `sast` (pinned permissive rulepack; Commons Clause FORBIDDEN) | source in a rulepack-covered language |
| sca | [sca.md](sca.md) | OSV schema v1; SPDX 2.3 / ISO/IEC 5962:2021; NIST SP 800-218 SSDF v1.1 | sensor: `sca` | dependency manifest + committed lockfile |
| secrets | [secrets.md](secrets.md) | CWE-798; NIST SP 800-53 Rev. 5 | sensor: `secrets` | version-controlled repo (tree + history) |
| database | [database.md](database.md) | ISO/IEC 25012:2008; ISO/IEC 9075:2023 (SQL:2023); NIST SP 800-53 Rev. 5 | sensors: `migration-lint`, `rls-coverage`, `query-budget`, `schema-crypto` | version-controlled schema (migrations/DDL) + reachable instance for runtime sensors; no database substrate = not assessable |
| ui-ux | [ui-ux.md](ui-ux.md) | WCAG 2.2; ISO 9241-110:2020; Core Web Vitals (INP set, 2024); W3C DTCG Format Module (2024 draft) | sensors: `a11y`, `web-vitals`, `bundle-budget`, `design-slop` + checklist (ISO 9241-110 principles; manual WCAG items) | a rendered UI: markup/styles for static sensors, servable build or running instance for runtime sensors; no UI substrate = not assessable |
| infrastructure | [infrastructure.md](infrastructure.md) | Twelve-Factor App (2017); OCI image v1.1 / runtime v1.2 / distribution v1.1; OpenTelemetry semconv (v1.23.0+); Google SRE (2016/2018); NIST SP 800-207; NIST SP 800-218 SSDF v1.1; SLSA v1.0; SPDX 2.3 / ISO/IEC 5962:2021; CIS Benchmarks | sensors: `iac-scan`, `container-lint`, `sbom` + checklist (operability, telemetry, SLO gate, zero trust) | IaC, container build files or deployment manifests; none = not assessable; partial substrate = only what exists is assessed |
| cloud | [cloud.md](cloud.md) | AWS Well-Architected (2023+); Azure Well-Architected (2026); Google Cloud Architecture Framework (2026); ISO/IEC 27017:2015; ISO/IEC 27018:2019; FinOps Framework (2024+) | sensor: `cost-budget` + checklist (six-pillar union, shared responsibility, PII, FinOps) | cloud provider substrate (provisioned resources, IaC targeting a provider, or a billing export); none = not assessable; on-prem = only transferable clauses |
| api | [api.md](api.md) | OpenAPI 3.1.0 (2021); RFC 9110 (2022); OWASP API Security Top 10 (2023); RFC 9457 (2023); RFC 8594 (2019) | sensor: `api-lint` + checklist (BOLA/authz, semantics honesty, versioning/sunset) | an API surface (OpenAPI doc, HTTP routes, or served endpoint); none = not assessable; API without an OpenAPI doc = assessable and failing rule 1 |
| distributed-systems | [distributed-systems.md](distributed-systems.md) | RFC 9110 (2022); Azure Cloud Design Patterns (2024); AWS Prescriptive Guidance (2023+) | INTEGRATION STORY CHECKLIST (outbox, idempotency, retry+jitter, DLQ+replay, saga, timeouts) — no sensor; template inheritance wired by SDD3-19 | components communicating across a process/network boundary; none = not assessable; monolith with outbound calls = only outbound clauses |
| ai-llm | [ai-llm.md](ai-llm.md) | OWASP Top 10 for LLM Applications (2025); ISO/IEC 42001:2023; NIST AI RMF 1.0 (2023) | sensor: `token-budget` + checklist (injection as untrusted input, evals as behavioral sensors, pinned model id); LLM judge = SDD3-10, flagged, advisory until calibrated | a model-touching surface (LLM calls, versioned prompts, consumed model output); none = not assessable |
| privacy | [privacy.md](privacy.md) | GDPR (EU) 2016/679; LGPD Law 13.709/2018; ISO/IEC 29100:2011 | checklist (minimization, purpose limitation, TTL+mechanical deletion, data-subject rights) — legal compliance is not sensor-provable; storage enforcement delegated to database.md sensors | personal data in the system (collection surfaces, PII columns, or inventory); provably none = not assessable; collects PII without inventory = assessable, inventory absence is the first finding |
| docs-adr | [docs-adr.md](docs-adr.md) | ISO/IEC/IEEE 42010:2022; MADR 4.0.0 (2024) | sensor: `adr-check` (ADR reference on declared architectural paths) + review rule for record quality | version-controlled repo + declared architectural paths; undeclared paths = assessable and failing rule 5 |
| iso-27001-mapping | [iso-27001-mapping.md](iso-27001-mapping.md) | ISO/IEC 27001:2022; ISO/IEC 27002:2022 | mapping table (controls 8.8, 8.24–8.32 → kit mechanism → auditor-readable artifact) + dossier checklist; rows are the kit's own `[P]` claim; NEVER a certification promise | an exercised SDD harness (contracts with QA runs, decision log, telemetry); installed-but-unused kit = empty dossier, reported as such |

---

## Story-type inheritance

> The SINGLE SOURCE for canon inheritance in stories (wired by SDD3-19). A
> story that declares `type:` in its frontmatter inherits every dimension in
> its row and must adopt each one inside a `## Canon requirements` section —
> enforced by the `canon-check` sensor (rule QC-07). The sensor parses EXACTLY
> the table below: it anchors on the header row `| type | dimensions |` and
> reads rows until the first non-table line. Prose around the table may change
> freely; the header row and the row format `| <type> | <slug>, <slug> |`
> must stay intact.

| type | dimensions |
|------|------------|
| integration | distributed-systems, api |
| persistence | database, privacy |
| iac | infrastructure, cloud |
| ui | ui-ux |
| ai-llm | ai-llm |

---

## Operational rules (Art. XXV, in enforceable form)

### 1. Doctrine only enters with a mechanism (mechanized: `canon-check`)

A dimension doc is admitted only when BOTH hold:

- **A versioned public standard.** `standards:` lists at least one public
  standard carrying a version or year token — `WCAG 2.2`,
  `ISO/IEC 25012:2008`, `OWASP API Security Top 10 (2023)`. "Best practice"
  with no anchor is opinion, not canon.
- **A verification mechanism.** Either `sensors:` names executable sensors
  registered in `sensors.yaml` (each carrying `dimension:` equal to this doc's
  slug), or `checklist: true` with a `## Checklist` section in the body whose
  items derive from the declared standard. Doctrine without verification does
  not get in.

### 2. No people's names (a REVIEW rule — honestly NOT mechanized)

The distributed kit references techniques, standards and institutional
frameworks (ISO, W3C, OWASP, NIST, CIS, CNCF, the cloud providers'
architecture frameworks) — never individual authors. Reliable proper-name
detection is beyond what a stdlib sensor can promise, so `canon-check` does
NOT claim to enforce this. It is a human review rule: whoever reviews a canon
PR checks it, and a violation is grounds for rejection, not for a sensor
exception.

### 3. Honest measurability (mechanized: `canon-check` requires the field)

Every dimension declares `measurability:` — which substrate must exist in the
project for the dimension to be assessed (a rendered UI, a deployable
artifact, a test suite, telemetry...). When the substrate is absent, the
dimension is reported as **"not assessable"** — it is NEVER scored, neither
well nor badly, in the absence of evidence. The sensor enforces that the
declaration exists; honoring it at assessment time is the assessor's contract.

### 4. Normative pinned, advisory live (registry arrives in phase 4)

Content that decides or blocks is versioned in the `sdd-canon` registry,
pinned by version + hash (`canon.lock`), vendored offline-first, and updated
only by explicit human act after a reviewed diff. Advisory content (curated
live sources) may be consulted on demand and enters the work as `[P]` until
verified. **Consuming remote configuration in any enforcement mechanism is
FORBIDDEN.** Until the registry ships (phase 4), everything in this directory
is vendored content under version control — there is nothing remote to pin.

### 5. An agent never updates the canon on its own

Staleness is a warning (`canon-freshness`, phase 4); the decision to update is
human — always.
