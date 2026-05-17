---
name: devcontainer-run
description: Use when the user wants to start, run, bring up, or ensure the Reserhub and/or Adara devcontainers are running. This skill captures Ignacio's local ~/.zshrc devcontainer workflow and should be used for OpenCode commands or direct requests such as "run devcontainers", "start adara devcontainer", or "bring up reserhub".
---

# Devcontainer Run

Use this skill to start the known local devcontainers without recreating existing containers.

## Projects

| Argument | Project | Workspace folder | OpenChamber port |
| --- | --- | --- | --- |
| `reserhub`, `reserhub-revenue`, `reserhub-revenue-full` | Reserhub Revenue Full | `/Users/ignacio/repositories/reserhub-revenue-full` | `4098` |
| `adara`, `adara-crm` | Adara CRM | `/Users/ignacio/repositories/adara-crm` | `4099` |

If no project is specified, target both projects in this order:

1. Reserhub Revenue Full
2. Adara CRM

If an unknown project is specified, stop and ask for the exact project key. Do not guess.

## Run workflow

For each selected project, run the same core command used by `~/.zshrc`:

```bash
bunx @devcontainers/cli up --workspace-folder "<workspace-folder>"
```

Forward any explicit extra arguments after the project key to the devcontainer CLI. Do not add `--remove-existing-container` or `--build-no-cache`; those belong to the rebuild workflow.

## MCP auth sync

After a successful `up`, sync remote MCP auth into the devcontainer persistent root:

```bash
opencode-sync-mcp-auth-devcontainer --root "<workspace-folder>/.devcontainer-persistent"
```

If sync fails because no matching remote MCP auth exists, report it as a warning but do not treat the devcontainer run as failed.

## OpenChamber link

After all selected devcontainers finish starting, use the `openchamber-week-link` skill for each selected project's OpenChamber port.

When multiple projects are selected, output one link per project with the project label and port.

## Final response

Report:

- Which project(s) were started.
- Whether MCP auth sync succeeded or warned.
- The one-week OpenChamber link(s), labeled by project.
- Any command that failed, including the failing project.
