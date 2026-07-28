# Section Patterns

Use these as default argument shapes, not mandatory fill-in templates.

## Abstract

Prefer one continuous path:

1. State the task or the specific limitation.
2. Present the method or resource.
3. Describe the main computation or construction in actual order.
4. Identify the design that enables the central capability.
5. State the evaluation scope.
6. Close with concrete results, generalization, efficiency, or scalability.

If the paper introduces a new framing, define it in one sentence and move
directly to the technical quantities that operationalize it. Avoid alternating
between conceptual explanation and method description.

## Introduction

Use a narrowing sequence:

1. Define the task and establish what current methods can do.
2. Identify the remaining bottleneck and explain its cause.
3. Review only the prior approaches needed to show why the bottleneck remains.
4. Present the central observation or representation choice.
5. Explain the method at overview level and connect each component to the
   bottleneck it addresses.
6. Preview the evidence.
7. List contributions as claims that the paper later demonstrates.

One strong bottleneck is usually better than several loosely related
motivations. Do not repeat the abstract sentence by sentence.

## Related Work

Organize work by the technical decision relevant to the paper, such as
representation, supervision, regularization, or scalability. Within each group:

1. State the shared approach.
2. Name representative methods and what they do.
3. Identify the limitation relevant to the present paper.
4. Position the proposed method by its different technical choice.

Avoid paper-by-paper catalogues and generic praise.

## Method

Begin with an overview that names the input, intermediate representations,
ordered operations, and outputs, and maps them to subsections.

For each component:

1. State the requirement or failure of the simpler alternative.
2. Introduce the representation or operation.
3. Specify its inputs and outputs.
4. Give the formulation.
5. Explain the direct consequence for the full system.

When ambiguity or a degenerate solution exists, state it explicitly before
introducing the constraint that addresses it. Keep implementation choices
separate from the conceptual method unless the choice changes behavior.

## Experiments

Make each subsection answer one question:

1. State the capability being tested.
2. Give the setup needed to interpret the comparison.
3. Report the main quantitative or qualitative result.
4. Explain the result using the proposed mechanism.
5. State the boundary or failure case when relevant.

Use ablations to test a named design claim, not merely to enumerate removed
components. Separate accuracy, generalization, scalability, and efficiency when
they require different evidence.

## Conclusion

Restate the problem, the technical choice, and the strongest demonstrated
consequence. Include a limitation only when it is concrete and supported.
Avoid broad forecasts or generic statements about future impact.
