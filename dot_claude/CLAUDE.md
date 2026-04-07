# Global Claude Instructions

## Communication

- Reply in Chinese by default; switch to English only when explicitly requested.
- All repository content (code, comments, docs, configs, commit messages) must be English only.
- Do not introduce Chinese text into any repository file, including diff/patch lines.
- Keep existing project terminology consistent; do not rename concepts without explicit instruction.


## Code Style

### General

- Write minimal, focused changes; avoid unrelated refactors unless explicitly requested.
- Preserve existing formatting conventions in each repo.
- Prefer clarity and maintainability over cleverness.

### Python

- Use modern native type hints: `list[str]`, `dict[str, int]`, `X | None` — never `typing.List`, `typing.Optional`, etc.
- Docstrings must be Google-style with `Args:` and `Returns:` sections where applicable.
- Comments must be in English.
- Prefer `logging` over `print` for non-trivial runtime output.
- For Hydra/OmegaConf structured configs, use `enum.StrEnum` (or `enum.Enum`) for categorical fields — avoid `typing.Literal` which causes OmegaConf validation errors.


## Shell and Tooling

- Use **bash/POSIX-compatible syntax** for all generated commands and scripts — ensures compatibility across environments, scripts, and automation pipelines.
- The user's interactive shell is fish; bash syntax runs fine in fish for one-liners and is safe in all other contexts.
- Use **uv** for all Python environment and dependency management:
  - Run Python: `uv run python -m ...`
  - Run tests: `uv run pytest`
  - Run ruff: `uvx ruff`
  - Add deps: `uv add <pkg>` — no ad-hoc `pip install`.


## Quality Gates

After any Python change, run in order:

1. `uvx ruff format`
2. `uvx ruff check --fix`
3. `uv run pytest` (if tests exist)

- Add or update tests whenever behavior changes.
- Never skip quality gates unless explicitly told to.


## Git

- Do not commit or push unless explicitly instructed.
- Commit messages must be concise, imperative mood, English (e.g. `fix: correct batch size default`).
- Never force-push, reset, or rebase without explicit instruction.
- Prefer small, focused commits; do not bundle unrelated changes.


## Safety

- Do not delete, overwrite, or move files without explicit instruction.
- Do not silently create new files outside the scope of the stated task.
- If a destructive or irreversible action is required, state it clearly and wait for confirmation.


## Task Discipline

- Keep changes atomic and scoped to the stated goal.
- If a task is ambiguous, ask a single clarifying question before proceeding.
- Prefer explicit over implicit; surface assumptions rather than silently resolving them.
- Do not over-engineer: avoid splitting simple tasks into multiple files or abstractions unless necessary.
