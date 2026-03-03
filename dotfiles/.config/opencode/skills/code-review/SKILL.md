---
name: code-review
description: |
  Automated multi-stage PR review with validation. Use when you need a thorough, high-signal code review of a pull request with false-positive filtering. Supports --comment flag to post inline GitHub comments.
---

# Automated Code Review

Run a multi-stage automated code review on a pull request with validation to minimize false positives.

**Arguments:** "$ARGUMENTS"

## Agent Assumptions

- All tools are functional. Do not test tools or make exploratory calls.
- Only call a tool if it is required to complete the task.
- Every tool call should have a clear purpose.

## Review Process

Follow these steps precisely:

### Step 1: Triage

@pr-triage — Check if any of the following are true:
- The pull request is closed
- The pull request is a draft
- The pull request does not need code review (e.g., automated PR, trivial change that is obviously correct)
- This PR has already been reviewed (check `gh pr view <PR> --comments` for previous review comments)

If @pr-triage returns SKIP, stop and explain why. Still review AI-generated PRs.

### Step 2: Gather Context

@config-finder — Find all relevant AGENTS.md files:
- The root AGENTS.md file, if it exists
- Any AGENTS.md files in directories containing files modified by the pull request

### Step 3: Summarize Changes

@pr-summarizer — View the pull request and create a brief summary of what changed and why.

### Step 4: Parallel Review

Launch 4 review passes in parallel:

**Pass 1 + 2: AGENTS.md Compliance**
@compliance-auditor (x2) — Audit changes for AGENTS.md compliance. When evaluating compliance for a file, only consider AGENTS.md files that share a file path with the file or its parents.

**Pass 3: Bug Detection (diff-only)**
@code-reviewer — Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that cannot be validated without looking at context outside of the git diff.

**Pass 4: Introduced Code Problems**
@code-reviewer — Look for problems in the introduced code: security issues, incorrect logic, etc. Only look for issues within the changed code.

**CRITICAL: HIGH SIGNAL ONLY.** Flag issues where:
- The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
- The code will definitely produce wrong results regardless of inputs (clear logic errors)
- Clear, unambiguous AGENTS.md violations where you can quote the exact rule being broken

Do NOT flag:
- Code style or quality concerns
- Potential issues that depend on specific inputs or state
- Subjective suggestions or improvements

If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

Provide each agent with the PR title and description for context about the author's intent.

### Step 5: Validate Issues

For each issue found in Step 4, @issue-validator validates each flagged issue. The validator receives the PR title, description, and a description of the issue. Its job is to confirm the issue is real with high confidence. For example:
- If "variable is not defined" was flagged, verify it is actually undefined in the code
- If an AGENTS.md violation was flagged, verify the rule is scoped for this file and is actually violated

### Step 6: Filter

Remove any issues that @issue-validator dismissed. This gives us the final list of high-signal issues.

### Step 7: Output Summary

Output a summary of the review findings to the terminal:
- If issues were found, list each issue with a brief description.
- If no issues were found, state: "No issues found. Checked for bugs and AGENTS.md compliance."

If `--comment` argument was NOT provided, stop here. Do not post any GitHub comments.

If `--comment` argument IS provided and NO issues were found, post a summary comment using `gh pr comment` with this format:

```
## Code review

No issues found. Checked for bugs and AGENTS.md compliance.
```

If `--comment` argument IS provided and issues were found, continue to Step 8.

### Step 8: Post Inline Comments

Post inline comments for each issue using the GitHub MCP tool. For each comment:
- Provide a brief description of the issue
- For small, self-contained fixes, include a committable suggestion block
- For larger fixes (6+ lines, structural changes, or changes spanning multiple locations), describe the issue and suggested fix without a suggestion block
- Never post a committable suggestion UNLESS committing the suggestion fixes the issue entirely

**Only post ONE comment per unique issue. Do not post duplicate comments.**

## False Positive Exclusion List

Do NOT flag these (they are false positives):
- Pre-existing issues
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch
- General code quality concerns unless explicitly required in AGENTS.md
- Issues mentioned in AGENTS.md but explicitly silenced in the code (e.g., via a lint ignore comment)

## Notes

- Use `gh` CLI to interact with GitHub (fetch PRs, create comments). Do not use web fetch.
- Cite and link each issue in inline comments (e.g., if referring to an AGENTS.md, include a link to it).
- When linking to code in inline comments, use this format: `https://github.com/OWNER/REPO/blob/FULL_SHA/path/to/file#L10-L15`
  - Requires full git SHA (not abbreviated)
  - Line range format is L[start]-L[end]
  - Provide at least 1 line of context before and after
