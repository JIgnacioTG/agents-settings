---
name: openspec-workflow
description: Use for OpenSpec explore, proposal/design/tasks artifact creation or updates, and OpenSpec artifact summaries. Ensures open questions are surfaced before generation, provided Notion or Linear source links are recorded in proposal.md, and final output highlights the generated artifacts.
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
- When creating or updating `proposal.md`, preserve any Notion card, Linear issue, ticket, card, issue, task, or project-management URL/reference provided by the user, prompt context, command arguments, or fetched source material.
- Add those references to `proposal.md` in a dedicated `## Source References` section near the top of the proposal, after the summary/problem statement and before detailed scope or impact sections.
- Use markdown links when a title and URL are available, such as `- [Linear ABC-123](https://linear.app/...)` or `- [Notion card](https://www.notion.so/...)`; use a plain reference when only an ID or title is available.
- If no Notion or Linear reference is provided, do not fabricate one and do not add an empty `## Source References` section.
- When creating or updating `tasks.md`, produce grouped execution work when the change spans multiple implementation areas.
- Each task group must make dependencies, ordering, parallelization, and remaining risks clear.

## Final Output Contract

After generating or updating OpenSpec artifacts, include a short summary with:

- `proposal.md`: problem, outcome, source references captured from Notion or Linear when provided, scope, and impact highlights.
- `design.md`: key decisions, trade-offs, and risks, or state that no design file exists.
- `tasks.md`: execution order, major task groups, dependencies, and verification steps.
- Remaining open questions or doubts, if any.
- Exact artifact paths that were created or changed.

OpenSpec artifact work is not complete if the final response omits the proposal/design/tasks highlights, drops provided Notion or Linear references from `proposal.md`, or hides unresolved questions.
