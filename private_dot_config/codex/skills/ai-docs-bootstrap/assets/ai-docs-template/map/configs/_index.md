# Configs Index

AI-MAP: CONFIGS-ROOT

Configuration root for runtime composition.

## Key files

### Path: `configs/experiment/train.yaml`
Purpose: Main training composition preset.
Key symbols: dataset/model/trainer references.
Pitfalls: Preset references can break when config names change.

### Path: `configs/dataset/default.yaml`
Purpose: Default dataset configuration.
Key symbols: dataset name, path fields, sampler options.
Pitfalls: Path or split mismatches can silently reduce coverage.

### Path: `configs/model/default.yaml`
Purpose: Default model configuration.
Key symbols: architecture and channel/dimension options.
Pitfalls: Dimension mismatches can cascade into runtime failures.

## Related
- Source map: `ai-docs/map/src/_index.md`
