---
name: learning-artifact-planner
description: Use when the user wants to add, capture, formalize, or apply agent learnings as a plan. Generate a docs/plans artifact that lists all required changes for project skills, user skills, project AGENTS.md, or user AGENTS.md, includes source references, and reports the saved path and artifact name separately. Do not modify those target guidance files directly.
---

# Learning Artifact Planner

Use this skill to turn approved learnings into a traceable implementation plan. The plan is the handoff artifact; it does not directly change the target skills or `AGENTS.md` files.

## Input Resolution

1. Resolve the requested learning.
   - Treat the primary input as a learning name first.
   - Search the current conversation, feedback analysis output, `.omo/notepads`, `.sisyphus/notepads`, existing `docs/plans`, and relevant review artifacts for that name.
   - If no named learning is found, treat the same input as a path and read it if it exists.
   - If neither name nor path resolves, ask one concise clarification question.

2. Gather source references.
   - Preserve all PR URLs, comment URLs, user messages, diff paths, plan paths, transcript snippets, issue IDs, or command outputs that justify the learning.
   - Do not fabricate references. If a learning has no source reference, mark it blocked until the user provides one.

3. Decide target scope for each learning.
   - `project-skill`: behavior belongs in a repository-specific skill or shared project workflow.
   - `user-skill`: behavior should follow the user across repositories.
   - `project-agents`: behavior belongs in the project `AGENTS.md` or nested project guidance.
   - `user-agents`: behavior belongs in the user-level `AGENTS.md` or global working agreements.
   - `command`: behavior belongs in an OpenCode command wrapper because it is an entry point, not reusable workflow logic.

## Plan Artifact Contract

Create a markdown plan under the current repository root:

```text
docs/plans/YYYY-MM-DD-<learning-name>.md
```

Use the local date. Convert the learning name to short kebab-case. If the file already exists, append `-2`, `-3`, and so on instead of overwriting.

The plan must include:

```markdown
# <Human Learning Name> Learning Plan

## Goal
One sentence describing the learning outcome.

## Source References
- [reference label](reference URL or path) - what it proves

## Classification
| Learning | Scope | Target | Confidence | Reason |
| --- | --- | --- | --- | --- |

## Required Changes
### Project Skills
- Create/update: `path`
- Change needed:
- Source reference:

### User Skills
- Create/update: `path`
- Change needed:
- Source reference:

### Project AGENTS.md
- Create/update: `path`
- Change needed:
- Source reference:

### User AGENTS.md
- Create/update: `path`
- Change needed:
- Source reference:

### Commands
- Create/update: `path`
- Change needed:
- Source reference:

## Execution Steps
1. The ordered implementation steps needed to apply the learning later.

## Verification
- How to verify each target was updated correctly.

## Open Questions
- Any unresolved decision, or `None`.
```

Omit a target subsection only when it is clearly not applicable. Keep source references attached to every proposed target change.

## Final Output Contract

After writing the plan, respond with these separate lines:

```text
Path: docs/plans/YYYY-MM-DD-<learning-name>.md
Name: <Human Learning Name> Learning Plan
```

Then include a short summary of the scopes covered and any blocked items.

## Guardrails

- Do not edit project skills, user skills, project `AGENTS.md`, user `AGENTS.md`, or command files directly from this skill.
- Do not turn low-confidence feedback into mandatory rules without marking the decision for user approval.
- Do not combine unrelated learnings into one plan just because they came from the same PR.
- Do not overwrite an existing plan artifact.
- Do not force-add or commit `docs/plans` artifacts when that directory is gitignored unless the user explicitly requests it.
