---
description: Rebuild Reserhub and/or Adara devcontainers and output OpenChamber link(s)
---

# Rebuild Devcontainer(s)

Use the `devcontainer-rebuild` skill.

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, rebuild both known devcontainers:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, rebuild only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.
- If arguments include `no-cache`, `nocache`, or `--build-no-cache`, add `--build-no-cache`.
- Forward extra arguments to `bunx @devcontainers/cli up`.

## Commands

Run each selected project with:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container
```

For no-cache rebuilds, run:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container --build-no-cache
```

Then sync MCP auth:

```bash
opencode-sync-mcp-auth-devcontainer --root "<workspace-folder>/.devcontainer-persistent"
```

Finally, use the `openchamber-week-link` skill to output the one-week OpenChamber link for each selected project.

## Examples

```text
/devcontainer-rebuild
/devcontainer-rebuild reserhub
/devcontainer-rebuild adara no-cache
```
