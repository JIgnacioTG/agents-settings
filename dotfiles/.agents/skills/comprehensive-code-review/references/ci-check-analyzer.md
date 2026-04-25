---
name: ci-check-analyzer
description: Lightweight PR CI/check failure pass for `comprehensive-code-review`.
model: gpt-5.1-codex-mini
reasoning_effort: low
---

Use this pass only inside `comprehensive-code-review`, and only for `pr-review` mode when failing or blocking PR check context is available.

Convert failing CI/check status into actionable PR-level review findings so broken required checks are reported alongside code findings instead of being lost as external status.

## Input

You receive PR check context gathered by the wrapper, preferably from `./scripts/github-integration.sh --checks` or equivalent GitHub data.

Each check may include:

- `name`
- `workflow`
- `event`
- `state`, `bucket`, or `conclusion`
- `description`
- `link` or `detailsUrl`
- `startedAt`
- `completedAt`

## Scope

- failing checks
- cancelled checks that block merge or indicate a broken workflow
- timed-out checks
- action-required checks

## Severity

- `critical`: a required check fails in a way that blocks merge or indicates deploy/build/test breakage for core behavior.
- `important`: a non-required check fails, a required check is cancelled/timed out/action-required, or the failure likely indicates a broken test/build/lint/typecheck path.
- `suggestion`: lower-risk CI hygiene where the check is not required and the failure does not block review, but still needs follow-up.

## Output

For each finding include:

- `file`: `PR` unless the check context identifies a specific changed file
- `line`: omitted unless a stable changed line is known
- `severity`: `low | medium | high | critical`
- `explanation`: concise evidence-based explanation of the failing or blocking check and why it matters
- `check_name`
- `check_state`
- `check_event` when available
- `check_url` when available
- `comment_target`: `pr`
- `confidence`: `0-100`

## Rules

- Do not inspect code or infer root cause unless the check description directly states it.
- Do not invent failure logs that were not provided.
- Do not report passing, successful, skipped, neutral, or pending checks as failures.
- Do not duplicate a code finding from another pass; report the CI status itself and let later remediation inspect logs or code if needed.
- Use PR-level targeting by default because CI status usually does not map to a changed diff line.
