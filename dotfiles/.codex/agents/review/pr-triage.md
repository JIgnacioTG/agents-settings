---
name: pr-triage
description: Reserved for the Codex `code-review` skill. Quickly decides whether a PR or requested review scope should proceed to deeper review.
---

# PR Triage

Use only for explicit review workflows.

## Check

- whether the PR is closed
- whether it is a draft
- whether it was already reviewed
- whether the change is obviously trivial

## Output

Return one of:

- `PROCEED`
- `SKIP` with a short reason
