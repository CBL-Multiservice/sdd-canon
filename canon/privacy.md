---
sdd: canon
dimension: privacy
standards:
  - "GDPR — Regulation (EU) 2016/679"
  - "LGPD — Brazilian General Data Protection Law No. 13.709/2018"
  - "ISO/IEC 29100:2011 (privacy framework)"
sensors: []
checklist: true
measurability: "Requires personal data in the system: collection surfaces (forms, telemetry, logs), schema columns holding personal data, or a PII inventory. A project that demonstrably processes no personal data is not assessable — never scored. A project that visibly collects personal data but has no PII inventory IS assessable: the missing inventory is the first finding, not missing substrate."
---

# Canon — Privacy

> One engineering dimension of the Quality Canon (Art. XXV). No executable
> sensor — and honestly so: legal compliance is not sensor-provable. The
> mechanism is the standard-derived checklist below, reviewed per story that
> touches personal data; the storage-level enforcement it references is
> mechanized by the database dimension's sensors.

---

## Doctrine

**What a sensor can and cannot prove (read first).** A script can verify
that a tenant table has RLS, that a classified column is encrypted, that a
TTL job exists. No script can verify that a processing purpose is lawful,
that consent was freely given, or that a legitimate-interest balance holds.
This dimension therefore declares `checklist: true` and does not pretend
otherwise: the checklist and the recorded decisions behind it are the
mechanism, and the sensor-provable substrate is delegated — deliberately —
to [database.md](database.md) (`rls-coverage`, `schema-crypto`) and
[cloud.md](cloud.md) (ISO/IEC 27018:2019 for PII on public clouds). Passing
this checklist is engineering diligence, not a legal opinion.

**Minimization is the default, not the exception.** GDPR Art. 5(1)(c) and
LGPD Art. 6 (necessity) agree on the founding rule: collect nothing you
cannot justify against a declared purpose. Every field collected, every log
line emitted, every analytics event fired answers "which purpose needs
this?" — and a field with no answer is removed, not kept "in case". Data
you never collected cannot leak, cannot be breached, cannot be subpoenaed
and never needs a deletion job: minimization is the cheapest security
control in the entire canon.

**The PII inventory is the substrate.** You cannot minimize, protect,
expire or export what you have not mapped. The inventory lists every class
of personal data the system touches — where it lives (column, log, cache,
third-party processor), its purpose, its legal basis, its retention TTL and
its classification. Every other rule in this doc keys off that inventory;
its absence in a system that collects personal data is the first finding.

**Privacy by design and by default.** GDPR Art. 25 makes posture a product
property: the protective setting is the DEFAULT setting. Data protection is
designed in at story time — this checklist runs per story, not per audit
season — and defaults favor the data subject: minimal collection on,
optional sharing off, shortest justifiable retention. A privacy review that
happens after the schema ships is archaeology, not design.

**Purpose limitation: data collected for X is not free for Y.** GDPR Art.
5(1)(b) and LGPD Art. 6 both bind data to the purpose declared at
collection. Reusing it for a new purpose — including model training — is a
NEW processing decision: recorded, justified against a legal basis, and
reflected in the inventory. "We already have the data" is an argument about
convenience, not lawfulness.

**Retention is declared and mechanical.** Every data class in the inventory
carries a TTL derived from its purpose (GDPR Art. 5(1)(e) storage
limitation; LGPD Art. 15 termination of processing). Deletion is a
scheduled, tested mechanism — a job that runs and is verified — never a
policy PDF with no executor. Backups are inside the story: the declared TTL
states how deletion propagates to them, even when the honest answer is
"expires with the backup rotation, N days later, and that is recorded".

**Data-subject rights are product capabilities.** Access, export in a
portable format, correction and deletion (GDPR Arts. 15–20; LGPD Art. 18)
are API-able capabilities of the system — implemented, tested and bounded
by the response deadlines the laws set — not a quarterly manual scramble
through production tables. If a right takes an engineer with write access
to fulfill, it is not implemented yet.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | A PII inventory exists and is current: every personal-data class with location, purpose, legal basis, TTL and classification | GDPR Art. 30 (records of processing); LGPD Art. 37 | checklist |
| 2 | Every collected field/log/event justifies itself against a declared purpose; unjustifiable data is not collected | GDPR Art. 5(1)(c); LGPD Art. 6 (necessity) | checklist |
| 3 | Defaults are protective: minimal collection, optional sharing off, shortest justifiable retention (by design and by default) | GDPR Art. 25 | checklist |
| 4 | Reuse of collected data for a new purpose is a recorded decision with a legal basis, reflected in the inventory | GDPR Art. 5(1)(b); LGPD Art. 6 (purpose) | checklist |
| 5 | Every data class declares a TTL; deletion is a scheduled, tested mechanism whose backup propagation is stated | GDPR Art. 5(1)(e); LGPD Art. 15 | checklist |
| 6 | Data-subject rights (access, export, correction, deletion) are implemented, tested capabilities within legal deadlines | GDPR Arts. 15–20; LGPD Art. 18 | checklist |
| 7 | Storage-level protection matches classification: tenant isolation and encryption enforced by the database dimension's sensors; PII on public clouds meets the cloud dimension's ISO/IEC 27018:2019 clauses | ISO/IEC 29100:2011 — safeguards; GDPR Art. 32 | `rls-coverage` + `schema-crypto` (database.md) + cloud.md checklist |

---

## Checklist

> Reviewed per story that touches personal data. Passing it is engineering
> diligence toward the anchors below — it is NOT a legal opinion, and this
> doc says so once more on purpose.

- [ ] The PII inventory covers every personal-data class this story touches: location, purpose, legal basis, TTL, classification — GDPR Art. 30; LGPD Art. 37
- [ ] Every new field, log line or event in this story names its purpose; anything without one was dropped — GDPR Art. 5(1)(c); LGPD Art. 6
- [ ] Defaults introduced by this story are the protective option (collection minimal, sharing opt-in, retention shortest justifiable) — GDPR Art. 25
- [ ] No data is reused beyond its collection purpose without a recorded decision and legal basis — including training/analytics reuse — GDPR Art. 5(1)(b); LGPD Art. 6
- [ ] Each touched data class has a declared TTL and a deletion mechanism that runs and is tested; backup propagation is stated — GDPR Art. 5(1)(e); LGPD Art. 15
- [ ] Export and deletion for the touched data classes work through the implemented data-subject-rights path, not manual production access — GDPR Arts. 15–20; LGPD Art. 18
- [ ] Storage protections match classification: tenant-scoped tables under RLS (`rls-coverage`), classified columns encrypted (`schema-crypto`); PII on a public cloud has the ISO/IEC 27018:2019 items of cloud.md answered — GDPR Art. 32; ISO/IEC 29100:2011
- [ ] Personal data sent to any third party (including LLM providers — see [ai-llm.md](ai-llm.md)) traces to a recorded decision naming the processor and its terms — GDPR Art. 28; LGPD Art. 39

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Personal data | Any information relating to an identified or identifiable natural person (GDPR Art. 4; LGPD Art. 5) |
| PII inventory | The versioned map of every personal-data class: location, purpose, legal basis, TTL, classification — this dimension's substrate |
| Minimization | Collecting only what a declared purpose justifies (GDPR Art. 5(1)(c); LGPD Art. 6) |
| Purpose limitation | Data serves the purpose declared at collection; new use = new recorded decision (GDPR Art. 5(1)(b)) |
| Privacy by design/default | Protection built in at design time, with the protective option as the default (GDPR Art. 25) |
| Legal basis | The lawful ground for processing (consent, contract, legal obligation, legitimate interest...) named per data class |
| TTL | Time-to-live: the declared retention period per data class, executed by a scheduled, tested deletion mechanism |
| Data-subject rights | Access, portability/export, correction, deletion — implemented as product capabilities (GDPR Arts. 15-20; LGPD Art. 18) |
| Processor | A third party processing personal data on the system's behalf; engagement is recorded (GDPR Art. 28) |
| RLS | Row-level security — tenant isolation at the database layer, enforced by `rls-coverage` (database.md) |
| Not assessable | The honest verdict when the system demonstrably processes no personal data (Art. XXV.3) — never a score |
