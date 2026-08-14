---
sdd: canon
dimension: docs-adr
standards:
  - "ISO/IEC/IEEE 42010:2022 (architecture description — decision rationale)"
  - "MADR 4.0.0 (2024) — Markdown Any Decision Records template"
sensors:
  - adr-check
measurability: "Requires a version-controlled repository with declared architectural paths (the modules/directories whose change implies an architectural decision). Every repo has the substrate; what varies is the declaration — a project that has not declared its architectural paths is assessable and fails rule 5, because the missing declaration is the finding."
---

# Canon — Docs / ADR

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; presence of a decision record on architectural
> change is enforced by the `adr-check` sensor; the quality of the record is
> a review rule this doc states plainly.

---

## Doctrine

**An architectural decision without an ADR is drift.** Not future drift —
drift already: the moment a boundary moves and no record says why, the
system's structure and the team's shared understanding of it have parted
ways. ISO/IEC/IEEE 42010:2022 makes decision rationale a first-class element
of an architecture description; this canon makes it enforceable. Code
reviews answer "is this change correct?"; only the ADR answers "why was this
change chosen over its alternatives?" — and that second question is the one
the next maintainer, the auditor and the future migration all ask.

**Two homes, one discipline (the kit's split).** Inside the SDD harness the
working-artifact form of this rule already exists: `decision-log.md`, where
every process/product/technical decision lands with context, alternatives
and reversibility (see the kit's own log for the living example). Deliverable
ADRs are different artifacts: under Art. XXIII they live WITH the
deliverable — in the delivered repository, under a declared path (e.g.
`docs/adr/`), versioned with the code they explain. The kit's decision-log
governs the kit's own evolution; the deliverable's ADRs travel with the
deliverable. One discipline, two homes, no copies.

**The format is small on purpose.** An ADR records: CONTEXT (the forces and
constraints at decision time), DECISION (what was chosen, in the active
voice), CONSEQUENCES (what becomes easier, what becomes harder, what debt is
accepted), and STATUS (proposed, accepted, deprecated, superseded — with a
link when superseded). MADR 4.0.0 (2024) is the reference template; a team
may extend it, never shrink below those four. A superseded ADR is never
deleted: the chain of superseded records IS the architectural history, and
rewriting it is the documentation equivalent of force-pushing over main.

**When an ADR is mandatory.** Judgment governs the gray zone, but four
triggers are not negotiable — each of these changes ships with an ADR or
does not ship: (1) a NEW DEPENDENCY that becomes load-bearing (framework,
database, broker, hosted service); (2) a BOUNDARY CHANGE (module/service
split or merge, ownership move, public contract change); (3) a PARADIGM or
TOPOLOGY choice (sync to async, monolith to services, new persistence
model); (4) a SECURITY POSTURE change (authn/authz model, trust boundary,
crypto, data classification). The mechanical proxy for "architectural" is
the declared-paths list the sensor watches; the four triggers are what the
declaration must at minimum cover.

**The sensor checks presence, review checks honesty.** `adr-check` can
assert that a change touching declared architectural paths carries an ADR
reference. It cannot assert that the context is truthful or the
consequences complete — that is the reviewer's job, and this doc says so
instead of implying the sensor does more than it does.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Every change touching the declared architectural paths carries an ADR reference (a new ADR or an explicit pointer to the governing one) | ISO/IEC/IEEE 42010:2022 — decision rationale | `adr-check` |
| 2 | ADRs contain at minimum context, decision, consequences, status | MADR 4.0.0 (2024) | review rule |
| 3 | The four mandatory triggers (new load-bearing dependency; boundary change; paradigm/topology choice; security posture change) always produce an ADR | ISO/IEC/IEEE 42010:2022 — key decisions recorded | `adr-check` (via declared paths) + review rule |
| 4 | ADRs are immutable history: superseding creates a new record linked from the old; deletion or rewriting of accepted ADRs is forbidden | MADR 4.0.0 (2024) — status/supersede chain | review rule |
| 5 | The deliverable declares its ADR location and its architectural paths; the kit's own decisions land in decision-log.md (working artifact, Art. XXIII split) | ISO/IEC/IEEE 42010:2022 — architecture description identified | `adr-check` (declaration required to run) |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| ADR | Architecture Decision Record — one recorded decision: context, decision, consequences, status |
| MADR | Markdown Any Decision Records — the public template (4.0.0, 2024) this canon uses as format reference |
| Decision rationale | The why behind a structural choice; a first-class element of an architecture description per ISO/IEC/IEEE 42010:2022 |
| Declared architectural paths | The versioned list of modules/directories whose change implies an architectural decision — the sensor's watch list |
| Mandatory trigger | One of the four change classes that always requires an ADR (dependency, boundary, paradigm/topology, security posture) |
| Superseded | The status of an ADR replaced by a newer one; both remain, linked — the chain is the history |
| decision-log.md | The kit's own working-artifact decision record (Art. XXIII: work in `.sdd/`, deliverable ADRs with the deliverable) |
| Drift | Structure and recorded rationale diverging — the state this dimension exists to prevent |
