# ~/.config/codex/AGENTS.md

## Communication
- In chat responses, prefer Chinese unless I explicitly ask otherwise.
- In any repository files (code, docs, README, comments, configs), use English only. Do not introduce Chinese text into files unless I provide a specific reference file and explicitly request using it.

## Python style and documentation
- Python docstrings must be Google-style and include "Args:" and "Returns:" sections when applicable, if it has args or returns.
- Python comments must be in English.
- Prefer clear, maintainable code with type hints where reasonable.

## Execution environment
- My default shell is fish. Prefer fish-compatible commands and syntax.
- My Python projects use uv for dependency and environment management.
- Run Python commands via uv (e.g., `uv run python -m ...`, `uv run pytest`) instead of calling python/pip directly.
- Run ruff via uvx (e.g., `uvx ruff`) instead of calling ruff

## Output constraints
- Do not place non-English text into generated files.
- When proposing shell commands, provide copy-paste ready commands (fish-friendly).

