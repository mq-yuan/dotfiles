# Interface Contract

AI-CONTRACT: INTERFACES-001

Interface/type changes are high-impact. If you change an interface, update producers, consumers, configs, and tests in the same task.

## Core type boundaries

## AI-HOTSPOT: Dataset sample and batch contracts
Path: `src/<package>/datasets/types.py`
Purpose: Canonical sample and batch structures bridging dataset -> training.
Key symbols: `Sample`, `Batch`, metadata types.
Pitfalls:
- Shape or key changes propagate into collate, model input, and tests.

## AI-HOTSPOT: Model input/output contracts
Path: `src/<package>/models/<module>/types.py`
Purpose: Canonical model-facing IO types.
Key symbols: model `Input`, model `Output`.
Pitfalls:
- Field changes can break checkpoint loading and forward contracts.

## AI-HOTSPOT: Loss input contract
Path: `src/<package>/losses/types.py`
Purpose: Unified payload consumed by all loss modules.
Key symbols: `LossInputs` or equivalent payload type.
Pitfalls:
- Loss modules depend on stable key names and tensor semantics.

## Impact analysis (required on interface edits)
1. Upstream producers:
   dataset loaders, collate functions, input builders.
2. Downstream consumers:
   model forward path, training step, loss and validation logic.
3. Config schema:
   typed config modules and runtime config presets.
4. Tests:
   update smoke tests and shape/semantic invariants.

## Related
- Checklist: `ai-docs/checklists.md`
- Playbook: `ai-docs/playbooks/modify-encoder-input.md`
