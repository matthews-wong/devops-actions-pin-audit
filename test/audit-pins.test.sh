#!/usr/bin/env bash
# Runs the audit against fixtures and checks exit codes and findings.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit="$root/scripts/audit-pins.sh"
failures=0

expect_status() {
  local name="$1" want="$2" dir="$3" got=0
  "$audit" "$dir" >/dev/null 2>&1 || got=$?
  if ((got != want)); then
    echo "FAIL $name: want exit $want, got $got"
    failures=$((failures + 1))
    return
  fi
  echo "ok   $name"
}

expect_status "pinned workflow passes" 0 "$root/test/fixtures/pinned"
expect_status "unpinned workflow fails" 1 "$root/test/fixtures/unpinned"
expect_status "empty directory is a usage error" 2 "$root/test/fixtures/empty"
expect_status "missing directory is a usage error" 2 "$root/test/fixtures/missing"

findings="$("$audit" "$root/test/fixtures/unpinned" 2>/dev/null || true)"
for ref in "actions/checkout@v4" "actions/setup-node@main" "docker://alpine:3.20"; do
  if [[ "$findings" != *"$ref"* ]]; then
    echo "FAIL finding for $ref missing"
    failures=$((failures + 1))
  fi
done

exit $((failures > 0))
