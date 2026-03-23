---
name: executing-grouped-tasks
description: Use when implementing from an existing grouped OpenSpec tasks artifact or grouped Codex/superpower implementation plan that already declares dependencies, parallelization, complexity, and execution-profile routing, especially before coding starts or when continuing grouped execution in a fresh session. When this skill applies, execute grouped work lane by lane, reusing one delegate across adjacent serialized same-profile groups when the artifact or legacy inference allows it.
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
- `branch suggestion`
- `execution profile`

The `execution profile` must include:

- `model`
- `reasoning_effort`
- `spark_offer`
- `fast_mode`

If any field is missing, stop and return to `grouped-tasks`.

If the artifact explicitly declares serialized delegate reuse, every participating group must also include `serialization lane` and `agent reuse`. Legacy artifacts may omit those fields; inference is allowed only as a backward-compatibility fallback.

If any groups are marked parallel-capable, the active artifact must also include a current `parallel execution trace` section that covers fan-out, merge-group requirements, and where serialization resumes. If that trace is missing or stale, stop and return to `grouped-tasks`.

## Execution Contract

- Execute work at the group level first, not task-by-task across group boundaries.
- Delegation is mandatory when this skill applies.
- Delegate every ready parallel lane to its own implementation subagent or worker instead of implementing grouped work inline in the parent agent.
- Keep group boundaries intact, but allow one long-lived delegate lane to handle 2 or more adjacent serialized groups when reuse is valid.
- If `serialization lane` and `agent reuse` are present, honor them literally.
- If those fields are absent, infer a reusable serialized lane only for legacy artifacts whose adjacent serialized groups share the same resolved execution profile.
- Read each group's `execution profile` literally.
- Treat the declared `model` as the non-fast fallback profile and keep the declared `reasoning_effort` unless the user explicitly overrides it.
- Resolve `fast_mode` before creating the implementation delegation:
  - `inherit` means use fast mode when the parent session is already running in fast mode or the user explicitly asked for fast mode
  - `off` means keep this group on the declared non-fast fallback profile
  - `on` means force fast mode for this group even when the parent session is not already fast
- For legacy inference, the reuse key is the resolved execution profile after that `fast_mode` resolution: `model`, `reasoning_effort`, `spark_offer`, and the active fast-mode state. Any mismatch ends the lane.
- If fast mode is active for the group after that resolution, keep Spark as a separate optional acceleration layer for eligible groups instead of treating fast mode as the final speed setting.
- When a lane's current group is `unknown`, or Spark is selected for that group's implementation path, start that group's work with a scoped explore phase before implementation continues in the lane.
- Never use Spark itself as the explore delegate.
- When a scoped explore phase is required, keep it bounded to repository grounding, current implementation shape, dependency notes, and verification targets. It must not redesign or regroup the plan.
- When a scoped explore phase is required, pass the explore findings into the lane's implementation context so the delegate starts with the relevant files, current findings, dependency notes, and verification expectations instead of rediscovering them.
- When a lane already has enough repository context for its next serialized group, pass the next group brief directly instead of restarting broad exploration.
- If only one lane is ready, delegate that lane anyway; single-lane execution is not an exception.
- If multiple ready lanes are explicitly marked independent, delegate those lanes in parallel only after confirming the artifact's `parallel execution trace`.
- When parallel lanes are delegated, prefer detached worktrees by default unless the user explicitly requested branch-per-group execution.
- If downstream serialized work depends on multiple earlier parallel groups, require the declared merge group to complete before starting that downstream serialized work.
- If `spark_offer` is true, offer Spark only when it is actually worth the tradeoff, including when fast mode is already active for the group.
- If fast mode is requested for a group but unavailable, surface that fallback and continue with the declared non-fast profile for that group.
- Do not ask the lane delegate to perform another broad startup exploration when the grouped plan, plus any scoped explore summary you already produced, already make the work implementation-ready. Escalate only if a concrete blocker remains.
- If the grouped artifact says serialization is required, serialize.
- After delegating a lane, allow at least 10 minutes for startup and exploration before interrupting, killing, or redirecting that agent unless the user explicitly asks for it or a hard blocker or safety issue appears.
- If delegation tooling is unavailable, stop and surface the blocker instead of executing the grouped work locally.

## Review Guard

- Do not invoke `review-pr`, `code-review`, or review-only assets during grouped execution unless the user explicitly requested review or the active plan names an explicit review step.
- Do not treat vague phrases such as "validate quality" or "final checks" as permission to start review.

## Fresh Session Behavior

When a fresh session receives an existing grouped plan:

- read all groups first
- identify which groups are ready and which are blocked
- preserve the declared group boundaries
- resolve each ready group's `fast_mode` against the parent session state and any explicit user fast-mode request before delegating implementation
- if serialized reuse metadata is present, form ready lanes from `serialization lane` plus `agent reuse`
- if serialized reuse metadata is absent, infer ready serialized lanes only for legacy artifacts whose adjacent serialized groups share the same resolved execution profile
- if a lane's current group is `unknown`, or Spark is selected for that group's implementation path, run the lane's scoped explore phase before implementation resumes
- if parallel lanes are ready, confirm the current artifact also includes the `parallel execution trace` and any required merge group before delegating them
- delegate ready lanes using the resolved execution profile
- pass the full group contents for the current lane position, any explore findings, relevant implementation context, dependency notes, and verification expectations into each implementation delegation
- treat early silence as normal exploration and do not interrupt a delegated lane during its first 10 minutes unless the user explicitly requests it or a hard blocker or safety issue appears
- reassess dependencies and lane boundaries after each completed group

## Pre-Execution Check

Before implementation starts:

- inspect the active artifact to determine whether grouped routing already exists
- if grouped routing exists, preserve the artifact and execute it with this skill
- if grouped routing does not exist or is incomplete, stop and repair the artifact with `grouped-tasks`

## Common Mistakes

- Flattening groups into a generic task loop
- Implementing grouped work inline in the parent agent instead of delegating each ready lane
- Skipping the required scoped explore phase for an `unknown` group or Spark-selected implementation path
- Using Spark for the explore delegate
- Forcing a scoped explore phase for implementation-ready known groups that already have sufficient lane context
- Ignoring the declared `execution profile`
- Forgetting to propagate parent fast mode or an explicit user fast-mode request to groups whose `fast_mode` is `inherit`
- Replacing `execution profile` with implementation-agent aliases
- Treating single-lane execution as a reason to skip delegation
- Allowing the lane delegate to restart broad exploration after it already received the grouped plan and explore summary
- Treating fast mode as a reason to stop offering Spark on eligible `medium` or `high` groups
- Reusing a lane because complexity matches even though the resolved execution profile differs
- Ignoring `serialization lane` or `agent reuse` when the artifact already declares them
- Interrupting or killing a delegated lane too early while it is still exploring startup context
- Running review automatically after implementation
- Running groups in parallel when dependencies say not to
- Starting downstream serialized work before the declared merge group completes
