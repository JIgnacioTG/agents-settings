---
description: Code review a pull request
---

Provide a code review for the given pull request.

**Arguments:** "$ARGUMENTS"

## Agent Assumptions

- All tools are functional. Do not test tools or make exploratory calls.
- Only call a tool if it is required to complete the task.
- Every tool call should have a clear purpose.

## Review Process

Follow these steps precisely:

### Step 1: Triage

Use `@pr-triage` to check whether any of the following are true:
- The pull request is closed.
- The pull request is a draft.
- The pull request does not need code review, such as an automated PR or an obviously trivial change.
- This PR has already been reviewed through `gh pr view <PR> --comments`.

If `@pr-triage` returns `SKIP`, stop and explain why. Still review AI-generated PRs.

### Step 2: Gather Context

Use `@config-finder` to find all relevant `AGENTS.md` files:
- The root `AGENTS.md` file, if it exists.
- Any `AGENTS.md` files in directories containing files modified by the pull request.

### Step 3: Summarize Changes

Use `@pr-summarizer` to create a brief summary of what changed and why.

### Step 4: Parallel Review

Launch 4 review passes in parallel.

**Pass 1 + 2: `AGENTS.md` compliance**
Use `@compliance-auditor` twice to audit changes for `AGENTS.md` compliance. When evaluating compliance for a file, only consider `AGENTS.md` files that share a file path with the file or its parents.

**Pass 3: Bug detection from the diff**
Use `@code-reviewer` to scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs and ignore likely false positives.

**Pass 4: Problems introduced by the changed code**
Use `@code-reviewer` to look for security issues, incorrect logic, or other clear problems that exist in the introduced code. Only look for issues within the changed code.

**CRITICAL: HIGH SIGNAL ONLY.** Flag issues where:
- The code will fail to compile or parse, such as syntax errors, type errors, missing imports, or unresolved references.
- The code will definitely produce wrong results regardless of inputs.
- There is a clear, unambiguous `AGENTS.md` violation and you can quote the exact rule.

Do not flag:
- Code style or quality concerns.
- Potential issues that depend on specific inputs or state.
- Subjective suggestions or improvements.

If you are not certain an issue is real, do not flag it.

Provide each review pass with the PR title and description for context about the author's intent.

### Step 5: Validate Issues

For each issue found in Step 4, use `@issue-validator` to validate the flagged issue. Provide the PR title, description, and issue details so the validator can independently confirm whether the issue is real.

### Step 6: Filter

Remove any issues that `@issue-validator` dismissed. This gives the final list of high-signal findings.

### Step 7: Output Summary

Output a summary of the review findings:
- If issues were found, list each issue with a brief description.
- If no issues were found, state: `No issues found. Checked for bugs and AGENTS.md compliance.`

If the `--comment` argument was not provided, stop here. Do not post any GitHub comments.

If the `--comment` argument was provided and no issues were found, post a summary comment using `gh pr comment` with this format:

```markdown
## Code review

No issues found. Checked for bugs and AGENTS.md compliance.
```

If the `--comment` argument was provided and issues were found, continue to Step 8.

### Step 8: Post Inline Comments

Post inline comments for each issue using the GitHub tooling available in this environment. For each comment:
- Provide a brief description of the issue.
- For small, self-contained fixes, include a committable suggestion block.
- For larger fixes, describe the issue and suggested fix without a suggestion block.
- Never post a committable suggestion unless it fixes the issue completely.

Only post one comment per unique issue.

## False Positive Exclusion List

Do not flag these:
- Pre-existing issues.
- Something that appears to be a bug but is actually correct.
- Pedantic nitpicks that a senior engineer would not flag.
- Issues that a linter will catch.
- General code quality concerns unless explicitly required in `AGENTS.md`.
- Issues mentioned in `AGENTS.md` but explicitly silenced in the code.

## Notes

- Use `gh` CLI to interact with GitHub.
- Cite and link each issue in inline comments when posting them.
- When linking to code in inline comments, use this format: `https://github.com/OWNER/REPO/blob/FULL_SHA/path/to/file#L10-L15`
- Use a full git SHA, not an abbreviated one.
- Provide at least one line of context before and after the relevant lines.
