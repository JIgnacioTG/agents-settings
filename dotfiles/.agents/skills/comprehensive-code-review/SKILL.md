---
name: comprehensive-code-review
description: Use when the user explicitly asks for a code review, PR review, or diff review that should be split into staged, role-based agent passes, validated, and reported. Also use it when the user wants findings posted back to someone else's PR, or when they own a PR/diff and need a traceable markdown remediation plan for validated findings.
---

# Multi-Agent Review

Run an explicit orchestration wrapper for staged, role-based review. This file decides mode, triage, context gathering, pass selection, dispatch, validation, aggregation, final output, and owner remediation-plan artifacts. Detailed heuristics stay in the reference profiles.

## Reference Profiles

### Core flow

- `./references/triage-agent.md`
- `./references/code-reviewer.md`
- `./references/agents-md-auditor.md`
- `./references/ci-check-analyzer.md`
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

## Required Reference Loading and Agent Dispatch Contract

This skill is an orchestration process, not a single-pass checklist. Every activated role must run as a delegated agent pass with its reference profile loaded before dispatch.

- Load the relevant reference file immediately before preparing that pass prompt. Do not rely on memory of the profile.
- Dispatch every activated pass through `task(...)` with the mapped `category`, `load_skills=[]`, and explicit `run_in_background` behavior. Use `subagent_type` only for named direct agents such as `explore`, `librarian`, `oracle`, `metis`, or `momus`.
- Do not merge multiple role profiles into one generic reviewer. Separate agents preserve independent failure modes and reduce skipped checks.
- Preserve each pass result, including empty results, so the final report can show which mandatory passes ran and why any conditional pass did not run.
- If a required pass cannot run because tooling is unavailable, record it as `not-run` with the concrete reason instead of silently skipping it.


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
   - When in PR mode, gather PR metadata and unresolved review discussion context if available from the chosen provider. Prefer GraphQL `reviewThreads`; if unavailable, accept REST review comments with unknown resolution state and preserve that limitation.
   - When in PR mode, gather failing or otherwise blocking CI/check status context from the chosen provider when available. Prefer `./scripts/github-integration.sh --checks` when using this skill from its directory; otherwise use equivalent `gh pr checks --json` or PR `statusCheckRollup` data.
   - Preserve CI check names, states or buckets, URLs, workflow names, events, descriptions, and timestamps so a downstream pass can report concrete PR-level issues instead of vague "CI failed" summaries.
   - Preserve unresolved thread/comment identifiers, URLs, authors, paths, lines, and outdated/resolved state so downstream remediation can reply to or resolve the exact comment rather than losing thread traceability.
   - Gather applicable `AGENTS.md` files for the changed paths when compliance context may matter.
   - Do not re-implement pass heuristics here; gather only enough to activate and feed the right profiles.

5. Determine review ownership and publication intent.
   - Treat the request as `owner-remediation-context` when the user is reviewing their own branch/work before fixing it.
   - Treat the request as `external-review-context` when the user is reviewing someone else's branch or PR and does not own the implementation work.
   - Detect `publish-review-comments` when the user explicitly asks to leave, post, submit, or publish findings on the PR.
   - In `external-review-context`, prefer preparing PR review comments over creating a remediation plan.
   - In `owner-remediation-context`, create a markdown remediation-plan artifact after validated findings are aggregated when the mode is `diff-review`, `request-review`, or `pr-review`.

6. Build the pass plan.
   - Always include `./references/code-reviewer.md` for general bug-finding.
   - Include `./references/agents-md-auditor.md` only when an applicable `AGENTS.md` governs the changed scope or the request explicitly asks for compliance/rules review.
   - Activate specialist passes only from explicit user scope or clear diff/context signals, and let each reference profile own the detailed activation heuristics and review criteria.
   - Keep `./references/code-simplifier.md` out of the first wave; it is a mandatory post-validation polish wave for broad reviews once blocker status is known.
   - Dispatch review passes through category-routed implementation delegation: pass the mapped value as `category`, not `subagent_type`. Use `subagent_type` only for named direct agents such as `explore`, `librarian`, `oracle`, `metis`, or `momus`, and never provide both `category` and `subagent_type` in the same delegation call. Use level fallback only when a category is unavailable:
     - `triage-agent` -> `quick` (fallback `low`)
     - `code-reviewer` -> `unspecified-high` (fallback `high`)
     - `agents-md-auditor` -> `unspecified-high` (fallback `high`)
     - `ci-check-analyzer` -> `quick` (fallback `low`)
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
   - Activate `ci-check-analyzer` only in `pr-review` mode when PR CI/check context contains failing, cancelled, timed-out, action-required, or otherwise blocking checks.
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
   - First wave: run `code-reviewer`, optional `agents-md-auditor`, activated `ci-check-analyzer`, and all activated specialist passes in parallel.
   - Keep each pass scoped to the requested diff or changed-code surface only.
   - Preserve raw outputs, cited evidence, and pass attribution exactly as returned.
   - Do not run `code-simplifier` in the first wave.

10. Validate candidate findings.
   - Send non-empty first-wave findings to `./references/validator-agent.md`.
   - The validator may validate, adjust severity with evidence, or dismiss existing findings only; it must not create new findings.
   - Drop dismissed items and all findings below the validator confidence threshold defined in the validator profile.
   - Preserve source-pass attribution for every surviving item.

11. Run the simplification pass as a required second wave when safe.
     - Load `./references/code-simplifier.md` and dispatch `code-simplifier` after first-wave validation for every broad `pr-review`, `diff-review`, or `request-review` unless validated `critical` blockers remain.
     - Also dispatch it for any targeted review that explicitly asks for simplification, maintainability polish, cleanup, refactoring suggestions, or broad improvement suggestions.
     - If validated `critical` blockers remain, do not dispatch `code-simplifier`; record `code-simplifier: skipped-critical-blockers` in the pass ledger and explain that simplification is deferred until correctness/security blockers are addressed.
     - Treat simplifier output as `suggestion` material only, then validate it before aggregation.
     - If the simplifier returns no findings, preserve the empty pass result so the final report proves the agent was not skipped.

12. Aggregate validated results.
     - Send only validated findings, validated simplifier suggestions, pass ledger entries, and explicit strengths to `./references/aggregator-agent.md`.
     - Let the aggregator deduplicate materially identical findings, keep the strongest supported final severity, preserve attribution, and keep strengths separate.
     - Preserve any PR comment/thread source and any suggested publication target for each finding: line-level when the issue maps to a changed line, file-level when the issue maps to a file but no stable line, and PR-level when the issue is cross-cutting or process-wide.
     - Preserve CI-check findings as PR-level findings unless the failing check output clearly identifies a changed file and stable line.
     - Aggregation is reporting-only; it must not become a fresh review pass.

13. Create an owner remediation-plan artifact when applicable.
     - Create this markdown file only for `owner-remediation-context` in `diff-review`, `request-review`, or `pr-review` mode. Do not create it for `external-review-context` unless the user explicitly says they own the fix or asks for a fix plan.
     - Save the file under `docs/plans/` at the repository root. Create the directory if it does not exist.
     - Name the file `{YYYY-mm-dd}-{plan-name}.md`, using the current local date and a short kebab-case plan name derived from the review target or dominant fix theme, for example `2026-04-26-auth-review-remediation.md`.
     - If the target filename already exists, append a numeric suffix such as `{YYYY-mm-dd}-{plan-name}-2.md` instead of overwriting it.
     - Base the plan only on validated findings and tracked PR comments; do not invent fixes for dismissed findings.
     - Use the exact plan template in `Owner Remediation Plan Artifact` below.

14. Produce the final response.
    - Return sections in this exact order: `critical`, `important`, `suggestion`, `strengths`.
    - Include concise evidence, file references, and contributing-pass attribution for each finding.
    - For PR-mode reviews, include `comment_target` metadata for every actionable finding: `line`, `file`, or `pr`, plus path/line/thread details when known.
    - For PR-mode reviews, include validated failing CI/check findings alongside code findings in the same severity sections; do not bury them in a separate status note.
    - If no validated findings survive, say so directly and include any meaningful strengths.
    - If GitHub/PR context was unavailable and review fell back to local diff context, say that the review used reduced context.
    - If an owner remediation-plan artifact was created, include both a concise summary and the project-relative saved path, for example `docs/plans/2026-04-26-auth-review-remediation.md`, and summarize which finding IDs it covers.
    - Include a compact pass ledger with every required/activated pass marked `ran`, `skipped:<reason>`, or `not-run:<reason>` so missing agents are visible.
    - If the user asked to post review comments, prepare the comments for the chosen target level and only post when the active workflow has explicit posting approval.
    - If the user is reviewing someone else's PR and posting is not yet approved, end with the two available next steps: `post comments to the PR` or `return findings only`.


## Owner Remediation Plan Artifact

When owner remediation planning is required, create a markdown file with this exact structure:

```markdown
# Comprehensive Code Review Remediation Plan

## Review source
- Source: <PR URL, local diff command, report path, or conversation>
- Scope: <branch/diff/files>
- Owner context: <why this is owner-remediation-context>
- Assumptions: <only concrete assumptions that affect execution>

## Finding map
| ID | Severity | Status | Source pass | Source comment/thread | Finding | Evidence | Fix group | Comment action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |

## Execution groups
### Group 1: <short outcome-focused name>
- Findings: <IDs>
- Why first: <dependency/risk reason>
- Files to inspect/change: <paths>
- Implementation approach:
  1. <step>
  2. <step>
- Tests to add/update: <paths or test descriptions>
- Verification: <commands/checks>
- Risks and rollback: <main risk and safe fallback>

## PR comment plan
| Comment/thread | Related finding | Action | Reply summary | Resolve when |
| --- | --- | --- | --- | --- |

## Verification matrix
| Finding ID | Required proof | Command or check |
| --- | --- | --- |

## Final options
1. Proceed to fix the findings using this plan.
2. Only leave or prepare comments for the findings in the PR.

## Open questions or blockers
- <only items that cannot be resolved from available context>
```

Plan rules:

- Choose a concise `{plan-name}` that identifies the review scope or dominant remediation theme, lowercased and slugged with hyphens.
- Assign stable finding IDs such as `CR-1`, `CR-2`, or `CRITICAL-1` and reuse them in the final response.
- Preserve severity, validator confidence, source-pass attribution, file evidence, and PR thread/comment identifiers.
- Group findings by shared root cause and implementation dependency, not by the agent that found them.
- Include reply-only actions for duplicate, not-actionable, or already-addressed PR comments so no fetched comment disappears.
- Define verification before implementation for every finding group.
- Stop after writing the plan unless the user explicitly asked to implement fixes too.

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
- If no specialist pass activates, run `code-reviewer`, plus `agents-md-auditor` when compliance context applies, then run `code-simplifier` as the second wave when no validated `critical` blockers remain.
- If the request names explicit passes, honor that narrower scope unless triage blocks review.
- If the request says `all`, run all conditionally applicable passes, not every reference file blindly.
- If authenticated `gh` is unavailable, prefer MCP-provided PR metadata or payloads before local diff fallback.
- If PR metadata or unresolved discussion context is unavailable, continue with diff-based review and note the reduced context.
- If CI/check context is unavailable in PR mode, continue with the review and note that failing check status could not be fetched.
- If CI/check context is available but has no failing or blocking checks, do not activate `ci-check-analyzer` and do not mention CI unless useful for context.
- If PR comment/thread identifiers are unavailable, keep findings actionable but mark comment targets as `unlinked` instead of inventing IDs.
- If a pass returns no findings, continue with the remaining stages.
- If validation dismisses every candidate finding, skip dismissed items and return a clean review summary.
- If multiple passes report the same issue with different labels, preserve original labels for attribution and let validation plus aggregation determine the final merged level.
- If simplification was requested or broad review would normally require polish but blocker-level findings remain, skip `code-simplifier` and report why in the pass ledger.

## Guardrails

- Stay high-signal and evidence-based.
- Keep detailed review heuristics, scoring, and detection logic in the reference profiles.
- Use this file for orchestration only: mode detection, context selection, pass selection, dispatch, normalization, validation, aggregation, remediation-plan artifact creation, and reporting.
- Do not duplicate reference-pass internals here.
- Do not activate specialist passes outside their conditional rules.
- Do not widen scope beyond the requested diff or changed code.
- Do not auto-post review comments without explicit workflow approval.
- Do not create remediation-plan artifacts for someone else's PR unless the user explicitly says they own the fix or asks for a fix plan.
- Do not lose PR thread/comment traceability when unresolved review comments are part of the input.

## Role of This File

- Each reference profile owns its own scope, activation detail, and output schema.
- This wrapper owns the staged workflow glue across mode detection, triage, context gathering, agent dispatch, validation, aggregation, owner remediation-plan artifacts, and final output.
- Keep helper-script behavior and implementation details outside this file except for the context-source preference order needed to orchestrate review correctly.
