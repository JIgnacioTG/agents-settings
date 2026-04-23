#!/usr/bin/env bash

set -euo pipefail

generated_file_exclude_pathspecs() {
    printf '%s\n' \
        ':(exclude)**/node_modules/**' \
        ':(exclude)**/dist/**' \
        ':(exclude)**/build/**' \
        ':(exclude)**/assets/**' \
        ':(exclude)**/*.lock' \
        ':(exclude)**/package-lock.json' \
        ':(exclude)**/npm-shrinkwrap.json' \
        ':(exclude)**/yarn.lock' \
        ':(exclude)**/pnpm-lock.yaml' \
        ':(exclude)**/bun.lock' \
        ':(exclude)**/bun.lockb' \
        ':(exclude)**/Cargo.lock' \
        ':(exclude)**/composer.lock' \
        ':(exclude)**/Gemfile.lock' \
        ':(exclude)**/Pipfile.lock' \
        ':(exclude)**/poetry.lock' \
        ':(exclude)**/go.sum' \
        ':(exclude)**/*.min.js' \
        ':(exclude)**/*.min.css' \
        ':(exclude)**/*.map' \
        ':(exclude)**/*.png' \
        ':(exclude)**/*.jpg' \
        ':(exclude)**/*.jpeg' \
        ':(exclude)**/*.gif' \
        ':(exclude)**/*.webp' \
        ':(exclude)**/*.ico' \
        ':(exclude)**/*.pdf'
}

should_keep() {
    local path="$1"

    case "$path" in
        */node_modules/*|node_modules/*)
            return 1
            ;;
        */dist/*|dist/*)
            return 1
            ;;
        */build/*|build/*)
            return 1
            ;;
        */assets/*|assets/*)
            return 1
            ;;
    esac

    case "$(basename "$path")" in
        package-lock.json|npm-shrinkwrap.json|pnpm-lock.yaml|yarn.lock|bun.lock|bun.lockb|Cargo.lock|Gemfile.lock|Pipfile.lock|poetry.lock|go.sum|composer.lock)
            return 1
            ;;
        *.min.js|*.min.css|*.map|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.pdf)
            return 1
            ;;
    esac

    return 0
}

main() {
    local paths=()

    if [[ $# -gt 0 ]]; then
        paths=("$@")
    else
        while IFS= read -r path || [[ -n "$path" ]]; do
            paths+=("$path")
        done
    fi

    local path
    for path in "${paths[@]}"; do
        [[ -n "$path" ]] || continue
        if should_keep "$path"; then
            printf '%s\n' "$path"
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
