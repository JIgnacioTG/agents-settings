# OpenCode Agent Model Migration and Spark Fallback Design

Date: 2026-03-09

## Goal

Update all OpenCode agent definitions that still use `openai/gpt-5.3-codex-spark` so they use `openai/gpt-5.4`, while splitting the implementation agent into two variants:

- `implementation-agent` on `openai/gpt-5.4`
- `implementation-agent-spark` on the codex spark model

The OpenCode workflow instructions in `dotfiles/.config/opencode/AGENTS.md` should prefer the spark implementation agent only when a short availability probe succeeds, and otherwise fall back to the default implementation agent.

## Current Context

The repository contains agent definitions in `dotfiles/.config/opencode/agents/` and workflow guidance in `dotfiles/.config/opencode/AGENTS.md`.

At design time, these agents still reference `openai/gpt-5.3-codex-spark`:

- `implementation-agent.md`
- `code-simplifier.md`
- `comment-analyzer.md`
- `compliance-auditor.md`
- `pr-summarizer.md`
- `pr-test-analyzer.md`
- `type-design-analyzer.md`

The current workflow guidance always refers to `@implementation-agent` and does not define a model-availability fallback path.

## Requirements

1. Replace all remaining `openai/gpt-5.3-codex-spark` agent references with `openai/gpt-5.4`.
2. Keep `dotfiles/.config/opencode/agents/implementation-agent.md` as the default implementation agent on `openai/gpt-5.4`.
3. Add `dotfiles/.config/opencode/agents/implementation-agent-spark.md` as a second implementation agent that preserves the same behavior but targets the codex spark model.
4. Update `dotfiles/.config/opencode/AGENTS.md` so implementation flows first attempt a lightweight probe against `@implementation-agent-spark` with a short timeout, such as 10 seconds.
5. If the probe succeeds, the real implementation task should use `@implementation-agent-spark`.
6. If the probe fails, times out, or the model is unavailable, the workflow should fall back immediately to `@implementation-agent`.
7. Historical design docs should remain untouched; create new docs for this change instead.

## Options Considered

### Option 1: Default agent plus explicit spark variant

Keep `implementation-agent` as the stable default on `openai/gpt-5.4`, add `implementation-agent-spark` as an optional fast-path variant, and encode fallback behavior in `AGENTS.md`.

Pros:

- Preserves the existing `@implementation-agent` contract.
- Keeps model selection policy centralized in one workflow document.
- Makes spark usage opportunistic instead of required.

Cons:

- Duplicates one agent prompt across two files.

### Option 2: Rename the current implementation agent to spark

Move the existing implementation agent identity to the spark-backed file and create a differently named default agent for `openai/gpt-5.4`.

Pros:

- Makes spark appear to be the primary implementation path.

Cons:

- Breaks or complicates existing references to `@implementation-agent`.
- Introduces unnecessary workflow churn.

### Option 3: Single implementation agent on `openai/gpt-5.4`

Update every agent to `openai/gpt-5.4` and do not add a spark variant.

Pros:

- Smallest config change.

Cons:

- Does not satisfy the requested two-variant implementation-agent behavior.
- Removes the ability to use spark opportunistically.

## Decision

Choose Option 1.

The default implementation path remains stable and reliable through `@implementation-agent` on `openai/gpt-5.4`. A new `@implementation-agent-spark` variant provides the codex spark fast path. `dotfiles/.config/opencode/AGENTS.md` becomes responsible for selecting between them by probing spark availability first and falling back immediately when needed.

## Design

### Agent file changes

- Update each non-implementation agent still on `openai/gpt-5.3-codex-spark` to `openai/gpt-5.4`.
- Update `dotfiles/.config/opencode/agents/implementation-agent.md` to `openai/gpt-5.4`.
- Add `dotfiles/.config/opencode/agents/implementation-agent-spark.md` with:
  - `name: implementation-agent-spark`
  - the same description and body as the default implementation agent
  - the codex spark model

The two implementation-agent files should differ only where needed to identify the agent and set the model.

### Workflow changes in `AGENTS.md`

The implementation workflow guidance should:

- describe a short spark probe using a minimal prompt
- keep the probe timeout low, around 10 seconds
- use the probe only as an availability check, not as the real implementation request
- route the real implementation request to `@implementation-agent-spark` when the probe succeeds
- route the real implementation request to `@implementation-agent` when the probe fails, times out, or is unavailable
- continue requiring approved design docs and task plans to be passed to the selected implementation agent

### Failure handling

The fallback path should be simple and deterministic:

- no retry loop
- no extra model-selection branches
- no partial work done during the probe step

This keeps spark availability as an optimization rather than a dependency.

## Verification Plan

After implementation:

- inspect the changed agent files to confirm the model values
- inspect the new spark agent file to confirm the duplicated prompt body and distinct name
- inspect `dotfiles/.config/opencode/AGENTS.md` to confirm the probe-first fallback guidance
- run targeted checks that are appropriate for markdown and config changes

## Out of Scope

- Changing agent behavior beyond model selection and naming
- Editing historical plan or design docs in place
- Introducing additional implementation-agent variants
