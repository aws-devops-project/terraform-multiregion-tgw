#!/usr/bin/env bash
set -euo pipefail

# Git Bash helper: stage all, commit, push to origin/dev.
# Usage:
#   ./push-dev.sh "your commit message"
#   ./push-dev.sh            # auto-generate message from latest changes

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

git pull origin dev

git add .

# If there's nothing staged, don't fail the script.
if git diff --cached --quiet; then
  echo "Nothing to commit (index is clean)."
  exit 0
fi

if [[ $# -gt 0 && -n "${1:-}" ]]; then
  commit_message="$1"
else
  file_count="$(git diff --cached --name-only | wc -l | tr -d ' ')"
  preview_files="$(git diff --cached --name-only | head -n 3 | sed ':a;N;$!ba;s/\n/, /g')"
  timestamp="$(date '+%Y-%m-%d %H:%M')"
  commit_message="chore(dev): update ${file_count} files (${timestamp}) - ${preview_files}"
fi

echo "Commit message: $commit_message"
git commit -m "$commit_message"
git push origin dev
