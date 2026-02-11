# Dataset Contract

AI-CONTRACT: DATASETS-001

Always use dataset-specific loaders/writers when required. Do not assume all formats are standard.

## Rules
1. Reuse canonical dataset base types and collate contracts.
2. Register datasets through the project registry path.
3. Keep non-standard decoding logic near dataset implementation.
4. Validate shapes and semantics before training/inference.

## AI-HOTSPOT: Dataset implementation
Path: `src/<package>/datasets/<dataset>.py`
Purpose: Load records and convert them into canonical sample structures.
Key symbols: dataset class, `_sample_from_index`, `_load_*` helpers.
Gotchas:
- Metadata schema drift can silently corrupt sample mapping.
- Intrinsics/extrinsics or coordinate assumptions can mismatch training code.
Sanity checks:
- Required metadata files exist and include required columns/fields.
- Decoded tensors have expected shape and dtype.
- Relative transforms follow the documented frame convention.

## AI-HOTSPOT: Dataset registry
Path: `src/<package>/datasets/registry.py`
Purpose: Registry-driven dataset instantiation from typed config.
Key symbols: `register_dataset`, `get_dataset`, `get_dataset_spec`.
Gotchas:
- Config `name` must exactly match a registered key.
- Wrong config subtype raises build-time type errors.
Sanity checks:
- Compose config and instantiate dataset in tests.
- Add or refresh tests for changed dataset constructors.

## Related
- Interface impact: `ai-docs/contracts/interfaces.md`
- Add dataset SOP: `ai-docs/playbooks/add-dataset.md`
