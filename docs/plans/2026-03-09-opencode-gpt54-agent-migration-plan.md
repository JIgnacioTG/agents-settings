# OpenCode Agent Model Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate remaining OpenCode agents from `openai/gpt-5.3-codex-spark` to `openai/gpt-5.4`, add an `implementation-agent-spark` variant, and update the workflow guidance to probe spark first and fall back to the default implementation agent.

**Architecture:** Keep `dotfiles/.config/opencode/agents/implementation-agent.md` as the stable `openai/gpt-5.4` implementation agent, add a second agent file for spark with the same prompt body, and update `dotfiles/.config/opencode/AGENTS.md` so model selection happens at the workflow layer through a short availability probe. Other remaining agent model updates stay as direct in-place metadata changes.

**Tech Stack:** Markdown agent definitions, OpenCode agent frontmatter, repository workflow docs, git, ripgrep.

---

### Task 1: Update the remaining non-implementation agent models

**Files:**
- Modify: `dotfiles/.config/opencode/agents/code-simplifier.md`
- Modify: `dotfiles/.config/opencode/agents/comment-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/compliance-auditor.md`
- Modify: `dotfiles/.config/opencode/agents/pr-summarizer.md`
- Modify: `dotfiles/.config/opencode/agents/pr-test-analyzer.md`
- Modify: `dotfiles/.config/opencode/agents/type-design-analyzer.md`

**Step 1: Capture the current verification baseline**

Run: `rg -n "openai/gpt-5\.3-codex-spark" dotfiles/.config/opencode/agents/{code-simplifier,comment-analyzer,compliance-auditor,pr-summarizer,pr-test-analyzer,type-design-analyzer}.md`
Expected: one match per file showing the old model value.

**Step 2: Replace each old model value with `openai/gpt-5.4`**

Edit only the `model:` line in each file. Leave prompt text and reasoning settings unchanged.

**Step 3: Verify the old model string is gone from those files**

Run: `rg -n "openai/gpt-5\.3-codex-spark" dotfiles/.config/opencode/agents/{code-simplifier,comment-analyzer,compliance-auditor,pr-summarizer,pr-test-analyzer,type-design-analyzer}.md`
Expected: no output.

**Step 4: Verify the new model string is present in those files**

Run: `rg -n "^model: openai/gpt-5\.4$" dotfiles/.config/opencode/agents/{code-simplifier,comment-analyzer,compliance-auditor,pr-summarizer,pr-test-analyzer,type-design-analyzer}.md`
Expected: six matches, one per file.

**Step 5: Commit**

```bash
git add dotfiles/.config/opencode/agents/code-simplifier.md dotfiles/.config/opencode/agents/comment-analyzer.md dotfiles/.config/opencode/agents/compliance-auditor.md dotfiles/.config/opencode/agents/pr-summarizer.md dotfiles/.config/opencode/agents/pr-test-analyzer.md dotfiles/.config/opencode/agents/type-design-analyzer.md
git commit -m "chore: move agent analyzers to gpt-5.4"
```

### Task 2: Split the implementation agent into default and spark variants

**Files:**
- Modify: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Create: `dotfiles/.config/opencode/agents/implementation-agent-spark.md`

**Step 1: Capture the current implementation-agent baseline**

Run: `rg -n "^(name: implementation-agent|model: )" dotfiles/.config/opencode/agents/implementation-agent.md`
Expected: the existing file is named `implementation-agent` and still points at the old spark model.

**Step 2: Update the default implementation agent to `openai/gpt-5.4`**

Edit only the `model:` line in `dotfiles/.config/opencode/agents/implementation-agent.md` so the default agent becomes the stable `gpt-5.4` variant.

**Step 3: Create the spark variant file**

Create `dotfiles/.config/opencode/agents/implementation-agent-spark.md` by copying the existing implementation-agent content and changing only:

- `name: implementation-agent-spark`
- example invocations from `@implementation-agent` to `@implementation-agent-spark` where the file refers to itself
- `model: openai/gpt-5.3-codex-spark`

Keep `reasoningEffort: high` and the prompt body aligned with the default implementation agent.

**Step 4: Verify both implementation-agent variants**

Run: `rg -n "^(name: implementation-agent|name: implementation-agent-spark|model: openai/gpt-5\.4|model: openai/gpt-5\.3-codex-spark)" dotfiles/.config/opencode/agents/implementation-agent.md dotfiles/.config/opencode/agents/implementation-agent-spark.md`
Expected: the default file shows `name: implementation-agent` and `model: openai/gpt-5.4`; the new file shows `name: implementation-agent-spark` and the spark model.

**Step 5: Commit**

```bash
git add dotfiles/.config/opencode/agents/implementation-agent.md dotfiles/.config/opencode/agents/implementation-agent-spark.md
git commit -m "chore: split implementation agent model variants"
```

### Task 3: Add spark probe and fallback guidance to the workflow instructions

**Files:**
- Modify: `dotfiles/.config/opencode/AGENTS.md`

**Step 1: Capture the current workflow wording**

Run: `rg -n "implementation work|@implementation-agent|approved design doc|task plan" dotfiles/.config/opencode/AGENTS.md`
Expected: the file currently points directly to `@implementation-agent` with no spark probe or timeout guidance.

**Step 2: Update the implementation workflow rule**

Replace the current implementation-agent instruction with wording that tells the caller to:

- first send a minimal availability check to `@implementation-agent-spark`
- keep the spark probe timeout low, around 10 seconds
- treat the probe as a health check only
- use `@implementation-agent-spark` for the real task only when the probe succeeds
- fall back immediately to `@implementation-agent` when the probe fails, times out, or is unavailable
- continue passing the approved design doc and task plan to the selected implementation agent

**Step 3: Verify the new workflow wording**

Run: `rg -n "implementation-agent-spark|10 seconds|fall back|approved design doc|task plan" dotfiles/.config/opencode/AGENTS.md`
Expected: the updated rule includes the probe-first flow, explicit fallback wording, and design-doc plus task-plan handoff requirements.

**Step 4: Sanity-check the full changed scope**

Run: `rg -n "openai/gpt-5\.3-codex-spark|openai/gpt-5\.4|implementation-agent-spark" dotfiles/.config/opencode/agents/*.md dotfiles/.config/opencode/AGENTS.md`
Expected: only `dotfiles/.config/opencode/agents/implementation-agent-spark.md` still references the spark model; the default implementation agent and the other migrated agent files use `openai/gpt-5.4`.

**Step 5: Commit**

```bash
git add dotfiles/.config/opencode/AGENTS.md
git commit -m "chore: add spark fallback for implementation agent"
```

### Task 4: Final verification and delivery check

**Files:**
- Verify: `dotfiles/.config/opencode/agents/code-simplifier.md`
- Verify: `dotfiles/.config/opencode/agents/comment-analyzer.md`
- Verify: `dotfiles/.config/opencode/agents/compliance-auditor.md`
- Verify: `dotfiles/.config/opencode/agents/pr-summarizer.md`
- Verify: `dotfiles/.config/opencode/agents/pr-test-analyzer.md`
- Verify: `dotfiles/.config/opencode/agents/type-design-analyzer.md`
- Verify: `dotfiles/.config/opencode/agents/implementation-agent.md`
- Verify: `dotfiles/.config/opencode/agents/implementation-agent-spark.md`
- Verify: `dotfiles/.config/opencode/AGENTS.md`

**Step 1: Inspect the combined diff**

Run: `git diff -- dotfiles/.config/opencode/agents/*.md dotfiles/.config/opencode/AGENTS.md`
Expected: only the requested model updates, the new spark agent file, and the workflow guidance change appear.

**Step 2: Confirm there are no unintended old-model references in the target scope**

Run: `rg -n "openai/gpt-5\.3-codex-spark" dotfiles/.config/opencode/agents/*.md dotfiles/.config/opencode/AGENTS.md`
Expected: only `dotfiles/.config/opencode/agents/implementation-agent-spark.md` matches.

**Step 3: Confirm the target scope now contains the expected `gpt-5.4` references**

Run: `rg -n "^model: openai/gpt-5\.4$" dotfiles/.config/opencode/agents/*.md`
Expected: matches include the six migrated analyzer files and `dotfiles/.config/opencode/agents/implementation-agent.md`.

**Step 4: Confirm git status is ready for delivery**

Run: `git status --short`
Expected: only the intended tracked changes remain before the final delivery commit, or the working tree is clean if each task commit already happened.

**Step 5: Final commit if needed**

```bash
git add dotfiles/.config/opencode/agents/*.md dotfiles/.config/opencode/AGENTS.md
git commit -m "chore: migrate opencode agents to gpt-5.4"
```

Skip this commit only if the earlier task commits already leave the branch clean and complete.
