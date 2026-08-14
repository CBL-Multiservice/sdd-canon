---
sdd: canon
dimension: secrets
standards:
  - "CWE-798 (use of hard-coded credentials)"
  - "NIST SP 800-53 Rev. 5 (security controls — IA-5 authenticator management, SC-12/SC-13 key management)"
sensors:
  - secrets
measurability: "Requires a version-controlled repository (working tree AND history are the scan surface). Detection patterns cover structured credentials; entropy heuristics are a net, not a proof — a clean scan lowers risk, it does not certify absence."
---

# Canon — Secrets Hygiene

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; detection runs through the sensor below.

---

## Doctrine

A secret in version control is not stored — it is published, with a
timestamp, to everyone who will ever clone the repository. CWE-798 classifies
hard-coded credentials as a weakness precisely because the credential outlives
every intention around it: forks, backups, CI caches and clones all remember.

Three laws, in the order they save you:

1. **Secrets never enter the repository.** Code references secrets by name;
   values arrive at runtime from the environment or a managed secret store.
   NIST SP 800-53 Rev. 5 (IA-5) treats authenticator management as a
   lifecycle — issue, protect, rotate, revoke — and a git blob does none of
   those.
2. **A leaked secret is rotated, never deleted.** History rewriting is
   incident theater: every existing clone still has the value. The only fix
   is making the value worthless — revoke and rotate first, clean the
   history second, and treat the leak as an incident with a record, not an
   oops with a force-push.
3. **Detection runs where it is cheapest.** At pre-commit, a finding costs a
   local fix and zero rotations. Post-push, the cheap option is gone —
   rotation is mandatory. The gate therefore runs at pre-commit AND over
   full history in CI: the first protects the future, the second audits the
   past.

The sensor is honest about its limits: pattern rules catch structured
credentials (API keys, tokens, private key blocks); entropy heuristics catch
some of the rest. A green scan is a lowered risk, not a certificate of
absence — which is exactly why law 1 exists.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | No credential material in the working tree: code reads secrets by name from the environment or a secret store | CWE-798; NIST SP 800-53r5 IA-5 | `secrets` |
| 2 | The scan covers full VCS history, not only the current tree — the past is part of the attack surface | CWE-798 (exposure persists in history) | `secrets` (history mode) |
| 3 | Detection runs at pre-commit locally and as a blocking gate in CI | NIST SP 800-53r5 SA-11 (developer testing) | `secrets` (both phases) |
| 4 | A confirmed leak triggers rotation of the credential BEFORE any history cleanup; the incident and the rotation are recorded | NIST SP 800-53r5 IA-5 (authenticator lifecycle), IR controls family | incident record + review rule |
| 5 | Cryptographic keys and tokens have named owners and rotation periods; long-lived static credentials require a recorded decision | NIST SP 800-53r5 SC-12 (key establishment and management) | secret inventory reviewed at each rotation period |
| 6 | False-positive suppressions are per-finding with a stated reason; path-level blanket ignores require a decision-log entry | Art. XXV.1 — the mechanism stays meaningful | `secrets` baseline file + review rule |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Secret | Any value granting access or identity: passwords, API keys, tokens, private keys, connection strings |
| Rotation | Replacing a credential and revoking the old value — the only real remedy for a leak |
| History scan | Scanning every commit ever made, not just the current tree |
| Entropy heuristic | Flagging high-randomness strings as candidate secrets — a net, not a proof |
| Baseline file | The sensor's committed list of reviewed, suppressed findings with reasons |
| Secret store | A managed runtime source of secret values (vault service, platform secret manager, environment injection) |
