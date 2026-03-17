---
name: review-pr
description: Use when the user explicitly asks for a broad review of changed code or a pull request using the original pr-review-toolkit style passes such as comments, tests, errors, types, code, or simplify.
---

# Review PR

Run an explicit multi-pass review that mirrors the original Claude Code `pr-review-toolkit` workflow once invoked.

Do not use this skill unless the user explicitly requested review.

## Pass Profiles

Load only the profiles needed for the requested review:

- `./references/code-reviewer.md`
- `./references/code-simplifier.md`
- `./references/comment-analyzer.md`
- `./references/silent-failure-hunter.md`
- `./references/type-design-analyzer.md`
- `./references/pr-test-analyzer.md`

Each profile declares its own `model` and `reasoning_effort`. Use those defaults directly.

Do not use Spark by default for review.

## Workflow

1. Determine the review scope from the explicit user request.
2. Parse requested aspects if present:
   - `comments`
   - `tests`
   - `errors`
   - `types`
   - `code`
   - `simplify`
   - `all`
   - `parallel`
3. Identify changed files from `git diff --name-only`, and check whether a PR exists when that context matters.
4. Determine applicable passes from the diff:
   - always include `code-reviewer` for general quality
   - include `pr-test-analyzer` when tests changed or behavior changed without obvious coverage
   - include `comment-analyzer` when comments or docs changed
   - include `silent-failure-hunter` when error handling, fallbacks, or retry paths changed
   - include `type-design-analyzer` when new or changed types appear
   - include `code-simplifier` only when `simplify` was explicitly requested or after a broad review with no critical blockers
5. Run passes sequentially by default. Run them in parallel only when the user explicitly requested `parallel`.
6. Aggregate findings into:
   - critical issues
   - important issues
   - suggestions
   - strengths
   - recommended action
7. Include file references and name which pass produced each finding.

## Rules

- Default to all applicable review passes only when the user asked for a broad review without narrowing scope.
- Keep review high-signal and actionable.
- Do not silently mutate code as part of review.
- Treat `simplify` as a polish pass, not a blocker-finding pass.
- Keep the original plugin behavior, but do not proactively trigger review on your own.
- Do not invoke this skill from grouped execution unless review is explicitly requested.
