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


## AI workflow (required)

1. Read `ai-docs/00-START-HERE.md` before any exploration or edits.
2. Use hierarchical indexes in `ai-docs/map/` to locate canonical implementation files.
3. Consult contracts in `ai-docs/contracts/` before changing IO, datasets, or interfaces.
4. Start each substantial task from `ai-docs/tasks/task_template.md` and track it in:
   - `ai-docs/tasks/in-progress/` while active
   - `ai-docs/tasks/done/` when completed
5. For recurring operations, follow `ai-docs/playbooks/` instead of inventing new ad-hoc workflows.


## Documentation scope

- `ai-docs/` is navigation and process scaffolding.
- Prefer pointers to canonical code paths instead of duplicating implementation.

