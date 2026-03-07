# OpenCode Implementation Agent Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a single OpenCode implementation agent that executes from approved docs when available, handles clearly straightforward requests directly, triages ambiguity with an explore agent, escalates non-straightforward work to `writing-plans`, and is wired into the OpenCode working agreements for openspec and superpowers-driven implementation tasks.

**Architecture:** Create one new agent definition under `dotfiles/.config/opencode/agents/` using `openai/gpt-5.3-codex-spark`. The prompt should classify requests as documented, straightforward, or unclear, implement only when safe, use explore only for straightforwardness triage, and require targeted verification before claiming completion. Update `dotfiles/.config/opencode/AGENTS.md` so openspec and superpowers implementation flows explicitly pass the approved design doc and task plan to this new subagent in both subagent-driven and parallel-session execution.

**Tech Stack:** Markdown, YAML frontmatter, OpenCode agent format, `rg`, `git`

---

### Task 1: Inventory the current agent set and reserve the new agent name

**Files:**
- Check: `dotfiles/.config/opencode/agents/*.md`
- Check: `docs/plans/2026-03-07-opencode-implementation-agent-design.md`

**Step 1: List the existing agent files**

Run: `rg --files dotfiles/.config/opencode/agents`

Expected: the current agent files are listed and there is no implementation-focused agent yet.

**Step 2: Search for implementation-oriented agent names already in use**

Run: `rg -n "^name: |implementation agent|implement|executor" dotfiles/.config/opencode/agents/*.md docs/plans/2026-03-07-opencode-implementation-agent-design.md`

Expected: no existing agent owns this role, and the design doc confirms the intended behavior.

**Step 3: Choose the exact new file and agent name**

Use:
- File: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Frontmatter name: `implementation-agent`

Expected: file name and `@implementation-agent` stay aligned with the repo naming pattern.

**Step 4: Commit the naming checkpoint**

```bash
git add docs/plans/2026-03-07-opencode-implementation-agent-design.md docs/plans/2026-03-07-opencode-implementation-agent-plan.md
git commit -m "docs: add implementation agent plan"
```

---

### Task 2: Create the new agent frontmatter and role definition

**Files:**
- Create: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Check: `dotfiles/.config/opencode/agents/code-simplifier.md`
- Check: `dotfiles/.config/opencode/AGENTS.md`

**Step 1: Write the new agent frontmatter**

Use this shape:

```yaml
---
name: implementation-agent
description: |
  Invoke this subagent with `@implementation-agent` when you need focused code-writing and implementation work that should follow approved design or task docs when available. The agent may also execute clearly straightforward requests directly, but it should not take over planning or design work. If the task is underspecified, it should first use an explore agent only to determine whether the work is straightforward enough to execute safely, and otherwise ask whether to create a plan with `writing-plans`.

  Examples:

  Context: You already have an approved implementation plan.
  user: "Implement the next task from this plan"
  assistant: "I'll @implementation-agent to execute the approved plan and verify the changed scope."

  Context: The user asked for a small direct code change.
  user: "Add a missing null guard in this helper"
  assistant: "I'll @implementation-agent to handle that directly and run the relevant checks."
model: openai/gpt-5.3-codex-spark
---
```

**Step 2: Verify the frontmatter fields**

Run: `rg -n "^(name: implementation-agent|model: openai/gpt-5.3-codex-spark)" dotfiles/.config/opencode/agents/implementation-agent.md`

Expected: one match for each required field, and no `mode: subagent` line so the agent remains available for direct use as well as subagent invocation.

**Step 3: Commit the frontmatter scaffold**

```bash
git add dotfiles/.config/opencode/agents/implementation-agent.md
git commit -m "feat: add implementation agent definition"
```

---

### Task 3: Write the implementation workflow and guardrails

**Files:**
- Modify: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Check: `docs/plans/2026-03-07-opencode-implementation-agent-design.md`

**Step 1: Add the intake classification section**

Write a body section that makes the agent classify each request as:

```markdown
## Intake

Classify each task before acting:

- `documented`: approved design or task docs are present
- `straightforward`: safe to implement directly without planning
- `unclear`: more context is needed before implementation
```

**Step 2: Add the execution rules**

Write a body section that says:

```markdown
## Execution Rules

- For `documented`, implement directly from the approved docs.
- For `straightforward`, implement directly with minimal exploration.
- For `unclear`, do not invent a design.
- Use an explore agent only to answer whether the task is straightforward enough to execute safely.
- If explore says yes, implement directly with minimal exploration.
- If the answer is no or uncertain, ask the user whether to create a plan with `writing-plans`.
- Keep changes scoped to the requested work.
- If the docs conflict with repository reality, stop and report the mismatch.
```

**Step 3: Add the anti-drift rules**

Write a section that forbids the agent from silently taking over brainstorming, architecture design, or plan generation when the task is not straightforward.

**Step 4: Verify the required workflow language**

Run: `rg -n "documented|straightforward|unclear|writing-plans|explore agent|do not invent a design|docs conflict" dotfiles/.config/opencode/agents/implementation-agent.md`

Expected: all guardrail phrases appear in the new agent body.

**Step 5: Commit the workflow rules**

```bash
git add dotfiles/.config/opencode/agents/implementation-agent.md
git commit -m "docs: define implementation agent workflow"
```

---

### Task 4: Add verification and completion behavior

**Files:**
- Modify: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Check: `dotfiles/.config/opencode/AGENTS.md`

**Step 1: Add targeted verification requirements**

Write a body section that includes:

```markdown
## Verification

- Run targeted lint, typecheck, and tests for the changed scope before claiming completion.
- Prefer file-level or feature-level verification over repo-wide commands.
- If related tests exist, run them.
- If no precise test target exists, say so clearly.
- If verification cannot run because tooling is missing or unclear, report that as a delivery gap.
```

**Step 2: Add completion reporting rules**

Write a section that requires the final report to include:

```markdown
## Completion Reporting

- What changed
- What verification ran
- Any remaining blockers or gaps
- Whether the task should move to planning instead of implementation
```

**Step 3: Verify the completion language**

Run: `rg -n "Run targeted lint|typecheck|tests for the changed scope|delivery gap|What changed|What verification ran|remaining blockers|move to planning" dotfiles/.config/opencode/agents/implementation-agent.md`

Expected: the verification and completion-reporting requirements are present.

**Step 4: Commit the verification behavior**

```bash
git add dotfiles/.config/opencode/agents/implementation-agent.md
git commit -m "docs: add implementation agent verification rules"
```

---

### Task 5: Final review of the new agent contract

**Files:**
- Modify: `dotfiles/.config/opencode/AGENTS.md`
- Check: `docs/plans/2026-03-07-opencode-implementation-agent-design.md`
- Check: `dotfiles/.config/opencode/agents/implementation-agent.md`

**Step 1: Add the new implementation-agent usage rule**

Add a working-agreement bullet to `dotfiles/.config/opencode/AGENTS.md` that makes the orchestration explicit.

Target intent:

```markdown
- For openspec or superpowers implementation work, use `@implementation-agent` as the code-writing subagent. In both subagent-driven and parallel-session execution, provide the approved design doc and the task plan to the agent before implementation starts.
```

**Step 2: Keep the existing workflow bullets aligned**

Adjust the existing implementation workflow wording only as needed so it stays consistent with the new rule and still points to `using-git-worktrees` before implementation and `subagent-driven-development` for in-session execution.

**Step 3: Verify the AGENTS.md guidance**

Run: `rg -n "implementation-agent|openspec|superpowers|design doc|task plan|subagent-driven-development|using-git-worktrees" dotfiles/.config/opencode/AGENTS.md`

Expected: the file explicitly mentions `@implementation-agent`, openspec or superpowers implementation work, and the requirement to provide the design doc plus task plan.

**Step 4: Commit the AGENTS.md integration**

```bash
git add dotfiles/.config/opencode/AGENTS.md
git commit -m "docs: wire implementation agent into opencode workflow"
```

---

### Task 6: Final review of the new agent contract

**Files:**
- Check: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Check: `docs/plans/2026-03-07-opencode-implementation-agent-design.md`
- Check: `dotfiles/.config/opencode/AGENTS.md`

**Step 1: Verify the final file contains the expected model and mode**

Run: `rg -n "^(name: implementation-agent|model: openai/gpt-5.3-codex-spark)" dotfiles/.config/opencode/agents/implementation-agent.md`

Expected: the file contains the expected name and model fields, and it does not force `mode: subagent` so it stays usable in both direct and subagent flows.

**Step 2: Verify the routing behavior is explicit**

Run: `rg -n "documented|straightforward|unclear|writing-plans|explore agent|verify" dotfiles/.config/opencode/agents/implementation-agent.md`

Expected: the prompt clearly encodes the intake gate, escalation path, and verification requirement.

**Step 3: Review the final diff**

Run: `git diff -- dotfiles/.config/opencode/agents/implementation-agent.md dotfiles/.config/opencode/AGENTS.md docs/plans/2026-03-07-opencode-implementation-agent-design.md docs/plans/2026-03-07-opencode-implementation-agent-plan.md`

Expected: the diff is limited to the new agent contract, the AGENTS.md workflow update, and the approved design/plan docs.

**Step 4: Confirm worktree state**

Run: `git status --short --branch`

Expected: only the intended files are changed before the final commit, and the branch is not `main` or `develop`.
