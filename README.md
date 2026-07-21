# oh-my-terminal

A portable, reproducible terminal setup: a zsh foundation plus a curated set of
modern CLI tools, driven by an interactive installer. Clone it onto a fresh
Ubuntu/Debian machine (or WSL) and get the same shell in a few minutes.

The name is a nod to [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh), which is
the backbone of the shell layer here.

## Quickstart

```sh
git clone https://github.com/matze298/oh-my-terminal.git
cd oh-my-terminal
./setup.sh
```

You get an interactive checklist. Recommended **core** tools are pre-selected,
optional (`opt`) tools start unchecked, and anything already installed is shown
as `[installed]` and skipped. Toggle with numbers/ranges, then press Enter.

After it finishes, restart your terminal (or `exec zsh`).

## What it installs

Grouped by category in [`lib/tools.manifest`](lib/tools.manifest):

- **Shell foundation** (core): zsh, oh-my-zsh, agnoster prompt, FiraCode Nerd
  Font, zsh-autosuggestions, zsh-syntax-highlighting; starship (opt)
- **Core CLI** (core): zoxide, eza, bat, ripgrep, fd, fzf, atuin, tmux, jq, yq,
  jnv, sd, tealdeer; hyperfine, zellij, yazi (opt)
- **Git & dev**: git, git-lfs, gh, direnv, delta (core); lazygit, just (opt)
- **Python & data**: uv (core); duckdb, visidata, s5cmd, csvlens (opt)
- **Kubernetes**: kubectl, helm, kustomize, kubecolor (core); k9s, stern,
  kubectx (opt)
- **Monitoring**: btop, dust, duf, procs (core); nvtop, nvitop (opt)
- **Containers**: lazydocker, dive (opt)
- **Languages**: Go (auto-installed when an opt tool needs it)

Tools are pulled from their latest stable upstream release wherever the apt build
lags; apt is used only where it already ships current stable (ripgrep, jq,
kubectx) or a source build would be heavy (zsh, git, tmux, go).

## Flags

```
./setup.sh --dry-run   # show the plan, install/change nothing
./setup.sh --core      # non-interactive: core tier only
./setup.sh --all       # non-interactive: every not-yet-installed tool
./setup.sh --upgrade   # also (re)install already-installed tools, to move them to latest
./setup.sh --yes       # skip confirmation + identity prompts (use detected defaults)
```

Re-running is safe: installed tools are detected and skipped, so `setup.sh`
doubles as an updater. Add `--upgrade` to also refresh tools you already have to
their latest release. Start with `--dry-run` to preview.

## Configuration

`setup.sh` installs three configs, backing up any existing file to
`<file>.bak.<timestamp>`:

- `~/.zshrc` — the portable shell config (from [`dotfiles/zshrc`](dotfiles/zshrc))
- `~/.gitconfig` — delta, git-lfs, sensible diff/merge defaults
  (from [`dotfiles/gitconfig`](dotfiles/gitconfig))
- `~/.gitconfig.local` — your git `user.name` / `user.email`, prompted for and
  kept **out of version control**

Personal and org-specific bits stay in untracked overlays so the repo itself is
clean and portable:

- `~/.gitconfig.local` (git identity)
- `~/.zshrc.local` (optional, e.g. `export GH_HOST=your-org.ghe.com`) — created
  from [`dotfiles/zshrc.local.template`](dotfiles/zshrc.local.template) if you opt in

After installing, the script offers to authenticate the GitHub CLI (`gh auth
login` + `gh auth setup-git`) so the git credential helper works. You can
decline and stay unauthenticated. If your environment sets `GH_HOST` to a
GitHub Enterprise host, `gh` targets that by default, use
`gh auth login --hostname github.com` for public GitHub.

## Ghostty (optional)

Ghostty is the terminal *emulator* and is machine-specific, so it is **not** part
of the core setup. Install it and its config separately:

```sh
./ghostty/install-ghostty.sh
```

On WSL this is a no-op (use the Windows host terminal). On macOS use
`brew install --cask ghostty`.

## Layout

```
setup.sh              entry point
lib/tools.manifest    the tool list (single source of truth)
lib/install.sh        install methods + per-tool installers
lib/ui.sh             the interactive checklist
lib/dotfiles.sh       config install + identity overlays
lib/common.sh         logging, platform/arch detection, apt/go/uv helpers
dotfiles/             portable ~/.zshrc and ~/.gitconfig
ghostty/              opt-in emulator installer + config
docs/                 the how-to notes this setup is based on
```

## Docs

The [`docs/`](docs/) folder holds the how-to notes the toolkit is based on.
[`docs/Setup-Inventory.md`](docs/Setup-Inventory.md) is the annotated parts list;
[`docs/Terminal-Toolkit.md`](docs/Terminal-Toolkit.md) is the index.

## Extending

- **Add a tool**: one line in `lib/tools.manifest`. Use an existing `method`
  (`apt`, `uv`, `go`) or add an `install_special_<name>` function to
  `lib/install.sh` and reference it with `method=special`, `arg=<name>`.
- **macOS**: currently unsupported. The extension point is a Homebrew branch in
  `install_tool` plus OS-aware methods in the manifest.
