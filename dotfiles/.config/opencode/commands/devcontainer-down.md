---
description: Bring down Reserhub and/or Adara devcontainers
---

# Down Devcontainer(s)

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, bring down both known devcontainers in parallel:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, bring down only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.
- If an unknown project is specified, stop and ask for the exact project key. Do not guess.

## Commands

Run each selected project with:

```bash
docker compose -f "<workspace-folder>/.devcontainer/docker-compose.devcontainer.yml" down --remove-orphans
```

Then stop leftover devcontainer containers:

```bash
docker ps -q --filter "name=<repo-name>_devcontainer" | xargs -r docker stop
```

Use `<repo-name>` as the basename of the workspace folder, for example `reserhub-revenue-full` or `adara-crm`.

The original zsh workflow suppresses failures and continues when nothing is running. Preserve that behavior: a missing running container is not an error.

When both projects are selected, launch each project's compose down and leftover-container stop workflow concurrently as independent shell tasks.

Do not run, rebuild, sync MCP auth, or output OpenChamber links from this command.

## Final response

Report:

- Which project(s) were brought down.
- Whether compose down completed or had a warning.
- Whether any leftover matching containers were stopped.
- Any command that failed unexpectedly, including the failing project.

## Examples

```text
/devcontainer-down
/devcontainer-down reserhub
/devcontainer-down adara
```
