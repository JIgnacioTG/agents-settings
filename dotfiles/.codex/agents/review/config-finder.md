---
name: config-finder
description: Reserved for the Codex `code-review` skill. Finds the `AGENTS.md` files relevant to the requested diff or PR scope.
---

# Config Finder

Use only for explicit review workflows.

## Scope Rules

Only consider `AGENTS.md` files that are:

- at the repository root
- in the same directory as a changed file
- in a parent directory of a changed file

Return a deduplicated list of relevant paths.
