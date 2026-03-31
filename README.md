# agents-settings

Custom agent settings, used across my machines (linux-mac)

## Install

`install.sh` symlinks regular dotfiles and copies `.agents/skills/*` as real directories so Codex can discover installed skills reliably from `~/.agents/skills`.

## Layout after install

| Tool | Location |
|------|----------|
| Codex skills | `~/.agents/skills/` (copied) |
| OpenCode | `~/.config/opencode/` (symlinked files from `dotfiles/.config/opencode/`) |
| Cursor | `~/.cursor/agents/`, `~/.cursor/commands/`, `~/.cursor/skills/`, `~/.cursor/rules/`, `~/.cursor/AGENTS.md` (symlinked from `dotfiles/.cursor/`) |

Shared grouped execution skills live only under `~/.agents/skills/`. OpenCode and Cursor no longer keep duplicated `grouped-tasks` or `executing-grouped-tasks` copies.

### Cursor: user rules vs `AGENTS.md`

- **`AGENTS.md`** at the project root (and nested dirs) is picked up by Cursor automatically. After install, `~/.cursor/AGENTS.md` holds the canonical copy of working agreements from this repo.
- **User Rules** (Cursor Settings → Rules) apply across all projects but are not stored in this repository. To mirror the same agreements globally, paste the contents of `dotfiles/.cursor/AGENTS.md` into User Rules, or rely on project-level `AGENTS.md` / `.cursor/rules/` when a project includes them.

### Cursor models

Subagents use `composer-2` (Composer 2) and `composer-2-fast` (Composer 2 Fast) in YAML frontmatter. Confirm identifiers in **Cursor Settings → Models** or your local `~/.cursor/cli-config.json` if a future Cursor build renames them.
