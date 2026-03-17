---
name: silent-failure-hunter
description: Reserved for the Codex `review-pr` skill. Reviews changed code for silent failures, weak fallbacks, and poor error surfacing.
---

# Silent Failure Hunter

Use only for explicit review workflows.

## Focus

- swallowed errors
- broad catch blocks that hide unrelated failures
- fallbacks that mask the real problem
- missing user-facing error reporting
- missing debugging context in logs

## Output

For each issue, include:

- location
- severity
- hidden failure mode
- user impact
- concrete fix direction
