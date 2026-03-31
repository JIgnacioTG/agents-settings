---
name: executing-grouped-tasks
description: Use when implementing from an existing grouped OpenSpec tasks artifact or grouped Codex/OpenCode/Cursor implementation plan that already declares dependencies, routing, and separated test lanes. When this skill applies, execute grouped work lane by lane and run the test-setup explorer before any test lane starts.
---

# Executing Grouped Tasks

Execute grouped implementation work group by group without flattening it into a generic task loop.

## Automatic Trigger Cases

Use this skill automatically when the active artifact is already grouped and work is moving into implementation, for example:

- coding from an existing grouped OpenSpec tasks file
- coding from an approved grouped superpower plan
- coding from a grouped Codex, OpenCode, or Cursor implementation plan
- continuing grouped execution in a fresh session

Before writing code or delegating implementation, check whether the active artifact is already grouped. If it is, this skill owns execution. If it is not, return to `grouped-tasks`.

## Preconditions

Before execution starts, every group must include:

- `goal`
- `tasks`
- `work type`
- `dependencies`
- `parallelization`
- `project scope`
- `branch suggestion`

`work type` must be one of:

- `implementation`
- `test/coverage`

Any `test/coverage` group must also include:

- `test scope`

`test scope` must be one of:

- `unit`
- `integration`
- `e2e`

Codex grouped artifacts must include:

- `execution profile`

The Codex `execution profile` must include:

- `model`
- `reasoning_effort`

OpenCode and Cursor grouped artifacts must include:

- `recommended agent`

If any field is missing, stop and return to `grouped-tasks`.

If the artifact explicitly declares serialized delegate reuse, every participating group must also include `serialization lane` and `agent reuse`. Legacy artifacts may omit those fields. Inference is allowed only as a backward-compatibility fallback.

If any groups are marked parallel-capable, the active artifact must also include a current `parallel execution trace` section that covers fan-out, each group's `project scope`, the fan-in gate type for downstream work, and where serialization resumes. If that trace is missing or stale, stop and return to `grouped-tasks`.

Legacy artifacts that still depend on `complexity`, `fast_mode`, `spark_offer`, or deprecated OpenCode implementation-agent variants must be repaired with `grouped-tasks` before execution continues.

## Routing Contract

Read the active artifact literally.

- Codex groups execute with `execution profile` and must not rely on `recommended agent`.
- OpenCode and Cursor groups execute with `recommended agent` and must not rely on `execution profile`.
- New grouped artifacts should route both `implementation` and `test/coverage` groups through the same main implementation route:
  - Codex: `gpt-5.3-codex` with `reasoning_effort: medium`
  - OpenCode: `@implementation-agent`
  - Cursor: `@implementation-agent`

Before any `test/coverage` lane starts, run the `test-setup-explorer` prepass:

- Codex: `gpt-5.4-mini` with `reasoning_effort: high`
- OpenCode: `@test-setup-explorer`
- Cursor: `@test-setup-explorer`

Pass the test-setup findings into the downstream implementation delegate for that test lane.

## Execution Contract

- Execute work at the group level first, not task-by-task across group boundaries.
- Delegation is mandatory when this skill applies.
- Delegate every ready parallel lane to its own implementation subagent or worker instead of implementing grouped work inline in the parent agent.
- Keep group boundaries intact, but allow one long-lived delegate lane to handle 2 or more adjacent serialized groups when reuse is valid.
- If `serialization lane` and `agent reuse` are present, honor them literally.
- If those fields are absent, infer a reusable serialized lane only for legacy artifacts whose adjacent serialized groups share the same work type and the same literal routing field.
- For Codex, compare the literal `execution profile`.
- For OpenCode and Cursor, compare the literal `recommended agent`.
- Delegate every `implementation` group directly with the declared main route.
- Before any `test/coverage` group executes, run the `test-setup-explorer` prepass for that lane.
- Keep the `test-setup-explorer` pass bounded to implementation analysis, existing test analysis, reusable fixtures and factories, reusable seeds and helpers, harness setup, and missing setup assets that must be created.
- Pass the `test-setup-explorer` findings into the lane's main implementation context so the downstream delegate starts with the relevant files, setup findings, dependency notes, and verification expectations instead of rediscovering them.
- When a lane already has enough repository context for its next serialized group, pass the next group brief directly instead of restarting broad exploration.
- When a lane already has valid `test-setup-explorer` findings for the next serialized `test/coverage` group, reuse them instead of rerunning the prepass.
- Rerun the `test-setup-explorer` prepass when the `project scope`, `test scope`, or dependency boundary changes the setup requirements materially.
- If only one lane is ready, delegate that lane anyway. Single-lane execution is not an exception.
- If multiple ready lanes are explicitly marked independent, delegate those lanes in parallel only after confirming the artifact's `parallel execution trace`.
- When parallel lanes are delegated, prefer detached worktrees by default unless the user explicitly requested branch-per-group execution.
- If downstream serialized work depends on multiple earlier parallel groups in the same `project scope`, require the declared merge group to complete before starting that downstream serialized work.
- If that fan-in spans different `project scope` values and the artifact marks it completion-only, wait for the upstream groups to finish and then continue without merge orchestration.
- If a parallel fan-in exists but the artifact does not make the gate explicit, stop and repair the artifact with `grouped-tasks`.
- Do not ask the lane delegate to perform another broad startup exploration when the grouped plan, plus any `test-setup-explorer` findings you already produced, already make the work implementation-ready. Escalate only if a concrete blocker remains.
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
- if serialized reuse metadata is present, form ready lanes from `serialization lane` plus `agent reuse`
- if serialized reuse metadata is absent, infer ready serialized lanes only for legacy artifacts whose adjacent serialized groups share the same work type and the same literal routing field
- if a lane's current group is `test/coverage`, run the lane's `test-setup-explorer` prepass before implementation resumes
- if parallel lanes are ready, confirm the current artifact also includes the `parallel execution trace` and the correct same-scope merge or cross-scope completion gate before delegating them
- delegate ready lanes using the declared tool-specific route
- pass the full group contents for the current lane position, any `test-setup-explorer` findings, relevant implementation context, dependency notes, and verification expectations into each implementation delegation
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
- Skipping the required `test-setup-explorer` prepass for a `test/coverage` lane
- Using `test-setup-explorer` as the main execution delegate instead of the setup prepass
- Ignoring the declared tool-specific routing field
- Missing or ignoring `project scope` on grouped execution
- Emitting or relying on deprecated OpenCode implementation agents during new grouped execution
- Treating single-lane execution as a reason to skip delegation
- Allowing the lane delegate to restart broad exploration after it already received the grouped plan and `test-setup-explorer` summary
- Reusing a lane across a work-type boundary
- Ignoring `serialization lane` or `agent reuse` when the artifact already declares them
- Interrupting or killing a delegated lane too early while it is still exploring startup context
- Running review automatically after implementation
- Running groups in parallel when dependencies say not to
- Starting same-`project scope` downstream serialized work before the declared merge group completes
- Forcing merge handling when cross-`project scope` fan-in is explicitly completion-only
