---
sdd: canon
dimension: sast
standards:
  - "CWE Top 25 Most Dangerous Software Weaknesses (2024)"
  - "OWASP Top 10:2021"
sensors:
  - sast
measurability: "Requires source code in a language the rulepack covers. A language with no rules in the pinned rulepack is \"not assessable\" for SAST — it is never given a clean bill of health it did not earn."
---

# Canon — SAST (Static Application Security Testing)

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; findings come from the sensor below, running a
> pinned, permissively-licensed rulepack — and nothing else.

---

## Doctrine

Static analysis finds the vulnerability while it is still a diff, when the
fix costs one review comment instead of one incident. The scanner reads code
against a rulepack — patterns for the weakness classes that actually get
exploited: injection, broken access control, hardcoded credentials, unsafe
deserialization. The CWE Top 25 (2024) and OWASP Top 10:2021 are the
coverage yardstick: a rulepack that cannot express the majority of those
classes for a target language is not coverage, it is a mascot.

A SAST gate is only as honest as its scope statement. Findings are cited
file:line with the rule id; a language the rulepack does not cover is
reported "not assessable" — silence is never claimed as safety.

### The license red line (non-negotiable)

- **The rulepack is built ONLY from permissively-licensed sources** (MIT,
  Apache-2.0, BSD and equivalents), with per-rule attribution preserved.
- **Rule configs under the Commons Clause are FORBIDDEN in any form** — no
  copying, no porting, no "inspiration", no vendoring. The upstream
  semgrep-rules / opengrep-rules registries are the canonical examples of
  Commons Clause-encumbered configs: they do not enter this kit, ever.
  A rulepack with an unlicensed rule is a lawsuit with a YAML extension.
- **The scan engine is fine; its registry is not.** An LGPL-licensed scanner
  CLI invoked as an external tool is acceptable — the license taint concern
  is the RULES, not the engine binary.
- **Never a remote `--config` in enforcement** (Art. XXV.4). A remote config
  is remote code deciding what blocks your merge, mutable outside your review.
  The rulepack is local, pinned and versioned — always.
- **The pinned rulepack ships via the `sdd-canon` registry in phase 4**,
  version + hash in `canon.lock`, vendored offline-first. Until then the
  sensor command stays `[DEFINE]`: an honest placeholder beats a scanner
  pointed at rules we may not use.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Every covered language is scanned on every change; findings block at the declared severity floor | CWE Top 25 (2024); OWASP Top 10:2021 | `sast` |
| 2 | Rulepack coverage is mapped to CWE Top 25 (2024) and OWASP Top 10:2021 classes; unmapped classes are declared gaps, not silent ones | CWE Top 25 (2024); OWASP Top 10:2021 | rulepack manifest reviewed at each rulepack update |
| 3 | The rulepack contains only permissively-licensed rules with attribution; Commons Clause sources (e.g. the upstream semgrep-rules / opengrep-rules registries) are PROHIBITED in any form | Art. XXV.4; per-rule license manifest | rulepack license manifest, human-reviewed at every update |
| 4 | The sensor never consumes a remote config; the rulepack is a local, pinned path (phase 4: `sdd-canon` registry, hash in `canon.lock`) | Art. XXV.4 — no remote configuration in enforcement | `sast` command inspection (local path only) |
| 5 | Suppressions are inline, per-finding, with a stated reason; blanket rule disabling requires a decision-log entry | OWASP Top 10:2021 — verified, not assumed, mitigations | `sast` + review rule |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| SAST | Static Application Security Testing — scanning source code for vulnerability patterns without executing it |
| Rulepack | The pinned, versioned set of detection rules the scanner runs — the kit's own, permissively-licensed build |
| Commons Clause | A license rider restricting commercial use; rule configs under it are forbidden in this kit in any form |
| CWE | Common Weakness Enumeration — the institutional catalog of software weakness classes |
| Severity floor | The minimum finding severity that blocks the gate |
| Remote config | Rule content fetched at scan time from outside the repository — forbidden in enforcement (Art. XXV.4) |
