---
description: External comprehensive GitHub PR code review with specialized subagents
---

# External Comprehensive Code Review

Run the canonical `comprehensive-code-review` workflow against someone else's GitHub PR.

**Arguments:** "$ARGUMENTS"

## Required input

- `$ARGUMENTS` must include a GitHub PR URL.
- If no GitHub PR URL is present, stop and ask for the PR link.

## Dispatch

1. Load the `comprehensive-code-review` skill.
2. Treat the GitHub PR URL in `$ARGUMENTS` as the review target.
3. Treat this as `external-review-context`; no remediation plan is needed unless the user explicitly overrides this command.
4. Treat posting findings to the PR as already approved for this command.
5. Follow the skill exactly for PR context gathering, unresolved comment lookup, CI/check context, pass activation, category-routed `task(...)` dispatch, validation, aggregation, and final output.

## PR review decision

- Write every PR comment in Spanish.
- Keep every posted PR comment concise: state only the issue and the suggested fix.
- Prefer a small replacement snippet when it makes the fix clearer.
- Do not include extended technical analysis, pass attribution, evidence trails, or broad rationale in posted PR comments.
- Post validated findings as PR comments when they have a stable PR comment target.
- Normally grant PR approval after posting comments.
- Request changes instead of approving only when a critical bug is found.
- If no validated findings are found, grant PR approval.
- Do not create a remediation-plan artifact.

## Output intent

- Return review findings for the external PR.
- Include a `comments posted` section listing each finding that was commented on the PR.
- Include a `smells not commented` section for non-blocking smells, weak signals, or observations that were found but intentionally not posted as PR comments.
- Include PR comment target metadata when available.
- Include the final PR review decision: approved, approved with comments, or changes requested for a critical bug.

## Guardrails

- Do not duplicate the skill's triage, setup passes, pass activation table, validation flow, aggregation rules, output format, or remediation-plan rules in this command.
- Do not create command-only setup passes such as `pr-triage`, `config-finder`, or `pr-summarizer`.
- Do not compact or summarize review evidence before the skill dispatches specialist passes.
- If this command and the skill conflict, this command controls only the external-review posting language, no-remediation-plan requirement, and approval policy; the skill wins for review orchestration.
