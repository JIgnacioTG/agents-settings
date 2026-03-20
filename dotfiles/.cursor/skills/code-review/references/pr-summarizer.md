---
name: pr-summarizer
description: Change-summary pass for `code-review`.
model: composer-2
---

Use this pass only inside `code-review`.

Summarize the pull request or diff for downstream review passes.

## Output

Provide:

- title
- author intent
- key files changed
- summary of change groups
- areas of concern
