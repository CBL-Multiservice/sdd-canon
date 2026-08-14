---
sdd: canon
dimension: cloud
standards:
  - "AWS Well-Architected Framework (six-pillar revision, 2023+)"
  - "Microsoft Azure Well-Architected Framework (2026 edition)"
  - "Google Cloud Architecture Framework (2026 edition)"
  - "ISO/IEC 27017:2015 (code of practice for cloud security controls)"
  - "ISO/IEC 27018:2019 (protection of PII in public clouds acting as PII processors)"
  - "FinOps Framework (FinOps Foundation, 2024+)"
sensors:
  - cost-budget
checklist: true
measurability: "Requires a cloud provider substrate: resources provisioned on (or IaC/manifests targeting) a public cloud provider, or a billing/usage export for that footprint. A project with no cloud provider substrate is reported as not assessable — never scored. A fully on-premises project is assessed only on the clauses that transfer (budget discipline, recovery objectives, least privilege); provider-posture clauses stay not assessable."
---

# Canon — Cloud

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the budget verdict comes from the `cost-budget`
> sensor, and the posture, compliance and per-pillar reviews from the
> framework-derived checklist below.

---

## Doctrine

**Boundary with the infrastructure dimension (read first).** The
[infrastructure](infrastructure.md) canon owns the mechanics of the substrate:
containers and OCI artifacts, infrastructure-as-code and its scanning, the
supply chain (provenance, SBOM), telemetry, SLOs, zero-trust networking. This
dimension owns what sits above those mechanics when the substrate is rented
from a provider: the provider posture (how the account, identity and service
surface are governed), the architecture pillars the public frameworks agree
on, and cost as an engineering property. The two dimensions meet at IaC — the
`iac-scan` sensor is registered under infrastructure and stays there; cloud
provider policy packs for it arrive pinned via the `sdd-canon` registry
(phase 4, Art. XXV.4). Nothing in this doc re-litigates a rule
infrastructure.md already states.

**The pillars are a union, not a copy.** All three public frameworks — the
AWS Well-Architected Framework (2023+), the Microsoft Azure Well-Architected
Framework (2026) and the Google Cloud Architecture Framework (2026) — converge
on the same small set of architecture pillars. The canon adopts the UNION of
the six as provider-neutral doctrine: operational excellence, security,
reliability, performance efficiency, cost optimization, sustainability.
Sustainability is an explicit pillar only in the AWS framework; Azure and
Google Cloud carry it as efficiency and carbon guidance — the union keeps it,
because a pillar one framework names and the others imply is still doctrine.
Each pillar below states the one rule that is not negotiable; everything else
is the checklist.

### Operational excellence

Operations are code. Every change to the cloud footprint — resources,
policies, quotas, alarms — goes through the same version-controlled, reviewed,
sensor-gated path as application code. The non-negotiable: **no console-driven
operations.** A change applied by hand in a provider console is drift the
moment it lands (infrastructure.md, rule 7); an operational procedure that
exists only in someone's memory is an outage response that cannot be reviewed,
rehearsed or rolled back. Runbooks are versioned artifacts; failure reviews
feed changes back through the pipeline.

### Security

The provider secures the cloud; the tenant secures what is in it — and the
line between the two is a documented fact, not folklore. The non-negotiable:
**least-privilege identity with no long-lived static credentials.** Human and
workload access is federated, short-lived and scoped to the task;
provider-account root/owner credentials are locked away and alarmed, never
used for routine work. ISO/IEC 27017:2015 is the compliance anchor: it extends
the ISO/IEC 27002 control set to the cloud relationship and forces the
shared-responsibility split to be stated per service consumed. Where the
project stores or processes PII on a public cloud, ISO/IEC 27018:2019 is the
second anchor: the tenant knows — and can state in writing — where PII lives,
for what purpose, and how it is returned or destroyed at contract end.

### Reliability

Every provider building block fails; the architecture, not the provider, is
what decides whether users notice. The non-negotiable: **recovery objectives
are declared and exercised.** Each user-facing workload declares its RTO and
RPO, the deployment spans failure domains (zones/regions) proportionate to
those objectives, and recovery is proven by running it — a restore that has
never been executed is a hope with a schedule. This composes with the SLO and
error-budget discipline infrastructure.md already mandates; the cloud clause
adds the provider-failure dimension to it.

### Performance efficiency

In a rented substrate, capacity is a continuous decision, not a purchase. The
non-negotiable: **capacity decisions come from measured utilization, never
from guesswork.** Instances, tiers and scaling bounds are selected and revised
against telemetry (Art. XII: performance has a budget and exceeding it is a
bug); managed and elastic services are preferred over self-operated
equivalents where they fit, because undifferentiated heavy lifting is spend
without product.

### Cost optimization

Cost is a fitness function, not a finance report. Under Art. XII the canon
treats spend exactly as it treats latency: **each environment declares a
monthly budget, and exceeding it is a bug that blocks — not a line item to
explain at month end.** The mechanism is the `cost-budget` sensor: projected
or actual spend is compared against the declared ceiling before deploy or on
schedule, and a breach fails the gate. Two further clauses make the budget
honest. First, unit economics: total spend is a vanity number until divided —
cost per request, per tenant, per job is tracked so growth in spend can be
distinguished from growth in business. Second, allocation: every provisioned
resource carries the mandatory cost-allocation tags/labels; an untagged
resource is a finding, because spend that cannot be attributed cannot be
optimized or even questioned.

### Sustainability

The efficiency pillar with a longer horizon. The non-negotiable: **utilization
is the metric — provisioned-but-idle capacity is waste twice**, once in the
budget and once in the energy the provider spends holding it. Right-sizing,
scale-to-zero for bursty workloads, lifecycle policies on storage, and region
choices that weigh the provider's published carbon data are the practical
form. This pillar rides the same telemetry and the same `cost-budget` sensor
as cost optimization: in a rented substrate, the proxy for carbon is the bill.

**FinOps is an engineering discipline, not an accounting one.** The FinOps
Framework (FinOps Foundation, 2024+) gives the cost pillar its operating
cycle — inform (allocate and show costs to the teams that cause them),
optimize (right-size, reserve, re-architect), operate (make the loop
continuous and owned by engineering). The canon adopts the framework's core
premise: the people who provision resources see and own their cost signal,
at the cadence of engineering (per deploy, per story), not the cadence of
invoicing. The budget, the unit metrics and the tagging rules above are the
framework's practices bound to Art. XII's enforcement: a fitness function
that blocks.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Each environment (dev/staging/prod) declares a monthly cost budget; projected or actual spend exceeding it is a bug that blocks (Art. XII.2) | FinOps Framework (2024+) — budgeting; Well-Architected cost pillars (AWS 2023+/Azure 2026/GCP 2026) | `cost-budget` |
| 2 | Unit economics are tracked: at least one cost-per-unit metric (per request, per tenant, or per job) is computed from billing data and reviewed | FinOps Framework (2024+) — unit economics | `cost-budget` + checklist |
| 3 | Every provisioned resource carries the declared cost-allocation tags/labels; an untagged resource is a finding | FinOps Framework (2024+) — cost allocation | `cost-budget` |
| 4 | The shared-responsibility split is documented per consumed cloud service: which controls the provider holds, which the tenant holds | ISO/IEC 27017:2015 — cloud-service-customer / cloud-service-provider control split | checklist |
| 5 | Where PII is stored or processed on a public cloud, its location, purpose, and return/deletion path are declared in writing | ISO/IEC 27018:2019 | checklist |
| 6 | No long-lived static credentials for humans or workloads; identity is federated, short-lived and least-privilege; root/owner credentials are locked and alarmed | Well-Architected security pillars (AWS 2023+/Azure 2026/GCP 2026); ISO/IEC 27017:2015 | checklist |
| 7 | Every change to the cloud footprint goes through version control and review; console-applied changes are drift | Well-Architected operational-excellence pillars (AWS 2023+/Azure 2026/GCP 2026) | checklist (+ `iac-scan`, owned by infrastructure) |
| 8 | Each user-facing workload declares RTO/RPO, spans failure domains proportionate to them, and exercises recovery on a schedule | Well-Architected reliability pillars (AWS 2023+/Azure 2026/GCP 2026) | checklist |
| 9 | Capacity (instance sizes, tiers, scaling bounds) is set and revised from measured utilization; idle provisioned capacity is a finding | Well-Architected performance-efficiency + sustainability pillars (AWS 2023+/Azure 2026/GCP 2026) | checklist |

---

## Checklist

> Framework-derived, provider-neutral in substance: each pillar maps to its
> named counterpart in the three public frameworks, and every item below is
> generic — posture and policy, never console click-paths. Reviewed by a human
> per story that touches the cloud footprint; the cost items are additionally
> enforced by the `cost-budget` sensor.

**Pillar map (union → the three frameworks):**

| Canon pillar | AWS Well-Architected (2023+) | Azure Well-Architected (2026) | Google Cloud Architecture Framework (2026) |
|---|---|---|---|
| Operational excellence | Operational Excellence | Operational Excellence | Operational excellence |
| Security | Security | Security | Security, privacy, and compliance |
| Reliability | Reliability | Reliability | Reliability |
| Performance efficiency | Performance Efficiency | Performance Efficiency | Performance optimization |
| Cost optimization | Cost Optimization | Cost Optimization | Cost optimization |
| Sustainability | Sustainability | (efficiency/carbon guidance) | (efficiency/carbon guidance) |

- [ ] Every cloud resource and policy change is version-controlled and reviewed; no standing human write access to production consoles; break-glass access is alarmed and time-boxed — operational-excellence pillar (AWS 2023+ / Azure 2026 / GCP 2026)
- [ ] Runbooks for the top operational events are versioned artifacts, and at least one failure scenario has been rehearsed against them — operational-excellence pillar (AWS 2023+ / Azure 2026 / GCP 2026)
- [ ] Human and workload identities are federated and short-lived; no long-lived access keys in use; root/owner credentials locked away with usage alarms — security pillar (AWS 2023+ / Azure 2026 / GCP 2026); ISO/IEC 27017:2015
- [ ] The shared-responsibility split is written down per consumed service (IaaS/PaaS/SaaS lines differ), and the tenant-side controls each have an owner — ISO/IEC 27017:2015
- [ ] If PII touches a public cloud: storage locations/regions, processing purpose, sub-processor visibility, and the return/deletion path are documented — ISO/IEC 27018:2019
- [ ] Each user-facing workload declares RTO/RPO; deployment spans availability zones (and regions where objectives demand it); backup restore and failover have been executed, not just configured — reliability pillar (AWS 2023+ / Azure 2026 / GCP 2026)
- [ ] Provider service quotas and limits for the workload's growth path are known and headroom-monitored — reliability pillar (AWS 2023+ / Azure 2026 / GCP 2026)
- [ ] Instance/tier/scaling choices are backed by utilization data reviewed on a cadence; managed or elastic services are the default where they fit — performance-efficiency pillar (AWS 2023+ / Azure 2026 / GCP 2026)
- [ ] A monthly budget is declared per environment and wired to the `cost-budget` sensor; a breach blocks, never merely alerts — cost-optimization pillar (AWS 2023+ / Azure 2026 / GCP 2026); FinOps Framework (2024+); Art. XII.2
- [ ] At least one unit-economics metric (cost per request/tenant/job) is computed from billing exports and visible to the engineering team — FinOps Framework (2024+)
- [ ] The mandatory cost-allocation tag/label set is declared, applied at provision time, and untagged resources surface as findings — FinOps Framework (2024+)
- [ ] Idle or oversized capacity is reviewed on a cadence: right-sizing, scale-to-zero for bursty workloads, storage lifecycle policies in place; region choice weighs provider-published carbon data where objectives allow — sustainability pillar (AWS 2023+; efficiency/carbon guidance in Azure 2026 / GCP 2026)

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Well-Architected | The family of public cloud architecture frameworks (AWS, Azure, Google Cloud) organizing guidance into pillars |
| Pillar | One top-level concern of a Well-Architected framework (e.g. reliability, cost optimization) |
| Union of pillars | This canon's provider-neutral pillar set: everything any of the three frameworks names, deduplicated |
| Shared responsibility | The documented split of security controls between the cloud provider (of the cloud) and the tenant (in the cloud); ISO/IEC 27017:2015 formalizes it |
| PII | Personally identifiable information; on public clouds its handling is anchored to ISO/IEC 27018:2019 |
| PII processor | A party processing PII on behalf of another (the public cloud provider, in the 27018 relationship) |
| FinOps | The FinOps Foundation's operating model for cloud cost: inform, optimize, operate — cost owned by engineering |
| Cost budget | The declared monthly spend ceiling per environment; a fitness function under Art. XII — exceeding it is a bug |
| Unit economics | Cost divided by a business unit (request, tenant, job), separating spend growth from business growth |
| Cost allocation tags | The mandatory tag/label set every resource carries so spend is attributable; untagged = finding |
| Billing export | The provider's machine-readable usage/cost feed; the data source for budget and unit-economics checks |
| RTO | Recovery time objective — how long a workload may be down after a failure |
| RPO | Recovery point objective — how much data (in time) a workload may lose after a failure |
| Failure domain | The blast radius unit of a provider (availability zone, region); reliability spans them |
| Right-sizing | Adjusting provisioned capacity to measured utilization; the shared practice of the performance and sustainability pillars |
| Break-glass access | Emergency human access outside the normal pipeline — permitted only alarmed, logged and time-boxed |
| Drift | Divergence between declared and running footprint, typically from console changes (see infrastructure.md) |
| Not assessable | The honest verdict when the project has no cloud provider substrate (Art. XXV.3) — never a score |
