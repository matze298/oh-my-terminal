#!/usr/bin/env bash
# Shared helpers: logging, platform/arch detection, PATH bootstrap, apt/go/uv.
# Sourced by setup.sh and the ghostty installer. Not meant to run standalone.

# Make freshly installed tools discoverable within this same run.
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.atuin/bin:$PATH"

# --- logging ------------------------------------------------------------------
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_BLUE=$'\033[34m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
else
  C_RESET=; C_BOLD=; C_DIM=; C_BLUE=; C_GREEN=; C_YELLOW=; C_RED=
fi

info()  { printf '%s==>%s %s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$*"; }
step()  { printf '  %s->%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()  { printf '%sWarning:%s %s\n' "$C_YELLOW$C_BOLD" "$C_RESET" "$*" >&2; }
err()   { printf '%sError:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$*" >&2; }
ok()    { printf '  %s[ok]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }

# --- platform / architecture --------------------------------------------------
detect_platform() {
  OS="$(uname -s)"
  IS_WSL=0
  case "$OS" in
    Linux)
      if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
        IS_WSL=1
      fi
      ;;
  esac

  # Architecture in the several naming schemes upstream projects use:
  #   DEB_ARCH    - dpkg / .deb assets      (amd64, arm64)
  #   REL_ARCH    - lazygit-style tarballs  (x86_64, arm64)
  #   RUST_TRIPLE - Rust tool release names (x86_64-unknown-linux-gnu, ...)
  #   BTOP_ARCH   - btop release names      (x86_64-linux-musl, ...)
  DEB_ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
  ARCH_M="$(uname -m)"          # x86_64 / aarch64 — as many projects name assets
  case "$(uname -m)" in
    x86_64)
      REL_ARCH=x86_64; RUST_TRIPLE=x86_64-unknown-linux-gnu; BTOP_ARCH=x86_64-linux-musl ;;
    aarch64|arm64)
      REL_ARCH=arm64;  RUST_TRIPLE=aarch64-unknown-linux-gnu; BTOP_ARCH=aarch64-linux-musl ;;
    *)
      REL_ARCH="$(uname -m)"; RUST_TRIPLE="$(uname -m)-unknown-linux-gnu"; BTOP_ARCH="$(uname -m)-linux-musl" ;;
  esac
}

# --- apt ----------------------------------------------------------------------
_APT_UPDATED=0
apt_update_once() {
  [ "$_APT_UPDATED" = 1 ] && return 0
  step "apt-get update"
  sudo apt-get update -qq
  _APT_UPDATED=1
}

apt_install() {
  apt_update_once
  sudo apt-get install -y -qq "$@"
}

# --- dependency toolchains ----------------------------------------------------
ensure_go() {
  command -v go >/dev/null 2>&1 && return 0
  info "Installing Go (required by a selected tool)"
  apt_install golang-go
}

ensure_uv() {
  command -v uv >/dev/null 2>&1 && return 0
  info "Installing uv (required by a selected tool)"
  install_special_uv
}

# --- misc ---------------------------------------------------------------------
# Nerd Font check needs a pipe, so it lives in a function (manifest checks
# must stay pipe-free to keep the parser simple).
check_nerdfont() {
  # Plain `grep -i` (no -q) so grep reads the whole stream; `grep -q` exits on
  # first match and SIGPIPEs fc-list, which trips `set -o pipefail`.
  fc-list 2>/dev/null | grep -i 'FiraCode Nerd' >/dev/null 2>&1
}
