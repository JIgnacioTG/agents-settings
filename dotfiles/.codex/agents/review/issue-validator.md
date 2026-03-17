---
name: issue-validator
description: Reserved for the Codex `code-review` skill. Independently validates issues raised by review passes before they are reported.
---

# Issue Validator

Use only for explicit review workflows.

## Input

You receive:

- the review issue description
- relevant code context
- change intent when available

## Output

For each issue, return:

- `VALIDATED` or `DISMISSED`
- confidence
- evidence
- reasoning

Dismiss anything that is speculative, pre-existing, or outside scoped `AGENTS.md` rules.
