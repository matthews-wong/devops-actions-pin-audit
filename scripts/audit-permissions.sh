#!/usr/bin/env bash
# Fail when a workflow has no top-level `permissions:` block, which leaves
# GITHUB_TOKEN with the repository's (often write-all) default scopes.
set -euo pipefail

readonly DEFAULT_DIR=".github/workflows"

dir="${1:-$DEFAULT_DIR}"

if [[ ! -d "$dir" ]]; then
  echo "audit-permissions: directory not found: $dir" >&2
  exit 2
fi

shopt -s nullglob
files=("$dir"/*.yml "$dir"/*.yaml)

if ((${#files[@]} == 0)); then
  echo "audit-permissions: no workflow files in $dir" >&2
  exit 2
fi

missing=0
for file in "${files[@]}"; do
  if ! grep -qE '^permissions:' "$file"; then
    echo "$file: no top-level permissions block"
    missing=$((missing + 1))
  fi
done

if ((missing > 0)); then
  echo "audit-permissions: $missing workflow(s) rely on default token scopes" >&2
  exit 1
fi
echo "audit-permissions: all workflows declare permissions (${#files[@]} file(s))"
