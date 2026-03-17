---
name: code-review
description: Use when the user explicitly asks for a high-signal code review of a pull request or diff with triage, scoped AGENTS compliance checks, bug detection, and issue validation.
---

# Code Review

Run the stricter PR-review workflow using the review-only assets under `dotfiles/.codex/agents/review/`.

Do not use this skill unless the user explicitly requested code review.

## Required Assets

Primary workflow assets:

- `../../agents/review/pr-triage.md`
- `../../agents/review/config-finder.md`
- `../../agents/review/pr-summarizer.md`
- `../../agents/review/compliance-auditor.md`
- `../../agents/review/code-reviewer.md`
- `../../agents/review/issue-validator.md`

## Workflow

1. Triage the PR or requested review scope.
2. Stop early if the request should be skipped because it is closed, draft, already reviewed, or clearly trivial.
3. Discover the relevant `AGENTS.md` files for the changed files.
4. Summarize the changes for downstream review passes.
5. Run parallel review passes for scoped compliance and high-signal bugs.
6. Validate each flagged issue before reporting it.
7. Report only validated, high-signal findings.

## Rules

- Keep the review scope narrow and explicit.
- Only flag issues that are clear, important, and defensible.
- Prefer false-negative over false-positive when confidence is low.
- Do not post comments or take GitHub actions unless the explicit workflow requires it.
- Do not invoke this skill from grouped execution unless review is explicitly requested.
