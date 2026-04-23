#!/usr/bin/env bash

set -euo pipefail

trim() {
    local value="$1"
    value="${value#${value%%[![:space:]]*}}"
    value="${value%${value##*[![:space:]]}}"
    printf '%s' "$value"
}

main() {
    local title="${1:-Review report}"
    local critical=()
    local important=()
    local suggestion=()
    local strengths=()
    local line severity message

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -n "${line//[[:space:]]/}" ]] || continue

        severity="${line%%|*}"
        message="${line#*|}"
        severity="$(trim "$severity")"
        message="$(trim "$message")"
        severity="$(printf '%s' "$severity" | tr '[:upper:]' '[:lower:]')"

        case "$severity" in
            critical) critical+=("$message") ;;
            important) important+=("$message") ;;
            suggestion) suggestion+=("$message") ;;
            strengths) strengths+=("$message") ;;
            *) suggestion+=("$line") ;;
        esac
    done

    printf '# %s\n\n' "$title"

    printf '## critical\n'
    if [[ ${#critical[@]} -eq 0 ]]; then
        printf '%s\n' '- None'
    else
        local item
        for item in "${critical[@]}"; do
            printf '%s\n' "- $item"
        done
    fi

    printf '\n## important\n'
    if [[ ${#important[@]} -eq 0 ]]; then
        printf '%s\n' '- None'
    else
        local item
        for item in "${important[@]}"; do
            printf '%s\n' "- $item"
        done
    fi

    printf '\n## suggestion\n'
    if [[ ${#suggestion[@]} -eq 0 ]]; then
        printf '%s\n' '- None'
    else
        local item
        for item in "${suggestion[@]}"; do
            printf '%s\n' "- $item"
        done
    fi

    printf '\n## strengths\n'
    if [[ ${#strengths[@]} -eq 0 ]]; then
        printf '%s\n' '- None'
    else
        local item
        for item in "${strengths[@]}"; do
            printf '%s\n' "- $item"
        done
    fi
}

main "$@"
