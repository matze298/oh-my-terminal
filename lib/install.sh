#!/usr/bin/env bash
# Install methods. install_tool() dispatches on a manifest 'method'; bespoke
# installers are install_special_<arg>. Relies on helpers from common.sh.
#
# Policy: prefer the latest stable release. apt is used only where it already
# ships current stable (ripgrep, jq, kubectx) or a from-source build would be
# heavy for little gain (zsh, git, tmux, go). Everything else pulls upstream.

install_tool() {
  local id=$1 method=$2 arg=$3
  case "$method" in
    apt)     apt_install "$arg" ;;
    uv)      ensure_uv; uv tool install $arg ;;   # arg may carry --with flags
    go)      ensure_go; go install "$arg" ;;
    special) "install_special_${arg}" ;;
    *)       err "unknown install method '$method' for '$id'"; return 1 ;;
  esac
}

# --- shared release helpers ---------------------------------------------------
gh_latest_tag() {  # repo -> latest release tag (e.g. v9.0.0 or 0.18.2)
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -Po '"tag_name": *"\K[^"]*'
}

# repo, extended-regex -> first matching asset download URL of the latest release.
# Robust to version strings embedded in asset names.
gh_asset_url() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
    | grep -Po '"browser_download_url": *"\K[^"]*' | grep -E "$2" | head -n1
}

# Install a single raw (uncompressed) release binary. Usage: _dl_rawbin <url> <dest>
_dl_rawbin() {
  local url=$1 dest=$2
  mkdir -p "$HOME/.local/bin"
  curl -fL "$url" -o "$HOME/.local/bin/$dest" || { err "download failed: $url"; return 1; }
  chmod 755 "$HOME/.local/bin/$dest"
}

# Download an archive, find a binary by name inside it, install to ~/.local/bin.
# Handles .tar.gz / .tbz / .zip. Usage: _dl_bin <url> <binary> [dest-name]
_dl_bin() {
  local url=$1 bin=$2 dest="${3:-$2}" tmp found
  mkdir -p "$HOME/.local/bin"
  tmp="$(mktemp -d)"
  curl -fL "$url" -o "$tmp/pkg" || { err "download failed: $url"; rm -rf "$tmp"; return 1; }
  mkdir -p "$tmp/x"
  case "$url" in
    *.zip) unzip -oq "$tmp/pkg" -d "$tmp/x" ;;
    *)     tar -xf "$tmp/pkg" -C "$tmp/x" ;;
  esac
  found="$(find "$tmp/x" -type f -name "$bin" | head -n1)"
  [ -n "$found" ] || { err "'$bin' not found in $url"; rm -rf "$tmp"; return 1; }
  install -m 755 "$found" "$HOME/.local/bin/$dest"
  rm -rf "$tmp"
}

# --- shell foundation ---------------------------------------------------------
install_special_ohmyzsh() {
  # Already present (e.g. under --upgrade): pull instead of re-running installer.
  if [ -d "$HOME/.oh-my-zsh" ]; then
    git -C "$HOME/.oh-my-zsh" pull --ff-only >/dev/null 2>&1 || true
    return 0
  fi
  # Unattended: don't switch shell, don't run zsh, don't touch our ~/.zshrc.
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

_clone_or_pull() {  # repo-url dir
  if [ -d "$2" ]; then git -C "$2" pull --ff-only >/dev/null 2>&1 || true
  else git clone --depth 1 "$1" "$2"; fi
}

install_special_zsh_autosuggestions() {
  _clone_or_pull https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
}

install_special_zsh_syntax_highlighting() {
  _clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
}

install_special_nerdfont() {
  command -v unzip >/dev/null 2>&1 || apt_install unzip
  local dest="$HOME/.local/share/fonts/FiraCode" tmp
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/FiraCode.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  mkdir -p "$dest"
  unzip -oq "$tmp/FiraCode.zip" -d "$dest"
  rm -rf "$tmp"
  fc-cache -f "$dest" >/dev/null 2>&1 || fc-cache -f >/dev/null 2>&1
}

# --- core CLI -----------------------------------------------------------------
install_special_zoxide() {
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_special_eza() {
  # Release asset carries no version in its name -> use /latest/download/.
  _dl_bin "https://github.com/eza-community/eza/releases/latest/download/eza_${RUST_TRIPLE}.tar.gz" eza
}

install_special_bat() {
  local t; t="$(gh_latest_tag sharkdp/bat)"
  _dl_bin "https://github.com/sharkdp/bat/releases/download/${t}/bat-${t}-${RUST_TRIPLE}.tar.gz" bat || return 1
  # Drop apt's duplicate (installs as `batcat`) so there's a single `bat`.
  dpkg -s bat >/dev/null 2>&1 && { step "removing apt 'bat' (batcat) in favor of upstream bat"; sudo apt-get remove -y -qq bat; }
  return 0
}

install_special_fd() {
  local t; t="$(gh_latest_tag sharkdp/fd)"
  _dl_bin "https://github.com/sharkdp/fd/releases/download/${t}/fd-${t}-${RUST_TRIPLE}.tar.gz" fd || return 1
  # Drop apt's duplicate (installs as `fdfind`) so there's a single `fd`.
  dpkg -s fd-find >/dev/null 2>&1 && { step "removing apt 'fd-find' (fdfind) in favor of upstream fd"; sudo apt-get remove -y -qq fd-find; }
  return 0
}

install_special_fzf() {
  [ -d "$HOME/.fzf" ] || git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  git -C "$HOME/.fzf" pull --ff-only >/dev/null 2>&1 || true
  "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
}

install_special_atuin() {
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
}

# --- git & dev ----------------------------------------------------------------
install_special_gitlfs() {
  apt_install git-lfs
  git lfs install --skip-repo
}

install_special_gh() {
  local key=/etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee "$key" >/dev/null
  sudo chmod go+r "$key"
  echo "deb [arch=$DEB_ARCH signed-by=$key] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  _APT_UPDATED=0            # force a refresh so the new repo is seen
  apt_install gh
}

install_special_delta() {
  local t; t="$(gh_latest_tag dandavison/delta)"   # delta tags have no 'v' prefix
  _dl_bin "https://github.com/dandavison/delta/releases/download/${t}/delta-${t}-${RUST_TRIPLE}.tar.gz" delta
}

install_special_lazygit() {
  local ver
  ver="$(gh_latest_tag jesseduffield/lazygit)"; ver="${ver#v}"
  _dl_bin "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${ver}_Linux_${REL_ARCH}.tar.gz" lazygit
}

install_special_just() {
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh \
    | bash -s -- --to "$HOME/.local/bin"
}

install_special_direnv() {
  export bin_path="$HOME/.local/bin"
  curl -sfL https://direnv.net/install.sh | bash
}

# --- python & data ------------------------------------------------------------
install_special_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
}

install_special_duckdb() {
  curl -fsSL https://install.duckdb.org | sh
}

# --- kubernetes ---------------------------------------------------------------
install_special_kubectl() {
  local ver tmp
  ver="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
  tmp="$(mktemp -d)"
  curl -fL -o "$tmp/kubectl" "https://dl.k8s.io/release/${ver}/bin/linux/${DEB_ARCH}/kubectl"
  install -m 0755 "$tmp/kubectl" "$HOME/.local/bin/kubectl"
  rm -rf "$tmp"
}

install_special_helm() {
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | HELM_INSTALL_DIR="$HOME/.local/bin" USE_SUDO=false bash
}

install_special_kustomize() {
  local tmp
  tmp="$(mktemp -d)"
  ( cd "$tmp" && curl -fsSL \
      https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash )
  install -m 0755 "$tmp/kustomize" "$HOME/.local/bin/kustomize"
  rm -rf "$tmp"
}

install_special_k9s() {
  local tmp
  tmp="$(mktemp -d)"
  curl -fL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${DEB_ARCH}.tar.gz" \
    -o "$tmp/k9s.tar.gz"
  tar -xf "$tmp/k9s.tar.gz" -C "$tmp" k9s
  install -m 0755 "$tmp/k9s" "$HOME/.local/bin/k9s"
  rm -rf "$tmp"
}

# --- monitoring ---------------------------------------------------------------
install_special_btop() {
  _dl_bin "https://github.com/aristocratos/btop/releases/latest/download/btop-${BTOP_ARCH}.tbz" btop
}

install_special_dust() {
  _dl_bin "$(gh_asset_url bootandy/dust "${RUST_TRIPLE}\.tar\.gz$")" dust
}

install_special_duf() {
  _dl_bin "$(gh_asset_url muesli/duf "linux_${ARCH_M}\.tar\.gz$")" duf
}

install_special_procs() {
  _dl_bin "$(gh_asset_url dalance/procs "${ARCH_M}-linux\.zip$")" procs
}

# --- data / json / yaml -------------------------------------------------------
install_special_yq() {
  _dl_rawbin "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${DEB_ARCH}" yq
}

install_special_jnv() {
  _dl_bin "$(gh_asset_url ynqa/jnv "${RUST_TRIPLE}\.tar\.xz$")" jnv
}

install_special_csvlens() {
  _dl_bin "$(gh_asset_url YS-L/csvlens "${RUST_TRIPLE}\.tar\.(gz|xz)$")" csvlens
}

# --- productivity -------------------------------------------------------------
install_special_tealdeer() {
  _dl_rawbin "$(gh_asset_url dbrgn/tealdeer "linux-${ARCH_M}-musl$")" tldr
}

install_special_sd() {
  _dl_bin "$(gh_asset_url chmln/sd "${RUST_TRIPLE}\.tar\.gz$")" sd
}

install_special_hyperfine() {
  _dl_bin "$(gh_asset_url sharkdp/hyperfine "${RUST_TRIPLE}\.tar\.gz$")" hyperfine
}

install_special_starship() {
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

install_special_zellij() {
  # Anchor on "zellij-<arch>" to avoid the separate "zellij-no-web-..." asset.
  _dl_bin "$(gh_asset_url zellij-org/zellij "zellij-${ARCH_M}-unknown-linux-musl\.tar\.gz$")" zellij
}

install_special_yazi() {
  _dl_bin "$(gh_asset_url sxyazi/yazi "${RUST_TRIPLE}\.zip$")" yazi
}

# --- containers ---------------------------------------------------------------
install_special_lazydocker() {
  _dl_bin "$(gh_asset_url jesseduffield/lazydocker "Linux_${REL_ARCH}\.tar\.gz$")" lazydocker
}

install_special_dive() {
  _dl_bin "$(gh_asset_url wagoodman/dive "linux_${DEB_ARCH}\.tar\.gz$")" dive
}

# --- kubernetes (colorizer) ---------------------------------------------------
install_special_kubecolor() {
  _dl_bin "$(gh_asset_url kubecolor/kubecolor "linux_${DEB_ARCH}\.tar\.gz$")" kubecolor
}
