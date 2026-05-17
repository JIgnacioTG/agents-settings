---
description: Run Reserhub and/or Adara devcontainers and output OpenChamber link(s)
---

# Run Devcontainer(s)

Use the `devcontainer-run` skill.

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, run both known devcontainers in parallel:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, run only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.
- Forward extra arguments to `bunx @devcontainers/cli up`.

## Commands

Run each selected project with:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>"
```

When both projects are selected, launch the two `bunx @devcontainers/cli up` commands concurrently as independent shell tasks.

Then sync MCP auth:

```bash
opencode-sync-mcp-auth-devcontainer --root "<workspace-folder>/.devcontainer-persistent"
```

Finally, use the `openchamber-week-link` skill to output the one-week OpenChamber link for each selected project.

When both projects are selected, sync MCP auth and generate OpenChamber links in parallel after each selected devcontainer is ready.

## Examples

```text
/devcontainer-run
/devcontainer-run reserhub
/devcontainer-run adara --log-level debug
```
