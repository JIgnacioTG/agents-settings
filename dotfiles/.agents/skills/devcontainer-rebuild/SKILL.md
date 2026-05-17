---
name: devcontainer-rebuild
description: Use when the user wants to rebuild, recreate, reset, or rebuild without cache for the Reserhub and/or Adara devcontainers. This skill captures Ignacio's local ~/.zshrc rebuild workflow and should be used for OpenCode commands or direct requests such as "rebuild devcontainers", "recreate adara", or "rebuild reserhub no cache".
---

# Devcontainer Rebuild

Use this skill to recreate the known local devcontainers.

## Projects

| Argument | Project | Workspace folder | OpenChamber port |
| --- | --- | --- | --- |
| `reserhub`, `reserhub-revenue`, `reserhub-revenue-full` | Reserhub Revenue Full | `/Users/ignacio/repositories/reserhub-revenue-full` | `4098` |
| `adara`, `adara-crm` | Adara CRM | `/Users/ignacio/repositories/adara-crm` | `4099` |

If no project is specified, target both projects in parallel:

1. Reserhub Revenue Full
2. Adara CRM

If an unknown project is specified, stop and ask for the exact project key. Do not guess.

## Rebuild workflow

For each selected project, run the same core command used by `~/.zshrc`:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container
```

If the user explicitly requests no-cache behavior with `no-cache`, `nocache`, or `--build-no-cache`, add `--build-no-cache`:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>" --remove-existing-container --build-no-cache
```

Forward any explicit extra arguments after the project key and no-cache flag to the devcontainer CLI.

When both projects are selected, launch the two `bunx @devcontainers/cli up --remove-existing-container` commands concurrently as independent shell tasks. Do not rebuild Reserhub first and wait before starting Adara unless the user explicitly requests sequential execution or one project depends on the other.

## MCP auth sync

After a successful rebuild, sync remote MCP auth into the devcontainer persistent root:

```bash
opencode-sync-mcp-auth-devcontainer --root "<workspace-folder>/.devcontainer-persistent"
```

If sync fails because no matching remote MCP auth exists, report it as a warning but do not treat the rebuild as failed.

When both projects were rebuilt in parallel, sync MCP auth for each successful project in parallel after its corresponding rebuild command completes.

## OpenChamber link

After all selected devcontainers finish rebuilding, use the `openchamber-week-link` skill for each selected project's OpenChamber port.

When multiple projects are selected, generate and output one link per project with the project label and port. Generate the links in parallel when both OpenChamber instances are available.

## Final response

Report:

- Which project(s) were rebuilt.
- Whether no-cache was used.
- Whether MCP auth sync succeeded or warned.
- The one-week OpenChamber link(s), labeled by project.
- Any command that failed, including the failing project.
