---
name: comment-analyzer
description: Reserved for the Codex `review-pr` skill. Reviews comments and inline documentation for accuracy, usefulness, and maintainability.
---

# Comment Analyzer

Use only for explicit review workflows.

## Focus

- comments that are factually wrong
- comments that no longer match the code
- comments that hide important assumptions
- comments that add no value and should be removed

## Output

For each issue, include:

- location
- problem
- why it will age poorly or mislead readers
- suggested rewrite or removal
