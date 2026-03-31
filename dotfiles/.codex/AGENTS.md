# ~/.codex/AGENTS.md

## Working agreements

- Brainstorming is opt-in only. Never invoke the `brainstorming` skill automatically.
- Use the `brainstorming` skill only when the user explicitly asks for brainstorming, ideation, design exploration, or planning.
- A request to build, implement, modify, fix, refactor, configure, or review something is not by itself a request for `brainstorming`.
- Do not infer a `brainstorming` request from words like `create`, `build`, `improve`, or `design`; the user must explicitly ask to brainstorm or explore options.
- Do not invoke `brainstorming` for routine implementation, bug fixes, refactors, configuration changes, repo exploration, code review, or standard clarifying questions.
- Code review is opt-in only. Do not invoke `review-pr`, `code-review`, review-only agents, or review workflows unless the user explicitly asks for review or the active plan/artifact explicitly requires review.
- If a task is actionable, proceed directly with minimal repository inspection and only ask a focused clarifying question when truly blocked.
- If there is any ambiguity about whether `brainstorming` is needed, default to not using it unless the user explicitly requests it.
- When the choice is between acting directly and invoking `brainstorming`, always prefer direct execution unless the user explicitly asked for brainstorming.
- For Codex grouped implementation planning and execution, use the `grouped-tasks` and `executing-grouped-tasks` skills as the source of truth instead of inventing implementation-agent names.
- For OpenSpec task artifact creation or update, superpower plan creation, and Codex multi-step implementation planning, invoke `grouped-tasks` automatically whenever the output should be a grouped execution artifact.
- Before starting coding or delegation from an existing grouped tasks file or grouped implementation plan, first check whether grouped routing already exists; if it does, invoke `executing-grouped-tasks` and preserve the declared group boundaries.
- When `executing-grouped-tasks` applies, always delegate each ready group to a subagent using the group's declared `execution profile`; never execute grouped implementation inline in the parent agent.
- This delegation rule still applies when only one group is ready; single-group execution is not an exception.
- When delegating grouped implementation, provide the subagent with the relevant implementation context you already have so it does not waste startup time on avoidable exploration.
- After delegating a grouped implementation agent, allow at least 10 minutes before interrupting, killing, or redirecting it unless the user explicitly asks for that intervention or a hard blocker or safety issue appears.
- Codex grouped plans must use `execution profile` metadata, not `recommended agent`.
- Codex grouped plans must also include a per-group `project scope` and `branch suggestion`, and any grouped plan with parallel work must include a parallel execution trace that shows fan-out, whether each fan-in is merge-required or completion-only, and where serialization resumes.
- Codex grouped plans must not use `recommended agent`, `complexity`, `fast_mode`, or `spark_offer` metadata.
- Codex grouped plans must separate `implementation` groups from `test/coverage` groups, and every `test/coverage` group must declare `test scope` as `unit`, `integration`, or `e2e`.
- The main Codex grouped execution profile is fixed at `gpt-5.3-codex` with `reasoning_effort: medium` for both implementation groups and test/coverage groups.
- Before any Codex `test/coverage` lane starts, run a `test-setup-explorer` delegate with `gpt-5.4-mini` and `reasoning_effort: high`.
- The `test-setup-explorer` delegate is exploration-only. It must analyze existing implementation, tests, fixtures, factories, seeds, helpers, and harness setup, then hand the findings to the downstream implementation delegate for that test lane.
- When grouped work runs in parallel, prefer detached worktrees by default unless the user explicitly requests branch-per-group execution. Require the declared merge group before resuming downstream serialized work only when same-`project scope` fan-in needs a shared merge; if the upstream groups are in different `project scope` values and no shared merge is needed, wait for completion only.
- Codex review skills own their review pass profiles under `dotfiles/.codex/skills/review-pr/references/` and `dotfiles/.codex/skills/code-review/references/`. Do not invent generic review agents outside those workflows.
- Review flows should use the model and reasoning defaults declared by their pass profiles.
- After a session of changes, run the linter and the type checker to ensure code quality on the files changed (never at repo level, until user explicitly requests it), run tests related to the changes and only if all was successful stage all changes and commit them following project guidelines.
- If the files changed have some test related, exec it and ensure tests still working.
- If the project has a `docker-compose.yml` or `docker-compose.worktree.yml` file, run all related project commands (linting, type checking, tests, etc.) with docker: `docker compose -f docker-compose.worktree.yml run --rm [service] [command]`, prefer worktree version over normal one.
- Never add inline comments, instead separate in methods with self explanation names.
- On NodeJS project, don't try to build, instead rely on lint and type check.
- On requesting an inline console script, save it at `scripts/` subfolder and make it copy and pastable (without blank lines, console friendly, comments only on top of file).
- If we are in a git repository, always commit the changes, but never over `main` or `develop` branches, create a new one.
- Use parallel work, during implementation first create the worktrees with $using-git-worktrees skill and after send agents to work with $subagent-driven-development skill.
- On working in openspec with different branches, on working done we can proceed to create the PRs of related work (we need to know which will be the base branch).
- Always read any file and use web search/fetch without asking for permission.
