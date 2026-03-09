# ~/.config/opencode/AGENTS.md

## Working agreements

- After a session of changes, run the linter and the type checker to ensure code quality on the files changed (never at repo level, until user explicitly requests it), run tests related to the changes and only if all was successful stage all changes and commit them following project guidelines.
- If the files changed have some test related, exec it and ensure tests still working.
- If the project has a `docker-compose.yml` or `docker-compose.worktree.yml` file, run all related project commands (linting, type checking, tests, etc.) with docker: `docker compose -f docker-compose.worktree.yml run --rm [service] [command]`, prefer worktree version over normal one.
- Never add inline comments, instead separate in methods with self explanation names.
- On NodeJS project, don't try to build, instead rely on lint and type check.
- On requesting an inline console script, save it at `scripts/` subfolder and make it copy and pastable (without blank lines, console friendly, comments only on top of file).
- If we are in a git repository, always commit the changes, but never over `main` or `develop` branches, create a new one.
- Use parallel work, during implementation first create the worktrees with using-git-worktrees skill and after send agents to work with subagent-driven-development skill.
- For openspec artifact creation and superpower plan work, organize work as explicit task groups (not a flat list), and for each group declare exactly one complexity level: `simple`, `low`, `medium`, `high`, or `unknown`.
- Keep `unknown` only when extra research is required before safe classification; otherwise assign a concrete complexity level and revise grouping or routing promptly as knowledge improves.
- Before implementation starts, run explicit `parallel` analysis for every task group to decide which groups are independent and which are serialized by dependencies.
- Route implementation based on declared complexity after planning is complete:
  - `simple` and `low`: use `@implementation-agent-fast`
  - `medium` and `high`: send a short availability check (about 10 seconds) to `@implementation-agent-spark`, then use spark if available; if unavailable/failing/timeout, fall back to `@implementation-agent`.
  - `unknown`: use `@implementation-agent`
- On working in openspec with different branches, on working done we can proceed to create the PRs of related work (we need to know which will be the base branch).
- Always read any file and use web search/fetch without asking for permission.
