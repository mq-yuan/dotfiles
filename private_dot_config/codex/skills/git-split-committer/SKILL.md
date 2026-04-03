---
name: git-split-committer
description: Analyze currently staged Git changes, decide whether they represent one logical change or multiple tasks, split mixed staged work into multiple atomic commits when needed, and execute the commits safely. Use when Codex needs to inspect `git diff --staged`, consult `ai-docs` task, plan, issue, design, or progress records when present, infer task boundaries from staged hunks and repository structure, generate accurate commit messages, and directly run Git commands to create a clean, reviewable, revertable commit history without pulling in unstaged work.
---

# Git Split Committer

## Overview

Turn a broadly staged index into a small sequence of atomic commits. Analyze staged changes, infer task boundaries from the user, `ai-docs`, the staged diff, and repository structure, then split and commit directly when the evidence is strong enough.

## Input Priority

1. Treat explicit user instructions as the primary source of truth.
2. Inspect `ai-docs` task or plan records when `ai-docs/` exists.
3. Inspect `git diff --staged` as the primary technical artifact.
4. Use file paths, module boundaries, tests, docs, and naming semantics as supporting evidence.

Interpretation rules:

- Prefer staged content as the default commit scope.
- Ignore unstaged and untracked changes unless the user explicitly asks to include them.
- Refuse to invent intent that is not supported by the sources above.

## Workflow

### 1. Establish the repo state

- Run `git status --short`.
- Run `git diff --staged --stat`.
- Run `git diff --staged --name-status --find-renames`.
- Abort commit execution if nothing is staged.
- Record whether unstaged or untracked files exist and exclude them by default.
- Record suspicious WIP markers early: debug prints, temporary comments, scratch files, experimental code, broad cleanup, or accidental edits.

### 2. Gather task context

- Read the user prompt first and extract requested task boundaries, exclusions, ordering hints, and links between implementation, tests, docs, or generated outputs.
- If `ai-docs/` exists, read `ai-docs/00-START-HERE.md` first.
- Inspect only the most relevant task-tracking files under `ai-docs/`, especially current tasks, plans, issue notes, design notes, and progress logs.
- Extract candidate task names, goals, dependencies, exclusions, and status clues from `ai-docs`.
- If `ai-docs/` does not exist or does not clarify the work, infer boundaries from the staged diff and repository structure alone.

### 3. Inspect the staged diff at hunk level

- Read file-level summaries to understand broad scope.
- Read staged patches for each relevant path cluster.
- Reason at hunk level whenever one file contains more than one intention.
- Classify each hunk as one of:
  - feature or user-visible behavior
  - bug fix
  - refactor
  - rename or move
  - formatting or lint cleanup
  - tests
  - docs
  - generated artifacts
  - suspicious WIP or accidental edit
- Decide whether a test or doc hunk belongs to a specific semantic change or stands alone.

### 4. Build commit groups

- Create the smallest set of commits that preserves semantic completeness.
- Make each commit represent one clear intention.
- Group across multiple files when they serve the same user-visible goal.
- Split one file across multiple commits when distinct hunks support different tasks and the split is practical.
- Keep tests and docs with the change they explain when they are tightly coupled.
- Separate mechanical or structural changes from semantic changes whenever practical.
- Leave ambiguous hunks out of a commit rather than guessing.

### 5. Attribute evidence for every group

For each proposed commit, record:

- the files or hunks included
- the relevant evidence sources:
  - `user`
  - `ai-docs`
  - `staged-diff`
  - `repo-structure`
- why those changes belong together
- what is intentionally excluded
- whether the grouping depends on hunk-level reasoning

### 6. Resolve ambiguity before committing

- Call out genuine uncertainty explicitly.
- If the boundary materially affects history and the evidence is genuinely ambiguous, ask the user before creating commits.
- If one split is clearly better supported, say why and proceed conservatively.
- Prefer leaving a doubtful hunk staged or uncommitted over silently forcing it into the wrong commit.

### 7. Order the commits

Choose the order that produces the cleanest narrative and the safest reverts. Prefer this sequence when it matches the evidence:

1. pure rename or move with no semantic change
2. pure refactor or preparatory cleanup
3. main feature or fix together with tightly coupled tests and docs
4. standalone docs, generated refreshes, or cleanup commits

Ordering rules:

- Commit preparatory refactors before the behavior change they enable.
- Keep standalone formatting or import reordering out of behavioral commits when practical.
- Put large generated refreshes after the semantic change that requires them unless regeneration is itself a separate maintenance task.

### 8. Execute the split safely

- Prefer non-destructive index operations.
- Prefer whole-file operations when task boundaries align cleanly with files.
- Use hunk-level staging or patch-based workflows when multiple tasks live in one file.
- Re-check `git diff --staged` before every commit.
- Create commits directly when the grouping is sufficiently supported.
- Use commit messages that match the exact scope of each commit.
- Do not rewrite published history, amend existing commits, or discard working tree changes unless the user explicitly asks for that behavior.

Read `references/git-execution-patterns.md` when:

- a file contains multiple tasks
- a rename is mixed with semantic edits
- generated files or formatting are mixed with semantic changes
- the safest execution path is not obvious

### 9. Verify and report

- Run `git status --short` after the final commit.
- Run `git log --oneline -n <commit-count>` after creating the sequence.
- Compare the remaining staged or unstaged changes against the original scope.
- Report leftovers, exclusions, suspicious WIP, and any ambiguity that remained unresolved.
- Use the template in `references/output-template.md`.

## Commit Principles

- Create atomic commits.
- Group by logical change, not by file boundary alone.
- Optimize for reviewability, revertability, and clean narrative history.
- Keep commits small but semantically complete.
- Separate mechanical changes from semantic changes when practical.
- Separate refactors from behavior changes when practical.
- Keep tests and docs with the change they explain unless they are clearly standalone.
- Do not fabricate task boundaries without evidence.

## Grouping Signals

- Treat code across multiple files as one commit when it implements one coherent feature or fix.
- Split different intentions in the same file when the hunk boundaries are clear enough to do so safely.
- Treat formatting, import reordering, whitespace cleanup, or generated refreshes as separate mechanical signals unless they are inseparable from the real change.
- Treat tests as tightly coupled when they clearly validate one specific implementation change.
- Treat docs as tightly coupled when they explain one specific implementation change.
- Treat a refactor as preparatory when the later feature or fix depends on it but the refactor does not intentionally change behavior.
- Treat `ai-docs` task or plan records as strong evidence for task boundaries and dependency order.
- Treat matching module paths, test directories, filenames, and symbol names as supporting evidence, not standalone proof.

## Safety Guardrails

- Do not include unstaged changes unless the user explicitly requests it.
- Do not discard working tree changes unless the user explicitly requests it.
- Do not rewrite published history unless the user explicitly requests it.
- Do not amend existing commits unless the user explicitly requests it.
- Do not use destructive cleanup commands such as `git reset --hard` or `git checkout --` as part of normal splitting.
- Preserve the user's broader working tree while manipulating only the index or well-scoped patch files.

## Special Cases

### Multiple tasks in one file

- Inspect hunks individually.
- Split by hunk when the intents are distinct and the patch remains safe to apply.
- Leave ambiguous hunks out and report them if the split cannot be done cleanly.

### Formatting mixed with behavior changes

- Isolate formatting, import sorting, lint-only changes, and whitespace-only edits when practical.
- Keep them together only when the tool output is inseparable or the isolated diff would be misleading.

### Rename or move mixed with semantic edits

- Prefer one commit for the pure structural rename or move.
- Follow with a semantic edit commit unless the repository state or patch safety makes that separation impractical.

### Generated files

- Keep generated files with the source change that directly requires them when the relationship is clear.
- Split standalone regeneration or maintenance refreshes into their own commit.

### Tests

- Commit regression tests with the feature or fix they validate when the scope matches.
- Split standalone test cleanup or harness refactors when they are not specific to the main change.

### Documentation

- Commit docs with the feature or fix they explain when the scope matches.
- Split standalone docs cleanup or broad reorganization into its own commit.

### WIP artifacts

- Flag debug logging, TODO probes, temporary comments, commented-out code, experimental helpers, accidental renames, and unrelated cleanup.
- Exclude them by default unless the user explicitly wants them committed.

## Commit Message Rules

- Prefer Conventional Commit prefixes when they accurately describe the scope.
- Use `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`, `perf:`, `build:`, or `ci:` when appropriate.
- Write the subject in imperative mood.
- Keep the subject concise and usually near 50 characters when practical.
- Avoid a trailing period in the subject.
- Add a body only when it improves scope, rationale, or impact.
- Make the message faithfully match the true contents of the commit.

Examples:

- `refactor: split parser config normalization`
- `fix: handle null tokens in runtime parser`
- `test: add regression coverage for null parser input`

## Output Contract

Return the report in this order:

1. commit split conclusion
2. evidence
3. ambiguities
4. commit order
5. commit messages
6. execution summary

Minimum content requirements:

- List each proposed or created commit with a one-line purpose.
- For each commit, explain which files or hunks belong to it and why.
- Attribute whether the grouping came from user instructions, `ai-docs`, staged diff analysis, or repository structure.
- State alternative groupings only when they are plausible enough to matter.
- After execution, list the created commits in order, then list remaining staged, unstaged, or intentionally excluded work.

Read `references/output-template.md` when you need a ready-made response skeleton.

## Command Pattern

Use commands like these and adjust them to the repository:

```sh
git status --short
git diff --staged --stat
git diff --staged --name-status --find-renames
git diff --staged -- path/to/file
git diff --staged --word-diff -- path/to/file
git log --oneline -n 5
```

If `ai-docs/` exists, use commands like these to find task context:

```sh
find ai-docs -maxdepth 3 -type f | sort
rg -n "task|plan|issue|design|progress|milestone" ai-docs
```

## Trigger Examples

- `Use $git-split-committer to split the staged parser refactor and null-handling fix into atomic commits and commit them.`
- `Use $git-split-committer to inspect ai-docs and staged changes, separate docs cleanup from the feature work, and commit the result.`
- `Use $git-split-committer to analyze the staged diff, warn about ambiguous hunks, and create the safest commit sequence you can support.`

## References

- Read `references/output-template.md` for the reporting skeleton.
- Read `references/git-execution-patterns.md` for safe split-and-commit execution patterns.
