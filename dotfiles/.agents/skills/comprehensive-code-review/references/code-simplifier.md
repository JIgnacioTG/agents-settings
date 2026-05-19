---
name: code-simplifier
description: Simplification-only polish pass for `comprehensive-code-review`.
---

Use this pass only inside `comprehensive-code-review`.

Run this post-review pass by default after the main review passes finish with no validated critical blockers. This is a readability and simplification step, not a bug-finding step.

## Scope

- reduce unnecessary complexity in changed code without altering behavior
- apply SOLID-oriented simplifications when they clarify responsibilities or dependencies
- prefer early returns over nested conditionals when behavior stays identical
- reduce nesting, branching noise, and temporary state when the control flow becomes clearer
- remove local redundancy, duplicate logic, dead branches, or needless indirection in touched code
- replace nested ternary operators with named variables, guard clauses, or small helper methods when that makes the decision readable
- flatten nested loops when equivalent iteration, indexing, extraction, or collection operations make intent clearer without changing complexity or order-sensitive behavior
- extract cohesive blocks into named methods or functions when the name captures a real domain step and reduces mixed abstraction levels
- split long boolean conditions into named predicates when the names explain domain intent
- remove duplicate branches, repeated calculations, and temporary state that obscure the changed behavior

## Activate When

- the main review passes are complete
- no critical issues or blockers remain open
- changed code can be reviewed for behavior-preserving readability improvements
- the user did not explicitly request findings only or exclude suggestions/simplification

Do not run this pass while correctness, security, or blocker-level review items are still open.

## Flag Only

- simplifications that preserve exact behavior while making the changed code easier to read or maintain
- safe extractions, consolidations, or reorderings that reduce duplication or nesting without changing outputs or side effects
- opportunities to replace complex branching with equivalent early-return structure
- redundancies that can be removed without altering public contracts, data flow, or observable behavior
- nested ternaries that would be clearer as named predicates, guard clauses, or a small function
- nested loops whose intent becomes clearer through a behavior-equivalent extraction or simpler iteration shape
- cohesive chunks that should become named methods because the current code mixes abstraction levels
- repeated branch bodies or repeated calculations that can be consolidated safely
- long conditionals that would be clearer as named predicates

Each finding should name the simpler shape, not just say that the code is complex.

## Do Not Flag

- bug reports, correctness concerns, or blocker issues owned by the main review passes
- behavior-altering refactors, architecture rewrites, or public API changes
- speculative cleanup that cannot show equivalence from the changed code
- style-only nits unrelated to simplification
- extraction for its own sake when a simple inline expression is already clearer
- hiding a short, obvious two-line expression behind a helper method
- changes that require new abstractions, configuration, or compatibility layers to justify the suggestion
- formatting-only preferences

## Verification

- every suggestion must state that behavior must not change
- every suggestion must explain why the simpler shape is behavior-equivalent from the changed code
- if equivalence depends on verification, name the narrow test or manual check needed
- keep recommendations simplification-only and limited to equivalent code paths
- return no findings when simplification would require semantic, contract, or side-effect changes

## Output

For each finding include:

- `file`
- `line`
- `severity`: `low | medium`
- `explanation`: concise simplification rationale tied to unchanged behavior
- `confidence`: `0-100`
