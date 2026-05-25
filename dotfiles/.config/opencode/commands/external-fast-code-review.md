---
description: External fast GitHub PR review focused on AGENTS.md compliance and readability
---

# External Fast Code Review

Run a narrow external review for someone else's GitHub PR, focused on project-rule compliance and code readability.

**Arguments:** "$ARGUMENTS"

## Required input

- `$ARGUMENTS` must include a GitHub PR URL.
- If no GitHub PR URL is present, stop and ask for the PR link.

## Scope

Review only the GitHub PR diff. Keep the review fast and focused on:

1. **AGENTS.md compliance**: Find applicable `AGENTS.md` files for changed paths and flag clear violations only.
2. **Readability and simplification**: Identify concrete simplifications that preserve behavior, improve maintainability, reduce unnecessary nesting or indirection, and align with project style.
3. **No suppression shortcuts**: Flag new or suspicious lint/type/test suppressions such as `noqa`, `eslint-disable`, `biome-ignore`, `ruff: noqa`, `@ts-ignore`, `@ts-expect-error`, or similar comments when a code fix should be proposed instead.
4. **Actionable solutions**: For every finding, provide a specific fix direction or replacement approach.

## Dispatch

1. Resolve the GitHub PR URL from `$ARGUMENTS` and fetch PR metadata plus the changed-file diff with `gh` when available.
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

Return sections in this order:

1. `comments posted`
2. `important`
3. `suggestion`
4. `smells not commented`
5. `strengths`
6. `review decision`
7. `pass ledger`

For each finding include:

- File path and line when available.
- The applicable rule or readability concern.
- Why it matters.
- A concrete solution.
- PR comment target metadata when available.
- Whether a Spanish PR comment was posted.

Keep the final report detailed enough for traceability, but keep posted PR comment bodies limited to the issue and suggested fix/snippet.

If there are no validated findings, say so directly, include any meaningful strengths, and approve the PR. Keep weak or non-actionable smells in `smells not commented` instead of posting them.
