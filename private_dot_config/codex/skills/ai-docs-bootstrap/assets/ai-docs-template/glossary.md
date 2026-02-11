# Glossary

AI-MAP: GLOSSARY

## Input
Definition: Typed payload consumed by a model stage.
Canonical type/location: `src/<package>/models/<module>/types.py`.
Common aliases: `context`, `inputs`.

## Sample
Definition: Single training item emitted by a dataset iterator.
Canonical type/location: `src/<package>/datasets/types.py`.
Common aliases: `item`, `example`.

## Batch
Definition: Collated multi-sample structure consumed by the training step.
Canonical type/location: `src/<package>/datasets/types.py` and collate function.
Common aliases: `mini-batch`.

## Dataset Config
Definition: Structured config used by registry/build logic to instantiate datasets.
Canonical type/location: `src/<package>/datasets/config.py`.
Common aliases: `dataset cfg`, `data config`.

## Loss Input
Definition: Unified payload passed to each loss module.
Canonical type/location: `src/<package>/losses/types.py`.
Common aliases: `loss payload`.
