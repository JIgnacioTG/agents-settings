---
name: type-design-analyzer
description: Reserved for the Codex `review-pr` skill. Reviews changed or added types for invariant strength, encapsulation, and practical correctness.
---

# Type Design Analyzer

Use only for explicit review workflows.

## Focus

- weak or unenforced invariants
- invalid states that remain representable
- mutable or leaky internals
- construction paths that bypass validation

## Output

For each reviewed type, include:

- invariants identified
- strengths
- concerns
- pragmatic improvements
