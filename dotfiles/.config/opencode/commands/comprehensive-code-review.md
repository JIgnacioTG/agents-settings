---
description: Deterministic comprehensive code review with specialized subagents
---

# Comprehensive Code Review

Use the `comprehensive-code-review` skill as the canonical workflow, but execute each review pass through Oh My OpenAgent category routing so every pass receives the category/model fit defined in `oh-my-openagent.json`.

**Arguments:** "$ARGUMENTS"

## Non-negotiable dispatch contract

- Do not set or switch to a custom OpenCode review agent for this command.
- Use `task(...)` for every review pass.
- Every `task(...)` call must include `category`, `load_skills=[]`, and explicit `run_in_background`.
- Do not use `subagent_type` for review passes; direct subagents bypass OMO category/model routing.
- Each pass prompt must include the pass name and the relevant `comprehensive-code-review/references/*.md` profile content before dispatch.
- Never merge multiple pass profiles into one prompt or one agent.
- Preserve a pass ledger with `ran`, `skipped:<reason>`, or `not-run:<reason>` for every mandatory or activated pass.
- A broad comprehensive review that only runs `code-reviewer` is incomplete unless triage explicitly narrows the request to general bug review only.

## Review surface

Resolve the requested review target from `$ARGUMENTS`:

1. PR URL, PR number, or branch-linked PR.
2. Explicit diff, commit range, or file list.
3. Local changed-code diff when no target is supplied.

For PR targets, use `gh` to gather PR metadata, diff, unresolved review discussion context when available, and check status. If any PR context source is unavailable, continue with the diff and record the reduced context in the ledger.

## Mandatory setup passes

Run these before review passes:

1. `pr-triage` synchronously to confirm there is a reviewable surface and identify the review mode.
2. `config-finder` synchronously to locate relevant `AGENTS.md` files for changed paths.
3. `pr-summarizer` synchronously to summarize author intent, changed files, and risky areas.

Use this shape:

```text
task(category="quick", load_skills=[], run_in_background=false, prompt="PASS: triage-agent\nPROFILE: <paste triage-agent.md>\n...")
task(category="quick", load_skills=[], run_in_background=false, prompt="PASS: config-finder\nPROFILE: <AGENTS.md lookup instructions>\n...")
task(category="quick", load_skills=[], run_in_background=false, prompt="PASS: pr-summarizer\nPROFILE: <summary instructions>\n...")
```

If `pr-triage` returns no reviewable surface, stop with the triage reason.

## First-wave specialized passes

Launch every activated first-wave pass in parallel with `run_in_background=true`:

| Pass | Category | Activation |
| --- | --- | --- |
| General bugs | `unspecified-high` | Always |
| Rules compliance | `unspecified-high` | Relevant `AGENTS.md` exists or user asks for compliance |
| Tests | `unspecified-high` | Test files changed, behavior changed without tests, or user asks for test review |
| Comments | `writing` | Comments/docs changed or user asks for comment review |
| Silent failures | `unspecified-high` | Error handling, fallback, retry, logging, async failure, optional/null handling, external I/O, or user asks for errors |
| Types | `deep` | Types/interfaces/schemas/models/API contracts changed or user asks for type review |

Use this shape for each activated pass:

```text
task(category="unspecified-high", load_skills=[], run_in_background=true, prompt="PASS: code-reviewer\nPROFILE: <paste code-reviewer.md>\n...")
```

Each prompt must include the review surface, PR summary, applicable `AGENTS.md` files, explicit pass scope, severity/output expectations, and instructions to review only changed code unless context is required to validate a changed-code issue.

## Validation and second wave

1. Collect every first-wave result, including empty results.
2. For every non-empty candidate issue, run `issue-validator` with `run_in_background=false` or parallel background calls when there are multiple independent issues.
3. Drop dismissed issues and preserve source-pass attribution for validated issues.
4. Run `code-simplifier` as a second wave when no validated critical blockers remain, or whenever the user explicitly requested simplification/maintainability review.
5. Validate non-empty simplifier suggestions with `issue-validator` before final aggregation.

## Output

Return sections in this exact order:

1. `critical`
2. `important`
3. `suggestion`
4. `strengths`
5. `pass ledger`

Every finding must include file references, evidence, final severity, source pass, validation status, and PR comment target metadata when reviewing a PR. If no validated findings remain, say so directly and still include the pass ledger.

If the user owns the branch or asks for a remediation plan, create `docs/plans/{YYYY-mm-dd}-{scope}-review-remediation.md` with the validated findings and mention the path in the final response. Do not post PR comments unless explicitly approved.
