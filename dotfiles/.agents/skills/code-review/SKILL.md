---
name: code-review
description: Deprecated compatibility alias for code-review requests. Use when the user explicitly asks for a high-signal code review of a pull request or diff and the request should be routed to multi-agent-review, while keeping the legacy code-review workflow usable during migration.
---

# Code Review

> Deprecated: prefer `multi-agent-review` for new review requests. This legacy skill stays available for backward compatibility and routes the same staged review flow.

This skill is a compatibility alias only.

Do not use this skill unless the user explicitly requested code review.

Route the request to `multi-agent-review` and keep this file limited to migration guidance.

## Compatibility Behavior

- Preserve the user's requested review surface when handing off to `multi-agent-review`.
- Keep backward compatibility for older prompts, commands, and habits that still say `code-review`.
- Let `multi-agent-review` own triage, context gathering, pass selection, validation, aggregation, and reporting.

## Guardrails

- Do not restate or fork the legacy staged workflow in this alias.
- Do not broaden the user request beyond the review scope they asked for.
- Do not post comments or take GitHub actions unless the active `multi-agent-review` workflow explicitly requires it.
