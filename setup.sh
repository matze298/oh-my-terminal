#!/usr/bin/env bash
# oh-my-terminal — reproduce a portable zsh + CLI toolkit on a fresh machine.
#
# Usage: ./setup.sh [--dry-run] [--all|--core] [--yes] [-h|--help]
#   --dry-run  show what would be installed/changed, touch nothing
#   --all      select every not-yet-installed tool (non-interactive)
#   --core     select only the recommended core tier (non-interactive)
#   --yes      skip confirmation and identity prompts (use detected defaults)
#
# Ghostty (the terminal emulator) is NOT installed here; see ghostty/.

set -o pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
MANIFEST="$REPO_DIR/lib/tools.manifest"

# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"
# shellcheck source=lib/install.sh
source "$REPO_DIR/lib/install.sh"
# shellcheck source=lib/ui.sh
source "$REPO_DIR/lib/ui.sh"
# shellcheck source=lib/dotfiles.sh
source "$REPO_DIR/lib/dotfiles.sh"

DRY_RUN=0; ASSUME_YES=0; SELECT_MODE=interactive

usage() { sed -n '2,12p' "$REPO_DIR/setup.sh" | sed 's/^# \{0,1\}//'; }

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --all)     SELECT_MODE=all ;;
      --core)    SELECT_MODE=core ;;
      --yes|-y)  ASSUME_YES=1 ;;
      -h|--help) usage; exit 0 ;;
      *) err "unknown option: $1"; usage; exit 2 ;;
    esac
    shift
  done
}

parse_manifest() {
  IDS=(); CATS=(); CHECKS=(); METHODS=(); ARGS=(); DEFAULTS=(); DESCS=()
  local id cat check method arg def desc
  while IFS='|' read -r id cat check method arg def desc; do
    [ -z "$id" ] && continue
    case "$id" in \#*) continue ;; esac
    IDS+=("$id"); CATS+=("$cat"); CHECKS+=("$check"); METHODS+=("$method")
    ARGS+=("$arg"); DEFAULTS+=("$def"); DESCS+=("$desc")
  done < "$MANIFEST"
}

compute_installed() {
  INSTALLED=()
  local i
  for i in "${!IDS[@]}"; do
    if eval "${CHECKS[$i]}" >/dev/null 2>&1; then INSTALLED[$i]=1; else INSTALLED[$i]=0; fi
  done
}

preflight() {
  detect_platform
  if [ "$OS" = Darwin ]; then
    err "macOS is not yet supported. The install methods here assume Debian/Ubuntu (apt)."
    echo "Extension point: add a Homebrew branch to lib/install.sh and OS-aware methods to the manifest." >&2
    exit 1
  fi
  if ! command -v apt-get >/dev/null 2>&1; then
    err "This installer targets Debian/Ubuntu (apt-get not found)."
    exit 1
  fi
  [ "$IS_WSL" = 1 ] && info "WSL detected: the CLI toolkit installs normally; skip the Ghostty module (use the Windows host terminal)."
}

apply_selection() {
  case "$SELECT_MODE" in
    all)  _ui_set_all_from_defaults all ;;
    core) _ui_set_all_from_defaults core ;;
    interactive)
      if [ -t 0 ]; then
        ui_select_tools || { warn "aborted by user"; exit 130; }
      else
        warn "no TTY for the interactive checklist; falling back to --core"
        _ui_set_all_from_defaults core
      fi
      ;;
  esac
}

# Non-interactive selection used by --all/--core and the no-TTY fallback.
_ui_set_all_from_defaults() {  # all|core
  local mode=$1 i
  SELECTED=()
  for i in "${!IDS[@]}"; do
    if [ "${INSTALLED[$i]}" = 1 ]; then SELECTED[$i]=0
    elif [ "$mode" = all ]; then SELECTED[$i]=1
    elif [ "${DEFAULTS[$i]}" = core ]; then SELECTED[$i]=1
    else SELECTED[$i]=0; fi
  done
}

show_plan() {
  local i any=0 needs_go=0 needs_uv=0
  info "Plan"
  for i in "${!IDS[@]}"; do
    [ "${SELECTED[$i]}" = 1 ] || continue
    any=1
    printf '  %sinstall%s %-14s %s(%s)%s\n' "$C_GREEN" "$C_RESET" "${IDS[$i]}" "$C_DIM" "${METHODS[$i]}" "$C_RESET"
    [ "${METHODS[$i]}" = go ] && needs_go=1
    [ "${METHODS[$i]}" = uv ] && needs_uv=1
  done
  [ "$any" = 0 ] && step "no new tools selected (configs will still be applied)"
  [ "$needs_go" = 1 ] && ! command -v go  >/dev/null 2>&1 && step "will also install: go (dependency)"
  [ "$needs_uv" = 1 ] && ! command -v uv  >/dev/null 2>&1 && step "will also install: uv (dependency)"
  echo
  step "configs: ~/.zshrc, ~/.gitconfig (+ ~/.gitconfig.local identity), optional ~/.zshrc.local"
}

confirm() {
  [ "$ASSUME_YES" = 1 ] && return 0
  [ -t 0 ] || return 0
  printf '\nProceed? [y/N] '
  local ans; read -r ans
  case "$ans" in y|Y) return 0 ;; *) warn "aborted"; exit 1 ;; esac
}

install_selected() {
  local i ok_list=() fail_list=()
  for i in "${!IDS[@]}"; do
    [ "${SELECTED[$i]}" = 1 ] || continue
    info "Installing ${IDS[$i]}"
    if install_tool "${IDS[$i]}" "${METHODS[$i]}" "${ARGS[$i]}"; then
      ok_list+=("${IDS[$i]}")
    else
      err "failed: ${IDS[$i]}"; fail_list+=("${IDS[$i]}")
    fi
  done
  INSTALLED_OK=("${ok_list[@]}")
  INSTALLED_FAIL=("${fail_list[@]}")
}

post_steps() {
  # Default shell.
  if command -v zsh >/dev/null 2>&1 && [ "$(basename "${SHELL:-}")" != zsh ]; then
    if [ "$DRY_RUN" = 1 ]; then
      step "would offer to set zsh as your default shell (chsh)"
    elif [ "$ASSUME_YES" = 1 ]; then
      step "set zsh as default later with: chsh -s \"\$(command -v zsh)\""
    elif [ -t 0 ]; then
      printf '\nSet zsh as your default login shell now (needs your password)? [y/N] '
      local ans; read -r ans
      case "$ans" in y|Y) chsh -s "$(command -v zsh)" && ok "default shell set to zsh (takes effect on next login)" ;; esac
    fi
  fi
  # gh auth hint.
  if command -v gh >/dev/null 2>&1 && ! gh auth status --hostname github.com >/dev/null 2>&1; then
    step "authenticate GitHub: gh auth login --hostname github.com  &&  gh auth setup-git"
  fi
}

summary() {
  echo
  info "Done"
  [ "${#INSTALLED_OK[@]}"   -gt 0 ] && step "installed: ${INSTALLED_OK[*]}"
  [ "${#INSTALLED_FAIL[@]}" -gt 0 ] && warn "failed:    ${INSTALLED_FAIL[*]}"
  step "restart your terminal (or run: exec zsh) to pick up the new shell config"
  step "optional terminal emulator: ./ghostty/install-ghostty.sh"
}

main() {
  parse_args "$@"
  preflight
  parse_manifest
  compute_installed
  apply_selection
  show_plan
  if [ "$DRY_RUN" = 1 ]; then
    echo; info "Dry run — nothing was installed or changed."
    return 0
  fi
  confirm
  INSTALLED_OK=(); INSTALLED_FAIL=()
  install_selected
  dotfiles_install
  post_steps
  summary
}

main "$@"
