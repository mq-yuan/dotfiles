# Repo Map Index

AI-MAP: REPO-ROOT

This is the top-level navigation map. Start here, then jump to the closest sub-index.

## Sub-indexes
- `ai-docs/map/src/_index.md`
- `ai-docs/map/configs/_index.md`
- `ai-docs/map/tests/_index.md`

## Key files

### Path: `pyproject.toml`
Purpose: Project dependencies and tooling baseline.
Key symbols: test, lint, and package configuration sections.
Pitfalls: Default test/lint options can hide failing paths if filters are too strict.

### Path: `scripts/train.py`
Purpose: Training CLI entrypoint.
Key symbols: `main`, config loader, run entrypoint.
Pitfalls: Config-schema drift often surfaces at runtime.

### Path: `scripts/infer.py`
Purpose: Inference/export CLI entrypoint.
Key symbols: inference config, model load helpers, output writer.
Pitfalls: IO assumptions can mismatch dataset conventions.

### Path: `src/<package>/config.py`
Purpose: Typed config loading and registry-driven construction.
Key symbols: config loaders and builder functions.
Pitfalls: Optional config blocks can cause silent misconfiguration.

## Related
- Contracts: `ai-docs/contracts/_index.md`
- Playbooks: `ai-docs/playbooks/_index.md`
