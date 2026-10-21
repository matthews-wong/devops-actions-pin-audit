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
