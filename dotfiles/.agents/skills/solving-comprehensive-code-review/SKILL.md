---
name: solving-comprehensive-code-review
description: Use when the user wants to resolve, fix, implement, or plan remediation for findings produced by the `comprehensive-code-review` skill or a similarly structured review report. This skill turns validated review findings and PR review comments into a concrete implementation plan before coding, preserving traceability from each finding/comment to files, tests, replies, resolution steps, verification, risks, and execution order.
---

# Solving Comprehensive Code Review Findings

Use this skill after a review has already produced findings. The goal is not to re-run the review; the goal is to convert the review output into an actionable remediation plan that can be executed safely.

## Activation

Activate for requests such as:

- "solve the comprehensive-code-review findings"
- "create a plan to fix this code review"
- "turn these critical/important/suggestion findings into implementation tasks"
- "implement the review feedback" when the feedback comes from `comprehensive-code-review`
- "plan how to resolve these PR review findings"

Do not activate for a fresh review request. Use `comprehensive-code-review` for reviewing code; use this skill only after findings exist.

## Inputs to Collect

Gather only the context needed to plan remediation:

- The complete review report or unresolved review comments.
- The target branch, PR, diff, or changed files referenced by the findings.
- Any validator output, confidence scores, severity labels, and source-pass attribution.
- PR comment/thread identifiers, URLs, authors, paths, lines, and resolved/outdated state when findings came from GitHub review comments.
- Project instructions such as `AGENTS.md`, package scripts, test commands, and relevant implementation conventions.
- Related tests or fixtures named by the findings.

If the review report is missing, ask for it or locate it from the active conversation, PR comments, saved artifacts, or local files. Do not invent findings.

## Planning Workflow

1. Normalize the findings.
   - Preserve the review severity buckets: `critical`, `important`, `suggestion`, and optional `strengths`.
   - Assign every actionable finding a stable ID such as `CR-1`, `CR-2`, or `CRITICAL-1`.
   - Keep each finding's original summary, evidence, file references, and attribution.
   - Link each finding to its source PR comment/thread when available; one finding may map to multiple comments, and one comment may require multiple fix tasks.
   - Separate non-actionable strengths from remediation work.

2. Validate actionability without re-reviewing.
   - Confirm each finding has enough code or diff evidence to plan a fix.
   - Mark findings as `ready`, `needs-context`, `duplicate`, `blocked`, or `not-actionable`.
   - If a finding is `duplicate` or `not-actionable` and came from a PR comment, create an `only-reply` action instead of an implementation group so the comment still receives a clear response.
   - Do not dismiss a validated finding casually. If it appears wrong, plan a verification step to prove or disprove it before implementation.

3. Inspect implementation context.
   - Read the cited files and nearby tests.
   - Search for existing patterns that solve the same kind of issue.
   - Identify APIs, type boundaries, error-handling conventions, and test style before proposing changes.
   - For unfamiliar external libraries, consult official docs or examples before planning library-specific fixes.

4. Build the remediation strategy.
   - Group findings that share a root cause or must be fixed together.
   - Order work by dependency and risk: critical correctness/security first, then important regressions, then suggestions.
   - Prefer the smallest safe code change that addresses the validated impact.
   - Identify whether each group should be executed directly or delegated, using the domain that matches the work: backend, frontend, test, security, performance, architecture, or docs.

5. Define verification before implementation.
   - Map every finding or group to concrete checks: unit tests, integration tests, typecheck, lint, focused manual checks, or PR-specific commands.
   - Include regression tests for bug findings unless the project has a clear reason not to.
   - For UI/UX fixes, include accessibility and interaction checks when relevant.
   - For security or data-loss findings, include negative-path and boundary-condition checks.

6. Plan PR comment handling.
   - For each source PR comment, decide whether the plan should reply, resolve, or leave open.
   - Reply to every fetched comment that is addressed by the plan, including duplicate and not-actionable comments.
   - Mark comments as solved/resolved only after the corresponding code change and verification proof are complete.
   - For duplicate comments, reply with the canonical finding ID or canonical thread that will address it.
   - For not-actionable comments, reply with concise evidence explaining why no code change is planned.
   - Keep comment operations separate from code changes so they can be executed after verification.
   - Keep tool expectations accurate: PR-level conversation comments can use `gh pr comment`, but inline/file review comments, replies to review comments or threads, and resolve/unresolve operations require GitHub REST or GraphQL via `gh api`/`gh api graphql`.

7. Produce the plan and stop unless the user explicitly asked to execute it too.
   - The default output is a remediation plan, not code changes.
   - If the user explicitly asked to implement, still produce the plan first, then proceed through it in order.
   - End the plan with two options when PR context exists: proceed to fix the findings, or only leave/comment the findings in the PR.

## Required Plan Format

Return the plan in this structure:

```markdown
# Comprehensive Code Review Remediation Plan

## Review source
- Source: <PR URL, local report path, pasted report, or conversation>
- Scope: <branch/diff/files>
- Assumptions: <only concrete assumptions that affect execution>

## Finding map
| ID | Severity | Status | Source comment/thread | Finding | Evidence | Fix group | Comment action |
| --- | --- | --- | --- | --- | --- | --- | --- |

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
2. Only leave comments for the findings in the PR.

## Open questions or blockers
- <only items that cannot be resolved from available context>
```

Keep the plan concrete enough that another agent or engineer can execute it without reinterpreting the review. Avoid vague tasks like "fix error handling"; name the function, behavior, expected state, and test proof when known.

## Execution Rules When Implementation Is Requested

- Work group-by-group; complete verification for one group before starting the next when practical.
- Preserve traceability in progress updates by referencing finding IDs.
- Do not widen scope beyond the review findings unless a minimal supporting refactor is necessary.
- Do not suppress types or tests to satisfy a finding.
- Do not delete failing tests to make verification pass.
- After implementation, report each finding ID as `resolved`, `partially resolved`, or `not resolved`, with evidence.
- After verification, reply to and mark solved/resolved each tracked PR comment according to the PR comment plan.
- If the user chooses comment-only mode, do not modify code; prepare or post the PR comments according to explicit posting approval.

## Output Rules

- Be evidence-based and cite files or findings.
- Distinguish planning confidence from implementation certainty.
- If review context is incomplete, create a plan with `needs-context` entries instead of fabricating details.
- If all findings are suggestions, still sequence them by risk and return a verification plan.
- If there are no actionable findings, say so directly and list any strengths or non-actionable notes separately.
- If a finding came from a PR comment, never drop it silently; it must appear in the finding map or PR comment plan as implementation, reply-only, blocked, or already-resolved.
