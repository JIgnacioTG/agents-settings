---
description: Comprehensive PR review using specialized agents
---

# Comprehensive PR Review

Run a comprehensive pull request review using multiple specialized agents, each focusing on a different aspect of code quality.

**Review Aspects (optional):** "$ARGUMENTS"

## Review Workflow

### 1. Determine Review Scope

- Check `git status` to identify changed files.
- Parse the arguments to see whether specific review aspects were requested.
- Default to all applicable reviews when no specific aspect is requested.

### 2. Available Review Aspects

- `comments` - Analyze code comment accuracy and maintainability.
- `tests` - Review test coverage quality and completeness.
- `errors` - Check error handling for silent failures.
- `types` - Analyze type design and invariants when new types are added.
- `code` - Run a general code review for project guidelines.
- `simplify` - Simplify code for clarity and maintainability.
- `all` - Run all applicable reviews.

### 3. Identify Changed Files

- Run `git diff --name-only` to see modified files.
- Check whether a PR already exists through `gh pr view`.
- Identify file types and determine which review aspects apply.

### 4. Determine Applicable Reviews

Based on the changes:
- Always applicable: `@code-reviewer`.
- If test files changed: `@pr-test-analyzer`.
- If comments or docs changed: `@comment-analyzer`.
- If error handling changed: `@silent-failure-hunter`.
- If types were added or modified: `@type-design-analyzer`.
- After passing review: `@code-simplifier`.

### 5. Launch Review Agents

**Sequential approach**
- Launch one agent at a time.
- Keep each report complete before moving to the next one.
- Use this by default for interactive review.

**Parallel approach**
- If the `parallel` argument is present, launch all applicable agents simultaneously.
- Use this for faster comprehensive review.

### 6. Aggregate Results

After the agents complete, summarize:

```markdown
# PR Review Summary

## Critical Issues (X found)
- [@agent-name]: Issue description [file:line]

## Important Issues (X found)
- [@agent-name]: Issue description [file:line]

## Suggestions (X found)
- [@agent-name]: Suggestion [file:line]

## Strengths
- What's well-done in this PR

## Recommended Action
1. Fix critical issues first
2. Address important issues
3. Consider suggestions
4. Re-run review after fixes
```

## Usage Examples

**Full review (default):**

```text
/review-pr
```

**Specific aspects:**

```text
/review-pr tests errors
/review-pr comments
/review-pr simplify
```

**Parallel review:**

```text
/review-pr all parallel
```

## Agent Descriptions

- `@code-reviewer`: checks `AGENTS.md` compliance, detects bugs, and reviews general code quality.
- `@pr-test-analyzer`: reviews behavioral test coverage and identifies critical test gaps.
- `@comment-analyzer`: verifies comment accuracy and identifies comment rot.
- `@silent-failure-hunter`: finds silent failures and reviews fallback and logging behavior.
- `@type-design-analyzer`: analyzes type encapsulation and invariant expression.
- `@code-simplifier`: simplifies code while preserving functionality.

## Workflow Integration

**Before creating a PR:**
1. Stage all changes.
2. Run `/review-pr all`.
3. Address all critical and important issues.
4. Run targeted reviews again to verify.
5. Create the PR.

**After PR feedback:**
1. Make the requested changes.
2. Run targeted reviews based on that feedback.
3. Verify the issues are resolved.
4. Push updates.

## Notes

- Agents run autonomously and return detailed reports.
- Each agent focuses on its specialty for deeper analysis.
- Results should be actionable with specific file and line references.
- All referenced agents are available in `dotfiles/.config/opencode/agents/`.
