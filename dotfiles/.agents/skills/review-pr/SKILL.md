---
name: review-pr
description: Deprecated compatibility alias for PR review requests. Use when the user explicitly asks for a broad review of changed code or a pull request and the request should be routed to multi-agent-review, while keeping the legacy review-pr workflow usable during migration.
---

# Review PR

> Deprecated: prefer `multi-agent-review` for new PR review requests. This legacy skill remains available for backward compatibility and routes the same staged review flow.

This skill is a compatibility alias only.

Do not use this skill unless the user explicitly requested review.

Route the request to `multi-agent-review` and keep this file limited to migration guidance.

## Compatibility Behavior

- Preserve PR-oriented intent, narrowed review angles, and explicit posting requests when handing off to `multi-agent-review`.
- Keep backward compatibility for older prompts, commands, and habits that still say `review-pr`.
- Let `multi-agent-review` own triage, context gathering, pass selection, validation, aggregation, and reporting.

## Guardrails

- Do not restate or fork the legacy PR review workflow in this alias.
- Do not broaden the request beyond the PR or changed-code scope the user asked to review.
- Do not post comments or take GitHub actions unless the active `multi-agent-review` workflow explicitly requires it.
