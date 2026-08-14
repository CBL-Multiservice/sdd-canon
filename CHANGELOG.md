# Changelog — sdd-canon

Format based on Keep a Changelog; semantic versioning (see README for the
MAJOR/MINOR/PATCH semantics specific to canon content).

## [0.1.0] — 2026-08-13

Seed release.

### Added

- `canon/` — 17 engineering-dimension doctrine docs + index, seeded from the
  SDD kit's phase-3 Quality Canon (code architecture/health, fitness
  functions, test seams, SAST, SCA, secrets, database, UI/UX, infrastructure,
  cloud, API, distributed systems, AI-LLM, privacy, docs/ADR, ISO/IEC 27001
  mapping). Every dimension declares versioned public standards, its twin
  sensors or checklist, and honest measurability.
- `rulepacks/` — structure with an honestly-empty placeholder (populated by
  the quality-canon exporter in a later release).
- `tools/release.sh` — deterministic release build: regenerated
  `MANIFEST.sha256` + byte-reproducible `sdd-canon-<version>.zip`.
- Release process and security model documented in `README.md` (pinned
  normative content, human-only updates, no remote config in enforcement,
  permissive-license red line).
