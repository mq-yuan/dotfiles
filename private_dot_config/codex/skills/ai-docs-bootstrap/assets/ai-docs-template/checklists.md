# Checklists

AI-PLAYBOOK: CHECKLISTS

## Interface / Type Change Checklist
- Locate canonical type definitions first (`datasets/types.py`, `models/*/types.py`, `losses/types.py`).
- Update all upstream producers (dataset sample/collate, input builders).
- Update all downstream consumers (model stages, losses, validation/logging paths).
- Check serialization/load paths if checkpoint schema or typed fields changed.
- Add or update tests for shape, dtype, and key semantic invariants.
- Run the minimum validation commands in `ai-docs/commands.md`.

## IO / Dataset Change Checklist
- Search for canonical IO helper first and reuse shared loaders when possible.
- If dataset format is non-standard, keep dataset-specific readers local.
- Verify key tensor shapes and conventions before training/inference.
- Add sanity checks for missing files, invalid channels, and malformed metadata.
- Add or update fixtures/golden data in tests where practical.
- Update `ai-docs/contracts/datasets.md` when introducing new format gotchas.
