---
name: grouped-tasks
description: "Use when generating or updating grouped OpenSpec task artifacts or grouped multi-step plans, especially during `openspec-new-change`, `openspec-ff-change`, `openspec-continue-change`, `/opsx:new`, `/opsx:ff`, `/opsx:continue`, `writing-plans`, or whenever a flat multi-step plan must be rewritten into explicit task groups."
---

# Grouped Tasks

## Overview

Turn planning output into explicit task groups instead of flat lists.

For OpenSpec `tasks.md`, grouping is additive: preserve the artifact's existing sectioned checklist format and attach the required group metadata without rewriting the task body into a new structure.

**Core principle:** every group must declare its work, dependency shape, execution mode, and implementation routing before execution starts.

This skill shapes grouped artifacts. It does not execute already-grouped work.
Grouped artifacts should be implementation-ready by default. A separate explore handoff is an execution-time tactic only for groups that remain `unknown`.

## Required Output

Never produce a flat task list when this skill applies.

This includes:

- grouped OpenSpec tasks artifacts
- superpower plans
- implementation plans generated from approved design docs
- user-requested multi-step plans
- user-requested multi-step todo lists

Every group must include:

- `goal`
- `tasks`
- `complexity`
- `dependencies`
- `parallelization`
- `recommended agent`

When the artifact is OpenSpec `tasks.md`, keep the `tasks` content in the repository's existing section format, for example:

```markdown
Section 1. CRUD
- 1.1 [ ] Add the create view
```

Add `goal`, `complexity`, `dependencies`, `parallelization`, and `recommended agent` around that section content. Do not replace the section headings or checkbox list with a new task-body format.

Allowed complexity values:

- `low`
- `medium`
- `high`
- `unknown`

`unknown` is valid only when the missing research is stated explicitly.

Implementation-test groups are an explicit planning exception. If a group is primarily about writing, debugging, stabilizing, or unblocking implementation tests, default it to `unknown` unless a similar nearby integration test or fixture path already makes the required generated data, setup flow, and assertions concrete enough to execute without additional research.

## Parallel Analysis

Before implementation starts, include an explicit cross-group analysis that states:

- which groups are independent
- which groups must stay serialized
- what dependency or shared-state constraint causes the ordering
- the resulting execution order

If nothing can run in parallel, say so explicitly.

## Routing

Use this mapping for `recommended agent`:

- `low` -> `@implementation-agent-fast`
- `medium` -> `@implementation-agent-fast`
- `high` -> `@implementation-agent`
- `unknown` -> `@implementation-agent`

Use the literal agent ids above. Do not invent aliases such as `implementation-agent-low`, `implementation-agent-high`, or other derived names.

When an implementation-test group stays `unknown`, name the missing research explicitly, such as fixture discovery, seed data shape, harness setup, or assertion strategy.

**Legacy artifacts:** Older grouped plans may reference `@implementation-agent-spark`, `@implementation-agent-medium`, or `@implementation-agent-thinker`. Treat `@implementation-agent-medium` and `@implementation-agent-spark` as **`@implementation-agent-fast`**, and `@implementation-agent-thinker` as **`@implementation-agent`**, unless you explicitly regenerate the artifact with the routing table above.

Direct delegation is the normal execution path for `low`, `medium`, and `high` groups. Reserve the separate explore handoff for `unknown` groups, even when a legacy artifact references `@implementation-agent-spark`.

## OpenSpec Boundaries

For OpenSpec repositories:

- preserve the existing `tasks.md` section layout and treat grouped metadata as an overlay on top of that layout
- `/openspec-new-change` or `/opsx:new` -> this skill may apply while creating grouped tasks output
- `/openspec-ff-change` or `/opsx:ff` -> this skill may apply while generating all artifacts, if grouped tasks output is being written
- `/openspec-continue-change` or `/opsx:continue` -> this skill may apply while updating the next grouped tasks artifact
- `/openspec-apply-change` or `/opsx:apply` -> this skill does not execute the grouped artifact; hand off to `executing-grouped-tasks` once grouped routing exists
- do not use this skill just because the user mentioned OpenSpec; it applies only when the artifact being written or rewritten must be grouped

## Execution Handoff

If grouped work already exists and the request is to implement or continue implementation:

- stop using this skill for control flow
- preserve the grouped artifact as written
- hand execution to `executing-grouped-tasks`

## Quick Reference

- `openspec-new-change` plus grouped tasks generation -> this skill applies
- `openspec-ff-change` plus grouped tasks generation -> this skill applies
- `openspec-continue-change` plus grouped tasks generation -> this skill applies
- `writing-plans` for multi-step work -> grouped tasks required
- `rewrite this flat plan into groups` -> this skill applies
- `execute this grouped plan` -> use `executing-grouped-tasks`
- single trivial action -> this skill does not apply

## Common Mistakes

- Flat checklist without groups
- Rewriting OpenSpec sectioned checklist tasks into a different task-body format
- Group without complexity
- Group without dependency notes
- Missing cross-group parallelization analysis
- Routing `unknown` to anything except `@implementation-agent`
- Assigning implementation-test groups a concrete complexity before the setup, generated data, and assertion path are grounded in a similar nearby integration test
- Invented agent aliases instead of the literal configured agent ids
- Using `unknown` without naming the missing research
- Planning as if every grouped task needs a separate explore handoff before implementation
- Letting another planning skill return a flat numbered task sequence
- Trying to execute grouped work from this skill instead of handing off

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "It is only a todo list" | Multi-step todos still need grouped execution planning. |
| "Writing-plans already formatted it" | If the result is flat, regroup it before returning it. |
| "The groups are obvious" | If dependencies are not written, the plan is incomplete. |
| "I can add routing later" | Agent routing is part of the plan contract. |
| "Unknown is safer" | `unknown` without missing-research notes is incomplete planning. |
| "Execution can figure it out" | Missing routing in the artifact is a planning failure. |

## Red Flags

- Flat list for multi-step work
- OpenSpec `tasks.md` sections rewritten instead of preserved
- Missing `parallelization`
- Missing `recommended agent`
- More than one complexity per group
- `unknown` with no explanation
- `simple` used as a new-plan complexity level

If any red flag appears, rewrite the plan in grouped form before continuing.
