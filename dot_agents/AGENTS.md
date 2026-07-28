# Global Agent Instructions

Canonical instruction file shared by all coding agents (Claude Code, Codex, omp).
Managed by chezmoi. Tool-specific files import or symlink this file.

## Communication

- Reply in Chinese by default; switch to English only when explicitly requested.
- All repository content (code, comments, docs, configs, commit messages) must be English only.
- Do not introduce Chinese text into any repository file, including diff/patch lines.
- Exception: research/survey notes under a `docs/research/` (or equivalent) folder may be bilingual (Chinese + English), paragraph-by-paragraph. This relaxation applies only to such research notes, not to code, configs, or other docs.
- Keep existing project terminology consistent; do not rename concepts without explicit instruction.


## Delivering Files to the User

- **NEVER deliver files via `/tmp` (including any scratchpad under `/tmp`).** The user will not
  open them. A file handed over in `/tmp` is a non-delivery.
- Deliver in one of exactly two ways:
  1. **In the project directory** — save under the repo (e.g. `outputs/`) and give the path.
  2. **On the server** — leave it on the remote and state the absolute remote path so the user
     can open it there.
- This applies to every artifact the user is meant to look at: images, EXR/depth dumps, reports,
  exports, logs.
- `/tmp` remains fine for my own intermediate work that the user never opens.


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

### Scientific Plotting

- Body text font: Libertinus Serif (preferred), with the fallback chain TeX Gyre Termes → Times New Roman → DejaVu Serif.
- **Fail-fast over silent recovery**: this is a research codebase — bugs must surface immediately, not be swallowed. Follow these rules strictly:
  - **Do not use bare `except:` or `except Exception:`** to suppress or hide errors.
  - **Avoid `try/except` blocks** unless you are handling a *specific*, *expected*, *recoverable* exception (e.g. `FileNotFoundError` when a missing file is a valid code path). In every such case add a comment explaining why the exception is caught and what the recovery is.
  - **Never wrap exploratory, experimental, or diagnostic code in `try/except`**. Research code is often temporary; hidden failures make root-cause analysis impossible and create hard-to-remove technical debt.
  - Prefer explicit assertions (`assert condition, "message"`) or direct attribute access over defensive guards that mask bugs.
  - If cleanup is needed, use `with` statements (context managers) or `try/finally` — **not** `except` — so exceptions still propagate.


## Shell and Tooling

- **Agent-executed commands, scripts, and automation: use bash/POSIX-compatible syntax.** Agent shell tools run in bash/zsh, not fish; scripts must stay portable across environments and pipelines.
- **Commands intended for the user to run manually in their own terminal: use fish syntax.** The user's interactive shell is fish. This applies only to copy-paste instructions addressed to the user (e.g. interactive logins, one-off setup commands), not to anything the agent executes itself or writes into files.
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


## Agent Skills and Instructions Management

- `~/.agents/` is the canonical location for cross-tool agent assets: this file and the shared skills under `~/.agents/skills/`.
- Claude Code, Codex, and omp consume them via symlinks: `~/.claude/skills/*` and `~/.config/codex/skills/*` link to the canonical skills, `~/.config/codex/AGENTS.md` links to this file, `~/.claude/CLAUDE.md` imports it, and `~/.codex` is a symlink to `~/.config/codex`.
- Everything above is managed by chezmoi (public repo `mq-yuan/dotfiles`). Do not edit tool-side symlinks; edit the canonical files, then sync via chezmoi.
- To add a new general-purpose skill:
  1. Create `~/.agents/skills/<name>/` with a `SKILL.md`.
  2. Symlink it into `~/.claude/skills/` and `~/.config/codex/skills/`.
  3. `chezmoi add` the new directory and both symlinks, then commit and push (with the user's approval).
- Project-specific skills (anything referencing a particular project, its notes, or unpublished content) stay in that project's `.claude/skills/` and must never be added to the public dotfiles repo.

## Task Discipline

- Keep changes atomic and scoped to the stated goal.
- If a task is ambiguous, ask a single clarifying question before proceeding.
- Prefer explicit over implicit; surface assumptions rather than silently resolving them.
- Do not over-engineer: avoid splitting simple tasks into multiple files or abstractions unless necessary.
