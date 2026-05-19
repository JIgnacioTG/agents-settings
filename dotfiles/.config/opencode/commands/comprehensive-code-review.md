---
description: Deterministic comprehensive code review with specialized subagents
---

# Comprehensive Code Review

Use the `comprehensive-code-review` skill as the only canonical workflow. This command is a thin launcher so command text cannot drift from the skill's pass plan.

**Arguments:** "$ARGUMENTS"

## Dispatch

1. Load the `comprehensive-code-review` skill.
2. Treat `$ARGUMENTS` as the review request.
3. Follow the skill exactly for review surface resolution, GitHub context, pass activation, category-routed `task(...)` dispatch, validation, aggregation, remediation-plan artifacts, and final output.

## Guardrails

- Do not duplicate the skill's triage, setup passes, pass activation table, validation flow, aggregation rules, output format, or remediation-plan rules in this command.
- Do not create command-only setup passes such as `pr-triage`, `config-finder`, or `pr-summarizer`.
- Do not compact or summarize review evidence before the skill dispatches specialist passes.
- If this command and the skill conflict, the skill wins.
