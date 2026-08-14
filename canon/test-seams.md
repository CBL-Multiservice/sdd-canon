---
sdd: canon
dimension: test-seams
standards:
  - "ISO/IEC/IEEE 29119-1:2022 (software testing — concepts and definitions)"
  - "ISO/IEC/IEEE 29119-4:2021 (software testing — test techniques)"
sensors:
  - test-seams
measurability: "Requires an executable test suite. A project with no tests has no seams to observe through: report \"not assessable\" — an untested codebase is not scored on seam quality, it is flagged for having no tests at all (a different finding)."
---

# Canon — Test Seams

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; seam quality is observed through the sensor
> below — by its consequences, because that is the only honest way.

---

## Doctrine

A **seam** is a place where behavior can be substituted without editing the
code under test. No seams, no isolation; no isolation, and every "unit" test
is secretly an integration test with worse error messages. Testability is not
a property of the test suite — it is a property of the design, and seams are
its unit of account.

The techniques are old and boring, which is why they work:

- **Injection points** — dependencies arrive through constructors or
  parameters, never conjured inside the function that uses them. What is
  constructed inline cannot be substituted.
- **Ports** — the domain talks to the outside world (clock, network, storage,
  randomness) through narrow interfaces it owns. The adapter is replaceable;
  the domain never imports the vendor SDK directly.
- **Humble objects** — logic is extracted out of hard-to-instantiate hosts
  (UI frames, framework callbacks, main functions) into plain testable
  objects, leaving the host too thin to hide a bug.

**Test pyramid honesty.** ISO/IEC/IEEE 29119-1:2022 distinguishes test levels
by scope; the pyramid is only a claim about their proportions. A suite that
calls everything "unit" while each test boots a database is not a pyramid, it
is an hourglass wearing a name tag. Classify tests by what they actually
touch, and let the shape say what it says.

**Measuring seams honestly.** No generic CLI inspects "seam quality"
directly — any tool claiming to would be scoring style. What CAN be measured
is the consequence: a suite that exercises code through real seams detects
behavioral substitution. Mutation testing does exactly that — mutate the
code, run the suite, count survivors. Surviving mutants accuse the seams as
much as the tests: code that cannot be observed closely enough to kill a
mutant is code without a working seam around it. The `test-seams` sensor is
therefore defined as a mutation-score gate over the project's stack, not as a
style inspection.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | External effects (clock, network, storage, randomness) are reached only through ports owned by the domain; no vendor SDK import inside domain logic | ISO/IEC/IEEE 29119-1:2022 — test item isolation | `test-seams` (survivors cluster where ports are missing) + code review |
| 2 | Dependencies are injected (constructor/parameter); inline construction of a collaborator inside business logic is a defect | ISO/IEC/IEEE 29119-4:2021 — techniques presuppose controllable inputs | `test-seams` + code review |
| 3 | Tests are classified by what they touch (unit / integration / end-to-end), and the declared level matches the actual footprint | ISO/IEC/IEEE 29119-1:2022 — test levels | suite layout reviewed against sensor run scope |
| 4 | The mutation score stays at or above the declared floor on the code under active change | ISO/IEC/IEEE 29119-4:2021 — technique effectiveness is measured, not assumed | `test-seams` |
| 5 | A surviving mutant in changed code is triaged before merge: kill it, or record why it is equivalent | Art. XXV.1 — doctrine with a mechanism | `test-seams` output + review record |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Seam | A place where behavior can be substituted without editing the code under test |
| Port | A narrow, domain-owned interface to an external effect; its adapter is replaceable |
| Humble object | A host kept too thin to hide a bug, its logic extracted into a plain testable object |
| Test pyramid | The claimed proportion of unit / integration / end-to-end tests; honest only if levels are classified by actual footprint |
| Mutation score | Percentage of injected code mutations the test suite detects (kills) |
| Surviving mutant | A mutation no test noticed — evidence of a missing seam or a vacuous test |
