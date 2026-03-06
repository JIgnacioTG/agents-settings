# Design: Normalize OpenCode agents as subagent-only

**Date:** 2026-03-06
**Status:** Approved

## Summary

Normalize every agent definition under `dotfiles/.config/opencode/agents/` so they are explicitly configured and described as OpenCode subagents. This adds `mode: subagent` to agent frontmatter and updates invocation wording to consistently use `@agent-name`. Review the OpenCode skill files under `dotfiles/.config/opencode/skills/` and only change them if they still imply non-subagent execution.

## Goals

- Make subagent mode explicit in every agent file
- Standardize invocation wording around `@agent-name`
- Remove ambiguous standalone-assistant framing from agent descriptions and examples
- Preserve existing agent responsibilities and model assignments
- Confirm whether the existing skills already align with subagent invocation

## Non-Goals

- Changing the set of agents or their core responsibilities
- Rebalancing model assignments
- Rewriting skill workflows that already use `@agent-name` correctly
- Adding a new repo-wide validation system in this pass

## Current State

Agent files already behave like OpenCode subagents, but their metadata and wording are inconsistent:

- Frontmatter currently includes `name`, `description`, and `model`, but not `mode: subagent`
- Most examples already show `@agent-name` usage, but some wording still says "Use this agent" rather than explicitly framing the file as a subagent contract
- Skills in `dotfiles/.config/opencode/skills/` already appear to orchestrate work through `@agent-name` references, so they likely only need verification rather than edits

## Options Considered

### Option 1: Metadata-only update

Add `mode: subagent` to every agent file and leave all wording alone.

**Pros**
- Lowest risk
- Small diff

**Cons**
- Leaves inconsistent invocation language in place
- Does not fully communicate subagent-only intent to future readers

### Option 2: Metadata plus wording normalization (recommended)

Add `mode: subagent` to every agent file and normalize description/example wording so invocation is always framed through `@agent-name`.

**Pros**
- Makes the contract explicit in both metadata and prose
- Preserves current behavior while reducing ambiguity
- Keeps change scope limited to the files that actually define agents

**Cons**
- Slightly larger diff than metadata-only

### Option 3: Full contract plus repo-level enforcement

Do Option 2 and also add an additional documented convention or validation rule elsewhere in the repo.

**Pros**
- Strongest long-term consistency

**Cons**
- Expands scope beyond the requested cleanup
- Requires deciding where enforcement belongs

## Recommended Design

Use Option 2.

Update every markdown file in `dotfiles/.config/opencode/agents/` to include `mode: subagent` in YAML frontmatter. Normalize the frontmatter descriptions and examples so they consistently describe the agent as something the main assistant invokes via `@agent-name`, not as a standalone persona the user interacts with directly.

Review every skill in `dotfiles/.config/opencode/skills/` for conflicting wording. If a skill already delegates with `@agent-name` and does not imply a different execution model, leave it unchanged. This keeps the change focused on the agent contracts while still verifying compatibility.

## Detailed Changes

### Agent frontmatter

For all files in `dotfiles/.config/opencode/agents/`:

- Add `mode: subagent`
- Preserve `name` and `model`
- Keep descriptions concise but explicit about `@agent-name` invocation

Expected frontmatter shape:

```yaml
---
name: code-reviewer
description: |
  Invoke this subagent with `@code-reviewer` when you need...
mode: subagent
model: openai/gpt-5.4
---
```

### Agent wording normalization

Apply these wording rules across all agent descriptions:

- Replace generic phrases like "Use this agent" with "Invoke this subagent with `@agent-name`"
- Keep examples centered on the orchestrating assistant calling `@agent-name`
- Preserve domain-specific guidance in the body unless it contains conflicting execution assumptions
- Prefer caller-oriented wording such as "the caller provides scope" or "when invoked" if body text needs adjustment

### Skill review

Inspect these skill files:

- `dotfiles/.config/opencode/skills/code-review/SKILL.md`
- `dotfiles/.config/opencode/skills/review-pr/SKILL.md`

Acceptance rule:

- If they already use `@agent-name` consistently and do not imply another delegation mechanism, do not edit them
- If any wording still implies a non-subagent execution path, make the smallest possible wording fix

## Risks and Mitigations

### Risk: Mechanical wording edits change agent intent

Mitigation: Limit edits to invocation framing and frontmatter unless a body section clearly conflicts with subagent usage.

### Risk: Skills drift from agent contract

Mitigation: Verify skills in the same pass and only patch conflicting language.

## Verification

After implementation:

- Confirm every file in `dotfiles/.config/opencode/agents/` contains `mode: subagent`
- Confirm agent descriptions/examples include `@agent-name` invocation wording
- Confirm `dotfiles/.config/opencode/skills/` has no conflicting standalone or non-subagent delegation guidance
- Review the final diff to ensure model assignments and core agent behavior remain unchanged unless intentionally edited
