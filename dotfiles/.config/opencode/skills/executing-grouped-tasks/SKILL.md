---
name: executing-grouped-tasks
description: "Use when implementing from an already-grouped `tasks.md` or grouped multi-step plan with explicit dependencies, parallelization, or `recommended agent` routing, especially after `openspec-apply-change` or `/opsx:apply` has selected the change, or when a fresh session is asked to continue grouped execution."
---

# Executing Grouped Tasks

## Overview

Execute already-grouped work group by group without flattening it back into a generic task loop.

**Core principle:** once grouped routing exists, the groups become the execution contract.

## Preconditions

Before execution starts, the active grouped artifact must include:

- `goal`
- `tasks`
- `complexity`
- `dependencies`
- `parallelization`
- `recommended agent`

If any field is missing, stop and return to `grouped-tasks` to repair the artifact before implementing.

## Precedence

This skill sits below workflow-selection skills and above generic execution skills.

- `openspec-apply-change` or `/opsx:apply` selects the change and loads OpenSpec apply context first
- once the active tasks artifact is grouped with routing metadata, this skill owns execution
- do not start with `subagent-driven-development` when grouped routing already exists
- do not start with `executing-plans` when grouped routing already exists
- if another workflow would flatten grouped work into a generic per-task loop, stop and preserve the grouped contract

## Fresh-Session Execution

When a new session receives an existing grouped plan or grouped OpenSpec tasks file:

- read all groups before starting implementation
- preserve existing group boundaries unless the user explicitly asks to rewrite them
- identify which groups are ready now and which are blocked by dependencies
- delegate each ready group to the literal `recommended agent` named in that group
- pass the full group text, dependency notes, and verification expectations into that delegation
- after a group completes, reassess dependency state before starting newly unblocked groups
- if multiple ready groups are independent and the grouped artifact says they can run in parallel, parallel execution is allowed; otherwise serialize

## Execution Contract

- grouped artifacts must be executed at the group level first, not rewritten into an ungrouped task loop
- every group must be delegated to the literal agent id named in `recommended agent`
- if a group omits `recommended agent`, execution must stop
- if the listed agent is unavailable, execution must stop
- if execution begins with `subagent-driven-development` or another generic executor before honoring grouped routing, execution must stop and restart under this skill
- do not invoke `requesting-code-review`, review agents, or review commands during grouped-plan execution unless the user or the plan explicitly names review

## OpenSpec Boundaries

For OpenSpec repositories:

- `/openspec-apply-change` or `/opsx:apply` -> let the OpenSpec skill select the change and load context first
- once the loaded OpenSpec tasks artifact is grouped, this skill controls implementation
- `/openspec-new-change`, `/openspec-ff-change`, and `/openspec-continue-change` remain responsible for artifact creation or update, not grouped execution
- if the OpenSpec tasks artifact is flat, stay in the OpenSpec workflow skill unless the user explicitly asks to regroup it

## Quick Reference

- `execute this grouped plan` -> this skill applies
- `continue grouped implementation in a fresh session` -> this skill applies
- `after /opsx:apply loaded grouped tasks, execute by group` -> this skill applies
- `grouped routing already exists` -> this skill applies
- `flat plan with no grouped routing` -> this skill does not apply
- `artifact creation or regrouping request` -> use `grouped-tasks`

## Common Mistakes

- Rewriting grouped work into a generic per-task loop before delegation
- Starting `subagent-driven-development` directly on a grouped artifact
- Auto-invoking `requesting-code-review` when no review was requested
- Ignoring dependency gates between groups
- Treating `recommended agent` as optional
- Running groups in parallel when the grouped artifact says serialization is required

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "subagent-driven-development can figure it out" | If grouped routing already exists, that skill is subordinate to this one. |
| "I can flatten the groups first" | Flattening destroys the execution contract. |
| "The dependencies are obvious" | If they are not respected explicitly, execution order is wrong. |
| "I can pick a better agent ad hoc" | The artifact already chose the routing contract. |

## Red Flags

- Fresh-session execution that skips straight to a generic executor
- Any automatic `requesting-code-review` invocation without explicit review request
- Missing `recommended agent`
- Group execution that ignores dependencies
- Group execution that ignores declared parallelization

If any red flag appears, stop and restore grouped execution discipline before continuing.
