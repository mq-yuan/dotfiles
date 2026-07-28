---
name: paper-style
description: Apply and extend a direct, method-forward CV/ML paper writing profile distilled from MVSNet and related papers. Use when drafting, revising, or reviewing an Abstract, Introduction, Related Work, Method, Experiments, or Conclusion; when the user asks for MVSNet-like flow, concrete technical prose, or stronger sentence-to-sentence progression; or when new reference papers should be distilled into this style.
---

# Paper Style

Use this skill as a style layer for CV/ML paper writing. Preserve the user's
technical meaning, evidence boundaries, terminology, and editing protocol.
Never invent results, implementation details, datasets, or citations to improve
the prose. When `research-paper-writing` is also available, apply its factual and
citation safeguards before this style layer.

## Apply the profile

1. Extract the section's single task, semantic spine, and required evidence.
2. Read `references/style-profile.md`.
3. Read the relevant section in `references/section-patterns.md`.
4. Draft a linear argument in which each sentence uses an object or claim from
   the previous sentence and creates the premise for the next.
5. Describe technical procedures in their actual execution order. Follow each
   important design choice with its direct technical consequence.
6. Run the flow audit in `references/style-profile.md`.
7. Return unresolved factual gaps separately instead of filling them with
   plausible details.

Do not force the profile when the user's accepted rhetorical direction requires
a different structure. Do not copy wording from the source papers; reuse only
the distilled organizational and rhetorical principles.

## Extend the profile

When the user supplies more reference papers:

1. Read the relevant full sections, not only the abstracts.
2. Record section-level observations in `references/source-notes.md`.
3. Separate recurring patterns from paper-specific choices.
4. Promote a pattern into `style-profile.md` only if it recurs across sources
   or the user explicitly selects it.
5. Update `section-patterns.md` only when the new evidence changes a
   section-level recipe.

Read `references/source-notes.md` when extending the profile, explaining its
provenance, or checking whether a rule is source-supported.
