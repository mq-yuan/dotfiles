# Structured Output Template

Use this template for the analysis summary and the post-execution report. Keep the sections in this order so the user can scan the decision, the supporting evidence, and the resulting commits quickly.

## Template

```markdown
## Commit Split Conclusion
- Commit 1: <one-line purpose>
- Commit 2: <one-line purpose>
- Commit N: <one-line purpose>

## Evidence
### Commit 1
- Scope: <files and, when needed, specific hunks>
- Evidence sources: <user | ai-docs | staged-diff | repo-structure>
- Why together: <why these changes form one logical task>
- Exclusions: <what was intentionally left out, or `none`>

### Commit 2
- Scope: <files and, when needed, specific hunks>
- Evidence sources: <user | ai-docs | staged-diff | repo-structure>
- Why together: <why these changes form one logical task>
- Exclusions: <what was intentionally left out, or `none`>

## Ambiguities
- <what is uncertain>
- <alternative grouping>
- <recommended choice and reason>
- Write `None.` when no material ambiguity exists.

## Commit Order
1. <commit 1 title> - <dependency or narrative reason>
2. <commit 2 title> - <dependency or narrative reason>
3. <commit N title> - <dependency or narrative reason>

## Commit Messages
- Commit 1: `<type: subject>`
  Body: <optional rationale, or `none`>
- Commit 2: `<type: subject>`
  Body: <optional rationale, or `none`>

## Execution Summary
- Created commits:
  - `<shortsha> <subject>`
  - `<shortsha> <subject>`
- Remaining staged: <none or list>
- Remaining unstaged: <none or list>
- Intentionally excluded: <none or list>
- Suspicious WIP or follow-up items: <none or list>
```

## Reporting Rules

- Keep the commit split conclusion short and decisive.
- Put evidence at file or hunk granularity when file-level grouping is not enough.
- Mention `ai-docs` only when it materially influenced the grouping.
- Explain ambiguity only when it changes the recommended split or the execution safety.
- Include commit SHAs in the execution summary after the commits are created.
- State leftovers explicitly, even when the answer is `none`.
