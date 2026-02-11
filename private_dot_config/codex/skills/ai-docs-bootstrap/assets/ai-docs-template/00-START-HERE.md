# AI Start Here

AI-MAP: START

Read this file first before touching code.

## Workflow (required)
1. Use `ai-docs/map/_index.md` to locate canonical files before writing.
2. Read relevant contracts in `ai-docs/contracts/` before IO, dataset, or interface edits.
3. Create a task file from `ai-docs/tasks/task_template.md` under `ai-docs/tasks/in-progress/`.
4. Keep the task file updated while working, then move it to `ai-docs/tasks/done/` on completion.

## Fast lookup commands
```bash
rg -n "AI-MAP:" ai-docs/map
rg -n "AI-CONTRACT:|AI-HOTSPOT:" ai-docs/contracts
rg -n "class .*Dataset|register_dataset|collate" src
rg -n "Input|Batch|LossInputs|interface|types" src
```

## Default guardrails
- Reuse canonical utilities; do not re-implement loaders, writers, or helpers.
- For non-standard datasets, keep dataset-specific readers close to the dataset module.
- For interface changes, update upstream producers, downstream consumers, and tests together.

## Metadata anchors
- Template profile: `ai-docs/_meta/template-profile.md`
- Git baseline: `ai-docs/_meta/git-baseline.md`
