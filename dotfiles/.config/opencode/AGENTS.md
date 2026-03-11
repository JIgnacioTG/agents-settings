# ~/.config/opencode/AGENTS.md

## Working agreements

- Brainstorming is opt-in only. Never invoke the `brainstorming` skill automatically.
- Use the `brainstorming` skill only when the user explicitly asks for brainstorming, ideation, design exploration, or planning.
- A request to build, implement, modify, fix, refactor, configure, or review something is not by itself a request for `brainstorming`.
- Do not infer a `brainstorming` request from words like `create`, `build`, `improve`, or `design`; the user must explicitly ask to brainstorm or explore options.
- Do not invoke `brainstorming` for routine implementation, bug fixes, refactors, configuration changes, repo exploration, code review, or standard clarifying questions.
- If a task is actionable, proceed directly with minimal repository inspection and only ask a focused clarifying question when truly blocked.
- If there is any ambiguity about whether `brainstorming` is needed, default to not using it unless the user explicitly requests it.
- When the choice is between acting directly and invoking `brainstorming`, always prefer direct execution unless the user explicitly asked for brainstorming.
- After a session of changes, run the linter and the type checker to ensure code quality on the files changed (never at repo level, until user explicitly requests it), run tests related to the changes and only if all was successful stage all changes and commit them following project guidelines.
- If the files changed have some test related, exec it and ensure tests still working.
- If the project has a `docker-compose.yml` or `docker-compose.worktree.yml` file, run all related project commands (linting, type checking, tests, etc.) with docker: `docker compose -f docker-compose.worktree.yml run --rm [service] [command]`, prefer worktree version over normal one.
- Never add inline comments, instead separate in methods with self explanation names.
- On NodeJS project, don't try to build, instead rely on lint and type check.
- On requesting an inline console script, save it at `scripts/` subfolder and make it copy and pastable (without blank lines, console friendly, comments only on top of file).
- If we are in a git repository, always commit the changes, but never over `main` or `develop` branches, instead generate a question to the user if we can continue or we create a new branch.
- On working in openspec with different branches, on working done we can proceed to create the PRs of related work (we need to know which will be the base branch).
- Always read any file and use web search/fetch without asking for permission.
