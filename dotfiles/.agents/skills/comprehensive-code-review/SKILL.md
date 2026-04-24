---
name: comprehensive-code-review
description: Use when the user explicitly asks for a code review, PR review, or diff review that should be split into staged, role-based passes and validated before reporting. Also use it when the user wants findings posted back to someone else's PR as line, file, or PR-level review comments.
---

# Multi-Agent Review

Run an explicit orchestration wrapper for staged, role-based review. This file decides mode, triage, context gathering, pass selection, dispatch, validation, aggregation, and final output. Detailed heuristics stay in the reference profiles.

## Reference Profiles

### Core flow

- `./references/triage-agent.md`
- `./references/code-reviewer.md`
- `./references/agents-md-auditor.md`
- `./references/validator-agent.md`
- `./references/aggregator-agent.md`

### Conditional specialists

- `./references/comment-analyzer.md`
- `./references/pr-test-analyzer.md`
- `./references/silent-failure-hunter.md`
- `./references/type-design-analyzer.md`
- `./references/history-context-analyzer.md`
- `./references/security-agent.md`
- `./references/performance-agent.md`
- `./references/ui-ux-agent.md`
- `./references/architecture-agent.md`
- `./references/code-simplifier.md`

## Orchestration Workflow

1. Confirm this skill should activate.
   - Activate only for explicit review requests: code review, PR review, diff review, commit review, changed-code review, pass-based review, or equivalent.
   - Detect the requested mode from the prompt and available artifacts:
     - `pr-review`: PR URL, PR number, branch-linked PR, or explicit PR wording.
     - `diff-review`: patch, diff, commit range, merge-base comparison, or branch comparison.
     - `request-review`: changed-code review without a formal PR.
     - `targeted-review`: explicit narrowing to code, tests, comments, security, performance, architecture, types, UI/UX, simplification, or compliance.
   - If review was not explicitly requested, do not run this skill.

2. Resolve context source before triage.
   - Prefer GitHub PR context from authenticated `gh` when available.
   - If `gh` context is unavailable, use MCP-provided PR metadata, diff payloads, and unresolved-thread payloads when present.
   - If neither GitHub source is available, fall back to local diff or changed-code review.
   - Preserve which source was used so later output can mention reduced context when necessary.

3. Run triage first.
   - Load `./references/triage-agent.md` before any deep review.
   - Give triage the resolved review mode, PR state when known, and a short summary of the diff target.
   - Let triage decide whether review should proceed for draft PRs, closed PRs, trivial or automated changes, already-reviewed requests, or diffs with no code changes.
   - If triage returns `proceed: false`, stop immediately and return only the short reason.

4. Gather only the minimum orchestration context.
    - Collect the review target, changed files, diff summary, and any explicitly requested review angles.
    - When in PR mode, gather PR metadata and unresolved review discussion context if available from the chosen provider.
    - Preserve unresolved thread/comment identifiers, URLs, authors, paths, lines, and outdated/resolved state so downstream remediation can reply to or resolve the exact comment rather than losing thread traceability.
    - Gather applicable `AGENTS.md` files for the changed paths when compliance context may matter.
    - Do not re-implement pass heuristics here; gather only enough to activate and feed the right profiles.

5. Determine review ownership and publication intent.
   - Treat the request as `owner-remediation-context` when the user is reviewing their own branch/work before fixing it.
   - Treat the request as `external-review-context` when the user is reviewing someone else's branch or PR and does not own the implementation work.
   - Detect `publish-review-comments` when the user explicitly asks to leave, post, submit, or publish findings on the PR.
   - In `external-review-context`, prefer preparing PR review comments over creating a remediation plan; remediation planning belongs to `solving-comprehensive-code-review` only when the user intends to fix the work.

6. Build the pass plan.
   - Always include `./references/code-reviewer.md` for general bug-finding.
   - Include `./references/agents-md-auditor.md` only when an applicable `AGENTS.md` governs the changed scope or the request explicitly asks for compliance/rules review.
   - Activate specialist passes only from explicit user scope or clear diff/context signals, and let each reference profile own the detailed activation heuristics and review criteria.
   - Keep `./references/code-simplifier.md` out of the initial plan; it is post-validation polish only.
   - Dispatch with category-first routing and level fallback when a category is unavailable:
     - `triage-agent` -> `quick` (fallback `low`)
     - `code-reviewer` -> `unspecified-high` (fallback `high`)
     - `agents-md-auditor` -> `unspecified-high` (fallback `high`)
     - `validator-agent` -> `unspecified-high` (fallback `high`)
     - `comment-analyzer` -> `writing` (fallback `low`)
     - `pr-test-analyzer` -> `unspecified-high` (fallback `high`)
     - `silent-failure-hunter` -> `unspecified-high` (fallback `high`)
     - `type-design-analyzer` -> `deep` (fallback `medium`)
     - `history-context-analyzer` -> `deep` (fallback `medium`)
     - `security-agent` -> `unspecified-high` (fallback `high`)
     - `performance-agent` -> `deep` (fallback `medium`)
     - `ui-ux-agent` -> `visual-engineering` (fallback `high`)
     - `architecture-agent` -> `ultrabrain` (fallback `xhigh`)
     - `code-simplifier` -> `deep` (fallback `medium`)
     - `aggregator-agent` -> `unspecified-high` (fallback `high`)

7. Apply conditional activation at a wrapper level.
   - Use the request plus diff/context shape only to decide which specialist families should be considered.
   - Leave pass-specific trigger details, scope boundaries, and issue heuristics to the referenced specialist profiles.
   - Keep `agents-md-auditor` behind explicit `AGENTS.md` context or an explicit compliance/rules request.
   - Keep `history-context-analyzer` reserved for large, cross-cutting, or intent-sensitive diffs where snapshot-only review is likely insufficient.

8. Normalize candidate categories before validation.
   - Normalize all pass outputs into final review levels: `critical`, `important`, `suggestion`, `strengths`.
   - Preserve the original pass category or schema fields for attribution even after normalization.
   - Use lightweight translation rules when a pass does not already emit final review levels:
     - severity `critical` or `high` -> `critical`
     - severity `medium` -> `important`
     - severity `low` -> `suggestion`
     - explicit positive observations -> `strengths`
   - When a pass emits ratings or another pass-specific schema instead of final severities, derive the nearest final level conservatively from the validator-supported evidence without re-implementing that profile's detailed rubric here.

9. Dispatch passes in waves.
   - First wave: run `code-reviewer`, optional `agents-md-auditor`, and all activated specialist passes in parallel.
   - Keep each pass scoped to the requested diff or changed-code surface only.
   - Preserve raw outputs, cited evidence, and pass attribution exactly as returned.
   - Do not run `code-simplifier` in the first wave.

10. Validate candidate findings.
   - Send non-empty first-wave findings to `./references/validator-agent.md`.
   - The validator may validate, adjust severity with evidence, or dismiss existing findings only; it must not create new findings.
   - Drop dismissed items and all findings below the validator confidence threshold defined in the validator profile.
   - Preserve source-pass attribution for every surviving item.

11. Optionally run the simplification pass.
    - Run `./references/code-simplifier.md` only when simplification or polish was explicitly requested, or when broad review asked for improvement suggestions after the main review is otherwise acceptable.
    - Require validation to show no open `critical` blockers before dispatching it.
    - Treat simplifier output as optional `suggestion` material, then validate it before aggregation.

12. Aggregate validated results.
    - Send only validated findings plus explicit strengths to `./references/aggregator-agent.md`.
    - Let the aggregator deduplicate materially identical findings, keep the strongest supported final severity, preserve attribution, and keep strengths separate.
    - Preserve any PR comment/thread source and any suggested publication target for each finding: line-level when the issue maps to a changed line, file-level when the issue maps to a file but no stable line, and PR-level when the issue is cross-cutting or process-wide.
    - Aggregation is reporting-only; it must not become a fresh review pass.

13. Produce the final response.
    - Return sections in this exact order: `critical`, `important`, `suggestion`, `strengths`.
    - Include concise evidence, file references, and contributing-pass attribution for each finding.
    - For PR-mode reviews, include `comment_target` metadata for every actionable finding: `line`, `file`, or `pr`, plus path/line/thread details when known.
    - If no validated findings survive, say so directly and include any meaningful strengths.
    - If GitHub/PR context was unavailable and review fell back to local diff context, say that the review used reduced context.
    - If the user asked to post review comments, prepare the comments for the chosen target level and only post when the active workflow has explicit posting approval.
    - If the user is reviewing someone else's PR and posting is not yet approved, end with the two available next steps: `post comments to the PR` or `return findings only`.

## PR Comment Publication Targets

- Use PR-level comments only for broad findings, summaries, or review conclusions that do not belong to a specific changed file or line.
- Use file-level review comments when the finding belongs to a changed file but no stable changed line should own it.
- Use line-level review comments when the finding maps to a specific changed line or multi-line range.
- Use replies when the finding answers an existing review comment or thread instead of opening a new discussion.
- Use thread resolution only after the workflow has evidence that the comment is addressed, obsolete, duplicate, or intentionally not actionable.
- Keep tool expectations accurate: `gh pr comment` is PR-level only; inline/file review comments, review-thread replies, and resolve/unresolve operations require the GitHub review comment REST API or GraphQL through `gh api`/`gh api graphql`.
- Posting remains approval-gated even when the user requested prepared comments; do not publish comments unless the active workflow explicitly approves posting.

## Fallback Rules

- If triage says not to proceed, stop immediately.
- If no specialist pass activates, run only `code-reviewer`, plus `agents-md-auditor` when compliance context applies.
- If the request names explicit passes, honor that narrower scope unless triage blocks review.
- If the request says `all`, run all conditionally applicable passes, not every reference file blindly.
- If authenticated `gh` is unavailable, prefer MCP-provided PR metadata or payloads before local diff fallback.
- If PR metadata or unresolved discussion context is unavailable, continue with diff-based review and note the reduced context.
- If PR comment/thread identifiers are unavailable, keep findings actionable but mark comment targets as `unlinked` instead of inventing IDs.
- If a pass returns no findings, continue with the remaining stages.
- If validation dismisses every candidate finding, skip dismissed items and return a clean review summary.
- If multiple passes report the same issue with different labels, preserve original labels for attribution and let validation plus aggregation determine the final merged level.
- If simplification was requested but blocker-level findings remain, skip `code-simplifier` and report why.

## Guardrails

- Stay high-signal and evidence-based.
- Keep detailed review heuristics, scoring, and detection logic in the reference profiles.
- Use this file for orchestration only: mode detection, context selection, pass selection, dispatch, normalization, validation, aggregation, and reporting.
- Do not duplicate reference-pass internals here.
- Do not activate specialist passes outside their conditional rules.
- Do not widen scope beyond the requested diff or changed code.
- Do not auto-post review comments without explicit workflow approval.
- Do not create remediation plans for someone else's PR unless the user explicitly says they own the fix or asks for a fix plan.
- Do not lose PR thread/comment traceability when unresolved review comments are part of the input.

## Role of This File

- Each reference profile owns its own scope, activation detail, and output schema.
- This wrapper owns the staged workflow glue across mode detection, triage, context gathering, agent dispatch, validation, aggregation, and final output.
- Keep helper-script behavior and implementation details outside this file except for the context-source preference order needed to orchestrate review correctly.
