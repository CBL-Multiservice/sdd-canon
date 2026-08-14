---
sdd: canon
dimension: code-health
standards:
  - "ISO/IEC 5055:2021 (automated source code quality measures)"
  - "ISO/IEC 25010:2011 (product quality — maintainability)"
sensors:
  - code-health
measurability: "Requires source code AND full version-control history (churn is computed from commits). A shallow clone or an imported snapshot has no churn signal: hotspots are \"not assessable\" there — never scored, well or badly, from half the data."
---

# Canon — Code Health

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the health signal comes from the sensor below.

---

## Doctrine

Not all complexity is equal. A convoluted function nobody has touched in two
years is a fossil; the same function changed every week is a fire. Code health
is the discipline of telling the two apart before spending effort.

The instrument is the **hotspot**: churn (how often a file changes, from
version-control history) multiplied by complexity (how hard it is to change,
from static measures of the kind ISO/IEC 5055:2021 automates). High churn plus
high complexity marks the small fraction of the codebase where most defects
and most maintenance cost concentrate. That is where refactoring pays; almost
nowhere else does.

Two corollaries the canon enforces:

1. **Churn needs history.** Hotspot analysis over a shallow clone is a lie
   with a straight face — every churn value reads zero and every fossil looks
   healthy. No history, no verdict: the dimension is reported "not assessable"
   (Art. XXV.3), never scored from half the data.
2. **Dead code is not neutral.** Unreferenced exports, unreachable branches
   and commented-out blocks cost reading time on every visit and hide real
   behavior. ISO/IEC 25010:2011 files this under analysability: the code
   that is not there does not have to be understood. Delete it — version
   control remembers.

A hotspot is a *review trigger*, not a refactor mandate. The sensor points;
a human decides. Automated rewrites of the hottest code in the system is how
incidents are manufactured.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Hotspots are computed as churn times complexity over a stated time window; the window is part of the sensor configuration, not folklore | ISO/IEC 5055:2021 — automated maintainability measures | `code-health` |
| 2 | The top hotspot list is produced by the sensor and reviewed each delivery cycle; review outcome (act / accept) is recorded | ISO/IEC 25010:2011 — maintainability: modifiability | `code-health` output + review record |
| 3 | Dead code (unreferenced exports, unreachable branches, commented-out blocks) is deleted, never accumulated | ISO/IEC 25010:2011 — maintainability: analysability | `code-health` |
| 4 | No health verdict without full history: shallow clones and snapshot imports make the dimension "not assessable" | Art. XXV.3 — honest measurability | `code-health` (must detect and refuse shallow history) |
| 5 | A hotspot finding triggers human review; it never authorizes an automated rewrite | Art. XXV.5 — the decision is human | review rule |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Churn | Number of commits touching a file within the stated window |
| Complexity | Static difficulty measure of a file or function (cyclomatic or equivalent automated measure) |
| Hotspot | A file ranking high on churn times complexity — where maintenance cost concentrates |
| Dead code | Code no execution path or importer reaches: unreferenced exports, unreachable branches, commented-out blocks |
| Fossil | High-complexity, near-zero-churn code — left alone unless it blocks a change |
