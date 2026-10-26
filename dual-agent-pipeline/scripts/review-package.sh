#!/usr/bin/env bash
# Write commit list, stat, and diff for reviewer (one file read).
# Usage:
#   review-package.sh BASE HEAD [OUTFILE]
#   review-package.sh BASE HEAD --working-tree [OUTFILE]
set -euo pipefail

usage() {
  echo "usage: review-package.sh BASE HEAD [OUTFILE]" >&2
  echo "       review-package.sh BASE HEAD --working-tree [OUTFILE]" >&2
  exit 2
}

[[ $# -ge 2 ]] || usage

base=$1
head=$2
working_tree=0
out=""

if [[ $# -ge 3 && "$3" == "--working-tree" ]]; then
  working_tree=1
  out=${4:-}
elif [[ $# -ge 3 && "$3" != "--working-tree" ]]; then
  out=$3
fi

git rev-parse --verify --quiet "$base" >/dev/null || { echo "bad BASE: $base" >&2; exit 2; }
git rev-parse --verify --quiet "$head" >/dev/null || { echo "bad HEAD: $head" >&2; exit 2; }

repo_root=$(git rev-parse --show-toplevel)
short_base=$(git rev-parse --short "$base")
short_head=$(git rev-parse --short "$head")

if [[ -z "$out" ]]; then
  dir="${TMPDIR:-/tmp}/dual-agent-review"
  mkdir -p "$dir"
  if [[ "$working_tree" -eq 1 ]]; then
    out="$dir/review-${short_base}..wt-${short_head}.diff"
  else
    out="$dir/review-${short_base}..${short_head}.diff"
  fi
fi

{
  echo "# Review package: ${base}..${head}"
  if [[ "$working_tree" -eq 1 ]]; then
    echo "# (includes working tree vs BASE)"
  fi
  echo
  echo "## Commits"
  if [[ "$working_tree" -eq 1 ]]; then
    git log --oneline "${base}..${head}" 2>/dev/null || true
    echo "(working tree changes may be uncommitted)"
  else
    git log --oneline "${base}..${head}"
  fi
  echo
  echo "## Files changed"
  if [[ "$working_tree" -eq 1 ]]; then
    {
      git diff --stat "${base}..${head}" 2>/dev/null || true
      git diff --stat "$base" 2>/dev/null || true
    } | awk 'NF' | sort -u
  else
    git diff --stat "${base}..${head}"
  fi
  echo
  echo "## Diff"
  if [[ "$working_tree" -eq 1 ]]; then
    git diff -U10 "${base}..${head}" 2>/dev/null || true
    echo
    echo "## Working tree diff (vs BASE)"
    git diff -U10 "$base" 2>/dev/null || true
    echo
    echo "## Untracked files (full content)"
    while IFS= read -r line; do
      [[ "$line" =~ ^\?\?[[:space:]]+(.*)$ ]] || continue
      f="${BASH_REMATCH[1]}"
      [[ -f "$repo_root/$f" ]] || continue
      echo
      echo "### $f"
      echo '```'
      cat "$repo_root/$f"
      echo '```'
    done < <(git -C "$repo_root" status --porcelain)
  else
    git diff -U10 "${base}..${head}"
  fi
} >"$out"

echo "$out"
