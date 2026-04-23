#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIFF_SCRIPT="$SCRIPT_DIR/local-diff.sh"
POST_COMMENTS_SCRIPT="$SCRIPT_DIR/post-comments.sh"
# shellcheck source=./file-filter.sh
source "$SCRIPT_DIR/file-filter.sh"

ACTION="detect"
PR_NUMBER="${PR_NUMBER:-}"
REPOSITORY="${GITHUB_REPOSITORY:-${GH_REPO:-${REPOSITORY:-}}}"
PR_URL="${PR_URL:-}"
ALLOW_POST=0
CONFIRM_LARGE_DIFF="${CONFIRM_LARGE_DIFF:-0}"

MODE="local"
PROVIDER="none"
REASON=""
PR_TITLE=""
PR_STATE=""
PR_IS_DRAFT=""
DIFF_FILE=""
DIFF_TEXT=""
THREADS_FILE=""
THREADS_JSON=""

usage() {
  cat <<'EOF'
Usage: github-integration.sh [--detect|--diff|--comments|--post] [--pr NUMBER] [--repo OWNER/REPO] [--url URL] [--approve-post] [--yes]

Modes:
  --detect        Detect PR context and print the active mode.
  --diff          Print PR diff when GitHub context is available, otherwise fall back to local-diff.sh.
  --comments      Print unresolved review threads when available.
  --post          Post stdin to the active PR only after explicit approval.

MCP fallback environment:
  PR_NUMBER / GITHUB_PR_NUMBER / REVIEW_PR_NUMBER / MCP_PR_NUMBER
  GITHUB_REPOSITORY / GH_REPO / REVIEW_REPO / MCP_REPO
  PR_URL / GITHUB_PR_URL / REVIEW_PR_URL / MCP_PR_URL
  PR_DIFF / GITHUB_PR_DIFF / REVIEW_PR_DIFF / MCP_PR_DIFF
  PR_THREADS_JSON / GITHUB_PR_THREADS_JSON / REVIEW_PR_THREADS_JSON / MCP_PR_THREADS_JSON

Posting is never automatic. Use --approve-post to confirm non-interactively.
Large diffs are never fetched automatically beyond 100 files. Use --yes or CONFIRM_LARGE_DIFF=1 to confirm non-interactively.
EOF
}

first_non_empty() {
  local value
  for value in "$@"; do
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return 0
    fi
  done
  return 1
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

parse_pr_url() {
  local url="$1"
  if [[ "$url" =~ github\.com/([^/]+/[^/]+)/pull/([0-9]+) ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    printf '%s\n' "${BASH_REMATCH[2]}"
  fi
}

parse_json_field() {
  local field="$1"
  JSON_FIELD="$field" python3 -c 'import json, os, sys
data = json.load(sys.stdin)
value = data.get(os.environ["JSON_FIELD"], "")
if isinstance(value, bool):
    print(str(value).lower())
elif value is None:
    print("")
else:
    print(value)'
}

parse_repo_json() {
  python3 -c 'import json, sys
data = json.load(sys.stdin)
owner = data.get("owner", {}).get("login", "")
name = data.get("name", "")
if owner and name:
    print(f"{owner}/{name}")'
}

filter_unresolved_threads() {
  if have_command jq; then
    jq '[.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false) | {threadId: .id, path: (.path // ""), line: .line, originalLine: .originalLine, diffSide: .diffSide, isOutdated: .isOutdated, comments: [.comments.nodes[]? | {databaseId, url, body, createdAt, author: (.author.login // "github-user")}]}]'
    return 0
  fi

  python3 -c 'import json, sys
data = json.load(sys.stdin)
threads = (
    data.get("data", {})
        .get("repository", {})
        .get("pullRequest", {})
        .get("reviewThreads", {})
        .get("nodes", [])
)
result = []
for thread in threads:
    if thread.get("isResolved"):
        continue
    comments = []
    for comment in thread.get("comments", {}).get("nodes", []):
        comments.append(
            {
                "databaseId": comment.get("databaseId"),
                "url": comment.get("url"),
                "body": comment.get("body", ""),
                "createdAt": comment.get("createdAt"),
                "author": (comment.get("author") or {}).get("login", "github-user"),
            }
        )
    result.append(
        {
            "threadId": thread.get("id"),
            "path": thread.get("path", ""),
            "line": thread.get("line"),
            "originalLine": thread.get("originalLine"),
            "diffSide": thread.get("diffSide"),
            "isOutdated": thread.get("isOutdated"),
            "comments": comments,
        }
    )
print(json.dumps(result, indent=2))'
}

gh_available() {
  have_command gh
}

gh_authenticated() {
  gh auth status >/dev/null 2>&1
}

resolve_repository_via_gh() {
  local repo_json
  repo_json="$(gh repo view --json owner,name 2>/dev/null)" || return 1
  if [[ -z "$repo_json" ]]; then
    return 1
  fi
  printf '%s' "$repo_json" | parse_repo_json
}

clear_mcp_file_payloads() {
  DIFF_FILE=""
  THREADS_FILE=""
}

load_mcp_context() {
  local parsed_line
  local parsed_index=0

  PR_NUMBER="$(first_non_empty "$PR_NUMBER" "${GITHUB_PR_NUMBER:-}" "${REVIEW_PR_NUMBER:-}" "${MCP_PR_NUMBER:-}" 2>/dev/null || true)"
  REPOSITORY="$(first_non_empty "$REPOSITORY" "${GITHUB_REPOSITORY:-}" "${GH_REPO:-}" "${REVIEW_REPO:-}" "${MCP_REPO:-}" 2>/dev/null || true)"
  PR_URL="$(first_non_empty "$PR_URL" "${GITHUB_PR_URL:-}" "${REVIEW_PR_URL:-}" "${MCP_PR_URL:-}" 2>/dev/null || true)"
  DIFF_FILE="$(first_non_empty "${PR_DIFF_FILE:-}" "${GITHUB_PR_DIFF_FILE:-}" "${REVIEW_PR_DIFF_FILE:-}" "${MCP_PR_DIFF_FILE:-}" 2>/dev/null || true)"
  DIFF_TEXT="$(first_non_empty "${PR_DIFF:-}" "${GITHUB_PR_DIFF:-}" "${REVIEW_PR_DIFF:-}" "${MCP_PR_DIFF:-}" 2>/dev/null || true)"
  THREADS_FILE="$(first_non_empty "${PR_THREADS_FILE:-}" "${GITHUB_PR_THREADS_FILE:-}" "${REVIEW_PR_THREADS_FILE:-}" "${MCP_PR_THREADS_FILE:-}" 2>/dev/null || true)"
  THREADS_JSON="$(first_non_empty "${PR_THREADS_JSON:-}" "${GITHUB_PR_THREADS_JSON:-}" "${REVIEW_PR_THREADS_JSON:-}" "${MCP_PR_THREADS_JSON:-}" 2>/dev/null || true)"

  if [[ -n "$PR_URL" ]] && { [[ -z "$PR_NUMBER" ]] || [[ -z "$REPOSITORY" ]]; }; then
    while IFS= read -r parsed_line; do
      if [[ $parsed_index -eq 0 && -z "$REPOSITORY" ]]; then
        REPOSITORY="$parsed_line"
      elif [[ $parsed_index -eq 1 && -z "$PR_NUMBER" ]]; then
        PR_NUMBER="$parsed_line"
      fi
      parsed_index=$((parsed_index + 1))
    done < <(parse_pr_url "$PR_URL")
  fi

  if [[ -n "$DIFF_FILE" || -n "$THREADS_FILE" ]]; then
    clear_mcp_file_payloads
  fi

  if [[ -n "$PR_NUMBER" || -n "$PR_URL" || -n "$REPOSITORY" ]]; then
    MODE="github"
    PROVIDER="mcp"
    REASON="mcp_pr_context_detected"
    return 0
  fi

  return 1
}

load_gh_context() {
  local pr_json

  if ! gh_available; then
    REASON="gh_unavailable"
    return 1
  fi

  if ! gh_authenticated; then
    REASON="gh_auth_unavailable"
    return 1
  fi

  if [[ -n "$PR_NUMBER" ]]; then
    if [[ -n "$REPOSITORY" ]]; then
      pr_json="$(gh pr view "$PR_NUMBER" --repo "$REPOSITORY" --json number,title,url,state,isDraft 2>/dev/null)" || {
        REASON="gh_pr_lookup_failed"
        return 1
      }
    else
      pr_json="$(gh pr view "$PR_NUMBER" --json number,title,url,state,isDraft 2>/dev/null)" || {
        REASON="gh_pr_lookup_failed"
        return 1
      }
    fi
  else
    if [[ -n "$REPOSITORY" ]]; then
      pr_json="$(gh pr view --repo "$REPOSITORY" --json number,title,url,state,isDraft 2>/dev/null)" || {
        REASON="no_pull_request_found_for_current_branch"
        return 1
      }
    else
      pr_json="$(gh pr view --json number,title,url,state,isDraft 2>/dev/null)" || {
        REASON="no_pull_request_found_for_current_branch"
        return 1
      }
    fi
  fi

  PR_NUMBER="$(printf '%s' "$pr_json" | parse_json_field number)"
  PR_TITLE="$(printf '%s' "$pr_json" | parse_json_field title)"
  PR_URL="$(printf '%s' "$pr_json" | parse_json_field url)"
  PR_STATE="$(printf '%s' "$pr_json" | parse_json_field state)"
  PR_IS_DRAFT="$(printf '%s' "$pr_json" | parse_json_field isDraft)"

  if [[ -z "$REPOSITORY" ]]; then
    REPOSITORY="$(resolve_repository_via_gh || true)"
  fi

  MODE="github"
  PROVIDER="gh"
  REASON="gh_pr_context_detected"
  return 0
}

detect_context() {
  MODE="local"
  PROVIDER="none"
  PR_TITLE=""
  PR_STATE=""
  PR_IS_DRAFT=""
  REASON="no_pull_request_found_for_current_branch"

  local original_pr_number="$PR_NUMBER"
  local original_repository="$REPOSITORY"
  local original_pr_url="$PR_URL"
  local original_diff_file="$DIFF_FILE"
  local original_diff_text="$DIFF_TEXT"
  local original_threads_file="$THREADS_FILE"
  local original_threads_json="$THREADS_JSON"

  if load_gh_context; then
    return 0
  fi

  PR_NUMBER="$original_pr_number"
  REPOSITORY="$original_repository"
  PR_URL="$original_pr_url"
  DIFF_FILE="$original_diff_file"
  DIFF_TEXT="$original_diff_text"
  THREADS_FILE="$original_threads_file"
  THREADS_JSON="$original_threads_json"

  if load_mcp_context; then
    return 0
  fi

  MODE="local"
  PROVIDER="none"
  return 1
}

print_context() {
  printf 'MODE=%s\n' "$MODE"
  printf 'PROVIDER=%s\n' "$PROVIDER"
  printf 'REASON=%s\n' "$REASON"
  printf 'PR_NUMBER=%s\n' "$PR_NUMBER"
  printf 'REPOSITORY=%s\n' "$REPOSITORY"
  printf 'PR_URL=%s\n' "$PR_URL"
  printf 'PR_TITLE=%s\n' "$PR_TITLE"
  printf 'PR_STATE=%s\n' "$PR_STATE"
  printf 'PR_IS_DRAFT=%s\n' "$PR_IS_DRAFT"
  printf 'POSTING=requires-explicit-approval\n'
}

fetch_diff_from_github() {
  if [[ -z "$PR_NUMBER" ]]; then
    echo "No PR number available for diff fetch." >&2
    return 1
  fi

  if [[ -n "$REPOSITORY" ]]; then
    gh pr diff "$PR_NUMBER" --repo "$REPOSITORY"
  else
    gh pr diff "$PR_NUMBER"
  fi
}

json_array_length() {
  local field="$1"

  if have_command jq; then
    jq --arg field "$field" '(.[$field] // []) | length'
    return 0
  fi

  JSON_FIELD="$field" python3 -c 'import json, os, sys
data = json.load(sys.stdin)
value = data.get(os.environ["JSON_FIELD"], [])
print(len(value if isinstance(value, list) else []))'
}

count_diff_files() {
  python3 -c 'import sys
count = 0
for line in sys.stdin:
    if line.startswith("diff --git "):
        count += 1
print(count)'
}

fetch_github_file_count() {
  local pr_json

  if [[ "$MODE" == "github" && "$PROVIDER" == "mcp" ]]; then
    if [[ -n "$DIFF_FILE" ]]; then
      count_diff_files < "$DIFF_FILE"
      return 0
    fi
    if [[ -n "$DIFF_TEXT" ]]; then
      printf '%s\n' "$DIFF_TEXT" | count_diff_files
      return 0
    fi
    return 1
  fi

  if [[ -z "$PR_NUMBER" ]]; then
    return 1
  fi

  if [[ -n "$REPOSITORY" ]]; then
    pr_json="$(gh pr view "$PR_NUMBER" --repo "$REPOSITORY" --json files 2>/dev/null)" || return 1
  else
    pr_json="$(gh pr view "$PR_NUMBER" --json files 2>/dev/null)" || return 1
  fi

  printf '%s' "$pr_json" | json_array_length files
}

confirm_large_diff() {
  local file_count="$1"

  if [[ -z "$file_count" ]] || ((file_count <= 100)); then
    return 0
  fi

  if [[ "$CONFIRM_LARGE_DIFF" == "1" ]]; then
    echo "Large diff confirmed. Continuing." >&2
    return 0
  fi

  if [[ -t 0 ]] && [[ -r /dev/tty ]]; then
    printf 'Review %d files? [y/N] ' "$file_count" > /dev/tty
    local reply
    read -r reply < /dev/tty
    case "$reply" in
      y|Y|yes|YES)
        return 0
        ;;
      *)
        echo "Aborted by confirmation gate." >&2
        return 1
        ;;
    esac
  fi

  echo "Large diff requires confirmation. Re-run with --yes or CONFIRM_LARGE_DIFF=1." >&2
  return 1
}

enforce_github_large_diff_gate() {
  local file_count
  file_count="$(fetch_github_file_count 2>/dev/null || true)"

  if [[ -z "$file_count" ]]; then
    return 0
  fi

  confirm_large_diff "$file_count"
}

fetch_unresolved_threads_from_github() {
  local owner name
  local raw_json

  if [[ -z "$PR_NUMBER" ]]; then
    echo "No PR number available for comment fetch." >&2
    return 1
  fi

  if [[ -n "$REPOSITORY" ]]; then
    owner="${REPOSITORY%%/*}"
    name="${REPOSITORY#*/}"
  else
    REPOSITORY="$(resolve_repository_via_gh)"
    owner="${REPOSITORY%%/*}"
    name="${REPOSITORY#*/}"
  fi

  raw_json="$(gh api graphql \
    -f query='query($owner:String!, $name:String!, $number:Int!) { repository(owner:$owner, name:$name) { pullRequest(number:$number) { reviewThreads(first:100) { nodes { id isResolved isOutdated path line originalLine diffSide comments(first:20) { nodes { databaseId url body createdAt author { login } } } } } } } }' \
    -f owner="$owner" \
    -f name="$name" \
    -F number="$PR_NUMBER")"

  printf '%s' "$raw_json" | filter_unresolved_threads
}

list_reviewable_worktree_files() {
  local file
  local pathspecs=()
  local pathspec

  while IFS= read -r pathspec; do
    pathspecs+=("$pathspec")
  done < <(generated_file_exclude_pathspecs)

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    if should_keep "$file"; then
      printf '%s\n' "$file"
    fi
  done < <(git diff --name-only HEAD -- . "${pathspecs[@]}")
}

working_tree_has_reviewable_changes() {
  local file

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    return 0
  done < <(list_reviewable_worktree_files)

  return 1
}

run_builtin_local_fallback() {
  local file
  local count=0
  local reviewable_files=()

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "Local diff fallback requires a git repository." >&2
    return 1
  fi

  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    reviewable_files+=("$file")
    count=$((count + 1))
  done < <(list_reviewable_worktree_files)

  printf 'Changed files (%s):\n' "$count"
  if ((count == 0)); then
    echo "No reviewable files after filtering generated output."
    return 0
  fi

  for file in "${reviewable_files[@]}"; do
    printf '%s\n' "$file"
  done

  git diff HEAD -- "${reviewable_files[@]}"
}

run_local_fallback() {
  local script_output

  if [[ -x "$LOCAL_DIFF_SCRIPT" ]]; then
    if script_output="$("$LOCAL_DIFF_SCRIPT" 2>&1)"; then
      printf '%s\n' "$script_output"
      if [[ "$script_output" == *"No reviewable files after filtering generated output."* ]] && working_tree_has_reviewable_changes; then
        echo "local-diff.sh only covered committed history. Falling back to built-in working tree diff mode." >&2
        run_builtin_local_fallback
        return $?
      fi
      return 0
    fi
    printf '%s\n' "$script_output" >&2
    echo "local-diff.sh failed. Falling back to built-in local diff mode." >&2
  fi

  run_builtin_local_fallback
}

confirm_posting() {
  if [[ "$ALLOW_POST" == "1" ]]; then
    return 0
  fi

  if [[ ! -t 1 ]] || [[ ! -r /dev/tty ]]; then
    echo "Posting blocked: explicit approval required. Re-run with --approve-post." >&2
    return 1
  fi

  printf 'Post review findings to PR #%s in %s? [y/N] ' "$PR_NUMBER" "${REPOSITORY:-current repository}" > /dev/tty
  local reply
  read -r reply < /dev/tty
  case "$reply" in
    y|Y|yes|YES)
      return 0
      ;;
    *)
      echo "Posting cancelled." >&2
      return 1
      ;;
  esac
}

post_review_body() {
  local body=""

  if [[ ! -t 0 ]]; then
    body="$(cat)"
  fi

  body="$(first_non_empty "$body" "${COMMENT_BODY:-}" 2>/dev/null || true)"

  if [[ -z "$body" ]]; then
    echo "No comment body provided on stdin or COMMENT_BODY." >&2
    return 1
  fi

  if [[ "$MODE" != "github" || -z "$PR_NUMBER" ]]; then
    echo "Posting is unavailable without an active GitHub PR context." >&2
    return 1
  fi

  confirm_posting

  if [[ -x "$POST_COMMENTS_SCRIPT" ]]; then
    if [[ -n "$REPOSITORY" ]]; then
      "$POST_COMMENTS_SCRIPT" --approve-post --pr "$PR_NUMBER" --repo "$REPOSITORY" <<<"$body"
    else
      "$POST_COMMENTS_SCRIPT" --approve-post --pr "$PR_NUMBER" <<<"$body"
    fi
    return 0
  fi

  if ! gh_available || ! gh_authenticated; then
    echo "Unable to post: gh CLI is unavailable or unauthenticated." >&2
    return 1
  fi

  if [[ -n "$REPOSITORY" ]]; then
    printf '%s' "$body" | gh pr comment "$PR_NUMBER" --repo "$REPOSITORY" --body-file -
  else
    printf '%s' "$body" | gh pr comment "$PR_NUMBER" --body-file -
  fi
}

main() {
  while (($#)); do
    case "$1" in
      --detect)
        ACTION="detect"
        shift
        ;;
      --diff)
        ACTION="diff"
        shift
        ;;
      --comments)
        ACTION="comments"
        shift
        ;;
      --post)
        ACTION="post"
        shift
        ;;
      --pr)
        [[ $# -ge 2 ]] || { usage; exit 1; }
        PR_NUMBER="$2"
        shift 2
        ;;
      --pr=*)
        PR_NUMBER="${1#*=}"
        shift
        ;;
      --repo)
        [[ $# -ge 2 ]] || { usage; exit 1; }
        REPOSITORY="$2"
        shift 2
        ;;
      --repo=*)
        REPOSITORY="${1#*=}"
        shift
        ;;
      --url)
        [[ $# -ge 2 ]] || { usage; exit 1; }
        PR_URL="$2"
        shift 2
        ;;
      --url=*)
        PR_URL="${1#*=}"
        shift
        ;;
      --approve-post)
        ALLOW_POST=1
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

  detect_context || true

  case "$ACTION" in
    detect)
      print_context
      ;;
    diff)
      if [[ "$MODE" == "github" && "$PROVIDER" == "mcp" ]]; then
        enforce_github_large_diff_gate
        if [[ -n "$DIFF_FILE" ]]; then
          cat "$DIFF_FILE"
          return 0
        fi
        if [[ -n "$DIFF_TEXT" ]]; then
          printf '%s\n' "$DIFF_TEXT"
          return 0
        fi
      fi

      if [[ "$MODE" == "github" ]] && gh_available && gh_authenticated; then
        enforce_github_large_diff_gate
        fetch_diff_from_github
      else
        echo "Falling back to local diff mode." >&2
        run_local_fallback
      fi
      ;;
    comments)
      if [[ "$MODE" == "github" && "$PROVIDER" == "mcp" ]]; then
        if [[ -n "$THREADS_FILE" ]]; then
          cat "$THREADS_FILE"
          return 0
        fi
        if [[ -n "$THREADS_JSON" ]]; then
          printf '%s\n' "$THREADS_JSON"
          return 0
        fi
      fi

      if [[ "$MODE" == "github" ]] && gh_available && gh_authenticated; then
        fetch_unresolved_threads_from_github
      else
        echo "No GitHub review threads available in local mode." >&2
        printf '[]\n'
      fi
      ;;
    post)
      post_review_body
      ;;
  esac
}

main "$@"
