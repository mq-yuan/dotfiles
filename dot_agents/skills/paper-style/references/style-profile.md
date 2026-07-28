# Distilled Style Profile

## Core character

Write in a direct, method-forward technical style. Build the paper around a
small number of concrete objects: the task, the limiting mechanism, the
proposed representation or operation, its immediate consequence, and the
evidence. Prefer a linear argument over a broad conceptual survey.

This profile was distilled from MVSNet and related papers by the same research
line. It captures recurring structural choices rather than their wording. See
`source-notes.md` for provenance.

## Argument structure

Use the following causal chain when the content supports it:

1. Define the task or establish the current capability.
2. Identify one controlling limitation.
3. Explain the mechanism that causes the limitation.
4. Introduce the proposed representation or operation at the same level of
   abstraction.
5. State the direct consequence of that design.
6. Provide experiments that test the consequence.

Do not insert a detached significance statement between these steps. If a
concept is necessary, introduce it where it changes the task definition,
method choice, or interpretation of evidence.

## Sentence-to-sentence flow

- Give each sentence one primary role.
- Reuse the established technical noun instead of rotating synonyms.
- Begin a sentence from information already available, then add one new unit.
- Keep cause next to consequence: `design -> resource/representation change ->
  capability`.
- Keep contrast local: state the prior choice, its specific limitation, and the
  proposed replacement in the same paragraph.
- Use `first`, `then`, and `next` only for a real computational or procedural
  order.
- Place definitions before the first inference that depends on them.
- End paragraphs on a technical consequence, an evidence-backed finding, or
  the precise question taken up next.

## Technical voice

- Prefer concrete subjects: `the decoder predicts`, `the cost volume requires`,
  `the dataset provides`.
- Prefer direct verbs over nominalized framing: `reduces`, `estimates`,
  `constructs`, `compares`, `shows`.
- Explain a component by input, operation, output, and purpose.
- Introduce equations only after stating the requirement or dependency they
  formalize.
- Use figures and tables as evidence anchors, not as substitutes for the claim.
- Keep claims proportional to the reported experiment.
- Use first-person plural when the authors' action matters; use passive voice
  when the operation or result is the focus.

## What not to inherit from the sources

Do not reproduce dated grammar, promotional phrases, unsupported
state-of-the-art language, or recurring surface expressions. Do not imitate
sentence fragments or copy distinctive phrases. The target is the sources'
clarity of technical progression, not stylistic mimicry.

## Flow audit

For every paragraph, check:

1. What single job does this paragraph perform?
2. Does its first sentence establish the object being discussed?
3. Does each later sentence depend on something already introduced?
4. Is the main limitation explained mechanistically rather than labeled?
5. Does each design choice have an immediate, specific consequence?
6. Is any sentence merely restating the paper's importance?
7. Does the final sentence close the paragraph or motivate the next one?

For the whole section, write a reverse outline. Remove or move any paragraph
whose role does not advance the section's main task.
