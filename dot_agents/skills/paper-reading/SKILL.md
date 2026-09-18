---
name: paper-reading
description: Analyze research papers from a PDF or an authoritative link such as arXiv, a project page, or GitHub. Use when the user wants to understand a paper's core idea, conceptual contribution, or prerequisite knowledge gaps; expand experimental analysis only when requested.
---

# Paper Reading

Help the user learn the idea that makes a paper worth reading. Prefer a faithful conceptual model over an exhaustive section-by-section summary.

## Resolve the paper source

Accept a local paper, an arXiv or publisher link, a project page, a code repository, or a combination of these. Do not require the user to download a PDF when the paper can be retrieved from public authoritative sources.

- For an arXiv abstract or PDF link, read the paper itself and record the title, authors, and version used. Prefer the latest version unless the user identifies a specific version.
- For a project page, locate its authoritative paper or preprint. Use the project page for demos, media, supplementary explanations, and links, not as a substitute for evidence in the paper.
- For a GitHub repository, inspect its citation and paper links before analyzing the README. Use the paper as the main source for conceptual claims and the repository for implementation details, configuration, and code-level clarification. If no paper exists, state that the analysis covers the repository rather than a paper.
- For a DOI or publisher page, follow the canonical paper link and use an accessible author manuscript or preprint when the publisher copy is unavailable.

Confirm that linked sources refer to the same work before combining them. Do not guess bibliographic identity, version, or correspondence between a repository and a paper. If a source is inaccessible because of permissions, login, bot protection, or missing files, try the other authoritative links already available; request a PDF only after those routes fail.

## Default analysis

Read the paper itself whenever it can be retrieved. Use the user's observations, the project page, the repository, and related notes as context, but distinguish each of them from statements supported by the paper.

Organize only the concepts needed to understand the paper into three layers:

1. **General background:** Concepts broadly understandable without specialist knowledge of the paper's field.
2. **Field-standard prerequisites:** Established tasks, methods, assumptions, terminology, and limitations that a practitioner in the relevant area is normally expected to know.
3. **Paper-specific content:** The paper's own framing, definitions, observations, assumptions, mechanisms, and claimed findings.

Do not treat everything paper-specific as novel. Mark whether an item is a genuine conceptual contribution, an adaptation of known ideas, a renamed concept, an implementation choice, or merely a paper-specific presentation detail.

Derive the paper's **core delta** across these layers:

`established understanding or method -> unresolved limitation -> paper's key observation -> proposed mechanism -> intended consequence`

This core delta is the main result of the reading. Explain the causal connection instead of listing components.

## Knowledge-gap assessment

Identify field-standard prerequisites that may deserve review, but do not infer that the user lacks knowledge merely because they did not mention it. Use these evidence levels:

- **Confirmed known:** The user explicitly demonstrates it, or their notes contain substantive understanding.
- **Encountered, depth unclear:** The concept appears in prior context, but the user's level of understanding is uncertain.
- **Not found; verify:** Available context does not establish familiarity.
- **Confirmed gap:** The user explicitly says they do not understand it or demonstrates a specific misconception.

For each useful prerequisite, explain why it matters for this paper and give the smallest useful refresher. Avoid generic textbook surveys.

## Evidence boundary

Experiments are not the default center of the analysis. Include only the minimum evidence anchors needed to show how the paper supports its central claim, preferably with section, page, figure, or table locations. Do not expand datasets, metrics, baselines, ablations, or implementation details unless the user asks for experimental analysis or they are necessary to interpret the core idea.

Separate clearly:

- what the paper states or demonstrates,
- what follows directly from the method,
- what is an inference about the authors' reasoning,
- what remains uncertain or unsupported.

## Default output

Adapt the amount of structure to the paper, but normally provide:

1. **Core idea in one sentence**
2. **Three-layer knowledge map**
3. **Core delta**
4. **Prerequisite knowledge check**
5. **Minimum evidence anchors**
6. **Likely misreadings and open questions**

Omit empty or unhelpful sections. When the user asks to save the result into a paper note, preserve the note's existing language, terminology, and Obsidian structure.

## Optional modes

- **Experiment mode:** Analyze protocols, datasets, metrics, baselines, ablations, fairness, and claim-evidence alignment.
- **Review mode:** Evaluate novelty, technical soundness, evidence strength, missing comparisons, limitations, and possible reviewer concerns.

Use an optional mode only when the user requests it or when the requested conclusion cannot be supported without it.
