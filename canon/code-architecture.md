---
sdd: canon
dimension: code-architecture
standards:
  - "ISO/IEC 25010:2011 (product quality — maintainability: modularity, modifiability)"
  - "ISO/IEC/IEEE 42010:2022 (architecture description — viewpoints and correspondence rules)"
sensors:
  - arch-layers
  - no-cycles
measurability: "Requires source code plus a declared layer map (which modules exist and which direction dependencies may point). A repository with no declared architecture has nothing to conform to: report \"not assessable\", never scored."
---

# Canon — Code Architecture

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; conformance verified by the sensors below.

---

## Doctrine

A diagram is a claim. The import graph is the fact. Architecture exists only
where the two agree, and the only way to keep them agreeing is to make the
claim executable.

ISO/IEC/IEEE 42010:2022 treats an architecture description as a set of views
governed by correspondence rules — rules that say how the description maps to
the system. This canon takes the standard at its word: the layer map is a
versioned artifact, and a sensor checks the code against it on every run. An
architecture that lives only in slides is not an architecture; it is a memory
of one.

Three properties carry the whole dimension:

1. **Named layers.** Every module belongs to exactly one declared layer. A
   module nobody can place is a module nobody owns.
2. **One dependency direction.** Dependencies point the way the layer map
   says, and only that way. The moment a lower layer imports a higher one, the
   layers are decoration — every change can now reach every module.
3. **No cycles.** A dependency cycle collapses its members into a single
   de facto module: none can be built, tested, replaced or understood alone.
   ISO/IEC 25010:2011 calls the underlying qualities modularity and
   modifiability; a cycle is the measurable absence of both.

Exceptions happen — a migration in flight, a boundary being redrawn. They
enter as explicit, dated allowlist entries in the sensor configuration, never
as silence. An undocumented exception is drift with a head start.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | The layer map (modules, layers, allowed directions) is a versioned artifact in the repository, expressed in the layer sensor's configuration | ISO/IEC/IEEE 42010:2022 — architecture description, correspondence rules | `arch-layers` (its config file IS the map) |
| 2 | Every source module maps to exactly one declared layer; unmapped modules fail the gate | ISO/IEC/IEEE 42010:2022 — correspondence between description and system | `arch-layers` |
| 3 | Dependencies cross layers only in the declared direction; a reversed import is a blocker, not a warning | ISO/IEC 25010:2011 — maintainability: modularity | `arch-layers` |
| 4 | The module-level import graph is acyclic | ISO/IEC 25010:2011 — maintainability: modifiability | `no-cycles` |
| 5 | Exceptions are explicit allowlist entries with a stated reason and an expiry; silent suppressions are forbidden | ISO/IEC/IEEE 42010:2022 — rationale recorded in the description | `arch-layers` (allowlist reviewed at each expiry) |

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Layer map | The versioned declaration of modules, layers and allowed dependency directions — the executable form of the architecture description |
| Dependency direction | The single allowed sense in which imports may cross a layer boundary |
| Cycle | A closed path in the import graph; its members can only change together |
| Allowlist entry | An explicit, dated, expiring exception in the sensor configuration |
| Blocker | A finding that fails the gate (exit != 0); QA does not approve over it |
