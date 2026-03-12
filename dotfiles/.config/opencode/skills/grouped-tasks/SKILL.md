---
name: grouped-tasks
description: "Use when generating or updating OpenSpec task artifacts or tasks.md during artifact workflow commands such as openspec ff, openspec new, openspec continue, /opsx:ff, /opsx:new, or /opsx:continue, especially when creating all artifacts needed for implementation, and when using writing-plans for superpower plans or creating multi-step plan or todo output that must stay in explicit task groups."
---

# Grouped Tasks

## Overview

Turn planning output into explicit task groups instead of flat lists.

**Core principle:** every group must declare its work, dependency shape, execution mode, and implementation routing before execution starts.

This skill shapes planning output. If another planning workflow would produce a flat sequence of tasks, regroup that output before returning it.

## Required Output

Never produce a flat task list when this skill applies.

This includes:

- openspec task files
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

Allowed complexity values:

- `simple`
- `low`
- `medium`
- `high`
- `unknown`

`unknown` is valid only when the missing research is stated explicitly.

## Parallel Analysis

Before implementation starts, include an explicit cross-group analysis that states:

- which groups are independent
- which groups must stay serialized
- what dependency or shared-state constraint causes the ordering
- the resulting execution order

If nothing can run in parallel, say so explicitly.

## Routing

Use this mapping for `recommended agent`:

- `simple` -> `@implementation-agent-fast`
- `low` -> `@implementation-agent-fast`
- `medium` -> `@implementation-agent-spark`
- `high` -> `@implementation-agent`
- `unknown` -> `@implementation-agent-thinker`

Use the literal agent ids above. Do not invent aliases such as `implementation-agent-medium`, `implementation-agent-high`, or other derived names.

## Execution Contract

- must be delegated to the literal agent id named in `recommended agent`.
- if a group omits `recommended agent`, execution must stop.
- if the listed agent is unavailable, execution must stop.
- review agents and review commands are forbidden during grouped-plan execution unless the user or the plan explicitly names review.

## Quick Reference

- `openspec task file` -> grouped tasks required
- `superpower plan` -> grouped tasks required
- `implementation plan` -> grouped tasks required
- `approved design doc` -> grouped tasks required
- `plan` for multi-step work -> grouped tasks required
- `todo list` for multi-step work -> grouped tasks required
- single trivial action -> this skill does not apply

## Common Mistakes

- Flat checklist without groups
- Group without complexity
- Group without dependency notes
- Missing cross-group parallelization analysis
- Routing `unknown` to anything except `@implementation-agent-thinker`
- Invented agent aliases instead of the literal configured agent ids
- Using `unknown` without naming the missing research
- Letting another planning skill return a flat numbered task sequence

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "It is only a todo list" | Multi-step todos still need grouped execution planning. |
| "Writing-plans already formatted it" | If the result is flat, regroup it before returning it. |
| "The groups are obvious" | If dependencies are not written, the plan is incomplete. |
| "I can add routing later" | Agent routing is part of the plan contract. |
| "Unknown is safer" | `unknown` without missing-research notes is incomplete planning. |

## Red Flags

- Flat list for multi-step work
- Missing `parallelization`
- Missing `recommended agent`
- More than one complexity per group
- `unknown` with no explanation

If any red flag appears, rewrite the plan in grouped form before continuing.
