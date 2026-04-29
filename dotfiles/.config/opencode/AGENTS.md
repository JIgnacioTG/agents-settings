# ~/.config/opencode/AGENTS.md

## Working agreements

- Code review is opt-in only. Do not invoke `comprehensive-code-review`, review agents, or review workflows unless the user explicitly asks for review or the active plan/artifact explicitly requires review. For end-of-plan execution and end-of-OpenSpec-task execution, auto-trigger the multi-agent `review-work` skill over the changed scope.
- After a session of changes, run the formatter, linter, and type checker to ensure code quality on the files changed (never at repo level, until user explicitly requests it), run tests related to the changes and only if all was successful stage all changes and commit them following project guidelines.
- When applying approved OpenSpec artifacts or executing an already-written plan as-is, do not invoke `test-driven-development` or `verification-before-completion`; this includes `/openspec-apply-change`, and `/opsx:apply` flows unless the user explicitly asks to rewrite the plan. OpenSpec verification is explicit-only: use `verification-before-completion` only when the active group is explicitly a verification group, which is usually the last group, or when the user explicitly requests verification. Do not auto-trigger verification from generic OpenSpec execution. Even in those execution flows, always finish with changed-scope formatter, linter, typecheck, related tests, and a code review. For OpenSpec flows, also run `openspec-verify-change` as the final OpenSpec-specific verification step.
- If the files changed have some test related, exec it and ensure tests still working.
- If the project has a `docker-compose.yml` or `docker-compose.worktree.yml` file, run all related project commands (linting, type checking, tests, etc.) with docker: `docker compose -f docker-compose.worktree.yml run --rm [service] [command]`, prefer worktree version over normal one.
- Never add inline comments, instead separate in methods with self explanation names.
- On user requesting manually test over playwright or test with playwright ui, run all process needed to reach the playwright ui using the env vars that devcontainer uses, if are empty use the default ones. Use `nohup` to prevent the process from being killed when the session ends.
- For OpenSpec explore and proposal/design/tasks artifact generation, use the `openspec-workflow` skill so open questions are surfaced before generation and final output summarizes artifact highlights and paths.
- For frontend E2E validation with Playwright, use the `e2e-evidence` skill so screenshots are captured under `.sisyphus/evidence/`, attached to Playwright reports when applicable, and exact evidence paths are listed in the final output.
- On NodeJS project, don't try to build, instead rely on lint and type check.
- On requesting an inline console script, save it at `scripts/` subfolder and make it copy and pastable (without blank lines, console friendly, comments only on top of file).
- If we are in a git repository, always commit implementation changes. Design docs and implementation plans are excluded from forced commit only when those artifacts are gitignored (i.e., they should not be force-committed when gitignored).
- Never commit directly to `main` or `develop`—ask the user whether to continue or create a new branch.
- Always ensure the git user name and email is set before to commit, otherwise ask to the user who is the committer.
- On PR Review or Code Review, before to start the analysis we need to validate if the branch has a GitHub (gh) PR related, we will fetch the unresolved comments to add in the analysis.
- Always read any file and use web search/fetch without asking for permission.
- Always use parallel approach.
- Always delegate the work on ultrawork mode. Use `category` for category-routed implementation delegation, and use `subagent_type` only for named direct agents such as `explore`, `librarian`, `oracle`, `metis`, or `momus`. Never provide both `category` and `subagent_type` in the same delegation call. If the work is complex or has many changes, create a plan that declares the correct category for each implementation group before delegating.
- When changing OpenCode config files that should also apply inside devcontainers, update the mirrored configs in `/Users/ignacio/repositories/reserhub-revenue-full/.devcontainer-persistent/config/opencode` and `/Users/ignacio/repositories/adara-crm/.devcontainer-persistent/config/opencode`.
