---
description: Bring down Reserhub and/or Adara devcontainers
---

# Down Devcontainer(s)

Use the `devcontainer-down` skill.

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, bring down both known devcontainers:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, bring down only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.

## Commands

Run each selected project with:

```bash
docker compose -f "<workspace-folder>/.devcontainer/docker-compose.devcontainer.yml" down --remove-orphans
```

Then stop leftover devcontainer containers:

```bash
docker ps -q --filter "name=<repo-name>_devcontainer" | xargs -r docker stop
```

Do not run, rebuild, sync MCP auth, or output OpenChamber links from this command.

## Examples

```text
/devcontainer-down
/devcontainer-down reserhub
/devcontainer-down adara
```
