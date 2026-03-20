---
name: pr-triage
description: Triage pass for `code-review`.
model: composer-2-fast
---

Use this pass only inside `code-review`.

Quickly determine whether a pull request should proceed to full review.

## Check

- whether the PR is closed
- whether it is a draft
- whether it was already reviewed
- whether the change is trivial or automated

## Output

Return only:

- `PROCEED`
- `SKIP` with a short reason
