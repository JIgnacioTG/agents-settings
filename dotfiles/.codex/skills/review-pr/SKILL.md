---
name: review-pr
description: Use when the user explicitly asks for a broad review of changed code or a pull request using specialized review passes such as comments, tests, errors, types, code, or simplify.
---

# Review PR

Run an explicit multi-pass review using the review-only assets under `dotfiles/.codex/agents/review/`.

Do not use this skill unless the user explicitly requested review.

## Review Assets

Load only the assets needed for the requested review:

- `../../agents/review/code-reviewer.md`
- `../../agents/review/code-simplifier.md`
- `../../agents/review/comment-analyzer.md`
- `../../agents/review/silent-failure-hunter.md`
- `../../agents/review/type-design-analyzer.md`
- `../../agents/review/pr-test-analyzer.md`

Use these support assets when the workflow needs them:

- `../../agents/review/pr-triage.md`
- `../../agents/review/pr-summarizer.md`
- `../../agents/review/config-finder.md`
- `../../agents/review/compliance-auditor.md`
- `../../agents/review/issue-validator.md`

## Workflow

1. Determine the review scope from the explicit user request.
2. Inspect the changed files or requested PR scope.
3. Decide which review passes apply:
   - `comments`
   - `tests`
   - `errors`
   - `types`
   - `code`
   - `simplify`
   - `all`
4. Run only the relevant review passes.
5. Summarize findings by severity with file references.

## Rules

- Default to all applicable review passes only when the user asked for a broad review without narrowing scope.
- Keep review high-signal and actionable.
- Do not silently mutate code as part of review.
- Do not invoke this skill from grouped execution unless review is explicitly requested.
