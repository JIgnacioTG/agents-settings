---
name: executing-grouped-tasks
description: Use when implementing from an existing grouped OpenSpec tasks artifact or grouped Codex/superpower implementation plan that already declares dependencies, parallelization, complexity, and execution-profile routing, especially before coding starts or when continuing grouped execution in a fresh session. When this skill applies, delegate each ready group to a subagent using the literal declared execution profile instead of implementing the grouped work inline.
---

# Executing Grouped Tasks

Execute grouped implementation work group by group without flattening it into a generic task loop.

## Automatic Trigger Cases

Use this skill automatically when the active artifact is already grouped and work is moving into implementation, for example:

- coding from an existing grouped OpenSpec tasks file
- coding from an approved grouped superpower plan
- coding from a grouped Codex implementation plan
- continuing grouped execution in a fresh session

Before writing code or delegating implementation, check whether the active artifact is already grouped. If it is, this skill owns execution. If it is not, return to `grouped-tasks`.

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
- Delegation is mandatory when this skill applies.
- Delegate every ready group to its own subagent or worker instead of implementing grouped work inline in the parent agent.
- Read each group's `execution profile` literally.
- Use the declared model and reasoning effort directly when creating that delegation instead of inventing implementation-agent names.
- Give each delegated group enough implementation context to avoid redundant startup exploration, including the relevant files, current findings, dependency notes, and verification expectations already known by the parent agent.
- If only one group is ready, delegate that group anyway; single-group execution is not an exception.
- If multiple ready groups are explicitly marked independent, delegate those groups in parallel.
- If Spark is offered for the group, offer it to the user only when it is actually worth the tradeoff.
- If Spark is unavailable or declined, continue with the declared non-Spark profile for that group.
- If the grouped artifact says serialization is required, serialize.
- After delegating a group, allow at least 10 minutes for startup and exploration before interrupting, killing, or redirecting that agent unless the user explicitly asks for it or a hard blocker or safety issue appears.
- If delegation tooling is unavailable, stop and surface the blocker instead of executing the grouped work locally.

## Review Guard

- Do not invoke `review-pr`, `code-review`, or review-only assets during grouped execution unless the user explicitly requested review or the active plan names an explicit review step.
- Do not treat vague phrases such as "validate quality" or "final checks" as permission to start review.

## Fresh Session Behavior

When a fresh session receives an existing grouped plan:

- read all groups first
- identify which groups are ready and which are blocked
- preserve the declared group boundaries
- delegate ready groups using the declared `execution profile`
- pass the full group contents, relevant implementation context, dependency notes, and verification expectations into each delegation
- treat early silence as normal exploration and do not interrupt a delegated group during its first 10 minutes unless the user explicitly requests it or a hard blocker or safety issue appears
- reassess dependencies after each completed group

## Pre-Execution Check

Before implementation starts:

- inspect the active artifact to determine whether grouped routing already exists
- if grouped routing exists, preserve the artifact and execute it with this skill
- if grouped routing does not exist or is incomplete, stop and repair the artifact with `grouped-tasks`

## Common Mistakes

- Flattening groups into a generic task loop
- Implementing grouped work inline in the parent agent instead of delegating each ready group
- Ignoring the declared `execution profile`
- Replacing `execution profile` with implementation-agent aliases
- Treating single-group execution as a reason to skip delegation
- Interrupting or killing a delegated group too early while it is still exploring startup context
- Running review automatically after implementation
- Running groups in parallel when dependencies say not to
