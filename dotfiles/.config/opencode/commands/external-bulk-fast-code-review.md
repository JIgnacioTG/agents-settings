---
description: Bulk external fast GitHub PR review with selection and Spanish approvals
---

# Bulk External Fast Code Review

Discover open GitHub PRs for the current repository where the current GitHub user is not the PR author, let the user choose which PRs to review, then run the external fast review path for each selected PR.

**Arguments:** "$ARGUMENTS"

## Discovery

1. Use `gh repo view --json owner,name` to resolve the current repository.
2. Use `gh api user --jq .login` to resolve the current GitHub login.
3. List open PRs with `gh pr list --state open --limit 100 --json number,title,author,url,reviewDecision,reviewRequests,isDraft,updatedAt`.
4. Exclude PRs authored by the current GitHub login.
5. For every remaining PR, determine our previous review state with `gh pr view <number> --json reviews --jq` or `gh api repos/<owner>/<repo>/pulls/<number>/reviews`:
   - `approved by us` when the latest non-dismissed review by the current login is `APPROVED`.
   - `reviewed by us` when the latest non-dismissed review by the current login is `COMMENTED`, `CHANGES_REQUESTED`, or another non-approval review state.
   - `not reviewed by us` when no review by the current login exists.
6. Sort remaining PRs in this priority order: ready PRs that are `not reviewed by us`, ready PRs that are `reviewed by us`, then `approved by us` and draft PRs.
7. Show a compact selection table including PR number, author, draft status, title, URL, GitHub `reviewDecision`, and our previous review state.
8. Always return the table as normal assistant output before asking any selectable question. Never put the table or table rows inside the question text or selectable options.

## Selection

- If `$ARGUMENTS` includes PR numbers, review only those PRs after confirming they are open and not authored by the current GitHub login.
- If `$ARGUMENTS` includes `--all`, review every discovered eligible PR.
- Otherwise, after showing the table, ask the user to select ready PR numbers from options ordered by the same priority: `not reviewed by us`, then `reviewed by us`.
- Treat ready PRs that are `not reviewed by us` or `reviewed by us` as the primary selectable group. Skip draft PRs and `approved by us` PRs from the default options unless the user explicitly asks to include them or names those PR numbers.
- Do not start review agents until the selection is known.
- If no eligible PRs exist, say so and stop.

## Review path per selected PR

For each selected PR, run the same fast path defined by `external-fast-code-review`:

1. Fetch PR metadata and changed-file diff with `gh`.
2. Find all applicable `AGENTS.md` files for changed paths before review.
3. Dispatch exactly these first-wave review passes in parallel with `task(..., run_in_background=true)` and `load_skills=[]`:
   - `agents-md-auditor` profile through category `unspecified-high`, using the applicable `AGENTS.md` files and changed diff.
   - `code-simplifier` profile through category `deep`, using the changed diff and project conventions.
4. Validate the returned candidates before reporting. Drop anything that is not supported by the PR diff or applicable rules.
5. Do not run broad bug, tests, security, performance, type-design, history, UI/UX, architecture, or CI passes unless the user explicitly expands the scope.

## PR review decision

- Write every PR comment in Spanish.
- Keep every posted PR comment concise: state only the issue and the suggested fix.
- Prefer a small replacement snippet when it makes the fix clearer.
- Do not include extended technical analysis, pass attribution, evidence trails, or broad rationale in posted PR comments.
- Post validated findings as PR comments when they have a stable PR comment target.
- Normally grant PR approval after posting comments.
- Request changes instead of approving only when a critical bug is found.
- If no validated findings are found, grant PR approval.
- Do not create a remediation-plan artifact.

## Output

Return one summary block per reviewed PR, then a final bulk summary.

For each PR, use sections in this order:

1. `PR reviewed`
2. `comments posted`
3. `important`
4. `suggestion`
5. `smells not commented`
6. `strengths`
7. `review decision`
8. `pass ledger`

For each finding include:

- File path and line when available.
- The applicable rule or readability concern.
- Why it matters.
- A concrete solution.
- PR comment target metadata when available.
- Whether a Spanish PR comment was posted.

Keep each summary block detailed enough for traceability, but keep posted PR comment bodies limited to the issue and suggested fix/snippet.

The final bulk summary must list:

- PRs reviewed.
- PR comments posted, grouped by PR.
- Review decisions submitted.
- Smells intentionally not posted.
- PRs skipped and the reason.

If there are no validated findings for a PR, say so directly, include any meaningful strengths, and approve the PR. Keep weak or non-actionable smells in `smells not commented` instead of posting them.
