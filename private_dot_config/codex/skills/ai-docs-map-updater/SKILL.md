---
name: ai-docs-map-updater
description: Incrementally maintain ai-docs map indexes while enforcing consistent map templates across repositories. Use when asked to update ai-docs/map after code changes, fix stale Path entries, add canonical or hotspot navigation for new or moved modules, or produce a concise map and template drift report.
---

# AI Docs Map Updater

## Overview

Update only impacted `ai-docs/map/` scopes. Keep documentation pointer-based, navigation-critical, and minimal. Resolve the diff range automatically from the ai-docs Git baseline label, and enforce consistent map file templates so incremental edits do not drift across projects.

## Inputs

- `commit_window` (optional): Number of latest commits to inspect.
- `focus` (optional): Extra scope hints from the user (for example `loss`, `dataset`, `predictor`).
- `enforce_templates` (optional, default `true`): Whether to normalize impacted map files to the map template profile.

Interpretation rules:
- If `commit_window` is provided and `N > 0`: inspect files changed in `HEAD~N..HEAD` plus current uncommitted changes.
- If `commit_window` is omitted: read `ai-docs/_meta/git-baseline.md`, extract `AI-DOCS-BASELINE-COMMIT`, and inspect files changed in `<baseline>..HEAD` plus current uncommitted changes.

## Template Profile Resolution

Use this sequence before map edits:

1. Read `ai-docs/_meta/template-profile.md`.
2. Extract `AI-DOCS-TEMPLATE-PROFILE: <profile>` when present.
3. If missing, fallback to built-in `ai-docs-v1` map rules.
4. Report which template source was used (`metadata` or `builtin`).

Map template rules for `ai-docs-v1`:
- Keep one `AI-MAP:` token near the top of each map index file.
- Keep `## Key files` section with curated entries.
- Keep `## Related` links at the end.
- Use this entry format for key files:

```markdown
### Path: `path/to/file`
Purpose: One-line role of this file in the architecture.
Key symbols: Core classes/functions/constants for navigation.
Pitfalls: High-risk assumptions or common break points.
```

## Baseline Resolution

When `commit_window` is omitted, use this sequence:

1. Read `ai-docs/_meta/git-baseline.md`.
2. Extract the commit from `AI-DOCS-BASELINE-COMMIT: <sha>`.
3. Validate the commit exists (`git cat-file -e <sha>^{commit}`).
4. If valid, use `<sha>..HEAD` as the committed diff range.
5. If missing or invalid, fallback in order:
   - `git log -1 --format=%H -- ai-docs`
   - uncommitted changes only
6. Always include uncommitted changes from working tree and index.
7. Report which baseline source was used (`metadata`, `git-log`, or `none`).

## Workflow

1. Read `ai-docs/00-START-HERE.md` before exploration or edits.
2. Resolve template profile (rules above).
3. Resolve baseline commit (rules above).
4. Identify changed code areas.
5. Map changed areas to impacted map indexes under `ai-docs/map/`.
6. Detect stale `Path:` entries and template drift in impacted indexes.
7. Apply minimal updates only in impacted indexes:
   - fix broken paths
   - add links to new sub-indexes for major new or moved modules
   - add or update canonical or hotspot entries using standard fields
   - normalize missing or malformed map template sections when `enforce_templates=true`
8. Keep indexes scoped and small:
   - include only navigation-critical entries (canonical APIs, high fan-in or fan-out modules, key hotspots)
   - if an index grows beyond around 30 key entries, split into deeper sub-indexes and link them
9. Refresh `ai-docs/_meta/git-baseline.md` to current `HEAD` metadata after map update pass, including no-op passes where map content was already up to date.
10. Re-run path and template verification and produce a short report.

## Command Pattern

Use commands like these (adjust as needed):

```bash
# 1) Read baseline commit from ai-docs metadata
rg -No "AI-DOCS-BASELINE-COMMIT:\\s*([0-9a-f]{40})" -r '$1' ai-docs/_meta/git-baseline.md

# 2) Validate baseline commit
git cat-file -e <BASELINE_COMMIT>^{commit}

# 3) Changed files by baseline range (default path)
git diff --name-only <BASELINE_COMMIT>..HEAD

# 4) Changed files by commit window override
git diff --name-only HEAD~<N>..HEAD

# 5) Uncommitted changes
git diff --name-only
git diff --name-only --cached

# 6) Locate map files for impacted scopes
find ai-docs/map -type f | sort

# 7) Verify Path entries
rg -n "Path:" ai-docs/map

# 8) Verify map template markers
rg -n "^AI-MAP:" ai-docs/map
rg -n "^### Path:|^Purpose:|^Key symbols:|^Pitfalls:" ai-docs/map
```

## Guardrails

- Do not rebuild the whole `ai-docs/map/` tree.
- Do not rewrite unrelated existing sections.
- Do not add exhaustive file lists; keep entries high-signal.
- Preserve existing project terminology and naming.
- Keep `ai-docs/_meta/git-baseline.md` and `ai-docs/_meta/template-profile.md` machine-parseable with stable keys.

## Completion Report

Return these sections at minimum:

- Modified files list
- Template source and profile used
- Baseline source and range used
- Baseline commit before and after refresh
- Stale paths found and fixed
- Template drift found and fixed
- New hotspots added
- Verification output summary for `rg -n "Path:" ai-docs/map` and map template checks

If no map updates are needed, state that explicitly and include verification results and baseline refresh outcome.
