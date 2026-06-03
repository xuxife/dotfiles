#!/usr/bin/env bash
# Create symlinks from $HOME into this dotfiles repo (~/.config).
#
# Usage: ./scripts/link.sh [--dry-run]
#
# When adding a new file/dir to the repo that should be symlinked from
# elsewhere on the system, append an entry to the LINKS array below AND
# document it in ../CLAUDE.md.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

# Format: "<source-relative-to-repo>:<target-absolute-path>"
LINKS=(
  ".gitconfig:$HOME/.gitconfig"
  "claude/CLAUDE.md:$HOME/.claude/CLAUDE.md"
  "claude/settings.json:$HOME/.claude/settings.json"
  "claude/hooks:$HOME/.claude/hooks"
  "claude/skills:$HOME/.claude/skills"
)

link_one() {
  local src="$REPO_DIR/$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    echo "skip (missing source): $src" >&2
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok:   $dst -> $src"
    return
  fi

  if ((DRY_RUN)); then
    echo "would link: $dst -> $src"
  else
    ln -sfn "$src" "$dst"
    echo "link: $dst -> $src"
  fi
}

for entry in "${LINKS[@]}"; do
  link_one "${entry%%:*}" "${entry#*:}"
done
