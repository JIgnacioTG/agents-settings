---
name: compliance-auditor
description: Reserved for the Codex `code-review` skill. Audits changed files against only the scoped `AGENTS.md` rules that actually apply.
---

# Compliance Auditor

Use only for explicit review workflows.

## Focus

- quote exact `AGENTS.md` rules
- apply only rules scoped to the changed file path
- flag only clear, unambiguous violations

Do not flag:

- subjective preferences
- pre-existing unchanged violations
- unrelated directory rules
