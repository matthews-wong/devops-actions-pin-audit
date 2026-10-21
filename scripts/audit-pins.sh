#!/usr/bin/env bash
# Fail when a workflow `uses:` reference is not pinned to an immutable ref.
set -euo pipefail

readonly DEFAULT_DIR=".github/workflows"
readonly SHA_PATTERN='^[^@]+@[0-9a-f]{40}$'
readonly DIGEST_PATTERN='^docker://[^@]+@sha256:[0-9a-f]{64}$'

dir="${1:-$DEFAULT_DIR}"

if [[ ! -d "$dir" ]]; then
  echo "audit-pins: directory not found: $dir" >&2
  exit 2
fi

shopt -s nullglob
files=("$dir"/*.yml "$dir"/*.yaml)

if ((${#files[@]} == 0)); then
  echo "audit-pins: no workflow files in $dir" >&2
  exit 2
fi

unpinned=0
for file in "${files[@]}"; do
  while IFS=: read -r line ref; do
    # Local actions live in the same repository and are reviewed with it.
    [[ "$ref" == ./* ]] && continue
    [[ "$ref" =~ $SHA_PATTERN || "$ref" =~ $DIGEST_PATTERN ]] && continue
    echo "$file:$line: $ref"
    unpinned=$((unpinned + 1))
  done < <(
    sed -nE 's/^[[:space:]-]*uses:[[:space:]]*["'\'']?([^"'\''[:space:]#]+).*/\1/;T;=;p' "$file" \
      | paste -d: - -
  )
done

if ((unpinned > 0)); then
  echo "audit-pins: $unpinned reference(s) not pinned to a full commit SHA" >&2
  exit 1
fi
echo "audit-pins: all references pinned (${#files[@]} file(s))"
