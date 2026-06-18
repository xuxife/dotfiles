# Dotfiles repo (`~/.config`)

This repo is cloned to `~/.config` and contains personal config files.

## Symlinks

Files in this repo that need to be symlinked into `$HOME` (or elsewhere) are
managed by `scripts/link.sh`. Run it after cloning:

```sh
~/.config/scripts/link.sh           # create/refresh links
~/.config/scripts/link.sh --dry-run # preview only
```

**When adding a new file to this repo that should be symlinked into place,
append an entry to the `LINKS` array in `scripts/link.sh`** (format:
`"<repo-relative-src>:<absolute-target>"`) and keep this note in sync if the
script's interface changes.
