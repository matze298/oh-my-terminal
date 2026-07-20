#!/usr/bin/env bash
# Opt-in Ghostty installer + config. NOT run by ../setup.sh.
#
# Ghostty is the terminal emulator layer, which is machine-specific:
#   - Linux (GNOME/KDE/...) : installed here
#   - WSL                   : not applicable (use the Windows host terminal)
#   - macOS                 : `brew install --cask ghostty` (not automated here)
#
# Usage: ./ghostty/install-ghostty.sh [--dry-run] [--yes]

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export REPO_DIR
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"
# shellcheck source=../lib/dotfiles.sh
source "$REPO_DIR/lib/dotfiles.sh"

DRY_RUN=0; ASSUME_YES=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) err "unknown option: $a"; exit 2 ;;
  esac
done

detect_platform

install_config_only() {
  _install_config "$SCRIPT_DIR/config" "$HOME/.config/ghostty/config"
}

install_ghostty_deb() {
  # Community-maintained Ubuntu packages (mkasberg/ghostty-ubuntu), matched to
  # this release's codename + arch. Best-effort with a manual fallback.
  local codename json url tmp
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
  json="$(curl -fsSL https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest)" || json=""
  url="$(printf '%s\n' "$json" | grep -Po '"browser_download_url": *"\K[^"]*\.deb' \
        | grep "_${DEB_ARCH}_" | grep -- "$codename" | head -n1)"
  if [ -z "$url" ]; then
    warn "No prebuilt Ghostty .deb found for ${codename}/${DEB_ARCH}."
    echo "Install Ghostty manually, then re-run this script to place the config:" >&2
    echo "  https://ghostty.org/docs/install/binary" >&2
    return 1
  fi
  tmp="$(mktemp -d)"
  step "downloading $(basename "$url")"
  curl -fL "$url" -o "$tmp/ghostty.deb" || { rm -rf "$tmp"; return 1; }
  sudo apt-get install -y "$tmp/ghostty.deb"
  rm -rf "$tmp"
}

main() {
  if [ "$IS_WSL" = 1 ]; then
    err "WSL detected: Ghostty runs on the Windows host, not inside WSL."
    echo "Use Windows Terminal (or another Windows emulator) and point it at this WSL distro." >&2
    exit 1
  fi
  if [ "$OS" = Darwin ]; then
    info "On macOS install with: brew install --cask ghostty"
    [ "$DRY_RUN" = 1 ] && exit 0
    install_config_only
    exit 0
  fi

  if command -v ghostty >/dev/null 2>&1; then
    step "ghostty already installed"
  elif [ "$DRY_RUN" = 1 ]; then
    step "would install Ghostty (community .deb) and place the config"
    exit 0
  else
    info "Installing Ghostty"
    install_ghostty_deb || warn "continuing to install the config anyway"
  fi

  install_config_only
  info "Done. Reload Ghostty config with ctrl+shift+, (verify: ghostty +show-config)"
}

main
