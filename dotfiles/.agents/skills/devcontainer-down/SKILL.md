---
name: devcontainer-down
description: Use when the user wants to stop, down, shut down, or bring down the Reserhub and/or Adara devcontainers. This skill captures Ignacio's local ~/.zshrc down workflow and should be used for OpenCode commands or direct requests such as "down devcontainers", "stop adara devcontainer", or "bring down reserhub".
---

# Devcontainer Down

Use this skill to stop the known local devcontainers without rebuilding or starting them.

## Projects

| Argument | Project | Workspace folder |
| --- | --- | --- |
| `reserhub`, `reserhub-revenue`, `reserhub-revenue-full` | Reserhub Revenue Full | `/Users/ignacio/repositories/reserhub-revenue-full` |
| `adara`, `adara-crm` | Adara CRM | `/Users/ignacio/repositories/adara-crm` |

If no project is specified, target both projects in this order:

1. Reserhub Revenue Full
2. Adara CRM

If an unknown project is specified, stop and ask for the exact project key. Do not guess.

## Down workflow

For each selected project, run the same workflow used by `~/.zshrc`.

Stop compose services:

```bash
docker compose -f "<workspace-folder>/.devcontainer/docker-compose.devcontainer.yml" down --remove-orphans
```

Then stop any remaining devcontainer containers matching the repo-name pattern:

```bash
docker ps -q --filter "name=<repo-name>_devcontainer" | xargs -r docker stop
```

Use `<repo-name>` as the basename of the workspace folder, for example `reserhub-revenue-full` or `adara-crm`.

The original zsh workflow suppresses failures and continues when nothing is running. Preserve that behavior: a missing running container is not an error.

## Final response

Report:

- Which project(s) were brought down.
- Whether compose down completed or had a warning.
- Whether any leftover matching containers were stopped.
- Any command that failed unexpectedly, including the failing project.

Do not start, rebuild, sync MCP auth, or generate OpenChamber links from this skill.
