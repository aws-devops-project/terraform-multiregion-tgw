#!/usr/bin/env bash
set -euo pipefail

# Git Bash helper: stage all, commit, push to origin/dev.

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository." >&2
  exit 1
}

# Ensure we're on dev (or can switch to it).
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "dev" ]]; then
  echo "Switching branch: $current_branch -> dev"
  git checkout dev
fi

git add .

# If there's nothing staged, don't fail the script.
if git diff --cached --quiet; then
  echo "Nothing to commit (index is clean)."
  exit 0
fi

git commit -m "remove action s3 and DynamoDB"
git push origin dev

