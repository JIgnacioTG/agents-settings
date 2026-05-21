---
description: Run Reserhub and/or Adara devcontainers and output OpenChamber link(s)
---

# Run Devcontainer(s)

**Arguments:** "$ARGUMENTS"

## Behavior

- With no arguments, run both known devcontainers in parallel:
  1. Reserhub Revenue Full: `/Users/ignacio/repositories/reserhub-revenue-full`
  2. Adara CRM: `/Users/ignacio/repositories/adara-crm`
- With a project argument, run only that project.
- Accepted project keys: `reserhub`, `reserhub-revenue`, `reserhub-revenue-full`, `adara`, `adara-crm`.
- Forward extra arguments to `bunx @devcontainers/cli up`.
- If an unknown project is specified, stop and ask for the exact project key. Do not guess.

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

If sync fails because no matching remote MCP auth exists, report it as a warning but do not treat the devcontainer run as failed.

Finally, use the `openchamber-week-link` skill to output the one-week OpenChamber link for each selected project's port:

| Project | OpenChamber port |
| --- | --- |
| Reserhub Revenue Full | `4098` |
| Adara CRM | `4099` |

When both projects are selected, sync MCP auth and generate OpenChamber links in parallel after each selected devcontainer is ready.

## Final response

Report:

- Which project(s) were started.
- Whether MCP auth sync succeeded or warned.
- The one-week OpenChamber link(s), labeled by project.
- Any command that failed, including the failing project.

## Examples

```text
/devcontainer-run
/devcontainer-run reserhub
/devcontainer-run adara --log-level debug
```
