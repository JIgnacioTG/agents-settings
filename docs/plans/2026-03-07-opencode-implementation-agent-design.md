# Design: Add an OpenCode implementation agent

**Date:** 2026-03-07
**Status:** Approved

## Summary

Add a single OpenCode agent dedicated to code-writing and implementation tasks. The agent should be usable both as the active direct-use agent and as an invoked subagent, and should optimize for balanced speed and reliability using `openai/gpt-5.3-codex-spark`.

## Goals

- Add one implementation-focused agent rather than a router or multi-agent execution family
- Keep planning, design, and debugging responsibilities outside this agent by default
- Execute directly from approved design or plan documents when they exist
- Allow direct execution without a plan only when the requested work is clearly straightforward
- Keep completion claims tied to targeted verification

## Non-Goals

- Replacing brainstorming, debugging, or planning skills
- Building a routing layer that chooses among multiple implementation agents
- Letting the agent redesign architecture during implementation
- Requiring a plan document for every trivial or obviously straightforward request

## Current Context

This repo already contains OpenCode agent definitions under `dotfiles/.config/opencode/agents/` and recent design/plan documents for agent-related changes under `docs/plans/`. Existing analysis agents already use `openai/gpt-5.3-codex-spark` for mid-tier reasoning tasks, which makes that model a good fit for a fast but reliable implementation agent.

## Options Considered

### Option 1: Focused implementation agent

One agent executes code-writing tasks and expects approved design or plan context most of the time, with a narrow fallback for obviously straightforward work.

**Pros**
- Simple contract
- Easy to keep scoped
- Aligns with the current workflow

**Cons**
- Needs explicit boundaries to avoid drifting into planning

### Option 2: Implementation agent with lightweight intake gate (recommended)

One agent performs implementation, but starts by classifying the request as documented, straightforward, or unclear.

**Pros**
- Preserves the single-agent model
- Handles missing-doc cases cleanly
- Works well for both direct use and subagent use

**Cons**
- Slightly more prompt complexity

### Option 3: General execution agent

One broad agent explores, plans, and implements when needed.

**Pros**
- Most flexible

**Cons**
- Weakens separation of responsibilities
- More likely to improvise architecture

## Recommended Design

Use Option 2.

Add a single implementation agent definition under `dotfiles/.config/opencode/agents/` with a behavior contract centered on execution. The agent should primarily implement from approved design or task documents, but it may proceed without them when the requested work is clearly straightforward and does not need extra planning.

If the request is underspecified, the agent should not silently plan on its own. Instead, it should use an explore agent only to determine whether the work is straightforward enough to execute safely. If the answer is no, the agent should ask the user whether to create a plan with the `writing-plans` skill.

## Architecture

The new agent is an execution specialist, not a planner. Its primary loop is: inspect provided context, classify the request, implement when safe, verify with targeted checks, and report results or blockers. It should be described so it behaves correctly whether it is the active agent for the session or is invoked as a subagent.

Model choice should remain `openai/gpt-5.3-codex-spark` to favor speed, with reliability coming from guardrails and verification rather than from a heavier model.

## Components

The change should stay small and centered on one new agent definition file.

- A single agent file under `dotfiles/.config/opencode/agents/`
- Explicit role and boundaries for implementation-only work
- Entry classification rules for documented, straightforward, and unclear requests
- A narrow fallback that uses an explore agent only for triage
- Escalation rules that route non-straightforward work to `writing-plans`
- Targeted verification rules before completion
- Subagent-oriented invocation examples only; no special direct-use invocation syntax is needed

## Data Flow

1. Read the prompt and any supplied design or task documents.
2. Classify the request as `documented`, `straightforward`, or `unclear`.
3. For `documented`, implement directly from the approved docs.
4. For `straightforward`, implement directly with minimal exploration.
5. For `unclear`, delegate to an explore agent only to answer whether the task is straightforward enough to execute safely.
6. If explore says yes, continue implementation.
7. If explore says no, stop and ask the user whether to create a plan with `writing-plans`.
8. Run targeted verification and report what changed, what passed, and any remaining gaps.

## Error Handling

- If required context is missing and the task is not obviously straightforward, do not guess; triage with explore and then escalate to planning.
- If provided docs conflict with repository reality, stop and surface the mismatch rather than redesigning the solution.
- If verification fails, report the exact failed command and whether the failure appears new or pre-existing.
- If the task expands beyond the original request during implementation, surface that scope change instead of absorbing it silently.
- If explore cannot confidently determine that the task is straightforward, treat it as not straightforward and escalate to planning.

## Testing and Verification

- Always run targeted checks for the changed scope after implementation.
- Prefer file- or feature-level lint, typecheck, and tests over repo-wide verification.
- If related tests exist, run them.
- If no precise test target exists, state that clearly instead of implying coverage.
- For straightforward no-doc tasks, verification is still required before claiming completion.
- If verification cannot run because tooling is missing or unclear, report that as a delivery gap.

## Risks and Mitigations

### Risk: The agent drifts into planning

Mitigation: Keep the entry contract explicit and require escalation to `writing-plans` for non-straightforward work.

### Risk: Fast model quality is inconsistent on ambiguous requests

Mitigation: Use the explore-agent triage step and fail loudly on ambiguity rather than improvising.

### Risk: Direct-use behavior and subagent behavior diverge

Mitigation: Define behavior in caller-agnostic terms and avoid examples that assume special direct invocation syntax.

## Acceptance Criteria

- A new implementation agent exists under `dotfiles/.config/opencode/agents/`
- The agent uses `openai/gpt-5.3-codex-spark`
- The prompt makes implementation its primary responsibility
- The prompt prefers approved design or plan docs when available
- The prompt allows direct execution for clearly straightforward tasks
- The prompt uses explore only to decide whether a task is straightforward enough without a plan
- The prompt escalates non-straightforward work to `writing-plans`
- The prompt requires targeted verification before claiming completion
