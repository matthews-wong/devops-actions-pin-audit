#!/usr/bin/env bash
# Checks the permissions audit exit codes against the shared fixtures.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
audit="$root/scripts/audit-permissions.sh"
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

expect_status "workflow with permissions passes" 0 "$root/test/fixtures/pinned"
expect_status "workflow without permissions fails" 1 "$root/test/fixtures/unpinned"
expect_status "empty directory is a usage error" 2 "$root/test/fixtures/empty"
expect_status "missing directory is a usage error" 2 "$root/test/fixtures/missing"

exit $((failures > 0))
