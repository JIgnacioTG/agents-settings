---
description: Rebuild Reserhub and/or Adara devcontainers and output OpenChamber link(s)
---

# Rebuild Devcontainer(s)

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, rebuild both known devcontainers in parallel:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, rebuild only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.
- If arguments include `no-cache`, `nocache`, or `--build-no-cache`, add `--build-no-cache`.
- Forward extra arguments to `bunx @devcontainers/cli up`.
- If an unknown project is specified, stop and ask for the exact project key. Do not guess.

## Commands

Run each selected project with:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container
```

When both projects are selected, launch the two rebuild commands concurrently as independent shell tasks.

For no-cache rebuilds, run:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container --build-no-cache
```

Then sync MCP auth:

```bash
opencode-sync-mcp-auth-devcontainer --root "<workspace-folder>/.devcontainer-persistent"
```

If sync fails because no matching remote MCP auth exists, report it as a warning but do not treat the rebuild as failed.

Finally, use the `openchamber-week-link` skill to output the one-week OpenChamber link for each selected project's port:

| Project | OpenChamber port |
| --- | --- |
| Reserhub Revenue Full | `4098` |
| Adara CRM | `4099` |

When both projects are selected, sync MCP auth and generate OpenChamber links in parallel after each selected devcontainer is ready.

## Final response

Report:

- Which project(s) were rebuilt.
- Whether no-cache was used.
- Whether MCP auth sync succeeded or warned.
- The one-week OpenChamber link(s), labeled by project.
- Any command that failed, including the failing project.

## Examples

```text
/devcontainer-rebuild
/devcontainer-rebuild reserhub
/devcontainer-rebuild adara no-cache
```
