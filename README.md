# sdd-canon

Quality Canon registry for the SDD framework — versioned engineering doctrine,
rulepacks, checklists and normative mappings, distributed as hash-verified
semver releases.

An SDD kit vendors this content (`.sdd/canon/`) and pins it in `canon.lock`
(version + hash). The registry exists so the canon can stay alive — OWASP,
WCAG, Well-Architected and SAST rules evolve — without ever becoming remote
configuration.

## Security model

Four rules, inherited from the SDD Constitution (Art. XXV) and non-negotiable:

1. **Normative content is pinned.** What decides or blocks in a project is
   consumed from a specific release, verified by `MANIFEST.sha256`, and
   vendored offline-first — the link exists to *update*, never to *operate*.
2. **Updates are a human act.** `sdd canon update` downloads a release,
   verifies the hash, shows the diff and stops. An agent never updates the
   canon on its own; staleness is a warning, not an excuse.
3. **No remote configuration in enforcement.** Nothing in a kit's sensors,
   hooks or CI ever fetches this repository at run time.
4. **License red line.** Every rulepack distributed here comes from permissive
   sources with attribution preserved. Commons Clause (and any
   non-commercial/restrictive clause) is FORBIDDEN — no exceptions.

## Layout

```
canon/          one doctrine doc per engineering dimension (17 dimensions):
                what good looks like, which versioned public standards say so,
                and which executable sensor or checklist verifies it
rulepacks/      curated sensor rulepacks (populated by the quality-canon
                exporter; empty at seed — see rulepacks/README.md)
tools/          release tooling (deterministic manifest + zip)
VERSION         current registry version (semver)
MANIFEST.sha256 sha256 of every content file (regenerated per release)
```

## Releases

Each release is a git tag `vX.Y.Z` plus a GitHub Release carrying exactly two
assets:

- `sdd-canon-X.Y.Z.zip` — the full content, deterministically built
  (byte-identical on rebuild)
- `MANIFEST.sha256` — the hash manifest, also present inside the zip

Consumers verify before use:

```bash
unzip -q sdd-canon-X.Y.Z.zip -d sdd-canon && cd sdd-canon
sha256sum -c MANIFEST.sha256 --quiet && echo OK
```

### Version semantics

- **MAJOR** — removal or incompatible restructuring of canon content.
- **MINOR** — a new dimension or rulepack, or a standard bump that changes
  verdicts (e.g. a new WCAG or CWE Top 25 edition).
- **PATCH** — editorial fixes that change no verdict.

### Cutting a release (maintainers)

1. Update content; bump `VERSION`; add a `CHANGELOG.md` entry.
2. `bash tools/release.sh` — regenerates `MANIFEST.sha256` and builds
   `dist/sdd-canon-<version>.zip` deterministically.
3. Commit, tag `v<version>`, push, then publish the GitHub Release with the
   two assets. The process is deliberately manual (rule 2 above).

## Provenance

Doctrine authored in the SDD 3.0 cycle (phase 3, Quality Canon). Content
references public, versioned standards only — ISO/IEC, W3C/WCAG, OWASP, NIST,
CIS, CNCF, FinOps Foundation, provider Well-Architected frameworks — never
individuals. Licensed under Apache-2.0 (ported rulepack rules keep their
original permissive licenses and attributions).
