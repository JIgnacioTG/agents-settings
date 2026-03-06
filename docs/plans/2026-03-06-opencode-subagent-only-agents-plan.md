# OpenCode Subagent-Only Agents Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make every OpenCode agent definition explicitly subagent-only and verify the existing skill files already orchestrate those agents correctly.

**Architecture:** Update all markdown agent definitions in `dotfiles/.config/opencode/agents/` so their YAML frontmatter includes `mode: subagent` and their descriptions/examples consistently instruct invocation via `@agent-name`. Review the two skill files under `dotfiles/.config/opencode/skills/` and only patch them if they contain conflicting wording.

**Tech Stack:** Markdown, YAML frontmatter, OpenCode agent format, OpenCode skill format, `rg`, `git`

---

### Task 1: Inventory current agent metadata and invocation wording

**Files:**
- Modify: `dotfiles/.config/opencode/agents/*.md`
- Check: `dotfiles/.config/opencode/skills/code-review/SKILL.md`
- Check: `dotfiles/.config/opencode/skills/review-pr/SKILL.md`

**Step 1: List agent files**

Run: `rg --files dotfiles/.config/opencode/agents`

Expected: all agent markdown files are listed.

**Step 2: Inspect current frontmatter and invocation wording**

Run: `rg -n "^(name:|description:|model:|mode:)|@[a-z0-9-]+|Use this agent|Invoke this agent" dotfiles/.config/opencode/agents/*.md`

Expected: identify which files are missing `mode: subagent` and which descriptions still use generic wording.

**Step 3: Inspect skill wording for delegation style**

Run: `rg -n "@[a-z0-9-]+|subagent|Task tool|standalone|Use this agent" dotfiles/.config/opencode/skills/**/*.md`

Expected: confirm the skill files already delegate via `@agent-name`, with any conflicting wording clearly visible.

**Step 4: Commit inventory checkpoint**

```bash
git add docs/plans/2026-03-06-opencode-subagent-only-agents-design.md docs/plans/2026-03-06-opencode-subagent-only-agents-plan.md
git commit -m "docs: add subagent-only agent plan"
```

---

### Task 2: Add `mode: subagent` to every agent frontmatter

**Files:**
- Modify: `dotfiles/.config/opencode/agents/code-reviewer.md`
- Modify: `dotfiles/.config/opencode/agents/code-simplifier.md`
- Modify: `dotfiles/.config/opencode/agents/comment-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/compliance-auditor.md`
- Modify: `dotfiles/.config/opencode/agents/config-finder.md`
- Modify: `dotfiles/.config/opencode/agents/issue-validator.md`
- Modify: `dotfiles/.config/opencode/agents/pr-summarizer.md`
- Modify: `dotfiles/.config/opencode/agents/pr-test-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/pr-triage.md`
- Modify: `dotfiles/.config/opencode/agents/silent-failure-hunter.md`
- Modify: `dotfiles/.config/opencode/agents/type-design-analyzer.md`

**Step 1: Write the metadata change**

For each agent file, insert `mode: subagent` into the YAML frontmatter between `description` and `model`.

Example target shape:

```yaml
---
name: code-reviewer
description: |
  Invoke this subagent with `@code-reviewer` when you need...
mode: subagent
model: openai/gpt-5.4
---
```

**Step 2: Verify all agent files now include the field**

Run: `rg -n "^mode: subagent$" dotfiles/.config/opencode/agents/*.md`

Expected: one match per agent file.

**Step 3: Commit metadata change**

```bash
git add dotfiles/.config/opencode/agents/*.md
git commit -m "chore: mark opencode agents as subagents"
```

---

### Task 3: Normalize agent descriptions to `@agent-name` invocation

**Files:**
- Modify: `dotfiles/.config/opencode/agents/code-reviewer.md`
- Modify: `dotfiles/.config/opencode/agents/code-simplifier.md`
- Modify: `dotfiles/.config/opencode/agents/comment-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/compliance-auditor.md`
- Modify: `dotfiles/.config/opencode/agents/config-finder.md`
- Modify: `dotfiles/.config/opencode/agents/issue-validator.md`
- Modify: `dotfiles/.config/opencode/agents/pr-summarizer.md`
- Modify: `dotfiles/.config/opencode/agents/pr-test-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/pr-triage.md`
- Modify: `dotfiles/.config/opencode/agents/silent-failure-hunter.md`
- Modify: `dotfiles/.config/opencode/agents/type-design-analyzer.md`

**Step 1: Rewrite the lead description in each file**

Replace generic lead-ins such as:

```markdown
Use this agent when...
```

with agent-specific wording like:

```markdown
Invoke this subagent with `@code-reviewer` when...
```

**Step 2: Keep examples explicitly orchestrated by the main assistant**

For each file, ensure the examples show the assistant invoking the agent with `@agent-name` and do not imply direct end-user execution of the subagent.

**Step 3: Adjust body text only if it conflicts with subagent execution**

Examples of acceptable body wording:

```markdown
When invoked, review the provided scope.
The caller may provide a specific diff or file list.
```

Avoid changing the body if it only defines the agent's analytical job.

**Step 4: Verify the new wording**

Run: `rg -n "Invoke this subagent with|@[a-z0-9-]+" dotfiles/.config/opencode/agents/*.md`

Expected: each agent description references its `@agent-name`, and examples still use `@` invocation.

**Step 5: Commit wording normalization**

```bash
git add dotfiles/.config/opencode/agents/*.md
git commit -m "docs: normalize opencode agent invocation wording"
```

---

### Task 4: Review and patch skill files only if needed

**Files:**
- Check: `dotfiles/.config/opencode/skills/code-review/SKILL.md`
- Check: `dotfiles/.config/opencode/skills/review-pr/SKILL.md`

**Step 1: Inspect current delegation language**

Run: `rg -n "@[a-z0-9-]+|Task tool|subagent|standalone" dotfiles/.config/opencode/skills/**/*.md`

Expected: current skill files reference agents via `@agent-name`.

**Step 2: Decide whether edits are required**

- If both files consistently use `@agent-name` and do not suggest another execution model, make no edits.
- If any line implies a standalone or non-subagent path, patch only that wording.

**Step 3: Verify final skill wording**

Run: `rg -n "Task tool|standalone" dotfiles/.config/opencode/skills/**/*.md`

Expected: no conflicting phrases remain, or the search shows no problematic wording to begin with.

**Step 4: Commit skill wording changes if any were needed**

```bash
git add dotfiles/.config/opencode/skills/**/*.md
git commit -m "docs: align opencode skills with subagent usage"
```

Skip this commit if there were no skill file changes.

---

### Task 5: Final verification

**Files:**
- Check: `dotfiles/.config/opencode/agents/*.md`
- Check: `dotfiles/.config/opencode/skills/**/*.md`

**Step 1: Verify `mode: subagent` coverage**

Run: `rg -n "^mode: subagent$" dotfiles/.config/opencode/agents/*.md | wc -l`

Expected: `11`

**Step 2: Verify no generic agent lead-ins remain**

Run: `rg -n "Use this agent|Invoke this agent" dotfiles/.config/opencode/agents/*.md`

Expected: no matches, or only intentional wording that still explicitly says `subagent`.

**Step 3: Verify skills still use `@agent-name` delegation**

Run: `rg -n "@[a-z0-9-]+" dotfiles/.config/opencode/skills/**/*.md`

Expected: multiple matches across both skill files.

**Step 4: Review git diff**

Run: `git diff --stat HEAD~1..HEAD && git diff -- dotfiles/.config/opencode/agents dotfiles/.config/opencode/skills`

Expected: changes are limited to agent metadata/wording and optional skill wording cleanup.

**Step 5: Confirm worktree state**

Run: `git status --short --branch`

Expected: branch name is visible and worktree is clean after commits.
