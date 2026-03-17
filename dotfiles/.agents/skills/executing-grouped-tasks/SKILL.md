---
name: executing-grouped-tasks
description: Use when implementing from an already-grouped Codex plan that declares dependencies, parallelization, complexity, and execution-profile routing.
---

# Executing Grouped Tasks

Execute grouped implementation work group by group without flattening it into a generic task loop.

## Preconditions

Before execution starts, every group must include:

- `goal`
- `tasks`
- `complexity`
- `dependencies`
- `parallelization`
- `execution profile`

The `execution profile` must include:

- `model`
- `reasoning_effort`
- `spark_offer`

If any field is missing, stop and return to `grouped-tasks`.

## Execution Contract

- Execute work at the group level first, not task-by-task across group boundaries.
- Read each group's `execution profile` literally.
- Use the declared model and reasoning effort directly instead of inventing implementation-agent names.
- If Spark is offered for the group, offer it to the user only when it is actually worth the tradeoff.
- If Spark is unavailable or declined, continue with the declared non-Spark profile for that group.
- If multiple ready groups are explicitly marked independent, parallel execution is allowed.
- If the grouped artifact says serialization is required, serialize.

## Review Guard

- Do not invoke `review-pr`, `code-review`, or review-only assets during grouped execution unless the user explicitly requested review or the active plan names an explicit review step.
- Do not treat vague phrases such as "validate quality" or "final checks" as permission to start review.

## Fresh Session Behavior

When a fresh session receives an existing grouped plan:

- read all groups first
- identify which groups are ready and which are blocked
- preserve the declared group boundaries
- execute ready groups using the declared `execution profile`
- reassess dependencies after each completed group

## Common Mistakes

- Flattening groups into a generic task loop
- Ignoring the declared `execution profile`
- Replacing `execution profile` with implementation-agent aliases
- Running review automatically after implementation
- Running groups in parallel when dependencies say not to
