---
sdd: canon
dimension: database
standards:
  - "ISO/IEC 25012:2008 (data quality model)"
  - "ISO/IEC 9075:2023 (SQL:2023 — transaction isolation levels and phenomena)"
  - "NIST SP 800-53 Rev. 5 (AC-3/AC-4 access enforcement; SC-28 protection of information at rest)"
sensors:
  - migration-lint
  - rls-coverage
  - query-budget
  - schema-crypto
measurability: "Requires a database substrate in the project: a version-controlled schema (migration files or DDL) and, for the runtime sensors, a reachable database instance to query. A project with no database substrate is reported as not assessable — never scored."
---

# Canon — Database

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the schema, migration, isolation and
> encryption verdicts come from the sensors below.

---

## Doctrine

A database outlives every application that talks to it. Code gets rewritten;
the data — and every shortcut taken in its shape — stays. This dimension
holds the schema to the same discipline the rest of the canon holds code to:
declared invariants, verified mechanically, with every deviation recorded as
a decision instead of accumulated as accident.

**Normal forms are the default; denormalization is a decision.** A schema in
third normal form (or Boyce-Codd normal form where the keys allow it) stores
each fact once, which is what makes update, insertion and deletion anomalies
structurally impossible rather than merely unlikely. Denormalization is
sometimes the right call — read-heavy paths, reporting shapes, avoiding a
join the workload cannot afford — but it is never the silent call. Every
denormalized copy is a consistency liability under ISO/IEC 25012:2008
(consistency: data free of contradiction, coherent with other data), so it
enters the schema only as a recorded decision naming the anomaly it accepts
and the mechanism (trigger, materialized view refresh, application-level
write-through) that keeps the copies coherent. A duplicate column nobody can
explain is not an optimization; it is a bug with latency.

**ACID is a contract, and isolation is its negotiable clause — negotiate it
knowingly.** Atomicity, consistency and durability are table stakes; isolation
is where engines trade correctness for throughput, and SQL:2023 defines the
trade precisely, by the phenomena each level admits:

| Isolation level | Dirty read | Non-repeatable read | Phantom |
|-----------------|-----------|---------------------|---------|
| READ UNCOMMITTED | admitted | admitted | admitted |
| READ COMMITTED | prevented | admitted | admitted |
| REPEATABLE READ | prevented | prevented | admitted |
| SERIALIZABLE | prevented | prevented | prevented |

Choosing a level means choosing which of these anomalies the workload can
absorb — not accepting whatever the engine defaults to. Two honesty notes
the doctrine insists on: most MVCC engines implement REPEATABLE READ as
snapshot isolation, which additionally admits **write skew** (two
transactions each reading the invariant the other one breaks) even though it
prevents the three standard phenomena; and an engine's default level is a
vendor choice, not a design. Invariants that span rows — balances, quotas,
uniqueness enforced in application code — either run at SERIALIZABLE, take
explicit locks, or are re-checked by a constraint the database enforces.

**Data quality is a measured property, not a mood.** ISO/IEC 25012:2008
gives the vocabulary: inherent characteristics (accuracy, completeness,
consistency, credibility, currentness) that live in the data itself, and
system-dependent characteristics (availability, portability, recoverability)
that live in the platform, with a shared band (accessibility, compliance,
confidentiality, efficiency, precision, traceability, understandability)
spanning both. The schema is the first enforcement point for the inherent
set: NOT NULL and CHECK constraints are completeness and accuracy made
mechanical; foreign keys are consistency made mechanical. A constraint
enforced only in application code is enforced in exactly one of the N
programs that will ever write this database.

**Expand-contract is THE migration rule.** Every schema change on a live
system follows the four-step sequence — **add** the new structure alongside
the old, **migrate** the data, **switch** the readers and writers, **remove**
the old structure only after nothing references it. A direct destructive
change (dropping or renaming a live column, narrowing a type in place,
tightening a constraint against existing rows) couples the schema change to
the deployment instant and turns every rollback into data loss; it is
forbidden, not discouraged. Two properties every migration must have:
**idempotent** (running it twice is safe — reruns happen, in recovery and in
drift repair) and **reversible** — or, where reversal is genuinely
impossible (data was destroyed by design, e.g. a contract step after its
grace window), the irreversibility is documented in the migration itself,
with the backup or export that stands in for the down path. The availability
and recoverability characteristics of ISO/IEC 25012:2008 are exactly what
this sequence protects: the system keeps answering, correctly, through the
change.

**Multi-tenant isolation is built, not bolted on.** In any schema where rows
belong to tenants, Row-Level Security is enabled in the same migration that
creates the table, with a **default-deny** policy: no session sees any row
until a policy affirmatively grants it the current tenant's rows. Retrofitting
RLS onto a live schema means a window — usually months — in which every
query is one missing WHERE clause away from a cross-tenant leak, and means
auditing every existing access path instead of inheriting safety from the
table's birth certificate. Enforcement lives in the database (NIST SP 800-53
Rev. 5, AC-3: access enforcement at the resource) because the database is
the one component every access path must traverse. And because a policy that
exists but does not bind is indistinguishable from no policy, the isolation
is **proven by tests**: a suite that connects as tenant A, attempts to read
and write tenant B's rows, and asserts the attempt fails. A green
cross-tenant test is the only evidence that counts; the policy's presence in
the catalog is a precondition, not a proof.

**Encryption at rest follows classification, not habit.** The project's data
classification (which columns hold regulated, secret or personal data) drives
which storage is encrypted and at what granularity — full-instance
encryption as the floor, column- or field-level mechanisms where the
classification demands that even a database-level compromise not expose the
value (NIST SP 800-53 Rev. 5, SC-28). Encrypting everything identically is
not rigor; it is the absence of a classification. The mechanical check is a
catalog-level assertion: every column tagged with a classification that
requires encryption demonstrably has it.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | The schema is normalized (3NF/BCNF) by default; every denormalized structure carries a recorded decision naming the accepted anomaly and the mechanism that keeps copies coherent | ISO/IEC 25012:2008 — consistency | migration review (decision recorded in the decision log; `migration-lint` flags the structural change) |
| 2 | Every transaction runs at an isolation level chosen from the anomalies the workload tolerates — never at an unexamined engine default; cross-row invariants use SERIALIZABLE, explicit locks, or a database-enforced constraint | ISO/IEC 9075:2023 — isolation levels and phenomena | code review + `query-budget` (hot-path transactions declare their level) |
| 3 | Schema changes ship exclusively as expand-contract sequences (add, migrate, switch, remove); no destructive DDL against a live column | ISO/IEC 25012:2008 — availability, recoverability | `migration-lint` |
| 4 | Every migration is idempotent; every migration is reversible, or documents its irreversibility and the recovery path in the migration file itself | ISO/IEC 25012:2008 — recoverability | `migration-lint` + migration review |
| 5 | Every tenant-scoped table has Row-Level Security enabled with a default-deny policy in the migration that creates it — never enabled retroactively | NIST SP 800-53 Rev. 5 — AC-3 | `rls-coverage` |
| 6 | Cross-tenant isolation is proven by tests that attempt cross-tenant reads and writes and assert failure | NIST SP 800-53 Rev. 5 — AC-4 | `rls-coverage` (policy presence) + the cross-tenant test suite |
| 7 | Columns whose data classification requires encryption are demonstrably encrypted at rest, at the granularity the classification demands | NIST SP 800-53 Rev. 5 — SC-28 | `schema-crypto` |
| 8 | Declared hot-path queries stay within their plan budget; a plan regression blocks like any other regression | ISO/IEC 25012:2008 — efficiency | `query-budget` |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| 3NF / BCNF | Third normal form / Boyce-Codd normal form — schema shapes in which every non-key fact depends on the key, making update anomalies structurally impossible |
| Denormalization | Deliberately storing a fact more than once for read performance — admitted only as a recorded decision with a coherence mechanism |
| ACID | Atomicity, Consistency, Isolation, Durability — the transaction contract |
| Isolation level | The SQL:2023 setting deciding which concurrency anomalies a transaction admits (see the phenomena table in Doctrine) |
| Dirty read | Reading data another transaction wrote but has not committed |
| Non-repeatable read | Re-reading a row inside one transaction and getting a different value |
| Phantom | Re-running a predicate query inside one transaction and getting new rows |
| Write skew | Two snapshot-isolated transactions each reading the invariant the other breaks — admitted by snapshot isolation even where the three standard phenomena are prevented |
| MVCC | Multi-version concurrency control — the engine technique that makes snapshot isolation the common REPEATABLE READ implementation |
| Expand-contract | The four-step live migration sequence: add the new structure, migrate data, switch readers/writers, remove the old structure |
| Idempotent migration | A migration safe to run more than once with the same end state |
| RLS | Row-Level Security — per-row access policies enforced by the database itself |
| Default-deny | A policy posture where no row is visible until a policy affirmatively grants it |
| Tenant-scoped table | A table whose rows belong to exactly one tenant of a multi-tenant system |
| Data classification | The project's labeling of data sensitivity (regulated, secret, personal, public) that drives protection requirements |
| Encryption at rest | Encryption of stored data — instance-level as the floor, column/field-level where classification demands it |
| Plan budget | A declared ceiling on the execution plan cost/shape of a hot-path query, checked with EXPLAIN |
