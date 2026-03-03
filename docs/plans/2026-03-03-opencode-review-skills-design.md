# Design: Port code-review and pr-review-toolkit to OpenCode

**Date:** 2026-03-03
**Status:** Approved

## Summary

Port two Claude Code plugins (`code-review` and `pr-review-toolkit`) from the `anthropics/claude-code` repo into opencode-compatible agents and skills, installed as dotfiles via this repo's `install.sh` script.

## Source Plugins

### code-review (anthropics/claude-code)
Single orchestrator command that runs automated multi-stage PR review:
1. Haiku triage (draft/closed/already reviewed?)
2. Haiku finds relevant AGENTS.md files
3. Sonnet summarizes PR changes
4. 4 parallel agents: 2 sonnet AGENTS.md compliance + 2 opus bug scanners
5. Validation subagents for each issue
6. Filter low-confidence issues
7. Output summary + optional GitHub inline comments

### pr-review-toolkit (anthropics/claude-code)
6 specialized agents + orchestrator command for comprehensive selective review:
- `code-reviewer` (opus) — general code review, AGENTS.md compliance, bug detection
- `code-simplifier` (opus) — simplification while preserving functionality
- `comment-analyzer` (inherit) — comment accuracy and maintainability
- `pr-test-analyzer` (inherit) — test coverage quality
- `silent-failure-hunter` (inherit) — error handling and silent failures
- `type-design-analyzer` (inherit) — type design and invariants

## Target Architecture

### Model Mapping

All agents use explicit models — no `inherit`.

| Claude Code | OpenCode (Codex) | Used by |
|---|---|---|
| opus | `gpt-5.3-codex` | Deep analysis agents (code-reviewer, issue-validator, silent-failure-hunter) |
| sonnet | `gpt-5.3-codex-spark` | Mid-tier analysis agents (code-simplifier, compliance-auditor, comment-analyzer, pr-test-analyzer, type-design-analyzer, pr-summarizer) |
| haiku | `gpt-5.1-codex-mini` | Lightweight agents (pr-triage, config-finder) |

### File Structure

```
dotfiles/.config/opencode/
├── agents/
│   ├── code-reviewer.md          # General code review (gpt-5.3-codex)
│   ├── code-simplifier.md        # Simplification (gpt-5.3-codex-spark)
│   ├── compliance-auditor.md     # AGENTS.md rule compliance (gpt-5.3-codex-spark)
│   ├── issue-validator.md        # Validate flagged issues (gpt-5.3-codex)
│   ├── comment-analyzer.md       # Comment accuracy (gpt-5.3-codex-spark)
│   ├── pr-test-analyzer.md       # Test coverage (gpt-5.3-codex-spark)
│   ├── silent-failure-hunter.md  # Error handling (gpt-5.3-codex)
│   ├── type-design-analyzer.md   # Type design (gpt-5.3-codex-spark)
│   ├── pr-triage.md              # PR status checks (gpt-5.1-codex-mini)
│   ├── config-finder.md          # Find AGENTS.md files (gpt-5.1-codex-mini)
│   └── pr-summarizer.md          # Summarize PR changes (gpt-5.3-codex-spark)
├── skills/
│   ├── code-review/
│   │   └── SKILL.md              # Automated multi-stage PR review
│   └── review-pr/
│       └── SKILL.md              # Comprehensive selective review toolkit
├── AGENTS.md                     # (existing, unchanged)
└── opencode.json                 # (existing, unchanged)
```

All files are managed by `install.sh` which symlinks `dotfiles/.config/opencode/` to `~/.config/opencode/`.

## Agent Definitions

Each agent is a markdown file with YAML frontmatter compatible with opencode:

```yaml
---
name: agent-name
description: |
  Use this agent when...
  Examples:
  ...
model: gpt-5.3-codex
---

[System prompt body]
```

### Adaptation Rules

1. **Frontmatter**: Remove `color` and `allowed-tools` fields (claude-code specific)
2. **Model**: Map to Codex equivalents per table above; all agents get explicit models
3. **Description examples**: Replace `Task` tool references with `@mention` syntax
4. **System prompt body**:
   - Replace `CLAUDE.md` → `AGENTS.md` throughout
   - Remove references to Claude Code-specific tools (logForDebugging, errorIds.ts, etc.)
   - Replace `mcp__github_inline_comment__create_inline_comment` with GitHub MCP tool reference
   - Keep all review logic, scoring, and output format instructions intact
5. **Agent-specific body** stays largely the same since it's model-agnostic review instructions

### Agent Details

#### Opus-tier agents (gpt-5.3-codex) — deep reasoning

#### code-reviewer.md
- **Model:** gpt-5.3-codex
- **Purpose:** General code review — AGENTS.md compliance + bug detection
- **Scoring:** Confidence 0-100, only reports >= 80
- **Output:** Issues grouped as Critical (90-100) and Important (80-89)

#### issue-validator.md
- **Model:** gpt-5.3-codex
- **Purpose:** Validate flagged issues from upstream review agents
- **Mode:** Receives issue description + PR context, confirms or dismisses
- **Output:** Validated (with evidence) or Dismissed (with reasoning)

#### silent-failure-hunter.md
- **Model:** gpt-5.3-codex
- **Purpose:** Error handling and silent failure detection — requires deep reasoning to catch subtle swallowed errors
- **Severity:** CRITICAL / HIGH / MEDIUM
- **Focus:** Every try-catch, error callback, fallback logic, optional chaining

#### Sonnet-tier agents (gpt-5.3-codex-spark) — structured analysis

#### code-simplifier.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Simplify code while preserving exact functionality — pattern recognition task
- **Focus:** Reduce complexity, eliminate redundancy, improve clarity
- **Operates:** Autonomously after code is written

#### compliance-auditor.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Audit code changes against AGENTS.md rules
- **Focus:** Match diffs against project-specific configuration rules
- **Output:** Violations with severity, line refs, and quoted rule

#### comment-analyzer.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Code comment accuracy, completeness, long-term maintainability
- **Mode:** Advisory only — does not modify code
- **Output:** Critical Issues, Improvement Opportunities, Recommended Removals

#### pr-test-analyzer.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Test coverage quality and completeness
- **Focus:** Behavioral coverage over line coverage
- **Scoring:** Criticality 1-10
- **Output:** Critical Gaps, Important Improvements, Test Quality Issues

#### type-design-analyzer.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Type design quality and invariants
- **Scoring:** 4 dimensions rated 1-10 (Encapsulation, Invariant Expression, Usefulness, Enforcement)

#### pr-summarizer.md
- **Model:** gpt-5.3-codex-spark
- **Purpose:** Summarize PR changes — needs real code comprehension for meaningful summaries
- **Output:** Structured summary of what changed and why

#### Haiku-tier agents (gpt-5.1-codex-mini) — simple tasks

#### pr-triage.md
- **Model:** gpt-5.1-codex-mini
- **Purpose:** Quick PR status checks (draft/closed/already reviewed/trivial)
- **Output:** Boolean proceed/stop with reason

#### config-finder.md
- **Model:** gpt-5.1-codex-mini
- **Purpose:** Find all relevant AGENTS.md files in the repo
- **Output:** List of file paths

## Skill Definitions

### code-review (SKILL.md)

Automated multi-stage PR review adapted from the `code-review` plugin. Orchestrates a multi-phase review with validation.

**Process:**
1. **Triage** — `@pr-triage` checks if PR is draft/closed/already reviewed
2. **Context gathering** — `@config-finder` finds relevant AGENTS.md files in the repo
3. **PR summary** — `@pr-summarizer` summarizes changes
4. **Parallel review** — Launch agents in parallel:
   - 2x `@compliance-auditor` for AGENTS.md compliance checks
   - 2x `@code-reviewer` for bug detection (one diff-only, one introduced code)
5. **Validation** — `@issue-validator` validates each flagged issue
6. **Filter** — Remove unvalidated issues
7. **Output** — Summary to terminal; if `--comment` provided, post GitHub comments
8. **Inline comments** — Use GitHub MCP for inline PR comments with suggestion blocks

**False positive exclusion list:**
- Pre-existing issues
- Pedantic nitpicks
- Issues a linter would catch
- General code quality concerns unless in AGENTS.md
- Issues silenced via lint-ignore comments

### review-pr (SKILL.md)

Comprehensive selective review adapted from `pr-review-toolkit`. Supports selective invocation of review aspects.

**Arguments:** `[tests|errors|types|code|simplify|comments|all|parallel]`

**Process:**
1. Check git status, parse arguments
2. Identify changed files and applicable reviews
3. Launch relevant agents (sequentially by default, parallel if requested):
   - `@code-reviewer` — always applicable
   - `@pr-test-analyzer` — if test files changed
   - `@comment-analyzer` — if comments/docs added
   - `@silent-failure-hunter` — if error handling changed
   - `@type-design-analyzer` — if types added/modified
   - `@code-simplifier` — after passing review (polish step)
4. Aggregate results by severity (Critical / Important / Suggestions / Positive)
5. Provide action plan with file:line references

## Integration Notes

- Agents are individually invocable via `@mention` for ad-hoc use
- Skills orchestrate multi-agent workflows for comprehensive review
- GitHub interactions use `gh` CLI for PR operations + GitHub MCP for inline comments
- The `install.sh` script handles deployment — no opencode plugin system needed
