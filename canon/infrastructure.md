---
sdd: canon
dimension: infrastructure
standards:
  - "The Twelve-Factor App methodology (12factor.net, 2017 revision)"
  - "OCI Image Format Specification v1.1; OCI Runtime Specification v1.2; OCI Distribution Specification v1.1 (Open Container Initiative)"
  - "OpenTelemetry Semantic Conventions (HTTP conventions stable since v1.23.0, 2023)"
  - "Google SRE — SLI/SLO/error-budget discipline (Site Reliability Engineering, 2016; The Site Reliability Workbook, 2018)"
  - "NIST SP 800-207 (2020 — Zero Trust Architecture)"
  - "NIST SP 800-218 (SSDF v1.1 — Secure Software Development Framework)"
  - "SLSA v1.0 (OpenSSF Supply-chain Levels for Software Artifacts)"
  - "SPDX 2.3 (ISO/IEC 5962:2021 — software bill of materials)"
  - "CIS Benchmarks (Center for Internet Security — e.g. CIS Docker Benchmark v1.6, CIS Kubernetes Benchmark v1.9)"
sensors:
  - iac-scan
  - container-lint
  - sbom
checklist: true
measurability: "Requires a deployment substrate in the repository: infrastructure-as-code, container build files (Dockerfile / OCI build config), or deployment manifests. A project with none of these is reported as not assessable — never scored. A partial substrate is assessed only on what exists (e.g. a Dockerfile but no IaC: container rules apply, IaC rules stay not assessable); absence of substrate is never counted for or against the project."
---

# Canon — Infrastructure

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the misconfiguration, container-hardening and
> inventory verdicts come from the sensors below, and the operability and
> boundary reviews from the standard-derived checklist.

---

## Doctrine

Infrastructure is where every other dimension either survives contact with
reality or does not. A well-factored codebase deployed as a hand-configured
snowflake, observed through grep over ssh, trusted because it sits "inside
the network", is not a well-engineered system — it is a well-engineered
component of an unengineered one. This dimension holds the substrate to the
same discipline the canon holds code to: declared contracts, verified
mechanically, with every deviation recorded as a decision.

**The twelve factors are the operability contract.** The Twelve-Factor App
methodology (12factor.net, 2017 revision) is the floor for anything that
runs as a service, and four of its factors carry most of the weight:

- **Config lives in the environment** (factor III). Everything that varies
  between deploys — endpoints, credentials handles, feature toggles — enters
  the process from the environment, never from a file baked into the
  artifact. An artifact that embeds its environment can only ever be tested
  as the environment it embeds; the same build must be promotable untouched
  from staging to production.
- **Processes are stateless** (factor VI). Anything worth keeping lives in a
  backing service; local disk and memory are per-request scratch space. A
  process that hoards state cannot be scaled horizontally, replaced on
  failure, or drained on deploy — statefulness in the process is a denial of
  every operation the platform exists to perform.
- **Disposability** (factor IX). Processes start fast and shut down clean on
  SIGTERM: finish in-flight work, release the locks, exit. A process that
  cannot be killed safely cannot be deployed safely — every rollout becomes
  a small outage negotiated by hand.
- **Dev/prod parity** (factor X). The gap between development and production
  — in time, in people, in tooling — is kept minimal, and the artifact that
  ran in staging is byte-for-byte the artifact that runs in production.
  "Build once, promote everywhere" is the mechanical form of this factor.

**OCI is the artifact contract.** The deployable unit is a container image
under the OCI Image Format Specification v1.1, executed under the OCI
Runtime Specification v1.2, distributed under the OCI Distribution
Specification v1.1. The point of the triple contract is substitutability:
any compliant builder, registry and runtime interoperate, so the platform is
a choice, not a lock-in. The image is immutable and content-addressed — it
is referenced by digest, because a tag is a mutable pointer and a mutable
pointer is not an identity. That goes for what the project ships and for
what it ships on: a base image pinned by tag alone (`:latest` being the
degenerate case) means the artifact rebuilt tomorrow is not the artifact
reviewed today.

**Telemetry that cannot answer "what happened to this request" fails.** The
observability contract is OpenTelemetry: traces, metrics and logs emitted
with the attribute names the OpenTelemetry Semantic Conventions define
(stable for HTTP since v1.23.0), correlated by trace and span identity.
Semantic conventions are what make telemetry queryable across services —
`http.response.status_code` means the same thing everywhere, so one query
spans the fleet. Correlation is what makes it an instrument instead of a
mood: a log line that does not carry its trace id is an anecdote; three
dashboards that cannot be joined on a request are three separate opinions.
The test of the whole apparatus is a single question asked of a single
failing request — what happened to it, where, and why — answered from
telemetry alone, without ssh.

**The error budget is a fitness function, not a sentiment.** SRE discipline
(Site Reliability Engineering, 2016; The Site Reliability Workbook, 2018)
gives reliability a mechanical form: each user-facing service declares SLIs
(what is measured), SLOs (the target), and thereby an error budget — the
tolerated unreliability, 1 minus the SLO. The canon adopts this as a fitness
function under Art. XII: exceeding the budget is a bug, not a trend to
watch. When the budget is exhausted, feature work yields to reliability work
— and the yield is mechanical, a release gate that reads the budget and
blocks, not a cultural aspiration that loses every negotiation with a
deadline. A 100% target is not rigor; it is the absence of an engineering
decision, since it allocates zero budget to change, and change is where the
product lives.

**Identity is the perimeter.** NIST SP 800-207 dissolves the walled-garden
model: network position confers no trust. Being "inside" — the VPC, the
VPN, the cluster, the service mesh — authorizes nothing; every access to
every resource is authenticated and authorized per request, based on the
identity of the caller (workload or user) and the policy for the resource.
The mechanical consequences: service-to-service calls carry verifiable
workload identity (mTLS or equivalent); network rules default-deny and open
only named flows, as documented exceptions rather than CIDR generosity; and
the phrase "internal service, no auth needed" is recognized for what it is —
a breach report scheduled in advance.

**The supply chain has a floor.** NIST SP 800-218 (SSDF v1.1) makes
protecting the build and verifying what ships baseline practice; SLSA v1.0
grades how believably a given artifact came from the source and build it
claims (Build L1: documented, provenance exists; L2: hosted build with
signed provenance; L3: hardened, tamper-resistant build). The canon's floor:
every deployable artifact carries provenance at SLSA Build L1 or above with
a declared target level, and an SBOM in SPDX 2.3 (ISO/IEC 5962:2021) is
producible for it on demand. The SCA dimension already scans the declared
dependency graph; the SBOM here inventories the artifact as built — the two
answer different questions, and only the second answers "what is actually
running". An artifact whose contents cannot be enumerated is not known — it
is assumed.

**Hardening starts from a baseline, not from scratch.** CIS Benchmarks are
the published, versioned consensus for hardening each platform in play —
container engine, orchestrator, operating system, managed cloud services.
The canon does not require every benchmark item; it requires that the
baseline be adopted explicitly and that every deviation be a recorded
decision naming what was relaxed and why. Hardening invented locally is
indistinguishable from hardening omitted locally — the benchmark exists so
that the burden of proof sits on the deviation, not on the default.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Deploy-varying config enters via the environment; no environment-specific value or credential is baked into the artifact or committed in IaC | Twelve-Factor App — factor III; NIST SP 800-218 SSDF v1.1 — PS.1 | `iac-scan` + `container-lint` (hardcoded values) + checklist |
| 2 | Service processes are stateless; durable state lives in declared backing services | Twelve-Factor App — factors IV, VI | checklist |
| 3 | Processes shut down clean on SIGTERM (finish in-flight work, release resources) and start fast enough for the platform's replacement cycle | Twelve-Factor App — factor IX | checklist |
| 4 | One artifact per release, promoted by digest across environments — never rebuilt per environment | Twelve-Factor App — factors V, X; OCI Image Format v1.1 (content addressing) | checklist |
| 5 | The deployable unit is an OCI image; base images are pinned by digest; no floating tag (`:latest` included) in any build or deployment file | OCI Image Format v1.1; CIS Docker Benchmark v1.6 | `container-lint` |
| 6 | Containers run as a non-root user on a minimal base; the hardening baseline is the platform's CIS Benchmark, with deviations recorded as decisions | CIS Docker Benchmark v1.6; CIS Kubernetes Benchmark v1.9 | `container-lint` + `iac-scan` + decision log |
| 7 | All infrastructure is declared as code, version-controlled, and scanned; findings at or above the declared severity floor block; out-of-band console changes are drift, not operations | NIST SP 800-218 SSDF v1.1 — PO.5 (secure environments) | `iac-scan` |
| 8 | Every service emits traces, metrics and logs with OpenTelemetry semantic-convention attributes; logs carry the active trace id; "what happened to this request" is answerable from telemetry alone | OpenTelemetry Semantic Conventions (v1.23.0+) | checklist |
| 9 | Every user-facing service declares SLIs and SLOs; the error budget is computed from telemetry; an exhausted budget mechanically gates feature releases until the budget recovers | SRE discipline (2016/2018); Art. XII.2 (exceeding budget is a bug) | checklist (gate presence and policy) |
| 10 | No access is authorized by network position; service-to-service calls carry verifiable workload identity; network rules default-deny with named, documented exceptions | NIST SP 800-207 — tenets 1, 2, 6 | `iac-scan` (open ingress, permissive rules) + checklist |
| 11 | Every deployable artifact has producible provenance at SLSA Build L1 or above (target level declared) and a producible SPDX 2.3 SBOM | SLSA v1.0 — Build track; SPDX 2.3 / ISO/IEC 5962:2021 | `sbom` |

---

## Checklist

> The non-mechanizable mechanism: the operability, observability, reliability
> and boundary properties no static scanner proves. Reviewed by a human per
> story that touches the deployment substrate.

- [ ] All deploy-varying config read from the environment; a diff of two environments touches env values only, never the artifact — Twelve-Factor App, factor III
- [ ] No service process holds durable state; sticky sessions, local file writes and in-process caches that outlive a request are recorded decisions — Twelve-Factor App, factors IV, VI
- [ ] SIGTERM handled: in-flight work completes or is re-queued, connections drain, exit is clean; verified by killing an instance under load — Twelve-Factor App, factor IX
- [ ] The digest deployed to production is the digest validated in staging — build once, promote everywhere — Twelve-Factor App, factors V, X; OCI Image Format v1.1
- [ ] A failing request can be traced end to end from telemetry alone: trace spans across services, correlated logs, no ssh required — OpenTelemetry Semantic Conventions (v1.23.0+)
- [ ] SLIs/SLOs declared per user-facing service; the error budget is visible on a dashboard and wired to a release gate that blocks on exhaustion — SRE discipline (2016/2018); Art. XII.2
- [ ] No service-to-service call trusted by network position: workload identity verified (mTLS or equivalent), authorization evaluated per request — NIST SP 800-207, tenets 1, 2, 6
- [ ] The platform's CIS Benchmark is the declared hardening baseline; every deviation is a recorded decision naming what was relaxed and why — CIS Benchmarks (versioned per platform)

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Twelve-Factor App | The 12factor.net methodology (2017 revision) for operable services; factors are numbered I–XII |
| Backing service | Any service the app consumes over the network (database, queue, cache), treated as an attached, swappable resource |
| Disposability | Twelve-factor property: fast startup plus graceful shutdown, making processes cheap to replace |
| Dev/prod parity | Keeping development and production close in time, tooling and substrate so staging validity transfers |
| OCI | Open Container Initiative — publisher of the image, runtime and distribution specifications that make container tooling interchangeable |
| Image digest | The content-addressed hash identifying an OCI image; immutable, unlike a tag |
| Floating tag | A mutable image reference (e.g. `:latest`) that can point at different content over time |
| IaC | Infrastructure as code — infrastructure declared in version-controlled files and applied by tooling, never hand-built |
| Drift | Divergence between the declared infrastructure and the running infrastructure, typically from out-of-band console changes |
| OpenTelemetry | The CNCF observability framework defining the signal model (traces, metrics, logs) and its semantic conventions |
| Semantic conventions | The OpenTelemetry attribute-naming standard that makes telemetry comparable across services and tools |
| Trace / span | A trace is one request's end-to-end record; a span is one operation within it; ids correlate signals |
| SLI | Service Level Indicator — the measured quantity (e.g. fraction of successful requests) |
| SLO | Service Level Objective — the target for an SLI over a window (e.g. 99.9% over 30 days) |
| Error budget | 1 minus the SLO: the unreliability the service may spend; exhaustion gates feature releases (Art. XII) |
| Zero trust | NIST SP 800-207 posture: no implicit trust from network position; every access authenticated and authorized per request |
| Workload identity | A verifiable identity carried by a service (certificate, signed token) used to authenticate service-to-service calls |
| mTLS | Mutual TLS — both ends of a connection authenticate with certificates; a common workload-identity mechanism |
| Default-deny | Network/policy posture where nothing is reachable until a rule affirmatively allows a named flow |
| SSDF | NIST SP 800-218 Secure Software Development Framework v1.1 — baseline secure development and build practices |
| SLSA | Supply-chain Levels for Software Artifacts v1.0 — graded levels (Build L1–L3) of build provenance believability |
| Provenance | Signed metadata stating which source and build produced an artifact |
| Attestation | A signed statement (provenance being one kind) about an artifact, verifiable by a third party |
| SBOM | Software bill of materials — the machine-readable inventory of an artifact's contents; SPDX 2.3 is the ISO-standardized format |
| CIS Benchmark | A versioned consensus hardening baseline published by the Center for Internet Security for a specific platform |
| Not assessable | The honest verdict when the substrate a rule needs does not exist in the project (Art. XXV.3) — never a score |
