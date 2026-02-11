# Commands

AI-MAP: COMMANDS

Source references: `pyproject.toml`, CI config, script headers in `scripts/`.

## Tests
- `uv run pytest`
- `uv run pytest -m manual`
- `uv run pytest tests/test_placeholder.py -q`

## Lint
- `uvx ruff check src tests scripts`
- `uvx ruff check --fix src tests scripts`

## Training
- `uv run python -m scripts.train --config-name=debug`
- `uv run python -m scripts.train --config-name=train`

## Inference / Tools
- `uv run python -m scripts.infer --help`
- `uv run python -m scripts.export --help`
