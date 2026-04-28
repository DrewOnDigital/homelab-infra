#!/bin/bash

set -euo pipefail
# git_auto_push.sh
# Usage: Run from the root of your homelab-infra repo directory.
# Stages all changes, commits with a timestamped message, and pushes to origin/master.

# Safety check — make sure we're inside a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "ERROR: Not inside a git repository. Navigate to your repo directory first."
  exit 1
fi

# Set remote to HTTPS (safe to run repeatedly)
git remote set-url origin https://github.com/DrewOnDigital/homelab-infra.git

echo ""
echo "========================================"
echo " Current repo status:"
echo "========================================"
git status
echo ""

# Show what's changed before committing
CHANGED=$(git diff --name-only; git ls-files --others --exclude-standard)

if [ -z "$CHANGED" ] && git diff --cached --quiet; then
  echo "Nothing to commit. Working tree is clean."
  exit 0
fi

echo "Files to be committed:"
echo "$CHANGED"
echo ""
echo "Script will continue in 3 seconds... Press Ctrl+C to abort."
sleep 3
echo ""

# Stage all changes
git add .
echo "Changes staged."
echo ""

# Single commit with timestamp and changed files
TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
FILES=$(git diff --cached --name-only | tr '\n' ' ')
git commit -m "chore: auto-commit ${TIMESTAMP} | changed: ${FILES}"

echo ""
echo "Committed. Pushing to origin/master..."
echo ""

# Push
git push -u origin master

echo ""
echo "========================================"
echo " Done. Changes pushed to GitHub."
echo "========================================"
echo ""
