# Write Unit Tests Playbook

AI-PLAYBOOK: WRITE-UNIT-TESTS

## SOP
1. Read context first.
   - Map: nearest relevant `ai-docs/map/**/_index.md`
   - Contracts: `ai-docs/contracts/interfaces.md`, `ai-docs/contracts/io.md`, `ai-docs/contracts/datasets.md`
2. Define invariants before coding.
   - Shapes/dtypes and key semantic expectations.
   - Error behavior for invalid inputs.
3. Place tests close to current patterns.
   - Reuse existing fixture style and naming.
4. Cover both positive and negative paths.
   - At least one realistic success case.
   - At least one failure/sanity-check case.
5. Run focused tests first, then full suite when feasible.

## Exit checklist
- Tests exercise the changed boundary, not only happy-path internals.
- Interface and contract changes are reflected in tests.
- Commands run and outcomes recorded in task log.

## Related
- Commands: `ai-docs/commands.md`
- Checklists: `ai-docs/checklists.md`
