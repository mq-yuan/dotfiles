# IO Contract

AI-CONTRACT: IO-001

Do not re-implement generic IO helpers. Reuse canonical utilities first.

## Rules
1. Search for existing shared helpers before writing new loader/writer code.
2. Add module-local IO logic only when format is truly non-standard.
3. Keep shape, dtype, color/depth semantics explicit.
4. Add or adjust tests when adding any new IO path.

## AI-HOTSPOT: Canonical IO utilities
Path: `src/<package>/utils/io.py`
Purpose: Shared image/text/binary read and write helpers.
Key symbols: `load_*`, `save_*`, `read_*`, `write_*`.
Pitfalls:
- Silent format conversion can hide data issues.
- Channel/layout assumptions can break downstream code.

## AI-HOTSPOT: Dataset-specific decode path
Path: `src/<package>/datasets/<dataset>.py`
Purpose: Decode non-standard dataset-specific files.
Key symbols: dataset-local `_load_*` helpers.
Pitfalls:
- Generic readers may not preserve dataset semantics.
- Missing validation causes late failures in training.

## Related
- Dataset format rules: `ai-docs/contracts/datasets.md`
- Unit test SOP: `ai-docs/playbooks/write-unit-tests.md`
