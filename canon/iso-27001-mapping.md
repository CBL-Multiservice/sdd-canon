---
sdd: canon
dimension: iso-27001-mapping
standards:
  - "ISO/IEC 27001:2022 (information security management systems — requirements)"
  - "ISO/IEC 27002:2022 (information security controls)"
sensors: []
checklist: true
measurability: "Requires an installed SDD harness whose governance artifacts are actually exercised: sensors.yaml filled in, contracts with QA evidence, decision-log entries, telemetry. The mapping is assessable exactly to the extent those artifacts exist and carry real runs; a kit installed but never used yields an empty dossier — reported as empty, never scored."
---

# Canon — ISO 27001 Mapping

> One engineering dimension of the Quality Canon (Art. XXV). No sensor of its
> own: the mechanism is the mapping table plus the checklist below — the
> other dimensions' sensors do the producing; this doc tells an auditor
> where their output lands.

---

## Doctrine

**The disclaimer comes first, because honesty does (RF-C9, framing P3).**
ISO/IEC 27001 certifies an ORGANIZATION'S ISMS — its information security
management system: people, processes, leadership, risk treatment — it does
not and cannot certify code. No tool output is a certificate, and running
this kit makes no one "27001 compliant". What the SDD does is narrower and
real: its governance artifacts (contracts with QA evidence, the decision
log, traceability, sensor telemetry) form an EVIDENCE DOSSIER an auditor
can read when assessing the development-related controls of ISO/IEC
27002:2022. The SDD generates the dossier and NEVER promises certification.
Any claim beyond that sentence is sales copy, and it does not belong in
this kit.

**Why the mapping targets 27002, not 27001 directly.** ISO/IEC 27001:2022
states the management-system requirements; its Annex A points to the
control catalog that ISO/IEC 27002:2022 details. The controls an SDD
harness can produce evidence for are the technological ones that govern how
software is built: 8.8 (technical vulnerability management) and the secure
development block 8.24–8.32. The table below maps each of those controls to
the KIT MECHANISM that produces evidence and to the SDD ARTIFACT an auditor
actually reads. Controls outside this range (organizational, people,
physical) are out of this kit's reach, and the table does not pretend
otherwise.

**The nature of the rows, marked honestly (grounding).** Under the kit's
evidence scale, each row below is the kit's OWN claim about itself — `[P]`
(presumed): a reasoned mapping written by the kit, not a finding accepted
by an accredited auditor. What is `[A]` (anchored) is only the existence of
the cited mechanisms and artifacts — the sensors are registered in
`sensors.yaml`, the canon docs exist, the contracts carry QA evidence. The
step from "this artifact exists" to "this control is satisfied" belongs to
the auditor, never to the kit.

**How the dossier accumulates.** Nothing extra is produced for audit day —
that is the point. Every story closed under the SDD loop appends to the
dossier as a side effect: the contract records what was verified and by
which sensor (section 6), the decision log records why, traceability ties
requirement to story to evidence, telemetry timestamps the runs. An audit
preparation is then an act of COLLECTION, not creation; the checklist below
is that collection procedure.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | The kit never claims or implies ISO/IEC 27001 certification; every audit-facing statement is scoped to "evidence dossier for the mapped controls" | ISO/IEC 27001:2022 — certification applies to an organization's ISMS | checklist + review rule |
| 2 | The mapping stays within controls the harness genuinely evidences (8.8, 8.24–8.32 of ISO/IEC 27002:2022); out-of-range controls are declared out of reach | ISO/IEC 27002:2022 | checklist |
| 3 | Mapping rows carry their honest grounding: the mapping is the kit's own claim `[P]`; only artifact existence is `[A]` | ISO/IEC 27001:2022 — audit evidence is the auditor's judgment; kit evidence scale | checklist |
| 4 | Dossier content is produced by the normal SDD loop (contracts, sensors, decision log, telemetry), never fabricated for audit day | ISO/IEC 27002:2022 — 8.25 secure development life cycle | checklist |

---

## Mapping — ISO/IEC 27002:2022 controls → kit mechanism → auditor-readable artifact

> Rows are the kit's own claim, `[P]` by nature (see Doctrine). "Mechanism"
> is what produces the evidence; "artifact" is what the auditor opens.

| Control (ISO/IEC 27002:2022) | Kit mechanism producing evidence | SDD artifact an auditor reads |
|---|---|---|
| 8.8 Management of technical vulnerabilities | `sca` sensor (lockfile scan, severity floor) + `sast` sensor (pinned rulepack) per [sca.md](sca.md) / [sast.md](sast.md); accepted risk recorded | `sensors.yaml` entries; contract section 6 (QA runs); `tech-debt-registry.md` for accepted findings |
| 8.24 Use of cryptography | `schema-crypto` sensor (encryption per data classification) + `secrets` sensor (no keys in code/history), per [database.md](database.md) / [secrets.md](secrets.md) | `sensors.yaml`; contract QA evidence; canon docs stating the classification rules |
| 8.25 Secure development life cycle | The SDD loop itself: story → signed contract → implementation → blocking sensor gates → QA verdict (Constitution Arts. V, XVIII) | `CONSTITUTION.md`; `contracts/` (signed, with evidence); `workflow-status.md`; `enforcement.yaml` |
| 8.26 Application security requirements | Security requirements enter at spec time: `security-checklist.md` plus the threat floors of [api.md](api.md) (OWASP API Top 10 2023) and [ai-llm.md](ai-llm.md) (OWASP LLM Top 10 2025) | `specs/` with grounding tags; canon docs; story acceptance criteria |
| 8.27 Secure system architecture and engineering principles | Canon architecture dimensions: [code-architecture.md](code-architecture.md) (`arch-layers`, `no-cycles`), [infrastructure.md](infrastructure.md) (zero trust, NIST SP 800-207) | Canon docs; sensor runs in contracts; ADRs per [docs-adr.md](docs-adr.md) |
| 8.28 Secure coding | `sast` sensor with pinned, permissively-licensed rulepack (CWE Top 25 2024 / OWASP Top 10:2021 yardstick) per [sast.md](sast.md) | `sensors.yaml`; contract section 6; rulepack license manifest |
| 8.29 Security testing in development and acceptance | Blocking suites (`harness-check`, `qa-feature`, `pre-deploy`) incl. `security-scan`, `secrets`, `mutation-bank`; seam quality via [test-seams.md](test-seams.md) | `sensors.yaml` suites; contract QA evidence; `telemetry/` run records |
| 8.30 Outsourced development | The contract mechanism itself: deliverables and verifications signed BEFORE work; QA evidence independent of the Developer (role separation enforced by hooks) | `contracts/` (sections 1–2 signed, 5–6 evidenced); `enforcement.yaml` (GUARD-02); `decision-log.md` |
| 8.31 Separation of development, test and production environments | [infrastructure.md](infrastructure.md) (twelve-factor dev/prod parity; build once, promote by digest) + [cloud.md](cloud.md) (per-environment budgets and posture) | Canon docs; per-environment declarations; checklist reviews in stories |
| 8.32 Change management | Story/contract loop with attempt limits; every decision logged; generated status (`status-check`), transcript audit (`trace-check`), reverse-drift watch (`unanchored-change`) | `decision-log.md`; `workflow-status.md`; `traceability.md`; contract loop section 7 |

---

## Checklist

> The dossier-assembly procedure — run when preparing audit material, and
> reviewed whenever an audit-facing claim is written.

- [ ] Every audit-facing statement uses the dossier framing and none claims or implies certification — ISO/IEC 27001:2022 (certification is of an organization's ISMS)
- [ ] The mapping table above only cites mechanisms that exist in `sensors.yaml`/`tools/` and artifacts present in this repository — kit evidence scale, `[A]` for existence
- [ ] Rows remain marked as the kit's own `[P]` claim; no row is presented as an auditor-accepted finding — kit evidence scale
- [ ] For each mapped control, at least one REAL run exists (contract section 6 entry or telemetry record) before the control is included in a dossier; controls without runs are listed as "mechanism present, not yet exercised" — ISO/IEC 27002:2022, 8.25
- [ ] Controls outside 8.8 / 8.24–8.32 requested by an auditor are answered "out of this kit's evidence reach", never improvised — ISO/IEC 27002:2022

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| ISMS | Information security management system — the organizational system ISO/IEC 27001:2022 certifies; never code |
| ISO/IEC 27002:2022 | The control catalog detailing Annex A of ISO/IEC 27001:2022; source of the mapped controls |
| Control 8.8 | Management of technical vulnerabilities — evidenced here by the `sca` + `sast` sensors |
| Controls 8.24–8.32 | The secure development block: crypto, SDLC, security requirements, architecture, coding, testing, outsourcing, environment separation, change management |
| Evidence dossier | The by-product of the SDD loop an auditor reads: contracts, decision log, traceability, telemetry — collected, not created |
| `[A]` / `[P]` | The kit's grounding tags (see evidence-scale.md): anchored by citable artifact vs. the kit's own presumed claim |
| Mechanism present, not yet exercised | The honest dossier entry for a mapped control whose sensor is registered but has no real run recorded |
| Certification claim | Any statement that the kit, a project or its code "is ISO 27001 certified/compliant" — forbidden in this kit |
| Not assessable | The honest verdict when the harness's governance artifacts carry no real usage (Art. XXV.3) — an empty dossier, never a score |
