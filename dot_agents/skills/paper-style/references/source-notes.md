# Source Notes and Provenance

This style profile is a structural distillation. It does not authorize copying
phrases, claims, citations, or technical content from the source papers.

## Initial source set

### MVSNet

- Yao et al., *MVSNet: Depth Inference for Unstructured Multi-view Stereo*,
  ECCV 2018.
- Sources: https://arxiv.org/abs/1804.02505 and
  https://openaccess.thecvf.com/content_ECCV_2018/html/Yao_Yao_MVSNet_Depth_Inference_ECCV_2018_paper.html
- Recurring observations: method-first abstract; computation described in
  execution order; representation choice tied immediately to flexibility;
  method overview mirrors the system diagram; experiments separate benchmark
  performance, generalization, and component ablations.

### R-MVSNet

- Yao et al., *Recurrent MVSNet for High-resolution Multi-view Stereo Depth
  Inference*, CVPR 2019.
- Source: https://arxiv.org/abs/1902.10556
- Recurring observations: progress is acknowledged before one controlling
  limitation is isolated; the limitation is explained by a concrete memory
  mechanism; the replacement operation is contrasted at the same abstraction
  level; the immediate resource consequence leads directly to the scalability
  claim; experiments test quality and scalability separately.

### BlendedMVS

- Yao et al., *BlendedMVS: A Large-scale Dataset for Generalized Multi-view
  Stereo Networks*, CVPR 2020.
- Source: https://arxiv.org/abs/1911.10127
- Recurring observations: the data bottleneck is traced to collection cost;
  dataset construction is narrated as an ordered pipeline; each processing
  step is followed by the property it preserves or adds; the introduction
  moves from benchmark evidence to the generalization gap; experiments compare
  training resources under controlled model choices.

### NeILF

- Yao et al., *NeILF: Neural Incident Light Field for Physically-based Material
  Estimation*, 2022.
- Source: https://arxiv.org/abs/2203.07182
- Recurring observations: the introduction starts from an inverse problem and
  identifies the simplifying assumptions used by prior work; the proposed
  representation is justified by the physical effects it can model; inputs and
  outputs of neural fields are stated directly; ambiguity is explained through
  a concrete degenerate solution before regularization is introduced;
  experimental interpretation returns to representation limits.

## Cross-source synthesis

Patterns promoted into the core profile:

- linear progression from bottleneck to mechanism to design to consequence;
- concrete technical objects and repeated stable terminology;
- procedure described in actual order;
- representation choices justified by the capability they enable;
- experiments organized around distinct claims;
- limited conceptual framing, placed next to the decision it motivates.

Paper-specific choices not promoted as universal rules:

- beginning every abstract with either `We present` or a progress statement;
- using state-of-the-art language;
- fixed contribution counts;
- exact transition phrases;
- grammar and wording characteristic of a particular publication year.

## Adding a source

For each new paper, record:

1. bibliographic identity and stable source URL;
2. the role and progression of each relevant section;
3. repeated sentence-level transitions or explanation patterns;
4. useful deviations from the current profile;
5. whether each observation confirms, refines, or conflicts with a core rule.

Promote a new rule only after cross-source comparison or explicit user
selection.
