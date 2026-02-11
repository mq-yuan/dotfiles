---
name: ai-docs-bootstrap
description: Bootstrap and maintain a standardized ai-docs scaffold with consistent per-file templates across repositories. Use when asked to create or refresh AI navigation maps, contracts, playbooks, task and ADR templates, AGENTS workflow pointers, git baseline labels, or template profile metadata that keeps docs consistent across projects.
---

# AI Docs Bootstrap

## Overview

Create or update a grep-friendly `ai-docs/` tree that helps agents find canonical code paths quickly and follow consistent workflow contracts. Keep content hierarchical and pointer-based instead of duplicating implementation details. Enforce a default per-file template profile so every repository starts from the same document shape.

## Core Rules

- Reuse existing `ai-docs/` content; merge and extend instead of deleting.
- Prefer path pointers and key symbols over copied code blocks.
- Keep docs concise and split by hierarchy; avoid giant single files.
- Standardize file-level templates, not only directory layout.
- Preserve project-specific facts while normalizing section skeletons.
- Use stable grep tokens:
  - `AI-MAP:`
  - `AI-CONTRACT:`
  - `AI-PLAYBOOK:`
  - `AI-HOTSPOT:`
  - `AI-DOCS-BASELINE-COMMIT:`
  - `AI-DOCS-TEMPLATE-PROFILE:`
- Use consistent entry fields where relevant:
  - `Path:`
  - `Purpose:`
  - `Key symbols:`
  - `Pitfalls:`

## Required Deliverables

Create or update the following structure:

```text
ai-docs/
  00-START-HERE.md
  commands.md
  glossary.md
  checklists.md
  _meta/
    git-baseline.md
    template-profile.md
  map/
    _index.md
    ... hierarchical sub-indexes for real source roots
  contracts/
    _index.md
    io.md
    datasets.md
    interfaces.md
  playbooks/
    _index.md
    write-unit-tests.md
    add-dataset.md
    modify-encoder-input.md
  tasks/
    task_template.md
    in-progress/
    done/
  adr/
    adr_template.md
```

Also update repository `AGENTS.md` to require reading `ai-docs/00-START-HERE.md` before work.

## Bundled Template Asset

Use the bundled starter template as an internal seed. Apply it automatically when the skill runs.

- Asset path: `assets/ai-docs-template/`
- Source style: generic ai-docs skeleton with placeholders only (no project-specific modules/datasets/naming)
- Intended use: initialize or normalize `ai-docs/`, then specialize with repository facts

Execution rule:
- Do not ask the user to run `cp` or `rsync` for normal bootstrap requests.
- Perform scaffold creation and updates directly as part of skill execution.

Post-apply required edits:
- Refresh `ai-docs/_meta/git-baseline.md` with real current `HEAD`.
- Refresh `ai-docs/_meta/template-profile.md` timestamp and notes.
- Replace project-specific placeholders in map/contracts/glossary/commands.

## Template Profile Rules

Always create or refresh `ai-docs/_meta/template-profile.md` during bootstrap or full refresh.

Required fields (single-line key-value format):
- `AI-DOCS-TEMPLATE-PROFILE: ai-docs-v1`
- `AI-DOCS-TEMPLATE-SOURCE: ai-docs-bootstrap`
- `AI-DOCS-TEMPLATE-BASE: current-project-ai-docs`
- `AI-DOCS-TEMPLATE-RECORDED-AT: <UTC ISO-8601>`
- `AI-DOCS-TEMPLATE-NOTES: <short note or n/a>`

Generation rules:
- Use `ai-docs-v1` unless user requests another profile.
- Keep this file machine-parseable; avoid prose between fields.
- Link this file from `ai-docs/00-START-HERE.md` for discoverability.

## Git Baseline Label Rules

Always create or refresh `ai-docs/_meta/git-baseline.md` during bootstrap or full refresh.

Required fields (single-line key-value format):
- `AI-DOCS-BASELINE-COMMIT: <40-char sha>`
- `AI-DOCS-BASELINE-SHORT: <short sha>`
- `AI-DOCS-BASELINE-SUBJECT: <commit subject>`
- `AI-DOCS-BASELINE-DATE: <ISO-8601 commit date>`
- `AI-DOCS-BASELINE-BRANCH: <branch-or-detached>`
- `AI-DOCS-BASELINE-WORKTREE: clean|dirty`
- `AI-DOCS-BASELINE-RECORDED-AT: <UTC ISO-8601>`

Generation rules:
- Use current `HEAD` as the baseline commit.
- Set worktree status to `dirty` if staged or unstaged tracked changes exist, else `clean`.
- Keep the file machine-parseable; avoid prose between fields.
- Link this file from `ai-docs/00-START-HERE.md` for discoverability.

## Standard File Templates (ai-docs-v1)

Use these skeleton constraints when creating or normalizing files.

### `00-START-HERE.md`
- Keep header `# AI Start Here`.
- Include `AI-MAP: START`.
- Keep sections in this order:
  1. `## Workflow (required)` with four numbered workflow steps.
  2. `## Fast lookup commands` fenced shell block.
  3. `## Default guardrails` bullet list.
- Add links to `ai-docs/_meta/template-profile.md` and `ai-docs/_meta/git-baseline.md`.

### `map/_index.md` and map sub-indexes
- Keep one `AI-MAP:` token per file near the top.
- Keep a `## Key files` section with curated entries.
- Use this entry template for each key file:

```markdown
### Path: `path/to/file`
Purpose: One-line role of this file in the architecture.
Key symbols: Core classes/functions/constants for navigation.
Pitfalls: High-risk assumptions or common break points.
```

- Keep `## Related` links at the end.

### `contracts/_index.md`
- Keep header `# Contracts Index`.
- Include `AI-CONTRACT: INDEX`.
- Keep `## Contract files` and `## Contract usage rules` sections.

### `contracts/io.md`, `contracts/datasets.md`, `contracts/interfaces.md`
- Include one `AI-CONTRACT:` token near the top.
- Keep `## Rules` section with numbered defaults.
- Add `## AI-HOTSPOT: <name>` blocks for canonical paths.
- End with `## Related` cross-links.

### `playbooks/_index.md`
- Keep header `# Playbooks Index`.
- Include `AI-PLAYBOOK: INDEX`.
- Keep `## Available playbooks` and `## Related` sections.

### `playbooks/*.md`
- Include one `AI-PLAYBOOK:` token near the top.
- Keep `## SOP` section with numbered steps.
- Add repo-specific placement and exit checklist sections when relevant.
- End with `## Related` links.

### `commands.md`
- Keep header `# Commands`.
- Include `AI-MAP: COMMANDS`.
- Keep these section names when possible: `## Tests`, `## Lint`, `## Training`, `## Inference / Tools`.

### `glossary.md`
- Keep header `# Glossary`.
- Include `AI-MAP: GLOSSARY`.
- Use this per-term block shape:

```markdown
## <Term>
Definition: ...
Canonical type/location: ...
Common aliases: ...
```

### `checklists.md`
- Keep header `# Checklists`.
- Include `AI-PLAYBOOK: CHECKLISTS`.
- Maintain at least two checklist sections:
  - Interface or type change checklist.
  - IO or dataset change checklist.

### `tasks/task_template.md`
- Keep YAML frontmatter keys in this order:
  - `id`, `title`, `status`, `owner`, `created`, `updated`.
- Keep section order:
  - `# Context`
  - `# Goal`
  - `# Constraints`
  - `# Scope`
  - `# Relevant Map / Contracts / Playbooks`
  - `# Plan`
  - `# Progress Log`
  - `# Files Touched`
  - `# Commands Run`
  - `# Decisions`
  - `# Risks / Gotchas`
  - `# Next Steps`
  - `# Completion Notes`

### `adr/adr_template.md`
- Keep section order:
  - `## Status`
  - `## Context`
  - `## Decision`
  - `## Consequences`
  - `## Alternatives Considered`
  - `## References`

## Workflow

1. Discover repository layout and tooling.
2. Identify source roots, canonical IO utilities, datasets, encoder modules, and key interfaces.
3. Build map indexes from top-level to deeper package indexes.
4. Write contracts for IO, datasets, and interfaces with concrete hotspots.
5. Write task-focused playbooks and concise checklists.
6. Add task and ADR templates.
7. Normalize all required files to `ai-docs-v1` skeletons while preserving project-specific facts.
8. Insert an AI workflow pointer section into `AGENTS.md`.
9. Write or refresh `ai-docs/_meta/template-profile.md` using the required fields.
10. Write or refresh `ai-docs/_meta/git-baseline.md` using the required fields.
11. Run quick verification commands and report gaps or TODOs.

## Discovery Checklist

- Confirm top-level layout and config files (`pyproject.toml`, `README*`, `Makefile`, `tox.ini`, `noxfile.py`, `justfile`).
- Confirm source roots and key package tree.
- Locate canonical IO paths (for example `utils/io.py`, `load_*`, `save_*`, `read_*`, `write_*`).
- Locate dataset readers, collate, and dataloader paths.
- Locate encoder modules and input/output type definitions.
- Detect test and lint commands from repository config.

## Map Construction Rules

- Start at `ai-docs/map/_index.md` and link to deeper `_index.md` files.
- Cover at least the primary source root and major subpackages.
- In each index, include a short overview, curated key files, and related links.
- Limit each index to important files; prefer deeper index links over exhaustive dumps.

## Contract Rules

- `contracts/io.md`: enforce reuse of canonical IO utilities and list `AI-HOTSPOT` paths.
- `contracts/datasets.md`: document non-standard dataset formats, loaders, gotchas, and sanity checks.
- `contracts/interfaces.md`: define core typed boundaries and include impact-analysis reminders.

## Playbook Rules

- `write-unit-tests.md`: locate canonical loaders first, choose test placement, run minimal checks.
- `add-dataset.md`: include where dataset code, config, and registration live and what must be updated.
- `modify-encoder-input.md`: track upstream producers, downstream consumers, config, and tests.

## AGENTS.md Update Rule

Add a small AI workflow section near the top. Require:

- Read `ai-docs/00-START-HERE.md` first.
- Use `ai-docs/map/` indexes.
- Consult contracts for IO, datasets, and interfaces.
- Track work with `tasks/task_template.md` in `in-progress/` then move to `done/`.

## Verification Commands

Use repository-compatible commands. Prefer equivalents when tools are missing.

```bash
tree ai-docs -L 4
rg -n "AI-MAP:|AI-CONTRACT:|AI-PLAYBOOK:|AI-HOTSPOT:" ai-docs
rg -n "AI-DOCS-TEMPLATE-" ai-docs/_meta/template-profile.md
rg -n "AI-DOCS-BASELINE-" ai-docs/_meta/git-baseline.md
rg -n "^id: task-YYYYMMDD-<slug>|^# Context|^# Completion Notes" ai-docs/tasks/task_template.md
rg -n "^## Status|^## Context|^## Decision|^## Consequences|^## Alternatives Considered|^## References" ai-docs/adr/adr_template.md
```

## Completion Output Checklist

- Summarize created or modified files.
- Provide short usage guidance.
- Include verification snippet output.
- Report the template profile recorded in `ai-docs/_meta/template-profile.md`.
- Report the baseline commit recorded in `ai-docs/_meta/git-baseline.md`.
- Call out unresolved TODOs and follow-up files.
