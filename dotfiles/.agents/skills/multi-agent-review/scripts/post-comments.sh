#!/usr/bin/env bash

set -euo pipefail

main() {
    local pr_number="${PR_NUMBER:-}"
    local repo="${GITHUB_REPOSITORY:-${GH_REPO:-}}"
    local approved=0
    local body

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --approve-post)
                approved=1
                ;; 
            --pr)
                [[ $# -ge 2 ]] || return 1
                pr_number="$2"
                shift
                ;;
            --repo)
                [[ $# -ge 2 ]] || return 1
                repo="$2"
                shift
                ;;
            *)
                if [[ -z "$pr_number" ]]; then
                    pr_number="$1"
                elif [[ -z "$repo" ]]; then
                    repo="$1"
                fi
                ;;
        esac
        shift
    done

    body="$(cat)"

    if [[ -z "$pr_number" ]]; then
        printf '%s\n' 'No PR number available for comment posting.' >&2
        return 1
    fi

    case "$approved" in
        1|true|TRUE|yes|YES)
            ;;
        *)
            printf '%s\n' 'Posting blocked: explicit approval required. Use --approve-post.' >&2
            return 1
            ;;
    esac

    if [[ -n "$repo" ]]; then
        gh pr comment "$pr_number" --repo "$repo" --body-file - <<<"$body"
    else
        gh pr comment "$pr_number" --body-file - <<<"$body"
    fi
}

main "$@"
