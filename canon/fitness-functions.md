---
sdd: canon
dimension: fitness-functions
standards:
  - "ISO/IEC 25010:2011 (product quality — maintainability, testability)"
  - "ISO/IEC 5055:2021 (automated source code quality measures — duplication, complexity weaknesses)"
  - "endoflife.date dataset (pinned snapshot, versioned in the repository)"
sensors:
  - complexity-ceiling
  - file-size-ceiling
  - no-duplication
  - no-eol-runtime
measurability: "Requires source code; the EOL check additionally requires declared runtime versions (manifest, lockfile or runtime config) plus a pinned endoflife.date snapshot. Absent either input, that specific function is \"not assessable\" — the others still run."
---

# Canon — Fitness Functions

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; each function below is its own sensor.

---

## Doctrine

An evolutionary architecture fitness function is a unit test for a system
property: an executable assertion that some structural quality still holds,
run on every change. Qualities that are only reviewed decay between reviews;
qualities that are asserted cannot decay silently. The kit ships five:

1. **no-cycles** — the import graph stays acyclic. This function belongs to
   the code-architecture dimension and its sensor is registered there (see
   `canon/code-architecture.md`); it is listed here because the five travel
   as a set, but it is NOT double-registered.
2. **complexity-ceiling** — no function exceeds the project's cyclomatic
   complexity ceiling. Complexity is a proxy for untestability: every path is
   a case someone must think of (ISO/IEC 25010:2011, testability).
3. **file-size-ceiling** — no source file exceeds the project's line ceiling.
   Oversized files are where modules go to dissolve; the ceiling forces the
   split conversation to happen while it is still cheap.
4. **no-duplication** — duplicated blocks above the threshold fail the gate.
   ISO/IEC 5055:2021 counts duplication among the automated maintainability
   weaknesses: every clone is a bug you will fix once and ship once.
5. **no-eol-runtime** — no declared runtime or platform version past its
   end-of-life date. The reference is the endoflife.date dataset as a
   **pinned snapshot versioned in the repository** — never a live lookup.
   Enforcement consuming remote data is forbidden (Art. XXV.4); the snapshot
   is updated only by explicit human act after a reviewed diff.

Ceilings and thresholds are project decisions — a compiler and a CRUD app do
not share a complexity budget. What is NOT a project decision is existence:
each function runs with SOME explicit value, and raising a ceiling is a
recorded decision (decision-log), not an edit made under deadline.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | The import graph is acyclic — registered under code-architecture; cross-reference only, no second registration | ISO/IEC 25010:2011 — modularity | `no-cycles` (dimension: code-architecture) |
| 2 | Cyclomatic complexity per function stays at or under the declared ceiling | ISO/IEC 25010:2011 — testability; ISO/IEC 5055:2021 complexity weaknesses | `complexity-ceiling` |
| 3 | Source file length stays at or under the declared ceiling | ISO/IEC 25010:2011 — analysability | `file-size-ceiling` |
| 4 | Duplicated code above the declared token/percentage threshold is a blocker | ISO/IEC 5055:2021 — duplication weaknesses | `no-duplication` |
| 5 | Every declared runtime/platform version is inside its support window per the pinned endoflife.date snapshot; the snapshot lives in the repository | endoflife.date dataset (pinned snapshot); Art. XXV.4 | `no-eol-runtime` |
| 6 | Every ceiling/threshold has an explicit value in the sensor configuration; changing one requires a decision-log entry | Art. XXIV — definition is data | sensor configs + review rule |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Fitness function | An executable assertion over a structural system property, run on every change (evolutionary architecture technique) |
| Ceiling | The maximum value a metric may reach before the gate fails |
| Cyclomatic complexity | Count of independent paths through a function |
| Clone | A duplicated code block at or above the duplication threshold |
| EOL (end-of-life) | Past the vendor's support window — no fixes, no security patches |
| Pinned snapshot | A dataset copy versioned in the repository; updated only by explicit human act (Art. XXV.4) |
