---
sdd: canon
dimension: ui-ux
standards:
  - "WCAG 2.2 (W3C Recommendation, 2023)"
  - "ISO 9241-110:2020 (ergonomics of human-system interaction — interaction principles)"
  - "Core Web Vitals — LCP, INP, CLS (web-vitals metric set; INP replaced FID in 2024)"
  - "W3C Design Tokens Community Group — Design Tokens Format Module (2024 draft)"
sensors:
  - a11y
  - web-vitals
  - bundle-budget
  - design-slop
checklist: true
measurability: "Requires a rendered-UI substrate: markup and styles in the repository for the static sensors (design-slop, bundle-budget) and a servable build or running instance for the runtime sensors (a11y page scans, web-vitals). A project with no UI substrate is reported as not assessable — never scored."
---

# Canon — UI/UX

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; accessibility, speed and identity verdicts come
> from the sensors below, and the interaction-quality review from the
> standard-derived checklist.

---

## Doctrine

The interface is the only part of the system a user ever experiences; every
architectural virtue behind it is invisible until the UI transmits it. This
dimension holds the interface to the same discipline the rest of the canon
holds code to: a floor no screen may sink below (accessibility), a vocabulary
for interaction quality (dialogue principles), budgets that block when
exceeded (speed and weight), one source of truth for visual decisions
(tokens), and a mechanical guard against the statistical sameness of
generated UI.

**Accessibility is a floor, not a feature.** WCAG 2.2 Level AA is the
minimum admission bar for any shipped screen — not a backlog item, not a
"phase 2". The floor is concrete:

- **Contrast.** Text at 4.5:1 against its background, 3:1 for large text
  (SC 1.4.3); interactive components and meaningful graphics at 3:1
  (SC 1.4.11). Gray text on a colored surface — the washed-out template
  look — fails this clause mechanically, which is why the contrast rule
  needs no aesthetic argument.
- **Focus.** Every interactive element has a visible focus indicator
  (SC 2.4.7), and that indicator is not hidden behind sticky headers,
  overlays or cookie banners (SC 2.4.11, new in 2.2). A keyboard user who
  cannot see where they are is locked out as surely as by a missing button.
- **Target size.** Pointer targets measure at least 24 by 24 CSS pixels
  (SC 2.5.8 — promoted to Level AA in WCAG 2.2). The kit's DESIGN.md
  (section 8) sets a stricter house floor of 44 by 44, matching the AAA
  clause SC 2.5.5 — that stricter number is a kit decision layered on top
  of the standard's floor, and the doc says so honestly.
- **Motion.** Content that moves, blinks or auto-updates for more than five
  seconds can be paused, stopped or hidden (SC 2.2.2). Interaction-triggered
  animation is disabled when the user asks for it via
  `prefers-reduced-motion` — SC 2.3.3 is Level AAA in the standard; this
  kit adopts it as mandatory anyway, because making animation conditional
  is cheap and vestibular disorders are not.

Level AA is the floor, never the ceiling: where an AAA clause costs little
(reduced motion, larger targets), the kit takes it and records that the
extra rigor is house doctrine, not an AA obligation.

**Interaction quality has a vocabulary, and it is not mechanizable.**
ISO 9241-110:2020 names seven interaction principles: suitability for the
user's tasks, self-descriptiveness, conformity with user expectations,
learnability, controllability, use error robustness, and user engagement.
No static analyzer can score "conformity with user expectations" — so this
part of the dimension is honestly a checklist, reviewed by a human against
the standard, not a sensor pretending to measure UX. The kit's UX-writing
rules (DESIGN.md section 13) are these principles made concrete: an error
message that states what happened, why, and how to recover IS use error
robustness; an empty state that explains what will appear and offers the
first action IS self-descriptiveness; a destructive confirmation that names
the consequence IS controllability.

**Speed is a budget, not an aspiration.** Core Web Vitals are this
dimension's fitness functions — executable assertions over user-experienced
speed, run on every change, in the exact sense of the fitness-functions
dimension. The budgets are explicit:

| Metric | Measures | Budget (p75 or lab-equivalent) |
|--------|----------|-------------------------------|
| LCP (Largest Contentful Paint) | loading — when the main content is visible | at or under 2.5 s |
| INP (Interaction to Next Paint) | responsiveness — worst interaction latency | at or under 200 ms |
| CLS (Cumulative Layout Shift) | visual stability — unexpected movement | at or under 0.1 |

Under Art. XII, exceeding a budget is a bug, not a future improvement: the
`web-vitals` sensor blocks like any failing test. Projects with field data
gate on the 75th percentile of real users; projects without it gate on a
reproducible lab run with the same thresholds and say which one they are
using. Serving the LCP budget upstream, every JavaScript entry point carries
a declared byte ceiling (recorded with the project's performance budget —
Art. XII.1) and the `bundle-budget` sensor fails the gate when a ceiling is
crossed. A bundle that grows 5 KB per story ships a slow product by
Christmas without any single commit being guilty.

**Design tokens are the single source of visual truth.** Color, spacing,
typography, radii, shadows and motion values live in one versioned token
file in the W3C Design Tokens Community Group format — the interoperable,
tool-neutral interchange the DTCG Format Module (2024 draft) defines — and
flow from there into every platform artifact. The kit's three-layer model
(DESIGN.md section 4: primitives, semantic, component) is the structure
inside that file. A raw hex value or magic pixel number in a component is
schema drift by another name: it forks the source of truth and makes the
next redesign an archaeology project. Tokens are also what make theming
honest — dark mode recalibrates token values; it never inverts hardcoded
ones.

**Generated sameness is a detectable dialect — and this doc is honest about
who forbids it.** The `design-slop` sensor mechanically blocks the
statistical average of LLM-generated UI: SLOP-01 (purple-to-blue
gradients), SLOP-03 (bounce/elastic easing and overshoot beziers), SLOP-05
(`transition: all`), SLOP-06 (nested cards), SLOP-07 (full-bleed gradient
hero), and warns on SLOP-02 (generic primary font) and SLOP-04 (untinted
pure black/white/gray). The grounding of those rules is split, and the
split is stated plainly:

- **Standards-grounded neighbors.** The contrast doctrine behind "no gray
  text on colored backgrounds" is WCAG SC 1.4.3/1.4.11 — verified by the
  `a11y` sensor, not by design-slop. The motion-restraint doctrine is
  WCAG SC 2.2.2/2.3.3 — verified by the checklist and the a11y scan where
  tooling covers it. The token discipline is the DTCG format — verified by
  review, with design-slop catching the raw-pure-tone and generic-font
  subset (SLOP-04, SLOP-02).
- **Kit identity doctrine.** No public standard forbids a purple gradient,
  a nested card, Inter as a body font, or `transition: all`. Those rules
  block on the authority of the kit's own identity doctrine — DESIGN.md
  section 3 under Art. II (exclusive visual identity) — because shipping
  the template everyone else ships is a product defect even when no ISO
  clause says so. Where a craft rationale exists it is real but secondary:
  `transition: all` animates properties the author never intended,
  including layout-affecting ones that surface as INP/CLS regressions —
  yet the blocking authority remains the kit's, and this doc does not
  dress a house rule in a standard's clothes.

**Honest measurability.** This dimension exists only where a UI exists. A
CLI, a library, a headless service — no rendered surface, no assessment:
the dimension is reported as "not assessable", never scored well for having
no UI to get wrong, never scored badly for the same reason (Art. XXV.3).

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | Text contrast at or above 4.5:1 (3:1 for large text); interactive components and meaningful graphics at or above 3:1 | WCAG 2.2 — SC 1.4.3, SC 1.4.11 (AA) | `a11y` |
| 2 | Every interactive element shows a visible focus indicator, and no author content obscures the focused element | WCAG 2.2 — SC 2.4.7, SC 2.4.11 (AA) | `a11y` + checklist (keyboard traversal) |
| 3 | Pointer targets at or above 24x24 CSS px (standard floor); house floor 44x44 per DESIGN.md section 8 | WCAG 2.2 — SC 2.5.8 (AA); SC 2.5.5 (AAA, adopted as kit doctrine) | `a11y` + checklist |
| 4 | Moving/auto-updating content over 5 s is pausable; non-essential animation is disabled under prefers-reduced-motion | WCAG 2.2 — SC 2.2.2 (A); SC 2.3.3 (AAA, adopted as kit doctrine) | checklist (+ `a11y` where tooling covers it) |
| 5 | Every user-facing flow is reviewed against the seven interaction principles; UX writing follows DESIGN.md section 13 | ISO 9241-110:2020 — interaction principles | checklist |
| 6 | Core Web Vitals stay within budget — LCP 2.5 s, INP 200 ms, CLS 0.1 (p75 or declared lab-equivalent); a violation blocks as a bug | Core Web Vitals thresholds (2024); Art. XII.2 | `web-vitals` |
| 7 | Every JS entry point stays at or under its declared byte ceiling (performance budget, Art. XII.1); a regression blocks | Art. XII; Core Web Vitals (the budget serves LCP/INP) | `bundle-budget` |
| 8 | Visual decisions live in one DTCG-format token file (three layers per DESIGN.md section 4); components consume tokens, never raw values | W3C DTCG Format Module (2024 draft) | review + `design-slop` (SLOP-02/04 subset) |
| 9 | No blocking design-slop anti-pattern (SLOP-01/03/05/06/07) in UI code; SLOP-02/04 warnings resolved or justified with `design:ignore` | Kit identity doctrine — DESIGN.md section 3, Art. II (honestly: no external normative anchor) | `design-slop` |

---

## Checklist

> The non-mechanizable mechanism: interaction quality per ISO 9241-110:2020
> plus the WCAG clauses no scanner fully covers. Reviewed by a human per
> story that touches UI.

- [ ] Each screen states what it is for and what to do next; empty states explain what will appear and offer the first action — ISO 9241-110:2020 (self-descriptiveness); DESIGN.md section 13
- [ ] Controls behave as the platform and the domain lead users to expect; no surprise navigation or focus theft — ISO 9241-110:2020 (conformity with user expectations)
- [ ] Long or destructive operations can be cancelled or undone; destructive confirmations name the consequence — ISO 9241-110:2020 (controllability, use error robustness); DESIGN.md section 13
- [ ] Error messages state what happened, why, and how to recover — no jargon, no blaming the user — ISO 9241-110:2020 (use error robustness); DESIGN.md section 13
- [ ] Full keyboard traversal in a logical order; the focused element is visible and unobscured at every stop — WCAG 2.2 SC 2.1.1, SC 2.4.3, SC 2.4.11
- [ ] prefers-reduced-motion honored: non-essential animation and parallax disabled — WCAG 2.2 SC 2.3.3 (adopted as kit doctrine)
- [ ] Pointer targets meet the 44x44 house floor (24x24 is the standard minimum) — WCAG 2.2 SC 2.5.5 / SC 2.5.8; DESIGN.md section 8

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| WCAG 2.2 | Web Content Accessibility Guidelines, W3C Recommendation (2023) — the accessibility standard this dimension floors on |
| Level AA | The middle WCAG conformance level — this canon's minimum bar; AAA clauses are adopted case by case as kit doctrine |
| SC | Success Criterion — a numbered, testable WCAG clause (e.g. SC 1.4.3) |
| Contrast ratio | Luminance ratio between foreground and background (1:1 to 21:1) — 4.5:1 is the AA body-text floor |
| Focus indicator | The visible marker showing which element receives keyboard input |
| Target size | The clickable/tappable area of a control, in CSS pixels |
| prefers-reduced-motion | The OS-level user signal, exposed to CSS/JS, requesting minimal animation |
| Interaction principles | The seven qualities of ISO 9241-110:2020 that describe good human-system dialogue |
| Core Web Vitals | The three-field metric set — LCP, INP, CLS — used here as fitness functions with blocking budgets |
| LCP | Largest Contentful Paint — time until the main content is rendered; budget 2.5 s |
| INP | Interaction to Next Paint — worst-case interaction latency across the visit; budget 200 ms (replaced FID in 2024) |
| CLS | Cumulative Layout Shift — total unexpected layout movement; budget 0.1 |
| p75 | The 75th percentile of real-user measurements — the CWV gating point when field data exists |
| Lab-equivalent | A reproducible synthetic run (e.g. CI page load) gating on the same thresholds when field data does not exist |
| Bundle budget | A declared byte ceiling per JS entry point; exceeding it blocks (Art. XII) |
| Design token | A named, versioned visual decision (color, spacing, type, motion) consumed by components instead of raw values |
| DTCG format | The W3C Design Tokens Community Group Format Module — the tool-neutral token file format used as source of truth |
| Slop / SLOP-* | The rule family of the `design-slop` sensor — mechanical detectors of LLM-generated-UI sameness (see DESIGN.md section 3) |
| design:ignore | The per-line opt-out comment recognized by `design-slop` — a recorded exception, not a silent one |
| Not assessable | The verdict for a project with no rendered-UI substrate — reported, never scored (Art. XXV.3) |
