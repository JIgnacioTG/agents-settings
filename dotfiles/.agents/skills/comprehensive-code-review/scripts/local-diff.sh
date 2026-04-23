#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./file-filter.sh
source "$SCRIPT_DIR/file-filter.sh"

BASE_SHA="${BASE_SHA:-origin/main}"
HEAD_SHA="${HEAD_SHA:-HEAD}"
CONFIRM_LARGE_DIFF="${CONFIRM_LARGE_DIFF:-0}"

usage() {
  cat <<'EOF'
Usage: local-diff.sh [--base SHA] [--head SHA] [--yes]

Reads changed files with git diff --name-only and diff content with git diff.
EOF
}

while (($#)); do
  case "$1" in
    --base)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      BASE_SHA="$2"
      shift 2
      ;;
    --base=*)
      BASE_SHA="${1#*=}"
      shift
      ;;
    --head)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      HEAD_SHA="$2"
      shift 2
      ;;
    --head=*)
      HEAD_SHA="${1#*=}"
      shift
      ;;
    --yes|-y)
      CONFIRM_LARGE_DIFF=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "local-diff.sh must run inside a git repository." >&2
  exit 1
fi

reviewable_files=()

git_diff_name_only_filtered() {
  local pathspecs=()
  local pathspec

  while IFS= read -r pathspec; do
    pathspecs+=("$pathspec")
  done < <(generated_file_exclude_pathspecs)

  git diff --name-only "$BASE_SHA" "$HEAD_SHA" -- . "${pathspecs[@]}"
}

while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  if should_keep "$file"; then
    reviewable_files+=("$file")
  fi
done < <(git_diff_name_only_filtered)

echo "Changed files (${#reviewable_files[@]}):"
if ((${#reviewable_files[@]} == 0)); then
  echo "No reviewable files after filtering generated output."
  exit 0
fi

if ((${#reviewable_files[@]} > 0)); then
  for file in "${reviewable_files[@]}"; do
    printf '%s\n' "$file"
  done
fi

if ((${#reviewable_files[@]} > 100)); then
  if [[ "$CONFIRM_LARGE_DIFF" == 1 ]]; then
    echo "Large diff confirmed. Continuing."
  elif [[ -t 0 ]]; then
    printf 'Review %d files? [y/N] ' "${#reviewable_files[@]}"
    read -r reply
    case "$reply" in
      y|Y|yes|YES)
        ;;
      *)
        echo "Aborted by confirmation gate." >&2
        exit 1
        ;;
    esac
  else
    echo "Large diff requires confirmation. Re-run with --yes or CONFIRM_LARGE_DIFF=1." >&2
    exit 1
  fi
fi

git diff "$BASE_SHA" "$HEAD_SHA" -- "${reviewable_files[@]}"
