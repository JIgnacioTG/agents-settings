---
name: executing-grouped-tasks
description: "Use when implementing from an already-grouped `tasks.md` or grouped multi-step plan with explicit dependencies, parallelization, or `recommended agent` routing, especially after `openspec-apply-change` or `/opsx:apply` has selected the change, or when a fresh session is asked to continue grouped execution. When this skill applies, run a scoped `explore` handoff only for groups that still need it so implementation-ready grouped work can delegate directly."
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
- `branch suggestion`
- `recommended agent`

If any field is missing, stop and return to `grouped-tasks` to repair the artifact before implementing.

If any groups are marked parallel-capable, the active artifact must also include a current `parallel execution trace` section that covers fan-out, merge-group requirements, and where serialization resumes. If that trace is missing or stale, stop and return to `grouped-tasks`.

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
- run a scoped `explore` subagent only for ready groups whose `complexity` is `unknown`
- if parallel groups are ready, confirm the current artifact also includes the `parallel execution trace` and any required merge group before delegating them
- delegate each ready group to the literal `recommended agent` named in that group
- pass the full group text, any explore findings, dependency notes, and verification expectations into that implementation delegation
- after a group completes, reassess dependency state before starting newly unblocked groups
- if multiple ready groups are independent and the grouped artifact says they can run in parallel, parallel execution is allowed with detached worktrees by default unless the user explicitly requested branch-per-group execution; otherwise serialize

## Execution Contract

- grouped artifacts must be executed at the group level first, not rewritten into an ungrouped task loop
- before delegating implementation for a ready group, send a scoped `explore` subagent only when that group's `complexity` is `unknown`
- every group must be delegated to the literal agent id named in `recommended agent`
- if a group omits `recommended agent`, execution must stop
- if the listed agent is unavailable, execution must stop
- when a scoped `explore` handoff is required, keep it for repository grounding only and do not redesign, regroup, or widen the approved plan
- the implementation agent must use the grouped plan, plus any scoped explore summary already produced, as execution-ready context and should not restart broad startup exploration unless a concrete blocker remains
- when a group is not `unknown`, delegate implementation directly with the grouped plan and the execution-critical context already in hand
- if multiple ready groups are explicitly marked independent, delegate those groups in parallel only after confirming the artifact's `parallel execution trace`
- when parallel groups are delegated, prefer detached worktrees by default unless the user explicitly requested branch-per-group execution
- if downstream serialized work depends on multiple earlier parallel groups, require the declared merge group to complete before starting that downstream serialized work
- if execution begins with `subagent-driven-development` or another generic executor before honoring grouped routing, execution must stop and restart under this skill
- do not invoke `requesting-code-review`, review agents, or review commands during grouped-plan execution unless the user or the plan explicitly names review
- reserve the pre-scoped handoff for `unknown` groups that still need repository grounding before implementation

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
- Skipping the required scoped `explore` handoff for an `unknown` group
- Forcing a scoped `explore` handoff for an implementation-ready non-`unknown` group
- Auto-invoking `requesting-code-review` when no review was requested
- Ignoring dependency gates between groups
- Treating `recommended agent` as optional
- Letting the implementation agent restart broad discovery after it already received a scoped explore summary
- Running groups in parallel when the grouped artifact says serialization is required
- Starting downstream serialized work before the declared merge group completes

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
- Missing `branch suggestion`
- Missing `parallel execution trace` for parallel work
- Missing `recommended agent`
- Group execution that ignores dependencies
- Group execution that ignores declared parallelization

If any red flag appears, stop and restore grouped execution discipline before continuing.
