---
name: openspec-workflow
description: Use for OpenSpec explore, proposal/design/tasks artifact creation or updates, and OpenSpec artifact summaries. Ensures open questions are surfaced before generation and final output highlights the generated artifacts.
---

# OpenSpec Workflow

Use this skill whenever working on OpenSpec explore or creating/updating OpenSpec artifacts such as `proposal.md`, `design.md`, `tasks.md`, or delta specs.

## Explore Contract

- Gather the relevant existing specs, active changes, project context, and related implementation patterns before proposing artifact content.
- Surface open questions, doubts, missing requirements, trade-offs, assumptions, and risky ambiguities explicitly.
- Continue exploration until the change feels technically solid enough to generate artifacts.
- If uncertainty remains after exploration, stop before artifact generation and ask the smallest concrete set of questions needed to unblock the change.
- Do not hide uncertainty in implementation tasks; record remaining questions where the user can act on them.

## Artifact Generation Contract

- Follow the project OpenSpec schema and the instructions from the active OpenSpec command or CLI output.
- Keep proposal, design, specs, and tasks consistent with one another.
- When creating or updating `tasks.md`, produce grouped execution work when the change spans multiple implementation areas.
- Each task group must make dependencies, ordering, parallelization, and remaining risks clear.

## Final Output Contract

After generating or updating OpenSpec artifacts, include a short summary with:

- `proposal.md`: problem, outcome, scope, and impact highlights.
- `design.md`: key decisions, trade-offs, and risks, or state that no design file exists.
- `tasks.md`: execution order, major task groups, dependencies, and verification steps.
- Remaining open questions or doubts, if any.
- Exact artifact paths that were created or changed.

OpenSpec artifact work is not complete if the final response omits the proposal/design/tasks highlights or hides unresolved questions.
