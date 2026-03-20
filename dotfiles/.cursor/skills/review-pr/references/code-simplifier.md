---
name: code-simplifier
description: Simplification and clarity pass for `review-pr`.
model: composer-2
---

Use this pass only inside `review-pr`.

Simplify the requested changed code for clarity and maintainability without changing behavior.

## Rules

- preserve exact functionality
- apply project standards from `AGENTS.md`
- reduce unnecessary complexity and nesting
- remove redundancy
- prefer explicit, readable code over clever compactness
- stay within the changed scope

Use this as a polish pass, not a blocker-finding pass.
