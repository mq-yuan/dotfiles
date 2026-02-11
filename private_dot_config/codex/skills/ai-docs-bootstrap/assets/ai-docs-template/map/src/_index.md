# Source Index

AI-MAP: SRC-ROOT

Primary source root is `src/`. Add package-level sub-indexes here for major modules.

## Suggested sub-indexes
- `ai-docs/map/src/<package>/_index.md`
- `ai-docs/map/src/<package>/datasets/_index.md`
- `ai-docs/map/src/<package>/models/_index.md`
- `ai-docs/map/src/<package>/training/_index.md`
- `ai-docs/map/src/<package>/utils/_index.md`

## Key files

### Path: `src/<package>/config.py`
Purpose: Canonical typed config and object construction entry.
Key symbols: `load_config`, registry builders.
Pitfalls: Builder assumptions can diverge from runtime presets.

### Path: `src/<package>/registry.py`
Purpose: Registry wiring for pluggable modules.
Key symbols: register/get helpers.
Pitfalls: Name mismatches cause runtime lookup failures.

## Related
- Root map: `ai-docs/map/_index.md`
- Contracts: `ai-docs/contracts/_index.md`
