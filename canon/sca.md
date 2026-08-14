---
sdd: canon
dimension: sca
standards:
  - "OSV schema v1 (OpenSSF vulnerability interchange format)"
  - "SPDX 2.3 (ISO/IEC 5962:2021 — software bill of materials)"
  - "NIST SP 800-218 (SSDF v1.1 — Secure Software Development Framework)"
sensors:
  - sca
measurability: "Requires a dependency manifest with a lockfile (pinned resolution). A project with no lockfile has an unverifiable dependency set: SCA over floating versions is \"not assessable\" — the finding is the missing lockfile itself."
---

# Canon — SCA (Software Composition Analysis)

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the dependency verdict comes from the sensor
> below.

---

## Doctrine

Most of a modern codebase is code nobody on the team wrote. SCA is how that
majority gets the same scrutiny as the minority: enumerate every dependency
(direct and transitive), match the set against known-vulnerability data, and
block on what matches. NIST SP 800-218 (SSDF v1.1, practice group "Produce
Well-Secured Software") makes verifying acquired components a baseline
practice, not an audit-season event.

Three commitments make it real:

1. **The lockfile is the truth.** Scanning a manifest with floating ranges
   scans a hypothesis. The sensor reads the lockfile — the exact resolved
   set that ships. No lockfile, no verdict: the missing lockfile IS the
   finding.
2. **Findings speak OSV.** The OSV schema (v1) gives every vulnerability a
   machine-readable identity, affected-range and severity — which makes
   deduplication, triage and suppression auditable instead of anecdotal.
3. **The inventory is exportable.** An SBOM in SPDX 2.3 (ISO/IEC 5962:2021)
   is the dependency inventory a third party can verify without trusting the
   build. If the inventory cannot be produced, it is not known — it is
   assumed.

Vulnerable does not always mean exploitable, and the canon does not pretend
otherwise: a finding may be accepted with a recorded reason and an expiry
date. What it may not be is ignored. An unreviewed known-vulnerable
dependency is a decision someone made by not making it.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Every lockfile in the repository is scanned on every change; findings at or above the declared severity floor block | NIST SP 800-218 SSDF v1.1 — PW.4 (reuse verified components) | `sca` |
| 2 | The scan covers transitive dependencies, not only direct ones — the resolved set, as locked | OSV schema v1 — affected-version matching over the full graph | `sca` |
| 3 | Dependency resolution is pinned by a lockfile committed to the repository | NIST SP 800-218 SSDF v1.1 — PO.3 (toolchain integrity) | `sca` (refuses manifests without a lockfile) |
| 4 | Accepted vulnerabilities carry a recorded reason and an expiry date; expired acceptances block again | NIST SP 800-218 SSDF v1.1 — RV.2 (assess and prioritize) | `sca` suppression file + review at expiry |
| 5 | An SBOM (SPDX 2.3) is producible from the repository state on demand | SPDX 2.3 / ISO/IEC 5962:2021 | `sca` (or its companion export command) |
| 6 | Vulnerability data used for blocking is a pinned local snapshot, refreshed by explicit act — never a live feed inside the gate | Art. XXV.4 — no remote configuration in enforcement | `sca` command inspection (offline database mode) |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| SCA | Software Composition Analysis — inventorying and vulnerability-matching third-party dependencies |
| Lockfile | The committed file pinning the exact resolved dependency set (direct + transitive) |
| Transitive dependency | A dependency of a dependency — shipped whether or not anyone chose it |
| OSV | Open Source Vulnerability schema — machine-readable vulnerability identity and affected ranges |
| SBOM | Software Bill of Materials — the exportable dependency inventory (here: SPDX 2.3) |
| Acceptance | A recorded, expiring decision to ship with a known finding — never silent |
