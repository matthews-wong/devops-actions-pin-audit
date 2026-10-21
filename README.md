# devops-actions-pin-audit

A small shell check that fails when a GitHub Actions workflow references a
third-party action by a mutable tag or branch instead of a full commit SHA.

A tag such as `actions/checkout@v4` can be moved by whoever controls the
upstream repository. A 40-character commit SHA cannot, so pinning by SHA keeps
a compromised release from silently running in your pipeline.

## Usage

```sh
scripts/audit-pins.sh                 # audits .github/workflows
scripts/audit-pins.sh path/to/dir     # audits another directory
```

Exit status is `0` when every reference is pinned and `1` when at least one is
not. Each finding is printed as `file:line: reference`.

## What counts as pinned

| Reference                          | Result |
| ---------------------------------- | ------ |
| `owner/repo@<40 hex chars>`        | pass   |
| `owner/repo/path@<40 hex chars>`   | pass   |
| `./local/action`                   | pass, it lives in the same repository |
| `docker://image@sha256:<digest>`   | pass   |
| `owner/repo@v4`, `@main`, `@1.2`   | fail   |
| `docker://image:tag`               | fail   |

Keep the readable version in a trailing comment, for example
`uses: actions/checkout@<sha> # v4.2.2`.

## Permissions check

```sh
scripts/audit-permissions.sh [dir]
```

Fails for any workflow without a top-level `permissions:` block. Without one,
`GITHUB_TOKEN` inherits the repository default, which may include write
access. Declare `contents: read` at the top and widen per job only when needed.

## Validation

```sh
make validate   # shellcheck + actionlint, fixture tests, audit of this repo
```

Needs `shellcheck` and `actionlint` on `PATH`. The tests run both audits
against the fixtures in `test/fixtures` and check exit codes: `0` clean,
`1` findings, `2` bad input.

## Limits

The scan is line based. It reads `uses:` entries that sit on their own line
and does not parse YAML, so a reference built through an expression or a
multi-line flow mapping is not seen. Reusable workflow calls
(`uses: owner/repo/.github/workflows/x.yml@ref`) are checked like any action.
