# Personal Claude instructions

## Branch naming

When creating new branches (including worktree branches), use the pattern:

```
xuxife/yy/mm/dd/<feature>
```

Where `yy/mm/dd` is today's date (2-digit year/month/day) and `<feature>` is a short
kebab-case description of the change.

## GitHub accounts

I have two GitHub identities and two `gh` CLI accounts authenticated locally:

| Context | MS alias | GitHub login | gh account |
|---|---|---|---|
| Work (Microsoft corp) | `xingfeixu` | `xingfeixu_microsoft` | `xingfeixu_microsoft` |
| Personal | — | `xuxife` | `xuxife` |

Rules:

- **Pick the right account per repo.** Microsoft corporate repos (e.g.
  `azure-management-and-platforms/*`, `microsoft/*`, anything under an MS
  org) → use `xingfeixu_microsoft`. Personal repos under `xuxife/*` → use
  `xuxife`.
- Check which account is active before running `gh` ops:
  ```sh
  gh auth status
  ```
- Switch with:
  ```sh
  gh auth switch -u <account>
  ```
- When @-mentioning Microsoft folks in corp-repo issues/PRs, the convention
  is `@<alias>_microsoft` (not the bare alias). Verify the handle exists
  with `gh api users/<login>` first.