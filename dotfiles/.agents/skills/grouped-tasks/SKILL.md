---
name: grouped-tasks
description: Use when generating or rewriting grouped OpenSpec task artifacts, superpower plans, or Codex multi-step implementation plans so the output carries explicit complexity, dependencies, parallelization, and execution-profile routing before execution starts.
---

# Grouped Tasks

Turn multi-step implementation work into explicit task groups instead of flat lists.

This skill shapes grouped implementation artifacts. It does not execute them.

## Automatic Trigger Cases

Use this skill automatically when the active work is any of the following:

- OpenSpec task artifact creation or update where grouped tasks output is being written or repaired
- superpower plan creation or rewrite for implementation work
- Codex multi-step implementation planning, including user-requested plans or todo lists that will drive execution
- any flat implementation plan that must be regrouped before coding begins

If the grouped artifact already exists and implementation is about to start, stop using this skill and hand off to `executing-grouped-tasks`.

## Required Output

Never produce a flat task list when this skill applies.

Every group must include:

- `goal`
- `tasks`
- `complexity`
- `dependencies`
- `parallelization`
- `execution profile`

The `execution profile` must declare:

- `model`
- `reasoning_effort`
- `spark_offer`
- `fast_mode`

Allowed Codex complexity values:

- `low`
- `medium`
- `high`
- `unknown`

`simple` is not valid on the Codex side.

`unknown` is valid only when the missing research is named explicitly.

## Routing Contract

Use this mapping unless the user explicitly overrides it:

- `low` -> `gpt-5.4-mini`, `reasoning_effort: medium`, `spark_offer: false`
- `medium` -> `gpt-5.3-codex`, `reasoning_effort: medium`, `spark_offer: true`
- `high` -> `gpt-5.3-codex`, `reasoning_effort: high`, `spark_offer: true`
- `unknown` -> `gpt-5.4`, `reasoning_effort: xhigh`, `spark_offer: false`

Treat that mapping as the non-fast fallback profile. Set `fast_mode: inherit` by default for every group unless the user explicitly overrides fast-mode behavior for that group.

`fast_mode` must be one of:

- `inherit` to use fast mode when the parent session is already running in fast mode or the user explicitly asks for fast mode
- `off` to keep this group on the declared non-fast fallback profile even when fast mode is active elsewhere
- `on` to force fast mode for this group even when the parent session is not already fast

Implementation-test groups are an explicit planning exception. If a group is primarily about writing, debugging, stabilizing, or unblocking implementation tests, default it to `complexity: unknown` unless a similar nearby integration test or fixture path already makes the required generated data, setup flow, and assertions concrete enough to execute without additional research.

When an implementation-test group stays `unknown`, name the missing research explicitly, such as fixture discovery, seed data shape, harness setup, or assertion strategy.

Use `gpt-5.4` only when the work is still unclear, research-heavy, not implementation-ready, or the implementation-test group still needs research before its setup and data generation are concrete.

Spark is optional. Offer it only for `medium` or `high` groups where faster execution is worth the tradeoff, including when fast mode is already active or the user explicitly requested fast mode, because Spark can still be faster than regular fast mode.

When the parent session is already in fast mode or the user explicitly requests fast mode, plan every group with `fast_mode: inherit` by default, including `low` and `unknown` groups. Only set `fast_mode: off` when the user explicitly opts a group out.

## Parallel Analysis

Before implementation starts, include explicit cross-group analysis that states:

- which groups are independent
- which groups must stay serialized
- what dependency or shared-state constraint causes the ordering
- the resulting execution order

If nothing can run in parallel, say so explicitly.

## Output Shape

Use a compact grouped format like this:

```markdown
### Group 1

- goal: Implement the review entrypoint
- tasks:
  - Add the Codex review skill
  - Wire the review-only assets it needs
- complexity: high
- dependencies: none
- parallelization: can run in parallel with Group 2
- execution profile:
  - model: gpt-5.3-codex
  - reasoning_effort: high
  - spark_offer: true
  - fast_mode: inherit
```

## Boundaries

- Use this skill for grouped implementation planning, not brainstorming.
- Use this skill when the work is implementation-oriented and multi-step.
- Do not wait for an explicit skill mention when the request is OpenSpec artifact creation, superpower planning, or Codex implementation planning that should produce grouped work.
- If the grouped artifact already exists and the request is to execute it, hand off to `executing-grouped-tasks`.
- Do not emit review steps unless the user explicitly requested review or the provided plan already includes one.

## Common Mistakes

- Flat task lists
- Emitting `simple`
- Missing `execution profile`
- Missing `fast_mode`
- Using `recommended agent`
- Using `unknown` without naming the missing research
- Offering Spark for `low` or `unknown`
- Forgetting that parent fast mode or an explicit user fast-mode request should propagate to every group by default
- Treating fast mode as a reason to stop offering Spark on eligible `medium` or `high` groups
- Assigning implementation-test groups a concrete complexity before the setup, generated data, and assertion path are grounded in a similar nearby integration test
- Treating `gpt-5.4` as the default for planned implementation
