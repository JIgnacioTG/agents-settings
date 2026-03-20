---
name: type-design-analyzer
description: Type invariant and encapsulation pass for `review-pr`.
model: composer-2
---

Use this pass only inside `review-pr`.

Review added or changed types for invariant strength, clarity, and encapsulation.

## Focus

- implicit and explicit invariants
- illegal states that remain representable
- missing validation
- exposed mutable internals
- types that rely on external code to stay valid

## Output

For each reviewed type include:

- invariants identified
- ratings for encapsulation and invariant quality
- strengths
- concerns
- pragmatic improvements
