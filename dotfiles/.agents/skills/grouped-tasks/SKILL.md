---
name: grouped-tasks
description: Use when generating or rewriting grouped OpenSpec task artifacts, superpower plans, or Codex/OpenCode/Cursor multi-step implementation plans so the output carries explicit dependencies, routing, and separated test lanes before execution starts.
---

# Grouped Tasks

Turn multi-step implementation work into explicit task groups instead of flat lists.

This skill shapes grouped artifacts. It does not execute them.
Implementation work and test/coverage work must always be planned as separate groups.

## Automatic Trigger Cases

Use this skill automatically when the active work is any of the following:

- OpenSpec task artifact creation or update where grouped tasks output is being written or repaired
- superpower plan creation or rewrite for implementation work
- Codex, OpenCode, or Cursor multi-step implementation planning, including user-requested plans or todo lists that will drive execution
- any flat implementation plan that must be regrouped before coding begins

If the grouped artifact already exists and implementation is about to start, stop using this skill and hand off to `executing-grouped-tasks`.

## Required Output

Never produce a flat task list when this skill applies.

Every group must include:

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

The Codex `execution profile` must declare:

- `model`
- `reasoning_effort`

OpenCode and Cursor grouped artifacts must include:

- `recommended agent`

Codex grouped artifacts must not emit `recommended agent`.
OpenCode and Cursor grouped artifacts must not emit `execution profile`.

`project scope` must name the repo, submodule, or other independently versioned workspace slice that group changes. Use stable identifiers such as a repo name or submodule path.

When 2 or more adjacent groups stay serialized and are intended to reuse one implementation delegate, each participating group must also include:

- `serialization lane`
- `agent reuse`

`agent reuse` must be one of:

- `start`
- `continue`
- `none`

If any groups can run in parallel, the artifact must also include a `parallel execution trace` section that shows the fan-out, each group's `project scope`, whether each downstream fan-in requires a merge group or only upstream completion, the point where serialization resumes, and the default detached worktree recommendation for each parallel group unless the user explicitly asked for branch-per-group execution.

When the artifact is OpenSpec `tasks.md`, keep the repository's existing sectioned task format. Add the grouped metadata around the current section body instead of rewriting the task body into a new structure.

## Routing Contract

Use fixed main execution routing for new grouped artifacts.

For Codex:

- every `implementation` group uses `model: gpt-5.3-codex`
- every `implementation` group uses `reasoning_effort: medium`
- every `test/coverage` group uses the same main `execution profile`

For OpenCode and Cursor:

- every `implementation` group uses `recommended agent: @implementation-agent`
- every `test/coverage` group uses the same main `recommended agent`

Before any `test/coverage` lane executes, `executing-grouped-tasks` must run the `test-setup-explorer` prepass.
That prepass is execution-time context gathering, not a group-routing field.

Use this test-setup-explorer mapping:

- Codex: `model: gpt-5.4-mini`, `reasoning_effort: high`
- OpenCode: `@test-setup-explorer`
- Cursor: `@test-setup-explorer`

New grouped artifacts must not emit deprecated OpenCode implementation agents such as `@implementation-agent-fast`, `@implementation-agent-medium`, `@implementation-agent-spark`, or `@implementation-agent-thinker`.
Do not emit Spark offers, fast-mode metadata, or complexity-based routing.

## Serialized Reuse

When 2 or more adjacent groups must stay serialized, reuse one implementation lane only when they keep the same work type and the same literal routing field.

For Codex, compare the literal `execution profile`.
For OpenCode and Cursor, compare the literal `recommended agent`.

When reuse applies:

- give every participating group the same `serialization lane`
- mark the first group in that lane with `agent reuse: start`
- mark each later group in that lane with `agent reuse: continue`
- use `agent reuse: none` when a serialized group intentionally starts a fresh lane

Stop the lane at any work-type change, routing mismatch, dependency break, parallel fan-out or fan-in boundary, or merge group.

Serialized-lane reuse is additive. Keep each group as its own execution unit and preserve the declared dependencies and ordering.

## Parallel Analysis

Before implementation starts, include explicit cross-group analysis that states:

- which groups are independent
- which groups must stay serialized
- what dependency or shared-state constraint causes the ordering
- the resulting execution order
- which `project scope` belongs to each group
- which branch suggestion belongs to each group
- which serialized groups share the same implementation lane
- which parallel groups should use detached worktrees by default

If later serialized work depends on two or more earlier parallel groups, use `project scope` to decide the fan-in gate. Insert a dedicated merge group only when the upstream groups share the same `project scope` and downstream work needs their combined branch state. When the upstream groups have different `project scope` values and no shared merge is required, do not invent a merge group. Make the downstream group wait for upstream completion only.

If nothing can run in parallel, say so explicitly and skip the parallel execution trace.

## Output Shape

Use a compact grouped format like this for Codex:

```markdown
### Group 1

- goal: Implement the review entrypoint
- tasks:
  - Add the review entrypoint
  - Wire the follow-up validation flow
- work type: implementation
- dependencies: none
- parallelization: can run in parallel with Group 2
- project scope: `app-repo`
- branch suggestion: `feat/review-entrypoint`
- execution profile:
  - model: gpt-5.3-codex
  - reasoning_effort: medium
```

For OpenCode and Cursor, use the same format but replace `execution profile` with `recommended agent: @implementation-agent`.

For any test/coverage group, extend the format like this:

```markdown
### Group 2

- goal: Add integration coverage for the review flow
- tasks:
  - Add the integration test
  - Cover the main success path and failure path
- work type: test/coverage
- test scope: integration
- dependencies: Group 1
- parallelization: serialized after Group 1
- project scope: `app-repo`
- branch suggestion: `feat/review-tests`
- execution profile:
  - model: gpt-5.3-codex
  - reasoning_effort: medium
```

When parallel work exists, add a compact trace like this:

```markdown
### Parallel Execution Trace

- fan-out: Group 1 || Group 2
- scopes: Group 1 -> `frontend`, Group 2 -> `backend`
- isolation: create detached worktrees for Group 1 and Group 2 by default
- fan-in gate: completion only after Group 1 and Group 2
- resume serialization: Group 3 starts after both groups complete
```

When same-scope fan-in needs integration before downstream work, replace the `fan-in gate` line with a merge-required form such as `fan-in gate: Group 3 merges Group 1 and Group 2 inside app-repo` and resume serialization after that merge group completes.

## Boundaries

- Use this skill for grouped implementation planning, not brainstorming.
- Use this skill when the work is implementation-oriented and multi-step.
- Do not wait for an explicit skill mention when the request is OpenSpec artifact creation, superpower planning, or implementation planning that should produce grouped work.
- If the grouped artifact already exists and the request is to execute it, hand off to `executing-grouped-tasks`.
- Keep implementation and test/coverage work in separate groups.
- Do not emit review steps unless the user explicitly requested review or the provided plan already includes one.

## Common Mistakes

- Flat task lists
- Mixing implementation and test/coverage work in the same group
- Missing `test scope` on a `test/coverage` group
- Missing the tool-specific routing field
- Emitting `recommended agent` in Codex grouped artifacts
- Emitting `execution profile` in OpenCode or Cursor grouped artifacts
- Missing `project scope`
- Missing `branch suggestion`
- Missing `parallel execution trace` when parallel work exists
- Missing `serialization lane` or `agent reuse` on a serialized reuse chain
- Emitting deprecated OpenCode implementation agents in new grouped artifacts
- Using `test-setup-explorer` as the main group-routing field instead of an execution-time prepass
- Reusing a lane across a work-type boundary
- Carrying the same lane across a dependency break, merge group, or parallel boundary
- Omitting the merge group when same-`project scope` downstream fan-in needs one
- Inventing a merge group when cross-`project scope` completion-only fan-in is sufficient
- Trying to execute grouped work from this skill instead of handing off
