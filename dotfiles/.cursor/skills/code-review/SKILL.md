---
name: code-review
description: Use when the user explicitly asks for a high-signal code review of a pull request or diff using triage, scoped AGENTS checks, bug detection, and issue validation.
---

# Code Review

Run the stricter staged review flow that mirrors the `code-review` command once invoked.

Do not use this skill unless the user explicitly requested code review.

## Pass Profiles

Load these profiles as the workflow requires:

- `./references/pr-triage.md`
- `./references/config-finder.md`
- `./references/pr-summarizer.md`
- `./references/compliance-auditor.md`
- `./references/code-reviewer.md`
- `./references/issue-validator.md`

Each profile lists the default `model` for that pass (`composer-2` or `composer-2-fast`). Prefer delegating to the matching subagent under `~/.cursor/agents/` when available.

## Workflow

1. Create a checklist before starting so the staged workflow is not skipped.
2. Run `pr-triage` first and stop immediately if the review should be skipped because the PR is closed, draft, trivial, or already reviewed.
3. Run `config-finder` to gather the relevant `AGENTS.md` files for the changed paths.
4. Run `pr-summarizer` to capture the title, intent, key files, and areas of concern.
5. Run these four review passes in parallel:
   - `compliance-auditor` pass 1
   - `compliance-auditor` pass 2
   - `code-reviewer` diff-only bug pass
   - `code-reviewer` introduced-code problem pass
6. Pass the PR title and description into each review pass for context.
7. Validate every issue from the bug/compliance passes with `issue-validator` before reporting it.
8. Filter out anything not validated.
9. Report only validated, high-signal findings.
10. If the user explicitly asked to post comments, use the validated findings only and preserve the original comment discipline:
   - one comment per unique issue
   - suggestion blocks only when the suggestion fully fixes the issue
   - no comments when there are no validated issues except the explicit summary comment flow

## Rules

- Keep the review scope narrow and explicit.
- Only flag issues that are clear, important, and defensible.
- Prefer false-negative over false-positive when confidence is low.
- High-signal only means definite failures, definite wrong behavior, or explicit scoped `AGENTS.md` violations.
- Do not report style nits, speculative concerns, or generic quality commentary.
- Do not post comments or take GitHub actions unless the explicit workflow requires it.
- Do not invoke this skill from grouped execution unless review is explicitly requested.
