# ~/.config/codex/AGENTS.md

## Communication

- In chat responses, prefer Chinese unless I explicitly ask otherwise.
- When providing diffs/patches or content intended to be committed into a repository, use English only.


## Repository language rules

- In any repository files (code, docs, README, comments, configs), use English only.
- Do not introduce Chinese text into repository content, including newly added lines in diffs/patches, unless I provide a specific reference file and explicitly request using it.
- Keep existing project terminology and naming consistent (do not rename concepts casually).


## Python style and documentation

- Prefer clear, maintainable code with type hints where reasonable.
- Python docstrings must be Google-style and include "Args:" and "Returns:" sections when applicable.
- Python comments must be in English.
- Prefer `logging` over `print` for non-trivial runtime output unless the project clearly uses `print`.


## Shell and tooling (fish, uv)

- My default shell is fish. Provide copy-paste ready fish-compatible commands.
- Avoid bashisms; use fish syntax (`set -l`, `and`, `or`, `begin; ...; end`) when needed.
- Use uv for dependency and environment management.
  - Run Python via uv (e.g., `uv run python -m ...`, `uv run pytest`).
  - Run ruff via uvx (e.g., `uvx ruff`).
  - Add dependencies via `uv add <pkg>` (avoid ad-hoc pip installs).


## Quality gates (default expectations)

- After Python changes, prefer running:
  - `uvx ruff format`
  - `uvx ruff check --fix`
  - `uv run pytest` (if tests exist)
- Keep changes minimal and focused; avoid unrelated refactors unless explicitly requested.
- Update or add tests when behavior changes.
- Preserve existing formatting and conventions in the repo.

