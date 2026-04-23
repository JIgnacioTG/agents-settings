#!/usr/bin/env bash

set -euo pipefail

main() {
    local lines=()

    if [[ $# -gt 0 ]]; then
        lines=("$@")
    else
        while IFS= read -r line || [[ -n "$line" ]]; do
            lines+=("$line")
        done
    fi

    printf '%s\n' "${lines[@]}" | awk '
        function rank(line) {
            if (line ~ /(^|[^[:alpha:]])critical([^[:alpha:]]|$)/) return 0
            if (line ~ /(^|[^[:alpha:]])important([^[:alpha:]]|$)/) return 1
            if (line ~ /(^|[^[:alpha:]])suggestion([^[:alpha:]]|$)/) return 2
            if (line ~ /(^|[^[:alpha:]])strengths([^[:alpha:]]|$)/) return 3
            return 4
        }
        {
            printf "%d\t%d\t%s\n", rank($0), NR, $0
        }
    ' | sort -n -k1,1 -k2,2 | cut -f3-
}

main "$@"
