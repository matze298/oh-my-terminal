#!/usr/bin/env bash
# Install the (portable) shell/git configs and split personal identity into
# untracked local overlays. Honors DRY_RUN and ASSUME_YES set by setup.sh.

_install_config() {  # src dest
  local src=$1 dest=$2
  if [ "$DRY_RUN" = 1 ]; then
    step "would install $(basename "$src") -> $dest (backing up any existing)"
    return
  fi
  if [ -e "$dest" ]; then
    local bak="$dest.bak.$(date +%Y%m%d-%H%M%S)"
    cp -a "$dest" "$bak"
    step "backed up existing $dest -> $bak"
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  ok "installed $dest"
}

_write_git_identity() {  # default-name default-email
  local def_name=$1 def_email=$2 name email
  if [ "$DRY_RUN" = 1 ]; then
    step "would write ~/.gitconfig.local (user.name / user.email)"
    return
  fi
  # Prefer an existing local overlay if one is already there.
  [ -f "$HOME/.gitconfig.local" ] && {
    def_name="$(git config --file "$HOME/.gitconfig.local" user.name 2>/dev/null || echo "$def_name")"
    def_email="$(git config --file "$HOME/.gitconfig.local" user.email 2>/dev/null || echo "$def_email")"
  }
  if [ "$ASSUME_YES" = 1 ]; then
    name="$def_name"; email="$def_email"
  else
    read -r -p "Git user.name  [$def_name]: " name;  name="${name:-$def_name}"
    read -r -p "Git user.email [$def_email]: " email; email="${email:-$def_email}"
  fi
  cat > "$HOME/.gitconfig.local" <<EOF
[user]
    name = $name
    email = $email
EOF
  ok "wrote ~/.gitconfig.local"
  { [ -z "$name" ] || [ -z "$email" ]; } && warn "git identity is incomplete; edit ~/.gitconfig.local"
}

_offer_zshrc_local() {  # template-path
  local tmpl=$1 ans
  if [ -f "$HOME/.zshrc.local" ]; then
    step "~/.zshrc.local already exists, leaving it untouched"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    step "would offer to create ~/.zshrc.local from the template"
    return
  fi
  [ "$ASSUME_YES" = 1 ] && return
  printf '\nCreate ~/.zshrc.local for org/machine-specific overrides (e.g. GH_HOST)? [y/N] '
  read -r ans
  case "$ans" in
    y|Y) cp "$tmpl" "$HOME/.zshrc.local"; ok "created ~/.zshrc.local (edit it to taste)" ;;
    *)   step "skipped ~/.zshrc.local" ;;
  esac
}

dotfiles_install() {
  local df="$REPO_DIR/dotfiles" def_name def_email
  def_name="$(git config user.name 2>/dev/null)"
  def_email="$(git config user.email 2>/dev/null)"

  info "Configuring dotfiles"
  _install_config "$df/zshrc"     "$HOME/.zshrc"
  _install_config "$df/gitconfig" "$HOME/.gitconfig"
  _write_git_identity "$def_name" "$def_email"
  _offer_zshrc_local "$df/zshrc.local.template"
}
