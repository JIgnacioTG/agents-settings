---
name: comprehensive-code-review
description: Use when the user explicitly asks for a code review, PR review, or diff review that should be split into staged, role-based agent passes, validated, and reported. Also use it when the user wants findings posted back to someone else's PR, or when they own a PR/diff and need a traceable markdown remediation plan for validated findings.
---

# Multi-Agent Review

Run an explicit orchestration wrapper for staged, role-based review. This file decides mode, triage, context gathering, pass selection, dispatch, validation, aggregation, final output, and owner remediation-plan artifacts. Detailed heuristics stay in the reference profiles.

## OpenCode Entry Point

This skill is the canonical workflow. The `/comprehensive-code-review` command is only a thin launcher that passes the user's request into this skill. Keep triage, context rules, pass activation, validation, aggregation, remediation planning, and final reporting here only.

If command text and this skill ever conflict, follow this skill. The command must not maintain a second pass table, setup workflow, validation flow, or output contract because duplicated orchestration drifts and causes specialists to be skipped.

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
- Dispatch every activated OpenCode pass through `task(...)` with the mapped `category`, `load_skills=[]`, explicit `run_in_background` behavior, and the relevant reference profile content copied into that pass prompt. First-wave review passes use `run_in_background=true`; dependent validation, aggregation, and any grouped second-wave passes use `run_in_background=false`. Preserve parallelism in second-wave work by issuing multiple synchronous `task(..., run_in_background=false)` calls in the same tool turn or parallel tool batch, then wait for every returned result before continuing. Do not use `subagent_type` for review passes because direct OpenCode subagents bypass Oh My OpenAgent category/model routing.
- Do not merge multiple role profiles into one generic reviewer. Separate agents preserve independent failure modes and reduce skipped checks. A broad comprehensive review that only ran `code-reviewer` is incomplete unless triage explicitly narrowed the request to general bug review only.
- Preserve each pass result, including empty results, outside the principal chat context when possible, so the final report can show which mandatory passes ran and why any conditional pass did not run without forcing every raw transcript through the principal agent. For synchronous second-wave passes, capture the returned task output immediately in the ledger because there is no background handle to recover later.
- Keep the principal context compact by maintaining a durable normalized review ledger
  immediately after every dispatch: pass name, category, `background_task_id`,
  `session_id`, status, activation reason, skip/not-run reason, finding IDs,
  severity, confidence, evidence pointers, and PR comment/thread IDs. Store raw
  pass outputs and bulky PR context in files or task transcripts; feed later
  stages the normalized ledger plus only the evidence slices they need.
- Treat the ledger's dispatch metadata as the only source of truth for launched passes. For background first-wave rows, store `background_task_id` and `session_id`; for synchronous second-wave rows, store `run_in_background=false`, completion status, and the returned output. Never rely on memory of task handles, prose summaries, or later session search to decide whether a pass already ran.
- Do not pre-compact review evidence before specialist passes. Each activated pass should receive the raw review surface needed for its role, such as the relevant diff, changed files, PR metadata, failing CI data, unresolved comments, and applicable `AGENTS.md` rules, with concise scope boundaries rather than lossy principal-agent summaries.
- If a required pass cannot run because tooling is unavailable, record it as `not-run` with the concrete reason instead of silently skipping it.

## Durable Pass Ledger and No-Rerun Recovery

Every review wave must be recoverable without launching duplicate agents.

- Immediately after each first-wave `task(..., run_in_background=true)` dispatch, copy both identifiers from the tool result into the ledger: `background_task_id` and `session_id`. Do this before dispatching dependent validation, simplification, or aggregation work.
- Dispatch dependent second-wave passes with `run_in_background=false`. This applies to `validator-agent`, `aggregator-agent`, and any split/grouped validation or aggregation pass. Synchronous calls return their output directly, so record the output and status in the ledger immediately and do not call `background_output` or session recovery for those rows.
- Preserve the parallel wave shape for second-wave work without background handles: when multiple validation or aggregation groups are needed, issue those synchronous `task(..., run_in_background=false)` calls together in one parallel tool batch. Treat the whole batch as the wave boundary and wait for every returned output before aggregation or final reporting. Do not advance with partial second-wave results.
- Before collecting a wave, read the ledger and call `background_output` exactly
  once per recorded `background_task_id` after completion notification. Attach
  the returned raw output or empty-result marker to that ledger row.
- If `background_output` cannot return a result because the background handle is
  missing, expired, or unavailable, recover the already-launched pass with
  `session_read(session_id=<ledger session_id>, include_transcript=false,
  limit=<small-window>)` and extract the final pass output from the session
  messages. Record `recovered-from-session:<session_id>` in the ledger.
- Use `include_transcript=true` only as a bounded last resort when normal session
  messages do not contain the final pass output. Keep the `limit` as small as the
  tool allows for the missing output; never load a full long review transcript
  just to recover a pass result.
- If both background output and session recovery fail, mark that pass
  `not-run:lost-output:<reason>` and report the loss in the pass ledger. Do not
  silently continue as if it ran.
- Never rerun a pass solely to recover output, refresh a handle, recreate a lost
  `background_task_id`, or fill a missing transcript. Rerun only when the review
  surface changed or the previous pass explicitly failed before producing any
  usable result; record the original failed row and the new row separately.
- Validation and aggregation must consume the ledger's collected or session-recovered first-wave results. They must not trigger first-wave agents again. Because they are synchronous second-wave passes, their returned outputs become the ledger entries for later steps without async recovery.
- Do not write fallback language such as "task handles expired, so I am
  rerunning". Expired handles require session recovery or an explicit
  `not-run:lost-output` ledger entry, never duplicate execution.


## Orchestration Workflow

1. Confirm this skill should activate.
   - Activate only for explicit review requests: code review, PR review, diff review, commit review, changed-code review, pass-based review, or equivalent.
   - Detect the requested mode from the prompt and available artifacts:
     - `pr-review`: PR URL, PR number, branch-linked PR, or explicit PR wording.
     - `diff-review`: patch, diff, commit range, merge-base comparison, or branch comparison.
     - `request-review`: changed-code review without a formal PR.
     - `targeted-review`: explicit narrowing to code, tests, comments, security, performance, architecture, types, UI/UX, simplification, or compliance.
   - If review was not explicitly requested, do not run this skill.

2. Resolve review surface and PR context before triage.
   - The changed-code diff is the review surface and is mandatory for every review mode. For PR reviews, gather the PR diff; for diff/request reviews, gather the requested patch, commit range, branch comparison, or local changed-code diff.
   - Prefer GitHub PR context from authenticated `gh` whenever the prompt names a PR, the current branch has a related PR, or the review target can be mapped to a PR.
   - If `gh` context is unavailable, use MCP-provided PR metadata, diff payloads, and unresolved-thread payloads when present.
   - If no PR context exists, continue with the resolved diff or changed-code review surface.
   - Preserve which source was used so later output can mention reduced context when necessary.

3. Run triage first.
   - Load `./references/triage-agent.md` before any deep review.
   - Give triage the resolved review mode, diff target, PR state when known, `reviewDecision` when available, and whether unresolved comments or prior review discussions were found.
   - Triage classifies scope, priority, and contextual risks; it does not block PR review because a PR is draft, closed, previously reviewed, automated, or already has `reviewDecision: true`. Those states are context that can reduce urgency, change emphasis, or explain residual risk.
   - Triage may return `proceed: false` only when there is no reviewable diff or changed-code surface, the explicit target cannot be resolved, or the request is not actually a review request.
   - If triage returns `proceed: false`, stop immediately and return only the short reason.

4. Gather and preserve bounded orchestration context.
   - Collect the review target, changed files, raw diff or changed-code surface, and any explicitly requested review angles.
   - Whenever a related PR exists in any status, gather PR metadata and unresolved review discussion context if available from the chosen provider. Prefer GraphQL `reviewThreads`; if unavailable, accept REST review comments with unknown resolution state and preserve that limitation.
   - Whenever a related PR exists, gather failing or otherwise blocking CI/check status context from the chosen provider when available. Prefer `./scripts/github-integration.sh --checks` when using this skill from its directory; otherwise use equivalent `gh pr checks --json` or PR `statusCheckRollup` data.
   - Preserve CI check names, states or buckets, URLs, workflow names, events, descriptions, and timestamps so a downstream pass can report concrete PR-level issues instead of vague "CI failed" summaries.
   - Preserve unresolved thread/comment identifiers, URLs, authors, paths, lines, and outdated/resolved state so downstream remediation can reply to or resolve the exact comment rather than losing thread traceability.
   - In owner PR flows, treat every fetched unresolved PR comment/thread as a tracked remediation obligation, even when it is duplicate, obsolete, already addressed, unclear, or ultimately not a validated code finding. The plan must account for each comment with either a fix path or an explicit reply-and-resolve path.
   - Gather applicable `AGENTS.md` files for the changed paths when compliance context may matter.
   - Do not run a summarizer or principal-agent compaction pass before specialist dispatch. If the diff is too large, split by changed file groups and keep a per-group ledger instead of replacing source evidence with a summary.
   - Do not re-implement pass heuristics here; gather only enough to activate and feed the right profiles.

5. Determine review ownership and publication intent.
   - Treat the request as `owner-remediation-context` when the user is reviewing their own branch/work before fixing it.
   - Treat the request as `external-review-context` when the user is reviewing someone else's branch or PR and does not own the implementation work.
   - Detect `publish-review-comments` when the user explicitly asks to leave, post, submit, or publish findings on the PR.
   - In `external-review-context`, prefer preparing PR review comments over creating a remediation plan.
   - In `owner-remediation-context`, create a markdown remediation-plan artifact after validated findings are aggregated when the mode is `diff-review`, `request-review`, or `pr-review`.
   - In owner `pr-review` mode with fetched unresolved comments, make comment closure a first-class outcome of the remediation plan: every tracked comment must be solved by implementation and later resolved, or answered with a concrete reply and later resolved when it is duplicate, obsolete, non-actionable, already addressed, or blocked by a decision outside the diff.

6. Build the pass plan.
   - Always include `./references/code-reviewer.md` for general bug-finding.
   - Include `./references/agents-md-auditor.md` only when an applicable `AGENTS.md` governs the changed scope or the request explicitly asks for compliance/rules review.
   - Activate specialist passes only from explicit user scope or clear diff/context signals, and let each reference profile own the detailed activation heuristics and review criteria.
   - Always include `./references/code-simplifier.md` as a first-wave readability pass for every reviewable changed-code surface. It is not conditional on blocker status, requested scope, or whether other specialists activate.
   - Dispatch review passes through Oh My OpenAgent categories. Pass the mapped value as `category`, not `subagent_type`, and never provide both in the same delegation call. Copy the named reference profile into the prompt so the category-routed Sisyphus-Junior still performs the specialist role:
     - `triage-agent` -> `quick`
     - `code-reviewer` -> `unspecified-high`
     - `agents-md-auditor` -> `unspecified-high`
     - `ci-check-analyzer` -> `quick`
     - `validator-agent` -> `unspecified-high`
     - `comment-analyzer` -> `writing`
     - `pr-test-analyzer` -> `unspecified-high`
     - `silent-failure-hunter` -> `unspecified-high`
     - `type-design-analyzer` -> `deep`
     - `history-context-analyzer` -> `deep`
     - `security-agent` -> `unspecified-high`
     - `performance-agent` -> `deep`
     - `ui-ux-agent` -> `visual-engineering`
     - `architecture-agent` -> `ultrabrain`
     - `code-simplifier` -> `deep`
     - `aggregator-agent` -> `unspecified-high`
   - Never silently fold a specialist profile into `code-reviewer`; if a pass cannot run, mark it `not-run:<reason>` in the ledger.

7. Apply conditional activation at a wrapper level.
   - Use the request plus diff/context shape only to decide which specialist families should be considered.
   - Leave pass-specific trigger details, scope boundaries, and issue heuristics to the referenced specialist profiles.
   - Keep `agents-md-auditor` behind explicit `AGENTS.md` context or an explicit compliance/rules request.
   - Activate `ci-check-analyzer` whenever related PR CI/check context contains failing, cancelled, timed-out, action-required, or otherwise blocking checks.
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
   - First wave: run `code-reviewer`, `code-simplifier`, optional `agents-md-auditor`, activated `ci-check-analyzer`, and all activated specialist passes in parallel.
   - Keep each pass scoped to the requested diff or changed-code surface only.
   - For each first-wave dispatched pass, immediately record the returned
     `background_task_id` and `session_id` in the durable pass ledger before
     moving to the next stage.
   - Preserve raw outputs, cited evidence, and pass attribution in the raw-output store or task transcripts. Keep the principal-agent working set to the normalized ledger plus concise evidence pointers.
   - Treat simplifier output as `suggestion` material only; it must not block or replace correctness, security, or stability findings.

10. Validate candidate findings.
   - Collect first-wave results from the durable pass ledger. If a background
     handle is unavailable, recover from the recorded `session_id`; do not rerun
     the first-wave pass.
   - Send non-empty first-wave findings and simplifier suggestions to `./references/validator-agent.md` with `task(..., run_in_background=false)`. If the review was split into multiple validation groups, dispatch every validator call synchronously in the same parallel tool batch and wait for all returned outputs before continuing.
   - The validator may validate, adjust severity with evidence, or dismiss existing findings only; it must not create new findings.
   - Drop dismissed items and all findings below the validator confidence threshold defined in the validator profile.
   - Preserve source-pass attribution for every surviving item.

11. Preserve the simplification pass result.
   - `code-simplifier` is expected to run in the first wave for every reviewable changed-code surface.
   - If the simplifier returns no findings, preserve the empty pass result in the ledger so the final report proves the agent was not skipped.
   - If the simplifier cannot run because tooling is unavailable, record `code-simplifier: not-run:<reason>` in the pass ledger.

12. Aggregate validated results.
   - Send only validated findings, validated simplifier suggestions, pass ledger entries, and explicit strengths to `./references/aggregator-agent.md` with `task(..., run_in_background=false)`. If aggregation is split by group, dispatch the synchronous aggregator calls together in a parallel tool batch and wait for every returned result before final synthesis. Do not dispatch aggregation as a background task; the final report depends on its returned output in the current turn.
   - Let the aggregator deduplicate materially identical findings, keep the strongest supported final severity, preserve attribution, and keep strengths separate.
   - Include ledger recovery status for every pass, including `ran`,
     `recovered-from-session:<session_id>`, `skipped:<reason>`, and
     `not-run:<reason>`; aggregation must not compensate for a missing pass by
     launching a new review pass.
   - Preserve any PR comment/thread source and any suggested publication target for each finding: line-level when the issue maps to a changed line, file-level when the issue maps to a file but no stable line, and PR-level when the issue is cross-cutting or process-wide.
   - Carry forward tracked owner-PR comments separately from validated findings so comments that do not become findings still reach the remediation plan.
   - Preserve CI-check findings as PR-level findings unless the failing check output clearly identifies a changed file and stable line.
   - Aggregation is reporting-only; it must not become a fresh review pass.

13. Create an owner remediation-plan artifact when applicable.
     - Create this markdown file only for `owner-remediation-context` in `diff-review`, `request-review`, or `pr-review` mode. Do not create it for `external-review-context` unless the user explicitly says they own the fix or asks for a fix plan.
     - Save the file under `docs/plans/` at the repository root. Create the directory if it does not exist.
     - Name the file `{YYYY-mm-dd}-{plan-name}.md`, using the current local date and a short kebab-case plan name derived from the review target or dominant fix theme, for example `2026-04-26-auth-review-remediation.md`.
     - If the target filename already exists, append a numeric suffix such as `{YYYY-mm-dd}-{plan-name}-2.md` instead of overwriting it.
     - Base the plan only on validated findings and tracked PR comments; do not invent fixes for dismissed findings.
     - For owner PR reviews, include every fetched unresolved PR comment/thread in the plan. A comment may share a validated finding, create a comment-only action, or be classified as duplicate/obsolete/not-actionable/already-addressed, but it must not disappear from the plan.
     - Assign stable comment action IDs such as `PC-1`, `PC-2` for tracked PR comments that do not map cleanly to a validated finding. Use those IDs in the comment plan and verification matrix so implementation can close them deliberately.
     - Each tracked PR comment must have one of these comment actions: `fix-and-resolve`, `reply-and-resolve`, or `blocked-needs-owner-decision`. Prefer `fix-and-resolve` when the comment identifies a real defect or requested change in scope; use `reply-and-resolve` for duplicate, obsolete, already-addressed, not-actionable, or explanation-only comments; use `blocked-needs-owner-decision` only when resolving would require a decision unavailable from the review context.
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
| Comment/thread | Action ID | Related finding | Action | Reply summary | Resolve when |
| --- | --- | --- | --- | --- | --- |

## Verification matrix
| Finding/action ID | Required proof | Command or check |
| --- | --- | --- |

## Final options
1. Proceed to fix the findings and close the tracked PR comments using this plan.
2. Only leave or prepare comments for the findings and tracked PR comments in the PR.

## Open questions or blockers
- <only items that cannot be resolved from available context>
```

Plan rules:

- Choose a concise `{plan-name}` that identifies the review scope or dominant remediation theme, lowercased and slugged with hyphens.
- Assign stable finding IDs such as `CR-1`, `CR-2`, or `CRITICAL-1` and reuse them in the final response.
- Preserve severity, validator confidence, source-pass attribution, file evidence, and PR thread/comment identifiers.
- Group findings by shared root cause and implementation dependency, not by the agent that found them.
- Include every fetched unresolved PR comment/thread in `## PR comment plan`; no comment may be dropped because it is duplicate, obsolete, already addressed, not actionable, or not tied to a validated finding.
- Use `fix-and-resolve` when implementation will satisfy the comment, and state the proof required before resolving the thread.
- Use `reply-and-resolve` when the correct owner action is a reply rather than code, and draft the reply summary specific enough that it can be posted later before marking the thread resolved.
- Use `blocked-needs-owner-decision` only when neither a fix nor a truthful reply can be chosen from available context, and list the blocker under `## Open questions or blockers`.
- Define verification before implementation for every finding group.
- Stop after writing the plan unless the user explicitly asked to implement fixes too.

## PR Comment Publication Targets

- Use PR-level comments only for broad findings, summaries, or review conclusions that do not belong to a specific changed file or line.
- Use file-level review comments when the finding belongs to a changed file but no stable changed line should own it.
- Use line-level review comments when the finding maps to a specific changed line or multi-line range.
- Use replies when the finding answers an existing review comment or thread instead of opening a new discussion.
- Use thread resolution only after the workflow has evidence that the comment is addressed, obsolete, duplicate, or intentionally not actionable.
- In owner remediation execution, do not finish with unresolved tracked comments: after code fixes or reply-only decisions are verified, post the needed replies and resolve the corresponding threads when the workflow has explicit approval and the GitHub API capability is available.
- Keep tool expectations accurate: `gh pr comment` is PR-level only; inline/file review comments, review-thread replies, and resolve/unresolve operations require the GitHub review comment REST API or GraphQL through `gh api`/`gh api graphql`.
- Posting remains approval-gated even when the user requested prepared comments; do not publish comments unless the active workflow explicitly approves posting.

## Fallback Rules

- If triage says not to proceed, stop immediately only when there is no reviewable diff or changed-code surface, the explicit target cannot be resolved, or the request is not actually a review request.
- If no conditional specialist pass activates, still run both always-on first-wave passes: `code-reviewer` and `code-simplifier`, plus `agents-md-auditor` when compliance context applies.
- If conditional specialist passes do activate, still run `code-simplifier` in the first wave; it is never only a fallback pass.
- If the request names explicit passes, honor that narrower scope unless triage blocks review.
- If the request says `all`, run all conditionally applicable passes, not every reference file blindly.
- If authenticated `gh` is unavailable, prefer MCP-provided PR metadata or payloads before local diff fallback.
- If PR metadata or unresolved discussion context is unavailable, continue with diff-based review and note the reduced context.
- If CI/check context is unavailable for a related PR, continue with the review and note that failing check status could not be fetched.
- If CI/check context is available but has no failing or blocking checks, do not activate `ci-check-analyzer` and do not mention CI unless useful for context.
- If PR comment/thread identifiers are unavailable, keep findings actionable but mark comment targets as `unlinked` instead of inventing IDs.
- If a pass returns no findings, continue with the remaining stages.
- If validation dismisses every candidate finding, skip dismissed items and return a clean review summary.
- If multiple passes report the same issue with different labels, preserve original labels for attribution and let validation plus aggregation determine the final merged level.
- If `code-simplifier` cannot run, report the concrete `not-run` reason in the pass ledger.

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
