#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_action() { echo -e "${CYAN}[ACTION]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
HOME_CONFIG="${HOME}"
BACKUP_BASE="${HOME}/.dotfiles-backup"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

backup_needed=false

OBSOLETE_PATHS=(
    ".config/opencode/skills/grouped-tasks/SKILL.md"
    ".config/opencode/skills/executing-grouped-tasks/SKILL.md"
    ".config/opencode/agents/implementation-agent-fast.md"
    ".config/opencode/agents/implementation-agent-medium.md"
    ".config/opencode/agents/implementation-agent-spark.md"
    ".config/opencode/agents/implementation-agent-thinker.md"
    ".cursor/skills/grouped-tasks/SKILL.md"
    ".cursor/skills/executing-grouped-tasks/SKILL.md"
    ".cursor/agents/implementation-agent-fast.md"
    ".agents/skills/code-review"
    ".agents/skills/comprehensive-code-review"
    ".agents/skills/e2e-evidence"
    ".agents/skills/feedback-learning-review"
    ".agents/skills/learning-artifact-planner"
    ".agents/skills/openchamber-week-link"
    ".agents/skills/openspec-workflow"
    ".agents/skills/review-pr"
    ".agents/skills/solving-comprehensive-code-review"
    ".config/opencode/commands/code-review.md"
    ".config/opencode/commands/review-pr.md"
    ".config/opencode/agents/comprehensive-code-reviewer.md"
    ".cursor/skills/code-review"
    ".cursor/skills/review-pr"
    ".cursor/commands/code-review.md"
    ".cursor/commands/review-pr.md"
    ".agents/skills/devcontainer-down"
    ".agents/skills/devcontainer-rebuild"
    ".agents/skills/devcontainer-run"
    ".config/opencode/commands/devcontainer-update-dependencies.md"
    ".config/opencode/commands/external-bulk-fast-code-review.md"
    ".config/opencode/commands/external-comprehensive-code-review.md"
    ".config/opencode/commands/external-fast-code-review.md"
)

EMPTY_CONFIG_DIRS=(
    ".agents/skills"
    ".config/opencode/commands"
    ".cursor/commands"
    ".cursor/skills"
)

is_skill_or_command_path() {
    local relative_path="$1"
    [[ "$relative_path" == .agents/skills/* || "$relative_path" == .config/opencode/commands/* || "$relative_path" == .cursor/commands/* || "$relative_path" == .cursor/skills/* ]]
}

is_correct_symlink() {
    local source_path="$1"
    local target_path="$2"

    if [[ -L "$target_path" ]]; then
        local current_target
        current_target="$(readlink -f "$target_path")"
        local expected_target
        expected_target="$(readlink -f "$source_path")"
        [[ "$current_target" == "$expected_target" ]]
    else
        return 1
    fi
}

backup_path() {
    local target_path="$1"
    local relative_path="$2"
    local backup_path="${BACKUP_DIR}/${relative_path}"

    mkdir -p "$(dirname "$backup_path")"

    if [[ -L "$target_path" ]]; then
        local link_target
        link_target="$(readlink "$target_path")"
        echo "$link_target" > "${backup_path}.symlink"
        print_info "Backed up symlink: ${target_path} -> ${link_target}"
    elif [[ -d "$target_path" ]]; then
        cp -pR "$target_path" "$backup_path"
        print_info "Backed up directory: ${target_path}"
    elif [[ -f "$target_path" ]]; then
        cp -p "$target_path" "$backup_path"
        print_info "Backed up file: ${target_path}"
    fi
    backup_needed=true
}

remove_target() {
    local target_path="$1"

    if [[ -L "$target_path" ]]; then
        print_action "Removing existing symlink: ${target_path}"
        rm "$target_path"
    elif [[ -d "$target_path" ]]; then
        print_action "Removing existing directory: ${target_path}"
        rm -rf "$target_path"
    elif [[ -e "$target_path" ]]; then
        print_action "Removing existing file: ${target_path}"
        rm "$target_path"
    fi
}

cleanup_obsolete_paths() {
    local relative_path

    for relative_path in "${OBSOLETE_PATHS[@]}"; do
        local target_path="${HOME_CONFIG}/${relative_path}"

        if [[ ! -e "$target_path" && ! -L "$target_path" ]]; then
            continue
        fi

        backup_path "$target_path" "$relative_path"
        remove_target "$target_path"
        print_success "Removed obsolete path: ${target_path}"

        local parent_dir
        parent_dir="$(dirname "$target_path")"
        while [[ "$parent_dir" != "$HOME_CONFIG" ]]; do
            if ! rmdir "$parent_dir" 2>/dev/null; then
                break
            fi
            print_info "Removed empty directory: ${parent_dir}"
            parent_dir="$(dirname "$parent_dir")"
        done
    done
}

ensure_empty_config_dirs() {
    local relative_path

    for relative_path in "${EMPTY_CONFIG_DIRS[@]}"; do
        local target_path="${HOME_CONFIG}/${relative_path}"

        if [[ ! -d "$target_path" ]]; then
            print_action "Creating directory: ${target_path}"
            mkdir -p "$target_path"
        fi
    done
}

process_dotfile() {
    local relative_path="$1"
    local source_path="${DOTFILES_DIR}/${relative_path}"
    local target_path="${HOME_CONFIG}/${relative_path}"

    print_info "Processing: ${relative_path}"

    if [[ ! -e "$source_path" ]]; then
        print_error "Source file not found: ${source_path}"
        return 1
    fi

    if is_correct_symlink "$source_path" "$target_path"; then
        print_success "Already correctly linked: ${relative_path}"
        return 0
    fi

    local parent_dir
    parent_dir="$(dirname "$target_path")"
    if [[ ! -d "$parent_dir" ]]; then
        print_action "Creating directory: ${parent_dir}"
        mkdir -p "$parent_dir"
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        backup_path "$target_path" "$relative_path"
        remove_target "$target_path"
    fi

    ln -s "$source_path" "$target_path"
    print_success "Created symlink: ${target_path} -> ${source_path}"
}

main() {
    echo -e "${BOLD}${CYAN}"
    echo "============================================"
    echo "    Agents Settings Dotfiles Installer"
    echo "============================================"
    echo -e "${NC}"

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found: ${DOTFILES_DIR}"
        exit 1
    fi

    print_info "Script directory: ${SCRIPT_DIR}"
    print_info "Dotfiles source: ${DOTFILES_DIR}"
    print_info "Target config: ${HOME_CONFIG}"
    print_info "Backup location: ${BACKUP_DIR}"
    echo ""

    cleanup_obsolete_paths
    ensure_empty_config_dirs

    local errors=0
    local processed=0

    while IFS= read -r -d '' file; do
        relative_path="${file#${DOTFILES_DIR}/}"
        if is_skill_or_command_path "$relative_path"; then
            continue
        fi
        if process_dotfile "$relative_path"; then
            ((processed++)) || true
        else
            ((errors++)) || true
        fi
        echo ""
    done < <(find "$DOTFILES_DIR" -type f -print0)

    echo -e "${BOLD}${CYAN}"
    echo "============================================"
    echo "           Installation Summary"
    echo "============================================"
    echo -e "${NC}"
    print_info "Processed: ${processed} files"

    if [[ $errors -gt 0 ]]; then
        print_error "Errors: ${errors}"
        exit 1
    else
        print_success "All dotfiles installed successfully!"
    fi

    if [[ "$backup_needed" == false && -d "$BACKUP_DIR" ]]; then
        rmdir "$BACKUP_DIR" 2>/dev/null || true
        print_info "No backups needed"
    elif [[ -d "$BACKUP_DIR" ]]; then
        print_info "Backups saved to: ${BACKUP_DIR}"
    fi
}

main "$@"
