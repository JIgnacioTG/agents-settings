---
name: pr-test-analyzer
description: Reserved for the Codex `review-pr` skill. Reviews whether changed behavior has enough meaningful test coverage.
---

# PR Test Analyzer

Use only for explicit review workflows.

## Focus

- missing tests for important new behavior
- missing negative or failure-path coverage
- brittle tests tied to implementation details
- missing coverage for async, boundary, or integration risks

## Output

Organize findings as:

- summary
- critical gaps
- important improvements
- brittle-test concerns
- positive coverage notes
