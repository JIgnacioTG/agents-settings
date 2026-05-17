---
name: openchamber-week-link
description: Use when the user needs an OpenChamber public/tunnel link, especially after starting or rebuilding devcontainers. Generates or retrieves an OpenChamber tunnel link with a one-week session TTL for local ports such as Reserhub 4098 or Adara 4099.
---

# OpenChamber One-Week Link

Use this skill to produce OpenChamber access links after devcontainer startup workflows.

## Known ports

| Project | OpenChamber port |
| --- | --- |
| Reserhub Revenue Full | `4098` |
| Adara CRM | `4099` |

If the request provides a port, use that port. If no project or port is clear, ask for the port.

## Generate the link

OpenChamber supports a one-week session TTL, but connect links are capped at 24 hours. Generate the tunnel with a one-week session and a 24-hour connect link:

```bash
openchamber tunnel start --port "<port>" --provider cloudflare --mode managed-remote --session-ttl 7d --connect-ttl 24h --json
```

If the project-specific devcontainer already has `OPENCHAMBER_TUNNEL_MODE`, provider, hostname, and token configured, OpenChamber should read those settings from the running instance. Do not print or expose tokens.

If `start` reports the tunnel is already active, run:

```bash
openchamber tunnel status --port "<port>" --json
```

Use the returned public URL/connect URL from the JSON output.

## Output contract

Return exactly the link(s) the user needs, labeled by project or port. Mention that the session TTL is one week and the connect link TTL is 24 hours if relevant.

Never include tunnel tokens, Cloudflare tokens, or secrets in the final response.
