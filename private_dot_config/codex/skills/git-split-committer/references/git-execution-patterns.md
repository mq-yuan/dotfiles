# Safe Git Execution Patterns

Use these patterns to split staged work into multiple commits without silently pulling in unstaged changes or discarding the user's working tree.

## Core Guardrails

- Prefer staged content as the source of truth.
- Preserve unstaged and untracked files unless the user explicitly asks to include or remove them.
- Prefer index-only or patch-based operations over destructive commands.
- Re-check the staged diff before every commit.
- Stop and ask when a hunk boundary is genuinely unclear and the choice would materially affect history.

## Pattern 1: Split by whole files

Use this pattern when each task aligns cleanly with file boundaries.

```sh
git status --short
git diff --staged --name-status --find-renames
git restore --staged -- path/to/non-target-a path/to/non-target-b
git diff --staged --stat
git commit -m "type: subject"
git add -- path/to/next-target-a path/to/next-target-b
```

Use this pattern only when the files for the next commit do not also contain unrelated unstaged edits.

## Pattern 2: Split by hunks in one file

Use this pattern when one file contains multiple logical tasks.

```sh
git diff --staged -- path/to/file
git reset -p -- path/to/file
git diff --staged -- path/to/file
git commit -m "type: subject"
git add -p -- path/to/file
```

Use patch mode only when the environment handles it cleanly. If patch mode is unreliable, switch to a saved patch workflow.

## Pattern 3: Split from a saved staged snapshot

Use this pattern when hunk boundaries are tricky or the safest path is to work from the exact staged snapshot.

```sh
git diff --staged --binary > /tmp/original-staged.patch
# Derive one patch file per commit group from the staged snapshot.
git reset --mixed --quiet HEAD
git apply --cached --check /tmp/commit-1.patch
git apply --cached /tmp/commit-1.patch
git diff --staged --stat
git commit -m "type: subject"
```

If earlier commits change nearby context, rebuild later patches against the current `HEAD` instead of forcing an old patch to apply.

## Pattern 4: Separate rename or move from semantic edits

Use this pattern when a structural change and a behavior change are mixed together.

```sh
git diff --staged --name-status --find-renames
```

First isolate the pure rename or move if the staged diff supports that separation cleanly. Then commit the semantic follow-up edits.

## Pattern 5: Handle generated files carefully

- Keep generated output with the change that directly requires it when the relationship is clear.
- Split broad regeneration or maintenance refreshes into a separate commit when they are not tightly coupled.
- Re-check the staged diff to confirm that generated content does not hide unrelated manual edits.

## Verification Checklist

Run these checks after each commit and again at the end:

```sh
git diff --staged --stat
git status --short
git log --oneline -n 5
```

Confirm all of the following:

- the staged diff matches the intended commit scope before committing
- the commit message matches the actual scope
- the remaining staged or unstaged work is expected
- no suspicious WIP or accidental edits were silently committed
