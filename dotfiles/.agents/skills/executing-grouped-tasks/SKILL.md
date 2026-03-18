---
name: executing-grouped-tasks
description: Use when implementing from an existing grouped OpenSpec tasks artifact or grouped Codex/superpower implementation plan that already declares dependencies, parallelization, complexity, and execution-profile routing, especially before coding starts or when continuing grouped execution in a fresh session. When this skill applies, first run a scoped explore delegation for each ready group, then delegate implementation using the literal declared execution profile instead of implementing the grouped work inline.
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
- `fast_mode`

If any field is missing, stop and return to `grouped-tasks`.

## Execution Contract

- Execute work at the group level first, not task-by-task across group boundaries.
- Delegation is mandatory when this skill applies.
- Before implementation starts for a ready group, send a scoped explore delegate to gather the execution-critical repository context that the implementation delegate needs.
- Delegate every ready group to its own implementation subagent or worker instead of implementing grouped work inline in the parent agent.
- Read each group's `execution profile` literally.
- Treat the declared `model` as the non-fast fallback profile and keep the declared `reasoning_effort` unless the user explicitly overrides it.
- Resolve `fast_mode` before creating the implementation delegation:
  - `inherit` means use fast mode when the parent session is already running in fast mode or the user explicitly asked for fast mode
  - `off` means keep this group on the declared non-fast fallback profile
  - `on` means force fast mode for this group even when the parent session is not already fast
- If fast mode is active for the group after that resolution, keep Spark as a separate optional acceleration layer for eligible groups instead of treating fast mode as the final speed setting.
- Keep the explore pass bounded to repository grounding, current implementation shape, dependency notes, and verification targets. It must not redesign or regroup the plan.
- Pass the explore findings into the implementation delegation so the implementation agent starts with the relevant files, current findings, dependency notes, and verification expectations instead of rediscovering them.
- If only one group is ready, delegate that group anyway; single-group execution is not an exception.
- If multiple ready groups are explicitly marked independent, delegate those groups in parallel.
- If `spark_offer` is true, offer Spark only when it is actually worth the tradeoff, including when fast mode is already active for the group.
- If fast mode is requested for a group but unavailable, surface that fallback and continue with the declared non-fast profile for that group.
- Do not ask the implementation delegate to perform another broad startup exploration when the grouped plan and explore summary already make the work implementation-ready. Escalate only if a concrete blocker remains after the scoped explore pass.
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
- run a scoped explore delegation for each ready group before delegating implementation for that group
- resolve each ready group's `fast_mode` against the parent session state and any explicit user fast-mode request before delegating implementation
- delegate ready groups using the resolved execution profile
- pass the full group contents, explore findings, relevant implementation context, dependency notes, and verification expectations into each implementation delegation
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
- Skipping the scoped explore prepass and forcing the implementation delegate to rediscover repository context
- Ignoring the declared `execution profile`
- Forgetting to propagate parent fast mode or an explicit user fast-mode request to groups whose `fast_mode` is `inherit`
- Replacing `execution profile` with implementation-agent aliases
- Treating single-group execution as a reason to skip delegation
- Allowing the implementation delegate to restart broad exploration after it already received the grouped plan and explore summary
- Treating fast mode as a reason to stop offering Spark on eligible groups
- Interrupting or killing a delegated group too early while it is still exploring startup context
- Running review automatically after implementation
- Running groups in parallel when dependencies say not to
