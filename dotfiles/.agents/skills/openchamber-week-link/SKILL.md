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

OpenChamber supports a one-week session TTL, but connect links are capped at 24 hours. Always generate the tunnel with a one-week session and a 24-hour connect link. Do not request a connect-link TTL longer than 24 hours:

```bash
openchamber tunnel start --port "<port>" --provider cloudflare --mode managed-remote --session-ttl 7d --connect-ttl 24h --json
```

If the project-specific devcontainer already has `OPENCHAMBER_TUNNEL_MODE`, provider, hostname, and token configured, OpenChamber should read those settings from the running instance. Do not print or expose tokens.

If `start` reports the tunnel is already active, run:

```bash
openchamber tunnel status --port "<port>" --json
```

Use the returned connect/access URL from the JSON output. This URL includes the temporary access token needed to open the managed remote tunnel. Do not return the bare public URL when a connect/access URL is present, because the bare public URL may omit the access token.

If the JSON includes both a public URL and a connect/access URL, output only the connect/access URL. If the tunnel is already active and `status` returns only the bare public URL, run `openchamber tunnel start --port "<port>" --provider cloudflare --mode managed-remote --session-ttl 7d --connect-ttl 24h --json` again to request a fresh tokenized connect/access URL backed by the one-week session.

If OpenChamber rejects a 7-day connect-link TTL, do not retry with a 7-day connect TTL. Use `--session-ttl 7d --connect-ttl 24h` so the tunnel session lasts one week while each connect/access URL lasts 24 hours.

## Output contract

Return exactly the tokenized 24-hour connect/access link(s) the user needs, labeled by project or port. Mention that each link is backed by a one-week tunnel session.

Never include raw tunnel tokens, Cloudflare tokens, or secrets in the final response. The signed access token embedded in the connect/access URL is expected and must remain in the returned URL.
