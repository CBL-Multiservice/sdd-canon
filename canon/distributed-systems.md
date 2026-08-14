---
sdd: canon
dimension: distributed-systems
standards:
  - "RFC 9110 (HTTP Semantics, 2022)"
  - "Microsoft Azure Architecture Center — Cloud Design Patterns (2024 edition)"
  - "AWS Prescriptive Guidance — cloud design patterns (2023+)"
sensors: []
checklist: true
measurability: "Requires more than one component communicating across a process or network boundary: services calling services, message queues/brokers, or outbound calls to third-party APIs. A single-process system with no remote calls is not assessable — never scored. A monolith that calls external APIs is assessed only on the clauses that apply to outbound calls (timeouts, retries, idempotency); topology clauses stay not assessable."
---

# Canon — Distributed Systems

> One engineering dimension of the Quality Canon (Art. XXV). No executable
> sensor: the mechanism is the INTEGRATION STORY CHECKLIST below — every story
> that crosses a process or network boundary inherits it (wiring into the
> story templates is SDD3-19). Structure validated by `canon-check`.

---

## Doctrine

**A word about authority, first.** This dimension is where the canon's
"versioned public standard" rule meets an honest limit. RFC 9110 anchors the
HTTP-facing clauses (idempotent methods, semantics under retry). The
transactional outbox, saga, and queue patterns have no ISO number: their
institutional homes are the cloud providers' published pattern catalogs —
the Azure Architecture Center Cloud Design Patterns (2024 edition) and AWS
Prescriptive Guidance (2023+) — which document, name and maintain them.
Where a clause below has no external standard at all, its authority is
engineering consensus recorded HERE, in a versioned canon doc, reviewed like
code. That is weaker than an RFC and the doc says so, instead of inventing a
citation.

**The network is not a function call.** Every clause in this dimension is a
consequence of one admission: a remote call can fail, duplicate, reorder or
hang — and will. Code that treats a boundary crossing as reliable is not
optimistic, it is wrong on a timer. The checklist exists because these
failure modes are invisible in the demo and inevitable in production; a
story that crosses a boundary answers every item BEFORE the failure does.

**Outbox over dual-write.** Writing to the database and publishing to a
broker as two separate operations means one of them will eventually succeed
alone, and the system will disagree with itself. The transactional outbox
closes the gap: the event is written in the SAME local transaction as the
state change, and a relay publishes it afterwards. Dual-write is not a
lesser option to be argued about per story — it is the defect the pattern
exists to remove.

**At-least-once is the default reality, so consumers are idempotent.**
Brokers redeliver; relays replay; retries duplicate. Exactly-once delivery
across heterogeneous systems is not a property to rely on. Therefore every
consumer and every mutating endpoint that can be retried carries an
idempotency key and a deduplication rule: same key, same outcome, no double
effect. For HTTP this rides RFC 9110's idempotent-method semantics; for
messaging it is a stored processed-key check.

**Retries are polite or they are an attack.** A retry is a bet that the
failure was transient — placed with exponential backoff AND jitter (a
synchronized retry storm is a self-inflicted outage), and capped by a retry
budget. A call that exhausts its budget fails and surfaces; unbounded
retrying converts one dependency's bad minute into everyone's bad hour.

**Dead letters are operational surface, not a landfill.** Messages that
exhaust processing attempts go to a dead-letter queue whose DEPTH IS
ALARMED — an unwatched DLQ is silent data loss with extra steps. Replay
after a fix is a documented, rehearsed procedure that respects the
consumers' idempotency; it is never an ad-hoc script written during the
incident.

**Sagas over distributed transactions.** Locking multiple services into one
atomic commit couples their availability and hands the slowest participant a
veto. A workflow spanning services is a saga: local transactions in
sequence, each with a defined compensation, and every intermediate state
either completes or compensates — no state that neither finishes nor rolls
back.

**Every remote call is bounded.** A call without a timeout is a resource
leak waiting for a peer to misbehave. Every outbound call declares a
timeout; timeouts compose down the call chain (a callee's budget fits inside
the caller's); and what happens on expiry — retry, degrade, fail — is a
decision written in the story, not an accident discovered under load.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | State change + event publication happen via transactional outbox (or equivalent single-writer mechanism); dual-write to store and broker is a defect | Cloud design pattern catalogs (Azure 2024 / AWS 2023+) — transactional outbox; consensus recorded here | checklist item 1 |
| 2 | Every consumer and every retryable mutating endpoint is idempotent under a declared key; duplicates produce no double effect | RFC 9110 (2022) — idempotent methods; pattern catalogs (Azure 2024 / AWS 2023+) — idempotent consumer | checklist item 2 |
| 3 | Retries use exponential backoff with jitter and a declared retry budget; exhaustion fails visibly | Pattern catalogs (Azure 2024 / AWS 2023+) — retry with backoff; consensus recorded here | checklist item 3 |
| 4 | Undeliverable messages land in a DLQ with alarmed depth and a documented, idempotency-respecting replay procedure | Pattern catalogs (Azure 2024 / AWS 2023+) — dead-letter channel; consensus recorded here | checklist items 4–5 |
| 5 | Cross-service workflows are sagas with defined compensations; no distributed two-phase commit across service boundaries | Pattern catalogs (Azure 2024 / AWS 2023+) — saga/compensating transaction | checklist item 6 |
| 6 | Every remote call declares a timeout; timeouts compose down the chain; on-expiry behavior is decided in the story | RFC 9110 (2022) — semantics under failure; consensus recorded here | checklist item 7 |

---

## Checklist

> THE INTEGRATION STORY CHECKLIST — the mechanism of this dimension. Every
> story whose scope crosses a process or network boundary answers all seven
> items before QA signs; "not applicable" is a valid answer only with the
> reason written down. Template inheritance is wired by SDD3-19.

1. - [ ] Outbox: every state change that must emit an event writes the event in the same local transaction (transactional outbox or equivalent); no dual-write to store + broker — pattern catalogs (Azure 2024 / AWS 2023+)
2. - [ ] Idempotency: every consumer and retryable mutating endpoint declares its idempotency key and dedup rule; a duplicate-delivery test exists — RFC 9110 (2022); pattern catalogs
3. - [ ] Retry: outbound calls retry with exponential backoff AND jitter, under a declared retry budget; budget exhaustion surfaces as a visible failure — pattern catalogs (Azure 2024 / AWS 2023+)
4. - [ ] DLQ: undeliverable messages route to a dead-letter queue; DLQ depth has an alarm with an owner — pattern catalogs (Azure 2024 / AWS 2023+)
5. - [ ] Replay: the DLQ replay procedure is documented, respects consumer idempotency, and has been executed at least once outside an incident — consensus recorded here
6. - [ ] Saga: any workflow spanning services lists its steps and the compensation for each; no step leaves a state that neither completes nor compensates; no cross-service atomic commit — pattern catalogs (Azure 2024 / AWS 2023+)
7. - [ ] Timeouts: every remote call has an explicit timeout; nested budgets fit inside their caller's; the on-expiry behavior (retry/degrade/fail) is stated in the story — RFC 9110 (2022); consensus recorded here

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Dual-write | Writing to two systems (e.g. database + broker) as separate operations — the failure window this dimension bans |
| Transactional outbox | Persisting the outgoing event in the same local transaction as the state change; a relay publishes it afterwards |
| At-least-once | The realistic delivery guarantee of brokers and retries: messages may duplicate, so consumers must dedup |
| Idempotency key | The declared identifier under which a repeated operation produces the same outcome exactly once |
| Backoff with jitter | Exponentially growing retry delays with randomization, preventing synchronized retry storms |
| Retry budget | The declared cap on retry attempts/time; exhaustion is a visible failure, not more retrying |
| DLQ | Dead-letter queue — where messages go after exhausting processing attempts; its depth is alarmed |
| Replay | Reprocessing DLQ messages after a fix, via a documented procedure that leans on consumer idempotency |
| Saga | A cross-service workflow of local transactions, each with a compensation, replacing distributed atomic commit |
| Compensation | The defined action that semantically undoes a completed saga step when a later step fails |
| Timeout composition | Nested calls carry deadlines that fit inside their caller's remaining budget |
| Consensus recorded here | The declared authority for clauses with no external standard: this versioned, reviewed canon doc (see Doctrine) |
| Not assessable | The honest verdict when nothing crosses a process/network boundary (Art. XXV.3) — never a score |
