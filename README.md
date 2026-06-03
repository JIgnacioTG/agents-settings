# agents-settings

Custom AGENTS, CLAUDE, and agent config settings, used across my machines (linux-mac).

## Install

`install.sh` symlinks regular dotfiles and recreates empty skill/command directories when needed. This repo no longer owns installed skills or command definitions.

## Layout after install

| Tool | Location |
|------|----------|
| Codex skills | `~/.agents/skills/` (empty directory managed only as a placeholder) |
| OpenCode | `~/.config/opencode/` (symlinked files from `dotfiles/.config/opencode/`) |
| Cursor | `~/.cursor/agents/`, `~/.cursor/rules/`, `~/.cursor/AGENTS.md` (symlinked from `dotfiles/.cursor/`) plus empty `commands/` and `skills/` placeholders |
| Claude | `~/.claude/CLAUDE.md` and Claude config files from `dotfiles/.claude/` |

AGENTS and CLAUDE files stay symlinked and are the primary focus of this repository alongside shared config files. Skills and commands should be installed or managed outside this repo.

### Cursor: user rules vs `AGENTS.md`

- **`AGENTS.md`** at the project root (and nested dirs) is picked up by Cursor automatically. After install, `~/.cursor/AGENTS.md` holds the canonical copy of working agreements from this repo.
- **User Rules** (Cursor Settings → Rules) apply across all projects but are not stored in this repository. To mirror the same agreements globally, paste the contents of `dotfiles/.cursor/AGENTS.md` into User Rules, or rely on project-level `AGENTS.md` / `.cursor/rules/` when a project includes them.

### Cursor models

Subagents use `composer-2` (Composer 2) and `composer-2-fast` (Composer 2 Fast) in YAML frontmatter. Confirm identifiers in **Cursor Settings → Models** or your local `~/.cursor/cli-config.json` if a future Cursor build renames them.
