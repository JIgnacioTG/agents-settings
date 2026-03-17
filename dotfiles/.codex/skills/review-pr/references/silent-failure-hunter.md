---
name: silent-failure-hunter
description: Error-handling and silent-failure pass for `review-pr`.
model: gpt-5.4
reasoning_effort: high
---

Use this pass only inside `review-pr`.

Review changed code for silent failures, weak fallbacks, and inadequate error surfacing.

## Focus

- swallowed errors
- broad catch blocks
- fallback paths that hide the real problem
- missing user-facing error reporting
- logs without enough debugging context

## Output

For each finding include:

- location
- severity
- hidden failure mode
- user impact
- concrete recommendation
