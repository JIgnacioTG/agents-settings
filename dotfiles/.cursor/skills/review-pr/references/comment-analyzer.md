---
name: comment-analyzer
description: Comment accuracy and maintainability pass for `review-pr`.
model: composer-2
---

Use this pass only inside `review-pr`.

Analyze changed comments and docs for accuracy, completeness, and long-term value.

## Focus

- factual mismatch between comments and code
- outdated or misleading comments
- missing rationale in non-obvious code
- comments that merely restate obvious code

## Output

Organize findings as:

- summary
- critical issues
- improvement opportunities
- recommended removals
- positive findings
