---
sdd: canon
dimension: api
standards:
  - "OpenAPI Specification 3.1.0 (2021)"
  - "RFC 9110 (HTTP Semantics, 2022)"
  - "OWASP API Security Top 10 (2023)"
  - "RFC 9457 (Problem Details for HTTP APIs, 2023)"
  - "RFC 8594 (The Sunset HTTP Header Field, 2019)"
sensors:
  - api-lint
checklist: true
measurability: "Requires an API surface: an OpenAPI document, HTTP route definitions in source, or a served API endpoint. A project exposing no API is not assessable — never scored. An API that EXISTS but has no OpenAPI document is assessable — and fails rule 1: the missing contract is the finding, not missing substrate."
---

# Canon — API

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the contract's structural quality comes from the
> `api-lint` sensor, and the authorization/semantics posture from the
> standard-derived checklist below.

---

## Doctrine

**Contract-first, or the contract is fiction.** The OpenAPI 3.1 document is
the source of truth for the API surface: code is generated from it or
validated against it — never the reverse as an afterthought. A specification
reverse-engineered from whatever the handlers happen to do is documentation,
not a contract; it changes when the bug changes. The document lives in the
repository, is versioned with the code it governs, and is linted by the
`api-lint` sensor on every change. An endpoint that exists in code but not in
the document is an undocumented liability; an endpoint in the document but
not in code is a broken promise. Both are findings.

**HTTP semantics are a contract with every intermediary.** RFC 9110 defines
what methods and status codes MEAN — and caches, proxies, retrying clients
and monitoring all act on those meanings. The canon's floor is semantic
honesty: safe methods (GET, HEAD) never mutate state; idempotent methods
(PUT, DELETE) tolerate replay; a 200 with an error payload inside is a lie
that poisons caches and dashboards alike; caching headers state what is
actually true about freshness. An API that abuses semantics forfeits every
piece of infrastructure built to trust them.

**OWASP API Security Top 10 (2023) is the threat floor — BOLA first.**
Broken Object Level Authorization (API1:2023) heads the list because it is
the API-shaped vulnerability: the handler authenticates the caller and then
fetches whatever id the caller asked for. Every endpoint that takes an object
identifier verifies that THIS caller may access THIS object — ownership or
tenancy checked at the data layer, not inferred from the route. The rest of
the floor follows the list: object property-level authorization (no
mass-assignment, no over-returning), resource consumption limits (rate and
size), and restricted business flows. A linter cannot prove authorization;
that part of the floor is checklist and review, and this doc says so rather
than pretending the sensor covers it.

**Versioning is a promise-keeping discipline.** A breaking change — removing
or renaming a field, tightening a type, changing an error shape — ships only
as a new major version. The old version is retired deliberately: a `Sunset`
header (RFC 8594) announces the date, the date is honored, and the retirement
is a recorded decision. Additive change within a major version is the normal,
cheap path; breakage disguised as an additive change ("the field is still
there, it just means something else now") is the expensive lie this rule
exists to block.

**Consistency is an API feature.** Pagination, filtering and sorting follow
ONE declared convention across the whole surface — cursor or page/limit,
picked once, recorded, applied everywhere. Errors have one shape: RFC 9457
`application/problem+json`, with `type`, `title`, `status` and enough detail
to act on — never a bare string, never a stack trace, never a different JSON
shape per handler. A client should learn the API once, not per endpoint.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | The API surface is described by an OpenAPI 3.1 document versioned in the repository; code conforms to the document, not the reverse | OpenAPI Specification 3.1.0 (2021) | `api-lint` + checklist (drift review) |
| 2 | The OpenAPI document passes the declared lint ruleset on every change (valid structure, operations described, schemas typed, no orphan components) | OpenAPI Specification 3.1.0 (2021) | `api-lint` |
| 3 | Method semantics are honest: safe methods never mutate, idempotent methods tolerate replay, status codes carry their RFC meaning (no 200-with-error) | RFC 9110 (2022) — sections 9.2, 15 | checklist |
| 4 | Every endpoint receiving an object identifier enforces object-level authorization for the authenticated caller (ownership/tenancy at the data layer) | OWASP API Security Top 10 (2023) — API1 BOLA | checklist |
| 5 | Responses expose only declared properties; requests bind only declared properties (no mass assignment); rate and payload-size limits are declared and enforced | OWASP API Security Top 10 (2023) — API3, API4 | checklist |
| 6 | A breaking change ships only as a new major version; retirement of an old version announces a `Sunset` date and honors it, as a recorded decision | RFC 8594 (2019); OpenAPI Specification 3.1.0 (2021) — `info.version` | checklist |
| 7 | Pagination, filtering and sorting follow one convention declared for the whole surface | OpenAPI Specification 3.1.0 (2021) — shared parameter components | `api-lint` (shared components) + checklist |
| 8 | Errors are RFC 9457 `application/problem+json` — one shape for the whole surface; no stack traces or internal detail in any response | RFC 9457 (2023); OWASP API Security Top 10 (2023) — API8 | `api-lint` (error schema declared) + checklist |

---

## Checklist

> The sensor proves the document's structural quality; it cannot prove
> authorization or semantic honesty. These items are reviewed by a human per
> story that touches the API surface — each anchors to a declared standard.

- [ ] Every endpoint in code appears in the OpenAPI document and vice versa; drift in either direction is a finding — OpenAPI Specification 3.1.0 (2021)
- [ ] Safe methods (GET, HEAD) perform no state mutation; PUT/DELETE handlers are replay-tolerant; status codes match their RFC 9110 meaning — RFC 9110 (2022)
- [ ] Every object-id-taking endpoint has an object-level authorization check tied to the authenticated principal, verified by a test that requests another principal's object and gets 403/404 — OWASP API Security Top 10 (2023), API1
- [ ] Request binding is allowlist-based (no mass assignment); response schemas expose no property the client does not need — OWASP API Security Top 10 (2023), API3
- [ ] Rate limits and maximum payload sizes are declared and return 429/413 when exceeded — OWASP API Security Top 10 (2023), API4
- [ ] Breaking changes ship as a new major version only; deprecated versions carry a `Sunset` header and a recorded retirement decision — RFC 8594 (2019)
- [ ] Pagination/filtering/sorting follow the one declared convention; errors are `application/problem+json` everywhere, with no internal detail leaked — RFC 9457 (2023)

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Contract-first | The OpenAPI document is authored/reviewed as the source of truth; implementations conform to it |
| OpenAPI 3.1 | The current OpenAPI Specification version (2021), aligned with JSON Schema |
| BOLA | Broken Object Level Authorization — OWASP API Security Top 10 (2023) item API1; caller authenticated, object access unchecked |
| Mass assignment | Binding client input directly to internal models, letting undeclared properties through (API3:2023) |
| Safe method | An HTTP method defined by RFC 9110 as read-only (GET, HEAD); must not mutate state |
| Idempotent method | A method whose replay has the same effect as one call (PUT, DELETE per RFC 9110) |
| Sunset header | RFC 8594 response header announcing when a resource/version will stop being served |
| problem+json | The RFC 9457 standard error body (`type`, `title`, `status`, `detail`) — the one error shape |
| Breaking change | Any change an existing well-behaved client can observe as a removal or meaning shift — requires a new major version |
| Not assessable | The honest verdict when the project exposes no API surface (Art. XXV.3) — never a score |
