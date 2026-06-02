---
description: Create a learning plan artifact from a learning name or path
---

# Add Learning

Use the `learning-artifact-planner` skill as the canonical workflow. This command is a thin launcher so command text cannot drift from the skill's learning-plan contract.

**Arguments:** "$ARGUMENTS"

## Dispatch

1. Load the `learning-artifact-planner` skill.
2. Pass `$ARGUMENTS` to the skill unchanged.
3. Treat `$ARGUMENTS` as a learning name first.
4. If no learning can be resolved by name, treat `$ARGUMENTS` as a path.
5. If neither a name nor path resolves, ask one concise clarification question.
6. Follow the skill exactly for source references, target classification, `docs/plans` artifact creation, and final `Path:` / `Name:` output.

## Guardrails

- Do not duplicate the skill's artifact template, classification rules, target-scope rules, or output contract in this command.
- Do not modify project skills, user skills, project `AGENTS.md`, user `AGENTS.md`, or command files directly.
- If this command and the skill conflict, follow the skill.
