---
name: feedback-learning-review
description: Use when receiving PR comments, code review feedback, reviewer requests, or user feedback that may reveal project conventions or user preferences. Analyze requested changes, classify each as a project pattern, user-level preference, one-off context, or unclear, aggregate reusable learnings, cite sources, and ask whether to learn them before changing skills or AGENTS.md files.
---

# Feedback Learning Review

Use this skill when review feedback might contain reusable guidance for future agent work. The goal is to separate real learnings from one-off fixes before anything is written into project or user guidance.

## Workflow

1. Gather the feedback surface.
   - Include PR comments, unresolved review threads, pasted reviewer feedback, user correction messages, and the code or plan changes that addressed them.
   - Preserve source references for every item: PR URL, comment URL, reviewer, file path, line, commit, local diff path, transcript excerpt, or user message.
   - If the current branch has a related GitHub PR, fetch unresolved comments before analysis when `gh` is available.

2. Classify each feedback item.
   - `project-pattern`: a convention that belongs to the current repository, product, stack, tests, architecture, or project `AGENTS.md`.
   - `user-preference`: a preference that should follow the user across repositories, such as response style, commit behavior, review posture, planning expectations, or user-level agent rules.
   - `tooling-skill`: behavior that should become or update a reusable skill because it is procedural, repeatable, and not limited to one repository.
   - `one-off`: a fix that applies only to this diff, issue, branch, or temporary context.
   - `unclear`: feedback that needs more evidence before it can be learned safely.

3. Verify whether the item is actually a pattern.
   - Search the codebase, existing skills, commands, plans, and applicable `AGENTS.md` files for matching conventions before proposing a learning.
   - Treat repeated feedback across comments or sessions as stronger evidence than a single reviewer remark.
   - Do not convert a reviewer opinion into a rule unless it is supported by project evidence or confirmed by the user.

4. Aggregate reusable learnings.
   - Merge duplicate or overlapping feedback into one proposed learning.
   - Keep project-level and user-level learnings separate.
   - Keep confidence explicit: high for established conventions, medium for repeated but undocumented patterns, low for plausible but weak signals.

5. Ask before learning.
   - Present the proposed learnings and ask the user which ones to capture.
   - Do not create, update, or edit project skills, user skills, project `AGENTS.md`, user `AGENTS.md`, commands, or plan files until the user approves the selected learnings or invokes the learning-plan workflow.

## Output Format

Use this structure:

```markdown
# Feedback Learning Analysis

## Source References
- [reference label](reference URL or path) - what it supports

## Feedback Items
| ID | Source | Request | Classification | Confidence | Rationale |
| --- | --- | --- | --- | --- | --- |

## Proposed Project Learnings
| ID | Learning | Evidence | Suggested target |
| --- | --- | --- | --- |

## Proposed User Learnings
| ID | Learning | Evidence | Suggested target |
| --- | --- | --- | --- |

## One-Off Or Rejected Items
| ID | Reason |
| --- | --- |

## Approval Question
Which proposed learnings should I capture in a learning plan?
```

## Guardrails

- Do not blindly accept PR feedback as truth. Verify it against the repository and existing instructions.
- Do not weaken existing project or user guidance without explicit approval.
- Do not write speculative compatibility, fallback, or legacy rules unless the source evidence shows they are required.
- Do not mix project learnings and user learnings in the same proposed target.
- Do not lose traceability: every proposed learning needs at least one source reference.
