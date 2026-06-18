#!/usr/bin/env bash
# setup-devbox.sh — one-shot, idempotent setup for a fresh devbox (CDE / Azure VM).
#
# Run it directly on the target box:
#     bash ~/.config/scripts/setup-devbox.sh
#
# Each phase detects "already done" and is safe to re-run.
#
# Strategy: apt installs only the minimal prerequisites Homebrew needs on Linux;
# Homebrew then manages every other tool (single source of truth, easy updates).
# The Tailscale installer auto-detects apt (Ubuntu) vs tdnf (Azure Linux).
set -euo pipefail

# --- config (override via env) ------------------------------------------------
TS_HOSTNAME="${TS_HOSTNAME:-$(hostname -s)}"   # tailnet machine name
GH_USER="${GH_USER:-xuxife}"                   # GitHub user whose public keys to trust
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
BREW_BIN="$BREW_PREFIX/bin/brew"

# --- logging ------------------------------------------------------------------
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }

# =============================================================================
# Phase: Tailscale
# =============================================================================
phase_tailscale() {
  log "Tailscale: checking installation"
  if ! command -v tailscale >/dev/null 2>&1; then
    log "Tailscale: installing via official script"
    curl -fsSL https://tailscale.com/install.sh | sh
    ok "Tailscale installed"
  else
    ok "Tailscale already installed ($(tailscale version | head -1))"
  fi

  # Ensure the daemon is up (systemd boxes only).
  if command -v systemctl >/dev/null 2>&1 && pidof systemd >/dev/null 2>&1; then
    sudo systemctl enable --now tailscaled
  fi

  # Already logged in? Then we're done.
  if tailscale status >/dev/null 2>&1; then
    ok "Tailscale already up: $(tailscale status --json 2>/dev/null | jq -r '.Self.DNSName // empty' 2>/dev/null || echo connected)"
    return 0
  fi

  log "Tailscale: bringing up interface (interactive login)"
  warn "A browser login URL will be printed below — open it to authenticate this machine."
  sudo tailscale up --ssh --accept-routes --hostname="$TS_HOSTNAME"
  ok "Tailscale up as '$TS_HOSTNAME'"
}

# =============================================================================
# Phase: SSH authorized_keys — trust the user's published GitHub keys
# =============================================================================
phase_sshkeys() {
  local ak="$HOME/.ssh/authorized_keys"
  mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
  touch "$ak"; chmod 600 "$ak"
  log "SSH: fetching public keys from github.com/$GH_USER.keys"
  local keys
  keys="$(curl -fsSL "https://github.com/$GH_USER.keys")" || { warn "could not fetch keys"; return 0; }
  [ -z "$keys" ] && { warn "no keys published at github.com/$GH_USER.keys"; return 0; }
  local added=0
  while IFS= read -r k; do
    [ -z "$k" ] && continue
    if ! grep -qF "$k" "$ak"; then
      echo "$k # github:$GH_USER" >> "$ak"
      added=$((added + 1))
    fi
  done <<< "$keys"
  ok "SSH: $added new key(s) added to authorized_keys"
}

# =============================================================================
# Phase: apt — minimal prerequisites for Homebrew on Linux only
# (https://docs.brew.sh/Homebrew-on-Linux#requirements)
# =============================================================================
phase_apt() {
  command -v apt-get >/dev/null 2>&1 || { ok "apt not present (non-Debian distro) — skipping"; return 0; }
  local pkgs=(build-essential procps curl file git)
  log "apt: installing Homebrew prerequisites: ${pkgs[*]}"
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}"
  ok "apt prerequisites installed"
}

# =============================================================================
# Phase: Homebrew — install brew, persist shellenv, then brew bundle
# =============================================================================
phase_brew() {
  if [ ! -x "$BREW_BIN" ]; then
    log "Homebrew: installing"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Homebrew installed"
  else
    ok "Homebrew already installed at $BREW_PREFIX"
  fi

  eval "$("$BREW_BIN" shellenv)"

  # Persist shellenv for bash and fish (idempotent: append only once).
  for rc in "$HOME/.bashrc" "$HOME/.profile"; do
    [ -e "$rc" ] || touch "$rc"
    if ! grep -q "brew shellenv" "$rc" 2>/dev/null; then
      printf '\n# Homebrew\neval "$(%s shellenv)"\n' "$BREW_BIN" >> "$rc"
      ok "appended brew shellenv to $rc"
    fi
  done
  local fishrc="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$fishrc")"; [ -e "$fishrc" ] || touch "$fishrc"
  if ! grep -q "brew shellenv" "$fishrc" 2>/dev/null; then
    printf '\n# Homebrew\n%s shellenv fish | source\n' "$BREW_BIN" >> "$fishrc"
    ok "appended brew shellenv to $fishrc"
  fi

  log "Homebrew: running brew bundle"
  local brewfile
  brewfile="$(mktemp)"
  cat > "$brewfile" <<'BREWFILE'
# CLI essentials
brew "fish"
brew "powershell"
brew "tmux"
brew "mosh"
brew "starship"
brew "autojump"
brew "fzf"
brew "eza"
brew "bat"
brew "fd"
brew "ripgrep"
brew "yq"
brew "jq"
brew "httpie"
brew "neovim"
brew "glow"
brew "htop"
brew "unzip"
brew "stow"

# Git & dev
brew "gh"
brew "git-extras"
brew "git-filter-repo"
brew "lazygit"
brew "delve"

# K8s / cloud
brew "k9s"
brew "argo"
brew "argocd"
brew "crane"
brew "caddy"
brew "helm"

# Languages / runtimes
brew "mise"
brew "uv"
brew "pipx"
brew "go"
brew "node"
brew "bazelisk"
brew "gofumpt"
brew "goimports"

# AI / coding
brew "opencode"

# Misc
brew "prettier"
brew "markdown-toc"
brew "markdownlint-cli2"
brew "code-server"
BREWFILE
  brew bundle --file="$brewfile"
  rm -f "$brewfile"
  ok "brew bundle complete"
}

# =============================================================================
# main
# =============================================================================
main() {
  log "devbox setup starting (user=$USER host=$(hostname -s))"
  phase_tailscale
  phase_sshkeys
  phase_apt
  phase_brew
  ok "devbox setup complete"
}

main "$@"
