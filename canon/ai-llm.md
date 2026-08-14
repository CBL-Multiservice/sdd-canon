---
sdd: canon
dimension: ai-llm
standards:
  - "OWASP Top 10 for LLM Applications (2025)"
  - "ISO/IEC 42001:2023 (AI management systems)"
  - "NIST AI Risk Management Framework (AI RMF 1.0, 2023)"
sensors:
  - token-budget
checklist: true
measurability: "Requires a model-touching surface: code that calls an LLM (hosted provider or local model), prompts under version control, or model outputs consumed by the product. A project with no model-touching code is not assessable — never scored. A model call hidden in a dependency still counts as substrate once discovered."
---

# Canon — AI / LLM

> One engineering dimension of the Quality Canon (Art. XXV). Structure
> validated by `canon-check`; the cost/latency discipline comes from the
> `token-budget` sensor, and the security and eval posture from the
> standard-derived checklist below.

---

## Doctrine

**A prompt is not a security boundary.** OWASP Top 10 for LLM Applications
(2025) is this dimension's threat floor, and its first entry — prompt
injection (LLM01) — is treated as what it actually is: an UNTRUSTED INPUT
problem. Any text the model reads that the operator did not author (user
messages, retrieved documents, tool outputs, web pages) can carry
instructions, and no system prompt, however stern, makes that safe. The
mitigations live OUTSIDE the prompt: privilege separation (the model gets
the least capability that does the job), tool allowlisting, output
validation before anything acts on it, and human confirmation on
consequential actions. "We told the model not to" is not a control; it is a
hope with a temperature setting. The rest of the floor follows the list:
insecure output handling (model output is untrusted input to the NEXT
component), excessive agency, and sensitive information disclosure.

**No secrets or personal data in third-party prompts.** A prompt sent to a
hosted provider is data leaving the trust boundary. Secrets never go in it;
personal data goes in it only under a recorded decision that names the legal
basis and the provider's data-handling terms (cross-reference:
[privacy.md](privacy.md) for the data rules, [cloud.md](cloud.md) for
processor obligations). Redaction happens before the call, not in the log
review after.

**An unevaluated model feature is an unsensed feature.** Everywhere else in
this kit, behavior is verified by sensors; model behavior is no exception —
evals ARE the behavioral sensors of this dimension. Every model-touching
feature declares a golden set: curated inputs with expected-quality outputs
and explicit failure examples. The eval runs like any test suite, and it
RERUNS on every change to model id, prompt, temperature or decoding
parameters — a prompt tweak is a deploy to the model's behavior, and an
unevaluated one is an unreviewed deploy. One honest caveat, stated rather
than hidden: the kit's calibrated LLM-as-judge is SDD3-10, ships behind a
flag, and NEVER blocks until its calibration against a human-labeled golden
set is proven. Until then, evals block on what deterministic checks can
assert (structure, groundedness against sources, refusal cases); judged
scores are advisory.

**Tokens are a budget, not weather.** Under Art. XII, cost and latency are
fitness functions: every model-touching feature declares a token/cost budget
and a latency budget, and the `token-budget` sensor compares measured
consumption against the declaration — exceeding the budget is a bug that
blocks, not a line item to explain later. Unbounded consumption is also the
denial-of-wallet entry of the OWASP LLM Top 10 (unbounded consumption,
2025): the budget is simultaneously an economic and a security control.

**Model identity is pinned; change is a decision.** The model id (and
version/date suffix where the provider offers one) is pinned in
configuration under version control — "latest" is not a model, it is a
surprise subscription. Changing model, provider, prompt or sampling
parameters is a recorded decision (decision log) accompanied by an eval
rerun whose results are attached. ISO/IEC 42001:2023 anchors the management
posture this implies: an accountable owner for each AI-touching capability,
risk assessment proportionate to impact, monitoring in operation, and
documented lifecycle change control. NIST AI RMF 1.0 (2023) supplies the
same discipline in framework form — govern, map, measure, manage — for
organizations that anchor to NIST instead.

---

## Rules

| # | Rule | Standard anchor | Verified by |
|---|------|-----------------|-------------|
| 1 | All model-read text from outside the operator's authorship is treated as untrusted input; controls live outside the prompt (least-capability tools, output validation, confirmation on consequential actions) | OWASP Top 10 for LLM Applications (2025) — LLM01 prompt injection | checklist |
| 2 | Model output is untrusted input to the next component: validated/encoded before execution, rendering or storage | OWASP Top 10 for LLM Applications (2025) — insecure output handling | checklist |
| 3 | No secrets in prompts to third-party providers; personal data only under a recorded decision naming legal basis and provider terms | OWASP Top 10 for LLM Applications (2025) — sensitive information disclosure; ISO/IEC 42001:2023 | checklist (+ privacy.md rules) |
| 4 | Every model-touching feature has an eval with a golden set; the eval reruns on any change to model id, prompt, temperature or decoding parameters | ISO/IEC 42001:2023 — performance monitoring; NIST AI RMF 1.0 (2023) — measure | checklist |
| 5 | Every model-touching feature declares a token/cost and latency budget; measured consumption within budget, exceeding blocks (Art. XII) | NIST AI RMF 1.0 (2023) — manage; OWASP Top 10 for LLM Applications (2025) — unbounded consumption | `token-budget` |
| 6 | Model id is pinned in versioned configuration; model/provider/prompt/parameter change = recorded decision + eval rerun with attached results | ISO/IEC 42001:2023 — change management | checklist |
| 7 | LLM-as-judge scores never block a gate until the judge is calibrated against a human-labeled golden set (SDD3-10, behind a flag) | ISO/IEC 42001:2023 — validity of measurement | checklist (honest-limit clause) |

---

## Checklist

> Reviewed per story that touches a model call, a prompt, or model-output
> handling. The `token-budget` sensor enforces rule 5 mechanically; the rest
> is review against the anchors below.

- [ ] Untrusted text (user input, retrieved docs, tool output) reaching the model is inventoried; mitigations are outside the prompt: least-capability tool access, output validation, human confirmation on consequential actions — OWASP LLM Top 10 (2025), LLM01
- [ ] No model output is executed, rendered or persisted without validation appropriate to its sink (encode for HTML, parameterize for SQL, schema-check for JSON) — OWASP LLM Top 10 (2025), insecure output handling
- [ ] Prompts to third-party providers carry no secrets; any personal data in them traces to a recorded decision with legal basis and provider data-handling terms — OWASP LLM Top 10 (2025); ISO/IEC 42001:2023
- [ ] The feature has a golden-set eval (curated inputs, expected outputs, explicit failure cases) that runs in the harness and blocks on its deterministic assertions — ISO/IEC 42001:2023; NIST AI RMF 1.0 (2023)
- [ ] The eval reran after the latest change to model id, prompt, temperature or decoding parameters, and results are attached to the story — ISO/IEC 42001:2023, change control
- [ ] Token/cost and latency budgets are declared for the feature and wired to the `token-budget` sensor; a breach blocks — Art. XII; OWASP LLM Top 10 (2025), unbounded consumption
- [ ] Model id is pinned (no "latest"); any provider or model change has a decision-log entry with the eval rerun attached — ISO/IEC 42001:2023
- [ ] Any LLM-judged score used in this story is marked advisory unless the judge's calibration evidence exists (SDD3-10 flag on) — honest-limit clause

---

## Legend & Glossary

| Term | Meaning |
|------|---------|
| Prompt injection | Instructions smuggled into model-read text by a party other than the operator (OWASP LLM01, 2025) — an untrusted-input problem |
| Untrusted input | Any text the operator did not author: user messages, retrieved documents, tool outputs, web content |
| Insecure output handling | Consuming model output without validation appropriate to its sink — output is input to the next component |
| Eval | The behavioral sensor of a model-touching feature: golden set + assertions, run like a test suite |
| Golden set | Curated inputs with expected-quality outputs and explicit failure examples, under version control |
| LLM-as-judge | Using a model to score another model's output; advisory in this kit until calibrated (SDD3-10, flagged) |
| Token budget | The declared token/cost ceiling per feature; a fitness function under Art. XII — exceeding blocks |
| Unbounded consumption | The OWASP LLM Top 10 (2025) risk of uncapped model usage — denial of wallet; the budget is the control |
| Pinned model id | An exact model identifier (with version/date where offered) in versioned config; "latest" is forbidden |
| Excessive agency | Granting the model more capability (tools, permissions, autonomy) than the feature requires |
| Not assessable | The honest verdict when the project has no model-touching surface (Art. XXV.3) — never a score |
