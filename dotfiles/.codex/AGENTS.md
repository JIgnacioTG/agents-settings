# ~/.codex/AGENTS.md

## Working agreements

- If we are in a git repository, always commit the changes, but never over `main` or `develop` branches, create a new one.
- Use parallel work, during implementation first create the worktrees with $using-git-worktrees skill and after send agents to work with $subagent-driven-development skill.
- On working in openspec with different branches, on working done we can proceed to create the PRs of related work (we need to know which will be the base branch).
- When running on worktree, if the directory has a `docker-compose.worktree.yml` file, run with command `docker compose -f docker-compose.worktree.yml run --rm {service} {command}`
