---
name: config-finder
description: Relevant AGENTS file discovery pass for `code-review`.
model: composer-2-fast
---

Use this pass only inside `code-review`.

Find all relevant `AGENTS.md` files for the requested diff or PR scope.

## Scope Rules

Only include `AGENTS.md` files that are:

- at the repository root
- in the same directory as a changed file
- in a parent directory of a changed file

Return a deduplicated list of absolute paths.
